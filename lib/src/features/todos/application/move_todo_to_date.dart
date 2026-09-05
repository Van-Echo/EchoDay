import '../domain/local_date.dart';
import '../domain/repositories/todo_repository.dart';
import '../domain/todo_item.dart';

final class MoveTodoToDate {
  const MoveTodoToDate(this._todos);

  final TodoRepository _todos;

  Future<TodoItem> call(TodoItem todo, LocalDate targetDate) {
    if (todo.localDate == targetDate) return Future.value(todo);
    return _todos.save(
      todo.copyWith(
        localDate: targetDate,
        plannedAt: _moveToDate(todo.plannedAt, targetDate),
        deadlineAt: _moveToDate(todo.deadlineAt, targetDate),
      ),
    );
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
