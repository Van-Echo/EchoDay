import 'package:echoday/src/app/echoday_app.dart';
import 'package:echoday/src/app/providers/data_providers.dart';
import 'package:echoday/src/features/calendar/application/calendar_controller.dart';
import 'package:echoday/src/features/settings/application/app_preferences.dart';
import 'package:echoday/src/features/todos/application/todo_providers.dart';
import 'package:echoday/src/features/todos/domain/category.dart';
import 'package:echoday/src/features/todos/domain/local_date.dart';
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
    expect(
      tester.getCenter(find.byKey(const ValueKey('calendar-motto'))).dx,
      closeTo(
        tester.getCenter(find.byKey(const ValueKey('calendar-week-grid'))).dx,
        1,
      ),
    );

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
      expect(spans[0].style?.color, const Color(0xFF7D8F7A));
      expect(spans[1].toPlainText(), ' - ');
      expect(spans[2].style?.color, isNot(const Color(0xFF7D8F7A)));
    },
  );

  testWidgets('overdue calendar preview uses the error color', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final today = LocalDate(2026, 9, 5);
    final item = TodoItem(
      id: 'overdue-preview',
      title: '完成EchoDay开发',
      localDate: today,
      createdAt: DateTime.utc(2026, 9, 5, 8),
      updatedAt: DateTime.utc(2026, 9, 5, 8),
      plannedAt: DateTime.utc(2026, 9, 5, 9),
      deadlineAt: DateTime.utc(2026, 9, 5, 19, 25),
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
            (ref) => Stream.value(DateTime.utc(2026, 9, 5, 20)),
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
