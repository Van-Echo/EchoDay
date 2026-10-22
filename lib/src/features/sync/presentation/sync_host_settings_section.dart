import 'dart:async';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../application/sync_client_controller.dart';
import '../application/sync_host_controller.dart';
import '../domain/sync_client_models.dart';
import '../domain/sync_endpoint_update.dart';
import '../domain/sync_merge_engine.dart';
import '../domain/sync_pairing_document.dart';
import '../security/sync_pairing_service.dart';
import '../server/secure_sync_host_service.dart';
import '../server/sync_lan_pairing_discovery.dart';
import '../server/sync_network_discovery.dart';
import 'sync_client_settings_section.dart';
import 'sync_conflict_comparison.dart';
import 'sync_conflict_description.dart';
import 'sync_status_badge.dart';

class SyncHostSettingsSection extends ConsumerStatefulWidget {
  const SyncHostSettingsSection({super.key});

  @override
  ConsumerState<SyncHostSettingsSection> createState() =>
      _SyncHostSettingsSectionState();
}

class _SyncHostSettingsSectionState
    extends ConsumerState<SyncHostSettingsSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncHostControllerProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final state = ref.watch(syncHostControllerProvider);
    final clientState = ref.watch(syncClientControllerProvider);
    final controller = ref.read(syncHostControllerProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final hostIssueCount =
        state.conflicts.length +
        state.devices.where((device) => device.requiresUpgrade).length;
    final clientIssueCount = clientState.conflicts.length;
    final issueCount = state.mode == SyncOperatingMode.client
        ? clientIssueCount
        : hostIssueCount;
    final hasWarning = state.mode == SyncOperatingMode.client
        ? clientState.needsAttention
        : state.lifecycle == SyncHostLifecycle.failed ||
              state.messageCode != null;

    return Card(
      key: const ValueKey('sync-host-settings'),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: SyncStatusBadge(
          icon: Icons.sync_lock_rounded,
          semanticLabel: strings.syncAttentionSemantics,
          issueCount: issueCount,
          hasWarning: hasWarning,
        ),
        title: Text(strings.syncHostTitle),
        subtitle: Text(
          state.mode == SyncOperatingMode.client
              ? _clientStatusText(strings, clientState)
              : _statusText(strings, state.lifecycle),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(strings.syncHostDescription),
          const SizedBox(height: 16),
          DropdownButtonFormField<SyncOperatingMode>(
            key: const ValueKey('sync-mode-field'),
            initialValue: state.mode,
            isExpanded: true,
            decoration: InputDecoration(labelText: strings.syncModeLabel),
            items: [
              DropdownMenuItem(
                value: SyncOperatingMode.off,
                child: Text(
                  strings.syncModeOff,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DropdownMenuItem(
                value: SyncOperatingMode.host,
                child: Text(
                  strings.syncModeHost,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DropdownMenuItem(
                value: SyncOperatingMode.client,
                child: Text(
                  strings.syncModeClient,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            onChanged:
                state.busy ||
                    (state.mode == SyncOperatingMode.client && clientState.busy)
                ? null
                : (mode) {
                    if (mode != null) {
                      _run(() => controller.setMode(mode));
                    }
                  },
          ),
          if (!state.loaded || state.busy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          if (state.messageCode case final message?) ...[
            const SizedBox(height: 12),
            Text(
              _messageText(strings, message),
              style: TextStyle(color: colorScheme.error),
            ),
          ],
          if (state.mode == SyncOperatingMode.host) ...[
            const SizedBox(height: 18),
            _HostConnectionPanel(state: state, onRun: _run),
            const SizedBox(height: 18),
            SwitchListTile.adaptive(
              key: const ValueKey('sync-launch-at-startup'),
              contentPadding: EdgeInsets.zero,
              title: Text(strings.syncLaunchAtStartup),
              value: state.launchAtStartup,
              onChanged: state.busy
                  ? null
                  : (value) => _run(() => controller.setLaunchAtStartup(value)),
            ),
            SwitchListTile.adaptive(
              key: const ValueKey('sync-keep-in-tray'),
              contentPadding: EdgeInsets.zero,
              title: Text(strings.syncKeepInTray),
              value: state.keepRunningInTray,
              onChanged: (value) =>
                  _run(() => controller.setKeepRunningInTray(value)),
            ),
            if (state.pendingPairings.isNotEmpty) ...[
              const Divider(height: 32),
              Text(
                strings.syncPendingPairings,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              for (final pending in state.pendingPairings)
                _PendingPairingTile(pending: pending, onRun: _run),
            ],
            const Divider(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  strings.syncDevicesTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                OutlinedButton.icon(
                  key: const ValueKey('sync-all-devices'),
                  onPressed: state.lifecycle == SyncHostLifecycle.running
                      ? () => _syncAll(controller)
                      : null,
                  icon: const Icon(Icons.sync_rounded),
                  label: Text(strings.syncAll),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final device in state.devices)
              _DeviceTile(device: device, onRun: _run),
            const Divider(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                key: const ValueKey('sync-conflicts-button'),
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
            ),
          ],
          if (state.mode == SyncOperatingMode.client) ...[
            const SizedBox(height: 18),
            const SyncClientSettingsSection(embedded: true),
          ],
        ],
      ),
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).syncOperationFailed),
        ),
      );
    }
  }

  Future<void> _syncAll(SyncHostController controller) async {
    try {
      final count = await controller.requestAllDeviceSyncs();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).syncRequestedCount(count)),
        ),
      );
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).syncOperationFailed),
        ),
      );
    }
  }

  Future<void> _showConflicts(List<SyncConflict> initial) async {
    final strings = AppLocalizations.of(context);
    var conflicts = initial;
    var resolving = false;
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
                      final description = SyncConflictDescription.from(
                        conflict,
                        strings,
                      );
                      return SyncConflictComparison(
                        description: description,
                        busy: resolving,
                        onChoose: (useLosingVersion) async {
                          if (resolving) return;
                          setDialogState(() => resolving = true);
                          try {
                            await ref
                                .read(syncHostControllerProvider.notifier)
                                .resolveConflict(
                                  conflict.id,
                                  useLosingVersion: useLosingVersion,
                                );
                            conflicts = ref
                                .read(syncHostControllerProvider)
                                .conflicts;
                          } finally {
                            if (dialogContext.mounted) {
                              setDialogState(() => resolving = false);
                            }
                          }
                        },
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

final class _HostConnectionPanel extends ConsumerWidget {
  const _HostConnectionPanel({required this.state, required this.onRun});

  final SyncHostViewState state;
  final Future<void> Function(Future<void> Function()) onRun;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final controller = ref.read(syncHostControllerProvider.notifier);
    final binding = state.binding;
    final selectedSaved = state.savedNetworks
        .where(
          (saved) =>
              saved.resolve(state.networks)?.address.address ==
              state.selectedAddress,
        )
        .firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: strings.syncAddressLabel,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    key: const ValueKey('sync-address-field'),
                    value:
                        state.availableSavedNetworks.any(
                          (item) =>
                              item.address.address == state.selectedAddress,
                        )
                        ? state.selectedAddress
                        : null,
                    isExpanded: true,
                    isDense: true,
                    items: [
                      for (final saved in state.savedNetworks)
                        DropdownMenuItem(
                          value:
                              saved.resolve(state.networks)?.address.address ??
                              'offline:${saved.id}',
                          enabled: saved.resolve(state.networks) != null,
                          child: Text(
                            '${saved.resolve(state.networks)?.address.address ?? saved.address} · '
                            '${saved.interfaceName}'
                            '${saved.id == state.defaultNetworkId ? " · ${strings.syncDefaultNetwork}" : ""}'
                            '${saved.resolve(state.networks) == null ? " · ${strings.syncNetworkOffline}" : ""}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      DropdownMenuItem(
                        value: '__add_network__',
                        child: Row(
                          children: [
                            const Icon(Icons.add_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(strings.syncAddNetwork),
                          ],
                        ),
                      ),
                    ],
                    onChanged: state.busy
                        ? null
                        : (value) {
                            if (value == '__add_network__') {
                              _showAddNetwork(context, ref);
                            } else if (value != null) {
                              onRun(() => controller.selectAddress(value));
                            }
                          },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.outlined(
              key: const ValueKey('sync-default-network'),
              tooltip: strings.syncSetDefaultNetwork,
              onPressed: state.busy || selectedSaved == null
                  ? null
                  : () => onRun(
                      () => controller.setDefaultNetwork(selectedSaved.id),
                    ),
              icon: Icon(
                selectedSaved?.id == state.defaultNetworkId
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
              ),
            ),
            const SizedBox(width: 6),
            IconButton.outlined(
              tooltip: strings.syncRefreshNetworks,
              onPressed: state.busy
                  ? null
                  : () => onRun(controller.refreshNetworks),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        if (binding != null) ...[
          const SizedBox(height: 12),
          SelectableText(strings.syncEndpointLabel('${binding.endpoint}')),
          const SizedBox(height: 4),
          SelectableText(
            strings.syncFingerprintLabel(
              _groupFingerprint(binding.fingerprintSha256),
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              key: const ValueKey('sync-create-pairing'),
              onPressed: state.lifecycle == SyncHostLifecycle.running
                  ? () => _showPairing(context, ref)
                  : null,
              icon: const Icon(Icons.qr_code_2_rounded),
              label: Text(strings.syncCreatePairing),
            ),
            OutlinedButton.icon(
              key: const ValueKey('sync-update-wlan'),
              onPressed:
                  state.busy || state.lifecycle != SyncHostLifecycle.running
                  ? null
                  : () => _showEndpointUpdate(context, ref),
              icon: const Icon(Icons.wifi_rounded),
              label: Text(strings.syncUpdateWlan),
            ),
            OutlinedButton.icon(
              key: const ValueKey('sync-restart-host'),
              onPressed: state.busy ? null : () => onRun(controller.restart),
              icon: const Icon(Icons.restart_alt_rounded),
              label: Text(strings.syncRestartHost),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showAddNetwork(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(syncHostControllerProvider.notifier);
    await onRun(controller.refreshNetworks);
    if (!context.mounted) return;
    final strings = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final current = ref.watch(syncHostControllerProvider);
          final candidates = <String, SyncNetworkEndpoint>{
            for (final endpoint in current.networks)
              if (!current.savedNetworks.any(
                (saved) =>
                    saved.id == SavedSyncNetwork.fromEndpoint(endpoint).id,
              ))
                SavedSyncNetwork.fromEndpoint(endpoint).id: endpoint,
          }.values.toList();
          return AlertDialog(
            title: Text(strings.syncAddNetworkTitle),
            content: SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(strings.syncAddNetworkHint),
                    const SizedBox(height: 12),
                    if (candidates.isEmpty) Text(strings.syncNoNewNetworks),
                    for (final endpoint in candidates)
                      ListTile(
                        leading: const Icon(Icons.add_circle_outline_rounded),
                        title: Text(endpoint.interfaceName),
                        subtitle: Text(
                          '${endpoint.address.address} · ${_networkName(endpoint.kind)}',
                        ),
                        onTap: () async {
                          await controller.addNetwork(endpoint);
                          if (context.mounted) Navigator.pop(context);
                        },
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(strings.close),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showPairing(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(syncHostControllerProvider.notifier);
    final invite = await controller.createPairingInvite();
    if (invite == null || !context.mounted) return;
    final uri = await controller.pairingUri(invite);
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => _PairingDialog(invite: invite, uri: uri),
    );
  }

  Future<void> _showEndpointUpdate(BuildContext context, WidgetRef ref) async {
    await onRun(() async {
      final uri = await ref
          .read(syncHostControllerProvider.notifier)
          .endpointUpdateUri();
      if (!context.mounted) return;
      final strings = AppLocalizations.of(context);
      final update = SyncEndpointUpdateCodec.parse(uri.toString());
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(strings.syncUpdateWlan),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(strings.syncEndpointUpdateHint),
                  const SizedBox(height: 16),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: QrImageView(
                        key: const ValueKey('sync-endpoint-update-qr'),
                        data: uri.toString(),
                        size: 220,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(update.endpoint.displayName),
                  Text(
                    strings.syncExpiresAt(
                      _formatTime(update.expiresAt.toLocal()),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: uri.toString()));
              },
              icon: const Icon(Icons.copy_rounded),
              label: Text(strings.syncCopy),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(strings.close),
            ),
          ],
        ),
      );
    });
  }
}

final class _PairingDialog extends ConsumerStatefulWidget {
  const _PairingDialog({
    required this.invite,
    required this.uri,
    this.repair = false,
  });

  final SyncPairingInvite invite;
  final Uri uri;
  final bool repair;

  @override
  ConsumerState<_PairingDialog> createState() => _PairingDialogState();
}

final class _PairingDialogState extends ConsumerState<_PairingDialog> {
  final _advertiser = SyncLanPairingAdvertiser();
  Timer? _pollTimer;
  bool _polling = false;
  bool _busy = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(
      _advertiser
          .start(name: Platform.localHostname, pairingUri: widget.uri)
          .catchError((_) {}),
    );
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_polling || !mounted) return;
      _polling = true;
      try {
        await ref.read(syncHostControllerProvider.notifier).refreshAdminData();
      } on Object {
        // A transient refresh failure must not dismiss an unconfirmed invite.
      } finally {
        _polling = false;
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    unawaited(_advertiser.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final code = _groupCode(widget.invite.token);
    final pending = ref
        .watch(syncHostControllerProvider)
        .pendingPairings
        .where((request) => request.inviteId == widget.invite.id)
        .toList();
    return AlertDialog(
      key: const ValueKey('sync-pairing-dialog'),
      title: Text(
        widget.repair ? strings.syncRePair : strings.syncPairingTitle,
      ),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.repair
                    ? strings.syncRePairHostHint
                    : strings.syncPairingHint,
              ),
              const SizedBox(height: 16),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: QrImageView(
                    key: const ValueKey('sync-pairing-qr'),
                    data: widget.uri.toString(),
                    size: 220,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  strings.syncConnectionCode,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(height: 6),
              SelectableText(
                code,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
              const SizedBox(height: 8),
              Text(strings.syncExpiresAt(_formatTime(widget.invite.expiresAt))),
              const Divider(height: 24),
              if (pending.isEmpty) Text(strings.syncPairingWaiting),
              for (final request in pending)
                _PendingPairingTile(
                  pending: request,
                  busy: _busy,
                  onRun: _runPairingAction,
                  onApproved: () {
                    if (mounted) Navigator.pop(context);
                  },
                ),
              if (_failed)
                Text(
                  strings.syncOperationFailed,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          key: const ValueKey('sync-export-pairing-file'),
          onPressed: () => _exportPairingFile(context),
          icon: const Icon(Icons.save_alt_rounded),
          label: Text(strings.syncExportPairingFile),
        ),
        TextButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: widget.uri.toString()));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(strings.syncCopied)));
          },
          icon: const Icon(Icons.copy_rounded),
          label: Text(strings.syncCopy),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.close),
        ),
      ],
    );
  }

  Future<void> _runPairingAction(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await action();
    } on Object {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportPairingFile(BuildContext context) async {
    const type = XTypeGroup(
      label: 'EchoDay pairing',
      extensions: [SyncPairingDocumentCodec.extension],
    );
    try {
      final location = await getSaveLocation(
        suggestedName:
            'EchoDay-${DateFormat('yyyyMMdd-HHmm').format(DateTime.now())}'
            '.${SyncPairingDocumentCodec.extension}',
        acceptedTypeGroups: const [type],
      );
      if (location == null) return;
      final document = SyncPairingDocumentCodec.encode(
        pairingUri: widget.uri,
        expiresAt: widget.invite.expiresAt,
      );
      await File(location.path).writeAsString(document, flush: true);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).syncPairingFileExported),
        ),
      );
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).syncOperationFailed),
        ),
      );
    }
  }
}

