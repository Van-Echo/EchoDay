import 'dart:async';
import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../app/platform/platform_capabilities.dart';
import '../../../app/providers/data_providers.dart';
import '../application/sync_client_controller.dart';
import '../domain/sync_client_models.dart';
import '../domain/sync_merge_engine.dart';
import '../domain/sync_pairing_document.dart';
import '../server/sync_lan_pairing_discovery.dart';
import 'sync_status_badge.dart';

class SyncClientSettingsSection extends ConsumerStatefulWidget {
  const SyncClientSettingsSection({super.key, this.embedded = false});

  final bool embedded;

  @override
  ConsumerState<SyncClientSettingsSection> createState() =>
      _SyncClientSettingsSectionState();
}

class _SyncClientSettingsSectionState
    extends ConsumerState<SyncClientSettingsSection> {
  final _codeController = TextEditingController();
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  String? _seededEndpoint;
  bool _discovering = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncClientControllerProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final state = ref.watch(syncClientControllerProvider);
    final content = <Widget>[
      Text(
        ref.watch(platformCapabilitiesProvider).isAndroid
            ? strings.syncClientDescription
            : strings.syncClientDesktopDescription,
      ),
      const SizedBox(height: 16),
      if (!state.loaded || state.phase == SyncClientPhase.connecting)
        const LinearProgressIndicator(),
      if (state.phase == SyncClientPhase.waitingForApproval)
        _ApprovalPanel(state: state),
      if (!state.connected && state.phase != SyncClientPhase.waitingForApproval)
        _buildDisconnected(strings, state),
      if (state.profile case final profile?)
        _buildConnected(strings, state, profile),
      if (state.messageCode case final code?) ...[
        const SizedBox(height: 12),
        Text(
          _messageText(strings, code),
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ],
    ];
    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: content,
      );
    }
    return Card(
      key: const ValueKey('sync-client-settings'),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: SyncStatusBadge(
          icon: Icons.sync_lock_rounded,
          semanticLabel: strings.syncAttentionSemantics,
          issueCount: state.conflicts.length,
          hasWarning: state.needsAttention,
        ),
        title: Text(strings.syncClientTitle),
        subtitle: Text(
          _phaseText(strings, state),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: content,
      ),
    );
  }

  Widget _buildDisconnected(
    AppLocalizations strings,
    SyncClientViewState state,
  ) {
    final controller = ref.read(syncClientControllerProvider.notifier);
    final isAndroid = ref.read(platformCapabilitiesProvider).isAndroid;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isAndroid) ...[
          FilledButton.icon(
            key: const ValueKey('sync-scan-qr'),
            onPressed: state.busy ? null : _scan,
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: Text(strings.syncScanQr),
          ),
          const SizedBox(height: 10),
        ] else ...[
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                key: const ValueKey('sync-discover-nearby'),
                onPressed: state.busy || _discovering ? null : _discoverNearby,
                icon: _discovering
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.radar_rounded),
                label: Text(strings.syncDiscoverNearby),
              ),
              OutlinedButton.icon(
                key: const ValueKey('sync-import-pairing-file'),
                onPressed: state.busy ? null : _importPairingFile,
                icon: const Icon(Icons.file_open_rounded),
                label: Text(strings.syncImportPairingFile),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildEndpointEditor(strings, state, connected: false),
          const SizedBox(height: 6),
          Text(
            strings.syncHostOverrideHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
        ],
        TextField(
          key: const ValueKey('sync-pairing-code-input'),
          controller: _codeController,
          enabled: !state.busy,
          minLines: 1,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: strings.syncPairingCodeLabel,
            prefixIcon: const Icon(Icons.content_paste_rounded),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton(
            key: const ValueKey('sync-connect-code'),
            onPressed: state.busy
                ? null
                : () => unawaited(
                    controller.pair(
                      _codeController.text,
                      addressOverride: isAndroid ? null : _hostController.text,
                      portOverride: isAndroid || _portController.text.isEmpty
                          ? null
                          : int.tryParse(_portController.text) ?? 0,
                    ),
                  ),
            child: Text(strings.syncConnect),
          ),
        ),
      ],
    );
  }

  Widget _buildConnected(
    AppLocalizations strings,
    SyncClientViewState state,
    SyncClientProfile profile,
  ) {
    final controller = ref.read(syncClientControllerProvider.notifier);
    final endpointKey = '${profile.address}:${profile.port}';
    if (_seededEndpoint != endpointKey) {
      _seededEndpoint = endpointKey;
      _hostController.text = profile.address;
      _portController.text = '${profile.port}';
    }
    final lastSync = profile.lastSyncAt == null
        ? strings.syncNeverSynced
        : strings.syncLastSynced(_formatTime(profile.lastSyncAt!.toLocal()));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.computer_rounded),
          title: Text(profile.hostDevice.displayName),
          subtitle: Text(
            '${strings.syncClientAddress('${profile.address}:${profile.port}')}'
            '\n$lastSync',
          ),
          isThreeLine: true,
        ),
        if (state.lastResult case final result?)
          Text(
            strings.syncClientLastResult(
              result.uploaded,
              result.downloaded,
              result.conflicts,
            ),
          ),
        const SizedBox(height: 12),
        if (ref.read(platformCapabilitiesProvider).isWindows) ...[
          _buildEndpointEditor(strings, state, connected: true),
          const SizedBox(height: 12),
        ],
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              key: const ValueKey('sync-client-now'),
              onPressed: state.busy
                  ? null
                  : () => unawaited(controller.synchronize()),
              icon: state.phase == SyncClientPhase.syncing
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync_rounded),
              label: Text(strings.syncNow),
            ),
            OutlinedButton.icon(
              key: const ValueKey('sync-client-conflicts'),
              onPressed: () => _showConflicts(state.conflicts),
              icon: SyncStatusBadge(
                icon: state.conflicts.isEmpty
                    ? Icons.check_circle_outline_rounded
                    : Icons.warning_amber_rounded,
                semanticLabel: strings.syncAttentionSemantics,
                issueCount: state.conflicts.length,
              ),
              label: Text(strings.syncConflicts(state.conflicts.length)),
            ),
            TextButton.icon(
              key: const ValueKey('sync-client-disconnect'),
              onPressed: state.busy ? null : _confirmDisconnect,
              icon: const Icon(Icons.link_off_rounded),
              label: Text(strings.syncClientDisconnect),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEndpointEditor(
    AppLocalizations strings,
    SyncClientViewState state, {
    required bool connected,
  }) {
    final host = TextField(
      key: ValueKey(connected ? 'sync-connected-host' : 'sync-host-override'),
      controller: _hostController,
      enabled: !state.busy,
      decoration: InputDecoration(
        labelText: connected
            ? strings.syncHostAddress
            : strings.syncHostOverride,
        hintText: connected ? null : '100.x.x.x / main-pc.tailnet.ts.net',
        prefixIcon: const Icon(Icons.dns_rounded),
      ),
    );
    final port = TextField(
      key: ValueKey(connected ? 'sync-connected-port' : 'sync-port-override'),
      controller: _portController,
      enabled: !state.busy,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: strings.syncPort),
    );
    final action = OutlinedButton.icon(
      key: const ValueKey('sync-save-endpoint'),
      onPressed: state.busy
          ? null
          : () => unawaited(
              ref
                  .read(syncClientControllerProvider.notifier)
                  .updateEndpointAndSynchronize(
                    _hostController.text,
                    int.tryParse(_portController.text) ?? 0,
                  ),
            ),
      icon: const Icon(Icons.refresh_rounded),
      label: Text(strings.syncSaveAndRetry),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final stack =
            constraints.maxWidth < 620 ||
            MediaQuery.textScalerOf(context).scale(16) >= 25;
        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              host,
              const SizedBox(height: 10),
              port,
              if (connected) ...[
                const SizedBox(height: 10),
                Align(alignment: Alignment.centerRight, child: action),
              ],
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: host),
            const SizedBox(width: 10),
            SizedBox(width: 150, child: port),
            if (connected) ...[const SizedBox(width: 10), action],
          ],
        );
      },
    );
  }

  Future<void> _scan() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const _SyncQrScannerPage()),
    );
    if (result == null || !mounted) return;
    _codeController.text = result;
    unawaited(ref.read(syncClientControllerProvider.notifier).pair(result));
  }

  Future<void> _importPairingFile() async {
    const types = XTypeGroup(
      label: 'EchoDay pairing',
      extensions: [SyncPairingDocumentCodec.extension, 'json', 'txt'],
    );
    try {
      final file = await openFile(acceptedTypeGroups: const [types]);
      if (file == null || !mounted) return;
      final source = SyncPairingDocumentCodec.decode(await file.readAsString());
      _codeController.text = source;
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).syncPairingFileInvalid),
        ),
      );
    }
  }

  Future<void> _discoverNearby() async {
    final strings = AppLocalizations.of(context);
    setState(() => _discovering = true);
    try {
      final hosts = await ref.read(syncLanPairingDiscoveryProvider).discover();
      if (!mounted) return;
      if (hosts.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(strings.syncNoNearbyHost)));
        return;
      }
      final selected = hosts.length == 1
          ? hosts.single
          : await showDialog<DiscoveredSyncHost>(
              context: context,
              builder: (context) => SimpleDialog(
                title: Text(strings.syncChooseNearbyHost),
                children: [
                  for (final host in hosts)
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, host),
                      child: ListTile(
                        leading: const Icon(Icons.computer_rounded),
                        title: Text(host.name),
                        subtitle: Text(
                          '${host.endpoint.address}:${host.endpoint.port}',
                        ),
                      ),
                    ),
                ],
              ),
            );
      if (selected == null || !mounted) return;
      _codeController.text = selected.pairingUri;
      _hostController.text = selected.endpoint.address;
      _portController.text = '${selected.endpoint.port}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.syncNearbyHostFound(selected.name))),
      );
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(strings.syncDiscoveryFailed)));
    } finally {
      if (mounted) setState(() => _discovering = false);
    }
  }

  Future<void> _confirmDisconnect() async {
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.syncClientDisconnectTitle),
        content: Text(strings.syncClientDisconnectBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.syncClientDisconnectAction),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(syncClientControllerProvider.notifier).disconnect();
    }
  }

  Future<void> _showConflicts(List<SyncConflict> initial) async {
    final strings = AppLocalizations.of(context);
    var conflicts = initial;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(strings.syncConflictTitle),
          content: SizedBox(
            width: 620,
            child: conflicts.isEmpty
                ? Text(strings.syncConflictEmpty)
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: conflicts.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final conflict = conflicts[index];
                      final payload = const JsonEncoder.withIndent('  ')
                          .convert(conflict.losingPayload);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '${conflict.entityType.wireName} · '
                          '${conflict.fieldGroup.wireName}',
                        ),
                        subtitle: SelectableText(
                          payload.length > 500
                              ? '${payload.substring(0, 500)}…'
                              : payload,
                        ),
                        trailing: FilledButton(
                          onPressed: () async {
                            await ref
                                .read(syncClientControllerProvider.notifier)
                                .resolveConflict(conflict.id);
                            conflicts = ref
                                .read(syncClientControllerProvider)
                                .conflicts;
                            if (dialogContext.mounted) {
                              setDialogState(() {});
                            }
                          },
                          child: Text(strings.syncRestoreVersion),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(strings.close),
            ),
          ],
        ),
      ),
    );
  }
}

