import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:echoday/src/data/database/app_database.dart';
import 'package:echoday/src/features/settings/data/local_settings_repository.dart';
import 'package:echoday/src/features/sync/data/local_sync_repository.dart';
import 'package:echoday/src/features/sync/domain/sync_repository.dart';
import 'package:echoday/src/features/todos/data/local_todo_repository.dart';
import 'package:echoday/src/features/todos/domain/local_date.dart';
import 'package:echoday/src/features/todos/domain/todo_item.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../drift/app_database/generated/schema_v3.dart' as v3;

/// Snapshot all user/sync rows without comparing the SQLite header or schema.
Future<Map<String, String>> snapshotRows(AppDatabase db) async => {
  for (final table in db.allTables)
    table.actualTableName: jsonEncode(
      (await db
              .customSelect(
                'SELECT * FROM "${table.actualTableName}" ORDER BY rowid',
              )
              .get())
          .map((row) => row.data)
          .toList(),
    ),
};

void main() {
  late Directory temporary;
  late File file;

  setUp(() async {
    temporary = await Directory.systemTemp.createTemp(
      'echoday-migration-recovery-',
    );
    file = File('${temporary.path}/test.sqlite');
  });

  tearDown(() => temporary.delete(recursive: true));

  for (final staleVersion in [3, 4]) {
    test(
      'recovers existing v5 columns with stale v$staleVersion header without changing rows',
      () async {
        final original = AppDatabase.forTesting(NativeDatabase(file));
        final todos = LocalTodoRepository(original);
        await todos.create(
          TodoDraft(title: 'Dated task', localDate: LocalDate(2026, 10, 22)),
        );
        await todos.create(
          TodoDraft(
            title: 'Future task',
            localDate: LocalDate(2026, 10, 22),
            isFuture: true,
          ),
        );
        final sync = LocalSyncRepository(original);
        final identity = await sync.initializeHost(
          localDevice: const SyncDeviceRegistration(
            deviceId: 'preserved-host',
            displayName: 'Test PC',
            platform: 'windows',
            appVersion: '1.0.8-dev.2',
            publicKey: 'preserved-public-key',
          ),
        );
        await LocalSettingsRepository(original)
            .set('device.sync.host.address', '100.64.0.10');
        final before = await snapshotRows(original);
        await original.customStatement('PRAGMA user_version = $staleVersion');
        await original.close();

        final recovered = AppDatabase.forTesting(NativeDatabase(file));
        try {
          expect(await snapshotRows(recovered), before);
          expect(
            (await recovered.customSelect('PRAGMA user_version').getSingle())
                .read<int>('user_version'),
            5,
          );
          expect(
            (await LocalSyncRepository(recovered).activeIdentity())!.groupId,
            identity.groupId,
          );
          expect(
            (await LocalTodoRepository(recovered).getFuture()).single.title,
            'Future task',
          );
        } finally {
          await recovered.close();
        }

        // A second application launch must not attempt the same ALTER again.
        final reopened = AppDatabase.forTesting(NativeDatabase(file));
        try {
          expect(await snapshotRows(reopened), before);
        } finally {
          await reopened.close();
        }
      },
    );
  }

  test('finishes a partially applied v3 to v4 migration', () async {
    final old = v3.DatabaseAtV3(NativeDatabase(file));
    await old.customStatement(
      'ALTER TABLE todos ADD COLUMN is_abandoned INTEGER NOT NULL DEFAULT 0',
    );
    await old.customStatement(
      "INSERT INTO todos(id,title,local_date,created_at,updated_at,is_abandoned) VALUES('kept','Keep abandoned','2026-10-22',1,1,1)",
    );
    await old.close();
    final recovered = AppDatabase.forTesting(NativeDatabase(file));
    try {
      final todo = (await recovered.select(recovered.todos).get()).single;
      expect(todo.isAbandoned, isTrue);
      expect(todo.abandonedAt, isNull);
      expect(todo.isFuture, isFalse);
      expect(
        (await recovered.customSelect('PRAGMA user_version').getSingle())
            .read<int>('user_version'),
        5,
      );
    } finally {
      await recovered.close();
    }
  });

  test(
    'incompatible existing columns fail safely and roll back additive changes',
    () async {
      final old = v3.DatabaseAtV3(NativeDatabase(file));
      await old.customStatement(
        "ALTER TABLE todos ADD COLUMN is_future TEXT NOT NULL DEFAULT '0'",
      );
      await old.close();
      final incompatible = AppDatabase.forTesting(NativeDatabase(file));
      try {
        await expectLater(
          incompatible.customSelect('SELECT 1').get(),
          throwsA(isA<StateError>()),
        );
      } finally {
        await incompatible.close();
      }
      final unchanged = v3.DatabaseAtV3(NativeDatabase(file));
      try {
        expect(
          (await unchanged.customSelect('PRAGMA user_version').getSingle())
              .read<int>('user_version'),
          3,
        );
        final names =
            (await unchanged.customSelect('PRAGMA table_info(todos)').get())
                .map((row) => row.read<String>('name'));
        expect(names, isNot(contains('is_abandoned')));
        expect(names, contains('is_future'));
      } finally {
        await unchanged.close();
      }
    },
  );

  test(
    'refuses unknown newer schemas without lowering their version',
    () async {
      final original = AppDatabase.forTesting(NativeDatabase(file));
      await original.customStatement('PRAGMA user_version = 6');
      await original.close();
      final unsupported = AppDatabase.forTesting(NativeDatabase(file));
      try {
        await expectLater(
          unsupported.customSelect('SELECT 1').get(),
          throwsA(isA<StateError>()),
        );
      } finally {
        await unsupported.close();
      }
      final inspector = _FutureDatabase(NativeDatabase(file));
      try {
        expect(
          (await inspector.customSelect('PRAGMA user_version').getSingle())
              .read<int>('user_version'),
          6,
        );
      } finally {
        await inspector.close();
      }
    },
  );
}

final class _FutureDatabase extends AppDatabase {
  _FutureDatabase(super.executor) : super.forTesting();

  @override
  int get schemaVersion => 6;
}
