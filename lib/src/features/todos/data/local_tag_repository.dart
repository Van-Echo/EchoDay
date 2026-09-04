import 'package:drift/drift.dart';

import '../../../core/time/clock.dart';
import '../../../data/database/app_database.dart';
import '../domain/repositories/tag_repository.dart';
import '../domain/tag.dart';

final class LocalTagRepository implements TagRepository {
  factory LocalTagRepository(
    AppDatabase database, {
    UtcClock clock = systemUtcClock,
  }) => LocalTagRepository._(database, clock);

  LocalTagRepository._(this._database, this._clock);

  final AppDatabase _database;
  final UtcClock _clock;

  @override
  Stream<List<Tag>> watchAll() {
    final query = _database.select(_database.tags)
      ..where((table) => table.deletedAt.isNull())
      ..orderBy([
        (table) => OrderingTerm.asc(table.sortOrder),
        (table) => OrderingTerm.asc(table.name),
      ]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<List<Tag>> getAll() async {
    final query = _database.select(_database.tags)
      ..where((table) => table.deletedAt.isNull())
      ..orderBy([
        (table) => OrderingTerm.asc(table.sortOrder),
        (table) => OrderingTerm.asc(table.name),
      ]);
    return (await query.get()).map(_toDomain).toList();
  }

  @override
  Future<Tag> save(Tag tag) async {
    final existing = await (_database.select(
      _database.tags,
    )..where((table) => table.id.equals(tag.id))).getSingleOrNull();
    final now = requireUtc(_clock(), 'clock');
    final saved = Tag(
      id: tag.id,
      name: tag.name.trim(),
      colorValue: tag.colorValue,
      sortOrder: tag.sortOrder,
      createdAt:
          existing?.createdAt.toUtc() ?? requireUtc(tag.createdAt, 'createdAt'),
      updatedAt: now,
      deletedAt: tag.deletedAt == null
          ? null
          : requireUtc(tag.deletedAt!, 'deletedAt'),
      revision: (existing?.revision ?? 0) + 1,
    );
    if (saved.name.isEmpty) {
      throw ArgumentError.value(tag.name, 'name', 'must not be blank');
    }
    await _database
        .into(_database.tags)
        .insertOnConflictUpdate(
          TagsCompanion(
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
      'UPDATE tags SET deleted_at = ?, updated_at = ?, '
      'revision = revision + 1 WHERE id = ?',
      variables: [
        Variable<DateTime>(now),
        Variable<DateTime>(now),
        Variable<String>(id),
      ],
      updates: {_database.tags, _database.todoTags},
    );
  }

  @override
  Future<void> undoDelete(String id) async {
    final now = requireUtc(_clock(), 'clock');
    await _database.customUpdate(
      'UPDATE tags SET deleted_at = NULL, updated_at = ?, '
      'revision = revision + 1 WHERE id = ?',
      variables: [Variable<DateTime>(now), Variable<String>(id)],
      updates: {_database.tags},
    );
  }

  Tag _toDomain(TagRow row) => Tag(
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
