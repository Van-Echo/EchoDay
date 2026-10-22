import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:echoday/src/app/platform/platform_capabilities.dart';
import 'package:echoday/src/app/providers/data_providers.dart';
import 'package:echoday/src/data/database/app_database.dart';
import 'package:echoday/src/features/backup/application/backup_maintenance_service.dart';
import 'package:echoday/src/features/backup/data/backup_directory_resolver.dart';
import 'package:echoday/src/features/backup/data/local_backup_repository.dart';
import 'package:echoday/src/features/sync/application/sync_client_controller.dart';
import 'package:echoday/src/features/sync/data/database_sync_change_recorder.dart';
import 'package:echoday/src/features/sync/data/direct_sync_client.dart';
import 'package:echoday/src/features/sync/data/local_sync_repository.dart';
import 'package:echoday/src/features/sync/domain/sync_client_models.dart';
import 'package:echoday/src/features/sync/domain/sync_endpoint_update.dart';
import 'package:echoday/src/features/sync/domain/sync_repository.dart';
import 'package:echoday/src/features/sync/security/device_identity.dart';
import 'package:echoday/src/features/sync/security/device_secret_store.dart';
import 'package:echoday/src/features/sync/security/host_tls_identity.dart';
import 'package:echoday/src/features/sync/security/sync_session_manager.dart';
import 'package:echoday/src/features/sync/server/secure_sync_host_service.dart';
import 'package:echoday/src/features/todos/data/local_todo_repository.dart';
import 'package:echoday/src/features/todos/domain/local_date.dart';
import 'package:echoday/src/features/todos/domain/todo_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/in_memory_settings_repository.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test(
    'Android pairs, merges offline data, resyncs, and disconnects safely',
    () => _exerciseClient(
      const PlatformCapabilities(isAndroid: true, isWindows: false),
      seedRevokedHistory: true,
    ),
    timeout: const Timeout(Duration(minutes: 2)),
  );
  test(
    'Windows client uses the same pinned pairing and incremental sync path',
    () => _exerciseClient(
      const PlatformCapabilities(isAndroid: false, isWindows: true),
    ),
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

Future<void> _exerciseClient(
  PlatformCapabilities capabilities, {
  bool seedRevokedHistory = false,
}) async {
  final hostDatabase = AppDatabase.forTesting(NativeDatabase.memory());
  final clientDatabase = AppDatabase.forTesting(NativeDatabase.memory());
  final temporary = await Directory.systemTemp.createTemp('echoday-s5-client-');
  final hostSecrets = MemoryDeviceSecretStore();
  final hostIdentity = await DeviceIdentityStore(hostSecrets)
      .loadOrCreate(() => 'host-device');
  final hostSync = LocalSyncRepository(hostDatabase);
  final hostTodos = LocalTodoRepository(hostDatabase);
  await hostTodos.create(
    TodoDraft(title: 'Host offline task', localDate: LocalDate(2026, 9, 9)),
  );
  await hostSync.initializeHost(
    groupId: 'echo-s5-group',
    localDevice: SyncDeviceRegistration(
      deviceId: hostIdentity.deviceId,
      displayName: 'Main PC',
      platform: 'windows',
      appVersion: '0.1.0',
      publicKey: hostIdentity.publicKeyBase64Url,
    ),
  );
  if (seedRevokedHistory) {
    await hostSync.registerDevice(
      const SyncDeviceRegistration(
        deviceId: 'retired-phone',
        displayName: 'Retired phone',
        platform: 'android',
        appVersion: '0.1.0',
        publicKey: 'retired-phone-public-key',
      ),
    );
    await (hostDatabase.update(hostDatabase.syncRuntimeStates)..where(
          (row) =>
              row.key.equals(DatabaseSyncChangeRecorder.localDeviceStateKey),
        ))
        .write(const SyncRuntimeStatesCompanion(value: Value('retired-phone')));
    await hostTodos.create(
      TodoDraft(
        title: 'Retired phone historical task',
        localDate: LocalDate(2026, 9, 8),
      ),
    );
    await (hostDatabase.update(hostDatabase.syncRuntimeStates)..where(
          (row) =>
              row.key.equals(DatabaseSyncChangeRecorder.localDeviceStateKey),
        ))
        .write(SyncRuntimeStatesCompanion(value: Value(hostIdentity.deviceId)));
    await (hostDatabase.update(
      hostDatabase.syncDevices,
    )..where((row) => row.deviceId.equals('retired-phone'))).write(
      SyncDevicesCompanion(revokedAt: Value(DateTime.utc(2026, 9, 9, 1))),
    );
  }
  final hostService = SecureSyncHostService(
    database: hostDatabase,
    syncRepository: hostSync,
    tlsIdentityStore: HostTlsIdentityStore(hostSecrets),
    sessions: SyncSessionManager(
      publicKeyForDevice: (id) => activeDevicePublicKey(hostDatabase, id),
    ),
    eventPollTimeout: const Duration(milliseconds: 20),
  );
  final binding = await hostService.start(
    address: InternetAddress.loopbackIPv4,
  );
  final invite = await hostService.createPairingInvite();

  final wrongIdentityStore = DeviceIdentityStore(MemoryDeviceSecretStore());
  final wrongIdentity = await wrongIdentityStore.loadOrCreate(
    () => 'wrong-pin-device',
  );
  final wrongPinClient = DirectSyncClient(
    baseUri: binding.endpoint,
    fingerprintSha256: '0' * 64,
    identity: wrongIdentity,
    identityStore: wrongIdentityStore,
  );
  await expectLater(
    wrongPinClient.verifyHost(),
    throwsA(
      isA<SyncRemoteException>().having(
        (error) => error.code,
        'code',
        'fingerprint_mismatch',
      ),
    ),
  );
  wrongPinClient.close();

  final clientTodos = LocalTodoRepository(clientDatabase);
  await clientTodos.create(
    TodoDraft(title: 'Phone offline task', localDate: LocalDate(2026, 9, 10)),
  );
  final settings = InMemorySettingsRepository();
  final backupRepository = LocalBackupRepository(
    clientDatabase,
    safetyBackupDirectory: () async =>
        Directory('${temporary.path}${Platform.pathSeparator}safety'),
  );
  final directories = BackupDirectoryResolver(
    settings,
    defaultRoot: () async => temporary,
  );
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(clientDatabase),
      settingsRepositoryProvider.overrideWithValue(settings),
      deviceSecretStoreProvider.overrideWithValue(MemoryDeviceSecretStore()),
      backupRepositoryProvider.overrideWithValue(backupRepository),
      backupDirectoryResolverProvider.overrideWithValue(directories),
      backupMaintenanceServiceProvider.overrideWithValue(
        BackupMaintenanceService(backupRepository, settings, directories),
      ),
      platformCapabilitiesProvider.overrideWithValue(capabilities),
    ],
  );
  addTearDown(() async {
    container.dispose();
    await hostService.stop();
    await hostDatabase.close();
    await clientDatabase.close();
    await settings.dispose();
    await temporary.delete(recursive: true);
  });

  final uri = Uri(
    scheme: 'echoday',
    host: 'pair',
    queryParameters: {
      'v': '1',
      'host': binding.address.address,
      'port': '${binding.port}',
      'group': 'echo-s5-group',
      'fingerprint': binding.fingerprintSha256,
      'invite': invite.id,
      'token': invite.token,
    },
  );
  var controller = container.read(syncClientControllerProvider.notifier);
  final pairing = controller.pair(
    uri.toString(),
    addressOverride: capabilities.isWindows ? 'localhost' : null,
  );
  await _waitUntil(
    () =>
        hostService.pendingPairingRequests.isNotEmpty &&
        container.read(syncClientControllerProvider).verificationCode != null,
  );
  final pending = hostService.pendingPairingRequests.single;
  expect(
    container.read(syncClientControllerProvider).verificationCode,
    pending.verificationCode,
  );
  await hostService.approvePairing(pending.id);
  await pairing;

  final pairedState = container.read(syncClientControllerProvider);
  expect(pairedState.phase, SyncClientPhase.synced);
  expect(pairedState.profile?.hostDevice.displayName, 'Main PC');
  expect(
    pairedState.profile!.savedEndpoints.single.id,
    pairedState.profile!.baseUri.toString(),
  );
  if (capabilities.isWindows) {
    expect(pairedState.profile?.address, 'localhost');
  }
  final seededTaskCount = seedRevokedHistory ? 1 : 0;
  expect(
    await hostDatabase.select(hostDatabase.todos).get(),
    hasLength(2 + seededTaskCount),
  );
  expect(
    await clientDatabase.select(clientDatabase.todos).get(),
    hasLength(2 + seededTaskCount),
  );
  if (seedRevokedHistory) {
    expect(
      await (clientDatabase.select(clientDatabase.syncDevices)
            ..where((row) => row.deviceId.equals('retired-phone')))
          .getSingleOrNull(),
      isNotNull,
    );
  }

  // Re-pair the same trusted host without disconnecting or emitting a new
  // baseline. Check both active and explicitly revoked registrations.
  final previousIdentity = (await container
      .read(syncRepositoryProvider)
      .activeIdentity())!;
  final originalOperationIds =
      (await clientDatabase.select(clientDatabase.syncChanges).get())
          .map((row) => row.operationId)
          .toSet();
  final originalProfile = container.read(syncClientControllerProvider).profile!;
  await controller.rePair(
    uri
        .replace(
          queryParameters: {...uri.queryParameters, 'group': 'unrelated-group'},
        )
        .toString(),
  );
  expect(
    container.read(syncClientControllerProvider).messageCode,
    'endpoint_identity_mismatch',
  );
  expect(
    container.read(syncClientControllerProvider).profile!.encode(),
    originalProfile.encode(),
  );
  for (final revoked in [false, true]) {
    if (revoked) {
      await (hostDatabase.update(hostDatabase.syncDevices)..where(
            (row) => row.deviceId.equals(previousIdentity.localDeviceId),
          ))
          .write(
            SyncDevicesCompanion(revokedAt: Value(DateTime.now().toUtc())),
          );
    }
    final reconnectInvite = await hostService.createPairingInvite();
    final reconnectUri = uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        'invite': reconnectInvite.id,
        'token': reconnectInvite.token,
      },
    );
    final reconnect = controller.rePair(reconnectUri.toString());
    await _waitUntil(
      () =>
          hostService.pendingPairingRequests.isNotEmpty &&
          container.read(syncClientControllerProvider).verificationCode != null,
    );
    final pendingReconnect = hostService.pendingPairingRequests.single;
    expect(pendingReconnect.device.deviceId, previousIdentity.localDeviceId);
    expect(await controller.synchronize(), isNull);
    expect(
      container.read(syncClientControllerProvider).phase,
      SyncClientPhase.waitingForApproval,
    );
    await hostService.approvePairing(pendingReconnect.id);
    await reconnect;
    expect(
      container.read(syncClientControllerProvider).phase,
      SyncClientPhase.synced,
    );
    expect(
      (await container.read(syncRepositoryProvider).activeIdentity())!
          .localDeviceId,
      previousIdentity.localDeviceId,
    );
    expect(
      (await clientDatabase.select(clientDatabase.syncChanges).get())
          .map((row) => row.operationId)
          .toSet(),
      originalOperationIds,
    );
    expect(
      container.read(syncClientControllerProvider).profile!.defaultEndpointId,
      originalProfile.defaultEndpointId,
    );
    expect(
      await container.read(syncRepositoryProvider).unresolvedConflicts(),
      isEmpty,
    );
    final device =
        await (hostDatabase.select(hostDatabase.syncDevices)..where(
              (row) => row.deviceId.equals(previousIdentity.localDeviceId),
            ))
            .getSingle();
    expect(device.revokedAt, isNull);
  }
  final cancelInvite = await hostService.createPairingInvite();
  final canceled = controller.rePair(
    uri
        .replace(
          queryParameters: {
            ...uri.queryParameters,
            'invite': cancelInvite.id,
            'token': cancelInvite.token,
          },
        )
        .toString(),
  );
  await _waitUntil(
    () =>
        hostService.pendingPairingRequests.isNotEmpty &&
        container.read(syncClientControllerProvider).verificationCode != null,
  );
  final cancelRequest = hostService.pendingPairingRequests.single;
  controller.cancelPairing();
  await canceled;
  await hostService.rejectPairing(cancelRequest.id);
  expect(container.read(syncClientControllerProvider).connected, isTrue);
  expect(
    (await container.read(syncRepositoryProvider).activeIdentity())!
        .localDeviceId,
    previousIdentity.localDeviceId,
  );
  expect(
    (await clientDatabase.select(clientDatabase.syncChanges).get())
        .map((row) => row.operationId)
        .toSet(),
    originalOperationIds,
  );

  final connectedClientTodos = container.read(todoRepositoryProvider);
  await connectedClientTodos.create(
    TodoDraft(
      title: 'Phone incremental task',
      localDate: LocalDate(2026, 9, 11),
    ),
  );
  await hostTodos.create(
    TodoDraft(
      title: 'Host incremental task',
      localDate: LocalDate(2026, 9, 12),
    ),
  );
  final result = await controller.synchronize();
  expect(result, isNotNull);
  expect(result!.uploaded, greaterThan(0));
  expect(result.downloaded, greaterThan(0));
  expect(
    await hostDatabase.select(hostDatabase.todos).get(),
    hasLength(4 + seededTaskCount),
  );
  expect(
    await clientDatabase.select(clientDatabase.todos).get(),
    hasLength(4 + seededTaskCount),
  );

  final hostEdited = (await hostTodos.getByDate(LocalDate(2026, 9, 9))).single;
  final clientEdited = (await clientTodos.getByDate(LocalDate(2026, 9, 9)))
      .single;
  await hostTodos.save(hostEdited.copyWith(title: 'Host conflict version'));
  await clientTodos.save(
    clientEdited.copyWith(title: 'Phone conflict version'),
  );
  await controller.synchronize();
  final clientConflicts = container
      .read(syncClientControllerProvider)
      .conflicts;
  expect(clientConflicts, isNotEmpty);
  expect(await hostSync.unresolvedConflicts(), isNotEmpty);

  await controller.resolveConflict(clientConflicts.first.id);
  expect(container.read(syncClientControllerProvider).conflicts, isEmpty);
  expect(await hostSync.unresolvedConflicts(), isEmpty);
  expect(
    (await hostTodos.getById(hostEdited.id))!.title,
    (await clientTodos.getById(clientEdited.id))!.title,
  );

  await hostService.stop();
  await connectedClientTodos.create(
    TodoDraft(
      title: 'Phone airplane-mode task',
      localDate: LocalDate(2026, 9, 13),
    ),
  );
  expect(await controller.synchronize(), isNull);
  expect(
    container.read(syncClientControllerProvider).phase,
    SyncClientPhase.offline,
  );
  expect(
    await hostDatabase.select(hostDatabase.todos).get(),
    hasLength(4 + seededTaskCount),
  );
  expect(
    await clientDatabase.select(clientDatabase.todos).get(),
    hasLength(5 + seededTaskCount),
  );

  await hostService.start(
    address: InternetAddress.loopbackIPv4,
    port: binding.port,
  );
  final recovered = await controller.synchronize();
  expect(recovered, isNotNull);
  expect(
    await hostDatabase.select(hostDatabase.todos).get(),
    hasLength(5 + seededTaskCount),
  );
  expect(
    await clientDatabase.select(clientDatabase.todos).get(),
    hasLength(5 + seededTaskCount),
  );

  if (capabilities.isWindows) {
    await controller.updateEndpointAndSynchronize(
      InternetAddress.loopbackIPv4.address,
      binding.port,
    );
    expect(
      container.read(syncClientControllerProvider).profile?.address,
      InternetAddress.loopbackIPv4.address,
    );
    expect(
      container.read(syncClientControllerProvider).phase,
      SyncClientPhase.synced,
    );
  }

  // A network/port change is not a new pairing. An untrusted QR must not
  // overwrite the last working address, cursor, or host identity.
  final previous = container.read(syncClientControllerProvider).profile!;
  await hostService.stop();
  final reservation = await ServerSocket.bind(
    InternetAddress.loopbackIPv4,
    binding.port,
  );
  final nextBinding = await hostService.start(
    address: InternetAddress.loopbackIPv4,
  );
  await reservation.close();
  Uri updateCode({
    String? group,
    String? fingerprint,
    DateTime? expires,
    int? port,
  }) => SyncEndpointUpdateCodec.encode(
    SyncEndpointUpdate(
      endpoint: SyncSavedEndpoint(
        address: nextBinding.address.address,
        port: port ?? nextBinding.port,
        label: 'WLAN',
      ),
      groupId: group ?? previous.groupId,
      hostDeviceId: previous.hostDevice.deviceId,
      fingerprintSha256: fingerprint ?? previous.fingerprintSha256,
      expiresAt:
          expires ?? DateTime.now().toUtc().add(const Duration(minutes: 10)),
    ),
  );
  await controller.applyEndpointUpdate(
    updateCode(group: 'another-group').toString(),
  );
  expect(
    container.read(syncClientControllerProvider).messageCode,
    'endpoint_identity_mismatch',
  );
  expect(
    container.read(syncClientControllerProvider).profile!.encode(),
    previous.encode(),
  );
  await controller.applyEndpointUpdate(
    updateCode(expires: DateTime.utc(2020)).toString(),
  );
  expect(
    container.read(syncClientControllerProvider).messageCode,
    'invalid_endpoint_code',
  );
  expect(
    container.read(syncClientControllerProvider).profile!.encode(),
    previous.encode(),
  );

  // Even a forged QR claiming the correct pin cannot replace it with another
  // TLS identity. Verification must happen before the endpoint is persisted.
  final rogue = SecureSyncHostService(
    database: hostDatabase,
    syncRepository: hostSync,
    tlsIdentityStore: HostTlsIdentityStore(MemoryDeviceSecretStore()),
    sessions: SyncSessionManager(
      publicKeyForDevice: (id) => activeDevicePublicKey(hostDatabase, id),
    ),
  );
  final rogueBinding = await rogue.start(address: InternetAddress.loopbackIPv4);
  try {
    await controller.applyEndpointUpdate(
      updateCode(port: rogueBinding.port).toString(),
    );
    expect(
      container.read(syncClientControllerProvider).messageCode,
      'fingerprint_mismatch',
    );
    expect(
      container.read(syncClientControllerProvider).profile!.encode(),
      previous.encode(),
    );
  } finally {
    await rogue.stop();
  }

  await controller.applyEndpointUpdate(updateCode().toString());
  var updated = container.read(syncClientControllerProvider).profile!;
  expect(
    container.read(syncClientControllerProvider).phase,
    SyncClientPhase.synced,
  );
  expect(updated.port, nextBinding.port);
  expect(
    updated.savedEndpoints.map((item) => item.id),
    contains(previous.baseUri.toString()),
  );
  final historyLength = updated.savedEndpoints.length;
  await controller.applyEndpointUpdate(updateCode().toString());
  expect(
    container.read(syncClientControllerProvider).profile!.savedEndpoints,
    hasLength(historyLength),
  );

  final preferredId = nextBinding.endpoint.toString();
  await controller.updateEndpointAndSynchronize('localhost', nextBinding.port);
  await controller.setDefaultEndpoint(preferredId);
  updated = container.read(syncClientControllerProvider).profile!;
  expect(updated.address, 'localhost');
  expect(updated.defaultEndpointId, preferredId);
  container.invalidate(syncClientControllerProvider);
  controller = container.read(syncClientControllerProvider.notifier);
  await controller.initialize();
  await _waitUntil(
    () =>
        container.read(syncClientControllerProvider).phase ==
            SyncClientPhase.synced &&
        container
                .read(syncClientControllerProvider)
                .profile
                ?.baseUri
                .toString() ==
            preferredId,
  );
  expect(
    container.read(syncClientControllerProvider).profile!.hostDevice.deviceId,
    previous.hostDevice.deviceId,
  );
  expect(
    await clientDatabase.select(clientDatabase.todos).get(),
    hasLength(5 + seededTaskCount),
  );

  await controller.disconnect();
  expect(
    container.read(syncClientControllerProvider).phase,
    SyncClientPhase.disconnected,
  );
  expect(await hostSync.activeIdentity(), isNotNull);
  expect(await container.read(syncRepositoryProvider).activeIdentity(), isNull);
  expect(
    await clientDatabase.select(clientDatabase.todos).get(),
    hasLength(5 + seededTaskCount),
  );
}

Future<void> _waitUntil(bool Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 10));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Timed out waiting for pairing request.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 25));
  }
}
