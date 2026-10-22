import '../domain/repositories/todo_repository.dart';
import '../domain/todo_item.dart';

final class TodoTransfers {
  const TodoTransfers(this._todos);

  final TodoRepository _todos;

  /// Copies the task to the day after its assigned date. A copy starts open
  /// and is independent of both the source task and any recurrence series.
  Future<TodoItem> copyToTomorrow(TodoItem todo) async {
    final source = await _todos.getById(todo.id);
    if (source == null) throw StateError('The source task no longer exists.');
    return _todos.create(
      TodoDraft(
        title: source.title,
        localDate: source.localDate.addDays(1),
        plannedAt: _nextDay(source.plannedAt),
        deadlineAt: _nextDay(source.deadlineAt),
        priority: source.priority,
        categoryId: source.categoryId,
        tagIds: source.tagIds,
        notes: source.notes,
        timeZoneId: source.timeZoneId,
      ),
    );
  }

  Future<TodoItem> moveToFuture(TodoItem todo) => _todos.moveToFuture(todo.id);

  DateTime? _nextDay(DateTime? value) {
    if (value == null) return null;
    final local = value.toLocal();
    return DateTime(
      local.year,
      local.month,
      local.day + 1,
      local.hour,
      local.minute,
      local.second,
      local.millisecond,
      local.microsecond,
    ).toUtc();
  }
}
