import 'package:drift/drift.dart';
import 'package:flutter/services.dart';

import '../../../data/database/app_database.dart';
import '../domain/holiday_year.dart';
import 'holiday_year_codec.dart';

final class BundledHolidaySource {
  const BundledHolidaySource([this._codec = const HolidayYearCodec()]);

  static const availableYears = {2025, 2026};

  final HolidayYearCodec _codec;

  Future<HolidayYear?> getYear(int year) async {
    if (!availableYears.contains(year)) return null;
    final value = await rootBundle.loadString('assets/holidays/$year.json');
    return _codec.decode(value);
  }
}

final class CachedHolidaySource {
  const CachedHolidaySource(
    this._database, [
    this._codec = const HolidayYearCodec(),
  ]);

  final AppDatabase _database;
  final HolidayYearCodec _codec;

  Future<HolidayYear?> getYear(int year) async {
    final query = _database.select(_database.holidayYears)
      ..where((table) => table.year.equals(year));
    final row = await query.getSingleOrNull();
    return row == null ? null : _codec.decode(row.payloadJson);
  }

  Future<void> save(HolidayYear year) {
    return _database
        .into(_database.holidayYears)
        .insertOnConflictUpdate(
          HolidayYearsCompanion(
            year: Value(year.year),
            sourceUrl: Value(year.sourceUrl),
            dataVersion: Value(year.dataVersion),
            checksum: Value(year.checksum),
            payloadJson: Value(_codec.encode(year)),
            updatedAt: Value(year.updatedAt),
          ),
        );
  }

  Future<Set<int>> getAvailableYears() async {
    final rows = await _database.select(_database.holidayYears).get();
    return rows.map((row) => row.year).toSet();
  }
}

abstract interface class RemoteHolidaySource {
  Future<String?> fetchYear(int year);
}

final class UnconfiguredRemoteHolidaySource implements RemoteHolidaySource {
  const UnconfiguredRemoteHolidaySource();

  @override
  Future<String?> fetchYear(int year) async => null;
}
