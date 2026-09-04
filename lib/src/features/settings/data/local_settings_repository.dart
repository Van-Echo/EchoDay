import 'package:drift/drift.dart';

import '../../../core/time/clock.dart';
import '../../../data/database/app_database.dart';
import '../domain/app_setting.dart';

final class LocalSettingsRepository implements SettingsRepository {
  factory LocalSettingsRepository(
    AppDatabase database, {
    UtcClock clock = systemUtcClock,
  }) => LocalSettingsRepository._(database, clock);

  LocalSettingsRepository._(this._database, this._clock);

  final AppDatabase _database;
  final UtcClock _clock;

  @override
  Stream<AppSetting?> watch(String key) {
    final query = _database.select(_database.settings)
      ..where((table) => table.key.equals(key));
    return query.watchSingleOrNull().map(_toDomainOrNull);
  }

  @override
  Future<AppSetting?> get(String key) async {
    final query = _database.select(_database.settings)
      ..where((table) => table.key.equals(key));
    return _toDomainOrNull(await query.getSingleOrNull());
  }

  @override
  Future<void> set(String key, String value) async {
    if (key.trim().isEmpty) {
      throw ArgumentError.value(key, 'key', 'must not be blank');
    }
    final existing = await get(key);
    await _database
        .into(_database.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: key,
            value: value,
            updatedAt: requireUtc(_clock(), 'clock'),
            revision: Value((existing?.revision ?? 0) + 1),
          ),
        );
  }

  @override
  Future<void> remove(String key) async {
    await (_database.delete(
      _database.settings,
    )..where((table) => table.key.equals(key))).go();
  }

  AppSetting? _toDomainOrNull(SettingRow? row) {
    if (row == null) return null;
    return AppSetting(
      key: row.key,
      value: row.value,
      updatedAt: row.updatedAt.toUtc(),
      revision: row.revision,
    );
  }
}
