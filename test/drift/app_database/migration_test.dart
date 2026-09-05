// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:echoday/src/data/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  test('migration from v1 to v2 does not corrupt data', () async {
    final oldCategoriesData = <v1.CategoriesData>[];
    final expectedNewCategoriesData = <v2.CategoriesData>[];

    final oldRecurrenceSeriesData = <v1.RecurrenceSeriesData>[];
    final expectedNewRecurrenceSeriesData = <v2.RecurrenceSeriesData>[];

    const oldTodosData = <v1.TodosData>[
      v1.TodosData(
        id: 'migration-todo',
        title: '保留旧版本任务',
        localDate: '2026-09-05',
        isCompleted: 0,
        createdAt: 1788566400000,
        updatedAt: 1788566400000,
        plannedAt: 1788598800000,
        priority: 1,
        notes: 'v1 数据完整性验证',
        deadlineAt: 1788602400000,
        manualOrder: 2,
        revision: 3,
      ),
    ];
    const expectedNewTodosData = <v2.TodosData>[
      v2.TodosData(
        id: 'migration-todo',
        title: '保留旧版本任务',
        localDate: '2026-09-05',
        isCompleted: 0,
        createdAt: 1788566400000,
        updatedAt: 1788566400000,
        plannedAt: 1788598800000,
        priority: 1,
        notes: 'v1 数据完整性验证',
        deadlineAt: 1788602400000,
        manualOrder: 2,
        revision: 3,
      ),
    ];

    final oldTagsData = <v1.TagsData>[];
    final expectedNewTagsData = <v2.TagsData>[];

    final oldTodoTagsData = <v1.TodoTagsData>[];
    final expectedNewTodoTagsData = <v2.TodoTagsData>[];

    final oldRecurrenceExceptionsData = <v1.RecurrenceExceptionsData>[];
    final expectedNewRecurrenceExceptionsData = <v2.RecurrenceExceptionsData>[];

    final oldHolidayYearsData = <v1.HolidayYearsData>[];
    final expectedNewHolidayYearsData = <v2.HolidayYearsData>[];

    const oldSettingsData = <v1.SettingsData>[
      v1.SettingsData(
        key: 'appearance.themeMode',
        value: 'dark',
        updatedAt: 1788566400000,
        revision: 2,
      ),
    ];
    const expectedNewSettingsData = <v2.SettingsData>[
      v2.SettingsData(
        key: 'appearance.themeMode',
        value: 'dark',
        updatedAt: 1788566400000,
        revision: 2,
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.categories, oldCategoriesData);
        batch.insertAll(oldDb.recurrenceSeries, oldRecurrenceSeriesData);
        batch.insertAll(oldDb.todos, oldTodosData);
        batch.insertAll(oldDb.tags, oldTagsData);
        batch.insertAll(oldDb.todoTags, oldTodoTagsData);
        batch.insertAll(
          oldDb.recurrenceExceptions,
          oldRecurrenceExceptionsData,
        );
        batch.insertAll(oldDb.holidayYears, oldHolidayYearsData);
        batch.insertAll(oldDb.settings, oldSettingsData);
      },
      validateItems: (newDb) async {
        expect(
          expectedNewCategoriesData,
          await newDb.select(newDb.categories).get(),
        );
        expect(
          expectedNewRecurrenceSeriesData,
          await newDb.select(newDb.recurrenceSeries).get(),
        );
        expect(expectedNewTodosData, await newDb.select(newDb.todos).get());
        expect(expectedNewTagsData, await newDb.select(newDb.tags).get());
        expect(
          expectedNewTodoTagsData,
          await newDb.select(newDb.todoTags).get(),
        );
        expect(
          expectedNewRecurrenceExceptionsData,
          await newDb.select(newDb.recurrenceExceptions).get(),
        );
        expect(
          expectedNewHolidayYearsData,
          await newDb.select(newDb.holidayYears).get(),
        );
        expect(
          expectedNewSettingsData,
          await newDb.select(newDb.settings).get(),
        );
      },
    );
  });
}
