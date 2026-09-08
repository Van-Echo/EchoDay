import 'dart:io';

import 'package:echoday/src/features/holidays/data/gov_cn_holiday_source.dart';
import 'package:echoday/src/features/holidays/data/holiday_year_codec.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AOSP Android can fetch and validate the official holiday data', (
    tester,
  ) async {
    if (!Platform.isAndroid) return;
    final payload = await const GovCnHolidaySource().fetchYear(2026);
    expect(payload, isNotNull);
    final year = const HolidayYearCodec().decode(payload!);
    expect(year.year, 2026);
    expect(year.days, isNotEmpty);
    expect(year.days.any((day) => !day.isDayOff), isTrue);
  }, timeout: const Timeout(Duration(minutes: 2)));
}
