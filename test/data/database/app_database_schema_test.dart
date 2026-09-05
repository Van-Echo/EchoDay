import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:echoday/src/data/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('current schema creates every user table and critical index', () async {
    final objects = await database.customSelect(
      '''SELECT type, name FROM sqlite_master
WHERE name NOT LIKE 'sqlite_%' ORDER BY name''',
    ).get();
    final tableNames = objects
        .where((row) => row.read<String>('type') == 'table')
        .map((row) => row.read<String>('name'))
        .toSet();
    final indexNames = objects
        .where((row) => row.read<String>('type') == 'index')
        .map((row) => row.read<String>('name'))
        .toSet();

    expect(database.schemaVersion, 2);
    expect(
      tableNames,
      containsAll({
        'todos',
        'categories',
        'tags',
        'todo_tags',
        'recurrence_series',
        'recurrence_exceptions',
        'holiday_years',
        'settings',
      }),
    );
    expect(
      indexNames,
      containsAll({
        'todos_date_active',
        'todos_deadline',
        'todos_updated',
        'todos_active_date_completion',
        'todo_tags_tag',
        'recurrence_exceptions_series_date',
      }),
    );
  });

  test(
    'foreign keys are enabled and relation tables declare constraints',
    () async {
      final enabled = await database
          .customSelect('PRAGMA foreign_keys')
          .getSingle();
      final todoTagKeys = await database
          .customSelect('PRAGMA foreign_key_list(todo_tags)')
          .get();

      expect(enabled.read<int>('foreign_keys'), 1);
      expect(todoTagKeys, hasLength(2));
    },
  );

  test('active day query uses the v2 composite index', () async {
    final plan = await database
        .customSelect(
          '''EXPLAIN QUERY PLAN
SELECT * FROM todos
WHERE deleted_at IS NULL AND local_date = ? AND is_completed = ?''',
          variables: [
            const Variable<String>('2026-09-05'),
            const Variable<int>(0),
          ],
        )
        .get();

    expect(
      plan.map((row) => row.read<String>('detail')).join('\n'),
      contains('todos_active_date_completion'),
    );
  });
}
