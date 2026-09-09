import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:echoday/src/core/ids/id_generator.dart';
import 'package:echoday/src/data/database/app_database.dart';
import 'package:echoday/src/features/sync/data/database_sync_change_recorder.dart';
import 'package:echoday/src/features/sync/data/local_sync_repository.dart';
import 'package:echoday/src/features/sync/domain/sync_protocol.dart';
import 'package:echoday/src/features/sync/domain/sync_repository.dart';
import 'package:echoday/src/features/todos/data/local_tag_repository.dart';
import 'package:echoday/src/features/todos/data/local_todo_repository.dart';
import 'package:echoday/src/features/todos/domain/local_date.dart';
import 'package:echoday/src/features/todos/domain/tag.dart';
import 'package:echoday/src/features/todos/domain/todo_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final now = DateTime.utc(2026, 9, 9, 10);
  const hostDevice = SyncDeviceRegistration(
    deviceId: 'device-host',
    displayName: 'Host PC',
    platform: 'windows',
    appVersion: '0.1.0',
    publicKey: 'host-public-key',
  );
  const clientDevice = SyncDeviceRegistration(
    deviceId: 'device-client',
    displayName: 'Android',
    platform: 'android',
    appVersion: '0.1.0',
    publicKey: 'client-public-key',
  );

  late AppDatabase hostDb;
  late AppDatabase clientDb;
  late LocalSyncRepository hostSync;
  late LocalSyncRepository clientSync;
  late LocalTodoRepository hostTodos;
  late LocalTodoRepository clientTodos;

  setUp(() async {
    hostDb = AppDatabase.forTesting(NativeDatabase.memory());
    clientDb = AppDatabase.forTesting(NativeDatabase.memory());
    final hostIds = _PrefixIds('host-operation');
    final clientIds = _PrefixIds('client-operation');
    DateTime clock() => now;
    final hostRecorder = DatabaseSyncChangeRecorder(
      hostDb,
      idGenerator: hostIds,
      clock: clock,
    );
    final clientRecorder = DatabaseSyncChangeRecorder(
      clientDb,
      idGenerator: clientIds,
      clock: clock,
    );
    hostSync = LocalSyncRepository(
      hostDb,
      idGenerator: hostIds,
      clock: clock,
      recorder: hostRecorder,
    );
    clientSync = LocalSyncRepository(
      clientDb,
      idGenerator: clientIds,
      clock: clock,
      recorder: clientRecorder,
    );
    hostTodos = LocalTodoRepository(
      hostDb,
      idGenerator: _PrefixIds('host-todo'),
      clock: clock,
      syncRecorder: hostRecorder,
    );
    clientTodos = LocalTodoRepository(
      clientDb,
      idGenerator: _PrefixIds('client-todo'),
      clock: clock,
      syncRecorder: clientRecorder,
    );
  });

  tearDown(() async {
    await hostDb.close();
    await clientDb.close();
  });

  test('snapshot baseline and offline field edits converge', () async {
    final hostTags = LocalTagRepository(hostDb, clock: () => now);
    await hostTags.save(
      Tag(
        id: 'tag-work',
        name: '工作',
        colorValue: 0xff767171,
        createdAt: now,
        updatedAt: now,
      ),
    );
    final original = await hostTodos.create(
      TodoDraft(
        title: '完成 EchoDay',
        localDate: LocalDate(2026, 9, 9),
        tagIds: const {'tag-work'},
      ),
    );

    await hostSync.initializeHost(
      groupId: 'echo-group',
      localDevice: hostDevice,
    );
    await clientSync.initializeClient(
      groupId: 'echo-group',
      hostDeviceId: hostDevice.deviceId,
      hostDevice: hostDevice,
      localDevice: clientDevice,
    );
    await hostSync.registerDevice(clientDevice);

    final baseline = await hostSync.changesAfter(SyncCursor());
    expect(baseline.operations, isNotEmpty);
    await clientSync.applyBatch(baseline);
    expect((await clientTodos.getById(original.id))?.title, '完成 EchoDay');
    expect(
      (await clientTodos.getById(original.id))?.tagIds,
      contains('tag-work'),
    );

    final clientBaselineCursor = baseline.cursor;
    await hostTodos.complete(original.id, at: now);
    final clientCopy = (await clientTodos.getById(original.id))!;
    await clientTodos.save(clientCopy.copyWith(title: '完成 EchoDay S2'));

    final hostDelta = await hostSync.changesAfter(clientBaselineCursor);
    await clientSync.applyBatch(hostDelta);
    final clientDelta = await clientSync.changesAfter(clientBaselineCursor);
    await hostSync.applyBatch(clientDelta);

    final hostResult = (await hostTodos.getById(original.id))!;
    final clientResult = (await clientTodos.getById(original.id))!;
    expect(hostResult.title, '完成 EchoDay S2');
    expect(clientResult.title, hostResult.title);
    expect(hostResult.isCompleted, isTrue);
    expect(clientResult.isCompleted, isTrue);
  });

  test('concurrent same-field edits converge and retain conflicts', () async {
    final original = await hostTodos.create(
      TodoDraft(title: '初始标题', localDate: LocalDate(2026, 9, 9)),
    );
    await hostSync.initializeHost(
      groupId: 'echo-group',
      localDevice: hostDevice,
    );
    await clientSync.initializeClient(
      groupId: 'echo-group',
      hostDeviceId: hostDevice.deviceId,
      hostDevice: hostDevice,
      localDevice: clientDevice,
    );
    await hostSync.registerDevice(clientDevice);
    final baseline = await hostSync.changesAfter(SyncCursor());
    await clientSync.applyBatch(baseline);

    await hostTodos.save(
      (await hostTodos.getById(original.id))!.copyWith(title: '主机修改'),
    );
    await clientTodos.save(
      (await clientTodos.getById(original.id))!.copyWith(title: '手机修改'),
    );

    await hostSync.applyBatch(await clientSync.changesAfter(baseline.cursor));
    await clientSync.applyBatch(await hostSync.changesAfter(baseline.cursor));

    expect(
      (await hostTodos.getById(original.id))!.title,
      (await clientTodos.getById(original.id))!.title,
    );
    final hostConflicts = await hostSync.unresolvedConflicts();
    expect(hostConflicts, isNotEmpty);
    expect(await clientSync.unresolvedConflicts(), isNotEmpty);

    await hostSync.resolveConflict(hostConflicts.single.id);
    expect(await hostSync.unresolvedConflicts(), isEmpty);
    await clientSync.applyBatch(await hostSync.changesAfter(baseline.cursor));
    expect(await clientSync.unresolvedConflicts(), isEmpty);
    expect(
      (await hostTodos.getById(original.id))!.title,
      (await clientTodos.getById(original.id))!.title,
    );
  });

  test(
    'failed business transaction cannot leave an orphan sync change',
    () async {
      await hostSync.initializeHost(
        groupId: 'echo-group',
        localDevice: hostDevice,
      );
      await expectLater(
        hostTodos.create(
          TodoDraft(
            title: '非法标签',
            localDate: LocalDate(2026, 9, 9),
            tagIds: const {'missing-tag'},
          ),
        ),
        throwsA(anything),
      );
      expect(await hostDb.select(hostDb.todos).get(), isEmpty);
      expect(await hostDb.select(hostDb.syncChanges).get(), isEmpty);
    },
  );

  test('three offline replicas converge after relay and replay', () async {
    const thirdDevice = SyncDeviceRegistration(
      deviceId: 'device-third',
      displayName: 'Second PC',
      platform: 'windows',
      appVersion: '0.1.0',
      publicKey: 'third-public-key',
    );
    final original = await hostTodos.create(
      TodoDraft(title: 'Three replicas', localDate: LocalDate(2026, 9, 9)),
    );
    await hostSync.initializeHost(
      groupId: 'echo-group',
      localDevice: hostDevice,
    );
    await clientSync.initializeClient(
      groupId: 'echo-group',
      hostDeviceId: hostDevice.deviceId,
      hostDevice: hostDevice,
      localDevice: clientDevice,
    );
    await hostSync.registerDevice(clientDevice);

    final thirdDb = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(thirdDb.close);
    final thirdIds = _PrefixIds('third-operation');
    final thirdRecorder = DatabaseSyncChangeRecorder(
      thirdDb,
      idGenerator: thirdIds,
      clock: () => now,
    );
    final thirdSync = LocalSyncRepository(
      thirdDb,
      idGenerator: thirdIds,
      clock: () => now,
      recorder: thirdRecorder,
    );
    final thirdTodos = LocalTodoRepository(
      thirdDb,
      idGenerator: _PrefixIds('third-todo'),
      clock: () => now,
      syncRecorder: thirdRecorder,
    );
    await thirdSync.initializeClient(
      groupId: 'echo-group',
      hostDeviceId: hostDevice.deviceId,
      hostDevice: hostDevice,
      localDevice: thirdDevice,
    );
    await hostSync.registerDevice(thirdDevice);
    await clientSync.registerDevice(thirdDevice);
    await thirdSync.registerDevice(clientDevice);

    final baseline = await hostSync.changesAfter(SyncCursor());
    await clientSync.applyBatch(baseline);
    await thirdSync.applyBatch(baseline);

    await hostTodos.complete(original.id, at: now);
    await clientTodos.save(
      (await clientTodos.getById(original.id))!.copyWith(notes: 'from phone'),
    );
    await thirdTodos.save(
      (await thirdTodos.getById(original.id))!.copyWith(manualOrder: 8),
    );

    await hostSync.applyBatch(await clientSync.changesAfter(baseline.cursor));
    await hostSync.applyBatch(await thirdSync.changesAfter(baseline.cursor));
    final relayed = await hostSync.changesAfter(baseline.cursor);
    await clientSync.applyBatch(relayed);
    await thirdSync.applyBatch(relayed);
    await clientSync.applyBatch(relayed);

    final host = (await hostTodos.getById(original.id))!;
    final client = (await clientTodos.getById(original.id))!;
    final third = (await thirdTodos.getById(original.id))!;
    expect(
      [client.title, client.notes, client.isCompleted, client.manualOrder],
      [host.title, host.notes, host.isCompleted, host.manualOrder],
    );
    expect(
      [third.title, third.notes, third.isCompleted, third.manualOrder],
      [host.title, host.notes, host.isCompleted, host.manualOrder],
    );
  });

  test('observed remove keeps a concurrent relation add', () async {
    await LocalTagRepository(hostDb, clock: () => now).save(
      Tag(
        id: 'tag-shared',
        name: 'Shared',
        colorValue: 0xff767171,
        createdAt: now,
        updatedAt: now,
      ),
    );
    final original = await hostTodos.create(
      TodoDraft(
        title: 'Relation merge',
        localDate: LocalDate(2026, 9, 9),
        tagIds: const {'tag-shared'},
      ),
    );
    await hostSync.initializeHost(
      groupId: 'echo-group',
      localDevice: hostDevice,
    );
    await clientSync.initializeClient(
      groupId: 'echo-group',
      hostDeviceId: hostDevice.deviceId,
      hostDevice: hostDevice,
      localDevice: clientDevice,
    );
    await hostSync.registerDevice(clientDevice);
    final baseline = await hostSync.changesAfter(SyncCursor());
    await clientSync.applyBatch(baseline);

    await hostTodos.save(
      (await hostTodos.getById(original.id))!.copyWith(tagIds: const {}),
    );
    await clientTodos.save(
      (await clientTodos.getById(original.id))!.copyWith(tagIds: const {}),
    );
    await clientTodos.save(
      (await clientTodos.getById(original.id))!
          .copyWith(tagIds: const {'tag-shared'}),
    );

    await hostSync.applyBatch(await clientSync.changesAfter(baseline.cursor));
    await clientSync.applyBatch(await hostSync.changesAfter(baseline.cursor));

    expect(
      (await hostTodos.getById(original.id))!.tagIds,
      contains('tag-shared'),
    );
    expect(
      (await clientTodos.getById(original.id))!.tagIds,
      contains('tag-shared'),
    );
  });

  test('compaction preserves winners and deletion tombstones', () async {
    await hostSync.initializeHost(
      groupId: 'echo-group',
      localDevice: hostDevice,
    );
    final todo = await hostTodos.create(
      TodoDraft(title: 'First title', localDate: LocalDate(2026, 9, 9)),
    );
    await hostTodos.save(
      (await hostTodos.getById(todo.id))!.copyWith(title: 'Winning title'),
    );
    await hostTodos.softDelete(todo.id, at: now);

    final before = await hostDb.select(hostDb.syncChanges).get();
    final compactor = LocalSyncRepository(
      hostDb,
      clock: () => now.add(const Duration(days: 31)),
    );
    expect(
      await compactor.compactAcknowledgedChanges(safetyWindow: Duration.zero),
      1,
    );
    final remaining = await hostDb.select(hostDb.syncChanges).get();
    expect(remaining, hasLength(before.length - 1));
    expect(
      remaining.where(
        (row) => row.entityId == todo.id && row.operationType == 'delete',
      ),
      hasLength(1),
    );
  });

  test('large baselines paginate without splitting a transaction', () async {
    for (var index = 0; index < 201; index++) {
      await hostTodos.create(
        TodoDraft(
          title: 'Baseline $index',
          localDate: LocalDate(2026, 9, 9),
          manualOrder: index.toDouble(),
        ),
      );
    }
    await hostSync.initializeHost(
      groupId: 'echo-group',
      localDevice: hostDevice,
    );
    await clientSync.initializeClient(
      groupId: 'echo-group',
      hostDeviceId: hostDevice.deviceId,
      hostDevice: hostDevice,
      localDevice: clientDevice,
    );
    await hostSync.registerDevice(clientDevice);

    final first = await hostSync.changesAfter(
      SyncCursor(),
      maximumOperations: 600,
    );
    expect(first.operations, hasLength(500));
    expect(first.cursor.sequenceFor(hostDevice.deviceId), 603);
    final applied = await clientSync.applyBatch(first);
    expect(applied.acknowledgedCursor.sequenceFor(hostDevice.deviceId), 500);

    final second = await hostSync.changesAfter(
      applied.acknowledgedCursor,
      maximumOperations: 600,
    );
    expect(second.operations, hasLength(103));
    await clientSync.applyBatch(second);
    expect(await clientDb.select(clientDb.todos).get(), hasLength(201));
  });
}

final class _PrefixIds implements IdGenerator {
  _PrefixIds(this.prefix);

  final String prefix;
  int _next = 0;

  @override
  String next() => '$prefix-${++_next}';
}
