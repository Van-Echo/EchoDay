import 'todo_item.dart';

enum TodoSortMode {
  manual,
  createdAtAscending,
  createdAtDescending,
  plannedTime,
  priority,
  composite,
}

List<TodoItem> sortTodos(Iterable<TodoItem> todos, TodoSortMode mode) {
  final result = todos.toList(growable: false);
  result.sort((left, right) {
    final completed = _compareBool(left.isCompleted, right.isCompleted);
    if (completed != 0) return completed;

    final comparison = switch (mode) {
      TodoSortMode.manual => _manual(left, right),
      TodoSortMode.createdAtAscending => left.createdAt.compareTo(
        right.createdAt,
      ),
      TodoSortMode.createdAtDescending => right.createdAt.compareTo(
        left.createdAt,
      ),
      TodoSortMode.plannedTime => _planned(left, right),
      TodoSortMode.priority => left.priority.sortRank.compareTo(
        right.priority.sortRank,
      ),
      TodoSortMode.composite => _composite(left, right),
    };
    if (comparison != 0) return comparison;
    final created = left.createdAt.compareTo(right.createdAt);
    return created != 0 ? created : left.id.compareTo(right.id);
  });
  return result;
}

int _manual(TodoItem left, TodoItem right) {
  return left.manualOrder.compareTo(right.manualOrder);
}

int _planned(TodoItem left, TodoItem right) {
  return _compareNullableDate(
    left.plannedAt ?? left.deadlineAt,
    right.plannedAt ?? right.deadlineAt,
  );
}

int _composite(TodoItem left, TodoItem right) {
  var value = left.priority.sortRank.compareTo(right.priority.sortRank);
  if (value != 0) return value;

  value = _compareNullableDate(left.plannedAt, right.plannedAt);
  if (value != 0) return value;

  value = _compareNullableDate(left.deadlineAt, right.deadlineAt);
  if (value != 0) return value;

  return left.createdAt.compareTo(right.createdAt);
}

int _compareBool(bool left, bool right) {
  if (left == right) return 0;
  return left ? 1 : -1;
}

int _compareNullableDate(DateTime? left, DateTime? right) {
  if (left == null && right == null) return 0;
  if (left == null) return 1;
  if (right == null) return -1;
  return left.compareTo(right);
}
