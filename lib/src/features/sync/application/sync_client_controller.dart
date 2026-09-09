import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/platform/platform_capabilities.dart';
import '../../../app/providers/data_providers.dart';
import '../../../core/config/app_config.dart';
import '../../../core/ids/id_generator.dart';
import '../data/direct_sync_client.dart';
import '../data/sync_connection_store.dart';
import '../domain/sync_client_models.dart';
import '../domain/sync_merge_engine.dart';
import '../domain/sync_protocol.dart';
import '../domain/sync_repository.dart';
import '../security/device_identity.dart';
import '../security/sync_pairing_service.dart';

typedef SyncClientFactory = SyncClientTransport Function(
  Uri baseUri,
  String fingerprint,
  DeviceIdentity identity,
  DeviceIdentityStore identityStore,
);

final syncConnectionStoreProvider = Provider<SyncConnectionStore>((ref) {
  return SyncConnectionStore(ref.watch(settingsRepositoryProvider));
});

final syncClientFactoryProvider = Provider<SyncClientFactory>((ref) {
  return (baseUri, fingerprint, identity, identityStore) => DirectSyncClient(
    baseUri: baseUri,
    fingerprintSha256: fingerprint,
    identity: identity,
    identityStore: identityStore,
  );
});

final syncClientControllerProvider =
    NotifierProvider<SyncClientController, SyncClientViewState>(
      SyncClientController.new,
    );

final class SyncClientViewState {
  const SyncClientViewState({
    this.loaded = false,
    this.phase = SyncClientPhase.disconnected,
    this.profile,
    this.verificationCode,
    this.pairingExpiresAt,
    this.lastResult,
    this.conflicts = const [],
    this.messageCode,
  });

  final bool loaded;
  final SyncClientPhase phase;
  final SyncClientProfile? profile;
  final String? verificationCode;
  final DateTime? pairingExpiresAt;
  final SyncRunResult? lastResult;
  final List<SyncConflict> conflicts;
  final String? messageCode;

  bool get connected => profile != null;
  bool get needsAttention =>
      conflicts.isNotEmpty ||
      phase == SyncClientPhase.offline ||
      phase == SyncClientPhase.error;
  bool get busy =>
      phase == SyncClientPhase.connecting ||
      phase == SyncClientPhase.waitingForApproval ||
      phase == SyncClientPhase.syncing;

  SyncClientViewState copyWith({
    bool? loaded,
    SyncClientPhase? phase,
    SyncClientProfile? profile,
    bool clearProfile = false,
    String? verificationCode,
    bool clearVerificationCode = false,
    DateTime? pairingExpiresAt,
    bool clearPairingExpiresAt = false,
    SyncRunResult? lastResult,
    bool clearLastResult = false,
    List<SyncConflict>? conflicts,
    String? messageCode,
    bool clearMessage = false,
  }) => SyncClientViewState(
    loaded: loaded ?? this.loaded,
    phase: phase ?? this.phase,
    profile: clearProfile ? null : profile ?? this.profile,
    verificationCode: clearVerificationCode
        ? null
        : verificationCode ?? this.verificationCode,
    pairingExpiresAt: clearPairingExpiresAt
        ? null
        : pairingExpiresAt ?? this.pairingExpiresAt,
    lastResult: clearLastResult ? null : lastResult ?? this.lastResult,
    conflicts: conflicts ?? this.conflicts,
    messageCode: clearMessage ? null : messageCode ?? this.messageCode,
  );
}

class SyncClientController extends Notifier<SyncClientViewState> {
  Future<SyncRunResult?>? _runningSync;
  bool _initializing = false;
  int _pairingGeneration = 0;

  @override
  SyncClientViewState build() => const SyncClientViewState();

  Future<void> initialize({bool synchronizeOnLoad = true}) async {
    if (_initializing || state.loaded) return;
    _initializing = true;
    try {
      final profile = await ref.read(syncConnectionStoreProvider).load();
      if (profile == null) {
        state = state.copyWith(loaded: true);
        return;
      }
      final identity = await ref.read(syncRepositoryProvider).activeIdentity();
      if (identity?.role == SyncGroupRole.client) {
        state = state.copyWith(
          loaded: true,
          phase: profile.lastSyncAt == null
              ? SyncClientPhase.offline
              : SyncClientPhase.synced,
          profile: profile,
        );
        await _refreshConflicts();
        if (synchronizeOnLoad) {
          unawaited(synchronize());
        }
      } else {
        state = state.copyWith(loaded: true);
      }
    } on Object {
      state = state.copyWith(
        loaded: true,
        phase: SyncClientPhase.error,
        messageCode: 'client_state_invalid',
      );
    } finally {
      _initializing = false;
    }
  }

