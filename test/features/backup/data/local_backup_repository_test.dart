import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:echoday/src/data/database/app_database.dart';
import 'package:echoday/src/features/backup/data/local_backup_repository.dart';
import 'package:echoday/src/features/backup/domain/backup_repository.dart';
import 'package:echoday/src/features/todos/domain/local_date.dart';
import 'package:echoday/src/features/todos/domain/recurrence_engine.dart';
import 'package:echoday/src/features/todos/domain/recurrence_series.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late Directory temporaryDirectory;
  late LocalBackupRepository repository;
  final fixedNow = DateTime.utc(2026, 9, 5, 12, 34, 56);

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'echoday-backup-test-',
    );
    repository = LocalBackupRepository(
      database,
      safetyBackupDirectory: () async => temporaryDirectory,
      now: () => fixedNow,
    );
    await _seed(database, fixedNow);
  });

  tearDown(() async {
    await database.close();
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('exports a versioned backup without holiday cache', () async {
    final path =
        '${temporaryDirectory.path}${Platform.pathSeparator}backup.json';

    final manifest = await repository.exportTo(path);
    final preview = await repository.inspect(path);
    final json =
        jsonDecode(await File(path).readAsString()) as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;

    expect(manifest.formatVersion, 1);
    expect(manifest.exportedAt, fixedNow);
    expect(preview.isValid, isTrue);
    expect(preview.todoCount, 1);
    expect(preview.totalRecordCount, 7);
    expect(json['appVersion'], '0.1.0');
    expect(data.keys, isNot(contains('holidayYears')));
    expect(jsonEncode(json), isNot(contains('holiday.example')));
  });

  test('replace restores all user data and keeps holiday cache', () async {
    final path =
        '${temporaryDirectory.path}${Platform.pathSeparator}backup.json';
    await repository.exportTo(path);
    await _clearUserData(database);

    final result = await repository.replace(path);

    expect(result.importedCount, 7);
    expect(result.skippedCount, 0);
    expect(result.safetyBackupPath, isNot(null));
    expect(await File(result.safetyBackupPath!).exists(), isTrue);
    expect(await database.select(database.todos).get(), hasLength(1));
    expect(await database.select(database.categories).get(), hasLength(1));
    expect(await database.select(database.tags).get(), hasLength(1));
    expect(
      await database.select(database.recurrenceSeriesEntries).get(),
      hasLength(1),
    );
    expect(
      await database.select(database.recurrenceExceptions).get(),
      hasLength(1),
    );
    expect(await database.select(database.todoTags).get(), hasLength(1));
    expect(await database.select(database.settings).get(), hasLength(1));
    expect(await database.select(database.holidayYears).get(), hasLength(1));
  });

  test('merge de-duplicates stable IDs and relation keys', () async {
    final path =
        '${temporaryDirectory.path}${Platform.pathSeparator}backup.json';
    await repository.exportTo(path);

    final result = await repository.merge(path);

    expect(result.importedCount, 0);
    expect(result.skippedCount, 7);
    expect(await database.select(database.todos).get(), hasLength(1));
    expect(await database.select(database.todoTags).get(), hasLength(1));
  });

  test('invalid backup never changes the database', () async {
    final path =
        '${temporaryDirectory.path}${Platform.pathSeparator}invalid.json';
    await File(path).writeAsString('{"formatVersion":999}');

    final preview = await repository.inspect(path);

    expect(preview.isValid, isFalse);
    await expectLater(
      repository.replace(path),
      throwsA(isA<BackupFormatException>()),
    );
    expect(await database.select(database.todos).get(), hasLength(1));
    expect(await database.select(database.settings).get(), hasLength(1));
  });

  test('replace rolls back all deletions when an insert fails', () async {
    final path =
        '${temporaryDirectory.path}${Platform.pathSeparator}backup.json';
    await repository.exportTo(path);
    await database.customStatement('''
CREATE TRIGGER reject_restored_todo BEFORE INSERT ON todos
WHEN NEW.id = 'todo-1'
BEGIN
  SELECT RAISE(ABORT, 'simulated restore failure');
END;
''');

    await expectLater(repository.replace(path), throwsA(anything));

    final todos = await database.select(database.todos).get();
    expect(todos, hasLength(1));
    expect(todos.single.title, '完成 M5');
    expect(await database.select(database.settings).get(), hasLength(1));
    expect(await database.select(database.holidayYears).get(), hasLength(1));
  });

  test('uses the standard portable backup file name', () {
    expect(
      standardBackupFileName(DateTime(2026, 9, 5, 6, 7, 8)),
      'EchoDay-backup-20260905-060708.json',
    );
  });
}

Future<void> _seed(AppDatabase database, DateTime now) async {
  await database
      .into(database.categories)
      .insert(
        CategoriesCompanion.insert(
          id: 'category-1',
          name: '工作',
          colorValue: 0xFF788C77,
          createdAt: now,
          updatedAt: now,
        ),
      );
  await database
      .into(database.tags)
      .insert(
        TagsCompanion.insert(
          id: 'tag-1',
          name: 'M5',
          colorValue: 0xFF667E8C,
          createdAt: now,
          updatedAt: now,
        ),
      );
  await database
      .into(database.recurrenceSeriesEntries)
      .insert(
        RecurrenceSeriesEntriesCompanion.insert(
          id: 'series-1',
          startDate: LocalDate(2026, 9, 5).toString(),
          ruleJson: const RecurrenceRuleCodec().encode(
            RecurrenceRule(frequency: RecurrenceFrequency.daily),
          ),
          createdAt: now,
          updatedAt: now,
        ),
      );
  await database
      .into(database.todos)
      .insert(
        TodosCompanion.insert(
          id: 'todo-1',
          title: '完成 M5',
          localDate: '2026-09-05',
          createdAt: now,
          updatedAt: now,
          categoryId: const Value('category-1'),
          recurrenceSeriesId: const Value('series-1'),
          occurrenceDate: const Value('2026-09-05'),
        ),
      );
  await database
      .into(database.todoTags)
      .insert(TodoTagsCompanion.insert(todoId: 'todo-1', tagId: 'tag-1'));
  await database
      .into(database.recurrenceExceptions)
      .insert(
        RecurrenceExceptionsCompanion.insert(
          id: 'exception-1',
          seriesId: 'series-1',
          occurrenceDate: '2026-09-06',
          isSkipped: const Value(true),
          createdAt: now,
          updatedAt: now,
        ),
      );
  await database
      .into(database.settings)
      .insert(
        SettingsCompanion.insert(
          key: 'appearance.themeMode',
          value: 'dark',
          updatedAt: now,
        ),
      );
  await database
      .into(database.holidayYears)
      .insert(
        HolidayYearsCompanion.insert(
          year: const Value(2026),
          sourceUrl: 'https://holiday.example',
          dataVersion: 'test',
          checksum: 'checksum',
          payloadJson: '{}',
          updatedAt: now,
        ),
      );
}

Future<void> _clearUserData(AppDatabase database) async {
  await database.transaction(() async {
    await database.delete(database.todoTags).go();
    await database.delete(database.recurrenceExceptions).go();
    await database.delete(database.todos).go();
    await database.delete(database.recurrenceSeriesEntries).go();
    await database.delete(database.categories).go();
    await database.delete(database.tags).go();
    await database.delete(database.settings).go();
  });
}
