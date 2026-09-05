import 'package:echoday/src/app/echoday_app.dart';
import 'package:echoday/src/app/providers/data_providers.dart';
import 'package:echoday/src/app/widgets/app_scaffold.dart';
import 'package:echoday/src/features/settings/application/app_preferences.dart';
import 'package:echoday/src/features/settings/application/hotkey_preferences.dart';
import 'package:echoday/src/features/todos/application/todo_providers.dart';
import 'package:echoday/src/features/todos/domain/category.dart';
import 'package:echoday/src/features/todos/domain/tag.dart';
import 'package:echoday/src/features/todos/domain/todo_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

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
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme?.textTheme.bodyMedium?.fontFamily, 'EchoDaySans');
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.byIcon(Icons.tune_outlined), findsNothing);
  });

  testWidgets('navigates to settings and changes the theme', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(app());
    await render(tester);

    await tester.tap(find.text('设置').first);
    await render(tester);
    expect(find.text('主题模式'), findsOneWidget);
    expect(find.text('深色'), findsNothing);

    await tester.tap(find.text('主题模式'));
    await render(tester);
    await tester.tap(find.text('深色'));
    await render(tester);

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);
  });

  testWidgets('restores theme mode and primary color from local settings', (
    tester,
  ) async {
    await settings.set(AppPreferenceKeys.themeMode, ThemeMode.dark.name);
    await settings.set(AppPreferenceKeys.primaryColor, '${0xFF667E8C}');

    await tester.pumpWidget(app());
    await render(tester);

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);
    expect(materialApp.theme?.colorScheme.primary, const Color(0xFF667E8C));
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
    expect(find.text('丸成 | EchoDay'), findsOneWidget);
    expect(find.byKey(const ValueKey('about-brand-logo')), findsOneWidget);
    expect(find.byKey(const ValueKey('about-maru-logo')), findsOneWidget);
    expect(find.byKey(const ValueKey('about-cheng-logo')), findsOneWidget);
    expect(find.text('由 丸一口 / Van Echo 使用 ChatGPT 5.6 Sol 创作'), findsOneWidget);
    expect(find.byType(FaIcon), findsNWidgets(2));
    expect(find.text('GNU Affero General Public License v3.0'), findsOneWidget);
    expect(find.text('个人、企业及商业使用均被允许'), findsOneWidget);
    expect(find.textContaining('计算机软件著作权登记号'), findsNothing);
    expect(find.text('v0.1.0 | 2026/9/5'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('about-license-link')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('community-license-dialog')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('community-license-dialog-title')),
      findsOneWidget,
    );
    expect(
      find.textContaining('source code of the modified version'),
      findsOneWidget,
    );
    await tester.tap(find.text('关闭'));
    await tester.pumpAndSettle();
    final aboutCenter = tester.getCenter(
      find.byKey(const ValueKey('about-main-content')),
    );
    final contentCenter = tester.getCenter(
      find.byKey(const ValueKey('about-content-area')),
    );
    expect(aboutCenter.dx, closeTo(contentCenter.dx, 1));
    expect(aboutCenter.dy, closeTo(contentCenter.dy, 1));
  });

  testWidgets('switches the navigation rail between its two persisted widths', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app());
    await render(tester);

    final rail = find.byType(NavigationRail);
    final expandedWidth = tester.getSize(rail).width;
    await tester.tap(
      find.byKey(const ValueKey('navigation-rail-width-toggle')),
    );
    await render(tester);

    expect(tester.getSize(rail).width, lessThan(expandedWidth));
    expect(expandedWidth, lessThanOrEqualTo(196));
    expect(
      (await settings.get(AppScaffoldSettingKeys.navigationRailExtended))
          ?.value,
      'false',
    );
    expect(find.byTooltip('显示导航文字'), findsOneWidget);
  });

  testWidgets('persists the calendar motto and exposes hotkey settings', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app());
    await render(tester);

    await tester.tap(find.text('设置').first);
    await render(tester);
    await tester.tap(find.text('碎碎念~'));
    await render(tester);
    expect(
      tester.getSize(find.byKey(const ValueKey('motto-field'))).height,
      greaterThanOrEqualTo(88),
    );
    await tester.enterText(
      find.byKey(const ValueKey('motto-field')),
      '今天也要完成计划',
    );
    await tester.tap(find.widgetWithText(FilledButton, '保存').last);
    await render(tester);
    expect((await settings.get(AppPreferenceKeys.motto))?.value, '今天也要完成计划');

    await tester.tap(find.text('键位'));
    await render(tester);
    expect(find.text('全局呼出「丸成」'), findsOneWidget);
    expect(find.text('打开全局搜索'), findsNothing);
    expect(find.text('回到「今天」'), findsOneWidget);
    final summon = defaultHotkey(AppHotkeyAction.summon);
    expect(summon.key, PhysicalKeyboardKey.keyQ);
    expect(summon.modifiers, [HotKeyModifier.control]);
    expect(summon.scope, HotKeyScope.system);

    await tester.tap(find.byIcon(Icons.calendar_month_outlined).first);
    await render(tester);
    expect(find.text('今天也要完成计划'), findsOneWidget);
  });
}
