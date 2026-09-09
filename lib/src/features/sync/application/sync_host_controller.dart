import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

import '../../../app/platform/platform_capabilities.dart';
import '../../../app/providers/data_providers.dart';
import '../../../core/config/app_config.dart';
import '../../../core/ids/id_generator.dart';
import '../../../data/database/app_database.dart';
import '../domain/sync_merge_engine.dart';
import '../domain/sync_protocol.dart';
import '../domain/sync_repository.dart';
import '../security/sync_pairing_service.dart';
import '../server/secure_sync_host_service.dart';
import '../server/sync_network_discovery.dart';

abstract final class SyncHostPreferenceKeys {
  static const mode = 'device.sync.mode';
  static const address = 'device.sync.host.address';
  static const port = 'device.sync.host.port';
  static const keepRunningInTray = 'device.sync.keepRunningInTray';
}

enum SyncOperatingMode { off, host, client }

final class ManagedSyncDevice {
  const ManagedSyncDevice({
    required this.id,
    required this.displayName,
    required this.platform,
    required this.appVersion,
    required this.isLocal,
    required this.isOnline,
    required this.syncRequested,
    this.protocolVersion = SyncProtocol.version,
    this.note,
    this.lastSyncAt,
    this.revokedAt,
  });

  final String id;
  final String displayName;
  final String? note;
  final String platform;
  final String appVersion;
  final DateTime? lastSyncAt;
  final DateTime? revokedAt;
  final bool isLocal;
  final bool isOnline;
  final bool syncRequested;
  final int protocolVersion;

  bool get requiresUpgrade => protocolVersion != SyncProtocol.version;
}

final class SyncHostViewState {
  const SyncHostViewState({
    this.loaded = false,
    this.busy = false,
    this.mode = SyncOperatingMode.off,
    this.lifecycle = SyncHostLifecycle.stopped,
    this.networks = const [],
    this.devices = const [],
    this.pendingPairings = const [],
    this.conflicts = const [],
    this.keepRunningInTray = true,
    this.launchAtStartup = false,
    this.selectedAddress,
    this.binding,
    this.messageCode,
  });

  final bool loaded;
  final bool busy;
  final SyncOperatingMode mode;
  final SyncHostLifecycle lifecycle;
  final List<SyncNetworkEndpoint> networks;
  final List<ManagedSyncDevice> devices;
  final List<PendingPairingRequest> pendingPairings;
  final List<SyncConflict> conflicts;
  final bool keepRunningInTray;
  final bool launchAtStartup;
  final String? selectedAddress;
  final SyncHostBinding? binding;
  final String? messageCode;

  SyncHostViewState copyWith({
    bool? loaded,
    bool? busy,
    SyncOperatingMode? mode,
    SyncHostLifecycle? lifecycle,
    List<SyncNetworkEndpoint>? networks,
    List<ManagedSyncDevice>? devices,
    List<PendingPairingRequest>? pendingPairings,
    List<SyncConflict>? conflicts,
    bool? keepRunningInTray,
    bool? launchAtStartup,
    String? selectedAddress,
    bool clearSelectedAddress = false,
    SyncHostBinding? binding,
    bool clearBinding = false,
    String? messageCode,
    bool clearMessage = false,
  }) => SyncHostViewState(
    loaded: loaded ?? this.loaded,
    busy: busy ?? this.busy,
    mode: mode ?? this.mode,
    lifecycle: lifecycle ?? this.lifecycle,
    networks: networks ?? this.networks,
    devices: devices ?? this.devices,
    pendingPairings: pendingPairings ?? this.pendingPairings,
    conflicts: conflicts ?? this.conflicts,
    keepRunningInTray: keepRunningInTray ?? this.keepRunningInTray,
    launchAtStartup: launchAtStartup ?? this.launchAtStartup,
    selectedAddress: clearSelectedAddress
        ? null
        : selectedAddress ?? this.selectedAddress,
    binding: clearBinding ? null : binding ?? this.binding,
    messageCode: clearMessage ? null : messageCode ?? this.messageCode,
  );
}

