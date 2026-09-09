import 'package:drift/drift.dart';

import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../../../data/database/app_database.dart';
import '../../sync/data/database_sync_change_recorder.dart';
import '../../sync/domain/sync_change_recorder.dart';
import '../../sync/domain/sync_entity_payloads.dart';
import '../../sync/domain/sync_protocol.dart';
import '../domain/local_date.dart';
import '../domain/recurrence_engine.dart';
import '../domain/recurrence_series.dart';
import '../domain/repositories/recurrence_repository.dart';

final class LocalRecurrenceRepository implements RecurrenceRepository {
  factory LocalRecurrenceRepository(
    AppDatabase database, {
    IdGenerator idGenerator = const UuidV7Generator(),
    UtcClock clock = systemUtcClock,
    RecurrenceRuleCodec codec = const RecurrenceRuleCodec(),
    SyncChangeRecorder? syncRecorder,
  }) => LocalRecurrenceRepository._(
    database,
    idGenerator,
    clock,
    codec,
    syncRecorder ?? DatabaseSyncChangeRecorder(database, clock: clock),
  );

  LocalRecurrenceRepository._(
    this._database,
    this._idGenerator,
    this._clock,
    this._codec,
    this._syncRecorder,
  );

  final AppDatabase _database;
  final IdGenerator _idGenerator;
  final UtcClock _clock;
  final RecurrenceRuleCodec _codec;
  final SyncChangeRecorder _syncRecorder;

  @override
  Stream<List<RecurrenceSeries>> watchAll() {
    final query = _database.select(_database.recurrenceSeriesEntries)
      ..where((table) => table.deletedAt.isNull())
      ..orderBy([(table) => OrderingTerm.asc(table.startDate)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<List<RecurrenceSeries>> getAll() async {
    final query = _database.select(_database.recurrenceSeriesEntries)
      ..where((table) => table.deletedAt.isNull())
      ..orderBy([(table) => OrderingTerm.asc(table.startDate)]);
    return (await query.get()).map(_toDomain).toList();
  }

  @override
  Future<RecurrenceSeries?> getById(String id) async {
    final query = _database.select(_database.recurrenceSeriesEntries)
      ..where((table) => table.id.equals(id) & table.deletedAt.isNull());
    final row = await query.getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<RecurrenceSeries> create(
    LocalDate startDate,
    RecurrenceRule rule,
  ) async {
    final now = requireUtc(_clock(), 'clock');
    return save(
      RecurrenceSeries(
        id: _idGenerator.next(),
        startDate: startDate,
        rule: rule,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  Future<RecurrenceSeries> save(RecurrenceSeries series) =>
      _database.transaction(() async {
        final existingRow = await (_database.select(
          _database.recurrenceSeriesEntries,
        )..where((table) => table.id.equals(series.id))).getSingleOrNull();
        final existing = existingRow == null ? null : _toDomain(existingRow);
        final now = requireUtc(_clock(), 'clock');
        final saved = RecurrenceSeries(
          id: series.id,
          startDate: series.startDate,
          rule: series.rule,
          timeZoneId: series.timeZoneId,
          createdAt: existing?.createdAt ?? series.createdAt,
          updatedAt: now,
          deletedAt: series.deletedAt,
          revision: (existing?.revision ?? 0) + 1,
        );
        await _database
            .into(_database.recurrenceSeriesEntries)
            .insertOnConflictUpdate(
              RecurrenceSeriesEntriesCompanion(
                id: Value(saved.id),
                startDate: Value(saved.startDate.toString()),
                ruleJson: Value(_codec.encode(saved.rule)),
                timeZoneId: Value(saved.timeZoneId),
                createdAt: Value(saved.createdAt),
                updatedAt: Value(saved.updatedAt),
                deletedAt: Value(saved.deletedAt),
                revision: Value(saved.revision),
              ),
            );
        final changes = <PendingSyncChange>[];
        if (existing == null ||
            existing.startDate != saved.startDate ||
            existing.timeZoneId != saved.timeZoneId ||
            _codec.encode(existing.rule) != _codec.encode(saved.rule)) {
          changes.add(
            PendingSyncChange(
              entityType: SyncEntityType.recurrenceSeries,
              entityId: saved.id,
              operationType: SyncOperationType.upsert,
              fieldGroup: SyncFieldGroup.content,
              payload: SyncEntityPayloads.recurrenceSeriesContent(
                saved,
                _codec,
              ),
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
  Future<void> truncateBefore(String id, LocalDate firstExcludedDate) async {
    final series = await getById(id);
    if (series == null) return;
    final until = firstExcludedDate.addDays(-1);
    await save(
      RecurrenceSeries(
        id: series.id,
        startDate: series.startDate,
        rule: RecurrenceRule(
          frequency: series.rule.frequency,
          interval: series.rule.interval,
          weekDays: series.rule.weekDays,
          monthDay: series.rule.monthDay,
          customUnit: series.rule.customUnit,
          untilDate: until,
          maxOccurrences: series.rule.maxOccurrences,
        ),
        timeZoneId: series.timeZoneId,
        createdAt: series.createdAt,
        updatedAt: series.updatedAt,
        revision: series.revision,
      ),
    );
  }

  @override
  Future<void> softDelete(String id, {DateTime? at}) async {
    await _database.transaction(() async {
      final row = await (_database.select(
        _database.recurrenceSeriesEntries,
      )..where((table) => table.id.equals(id))).getSingleOrNull();
      if (row == null || row.deletedAt != null) return;
      final now = requireUtc(at ?? _clock(), 'at');
      await (_database.update(
        _database.recurrenceSeriesEntries,
      )..where((table) => table.id.equals(id))).write(
        RecurrenceSeriesEntriesCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          revision: Value(row.revision + 1),
        ),
      );
      await _syncRecorder.recordAll([
        _deletionChange(_toDomain(row), deletedAt: now),
      ]);
    });
  }

  PendingSyncChange _deletionChange(
    RecurrenceSeries series, {
    DateTime? deletedAt,
  }) {
    final value = deletedAt ?? series.deletedAt;
    return PendingSyncChange(
      entityType: SyncEntityType.recurrenceSeries,
      entityId: series.id,
      operationType: value == null
          ? SyncOperationType.restore
          : SyncOperationType.delete,
      fieldGroup: SyncFieldGroup.deletion,
      payload: SyncEntityPayloads.deletion(value),
    );
  }

  RecurrenceSeries _toDomain(RecurrenceSeriesRow row) => RecurrenceSeries(
    id: row.id,
    startDate: LocalDate.parse(row.startDate),
    rule: _codec.decode(row.ruleJson),
    timeZoneId: row.timeZoneId,
    createdAt: row.createdAt.toUtc(),
    updatedAt: row.updatedAt.toUtc(),
    deletedAt: row.deletedAt?.toUtc(),
    revision: row.revision,
  );
}
