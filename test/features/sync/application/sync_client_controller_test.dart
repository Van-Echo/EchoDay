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
import 'package:echoday/src/features/sync/data/direct_sync_client.dart';
import 'package:echoday/src/features/sync/data/local_sync_repository.dart';
import 'package:echoday/src/features/sync/domain/sync_client_models.dart';
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

Future<void> _exerciseClient(PlatformCapabilities capabilities) async {
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
  final controller = container.read(syncClientControllerProvider.notifier);
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
  if (capabilities.isWindows) {
    expect(pairedState.profile?.address, 'localhost');
  }
  expect(await hostDatabase.select(hostDatabase.todos).get(), hasLength(2));
  expect(await clientDatabase.select(clientDatabase.todos).get(), hasLength(2));

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
  expect(await hostDatabase.select(hostDatabase.todos).get(), hasLength(4));
  expect(await clientDatabase.select(clientDatabase.todos).get(), hasLength(4));

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
  expect(await hostDatabase.select(hostDatabase.todos).get(), hasLength(4));
  expect(await clientDatabase.select(clientDatabase.todos).get(), hasLength(5));

  await hostService.start(
    address: InternetAddress.loopbackIPv4,
    port: binding.port,
  );
  final recovered = await controller.synchronize();
  expect(recovered, isNotNull);
  expect(await hostDatabase.select(hostDatabase.todos).get(), hasLength(5));
  expect(await clientDatabase.select(clientDatabase.todos).get(), hasLength(5));

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

  await controller.disconnect();
  expect(
    container.read(syncClientControllerProvider).phase,
    SyncClientPhase.disconnected,
  );
  expect(await hostSync.activeIdentity(), isNotNull);
  expect(await container.read(syncRepositoryProvider).activeIdentity(), isNull);
  expect(await clientDatabase.select(clientDatabase.todos).get(), hasLength(5));
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
