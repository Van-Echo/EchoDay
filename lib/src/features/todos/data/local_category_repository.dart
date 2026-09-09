import 'package:drift/drift.dart';

import '../../../core/time/clock.dart';
import '../../../data/database/app_database.dart';
import '../../sync/data/database_sync_change_recorder.dart';
import '../../sync/domain/sync_change_recorder.dart';
import '../../sync/domain/sync_entity_payloads.dart';
import '../../sync/domain/sync_protocol.dart';
import '../domain/category.dart';
import '../domain/repositories/category_repository.dart';

final class LocalCategoryRepository implements CategoryRepository {
  factory LocalCategoryRepository(
    AppDatabase database, {
    UtcClock clock = systemUtcClock,
    SyncChangeRecorder? syncRecorder,
  }) => LocalCategoryRepository._(
    database,
    clock,
    syncRecorder ?? DatabaseSyncChangeRecorder(database, clock: clock),
  );

  LocalCategoryRepository._(this._database, this._clock, this._syncRecorder);

  final AppDatabase _database;
  final UtcClock _clock;
  final SyncChangeRecorder _syncRecorder;

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
  Future<Category> save(Category category) => _database.transaction(() async {
    final existingRow = await (_database.select(
      _database.categories,
    )..where((table) => table.id.equals(category.id))).getSingleOrNull();
    final existing = existingRow == null ? null : _toDomain(existingRow);
    final now = requireUtc(_clock(), 'clock');
    final saved = Category(
      id: category.id,
      name: category.name.trim(),
      colorValue: category.colorValue,
      sortOrder: category.sortOrder,
      createdAt:
          existing?.createdAt ?? requireUtc(category.createdAt, 'createdAt'),
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
    final changes = <PendingSyncChange>[];
    if (existing == null ||
        existing.name != saved.name ||
        existing.colorValue != saved.colorValue) {
      changes.add(
        PendingSyncChange(
          entityType: SyncEntityType.category,
          entityId: saved.id,
          operationType: SyncOperationType.upsert,
          fieldGroup: SyncFieldGroup.content,
          payload: SyncEntityPayloads.categoryContent(saved),
        ),
      );
    }
    if (existing == null || existing.sortOrder != saved.sortOrder) {
      changes.add(
        PendingSyncChange(
          entityType: SyncEntityType.category,
          entityId: saved.id,
          operationType: SyncOperationType.upsert,
          fieldGroup: SyncFieldGroup.order,
          payload: SyncEntityPayloads.categoryOrder(saved),
        ),
      );
    }
    if (existing?.deletedAt != saved.deletedAt && saved.deletedAt != null) {
      changes.add(_deletionChange(saved));
    } else if (existing?.deletedAt != null && saved.deletedAt == null) {
      changes.add(_deletionChange(saved));
    }
    await _syncRecorder.recordAll(changes);
    return saved;
  });

  @override
  Future<void> softDelete(String id, {DateTime? at}) async {
    await _database.transaction(() async {
      final row = await (_database.select(
        _database.categories,
      )..where((table) => table.id.equals(id))).getSingleOrNull();
      if (row == null || row.deletedAt != null) return;
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
      await _syncRecorder.recordAll([
        _deletionChange(_toDomain(row), deletedAt: now),
      ]);
    });
  }

  @override
  Future<void> undoDelete(String id) async {
    await _database.transaction(() async {
      final row = await (_database.select(
        _database.categories,
      )..where((table) => table.id.equals(id))).getSingleOrNull();
      if (row == null || row.deletedAt == null) return;
      final now = requireUtc(_clock(), 'clock');
      await _database.customUpdate(
        'UPDATE categories SET deleted_at = NULL, updated_at = ?, '
        'revision = revision + 1 WHERE id = ?',
        variables: [Variable<DateTime>(now), Variable<String>(id)],
        updates: {_database.categories},
      );
      await _syncRecorder.recordAll([
        _deletionChange(_toDomain(row), deletedAt: null),
      ]);
    });
  }

  PendingSyncChange _deletionChange(Category category, {DateTime? deletedAt}) {
    final value = deletedAt ?? category.deletedAt;
    return PendingSyncChange(
      entityType: SyncEntityType.category,
      entityId: category.id,
      operationType: value == null
          ? SyncOperationType.restore
          : SyncOperationType.delete,
      fieldGroup: SyncFieldGroup.deletion,
      payload: SyncEntityPayloads.deletion(value),
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
