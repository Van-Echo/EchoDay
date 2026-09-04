import 'package:echoday/l10n/app_localizations.dart';
import 'package:echoday/src/app/providers/data_providers.dart';
import 'package:echoday/src/features/holidays/domain/holiday_repository.dart';
import 'package:echoday/src/features/holidays/domain/holiday_year.dart';
import 'package:echoday/src/features/settings/presentation/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/in_memory_settings_repository.dart';

final class _HolidayRepository implements HolidayRepository {
  int? refreshedYear;

  @override
  Future<Set<int>> getAvailableYears() async => {2025, 2026};

  @override
  Future<HolidayYear?> getYear(int year) async => null;

  @override
  Future<HolidayRefreshResult> refresh(int year) async {
    refreshedYear = year;
    return HolidayRefreshResult(HolidayRefreshStatus.unavailable);
  }
}

void main() {
  testWidgets('selects a year and reports database plus website failure', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final holidays = _HolidayRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            InMemorySettingsRepository(),
          ),
          holidayRepositoryProvider.overrideWithValue(holidays),
        ],
        child: const MaterialApp(
          locale: Locale('zh'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('${DateTime.now().year + 1}').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('检查更新'));
    await tester.pumpAndSettle();

    expect(holidays.refreshedYear, DateTime.now().year + 1);
    expect(find.text('本地数据库和中国政府网均未找到该年度的有效节假日安排'), findsOneWidget);
  });
}
