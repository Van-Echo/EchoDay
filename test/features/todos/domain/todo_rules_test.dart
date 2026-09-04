import 'package:echoday/src/features/todos/domain/local_date.dart';
import 'package:echoday/src/features/todos/domain/todo_item.dart';
import 'package:echoday/src/features/todos/domain/todo_priority.dart';
import 'package:echoday/src/features/todos/domain/todo_sort.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final base = DateTime.utc(2026, 9, 3, 8);

  TodoItem todo(
    String id, {
    TodoPriority priority = TodoPriority.none,
    DateTime? plannedAt,
    DateTime? deadlineAt,
    bool completed = false,
    double manualOrder = 0,
    int createdOffset = 0,
  }) {
    final createdAt = base.add(Duration(minutes: createdOffset));
    return TodoItem(
      id: id,
      title: id,
      localDate: LocalDate(2026, 9, 3),
      isCompleted: completed,
      createdAt: createdAt,
      updatedAt: createdAt,
      plannedAt: plannedAt,
      priority: priority,
      deadlineAt: deadlineAt,
      completedAt: completed ? createdAt : null,
      manualOrder: manualOrder,
    );
  }

  group('overdue', () {
    test('becomes overdue only after the DDL instant', () {
      final item = todo('a', deadlineAt: base);

      expect(
        item.isOverdueAt(base.subtract(const Duration(seconds: 1))),
        false,
      );
      expect(item.isOverdueAt(base), false);
      expect(item.isOverdueAt(base.add(const Duration(microseconds: 1))), true);
    });

    test('completed and deleted tasks are not overdue', () {
      final completed = todo('complete', deadlineAt: base, completed: true);
      final deleted = todo(
        'deleted',
        deadlineAt: base,
      ).copyWith(deletedAt: base);

      expect(completed.isOverdueAt(base.add(const Duration(days: 1))), false);
      expect(deleted.isOverdueAt(base.add(const Duration(days: 1))), false);
    });

    test('requires UTC to avoid hidden time-zone conversion', () {
      final item = todo('a', deadlineAt: base);

      expect(() => item.isOverdueAt(DateTime(2026)), throwsArgumentError);
    });
  });

  group('sorting', () {
    test('completed tasks always form the last partition', () {
      final completed = todo(
        'completed',
        priority: TodoPriority.high,
        completed: true,
      );
      final incomplete = todo('incomplete', priority: TodoPriority.none);

      for (final mode in TodoSortMode.values) {
        expect(sortTodos([completed, incomplete], mode).first.id, 'incomplete');
      }
    });

    test('composite uses priority, execution, DDL, creation, then id', () {
      final values = [
        todo('none', priority: TodoPriority.none),
        todo(
          'deadline-late',
          priority: TodoPriority.high,
          deadlineAt: base.add(const Duration(hours: 3)),
        ),
        todo(
          'planned-late',
          priority: TodoPriority.high,
          plannedAt: base.add(const Duration(hours: 2)),
        ),
        todo(
          'planned-early',
          priority: TodoPriority.high,
          plannedAt: base.add(const Duration(hours: 1)),
          deadlineAt: base.add(const Duration(hours: 8)),
        ),
        todo('medium', priority: TodoPriority.medium),
      ];

      expect(sortTodos(values, TodoSortMode.composite).map((item) => item.id), [
        'planned-early',
        'planned-late',
        'deadline-late',
        'medium',
        'none',
      ]);
    });

    test('manual and creation modes have deterministic fallbacks', () {
      final values = [
        todo('b', manualOrder: 1),
        todo('a', manualOrder: 1),
        todo('c', manualOrder: 0, createdOffset: 5),
      ];

      expect(sortTodos(values, TodoSortMode.manual).map((item) => item.id), [
        'c',
        'a',
        'b',
      ]);
      expect(
        sortTodos(
          values,
          TodoSortMode.createdAtDescending,
        ).map((item) => item.id),
        ['c', 'a', 'b'],
      );
    });

    test('planned time falls back to DDL and leaves missing values last', () {
      final values = [
        todo('none'),
        todo('ddl', deadlineAt: base.add(const Duration(hours: 2))),
        todo('planned', plannedAt: base.add(const Duration(hours: 1))),
      ];

      expect(
        sortTodos(values, TodoSortMode.plannedTime).map((item) => item.id),
        ['planned', 'ddl', 'none'],
      );
    });
  });
}