final syncHostControllerProvider =
    NotifierProvider<SyncHostController, SyncHostViewState>(
      SyncHostController.new,
    );

class SyncHostController extends Notifier<SyncHostViewState> {
  Timer? _maintenanceTimer;
  bool _initializing = false;
  bool _maintaining = false;
  int _maintenanceTicks = 0;

  @override
  SyncHostViewState build() {
    ref.onDispose(() => _maintenanceTimer?.cancel());
    return const SyncHostViewState();
  }

  Future<void> initialize() async {
    if (_initializing || state.loaded) return;
    _initializing = true;
    try {
      if (!ref.read(platformCapabilitiesProvider).isWindows) {
        state = state.copyWith(loaded: true);
        return;
      }
      final settings = ref.read(settingsRepositoryProvider);
      final values = await Future.wait([
        settings.get(SyncHostPreferenceKeys.mode),
        settings.get(SyncHostPreferenceKeys.address),
        settings.get(SyncHostPreferenceKeys.keepRunningInTray),
      ]);
      if (!ref.mounted) return;
      final mode = SyncOperatingMode.values.firstWhere(
        (value) => value.name == values[0]?.value,
        orElse: () => SyncOperatingMode.off,
      );
      final discovery = ref.read(syncNetworkDiscoveryProvider);
      final networks = usableSyncHostNetworks(await discovery.discover());
      if (!ref.mounted) return;
      final storedAddress = values[1]?.value;
      final selectedAddress = selectSyncHostAddress(networks, storedAddress);
      final launchEnabled = await _isLaunchAtStartupEnabled();
      if (!ref.mounted) return;
      state = state.copyWith(
        loaded: true,
        mode: mode,
        networks: networks,
        selectedAddress: selectedAddress,
        clearSelectedAddress: selectedAddress == null,
        keepRunningInTray: values[2]?.value != 'false',
        launchAtStartup: launchEnabled,
      );
      if (selectedAddress != null && selectedAddress != storedAddress) {
        await settings.set(SyncHostPreferenceKeys.address, selectedAddress);
        if (!ref.mounted) return;
      }
      await refreshAdminData();
      if (!ref.mounted) return;
      if (mode == SyncOperatingMode.host) {
        _startMaintenance();
        try {
          await _startHost();
        } on Object {
          if (!ref.mounted) return;
          state = state.copyWith(
            busy: false,
            lifecycle: ref.read(secureSyncHostServiceProvider).lifecycle,
            messageCode: 'host_start_failed',
          );
        }
      }
    } on Object {
      if (!ref.mounted) return;
      state = state.copyWith(
        loaded: true,
        busy: false,
        messageCode: 'initialization_failed',
      );
    } finally {
      _initializing = false;
    }
  }

  Future<void> setMode(SyncOperatingMode mode) async {
    if (state.busy) return;
    state = state.copyWith(busy: true, clearMessage: true);
    try {
      if (mode == SyncOperatingMode.off) {
        await ref.read(secureSyncHostServiceProvider).stop();
        _stopMaintenance();
        await _setPreference(SyncHostPreferenceKeys.mode, mode.name);
        state = state.copyWith(
          busy: false,
          mode: mode,
          lifecycle: SyncHostLifecycle.stopped,
          clearBinding: true,
        );
        return;
      }
      if (mode == SyncOperatingMode.client) {
        final identity = await ref
            .read(syncRepositoryProvider)
            .activeIdentity();
        if (identity?.role == SyncGroupRole.host) {
          state = state.copyWith(
            busy: false,
            messageCode: 'role_change_requires_disconnect',
          );
          return;
        }
        await ref.read(secureSyncHostServiceProvider).stop();
        _stopMaintenance();
        await _setPreference(SyncHostPreferenceKeys.mode, mode.name);
        state = state.copyWith(
          busy: false,
          mode: mode,
          lifecycle: SyncHostLifecycle.stopped,
          clearBinding: true,
        );
        return;
      }
      await _ensureHostIdentity();
      await _setPreference(SyncHostPreferenceKeys.mode, mode.name);
      state = state.copyWith(mode: mode);
      _startMaintenance();
      await _startHost(alreadyBusy: true);
    } on StateError {
      state = state.copyWith(
        busy: false,
        messageCode: 'role_change_requires_disconnect',
      );
    } on Object {
      state = state.copyWith(busy: false, messageCode: 'host_start_failed');
    }
  }

