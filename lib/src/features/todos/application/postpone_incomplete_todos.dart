import '../domain/local_date.dart';
import '../domain/repositories/todo_repository.dart';
import '../domain/todo_item.dart';

final class PostponeIncompleteTodos {
  const PostponeIncompleteTodos(this._todos);

  final TodoRepository _todos;

  Future<int> call(LocalDate date, {int days = 1}) async {
    _validateDays(days);
    final targetDate = date.addDays(days);
    final incomplete = (await _todos.getByDate(date))
        .where((todo) => !todo.isCompleted)
        .toList(growable: false);

    for (final todo in incomplete) {
      await _todos.save(
        todo.copyWith(
          localDate: targetDate,
          plannedAt: _moveToDate(todo.plannedAt, targetDate),
          deadlineAt: _moveToDate(todo.deadlineAt, targetDate),
        ),
      );
    }
    return incomplete.length;
  }

  Future<void> moveOne(TodoItem todo, {int days = 1}) async {
    _validateDays(days);
    if (todo.isCompleted) return;
    final targetDate = todo.localDate.addDays(days);
    await _todos.save(
      todo.copyWith(
        localDate: targetDate,
        plannedAt: _moveToDate(todo.plannedAt, targetDate),
        deadlineAt: _moveToDate(todo.deadlineAt, targetDate),
      ),
    );
  }

  void _validateDays(int days) {
    if (days < 1 || days > 365) {
      throw ArgumentError.value(days, 'days', 'must be between 1 and 365');
    }
  }

  DateTime? _moveToDate(DateTime? value, LocalDate target) {
    if (value == null) return null;
    final local = value.toLocal();
    return DateTime(
      target.year,
      target.month,
      target.day,
      local.hour,
      local.minute,
      local.second,
      local.millisecond,
      local.microsecond,
    ).toUtc();
  }
}
