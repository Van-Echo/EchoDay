import 'dart:convert';

import 'package:drift/native.dart';
import 'package:echoday/src/data/database/app_database.dart';
import 'package:echoday/src/features/backup/data/backup_document_codec.dart';
import 'package:echoday/src/features/todos/application/move_todo_to_date.dart';
import 'package:echoday/src/features/todos/application/todo_transfers.dart';
import 'package:echoday/src/features/todos/data/local_recurrence_repository.dart';
import 'package:echoday/src/features/todos/data/local_tag_repository.dart';
import 'package:echoday/src/features/todos/data/local_todo_repository.dart';
import 'package:echoday/src/features/todos/domain/local_date.dart';
import 'package:echoday/src/features/todos/domain/recurrence_series.dart';
import 'package:echoday/src/features/todos/domain/tag.dart';
import 'package:echoday/src/features/todos/domain/todo_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late LocalTodoRepository todos;
  final now = DateTime.utc(2026, 10, 22, 8);
  final day = LocalDate(2026, 10, 22);

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    todos = LocalTodoRepository(database, clock: () => now);
  });
  tearDown(() => database.close());

  test(
    'copy keeps the original history and creates an independent open task',
    () async {
      await LocalTagRepository(database, clock: () => now).save(
        Tag(
          id: 'tag',
          name: 'Work',
          colorValue: 0xff336699,
          createdAt: now,
          updatedAt: now,
        ),
      );
      final planned = DateTime(2026, 10, 22, 9).toUtc();
      final ddl = DateTime(2026, 10, 24, 18).toUtc();
      final original = await todos.create(
        TodoDraft(
          title: 'Continue tomorrow',
          localDate: day,
          plannedAt: planned,
          deadlineAt: ddl,
          notes: 'Progress today',
          tagIds: {'tag'},
        ),
      );
      await todos.complete(original.id);
      final before = (await todos.getById(original.id))!;

      final copy = await TodoTransfers(todos).copyToTomorrow(before);

      final after = (await todos.getById(original.id))!;
      expect(after.revision, before.revision);
      expect(after.isCompleted, isTrue);
      expect(after.localDate, day);
      expect(copy.id, isNot(original.id));
      expect(copy.localDate, day.addDays(1));
      expect(copy.isTerminal, isFalse);
      expect(copy.isFuture, isFalse);
      expect(copy.recurrenceSeriesId, isNull);
      expect(copy.notes, before.notes);
      expect(copy.tagIds, before.tagIds);
      expect(copy.plannedAt, DateTime(2026, 10, 23, 9).toUtc());
      expect(copy.deadlineAt, DateTime(2026, 10, 25, 18).toUtc());
    },
  );

  test('future tasks leave dated lists, persist and return to today with the same ID', () async {
    final original = await todos.create(
      TodoDraft(title: 'Unscheduled idea', localDate: day),
    );
    final changed = todos.watchFuture().firstWhere((items) => items.isNotEmpty);
    final future = await todos.moveToFuture(original.id);
    expect((await changed).single.id, original.id);
    expect(await todos.getByDate(day), isEmpty);
    expect(
      (await LocalTodoRepository(database).getFuture()).single.id,
      original.id,
    );
    expect(future.isFuture, isTrue);

    final restored = await MoveTodoToDate(todos)(future, day);
    expect(restored.id, original.id);
    expect(restored.isFuture, isFalse);
    expect(await todos.getFuture(), isEmpty);
    expect((await todos.getByDate(day)).single.id, original.id);
  });

  test(
    'moving a recurring occurrence does not cancel or duplicate its series',
    () async {
      final series = await LocalRecurrenceRepository(
        database,
        clock: () => now,
      ).create(day, RecurrenceRule(frequency: RecurrenceFrequency.daily));
      final original = await todos.create(
        TodoDraft(
          title: 'Daily task',
          localDate: day,
          recurrenceSeriesId: series.id,
          occurrenceDate: day,
        ),
      );
      await todos.moveToFuture(original.id);
      expect(await todos.getByDate(day), isEmpty);
      final next = (await todos.getByDate(day.addDays(1))).single;
      final future = await todos.moveToFuture(next.id);
      expect(future.isFuture, isTrue);
      expect(await todos.getByDate(day.addDays(1)), isEmpty);
      expect(await todos.getFuture(), hasLength(2));
      expect(await todos.getByDate(day.addDays(2)), hasLength(1));
    },
  );

  test('backup codec preserves future state and accepts older rows', () async {
    final future = await todos.create(
      TodoDraft(title: 'Future', localDate: day, isFuture: true),
    );
    final row = (await database.select(database.todos).get()).single;
    const codec = BackupDocumentCodec();
    final json = codec.encodeRow(row);
    expect(codec.decodeTodo(json).isFuture, isTrue);
    final legacy = Map<String, dynamic>.from(json)..remove('isFuture');
    expect(
      codec
          .decodeTodo(jsonDecode(jsonEncode(legacy)) as Map<String, dynamic>)
          .isFuture,
      isFalse,
    );
    expect(future.isOverdueAt(now), isFalse);
  });
}