  Future<void> restart() async {
    if (state.mode != SyncOperatingMode.host || state.busy) return;
    state = state.copyWith(busy: true, clearMessage: true);
    try {
      await ref.read(secureSyncHostServiceProvider).stop();
      await _startHost(alreadyBusy: true);
    } on Object {
      state = state.copyWith(busy: false, messageCode: 'host_start_failed');
    }
  }

  /// Re-establishes the host after sleep, an adapter change, or an unexpected
  /// socket shutdown. Failures stay as inline state and are retried later.
  Future<void> recoverHostIfNeeded({bool forceNetworkRefresh = false}) async {
    if (state.mode != SyncOperatingMode.host || state.busy || _maintaining) {
      return;
    }
    _maintaining = true;
    try {
      final service = ref.read(secureSyncHostServiceProvider);
      final binding = service.binding;
      var bindingAvailable = binding != null;
      if (forceNetworkRefresh || binding == null) {
        final networks = usableSyncHostNetworks(
          await ref.read(syncNetworkDiscoveryProvider).discover(),
        );
        bindingAvailable =
            binding != null &&
            networks.any(
              (network) => network.address.address == binding.address.address,
            );
        final selected = selectSyncHostAddress(
          networks,
          bindingAvailable ? binding.address.address : state.selectedAddress,
        );
        state = state.copyWith(
          networks: networks,
          selectedAddress: selected,
          clearSelectedAddress: selected == null,
        );
      }
      if (service.lifecycle != SyncHostLifecycle.running || !bindingAvailable) {
        await service.stop();
        state = state.copyWith(
          lifecycle: SyncHostLifecycle.stopped,
          clearBinding: true,
        );
        await _startHost();
      } else {
        await refreshAdminData();
        if (state.messageCode == 'host_start_failed') {
          state = state.copyWith(clearMessage: true);
        }
      }
    } on Object {
      state = state.copyWith(
        busy: false,
        lifecycle: ref.read(secureSyncHostServiceProvider).lifecycle,
        messageCode: 'host_start_failed',
      );
    } finally {
      _maintaining = false;
    }
  }

  Future<void> refreshNetworks() async {
    final networks = usableSyncHostNetworks(
      await ref.read(syncNetworkDiscoveryProvider).discover(),
    );
    final selected = selectSyncHostAddress(networks, state.selectedAddress);
    state = state.copyWith(
      networks: networks,
      selectedAddress: selected,
      clearSelectedAddress: selected == null,
    );
  }

  Future<void> selectAddress(String address) async {
    if (!state.networks.any((item) => item.address.address == address)) return;
    await _setPreference(SyncHostPreferenceKeys.address, address);
    state = state.copyWith(selectedAddress: address);
    if (state.lifecycle == SyncHostLifecycle.running) await restart();
  }

  Future<SyncPairingInvite?> createPairingInvite() async {
    if (state.lifecycle != SyncHostLifecycle.running) return null;
    try {
      final invite = await ref
          .read(secureSyncHostServiceProvider)
          .createPairingInvite();
      await refreshAdminData();
      return invite;
    } on Object {
      state = state.copyWith(messageCode: 'invite_failed');
      return null;
    }
  }

  Future<Uri> pairingUri(SyncPairingInvite invite) async {
    final identity = await ref.read(syncRepositoryProvider).activeIdentity();
    final binding = state.binding;
    if (identity == null || binding == null) {
      throw StateError('The sync host is not running.');
    }
    return Uri(
      scheme: 'echoday',
      host: 'pair',
      queryParameters: {
        'v': '1',
        'host': binding.address.address,
        'port': '${binding.port}',
        'group': identity.groupId,
        'fingerprint': invite.hostFingerprint,
        'invite': invite.id,
        'token': invite.token,
      },
    );
  }

  Future<void> approvePairing(String requestId) async {
    await ref.read(secureSyncHostServiceProvider).approvePairing(requestId);
    await refreshAdminData();
  }

