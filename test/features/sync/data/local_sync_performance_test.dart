import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:echoday/src/core/ids/id_generator.dart';
import 'package:echoday/src/data/database/app_database.dart';
import 'package:echoday/src/features/sync/data/database_sync_change_recorder.dart';
import 'package:echoday/src/features/sync/data/direct_sync_client.dart';
import 'package:echoday/src/features/sync/data/local_sync_repository.dart';
import 'package:echoday/src/features/sync/domain/sync_protocol.dart';
import 'package:echoday/src/features/sync/domain/sync_repository.dart';
import 'package:echoday/src/features/sync/security/device_identity.dart';
import 'package:echoday/src/features/sync/security/device_secret_store.dart';
import 'package:echoday/src/features/sync/security/host_tls_identity.dart';
import 'package:echoday/src/features/sync/security/sync_session_manager.dart';
import 'package:echoday/src/features/sync/server/secure_sync_host_service.dart';
import 'package:echoday/src/features/todos/data/local_todo_repository.dart';
import 'package:echoday/src/features/todos/domain/local_date.dart';
import 'package:echoday/src/features/todos/domain/todo_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final enabled = Platform.environment['ECHODAY_SYNC_PERFORMANCE_TEST'] == '1';

  test(
    'ten thousand tasks complete an initial and incremental sync',
    () async {
      final hostDatabase = AppDatabase.forTesting(NativeDatabase.memory());
      final clientDatabase = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(hostDatabase.close);
      addTearDown(clientDatabase.close);

      final now = DateTime.utc(2026, 9, 9, 10);
      final hostIds = _SequentialIds('host');
      final clientIds = _SequentialIds('client');
      final hostRecorder = DatabaseSyncChangeRecorder(
        hostDatabase,
        idGenerator: hostIds,
        clock: () => now,
      );
      final clientRecorder = DatabaseSyncChangeRecorder(
        clientDatabase,
        idGenerator: clientIds,
        clock: () => now,
      );
      final hostSync = LocalSyncRepository(
        hostDatabase,
        idGenerator: hostIds,
        clock: () => now,
        recorder: hostRecorder,
      );
      final clientSync = LocalSyncRepository(
        clientDatabase,
        idGenerator: clientIds,
        clock: () => now,
        recorder: clientRecorder,
      );
      const hostDevice = SyncDeviceRegistration(
        deviceId: 'performance-host',
        displayName: 'Performance host',
        platform: 'windows',
        appVersion: '1.0.0',
        publicKey: 'performance-host-public-key',
      );
      final clientIdentityStore = DeviceIdentityStore(
        MemoryDeviceSecretStore(),
      );
      final clientIdentity = await clientIdentityStore.loadOrCreate(
        () => 'performance-client',
      );
      final clientDevice = SyncDeviceRegistration(
        deviceId: 'performance-client',
        displayName: 'Performance client',
        platform: 'android',
        appVersion: '1.0.0',
        publicKey: clientIdentity.publicKeyBase64Url,
      );

      await hostDatabase.batch((batch) {
        for (var index = 0; index < 10000; index++) {
          batch.insert(
            hostDatabase.todos,
            TodosCompanion.insert(
              id: 'sync-performance-$index',
              title: 'Sync performance task $index',
              localDate: LocalDate(2026, 1, 5).addDays(index % 70).toString(),
              createdAt: now.add(Duration(microseconds: index)),
              updatedAt: now.add(Duration(microseconds: index)),
              manualOrder: Value(index.toDouble()),
            ),
          );
        }
      });

      final baselineBuildWatch = Stopwatch()..start();
      await hostSync.initializeHost(
        groupId: 'performance-group',
        localDevice: hostDevice,
      );
      baselineBuildWatch.stop();
      await clientSync.initializeClient(
        groupId: 'performance-group',
        hostDeviceId: hostDevice.deviceId,
        hostDevice: hostDevice,
        localDevice: clientDevice,
      );
      await hostSync.registerDevice(clientDevice);
      final service = SecureSyncHostService(
        database: hostDatabase,
        syncRepository: hostSync,
        tlsIdentityStore: HostTlsIdentityStore(MemoryDeviceSecretStore()),
        sessions: SyncSessionManager(
          publicKeyForDevice: (deviceId) =>
              activeDevicePublicKey(hostDatabase, deviceId),
        ),
      );
      final binding = await service.start(
        address: InternetAddress.loopbackIPv4,
      );
      addTearDown(service.stop);
      final transport = DirectSyncClient(
        baseUri: binding.endpoint,
        fingerprintSha256: binding.fingerprintSha256,
        identity: clientIdentity,
        identityStore: clientIdentityStore,
        timeout: const Duration(minutes: 3),
      );
      addTearDown(transport.close);
      final sessionToken = await transport.openSession();

      final initialSyncWatch = Stopwatch()..start();
      final initial = await _drainRemote(
        transport,
        clientSync,
        sessionToken: sessionToken,
      );
      initialSyncWatch.stop();
      expect(initial.operations, 30000);
      expect(
        await clientDatabase.select(clientDatabase.todos).get(),
        hasLength(10000),
      );

      final hostTodos = LocalTodoRepository(
        hostDatabase,
        idGenerator: _SequentialIds('incremental-todo'),
        clock: () => now.add(const Duration(minutes: 1)),
        syncRecorder: hostRecorder,
      );
      for (var index = 0; index < 100; index++) {
        await hostTodos.create(
          TodoDraft(
            title: 'Incremental task $index',
            localDate: LocalDate(2026, 9, 10),
          ),
        );
      }

      final incrementalWatch = Stopwatch()..start();
      final incremental = await _drainRemote(
        transport,
        clientSync,
        sessionToken: sessionToken,
        cursor: initial.cursor,
      );
      incrementalWatch.stop();
      expect(incremental.operations, 300);
      expect(
        await clientDatabase.select(clientDatabase.todos).get(),
        hasLength(10100),
      );

      expect(baselineBuildWatch.elapsed, lessThan(const Duration(minutes: 3)));
      expect(initialSyncWatch.elapsed, lessThan(const Duration(minutes: 3)));
      expect(incrementalWatch.elapsed, lessThan(const Duration(seconds: 2)));

      // ignore: avoid_print
      print(
        'S8 10k sync metrics: baseline='
        '${baselineBuildWatch.elapsedMilliseconds}ms, initial='
        '${initialSyncWatch.elapsedMilliseconds}ms (${initial.batches} batches), '
        'incremental=${incrementalWatch.elapsedMilliseconds}ms '
        '(${incremental.batches} batches)',
      );
    },
    skip: enabled ? false : 'Set ECHODAY_SYNC_PERFORMANCE_TEST=1 to run.',
    timeout: const Timeout(Duration(minutes: 8)),
  );
}

Future<_DrainResult> _drainRemote(
  DirectSyncClient source,
  LocalSyncRepository target, {
  required String sessionToken,
  SyncCursor? cursor,
}) async {
  var acknowledged = cursor ?? SyncCursor();
  var operations = 0;
  var batches = 0;
  while (true) {
    final batch = await source.pull(acknowledged, sessionToken);
    if (batch.operations.isEmpty) break;
    final applied = await target.applyBatch(batch);
    acknowledged = applied.acknowledgedCursor;
    await source.acknowledge(acknowledged, sessionToken);
    operations += batch.operations.length;
    batches++;
  }
  return _DrainResult(acknowledged, operations, batches);
}

final class _DrainResult {
  const _DrainResult(this.cursor, this.operations, this.batches);

  final SyncCursor cursor;
  final int operations;
  final int batches;
}

final class _SequentialIds implements IdGenerator {
  _SequentialIds(this.prefix);

  final String prefix;
  var _next = 0;

  @override
  String next() => '$prefix-${_next++}';
}
