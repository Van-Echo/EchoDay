import 'dart:io';

import 'package:echoday/src/features/holidays/data/gov_cn_holiday_source.dart';
import 'package:echoday/src/features/holidays/data/holiday_year_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final enabled = Platform.environment['ECHODAY_LIVE_HOLIDAY_TEST'] == '1';

  test('fetches published official notices from gov.cn', () async {
    for (final entry in {2025: 5, 2026: 6}.entries) {
      final payload = await const GovCnHolidaySource().fetchYear(entry.key);
      expect(payload, isNotNull, reason: 'year ${entry.key}');
      final year = const HolidayYearCodec().decode(payload!);
      expect(year.year, entry.key);
      expect(year.days.where((day) => !day.isDayOff), hasLength(entry.value));
    }
  }, skip: enabled ? false : 'Set ECHODAY_LIVE_HOLIDAY_TEST=1 to use gov.cn.');
}
