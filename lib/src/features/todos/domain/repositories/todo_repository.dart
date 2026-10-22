import '../local_date.dart';
import '../todo_item.dart';
import '../todo_search.dart';

abstract interface class TodoRepository {
  Stream<List<TodoItem>> watchByDate(LocalDate date);
  Future<List<TodoItem>> getByDate(LocalDate date);
  Stream<List<TodoItem>> watchFuture();
  Future<List<TodoItem>> getFuture();
  Future<TodoItem> moveToFuture(String id);
  Future<TodoItem?> getById(String id, {bool includeDeleted = false});
  Future<TodoItem> create(TodoDraft draft);
  Future<TodoItem> save(TodoItem todo);
  Future<void> complete(String id, {DateTime? at});
  Future<void> abandon(String id, {DateTime? at});
  Future<void> restore(String id);
  Future<void> softDelete(String id, {DateTime? at});
  Future<void> undoDelete(String id);
  Future<void> reorder(LocalDate date, List<String> orderedIds);
  Future<void> reorderFuture(List<String> orderedIds);
  Future<TodoSearchPage> search(TodoSearchQuery query);
}
