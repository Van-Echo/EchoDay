import 'package:echoday/src/app/echoday_app.dart';
import 'package:echoday/src/app/providers/data_providers.dart';
import 'package:echoday/src/features/todos/application/todo_providers.dart';
import 'package:echoday/src/features/todos/domain/category.dart';
import 'package:echoday/src/features/todos/domain/tag.dart';
import 'package:echoday/src/features/todos/domain/todo_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/in_memory_settings_repository.dart';

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
      holidayAvailableYearsProvider.overrideWith((ref) async => const {}),
    ],
    child: const EchoDayApp(locale: Locale('zh')),
  );

  Future<void> render(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('starts on the localized calendar shell', (tester) async {
    await tester.pumpWidget(app());
    await render(tester);

    expect(find.text('丸成'), findsOneWidget);
    expect(find.text('月历工作台'), findsWidgets);
    expect(find.byKey(const ValueKey('calendar-week-grid')), findsOneWidget);
  });

  testWidgets('navigates to settings and changes the theme', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(app());
    await render(tester);

    await tester.tap(find.text('设置').first);
    await render(tester);
    expect(find.text('主题模式'), findsOneWidget);

    await tester.tap(find.text('深色'));
    await render(tester);

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);
  });

  testWidgets('opens every M0 destination', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(app());
    await render(tester);

    await tester.tap(find.byIcon(Icons.checklist_outlined));
    await render(tester);
    expect(find.byTooltip('返回月历'), findsOneWidget);

    await tester.tap(find.byTooltip('返回月历'));
    await render(tester);

    await tester.tap(find.byIcon(Icons.search_outlined));
    await render(tester);
    expect(find.byKey(const ValueKey('global-search-field')), findsOneWidget);

    await tester.tap(find.byIcon(Icons.info_outline_rounded));
    await render(tester);
    expect(find.textContaining('丸一口 / Van Echo'), findsOneWidget);
  });
}
