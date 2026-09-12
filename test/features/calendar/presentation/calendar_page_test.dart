import 'dart:async';

import 'package:echoday/src/app/echoday_app.dart';
import 'package:echoday/src/app/platform/platform_capabilities.dart';
import 'package:echoday/src/app/providers/data_providers.dart';
import 'package:echoday/src/features/calendar/application/calendar_controller.dart';
import 'package:echoday/src/features/settings/application/app_preferences.dart';
import 'package:echoday/src/features/settings/application/hotkey_preferences.dart';
import 'package:echoday/src/features/todos/application/todo_providers.dart';
import 'package:echoday/src/features/todos/domain/category.dart';
import 'package:echoday/src/features/todos/domain/local_date.dart';
import 'package:echoday/src/features/todos/domain/repositories/todo_repository.dart';
import 'package:echoday/src/features/todos/domain/tag.dart';
import 'package:echoday/src/features/todos/domain/todo_item.dart';
import 'package:echoday/src/features/todos/domain/todo_search.dart';
import 'package:echoday/src/features/todos/presentation/day_todo_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import '../../../support/in_memory_settings_repository.dart';

void main() {
  late InMemorySettingsRepository settings;

  setUp(() => settings = InMemorySettingsRepository());

  Widget app({Locale locale = const Locale('zh'), bool isAndroid = false}) =>
      ProviderScope(
        overrides: [
          platformCapabilitiesProvider.overrideWithValue(
            PlatformCapabilities(isAndroid: isAndroid, isWindows: !isAndroid),
          ),
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
        child: EchoDayApp(locale: locale),
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

  testWidgets('add TODO hotkey request opens editor for selected date', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    late ProviderContainer container;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container = ProviderContainer(
          overrides: [
            platformCapabilitiesProvider.overrideWithValue(
              const PlatformCapabilities(isAndroid: false, isWindows: true),
            ),
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

    final selectedDate = container
        .read(calendarControllerProvider)
        .selectedDate;
    container.read(addTodoHotkeyRequestProvider.notifier).request(selectedDate);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byKey(const ValueKey('todo-editor-desktop')), findsOneWidget);
    expect(
      container.read(calendarControllerProvider).selectedDate,
      selectedDate,
    );
  });

  testWidgets('Android focus card follows its startup preference', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(412, 915));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final today = LocalDate.fromDateTime(DateTime.now());
    await settings.set(
      AppPreferenceKeys.androidCalendarCellExpansionEnabled,
      'true',
    );
    await settings.set(AppPreferenceKeys.androidExpandTodayByDefault, 'true');

    await tester.pumpWidget(app(isAndroid: true));
    await render(tester);

    expect(dayCells(), findsNWidgets(14));
    expect(
      find.byKey(const ValueKey('compact-bottom-navigation')),
      findsOneWidget,
    );
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byKey(const ValueKey('calendar-motto')), findsNothing);
    expect(find.byKey(const ValueKey('android-todo-pane')), findsOneWidget);
    final focusCard = find.byKey(ValueKey('expanded-day-card-$today'));
    expect(focusCard, findsOneWidget);
    final dayCellSize = tester.getSize(find.byKey(ValueKey('day-cell-$today')));
    final focusCardSize = tester.getSize(focusCard);
    expect(focusCardSize.width, closeTo(dayCellSize.width * 3, 0.01));
    expect(focusCardSize.height, closeTo(dayCellSize.height * 2, 0.01));
    final calendarHeight = tester
        .getSize(find.byKey(const ValueKey('android-calendar-pane')))
        .height;
    final todoHeight = tester
        .getSize(find.byKey(const ValueKey('android-todo-pane')))
        .height;
    expect(todoHeight / calendarHeight, closeTo(1.5, 0.02));
    final month = find.descendant(
      of: focusCard,
      matching: find.text(
        DateFormat.MMM('zh')
            .format(DateTime(today.year, today.month, today.day)),
      ),
    );
    final day = find.descendant(
      of: focusCard,
      matching: find.text('${today.day}'),
    );
    expect(tester.getCenter(month).dx, lessThan(tester.getCenter(day).dx));

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await render(tester);
    expect(find.byKey(const ValueKey('motto-settings')), findsNothing);
    expect(find.byKey(const ValueKey('hotkey-settings')), findsNothing);
    expect(find.byKey(const ValueKey('language-settings')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Android does not expand today by default', (tester) async {
    await tester.binding.setSurfaceSize(const Size(412, 915));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(app(isAndroid: true));
    await render(tester);

    final today = LocalDate.fromDateTime(DateTime.now());
    expect(find.byKey(ValueKey('expanded-day-card-$today')), findsNothing);

    final todayWeekday = DateTime(today.year, today.month, today.day).weekday;
    final anotherDate = today.addDays(todayWeekday == DateTime.sunday ? -1 : 1);
    await tester.tap(find.byKey(ValueKey('day-cell-$anotherDate')));
    await render(tester);

    expect(
      find.byKey(ValueKey('expanded-day-card-$anotherDate')),
      findsNothing,
    );
  });

  testWidgets('Android compact calendar supports its complete touch flow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    late ProviderContainer container;
    await settings.set(
      AppPreferenceKeys.androidCalendarCellExpansionEnabled,
      'true',
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container = ProviderContainer(
          overrides: [
            platformCapabilitiesProvider.overrideWithValue(
              const PlatformCapabilities(isAndroid: true, isWindows: false),
            ),
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

    expect(
      find.byKey(const ValueKey('compact-calendar-toolbar')),
      findsOneWidget,
    );
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(dayCells(), findsNWidgets(14));
    final before = container.read(calendarControllerProvider).anchorWeekStart;
    await tester.fling(
      find.byKey(const ValueKey('calendar-touch-surface')),
      const Offset(0, -180),
      1000,
    );
    await render(tester);
    expect(
      container.read(calendarControllerProvider).anchorWeekStart,
      before.addDays(7),
    );

    final longPressDate = container
        .read(calendarControllerProvider)
        .anchorWeekStart
        .addDays(1);
    await tester.longPress(find.byKey(ValueKey('day-cell-$longPressDate')));
    await tester.pumpAndSettle();
    expect(find.text('快速新增 TODO'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(ValueKey('day-cell-$longPressDate')));
    await render(tester);
    expect(
      container.read(calendarControllerProvider).selectedDate,
      longPressDate,
    );
    final focusCard = find.byKey(ValueKey('expanded-day-card-$longPressDate'));
    expect(focusCard, findsOneWidget);
    await tester.tap(focusCard);
    await render(tester);
    expect(focusCard, findsNothing);
    await tester.tap(find.byKey(ValueKey('day-cell-$longPressDate')));
    await render(tester);
    expect(focusCard, findsOneWidget);

    container
        .read(calendarControllerProvider.notifier)
        .goToDate(longPressDate.addDays(30));
    await render(tester);
    await tester.tap(find.byKey(const ValueKey('calendar-compact-today')));
    await render(tester);
    expect(
      container.read(calendarControllerProvider).selectedDate,
      LocalDate.fromDateTime(DateTime.now()),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Android long-press drags tasks from calendar and TODO pane', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(412, 915));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final today = LocalDate.fromDateTime(DateTime.now());
    final firstTarget = today.addDays(1);
    final secondTarget = today.addDays(2);
    final todo = TodoItem(
      id: 'touch-drag-todo',
      title: '长按拖动任务',
      localDate: today,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    final repository = _DragTodoRepository(todo);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          platformCapabilitiesProvider.overrideWithValue(
            const PlatformCapabilities(isAndroid: true, isWindows: false),
          ),
          settingsRepositoryProvider.overrideWithValue(settings),
          todoRepositoryProvider.overrideWithValue(repository),
          categoriesProvider.overrideWith(
            (ref) => Stream.value(const <Category>[]),
          ),
          tagsProvider.overrideWith((ref) => Stream.value(const <Tag>[])),
          holidayYearProvider.overrideWith((ref, year) async => null),
        ],
        child: const EchoDayApp(locale: Locale('zh')),
      ),
    );
    await render(tester);

    final calendarDrag = find.byKey(
      ValueKey('calendar-long-press-drag-${todo.id}'),
    );
    expect(calendarDrag, findsOneWidget);
    expect(
      find.byKey(ValueKey('todo-long-press-drag-${todo.id}')),
      findsOneWidget,
    );
    final firstTargetCell = find.byKey(ValueKey('day-cell-$firstTarget'));
    final firstGesture = await tester.startGesture(
      tester.getCenter(calendarDrag),
    );
    await tester.pump(const Duration(milliseconds: 400));
    await firstGesture.moveTo(tester.getCenter(firstTargetCell));
    await tester.pump();
    await firstGesture.up();
    await tester.pumpAndSettle();
    expect((await repository.getById(todo.id))?.localDate, firstTarget);

    await tester.tap(firstTargetCell);
    await render(tester);
    final sidebarDrag = find.byKey(ValueKey('todo-long-press-drag-${todo.id}'));
    final secondTargetCell = find.byKey(ValueKey('day-cell-$secondTarget'));
    final secondGesture = await tester.startGesture(
      tester.getCenter(sidebarDrag),
    );
    await tester.pump(const Duration(milliseconds: 400));
    await secondGesture.moveTo(tester.getCenter(secondTargetCell));
    await tester.pump();
    await secondGesture.up();
    await tester.pumpAndSettle();
    expect((await repository.getById(todo.id))?.localDate, secondTarget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await repository.dispose();
  });

  testWidgets('Android medium uses a collapsed rail and single calendar pane', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(700, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(app(isAndroid: true));
    await render(tester);

    final rail = tester.widget<NavigationRail>(
      find.byKey(const ValueKey('medium-navigation-rail')),
    );
    expect(rail.extended, isFalse);
    expect(
      find.byKey(const ValueKey('compact-bottom-navigation')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('android-calendar-pane')), findsNothing);
    expect(find.byKey(const ValueKey('android-todo-pane')), findsNothing);
    expect(find.byKey(const ValueKey('selected-day-sidebar')), findsNothing);
    expect(find.byKey(const ValueKey('calendar-motto')), findsNothing);
    expect(dayCells(), findsNWidgets(35));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Android expanded uses a rail and two-pane calendar workspace', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(app(isAndroid: true));
    await render(tester);

    final rail = tester.widget<NavigationRail>(
      find.byKey(const ValueKey('expanded-navigation-rail')),
    );
    expect(rail.extended, isFalse);
    expect(find.byKey(const ValueKey('selected-day-sidebar')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('calendar-sidebar-splitter')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('android-todo-pane')), findsNothing);
    expect(find.byKey(const ValueKey('calendar-motto')), findsNothing);
    expect(dayCells(), findsNWidgets(35));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Android landscape keeps two weeks beside the TODO pane', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 450));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(app(isAndroid: true));
    await render(tester);

    expect(
      find.byKey(const ValueKey('expanded-navigation-rail')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('selected-day-sidebar')), findsOneWidget);
    expect(dayCells(), findsNWidgets(14));
    expect(tester.takeException(), isNull);
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

  testWidgets('calendar header omits week count and zoom buttons', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app());
    await render(tester);

    expect(dayCells(), findsNWidgets(35));
    expect(find.byTooltip('显示更多周'), findsNothing);
    expect(find.byTooltip('显示更少周'), findsNothing);
    expect(find.text('5 周'), findsNothing);
    expect(find.byKey(const ValueKey('calendar-date-picker')), findsOneWidget);
    expect(find.text(defaultCalendarMotto), findsOneWidget);
    final defaultMotto = tester.widget<Text>(
      find.byKey(const ValueKey('calendar-motto')),
    );
    expect(defaultMotto.style?.fontSize, 14);
    expect(defaultMotto.style?.color, Colors.black);
    expect(defaultMotto.style?.fontWeight, FontWeight.w700);
    expect(
      tester.getCenter(find.byKey(const ValueKey('calendar-motto'))).dx,
      closeTo(
        tester.getCenter(find.byKey(const ValueKey('calendar-week-grid'))).dx,
        1,
      ),
    );
    await settings.set(
      AppPreferenceKeys.mottoStyle,
      '{"fontSize":18,"colorValue":4282664004,'
      '"bold":true,"italic":true,"underline":true}',
    );
    await render(tester);
    final styledMotto = tester.widget<Text>(
      find.byKey(const ValueKey('calendar-motto')),
    );
    expect(styledMotto.style?.fontSize, 18);
    expect(styledMotto.style?.fontWeight, FontWeight.w700);
    expect(styledMotto.style?.fontStyle, FontStyle.italic);
    expect(styledMotto.style?.decoration, TextDecoration.underline);

    await tester.tap(find.byKey(const ValueKey('calendar-motto')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('calendar-motto-field')),
      '直接在日历修改',
    );
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await render(tester);
    expect((await settings.get(AppPreferenceKeys.motto))?.value, '直接在日历修改');
    expect(find.text('直接在日历修改'), findsOneWidget);
  });

  testWidgets(
    'calendar preview joins planned and DDL times with distinct colors',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final today = LocalDate.fromDateTime(DateTime.now());
      final now = DateTime.now().toUtc();
      final item = TodoItem(
        id: 'deadline-preview',
        title: '提交材料',
        localDate: today,
        createdAt: now,
        updatedAt: now,
        plannedAt: DateTime(today.year, today.month, today.day, 9).toUtc(),
        deadlineAt: DateTime(
          today.year,
          today.month,
          today.day,
          19,
          25,
        ).toUtc(),
      );
      await settings.set(AppPreferenceKeys.calendarTodoFontSize, '16');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(settings),
            todosByDateProvider.overrideWith(
              (ref, date) => Stream.value(date == today ? [item] : const []),
            ),
            categoriesProvider.overrideWith(
              (ref) => Stream.value(const <Category>[]),
            ),
            tagsProvider.overrideWith((ref) => Stream.value(const <Tag>[])),
            holidayYearProvider.overrideWith((ref, year) async => null),
            currentTimeProvider.overrideWith(
              (ref) => Stream.value(DateTime.utc(2026, 9, 5, 10)),
            ),
          ],
          child: const EchoDayApp(locale: Locale('zh')),
        ),
      );
      await render(tester);

      final cell = find.byKey(ValueKey('day-cell-$today'));
      final time = find.descendant(
        of: cell,
        matching: find.byKey(
          const ValueKey('calendar-task-time-deadline-preview'),
        ),
      );
      expect(time, findsOneWidget);
      expect(
        find.descendant(
          of: cell,
          matching: find.text('09:00 - 19:25', findRichText: true),
        ),
        findsOneWidget,
      );
      final timeText = tester.widget<Text>(time);
      final spans = (timeText.textSpan! as TextSpan).children!;
      final titleText = tester.widget<Text>(
        find.descendant(of: cell, matching: find.text('提交材料')),
      );
      expect(titleText.style?.fontSize, 16);
      expect(spans[0].style?.color, const Color(0xFF7D8F7A));
      expect(spans[1].toPlainText(), ' - ');
      expect(spans[2].style?.color, isNot(const Color(0xFF7D8F7A)));
      expect(find.byType(Draggable<TodoDragPayload>), findsNWidgets(2));
      expect(find.byType(DragTarget<TodoDragPayload>), findsNWidgets(35));
    },
  );

  testWidgets(
    'Android stacks dual times at half the configured task font size',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(412, 915));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final today = LocalDate.fromDateTime(DateTime.now());
      final now = DateTime.now().toUtc();
      final item = TodoItem(
        id: 'android-stacked-time',
        title: '保留任务内容',
        localDate: today,
        createdAt: now,
        updatedAt: now,
        plannedAt: DateTime(today.year, today.month, today.day, 9).toUtc(),
        deadlineAt: DateTime(today.year, today.month, today.day, 18).toUtc(),
      );
      await settings.set(AppPreferenceKeys.calendarTodoFontSize, '5');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            platformCapabilitiesProvider.overrideWithValue(
              const PlatformCapabilities(isAndroid: true, isWindows: false),
            ),
            settingsRepositoryProvider.overrideWithValue(settings),
            todosByDateProvider.overrideWith(
              (ref, date) => Stream.value(date == today ? [item] : const []),
            ),
            categoriesProvider.overrideWith(
              (ref) => Stream.value(const <Category>[]),
            ),
            tagsProvider.overrideWith((ref) => Stream.value(const <Tag>[])),
            holidayYearProvider.overrideWith((ref, year) async => null),
          ],
          child: const EchoDayApp(locale: Locale('zh')),
        ),
      );
      await render(tester);

      final cell = find.byKey(ValueKey('day-cell-$today'));
      final timeColumn = find.descendant(
        of: cell,
        matching: find.byKey(
          const ValueKey('calendar-task-time-android-stacked-time'),
        ),
      );
      final planned = tester.widget<Text>(
        find.descendant(
          of: cell,
          matching: find.byKey(
            const ValueKey('calendar-task-planned-time-android-stacked-time'),
          ),
        ),
      );
      final deadline = tester.widget<Text>(
        find.descendant(
          of: cell,
          matching: find.byKey(
            const ValueKey('calendar-task-deadline-time-android-stacked-time'),
          ),
        ),
      );
      final title = tester.widget<Text>(
        find.descendant(of: cell, matching: find.text('保留任务内容')),
      );
      expect(timeColumn, findsOneWidget);
      expect(planned.style?.fontSize, 2.5);
      expect(deadline.style?.fontSize, 2.5);
      expect(title.style?.fontSize, 5);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('overdue calendar preview uses the error color', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final today = LocalDate.fromDateTime(DateTime.now());
    final item = TodoItem(
      id: 'overdue-preview',
      title: '完成EchoDay开发',
      localDate: today,
      createdAt: DateTime.utc(today.year, today.month, today.day, 8),
      updatedAt: DateTime.utc(today.year, today.month, today.day, 8),
      plannedAt: DateTime.utc(today.year, today.month, today.day, 9),
      deadlineAt: DateTime.utc(today.year, today.month, today.day, 19, 25),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settings),
          todosByDateProvider.overrideWith(
            (ref, date) => Stream.value(date == today ? [item] : const []),
          ),
          categoriesProvider.overrideWith(
            (ref) => Stream.value(const <Category>[]),
          ),
          tagsProvider.overrideWith((ref) => Stream.value(const <Tag>[])),
          holidayYearProvider.overrideWith((ref, year) async => null),
          currentTimeProvider.overrideWith(
            (ref) => Stream.value(
              DateTime.utc(today.year, today.month, today.day, 20),
            ),
          ),
        ],
        child: const EchoDayApp(locale: Locale('zh')),
      ),
    );
    await render(tester);

    final task = find.byKey(const ValueKey('calendar-task-overdue-preview'));
    expect(task, findsOneWidget);
    final errorColor = Theme.of(tester.element(task)).colorScheme.error;
    final title = tester.widget<Text>(
      find.descendant(of: task, matching: find.text('完成EchoDay开发')),
    );
    final statusIcon = tester.widget<Icon>(
      find.descendant(of: task, matching: find.byIcon(Icons.circle_outlined)),
    );
    final time = tester.widget<Text>(
      find.descendant(
        of: task,
        matching: find.byKey(
          const ValueKey('calendar-task-time-overdue-preview'),
        ),
      ),
    );
    final timeSpans = (time.textSpan! as TextSpan).children!;
    expect(title.style?.color, errorColor);
    expect(statusIcon.color, errorColor);
    expect(
      timeSpans,
      everyElement(
        predicate<TextSpan>((span) {
          return span.style?.color == errorColor;
        }),
      ),
    );
  });

  testWidgets('drags tasks from calendar cells and sidebar to another date', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final today = LocalDate.fromDateTime(DateTime.now());
    final firstTarget = today.addDays(1);
    final secondTarget = today.addDays(2);
    final todo = TodoItem(
      id: 'drag-todo',
      title: '拖动任务',
      localDate: today,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
      plannedAt: DateTime(today.year, today.month, today.day, 9, 15).toUtc(),
      deadlineAt: DateTime(today.year, today.month, today.day, 19, 25).toUtc(),
    );
    final repository = _DragTodoRepository(todo);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settings),
          todoRepositoryProvider.overrideWithValue(repository),
          categoriesProvider.overrideWith(
            (ref) => Stream.value(const <Category>[]),
          ),
          tagsProvider.overrideWith((ref) => Stream.value(const <Tag>[])),
          holidayYearProvider.overrideWith((ref, year) async => null),
        ],
        child: const EchoDayApp(locale: Locale('zh')),
      ),
    );
    await render(tester);

    final calendarTask = find.byKey(ValueKey('calendar-task-${todo.id}'));
    final firstTargetCell = find.byKey(ValueKey('day-cell-$firstTarget'));
    await tester.drag(
      calendarTask,
      tester.getCenter(firstTargetCell) - tester.getCenter(calendarTask),
    );
    await tester.pumpAndSettle();
    var moved = await repository.getById(todo.id);
    expect(moved?.localDate, firstTarget);
    expect(moved?.plannedAt?.toLocal().hour, 9);
    expect(moved?.deadlineAt?.toLocal().hour, 19);

    await tester.tap(firstTargetCell);
    await render(tester);
    final sidebarTask = find.byKey(ValueKey('todo-${todo.id}'));
    final secondTargetCell = find.byKey(ValueKey('day-cell-$secondTarget'));
    await tester.drag(
      sidebarTask,
      tester.getCenter(secondTargetCell) - tester.getCenter(sidebarTask),
    );
    await tester.pumpAndSettle();
    moved = await repository.getById(todo.id);
    expect(moved?.localDate, secondTarget);
    expect(moved?.plannedAt?.toLocal().minute, 15);
    expect(moved?.deadlineAt?.toLocal().minute, 25);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await repository.dispose();
  });

  testWidgets(
    'December watermark stays on one line with the bundled Kai font',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 720));
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
      final target = LocalDate(DateTime.now().year, 12, 1);
      final controller = container.read(calendarControllerProvider.notifier);
      controller.selectDate(target);
      controller.ensureSelectedVisible();
      await render(tester);

      final watermark = find.byKey(ValueKey('month-watermark-$target'));
      final text = tester.widget<Text>(watermark);
      expect(text.data, '十二');
      expect(text.maxLines, 1);
      expect(text.softWrap, isFalse);
      expect(text.style?.fontFamily, 'EchoDayMonthKai');
      expect(text.style?.color, const Color(0x99767171));
      expect(
        find.ancestor(of: watermark, matching: find.byType(FittedBox)),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('English uses abbreviated month watermarks and TODO dates', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 720));
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
        child: const EchoDayApp(locale: Locale('en')),
      ),
    );
    addTearDown(container.dispose);
    await render(tester);
    final target = LocalDate(2026, 1, 1);
    container.read(calendarControllerProvider.notifier).goToDate(target);
    await render(tester);

    final watermark = find.byKey(ValueKey('month-watermark-$target'));
    final watermarkText = tester.widget<Text>(watermark);
    expect(watermarkText.data, 'Jan.');
    expect(watermarkText.style?.fontFamily, 'EchoDaySans');

    final cell = find.byKey(ValueKey('day-cell-$target'));
    await tester.tap(cell);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(cell);
    await render(tester);
    final expectedTitle = DateFormat.yMMMEd('en')
        .format(DateTime(target.year, target.month, target.day));
    expect(find.text(expectedTitle), findsOneWidget);
    expect(expectedTitle, isNot(contains('January')));
    expect(expectedTitle, isNot(contains('Thursday')));
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
      final today = LocalDate.fromDateTime(DateTime.now());
      final target = container
          .read(calendarControllerProvider)
          .visibleDates
          .firstWhere((date) => date != today);
      final finder = find.byKey(ValueKey('day-cell-$target'));

      await tester.tap(finder);
      await tester.pump(const Duration(milliseconds: 400));
      expect(container.read(calendarControllerProvider).selectedDate, target);
      expect(
        find.text(
          '${target.month.toString().padLeft(2, '0')}/'
          '${target.day.toString().padLeft(2, '0')}',
        ),
        findsOneWidget,
      );
      final monthTitle = tester.widget<Text>(
        find.byKey(const ValueKey('calendar-month-title')),
      );
      expect(monthTitle.data, contains('${target.month}'));

      await tester.tap(finder);
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tap(finder);
      await render(tester);
      expect(find.byTooltip('返回月历'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('day-todo-font-size-menu')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('day-todo-font-size-menu')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(CheckedPopupMenuItem<double>, '20 px'),
      );
      await render(tester);
      expect(
        (await settings.get(AppPreferenceKeys.dayTodoFontSize))?.value,
        '20.0',
      );

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

final class _DragTodoRepository implements TodoRepository {
  _DragTodoRepository(this._todo);

  TodoItem _todo;
  final _changes = StreamController<void>.broadcast(sync: true);

  List<TodoItem> _itemsFor(LocalDate date) =>
      _todo.localDate == date ? [_todo] : const [];

  Future<void> dispose() => _changes.close();

  @override
  Stream<List<TodoItem>> watchByDate(LocalDate date) async* {
    yield _itemsFor(date);
    yield* _changes.stream.map((_) => _itemsFor(date));
  }

  @override
  Future<List<TodoItem>> getByDate(LocalDate date) async => _itemsFor(date);

  @override
  Future<TodoItem?> getById(String id, {bool includeDeleted = false}) async =>
      id == _todo.id ? _todo : null;

  @override
  Future<TodoItem> save(TodoItem todo) async {
    _todo = todo;
    _changes.add(null);
    return todo;
  }

  @override
  Future<TodoItem> create(TodoDraft draft) => throw UnimplementedError();

  @override
  Future<void> complete(String id, {DateTime? at}) =>
      throw UnimplementedError();

  @override
  Future<void> restore(String id) => throw UnimplementedError();

  @override
  Future<void> softDelete(String id, {DateTime? at}) =>
      throw UnimplementedError();

  @override
  Future<void> undoDelete(String id) => throw UnimplementedError();

  @override
  Future<void> reorder(LocalDate date, List<String> orderedIds) =>
      throw UnimplementedError();

  @override
  Future<TodoSearchPage> search(TodoSearchQuery query) =>
      throw UnimplementedError();
}
