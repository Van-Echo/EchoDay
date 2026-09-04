import '../tag.dart';

abstract interface class TagRepository {
  Stream<List<Tag>> watchAll();
  Future<List<Tag>> getAll();
  Future<Tag> save(Tag tag);
  Future<void> softDelete(String id, {DateTime? at});
  Future<void> undoDelete(String id);
}