final class _PendingPairingTile extends ConsumerWidget {
  const _PendingPairingTile({
    required this.pending,
    required this.onRun,
    this.onApproved,
    this.busy = false,
  });

  final PendingPairingRequest pending;
  final Future<void> Function(Future<void> Function()) onRun;
  final VoidCallback? onApproved;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final controller = ref.read(syncHostControllerProvider.notifier);
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(_platformIcon(pending.device.platform)),
                const SizedBox(width: 8),
                Expanded(child: Text(pending.device.displayName)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${pending.device.platform} · ${pending.device.appVersion}\n'
              '${strings.syncVerificationCode(pending.verificationCode)} · '
              '${strings.syncExpiresAt(_formatTime(pending.expiresAt))}',
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: busy
                      ? null
                      : () => onRun(() => controller.rejectPairing(pending.id)),
                  child: Text(strings.syncReject),
                ),
                FilledButton(
                  key: ValueKey('sync-approve-${pending.id}'),
                  onPressed: busy
                      ? null
                      : () => onRun(() async {
                          await controller.approvePairing(pending.id);
                          onApproved?.call();
                        }),
                  child: Text(strings.syncApprove),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final class _DeviceTile extends ConsumerWidget {
  const _DeviceTile({required this.device, required this.onRun});

  final ManagedSyncDevice device;
  final Future<void> Function(Future<void> Function()) onRun;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final controller = ref.read(syncHostControllerProvider.notifier);
    final revoked = device.revokedAt != null;
    final status = revoked
        ? strings.syncRevoked
        : device.requiresUpgrade
        ? strings.syncNeedsUpgrade
        : device.syncRequested
        ? strings.syncWaiting
        : device.isOnline
        ? strings.syncOnline
        : strings.syncOffline;
    final lastSync = device.lastSyncAt == null
        ? strings.syncNeverSynced
        : strings.syncLastSynced(_formatTime(device.lastSyncAt!));
    final actionStyle = IconButton.styleFrom(
      minimumSize: const Size.square(36),
      maximumSize: const Size.square(36),
      padding: const EdgeInsets.all(6),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    final actions = Row(
      key: ValueKey('sync-device-actions-${device.id}'),
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          key: ValueKey('sync-repair-device-${device.id}'),
          tooltip: strings.syncRePair,
          style: actionStyle,
          onPressed:
              revoked ||
                  ref.watch(syncHostControllerProvider).lifecycle !=
                      SyncHostLifecycle.running
              ? null
              : () => onRun(() async {
                  final invite = await controller.createPairingInvite();
                  if (invite == null) return;
                  final uri = await controller.pairingUri(invite);
                  if (!context.mounted) return;
                  await showDialog<void>(
                    context: context,
                    builder: (_) =>
                        _PairingDialog(invite: invite, uri: uri, repair: true),
                  );
                }),
          icon: const Icon(Icons.link_rounded, size: 20),
        ),
        IconButton(
          key: ValueKey('sync-rename-device-${device.id}'),
          tooltip: strings.syncEditNote,
          style: actionStyle,
          onPressed: revoked ? null : () => _editNote(context, controller),
          icon: const Icon(Icons.edit_note_rounded, size: 20),
        ),
        IconButton(
          key: ValueKey('sync-device-now-${device.id}'),
          tooltip: strings.syncNow,
          style: actionStyle,
          onPressed: revoked
              ? null
              : () => onRun(() => controller.requestDeviceSync(device.id)),
          icon: const Icon(Icons.sync_rounded, size: 20),
        ),
        IconButton(
          key: ValueKey('sync-revoke-device-${device.id}'),
          tooltip: strings.syncRevoke,
          style: actionStyle,
          onPressed: revoked ? null : () => _confirmRevoke(context, controller),
          icon: const Icon(Icons.link_off_rounded, size: 20),
        ),
      ],
    );
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SyncStatusBadge(
                  icon: _platformIcon(device.platform),
                  semanticLabel: strings.syncAttentionSemantics,
                  hasWarning:
                      revoked ||
                      device.requiresUpgrade ||
                      (!device.isLocal && !device.isOnline),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Tooltip(
                    message: device.displayLabel,
                    child: Text(
                      device.displayLabel,
                      key: ValueKey('sync-device-title-${device.id}'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (device.isLocal)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(strings.syncLocalDevice),
                  )
                else
                  actions,
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 36, top: 4),
              child: Text(
                '${device.platform} · ${device.appVersion} · $status\n$lastSync',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editNote(
    BuildContext context,
    SyncHostController controller,
  ) async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => _DeviceNameDialog(initialName: device.displayLabel),
    );
    if (value != null) {
      await onRun(() => controller.updateDeviceNote(device.id, value));
    }
  }

  Future<void> _confirmRevoke(
    BuildContext context,
    SyncHostController controller,
  ) async {
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.syncRevokeConfirmTitle),
        content: Text(strings.syncRevokeConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.syncRevoke),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.revokeDevice(device.id);
  }
}

final class _DeviceNameDialog extends StatefulWidget {
  const _DeviceNameDialog({required this.initialName});
  final String initialName;