  Future<void> rejectPairing(String requestId) async {
    await ref.read(secureSyncHostServiceProvider).rejectPairing(requestId);
    await refreshAdminData();
  }

  Future<void> updateDeviceNote(String deviceId, String note) async {
    final normalized = note.trim();
    if (normalized.length > 120) throw ArgumentError('note is too long');
    await (ref
            .read(appDatabaseProvider)
            .update(ref.read(appDatabaseProvider).syncDevices)
          ..where((row) => row.deviceId.equals(deviceId)))
        .write(
          SyncDevicesCompanion(
            note: Value(normalized.isEmpty ? null : normalized),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
    await refreshAdminData();
  }

  Future<void> revokeDevice(String deviceId) async {
    await ref.read(secureSyncHostServiceProvider).revokeDevice(deviceId);
    await refreshAdminData();
  }

  Future<void> requestDeviceSync(String deviceId) async {
    await ref.read(secureSyncHostServiceProvider).requestDeviceSync(deviceId);
    await refreshAdminData();
  }

  Future<int> requestAllDeviceSyncs() async {
    final count = await ref
        .read(secureSyncHostServiceProvider)
        .requestAllDeviceSyncs();
    await refreshAdminData();
    return count;
  }

  Future<void> resolveConflict(String conflictId) async {
    await ref.read(syncRepositoryProvider).resolveConflict(conflictId);
    await refreshAdminData();
  }

  Future<void> setKeepRunningInTray(bool value) async {
    await _setPreference(SyncHostPreferenceKeys.keepRunningInTray, '$value');
    state = state.copyWith(keepRunningInTray: value);
  }

  Future<void> setLaunchAtStartup(bool value) async {
    _setupLaunchAtStartup();
    final changed = value
        ? await launchAtStartup.enable()
        : await launchAtStartup.disable();
    final actual = changed ? value : await launchAtStartup.isEnabled();
    state = state.copyWith(launchAtStartup: actual);
  }

  Future<void> refreshAdminData() async {
    final repository = ref.read(syncRepositoryProvider);
    final identity = await repository.activeIdentity();
    if (!ref.mounted) return;
    if (identity == null) {
      state = state.copyWith(devices: const [], conflicts: const []);
      return;
    }
    final database = ref.read(appDatabaseProvider);
    final rows =
        await (database.select(database.syncDevices)..where(
              (row) =>
                  row.syncGroupId.equals(identity.groupId) &
                  row.revokedAt.isNull(),
            ))
            .get();
    if (!ref.mounted) return;
    final service = ref.read(secureSyncHostServiceProvider);
    final online = service.onlineDeviceIds;
    final requested = service.requestedSyncDeviceIds;
    final devices =
        rows
            .map(
              (row) => ManagedSyncDevice(
                id: row.deviceId,
                displayName: row.displayName,
                note: row.note,
                platform: row.platform,
                appVersion: row.appVersion,
                lastSyncAt: row.lastSeenAt?.toLocal(),
                revokedAt: row.revokedAt?.toLocal(),
                isLocal: row.deviceId == identity.localDeviceId,
                isOnline: online.contains(row.deviceId),
                syncRequested: requested.contains(row.deviceId),
                protocolVersion: row.protocolVersion,
              ),
            )
            .toList()
          ..sort((left, right) {
            if (left.isLocal != right.isLocal) return left.isLocal ? -1 : 1;
            return left.displayName.compareTo(right.displayName);
          });
    final conflicts = await repository.unresolvedConflicts();
    if (!ref.mounted) return;
    state = state.copyWith(
      lifecycle: service.lifecycle,
      binding: service.binding,
      clearBinding: service.binding == null,
      devices: List.unmodifiable(devices),
      pendingPairings: service.pendingPairingRequests,
      conflicts: conflicts,
    );
  }

  Future<void> stopForExit() => ref.read(secureSyncHostServiceProvider).stop();

  Future<void> _startHost({bool alreadyBusy = false}) async {
    if (!alreadyBusy) state = state.copyWith(busy: true, clearMessage: true);
    await _ensureHostIdentity();
    await refreshNetworks();
    final addressText = state.selectedAddress;
    if (addressText == null) throw StateError('No private interface found.');
    final settings = ref.read(settingsRepositoryProvider);
    final savedPort = int.tryParse(
      (await settings.get(SyncHostPreferenceKeys.port))?.value ?? '',
    );
    final service = ref.read(secureSyncHostServiceProvider);
    final candidateAddresses = <String>{
      addressText,
      ...state.networks
          .where((item) => item.address.type == InternetAddressType.IPv4)
          .map((item) => item.address.address),
      ...state.networks.map((item) => item.address.address),
    };
    SyncHostBinding? binding;
    String? boundAddress;
    SyncHostStartException? lastRecoverableError;
    for (final candidate in candidateAddresses) {
      try {
        binding = await _bindHost(
          service,
          InternetAddress(candidate),
          savedPort,
        );
        boundAddress = candidate;
        break;
      } on SyncHostStartException catch (error) {
        if (error.code != SyncHostStartFailureCode.addressUnavailable &&
            error.code != SyncHostStartFailureCode.networkUnavailable) {
          rethrow;
        }
        lastRecoverableError = error;
      }
    }
    if (binding == null || boundAddress == null) {
      throw lastRecoverableError ?? StateError('No private interface found.');
    }
    if (boundAddress != addressText) {
      await settings.set(SyncHostPreferenceKeys.address, boundAddress);
    }
    await settings.set(SyncHostPreferenceKeys.port, '${binding.port}');
    state = state.copyWith(
      busy: false,
      lifecycle: SyncHostLifecycle.running,
      selectedAddress: boundAddress,
      binding: binding,
    );
    _startMaintenance();
    await refreshAdminData();
  }

  void _startMaintenance() {
    if (_maintenanceTimer != null) return;
    _maintenanceTicks = 0;
    _maintenanceTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _maintenanceTicks++;
      unawaited(
        recoverHostIfNeeded(forceNetworkRefresh: _maintenanceTicks % 3 == 0),
      );
    });
  }

