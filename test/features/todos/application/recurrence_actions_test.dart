import 'package:drift/native.dart';
import 'package:echoday/src/data/database/app_database.dart';
import 'package:echoday/src/features/todos/application/recurrence_actions.dart';
import 'package:echoday/src/features/todos/data/local_recurrence_repository.dart';
import 'package:echoday/src/features/todos/data/local_todo_repository.dart';
import 'package:echoday/src/features/todos/domain/local_date.dart';
import 'package:echoday/src/features/todos/domain/recurrence_series.dart';
import 'package:echoday/src/features/todos/domain/todo_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late LocalTodoRepository todos;
  late LocalRecurrenceRepository recurrences;
  late RecurrenceActions actions;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    todos = LocalTodoRepository(database);
    recurrences = LocalRecurrenceRepository(database);
    actions = RecurrenceActions(
      database: database,
      todos: todos,
      recurrences: recurrences,
    );
  });

  tearDown(() => database.close());

  test(
    'this and future splits the series without rewriting its history',
    () async {
      final start = LocalDate(2026, 9, 1);
      final series = await recurrences.create(
        start,
        RecurrenceRule(frequency: RecurrenceFrequency.daily),
      );
      await todos.create(
        TodoDraft(
          title: '旧计划',
          localDate: start,
          recurrenceSeriesId: series.id,
          occurrenceDate: start,
        ),
      );
      final splitDate = LocalDate(2026, 9, 3);
      final occurrence = (await todos.getByDate(splitDate)).single;

      await actions.saveFrom(
        occurrence,
        occurrence.copyWith(title: '新计划'),
        scope: RecurrenceActionScope.thisAndFuture,
        futureRule: RecurrenceRule(frequency: RecurrenceFrequency.daily),
      );

      expect(
        (await todos.getByDate(LocalDate(2026, 9, 2))).single.title,
        '旧计划',
      );
      expect((await todos.getByDate(splitDate)).single.title, '新计划');
      expect(
        (await todos.getByDate(LocalDate(2026, 9, 4))).single.title,
        '新计划',
      );
      final allSeries = await recurrences.getAll();
      expect(allSeries, hasLength(2));
      expect(
        allSeries.where((item) => item.id == series.id).single.rule.untilDate,
        LocalDate(2026, 9, 2),
      );
    },
  );

  test('deleting only one virtual occurrence preserves later dates', () async {
    final start = LocalDate(2026, 9, 1);
    final series = await recurrences.create(
      start,
      RecurrenceRule(frequency: RecurrenceFrequency.daily),
    );
    await todos.create(
      TodoDraft(
        title: '每日任务',
        localDate: start,
        recurrenceSeriesId: series.id,
        occurrenceDate: start,
      ),
    );
    final targetDate = LocalDate(2026, 9, 2);
    final target = (await todos.getByDate(targetDate)).single;

    await actions.delete(target, scope: RecurrenceActionScope.occurrence);

    expect(await todos.getByDate(targetDate), isEmpty);
    expect(await todos.getByDate(LocalDate(2026, 9, 3)), hasLength(1));
  });
}
