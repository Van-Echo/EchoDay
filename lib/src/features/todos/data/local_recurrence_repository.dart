import 'package:drift/drift.dart';

import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../../../data/database/app_database.dart';
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
  }) => LocalRecurrenceRepository._(database, idGenerator, clock, codec);

  LocalRecurrenceRepository._(
    this._database,
    this._idGenerator,
    this._clock,
    this._codec,
  );

  final AppDatabase _database;
  final IdGenerator _idGenerator;
  final UtcClock _clock;
  final RecurrenceRuleCodec _codec;

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
  Future<RecurrenceSeries> save(RecurrenceSeries series) async {
    final existing = await (_database.select(
      _database.recurrenceSeriesEntries,
    )..where((table) => table.id.equals(series.id))).getSingleOrNull();
    final now = requireUtc(_clock(), 'clock');
    final saved = RecurrenceSeries(
      id: series.id,
      startDate: series.startDate,
      rule: series.rule,
      timeZoneId: series.timeZoneId,
      createdAt: existing?.createdAt.toUtc() ?? series.createdAt,
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
    return saved;
  }

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
    final now = requireUtc(at ?? _clock(), 'at');
    await (_database.update(
      _database.recurrenceSeriesEntries,
    )..where((table) => table.id.equals(id))).write(
      RecurrenceSeriesEntriesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
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
