import 'package:drift/drift.dart';

import '../../../core/time/clock.dart';
import '../../../data/database/app_database.dart';
import '../domain/category.dart';
import '../domain/repositories/category_repository.dart';

final class LocalCategoryRepository implements CategoryRepository {
  factory LocalCategoryRepository(
    AppDatabase database, {
    UtcClock clock = systemUtcClock,
  }) => LocalCategoryRepository._(database, clock);

  LocalCategoryRepository._(this._database, this._clock);

  final AppDatabase _database;
  final UtcClock _clock;

  @override
  Stream<List<Category>> watchAll() {
    final query = _database.select(_database.categories)
      ..where((table) => table.deletedAt.isNull())
      ..orderBy([
        (table) => OrderingTerm.asc(table.sortOrder),
        (table) => OrderingTerm.asc(table.name),
      ]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<List<Category>> getAll() async {
    final query = _database.select(_database.categories)
      ..where((table) => table.deletedAt.isNull())
      ..orderBy([
        (table) => OrderingTerm.asc(table.sortOrder),
        (table) => OrderingTerm.asc(table.name),
      ]);
    return (await query.get()).map(_toDomain).toList();
  }

  @override
  Future<Category> save(Category category) async {
    final existing = await (_database.select(
      _database.categories,
    )..where((table) => table.id.equals(category.id))).getSingleOrNull();
    final now = requireUtc(_clock(), 'clock');
    final saved = Category(
      id: category.id,
      name: category.name.trim(),
      colorValue: category.colorValue,
      sortOrder: category.sortOrder,
      createdAt:
          existing?.createdAt.toUtc() ??
          requireUtc(category.createdAt, 'createdAt'),
      updatedAt: now,
      deletedAt: category.deletedAt == null
          ? null
          : requireUtc(category.deletedAt!, 'deletedAt'),
      revision: (existing?.revision ?? 0) + 1,
    );
    if (saved.name.isEmpty) {
      throw ArgumentError.value(category.name, 'name', 'must not be blank');
    }
    await _database
        .into(_database.categories)
        .insertOnConflictUpdate(
          CategoriesCompanion(
            id: Value(saved.id),
            name: Value(saved.name),
            colorValue: Value(saved.colorValue),
            sortOrder: Value(saved.sortOrder),
            createdAt: Value(saved.createdAt),
            updatedAt: Value(saved.updatedAt),
            deletedAt: Value(saved.deletedAt),
            revision: Value(saved.revision),
          ),
        );
    return saved;
  }

  @override
  Future<void> softDelete(String id, {DateTime? at}) async {
    final now = requireUtc(at ?? _clock(), 'at');
    await _database.customUpdate(
      'UPDATE categories SET deleted_at = ?, updated_at = ?, '
      'revision = revision + 1 WHERE id = ?',
      variables: [
        Variable<DateTime>(now),
        Variable<DateTime>(now),
        Variable<String>(id),
      ],
      updates: {_database.categories, _database.todos},
    );
  }

  @override
  Future<void> undoDelete(String id) async {
    final now = requireUtc(_clock(), 'clock');
    await _database.customUpdate(
      'UPDATE categories SET deleted_at = NULL, updated_at = ?, '
      'revision = revision + 1 WHERE id = ?',
      variables: [Variable<DateTime>(now), Variable<String>(id)],
      updates: {_database.categories},
    );
  }

  Category _toDomain(CategoryRow row) => Category(
    id: row.id,
    name: row.name,
    colorValue: row.colorValue,
    sortOrder: row.sortOrder,
    createdAt: row.createdAt.toUtc(),
    updatedAt: row.updatedAt.toUtc(),
    deletedAt: row.deletedAt?.toUtc(),
    revision: row.revision,
  );
}