  Future<void> pair(
    String source, {
    String? addressOverride,
    int? portOverride,
  }) async {
    if (state.busy || state.connected) return;
    final generation = ++_pairingGeneration;
    SyncClientTransport? client;
    state = state.copyWith(
      loaded: true,
      phase: SyncClientPhase.connecting,
      clearMessage: true,
      clearVerificationCode: true,
      clearPairingExpiresAt: true,
    );
    try {
      var endpoint = SyncPairingUriCodec.parse(source);
      if (portOverride != null && (portOverride < 1 || portOverride > 65535)) {
        throw const FormatException('Port is invalid.');
      }
      if (addressOverride?.trim().isNotEmpty == true || portOverride != null) {
        endpoint = endpoint.copyWith(
          address: addressOverride?.trim().isNotEmpty == true
              ? SyncPairingUriCodec.normalizeHost(addressOverride!)
              : null,
          port: portOverride,
        );
      }
      if (await ref.read(syncRepositoryProvider).activeIdentity() != null) {
        throw const SyncRemoteException('already_in_sync_group', 409);
      }
      final identityStore = ref.read(deviceIdentityStoreProvider);
      final identity = await identityStore.loadOrCreate(
        const UuidV7Generator().next,
      );
      final registration = SyncDeviceRegistration(
        deviceId: identity.deviceId,
        displayName: _deviceName(),
        platform: ref.read(platformCapabilitiesProvider).isAndroid
            ? 'android'
            : 'windows',
        appVersion: AppConfig.version,
        publicKey: identity.publicKeyBase64Url,
      );
      client = ref.read(syncClientFactoryProvider)(
        endpoint.baseUri,
        endpoint.fingerprintSha256,
        identity,
        identityStore,
      );
      await client.verifyHost();
      final pending = await client.preparePairing(
        endpoint: endpoint,
        device: registration,
      );
      state = state.copyWith(
        phase: SyncClientPhase.waitingForApproval,
        verificationCode: pending.verificationCode,
        pairingExpiresAt: pending.expiresAt.toLocal(),
      );
      ClientPairingStatus? approved;
      while (generation == _pairingGeneration &&
          DateTime.now().toUtc().isBefore(pending.expiresAt)) {
        final status = await client.pollPairing(pending);
        if (status.state == PairingPollState.approved) {
          approved = status;
          break;
        }
        if (status.state == PairingPollState.rejected) {
          throw const SyncRemoteException('pairing_rejected', 403);
        }
        await Future<void>.delayed(const Duration(seconds: 1));
      }
      if (generation != _pairingGeneration) return;
      if (approved == null) {
        throw const SyncRemoteException('invite_expired', 410);
      }
      final hostDevice = approved.hostDevice;
      final sessionToken = approved.sessionToken;
      if (approved.groupId != endpoint.groupId ||
          hostDevice == null ||
          sessionToken == null) {
        throw const SyncRemoteException('pairing_response_invalid', 400);
      }
      await _createSafetyBackupOnce();
      await ref
          .read(syncRepositoryProvider)
          .initializeClient(
            groupId: endpoint.groupId,
            hostDeviceId: hostDevice.deviceId,
            hostDevice: hostDevice,
            localDevice: registration,
          );
      var profile = SyncClientProfile(
        address: endpoint.address,
        port: endpoint.port,
        fingerprintSha256: endpoint.fingerprintSha256,
        groupId: endpoint.groupId,
        hostDevice: hostDevice,
      );
      await ref.read(syncConnectionStoreProvider).save(profile);
      state = state.copyWith(
        phase: SyncClientPhase.syncing,
        profile: profile,
        clearVerificationCode: true,
        clearPairingExpiresAt: true,
      );
      final result = await _runSync(
        profile,
        client,
        sessionToken: sessionToken,
        firstSync: true,
      );
      profile = (await ref.read(syncConnectionStoreProvider).load())!;
      state = state.copyWith(
        phase: SyncClientPhase.synced,
        profile: profile,
        lastResult: result,
      );
      await _refreshConflicts();
    } on FormatException {
      state = state.copyWith(
        phase: SyncClientPhase.error,
        messageCode: 'invalid_pairing_code',
        clearVerificationCode: true,
        clearPairingExpiresAt: true,
      );
    } on Object catch (error) {
      state = state.copyWith(
        phase: _isOffline(error)
            ? SyncClientPhase.offline
            : SyncClientPhase.error,
        messageCode: _messageFor(error),
        clearVerificationCode: true,
        clearPairingExpiresAt: true,
      );
    } finally {
      client?.close();
    }
  }

