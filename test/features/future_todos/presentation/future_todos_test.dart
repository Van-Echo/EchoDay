import 'package:drift/native.dart';
import 'package:echoday/src/app/echoday_app.dart';
import 'package:echoday/src/app/platform/platform_capabilities.dart';
import 'package:echoday/src/app/platform/window_visibility.dart';
import 'package:echoday/src/app/providers/data_providers.dart';
import 'package:echoday/src/app/router/app_router.dart';
import 'package:echoday/src/app/router/app_routes.dart';
import 'package:echoday/src/data/database/app_database.dart';
import 'package:echoday/src/features/settings/application/app_preferences.dart';
import 'package:echoday/src/features/todos/application/todo_providers.dart';
import 'package:echoday/src/features/todos/data/local_todo_repository.dart';
import 'package:echoday/src/features/todos/domain/category.dart';
import 'package:echoday/src/features/todos/domain/local_date.dart';
import 'package:echoday/src/features/todos/domain/tag.dart';
import 'package:echoday/src/features/todos/domain/todo_item.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/in_memory_settings_repository.dart';

void main() {
  late AppDatabase database;
  late LocalTodoRepository repository;
  late ProviderContainer container;
  late _VisibilityProbe visibility;
  late InMemorySettingsRepository settings;
  final today = LocalDate.fromDateTime(DateTime.now());

  Future<void> render(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 650));
    await tester.pump();
  }

  Future<void> open(WidgetTester tester, {required bool android}) async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LocalTodoRepository(database);
    visibility = _VisibilityProbe();
    settings = InMemorySettingsRepository();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        todoRepositoryProvider.overrideWithValue(repository),
        windowVisibilityProbeProvider.overrideWithValue(visibility),
        settingsRepositoryProvider.overrideWithValue(settings),
        platformCapabilitiesProvider.overrideWithValue(
          PlatformCapabilities(isAndroid: android, isWindows: !android),
        ),
        categoriesProvider.overrideWith(
          (ref) => Stream.value(const <Category>[]),
        ),
        tagsProvider.overrideWith((ref) => Stream.value(const <Tag>[])),
        holidayYearProvider.overrideWith((ref, year) async => null),
      ],
    );
    await tester.binding.setSurfaceSize(
      android ? const Size(360, 800) : const Size(1280, 800),
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const EchoDayApp(locale: Locale('zh')),
      ),
    );
    await render(tester);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      container.dispose();
      await settings.dispose();
      await database.close();
      await tester.binding.setSurfaceSize(null);
    });
  }

  for (final android in [false, true]) {
    final platform = android ? 'Android' : 'Windows';
    testWidgets('$platform can create a future task and move it to today', (
      tester,
    ) async {
      await open(tester, android: android);
      final navigation = find.byType(android ? NavigationBar : NavigationRail);
      await tester.tap(
        find.descendant(
          of: navigation,
          matching: find.byIcon(Icons.upcoming_outlined),
        ),
      );
      await render(tester);
      expect(find.byKey(const ValueKey('add-future-todo')), findsNothing);
      final add = find.byKey(const ValueKey('future-todo-header-add'));
      final filter = find.byKey(const ValueKey('todo-filter-button'));
      expect(tester.widget(add), isA<IconButton>());
      expect(tester.getCenter(add).dy, tester.getCenter(filter).dy);
      expect(tester.getCenter(add).dx, lessThan(tester.getCenter(filter).dx));
      await tester.tap(add);
      await render(tester);
      await tester.enterText(
        find.byKey(const ValueKey('todo-editor-title')),
        'Read a book someday',
      );
      expect(find.text('暂未安排日期'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('todo-editor-save')));
      await render(tester);
      final todo = (await repository.getFuture()).single;
      if (android) {
        expect(find.byKey(const ValueKey('future-todo-ticker')), findsNothing);
      }
      expect(await repository.getByDate(today), isEmpty);
      final tile = find.byKey(ValueKey('todo-${todo.id}'));
      if (android) {
        await tester.longPress(tile);
      } else {
        await tester.tap(tile, buttons: kSecondaryMouseButton);
      }
      await render(tester);
      await tester.ensureVisible(find.text('转移到当日TODO'));
      await tester.tap(find.text('转移到当日TODO'));
      await render(tester);
      expect(await repository.getFuture(), isEmpty);
      expect((await repository.getByDate(today)).single.id, todo.id);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      '$platform calendar and day list expose copy and future transfers',
      (tester) async {
        await open(tester, android: android);
        final todo = await repository.create(
          TodoDraft(title: 'Make progress today', localDate: today),
        );
        await render(tester);
        final preview = find.byKey(ValueKey('calendar-task-${todo.id}'));
        expect(preview, findsOneWidget);
        await tester.tap(
          preview,
          buttons: android ? kPrimaryMouseButton : kSecondaryMouseButton,
        );
        await render(tester);
        await tester.tap(find.text('复制到下一天'));
        await render(tester);
        expect((await repository.getByDate(today)).single.id, todo.id);
        final copy = (await repository.getByDate(today.addDays(1))).single;
        expect(copy.id, isNot(todo.id));

        container
            .read(appRouterProvider)
            .go(AppRoutes.dayTodosForLocalDate(today));
        await render(tester);
        final tile = find.byKey(ValueKey('todo-${todo.id}'));
        if (android) {
          await tester.longPress(tile);
        } else {
          await tester.tap(tile, buttons: kSecondaryMouseButton);
        }
        await render(tester);
        await tester.ensureVisible(find.text('移动到未来TODO'));
        await tester.tap(find.text('移动到未来TODO'));
        await render(tester);
        expect(await repository.getByDate(today), isEmpty);
        expect((await repository.getFuture()).single.id, todo.id);
        container.read(appRouterProvider).go(AppRoutes.calendar);
        await render(tester);
        expect(
          find.byKey(const ValueKey('future-todo-ticker')),
          android ? findsNothing : findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('calendar ticker loops only open future tasks below the motto', (
    tester,
  ) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await open(tester, android: false);
    final first = await repository.create(
      TodoDraft(title: 'First idea', localDate: today, isFuture: true),
    );
    await repository.create(
      TodoDraft(title: 'Second idea', localDate: today, isFuture: true),
    );
    final completed = await repository.create(
      TodoDraft(title: 'Finished idea', localDate: today, isFuture: true),
    );
    await repository.complete(completed.id);
    await render(tester);
    final ticker = find.byKey(const ValueKey('future-todo-ticker'));
    expect(ticker, findsOneWidget);
    expect(
      tester.getTopLeft(ticker).dy,
      greaterThan(
        tester.getBottomLeft(find.byKey(const ValueKey('calendar-motto'))).dy,
      ),
    );
    final pages = tester.widget<PageView>(
      find.byKey(const ValueKey('future-todo-ticker-pages')),
    );
    expect(pages.controller!.page, 0);
    expect(
      tester.widget<Text>(find.text('First idea')).textAlign,
      TextAlign.center,
    );
    expect(
      tester.getCenter(find.text('First idea')).dx,
      closeTo(tester.getCenter(ticker).dx, 1),
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(pages.controller!.page, 1);
    expect(find.text('Finished idea'), findsNothing);
    visibility.visible = false;
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(pages.controller!.page, 1);
    visibility.visible = true;
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(pages.controller!.page, 2);
    expect(
      find.byKey(ValueKey('future-ticker-task-${first.id}')),
      findsOneWidget,
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });

  testWidgets(
    'ticker interval changes restart the timer without resetting the item',
    (tester) async {
      await open(tester, android: false);
      await settings.set(
        AppPreferenceKeys.futureTodoTickerIntervalSeconds,
        '10',
      );
      await repository.create(
        TodoDraft(title: 'First', localDate: today, isFuture: true),
      );
      await repository.create(
        TodoDraft(title: 'Second', localDate: today, isFuture: true),
      );
      await render(tester);
      final pages = tester.widget<PageView>(
        find.byKey(const ValueKey('future-todo-ticker-pages')),
      );
      await tester.pump(const Duration(seconds: 4));
      expect(pages.controller!.page, 0);
      await tester.pump(const Duration(seconds: 6));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(pages.controller!.page, 1);
      await settings.set(
        AppPreferenceKeys.futureTodoTickerIntervalSeconds,
        '20',
      );
      await render(tester);
      await tester.pump(const Duration(seconds: 8));
      expect(pages.controller!.page, 1);
      await tester.pump(const Duration(seconds: 12));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(pages.controller!.page, 2);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'ticker numbering is optional and restarts at one after looping',
    (tester) async {
      await open(tester, android: false);
      await settings.set(
        AppPreferenceKeys.futureTodoTickerIntervalSeconds,
        '3600',
      );
      await repository.create(
        TodoDraft(title: 'First', localDate: today, isFuture: true),
      );
      await repository.create(
        TodoDraft(title: 'Second', localDate: today, isFuture: true),
      );
      await render(tester);
      expect(find.text('First'), findsOneWidget);
      await settings.set(AppPreferenceKeys.futureTodoTickerNumbered, 'true');
      await render(tester);
      expect(find.text('1. First'), findsOneWidget);
      final pages = tester.widget<PageView>(
        find.byKey(const ValueKey('future-todo-ticker-pages')),
      );
      pages.controller!.jumpToPage(1);
      await render(tester);
      expect(find.text('2. Second'), findsOneWidget);
      pages.controller!.jumpToPage(2);
      await render(tester);
      expect(find.text('1. First'), findsOneWidget);
      await settings.set(AppPreferenceKeys.futureTodoTickerNumbered, 'false');
      await render(tester);
      expect(find.text('First'), findsOneWidget);
      expect(find.text('1. First'), findsNothing);
      expect(pages.controller!.page, 2);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Windows settings validate and persist ticker preferences', (
    tester,
  ) async {
    await open(tester, android: false);
    container.read(appRouterProvider).go(AppRoutes.settings);
    await render(tester);
    final card = find.byKey(const ValueKey('ticker-settings'));
    await tester.scrollUntilVisible(
      card,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(card);
    await render(tester);
    final field = find.byKey(const ValueKey('ticker-interval-seconds'));
    await tester.ensureVisible(field);
    await tester.enterText(field, '0');
    await tester.tap(find.byKey(const ValueKey('ticker-interval-save')));
    await render(tester);
    expect(find.text('请输入 1～3600 之间的整数'), findsOneWidget);
    expect(
      await settings.get(AppPreferenceKeys.futureTodoTickerIntervalSeconds),
      isNull,
    );
    await tester.enterText(field, '6');
    await tester.tap(find.byKey(const ValueKey('ticker-interval-save')));
    await render(tester);
    expect(
      (await settings.get(AppPreferenceKeys.futureTodoTickerIntervalSeconds))
          ?.value,
      '6',
    );
    final numbering = find.byKey(const ValueKey('ticker-numbered-toggle'));
    await tester.ensureVisible(numbering);
    await tester.tap(numbering);
    await render(tester);
    expect(
      (await settings.get(AppPreferenceKeys.futureTodoTickerNumbered))?.value,
      'true',
    );
    expect(tester.takeException(), isNull);
  });
}

final class _VisibilityProbe implements WindowVisibilityProbe {
  bool visible = true;

  @override
  Future<bool> hasVisibleArea() async => visible;
}
