import 'package:drift/native.dart';
import 'package:echoday/src/data/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('schema version 1 creates every M1 table and critical index', () async {
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

    expect(database.schemaVersion, 1);
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
}