final class _ApprovalPanel extends ConsumerWidget {
  const _ApprovalPanel({required this.state});

  final SyncClientViewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              state.verificationCode ?? '------',
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(letterSpacing: 8, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(strings.syncClientVerificationHint),
            if (state.pairingExpiresAt case final expires?) ...[
              const SizedBox(height: 6),
              Text(strings.syncExpiresAt(_formatTime(expires))),
            ],
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref
                  .read(syncClientControllerProvider.notifier)
                  .cancelPairing(),
              child: Text(strings.cancel),
            ),
          ],
        ),
      ),
    );
  }
}

final class _SyncQrScannerPage extends StatefulWidget {
  const _SyncQrScannerPage();

  @override
  State<_SyncQrScannerPage> createState() => _SyncQrScannerPageState();
}

final class _SyncQrScannerPageState extends State<_SyncQrScannerPage> {
  late final MobileScannerController _controller;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    // The native camera permission is requested only now, after the user has
    // explicitly opened this scanner page.
    _controller = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.noDuplicates,
      autoZoom: true,
    );
  }

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.syncScannerTitle)),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_handled) return;
              for (final barcode in capture.barcodes) {
                final value = barcode.rawValue;
                if (value == null || value.isEmpty) continue;
                try {
                  SyncPairingUriCodec.parse(value);
                } on FormatException {
                  continue;
                }
                _handled = true;
                Navigator.pop(context, value);
                return;
              }
            },
            errorBuilder: (context, _) => ColoredBox(
              color: Colors.black,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    strings.syncScannerPermissionDenied,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 36,
            child: Text(
              strings.syncScannerHint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatTime(DateTime value) =>
    DateFormat('yyyy-MM-dd HH:mm').format(value);

String _phaseText(AppLocalizations strings, SyncClientViewState state) {
  if (state.conflicts.isNotEmpty) {
    return strings.syncConflictsNeedAttention(state.conflicts.length);
  }
  return switch (state.phase) {
    SyncClientPhase.disconnected => strings.syncClientDisconnected,
    SyncClientPhase.connecting => strings.syncClientConnecting,
    SyncClientPhase.waitingForApproval => strings.syncClientWaitingApproval,
    SyncClientPhase.syncing => strings.syncClientSyncing,
    SyncClientPhase.synced => strings.syncClientSynced,
    SyncClientPhase.offline => strings.syncClientOffline,
    SyncClientPhase.error => strings.syncClientError,
  };
}

String _messageText(AppLocalizations strings, String code) => switch (code) {
  'invalid_pairing_code' ||
  'pairing_response_invalid' => strings.syncClientInvalidCode,
  'host_unreachable' || 'network_error' => strings.syncClientHostUnreachable,
  'pairing_rejected' => strings.syncClientPairRejected,
  'invite_expired' => strings.syncClientInviteExpired,
  'fingerprint_mismatch' => strings.syncClientFingerprintMismatch,
  'protocol_incompatible' ||
  'schema_incompatible' => strings.syncClientProtocolIncompatible,
  'already_in_sync_group' => strings.syncClientAlreadyConnected,
  'device_revoked' => strings.syncClientDeviceRevoked,
  'unauthorized' || 'replay_detected' => strings.syncClientAuthenticationFailed,
  'invalid_host_address' => strings.syncInvalidHostAddress,
  'disconnect_failed' => strings.syncClientDisconnectFailed,
  _ => strings.syncClientSyncFailed,
};