  @override
  State<_DeviceNameDialog> createState() => _DeviceNameDialogState();
}

final class _DeviceNameDialogState extends State<_DeviceNameDialog> {
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(strings.syncEditNote),
      content: TextField(
        key: const ValueKey('sync-device-name-input'),
        controller: _name,
        autofocus: true,
        maxLength: 120,
        decoration: InputDecoration(
          labelText: strings.syncDeviceNote,
          helperText: strings.syncDeviceNameHint,
          helperMaxLines: 2,
        ),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.cancel),
        ),
        FilledButton(
          key: const ValueKey('sync-device-name-save'),
          onPressed: () => Navigator.pop(context, _name.text),
          child: Text(strings.save),
        ),
      ],
    );
  }
}

String _statusText(AppLocalizations strings, SyncHostLifecycle lifecycle) =>
    switch (lifecycle) {
      SyncHostLifecycle.stopped => strings.syncStatusStopped,
      SyncHostLifecycle.starting => strings.syncStatusStarting,
      SyncHostLifecycle.running => strings.syncStatusRunning,
      SyncHostLifecycle.stopping => strings.syncStatusStopping,
      SyncHostLifecycle.failed => strings.syncStatusFailed,
    };

String _clientStatusText(AppLocalizations strings, SyncClientViewState state) {
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
  'host_start_failed' => strings.syncHostStartFailed,
  'initialization_failed' => strings.syncInitializationFailed,
  'invite_failed' => strings.syncInviteFailed,
  'role_change_requires_disconnect' => strings.syncRoleChangeBlocked,
  _ => strings.syncOperationFailed,
};

String _networkName(SyncNetworkKind kind) => switch (kind) {
  SyncNetworkKind.loopback => 'Loopback',
  SyncNetworkKind.localAreaNetwork => 'LAN',
  SyncNetworkKind.tailscale => 'Tailscale',
};

IconData _platformIcon(String platform) => switch (platform.toLowerCase()) {
  'android' => Icons.phone_android_rounded,
  'windows' => Icons.desktop_windows_rounded,
  _ => Icons.devices_other_rounded,
};

String _groupFingerprint(String value) {
  final groups = <String>[];
  for (var index = 0; index < value.length; index += 8) {
    groups.add(value.substring(index, (index + 8).clamp(0, value.length)));
  }
  return groups.join(' ');
}

String _groupCode(String value) {
  final groups = <String>[];
  for (var index = 0; index < value.length; index += 4) {
    groups.add(value.substring(index, (index + 4).clamp(0, value.length)));
  }
  return groups.join('-');
}

String _formatTime(DateTime value) =>
    DateFormat('yyyy-MM-dd HH:mm').format(value.toLocal());