  void cancelPairing() {
    _pairingGeneration++;
    state = state.copyWith(
      phase: SyncClientPhase.disconnected,
      clearVerificationCode: true,
      clearPairingExpiresAt: true,
    );
  }

  Future<SyncRunResult?> synchronize() {
    final running = _runningSync;
    if (running != null) return running;
    final future = _synchronizeWithRetry();
    _runningSync = future;
    return future.whenComplete(() => _runningSync = null);
  }

  Future<SyncRunResult?> _synchronizeWithRetry() async {
    final profile =
        state.profile ?? await ref.read(syncConnectionStoreProvider).load();
    if (profile == null) return null;
    state = state.copyWith(
      phase: SyncClientPhase.syncing,
      profile: profile,
      clearMessage: true,
    );
    try {
      return await _synchronizeOnce(profile);
    } on Object catch (firstError) {
      if (!_isOffline(firstError)) {
        _recordSyncFailure(firstError);
        return null;
      }
      await Future<void>.delayed(const Duration(milliseconds: 800));
      try {
        return await _synchronizeOnce(profile);
      } on Object catch (secondError) {
        _recordSyncFailure(secondError);
        return null;
      }
    }
  }

  Future<SyncRunResult> _synchronizeOnce(SyncClientProfile profile) async {
    await _createSafetyBackupOnce();
    final identityStore = ref.read(deviceIdentityStoreProvider);
    final identity = await identityStore.loadOrCreate(
      const UuidV7Generator().next,
    );
    final client = ref.read(syncClientFactoryProvider)(
      profile.baseUri,
      profile.fingerprintSha256,
      identity,
      identityStore,
    );
    try {
      await client.verifyHost();
      final token = await client.openSession();
      final result = await _runSync(profile, client, sessionToken: token);
      final updated = (await ref.read(syncConnectionStoreProvider).load())!;
      state = state.copyWith(
        phase: SyncClientPhase.synced,
        profile: updated,
        lastResult: result,
      );
      await _refreshConflicts();
      return result;
    } finally {
      client.close();
    }
  }

  Future<SyncRunResult> _runSync(
    SyncClientProfile profile,
    SyncClientTransport client, {
    required String sessionToken,
    bool firstSync = false,
  }) async {
    final repository = ref.read(syncRepositoryProvider);
    for (final device in await client.devices(sessionToken)) {
      await repository.registerDevice(device);
    }
    var remoteCursor = profile.remoteCursor;
    var uploaded = 0;
    var downloaded = 0;
    var conflictCount = 0;
    ({int uploaded, int conflicts, SyncCursor cursor}) pushResult =
        await _pushPendingChanges(
          repository,
          client,
          sessionToken,
          profile,
          remoteCursor,
        );
    uploaded += pushResult.uploaded;
    conflictCount += pushResult.conflicts;
    remoteCursor = pushResult.cursor;
    profile = profile.copyWith(remoteCursor: remoteCursor);
    var snapshot = firstSync;
    while (true) {
      final localCursor = await repository.currentCursor();
      final batch = await client.pull(
        localCursor,
        sessionToken,
        snapshot: snapshot,
      );
      snapshot = false;
      remoteCursor = batch.cursor;
      if (batch.operations.isEmpty) break;
      final applied = await repository.applyBatch(batch);
      downloaded += applied.insertedOperations;
      conflictCount += applied.conflicts.length;
    }
    // A local edit may be committed while a remote batch is being pulled and
    // merged. Sweep the durable change log again before acknowledging the
    // run, so foreground editing is queued without blocking the TODO UI.
    pushResult = await _pushPendingChanges(
      repository,
      client,
      sessionToken,
      profile,
      remoteCursor,
    );
    uploaded += pushResult.uploaded;
    conflictCount += pushResult.conflicts;
    remoteCursor = pushResult.cursor;
    profile = profile.copyWith(remoteCursor: remoteCursor);
    final cursor = await repository.currentCursor();
    await client.acknowledge(cursor, sessionToken);
    final completedAt = DateTime.now().toUtc();
    profile = profile.copyWith(
      remoteCursor: remoteCursor,
      lastSyncAt: completedAt,
    );
    await ref.read(syncConnectionStoreProvider).save(profile);
    return SyncRunResult(
      uploaded: uploaded,
      downloaded: downloaded,
      conflicts: conflictCount,
      completedAt: completedAt,
    );
  }

