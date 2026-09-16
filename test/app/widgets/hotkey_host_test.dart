import 'package:echoday/src/app/echoday_app.dart';
import 'package:echoday/src/app/platform/platform_capabilities.dart';
import 'package:echoday/src/app/platform/windows_desktop_runtime.dart';
import 'package:echoday/src/app/providers/data_providers.dart';
import 'package:echoday/src/app/widgets/hotkey_host.dart';
import 'package:echoday/src/features/calendar/application/calendar_controller.dart';
import 'package:echoday/src/features/settings/application/hotkey_preferences.dart';
import 'package:echoday/src/features/todos/application/todo_providers.dart';
import 'package:echoday/src/features/todos/domain/category.dart';
import 'package:echoday/src/features/todos/domain/local_date.dart';
import 'package:echoday/src/features/todos/domain/tag.dart';
import 'package:echoday/src/features/todos/domain/todo_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../../support/in_memory_settings_repository.dart';

void main() {
  testWidgets('Android never invokes the Windows desktop runtime', (
    tester,
  ) async {
    final runtime = _RecordingDesktopRuntime();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          platformCapabilitiesProvider.overrideWithValue(
            const PlatformCapabilities(isAndroid: true, isWindows: false),
          ),
          desktopRuntimeProvider.overrideWithValue(runtime),
        ],
        child: const MaterialApp(
          home: HotkeyHost(child: Text('Android content')),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Android content'), findsOneWidget);
    expect(runtime.callCount, 0);
  });

  testWidgets('Ctrl+1 opens the selected-date editor from settings', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final runtime = _RecordingDesktopRuntime();
    final settings = InMemorySettingsRepository();
    late ProviderContainer container;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container = ProviderContainer(
          overrides: [
            platformCapabilitiesProvider.overrideWithValue(
              const PlatformCapabilities(isAndroid: false, isWindows: true),
            ),
            desktopRuntimeProvider.overrideWithValue(runtime),
            settingsRepositoryProvider.overrideWithValue(settings),
            todosByDateProvider.overrideWith(
              (ref, date) => Stream.value(const <TodoItem>[]),
            ),
            categoriesProvider.overrideWith(
              (ref) => Stream.value(const <Category>[]),
            ),
            tagsProvider.overrideWith((ref) => Stream.value(const <Tag>[])),
          ],
        ),
        child: const EchoDayApp(locale: Locale('zh')),
      ),
    );
    addTearDown(container.dispose);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    final selectedDate = container
        .read(calendarControllerProvider)
        .selectedDate;
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('calendar-week-grid')), findsNothing);

    runtime.press('echoday-add-todo');
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('calendar-week-grid')), findsOneWidget);
    expect(find.byKey(const ValueKey('todo-editor-desktop')), findsOneWidget);
    expect(
      container.read(calendarControllerProvider).selectedDate,
      selectedDate,
    );
    expect(container.read(addTodoHotkeyRequestProvider), isNull);

    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();
    container
        .read(calendarControllerProvider.notifier)
        .goToDate(selectedDate.addDays(7));
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    runtime.press('echoday-today');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('calendar-week-grid')), findsOneWidget);
    expect(
      container.read(calendarControllerProvider).selectedDate,
      LocalDate.fromDateTime(DateTime.now()),
    );
  });
}

final class _RecordingDesktopRuntime implements DesktopRuntime {
  int callCount = 0;
  final Map<String, void Function()> handlers = {};

  void press(String identifier) => handlers[identifier]!();

  @override
  Future<void> initialize() async => callCount++;

  @override
  Future<void> registerHotkey(HotKey hotkey, void Function() onPressed) async {
    callCount++;
    handlers[hotkey.identifier] = onPressed;
  }

  @override
  Future<void> toggleWindowVisibility() async => callCount++;

  @override
  Future<void> unregisterHotkey(HotKey hotkey) async => callCount++;
}
