import '../category.dart';

abstract interface class CategoryRepository {
  Stream<List<Category>> watchAll();
  Future<List<Category>> getAll();
  Future<Category> save(Category category);
  Future<void> softDelete(String id, {DateTime? at});
  Future<void> undoDelete(String id);
}
