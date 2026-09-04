import 'package:echoday/l10n/app_localizations.dart';
import 'package:echoday/src/app/widgets/echoday_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('range picker exposes year, month and clear controls', (
    tester,
  ) async {
    EchoDayDateRangeResult? result;
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    final future = showEchoDayDateRangePicker(
      context: context,
      initialRange: DateTimeRange(
        start: DateTime(2026, 9, 1),
        end: DateTime(2026, 9, 5),
      ),
    ).then((value) => result = value);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('date-picker-year')), findsOneWidget);
    expect(find.byKey(const ValueKey('date-picker-month')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('date-picker-clear')));
    await tester.pumpAndSettle();
    await future;
    expect(result, isNotNull);
    expect(result?.range, isNull);
  });

  testWidgets('double-clicking a day confirms without the save button', (
    tester,
  ) async {
    EchoDayDateRangeResult? result;
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    final future = showEchoDayDateRangePicker(
      context: context,
      initialRange: DateTimeRange(
        start: DateTime(2026, 9, 1),
        end: DateTime(2026, 9, 5),
      ),
    ).then((value) => result = value);
    await tester.pumpAndSettle();
    final day = find.byKey(const ValueKey('date-picker-day-12'));
    await tester.tap(day);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(day);
    await tester.pumpAndSettle();
    await future;

    expect(result?.range?.start.day, 12);
    expect(result?.range?.end.day, 12);
    expect(find.byKey(const ValueKey('date-picker-save')), findsNothing);
  });
}
