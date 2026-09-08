import 'dart:io';

import 'package:drift/native.dart';
import 'package:echoday/src/app/echoday_app.dart';
import 'package:echoday/src/app/platform/platform_capabilities.dart';
import 'package:echoday/src/app/providers/data_providers.dart';
import 'package:echoday/src/data/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android compact core flow survives input, completion and back', (
    tester,
  ) async {
    if (!Platform.isAndroid) return;
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          platformCapabilitiesProvider.overrideWithValue(
            const PlatformCapabilities(isAndroid: true, isWindows: false),
          ),
        ],
        child: const EchoDayApp(locale: Locale('zh')),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('compact-bottom-navigation')),
      findsOneWidget,
    );
    expect(find.byType(AppBar), findsNothing);
    expect(find.byKey(const ValueKey('android-calendar-pane')), findsOneWidget);
    expect(find.byKey(const ValueKey('android-todo-pane')), findsOneWidget);

    await tester.tap(find.byTooltip('新增').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('todo-editor-mobile')), findsOneWidget);
    final title = find.byKey(const ValueKey('todo-editor-title'));
    await tester.tap(title);
    await tester.enterText(title, 'A6 中文输入与重启验证');
    await tester.ensureVisible(find.byKey(const ValueKey('todo-editor-save')));
    await tester.tap(find.byKey(const ValueKey('todo-editor-save')));
    await tester.pumpAndSettle();

    final rows = await database.select(database.todos).get();
    expect(rows, hasLength(1));
    expect(rows.single.title, 'A6 中文输入与重启验证');
    final todo = find.byKey(ValueKey('todo-${rows.single.id}'));
    expect(todo, findsOneWidget);
    await tester.tap(
      find.descendant(of: todo, matching: find.byType(Checkbox)),
    );
    await tester.pumpAndSettle();
    expect(
      (await database.select(database.todos).get()).single.isCompleted,
      isTrue,
    );

    await tester.tap(find.text('设置').last);
    await tester.pumpAndSettle();
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byKey(const ValueKey('language-settings')), findsOneWidget);
    expect(find.byKey(const ValueKey('hotkey-settings')), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('android-calendar-pane')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
