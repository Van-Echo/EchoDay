import 'dart:io';

import 'package:drift/native.dart';
import 'package:echoday/src/app/platform/platform_capabilities.dart';
import 'package:echoday/src/app/providers/data_providers.dart';
import 'package:echoday/src/data/database/app_database.dart';
import 'package:echoday/src/features/backup/application/backup_maintenance_service.dart';
import 'package:echoday/src/features/backup/data/backup_directory_resolver.dart';
import 'package:echoday/src/features/backup/data/local_backup_repository.dart';
import 'package:echoday/src/features/sync/application/sync_client_controller.dart';
import 'package:echoday/src/features/sync/data/direct_sync_client.dart';
import 'package:echoday/src/features/sync/data/sync_connection_store.dart';
import 'package:echoday/src/features/sync/domain/sync_client_models.dart';
import 'package:echoday/src/features/sync/domain/sync_protocol.dart';
import 'package:echoday/src/features/sync/domain/sync_repository.dart';
import 'package:echoday/src/features/sync/security/device_identity.dart';
import 'package:echoday/src/features/sync/security/device_secret_store.dart';
import 'package:echoday/src/features/todos/domain/local_date.dart';
import 'package:echoday/src/features/todos/domain/todo_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/in_memory_settings_repository.dart';

void main() {
  test(
    'a local edit committed during pull is uploaded in the same run',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final settings = InMemorySettingsRepository();
      final temporary = await Directory.systemTemp.createTemp(
        'echoday-s7-queue-',
      );
      final secrets = MemoryDeviceSecretStore();
      final identityStore = DeviceIdentityStore(secrets);
      final identity = await identityStore.loadOrCreate(() => 'client-device');
      final host = SyncDeviceRegistration(
        deviceId: 'host-device',
        displayName: 'Main PC',
        platform: 'windows',
        appVersion: '1.0.0',
        publicKey: identity.publicKeyBase64Url,
      );
      final local = SyncDeviceRegistration(
        deviceId: identity.deviceId,
        displayName: 'Client',
        platform: 'windows',
        appVersion: '1.0.0',
        publicKey: identity.publicKeyBase64Url,
      );
      final backupRepository = LocalBackupRepository(
        database,
        safetyBackupDirectory: () async =>
            Directory('${temporary.path}/safety'),
      );
      final directories = BackupDirectoryResolver(
        settings,
        defaultRoot: () async => temporary,
      );
      late final _QueueAwareTransport transport;
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          settingsRepositoryProvider.overrideWithValue(settings),
          deviceSecretStoreProvider.overrideWithValue(secrets),
          backupRepositoryProvider.overrideWithValue(backupRepository),
          backupDirectoryResolverProvider.overrideWithValue(directories),
          backupMaintenanceServiceProvider.overrideWithValue(
            BackupMaintenanceService(backupRepository, settings, directories),
          ),
          platformCapabilitiesProvider.overrideWithValue(
            const PlatformCapabilities(isAndroid: false, isWindows: true),
          ),
          syncClientFactoryProvider.overrideWith(
            (ref) =>
                (baseUri, fingerprint, identity, identityStore) => transport,
          ),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await database.close();
        await settings.dispose();
        await temporary.delete(recursive: true);
      });

      await container
          .read(syncRepositoryProvider)
          .initializeClient(
            groupId: 'queue-group',
            hostDeviceId: host.deviceId,
            hostDevice: host,
            localDevice: local,
          );
      await SyncConnectionStore(settings).save(
        SyncClientProfile(
          address: InternetAddress.loopbackIPv4.address,
          port: 12380,
          fingerprintSha256: 'a' * 64,
          groupId: 'queue-group',
          hostDevice: host,
        ),
      );
      final todos = container.read(todoRepositoryProvider);
      await todos.create(
        TodoDraft(title: 'before pull', localDate: LocalDate(2026, 9, 9)),
      );
      transport = _QueueAwareTransport(
        host: host,
        onFirstPull: () => todos.create(
          TodoDraft(title: 'during pull', localDate: LocalDate(2026, 9, 10)),
        ),
      );

      final controller = container.read(syncClientControllerProvider.notifier);
      await controller.initialize(synchronizeOnLoad: false);
      final result = await controller.synchronize();

      expect(result, isNotNull);
      expect(transport.pushedBatches, hasLength(2));
      expect(transport.pushedBatches[0].operations, isNotEmpty);
      expect(transport.pushedBatches[1].operations, isNotEmpty);
      expect(
        transport.pushedBatches[1].operations.any(
          (operation) => operation.payload['title'] == 'during pull',
        ),
        isTrue,
      );
    },
  );
}

final class _QueueAwareTransport implements SyncClientTransport {
  _QueueAwareTransport({required this.host, required this.onFirstPull});

  final SyncDeviceRegistration host;
  final Future<Object?> Function() onFirstPull;
  final List<SyncBatch> pushedBatches = [];
  var _pulled = false;

  @override
  Future<void> acknowledge(SyncCursor cursor, String sessionToken) async {}

  @override
  void close() {}

  @override
  Future<List<SyncDeviceRegistration>> devices(String sessionToken) async => [
    host,
  ];

  @override
  Future<String> openSession() async => 'session';

  @override
  Future<ClientPairingStart> preparePairing({
    required SyncPairingEndpoint endpoint,
    required SyncDeviceRegistration device,
  }) => throw UnimplementedError();

  @override
  Future<ClientPairingStatus> pollPairing(ClientPairingStart start) =>
      throw UnimplementedError();

  @override
  Future<SyncBatch> pull(
    SyncCursor cursor,
    String sessionToken, {
    bool snapshot = false,
  }) async {
    if (!_pulled) {
      _pulled = true;
      await onFirstPull();
    }
    return SyncBatch(
      syncGroupId: 'queue-group',
      senderDeviceId: host.deviceId,
      cursor: cursor,
      operations: const [],
    );
  }

  @override
  Future<SyncPushReceipt> push(SyncBatch batch, String sessionToken) async {
    pushedBatches.add(batch);
    return SyncPushReceipt(acknowledgedCursor: batch.cursor, conflictCount: 0);
  }

  @override
  Future<void> verifyHost() async {}
}