  Future<({int uploaded, int conflicts, SyncCursor cursor})>
  _pushPendingChanges(
    SyncRepository repository,
    SyncClientTransport client,
    String sessionToken,
    SyncClientProfile profile,
    SyncCursor initialCursor,
  ) async {
    var remoteCursor = initialCursor;
    var uploaded = 0;
    var conflicts = 0;
    while (true) {
      final batch = await repository.changesAfter(remoteCursor);
      if (batch.operations.isEmpty) break;
      final receipt = await client.push(batch, sessionToken);
      uploaded += batch.operations.length;
      conflicts += receipt.conflictCount;
      remoteCursor = receipt.acknowledgedCursor;
      profile = profile.copyWith(remoteCursor: remoteCursor);
      await ref.read(syncConnectionStoreProvider).save(profile);
    }
    return (uploaded: uploaded, conflicts: conflicts, cursor: remoteCursor);
  }

  Future<void> resolveConflict(String conflictId) async {
    await ref.read(syncRepositoryProvider).resolveConflict(conflictId);
    await _refreshConflicts();
  }

  Future<void> updateEndpointAndSynchronize(String address, int port) async {
    final profile =
        state.profile ?? await ref.read(syncConnectionStoreProvider).load();
    if (profile == null || state.busy || port < 1 || port > 65535) return;
    try {
      final updated = profile.copyWith(
        address: SyncPairingUriCodec.normalizeHost(address),
        port: port,
      );
      await ref.read(syncConnectionStoreProvider).save(updated);
      state = state.copyWith(profile: updated, clearMessage: true);
      await synchronize();
    } on FormatException {
      state = state.copyWith(
        phase: SyncClientPhase.error,
        messageCode: 'invalid_host_address',
      );
    }
  }

  Future<void> disconnect() async {
    if (!state.connected || state.busy) return;
    state = state.copyWith(phase: SyncClientPhase.connecting);
    try {
      await ref.read(backupMaintenanceServiceProvider).createDefaultBackup();
      await ref.read(syncRepositoryProvider).leaveGroup();
      await ref.read(syncConnectionStoreProvider).clear();
      state = const SyncClientViewState(loaded: true);
    } on Object {
      state = state.copyWith(
        phase: SyncClientPhase.error,
        messageCode: 'disconnect_failed',
      );
    }
  }

  Future<void> _refreshConflicts() async {
    final identity = await ref.read(syncRepositoryProvider).activeIdentity();
    final conflicts = identity == null
        ? const <SyncConflict>[]
        : await ref.read(syncRepositoryProvider).unresolvedConflicts();
    state = state.copyWith(conflicts: conflicts);
  }

  Future<void> _createSafetyBackupOnce() async {
    final settings = ref.read(settingsRepositoryProvider);
    final now = DateTime.now();
    final date =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    final previous = await settings.get(
      SyncClientPreferenceKeys.lastSafetyBackupDate,
    );
    if (previous?.value == date) return;
    await ref.read(backupMaintenanceServiceProvider).createDefaultBackup();
    await settings.set(SyncClientPreferenceKeys.lastSafetyBackupDate, date);
  }

  void _recordSyncFailure(Object error) {
    state = state.copyWith(
      phase: _isOffline(error)
          ? SyncClientPhase.offline
          : SyncClientPhase.error,
      messageCode: _messageFor(error),
    );
  }

  static bool _isOffline(Object error) =>
      error is SocketException ||
      error is TimeoutException ||
      error is HandshakeException;

  static String _messageFor(Object error) {
    if (error is SyncRemoteException) return error.code;
    if (_isOffline(error)) return 'host_unreachable';
    return 'sync_failed';
  }

  static String _deviceName() {
    final name = Platform.localHostname.trim();
    if (name.isNotEmpty) return name;
    return Platform.isAndroid ? 'Android' : 'Windows PC';
  }
}
