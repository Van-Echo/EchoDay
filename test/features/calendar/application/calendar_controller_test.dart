import 'package:drift/native.dart';
import 'package:echoday/src/app/providers/data_providers.dart';
import 'package:echoday/src/data/database/app_database.dart';
import 'package:echoday/src/features/calendar/application/calendar_controller.dart';
import 'package:echoday/src/features/settings/data/local_settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late ProviderContainer container;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test('loads and clamps persisted calendar preferences', () async {
    final settings = LocalSettingsRepository(database);
    await settings.set(CalendarSettingKeys.visibleWeekCount, '12');
    await settings.set(CalendarSettingKeys.previewLimit, '9');
    await settings.set(CalendarSettingKeys.sidebarRatio, '0.42');

    await container.read(calendarControllerProvider.notifier).loadPreferences();
    final state = container.read(calendarControllerProvider);

    expect(state.visibleWeekCount, 10);
    expect(state.previewLimit, 9);
    expect(state.sidebarRatio, 0.42);
  });

  test('zoom stays in 5 to 10 weeks and persists the result', () async {
    final controller = container.read(calendarControllerProvider.notifier);
    await controller.loadPreferences();

    await controller.changeVisibleWeeks(-10);
    expect(container.read(calendarControllerProvider).visibleWeekCount, 5);
    await controller.changeVisibleWeeks(2);
    expect(container.read(calendarControllerProvider).visibleWeekCount, 7);

    final stored = await container
        .read(settingsRepositoryProvider)
        .get(CalendarSettingKeys.visibleWeekCount);
    expect(stored?.value, '7');
  });

  test(
    'sidebar ratio clamps during drag and persists only on request',
    () async {
      final controller = container.read(calendarControllerProvider.notifier);
      controller.setSidebarRatio(0.9);
      expect(container.read(calendarControllerProvider).sidebarRatio, 0.5);

      await controller.persistSidebarRatio();
      final stored = await container
          .read(settingsRepositoryProvider)
          .get(CalendarSettingKeys.sidebarRatio);
      expect(stored?.value, '0.5');

      await controller.resetSidebarRatio();
      expect(container.read(calendarControllerProvider).sidebarRatio, 0.125);
    },
  );

  test('ordinary scrolling advances one continuous week', () {
    final controller = container.read(calendarControllerProvider.notifier);
    final before = container.read(calendarControllerProvider).anchorWeekStart;

    controller.scrollWeeks(1);

    expect(
      container.read(calendarControllerProvider).anchorWeekStart,
      before.addDays(7),
    );
  });

  test('month navigation keeps the selected date visible', () {
    final controller = container.read(calendarControllerProvider.notifier);
    final before = container.read(calendarControllerProvider).selectedDate;

    controller.showAdjacentMonth(1);
    final state = container.read(calendarControllerProvider);

    expect(state.selectedDate.month, before.month == 12 ? 1 : before.month + 1);
    expect(state.visibleDates, contains(state.selectedDate));
  });
}
