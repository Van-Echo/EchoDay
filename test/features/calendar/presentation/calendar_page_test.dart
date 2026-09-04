import 'package:echoday/src/app/echoday_app.dart';
import 'package:echoday/src/app/providers/data_providers.dart';
import 'package:echoday/src/features/calendar/application/calendar_controller.dart';
import 'package:echoday/src/features/todos/application/todo_providers.dart';
import 'package:echoday/src/features/todos/domain/category.dart';
import 'package:echoday/src/features/todos/domain/tag.dart';
import 'package:echoday/src/features/todos/domain/todo_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/in_memory_settings_repository.dart';

void main() {
  late InMemorySettingsRepository settings;

  setUp(() => settings = InMemorySettingsRepository());

  Widget app() => ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(settings),
      todosByDateProvider.overrideWith(
        (ref, date) => Stream.value(const <TodoItem>[]),
      ),
      categoriesProvider.overrideWith(
        (ref) => Stream.value(const <Category>[]),
      ),
      tagsProvider.overrideWith((ref) => Stream.value(const <Tag>[])),
      holidayYearProvider.overrideWith((ref, year) async => null),
    ],
    child: const EchoDayApp(locale: Locale('zh')),
  );

  Finder dayCells() => find.byWidgetPredicate((widget) {
    final key = widget.key;
    return key is ValueKey<String> && key.value.startsWith('day-cell-');
  });

  Future<void> render(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('default five weeks exactly fill the remaining calendar height', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app());
    await render(tester);

    final gridSize = tester.getSize(
      find.byKey(const ValueKey('calendar-week-grid')),
    );
    final rowSize = tester.getSize(
      find.byKey(const ValueKey('calendar-week-0')),
    );

    expect(dayCells(), findsNWidgets(35));
    expect(rowSize.height * 5, closeTo(gridSize.height, 0.01));
    expect(find.byKey(const ValueKey('selected-day-sidebar')), findsOneWidget);
    expect(find.text('调休未覆盖'), findsOneWidget);
  });

  testWidgets('Full HD, 2K and 4K keep seven columns and five visible weeks', (
    tester,
  ) async {
    for (final size in [
      const Size(1920, 1080),
      const Size(2560, 1440),
      const Size(3840, 2160),
    ]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(app());
      await render(tester);

      expect(dayCells(), findsNWidgets(35));
      final firstRow = tester.getSize(
        find.byKey(const ValueKey('calendar-week-0')),
      );
      final firstCell = tester.getSize(dayCells().first);
      expect(firstCell.width * 7, closeTo(firstRow.width, 0.1));
    }
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('100 through 200 percent display scales preserve the grid', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final scale in [1.0, 1.25, 1.5, 2.0]) {
      tester.view.devicePixelRatio = scale;
      await tester.pumpWidget(app());
      await render(tester);
      expect(dayCells(), findsNWidgets(35));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('week controls zoom from five to six continuous weeks', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app());
    await render(tester);

    await tester.tap(find.byTooltip('显示更多周'));
    await render(tester);

    expect(dayCells(), findsNWidgets(42));
    expect(find.text('6 周'), findsOneWidget);
  });

  testWidgets(
    'single click selects and double click opens full-screen day TODO',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      late ProviderContainer container;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container = ProviderContainer(
            overrides: [
              settingsRepositoryProvider.overrideWithValue(settings),
              todosByDateProvider.overrideWith(
                (ref, date) => Stream.value(const <TodoItem>[]),
              ),
              categoriesProvider.overrideWith(
                (ref) => Stream.value(const <Category>[]),
              ),
              tagsProvider.overrideWith((ref) => Stream.value(const <Tag>[])),
              holidayYearProvider.overrideWith((ref, year) async => null),
            ],
          ),
          child: const EchoDayApp(locale: Locale('zh')),
        ),
      );
      addTearDown(container.dispose);
      await render(tester);
      final target = container.read(calendarControllerProvider).visibleDates[1];
      final finder = find.byKey(ValueKey('day-cell-$target'));

      await tester.tap(finder);
      await tester.pump(const Duration(milliseconds: 400));
      expect(container.read(calendarControllerProvider).selectedDate, target);

      await tester.tap(finder);
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tap(finder);
      await render(tester);
      expect(find.byTooltip('返回月历'), findsOneWidget);

      await tester.tap(find.byTooltip('返回月历'));
      await render(tester);
      expect(container.read(calendarControllerProvider).selectedDate, target);
      expect(find.byKey(ValueKey('day-cell-$target')), findsOneWidget);
    },
  );

  testWidgets('splitter clamps its sidebar ratio and narrow windows hide it', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    late ProviderContainer container;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container = ProviderContainer(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(settings),
            todosByDateProvider.overrideWith(
              (ref, date) => Stream.value(const <TodoItem>[]),
            ),
            categoriesProvider.overrideWith(
              (ref) => Stream.value(const <Category>[]),
            ),
            tagsProvider.overrideWith((ref) => Stream.value(const <Tag>[])),
            holidayYearProvider.overrideWith((ref, year) async => null),
          ],
        ),
        child: const EchoDayApp(locale: Locale('zh')),
      ),
    );
    addTearDown(container.dispose);
    await render(tester);

    final splitter = find.byKey(const ValueKey('calendar-sidebar-splitter'));
    await tester.drag(splitter, const Offset(-2000, 0));
    await render(tester);
    expect(container.read(calendarControllerProvider).sidebarRatio, 0.5);

    await tester.drag(splitter, const Offset(2000, 0));
    await render(tester);
    expect(container.read(calendarControllerProvider).sidebarRatio, 0.125);

    await tester.binding.setSurfaceSize(const Size(900, 720));
    await render(tester);
    expect(splitter, findsNothing);
    expect(find.byKey(const ValueKey('selected-day-sidebar')), findsNothing);
  });
}
