import 'dart:convert';

import 'package:echoday/l10n/app_localizations.dart';
import 'package:echoday/src/app/platform/platform_capabilities.dart';
import 'package:echoday/src/app/providers/data_providers.dart';
import 'package:echoday/src/features/calendar/application/calendar_controller.dart';
import 'package:echoday/src/features/holidays/domain/holiday_repository.dart';
import 'package:echoday/src/features/holidays/domain/holiday_year.dart';
import 'package:echoday/src/features/settings/application/app_preferences.dart';
import 'package:echoday/src/features/settings/presentation/settings_page.dart';
import 'package:echoday/src/features/todos/application/todo_providers.dart';
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

    expect(find.text('检查更新'), findsNothing);
    await tester.tap(find.text('中国法定节假日数据'));
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

  testWidgets('persists calendar preview and default sorting preferences', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final settings = InMemorySettingsRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settings),
          holidayRepositoryProvider.overrideWithValue(_HolidayRepository()),
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

    await tester.tap(find.text('日历与任务'));
    await tester.pumpAndSettle();
    final slider = find.byKey(const ValueKey('calendar-preview-slider'));
    await tester.drag(slider, const Offset(500, 0));
    await tester.pumpAndSettle();
    expect(
      int.parse((await settings.get(CalendarSettingKeys.previewLimit))!.value),
      greaterThan(6),
    );

    await tester.tap(find.byKey(const ValueKey('calendar-todo-font-size')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('16 px').last);
    await tester.pumpAndSettle();
    expect(
      (await settings.get(AppPreferenceKeys.calendarTodoFontSize))?.value,
      '16.0',
    );
    await tester.tap(find.byKey(const ValueKey('calendar-todo-font-size')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('5 px').last);
    await tester.pumpAndSettle();
    expect(
      (await settings.get(AppPreferenceKeys.calendarTodoFontSize))?.value,
      '5.0',
    );

    await tester.tap(find.byKey(const ValueKey('sidebar-todo-font-size')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('20 px').last);
    await tester.pumpAndSettle();
    expect(
      (await settings.get(AppPreferenceKeys.sidebarTodoFontSize))?.value,
      '20.0',
    );

    await tester.tap(find.byKey(const ValueKey('default-sort-field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('创建时间（早到晚）').last);
    await tester.pumpAndSettle();
    expect(
      (await settings.get(TodoSettingKeys.sortMode))?.value,
      'createdAtAscending',
    );

    await tester.scrollUntilVisible(
      find.text('数据备份与恢复'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('数据备份与恢复'), findsOneWidget);
    await tester.tap(find.text('数据备份与恢复'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('clear-data-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('clear-data-button')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('clear-data-confirm-dialog')),
      findsOneWidget,
    );
    expect(find.text('法定节假日缓存会保留', findRichText: true), findsNothing);
    expect(find.textContaining('法定节假日缓存会保留'), findsOneWidget);
    await tester.tap(find.text('取消').last);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('motto-settings')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('motto-settings')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('motto-bold-toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('motto-bold-toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('motto-font-size')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('18 px').last);
    await tester.pumpAndSettle();

    final mottoStyle = jsonDecode(
      (await settings.get(AppPreferenceKeys.mottoStyle))!.value,
    ) as Map<String, dynamic>;
    expect(mottoStyle['bold'], isFalse);
    expect(mottoStyle['fontSize'], 18.0);

    await tester.tap(find.byKey(const ValueKey('motto-color-button')));
    await tester.pumpAndSettle();
    final preview = tester.widget<Container>(
      find.byKey(const ValueKey('motto-color-preview')),
    );
    expect(
      (preview.decoration! as BoxDecoration).color,
      const Color(defaultCalendarMottoColorValue),
    );
  });

  testWidgets('Android settings remain scrollable at 360dp and 200% text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            InMemorySettingsRepository(),
          ),
          holidayRepositoryProvider.overrideWithValue(_HolidayRepository()),
          platformCapabilitiesProvider.overrideWithValue(
            const PlatformCapabilities(isAndroid: true, isWindows: false),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: const SettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('hotkey-settings')), findsNothing);
    expect(find.byKey(const ValueKey('motto-settings')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('theme-settings')));
    await tester.pumpAndSettle();
    expect(find.text('跟随系统'), findsOneWidget);
    expect(find.text('浅色'), findsOneWidget);
    expect(find.text('深色'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('language-settings')),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('language-settings')));
    await tester.pumpAndSettle();
    expect(find.text('English'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('calendar-task-settings')),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('calendar-task-settings')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('calendar-preview-slider')),
      findsOneWidget,
    );
    final expandTodaySwitch = find.byKey(
      const ValueKey('android-expand-today-by-default'),
    );
    final expansionEnabledSwitch = find.byKey(
      const ValueKey('android-calendar-cell-expansion-enabled'),
    );
    expect(expansionEnabledSwitch, findsOneWidget);
    expect(
      tester.widget<SwitchListTile>(expansionEnabledSwitch).value,
      isFalse,
    );
    expect(expandTodaySwitch, findsOneWidget);
    expect(tester.widget<SwitchListTile>(expandTodaySwitch).value, isFalse);
    expect(tester.widget<SwitchListTile>(expandTodaySwitch).onChanged, isNull);
    await tester.ensureVisible(expansionEnabledSwitch);
    await tester.pumpAndSettle();
    await tester.tap(expansionEnabledSwitch);
    await tester.pumpAndSettle();
    await tester.ensureVisible(expandTodaySwitch);
    await tester.pumpAndSettle();
    await tester.tap(expandTodaySwitch);
    await tester.pumpAndSettle();
    expect(
      (await (ProviderScope.containerOf(tester.element(expandTodaySwitch))
              .read(settingsRepositoryProvider)
              .get(AppPreferenceKeys.androidExpandTodayByDefault)))
          ?.value,
      'true',
    );
    expect(
      (await (ProviderScope.containerOf(tester.element(expandTodaySwitch))
              .read(settingsRepositoryProvider)
              .get(AppPreferenceKeys.androidCalendarCellExpansionEnabled)))
          ?.value,
      'true',
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('backup-settings')),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('backup-settings')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('choose-backup-directory')), findsNothing);
    expect(find.byKey(const ValueKey('automatic-backup-toggle')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
