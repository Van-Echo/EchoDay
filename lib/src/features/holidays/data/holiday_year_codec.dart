import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../todos/domain/local_date.dart';
import '../domain/holiday_year.dart';

final class HolidayYearCodec {
  const HolidayYearCodec();

  HolidayYear decode(String source) {
    final value = jsonDecode(source);
    if (value is! Map<String, dynamic> || value['schemaVersion'] != 1) {
      throw const FormatException('Unsupported holiday data schema.');
    }
    final year = value['year'];
    final sourceUrl = value['sourceUrl'];
    final dataVersion = value['dataVersion'];
    final checksum = value['checksum'];
    final updatedAtText = value['updatedAt'];
    final rawDays = value['days'];
    if (year is! int ||
        sourceUrl is! String ||
        sourceUrl.isEmpty ||
        dataVersion is! String ||
        dataVersion.isEmpty ||
        checksum is! String ||
        checksum.isEmpty ||
        updatedAtText is! String ||
        rawDays is! List) {
      throw const FormatException('Holiday metadata is incomplete.');
    }
    final updatedAt = DateTime.tryParse(updatedAtText)?.toUtc();
    if (updatedAt == null) {
      throw const FormatException('Holiday update time is invalid.');
    }
    final days = <HolidayDay>[];
    final dates = <String>{};
    for (final raw in rawDays) {
      if (raw is! Map<String, dynamic> ||
          raw['date'] is! String ||
          raw['name'] is! String ||
          raw['isDayOff'] is! bool) {
        throw const FormatException('Holiday day is invalid.');
      }
      final date = LocalDate.parse(raw['date'] as String);
      if (date.year != year || !dates.add(date.toString())) {
        throw const FormatException(
          'Holiday dates must be unique and in-year.',
        );
      }
      final name = (raw['name'] as String).trim();
      if (name.isEmpty) throw const FormatException('Holiday name is blank.');
      days.add(
        HolidayDay(
          date: date.toString(),
          name: name,
          isDayOff: raw['isDayOff'] as bool,
        ),
      );
    }
    days.sort((left, right) => left.date.compareTo(right.date));
    final expectedChecksum = calculateChecksum(
      year: year,
      sourceUrl: sourceUrl,
      dataVersion: dataVersion,
      days: days,
    );
    if (checksum != expectedChecksum) {
      throw const FormatException('Holiday data checksum is invalid.');
    }
    return HolidayYear(
      year: year,
      sourceUrl: sourceUrl,
      dataVersion: dataVersion,
      checksum: checksum,
      updatedAt: updatedAt,
      days: List.unmodifiable(days),
    );
  }

  String encode(HolidayYear year) {
    final expectedChecksum = calculateChecksum(
      year: year.year,
      sourceUrl: year.sourceUrl,
      dataVersion: year.dataVersion,
      days: year.days,
    );
    if (year.checksum != expectedChecksum) {
      throw const FormatException('Holiday data checksum is invalid.');
    }
    return jsonEncode({
      'schemaVersion': 1,
      'year': year.year,
      'sourceUrl': year.sourceUrl,
      'dataVersion': year.dataVersion,
      'checksum': year.checksum,
      'updatedAt': year.updatedAt.toUtc().toIso8601String(),
      'days': [
        for (final day in year.days)
          {'date': day.date, 'name': day.name, 'isDayOff': day.isDayOff},
      ],
    });
  }

  static String calculateChecksum({
    required int year,
    required String sourceUrl,
    required String dataVersion,
    required Iterable<HolidayDay> days,
  }) {
    final sortedDays = days.toList()
      ..sort((left, right) => left.date.compareTo(right.date));
    final parts = <String>['$year|$sourceUrl|$dataVersion'];
    for (final day in sortedDays) {
      parts.add('${day.date}|${day.name}|${day.isDayOff ? 1 : 0}');
    }
    return 'sha256:${sha256.convert(utf8.encode(parts.join(';')))}';
  }
}