  void _stopMaintenance() {
    _maintenanceTimer?.cancel();
    _maintenanceTimer = null;
    _maintenanceTicks = 0;
  }

  Future<SyncHostBinding> _bindHost(
    SecureSyncHostService service,
    InternetAddress address,
    int? savedPort,
  ) async {
    try {
      return await service.start(
        address: address,
        port: savedPort?.clamp(1, 65535) ?? 0,
      );
    } on SyncHostStartException catch (error) {
      if (savedPort == null ||
          error.code != SyncHostStartFailureCode.addressInUse) {
        rethrow;
      }
      return service.start(address: address);
    }
  }

  Future<void> _ensureHostIdentity() async {
    final repository = ref.read(syncRepositoryProvider);
    final existing = await repository.activeIdentity();
    if (existing != null) {
      if (existing.role != SyncGroupRole.host) {
        throw StateError('This database belongs to a client sync group.');
      }
      return;
    }
    await ref.read(backupMaintenanceServiceProvider).createDefaultBackup();
    final device = await ref
        .read(deviceIdentityStoreProvider)
        .loadOrCreate(const UuidV7Generator().next);
    await repository.initializeHost(
      localDevice: SyncDeviceRegistration(
        deviceId: device.deviceId,
        displayName: _hostName(),
        platform: 'windows',
        appVersion: AppConfig.version,
        publicKey: device.publicKeyBase64Url,
      ),
    );
  }

  Future<bool> _isLaunchAtStartupEnabled() async {
    _setupLaunchAtStartup();
    return launchAtStartup.isEnabled();
  }

  void _setupLaunchAtStartup() {
    launchAtStartup.setup(
      appName: 'EchoDay',
      appPath: Platform.resolvedExecutable,
      packageName: AppConfig.applicationId,
      args: const ['--background'],
    );
  }

  Future<void> _setPreference(String key, String value) =>
      ref.read(settingsRepositoryProvider).set(key, value);

  static String _hostName() {
    final value = Platform.localHostname.trim();
    return value.isEmpty ? 'Windows PC' : value;
  }
}
