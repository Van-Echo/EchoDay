import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../../../app/providers/data_providers.dart';
import '../../todos/domain/local_date.dart';

enum AppHotkeyAction { summon, today, addTodo }

String hotkeySettingKey(AppHotkeyAction action) => 'hotkeys.${action.name}';

HotKey defaultHotkey(AppHotkeyAction action) => switch (action) {
  AppHotkeyAction.summon => HotKey(
    identifier: 'echoday-summon',
    key: PhysicalKeyboardKey.keyQ,
    modifiers: [HotKeyModifier.control],
    scope: HotKeyScope.system,
  ),
  AppHotkeyAction.today => HotKey(
    identifier: 'echoday-today',
    key: PhysicalKeyboardKey.keyT,
    modifiers: [HotKeyModifier.control],
    scope: HotKeyScope.inapp,
  ),
  AppHotkeyAction.addTodo => HotKey(
    identifier: 'echoday-add-todo',
    key: PhysicalKeyboardKey.digit1,
    modifiers: [HotKeyModifier.control],
    scope: HotKeyScope.inapp,
  ),
};

final class AddTodoHotkeyRequest {
  const AddTodoHotkeyRequest(this.revision, this.date);

  final int revision;
  final LocalDate date;
}

final addTodoHotkeyRequestProvider =
    NotifierProvider<AddTodoHotkeyRequestController, AddTodoHotkeyRequest?>(
      AddTodoHotkeyRequestController.new,
    );

final class AddTodoHotkeyRequestController
    extends Notifier<AddTodoHotkeyRequest?> {
  var _revision = 0;

  @override
  AddTodoHotkeyRequest? build() => null;

  void request(LocalDate date) {
    state = AddTodoHotkeyRequest(++_revision, date);
  }

  void consume(int revision) {
    if (state?.revision == revision) state = null;
  }
}

final hotkeyPreferenceProvider = StreamProvider.family<HotKey, AppHotkeyAction>(
  (ref, action) => ref
      .watch(settingsRepositoryProvider)
      .watch(hotkeySettingKey(action))
      .map((setting) {
        if (setting == null) return defaultHotkey(action);
        try {
          return HotKey.fromJson(
            (jsonDecode(setting.value) as Map).cast<String, dynamic>(),
          );
        } on Object {
          return defaultHotkey(action);
        }
      }),
);

Future<void> saveHotkey(WidgetRef ref, AppHotkeyAction action, HotKey hotkey) {
  return ref
      .read(settingsRepositoryProvider)
      .set(hotkeySettingKey(action), jsonEncode(hotkey.toJson()));
}
