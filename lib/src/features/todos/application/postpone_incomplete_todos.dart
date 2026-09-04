import '../domain/local_date.dart';
import '../domain/repositories/todo_repository.dart';

final class PostponeIncompleteTodos {
  const PostponeIncompleteTodos(this._todos);

  final TodoRepository _todos;

  Future<int> call(LocalDate date) async {
    final targetDate = date.addDays(1);
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
