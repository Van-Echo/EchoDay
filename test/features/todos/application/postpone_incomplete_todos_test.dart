import 'package:drift/native.dart';
import 'package:echoday/src/data/database/app_database.dart';
import 'package:echoday/src/features/todos/application/postpone_incomplete_todos.dart';
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
  late PostponeIncompleteTodos postpone;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    todos = LocalTodoRepository(database);
    recurrences = LocalRecurrenceRepository(database);
    postpone = PostponeIncompleteTodos(todos);
  });

  tearDown(() => database.close());

  test(
    'moves incomplete items and their times while preserving completed items',
    () async {
      final date = LocalDate(2026, 9, 2);
      final nextDate = date.addDays(1);
      final planned = DateTime(2026, 9, 2, 9, 30).toUtc();
      final deadline = DateTime(2026, 9, 2, 18, 45).toUtc();
      final normal = await todos.create(
        TodoDraft(
          title: '普通任务',
          localDate: date,
          plannedAt: planned,
          deadlineAt: deadline,
        ),
      );
      final completed = await todos.create(
        TodoDraft(title: '已完成任务', localDate: date),
      );
      await todos.complete(completed.id);

      final series = await recurrences.create(
        LocalDate(2026, 9, 1),
        RecurrenceRule(frequency: RecurrenceFrequency.daily),
      );
      await todos.create(
        TodoDraft(
          title: '每日任务',
          localDate: LocalDate(2026, 9, 1),
          recurrenceSeriesId: series.id,
          occurrenceDate: LocalDate(2026, 9, 1),
        ),
      );

      expect(await postpone(date), 2);

      final originalDay = await todos.getByDate(date);
      expect(originalDay.map((item) => item.title), ['已完成任务']);
      final nextDay = await todos.getByDate(nextDate);
      final movedNormal = nextDay.singleWhere((item) => item.id == normal.id);
      expect(movedNormal.plannedAt?.toLocal().hour, 9);
      expect(movedNormal.plannedAt?.toLocal().minute, 30);
      expect(movedNormal.deadlineAt?.toLocal().hour, 18);
      expect(movedNormal.deadlineAt?.toLocal().minute, 45);
      expect(nextDay.where((item) => item.title == '每日任务'), hasLength(2));
      expect(
        nextDay
            .where((item) => item.title == '每日任务')
            .any((item) => item.occurrenceDate == date),
        isTrue,
      );
    },
  );
}
