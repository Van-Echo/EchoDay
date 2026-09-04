import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/data_providers.dart';
import '../domain/category.dart';
import '../domain/local_date.dart';
import '../domain/tag.dart';
import '../domain/todo_item.dart';
import '../domain/todo_sort.dart';
import 'postpone_incomplete_todos.dart';
import 'recurrence_actions.dart';

abstract final class TodoSettingKeys {
  static const sortMode = 'todo.sortMode';
}

final recurrenceActionsProvider = Provider<RecurrenceActions>((ref) {
  return RecurrenceActions(
    database: ref.watch(appDatabaseProvider),
    todos: ref.watch(todoRepositoryProvider),
    recurrences: ref.watch(recurrenceRepositoryProvider),
  );
});

final postponeIncompleteTodosProvider = Provider<PostponeIncompleteTodos>((
  ref,
) {
  return PostponeIncompleteTodos(ref.watch(todoRepositoryProvider));
});

final todoSortModeProvider = StreamProvider<TodoSortMode>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.watch(TodoSettingKeys.sortMode).map((setting) {
    return TodoSortMode.values.firstWhere(
      (mode) => mode.name == setting?.value,
      orElse: () => TodoSortMode.composite,
    );
  });
});

final categoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchAll();
});

final tagsProvider = StreamProvider<List<Tag>>((ref) {
  return ref.watch(tagRepositoryProvider).watchAll();
});

final currentTimeProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now().toUtc();
  yield* Stream<DateTime>.periodic(
    const Duration(minutes: 1),
    (_) => DateTime.now().toUtc(),
  );
});

Future<void> setTodoSortMode(WidgetRef ref, TodoSortMode mode) {
  return ref
      .read(settingsRepositoryProvider)
      .set(TodoSettingKeys.sortMode, mode.name);
}

final todosByDateProvider = StreamProvider.autoDispose
    .family<List<TodoItem>, LocalDate>((ref, date) {
      final repository = ref.watch(todoRepositoryProvider);
      final mode =
          ref.watch(todoSortModeProvider).value ?? TodoSortMode.composite;
      return repository
          .watchByDate(date)
          .map((items) => sortTodos(items, mode));
    });
