import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../../features/calendar/application/calendar_controller.dart';
import '../../features/settings/application/hotkey_preferences.dart';
import '../router/app_routes.dart';

class HotkeyHost extends ConsumerStatefulWidget {
  const HotkeyHost({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<HotkeyHost> createState() => _HotkeyHostState();
}

class _HotkeyHostState extends ConsumerState<HotkeyHost> {
  final Map<AppHotkeyAction, String> _registered = {};
  final Map<AppHotkeyAction, HotKey> _registeredHotkeys = {};
  var _restoreMaximized = false;
  var _togglingWindow = false;

  @override
  Widget build(BuildContext context) {
    for (final action in AppHotkeyAction.values) {
      final hotkey = ref.watch(hotkeyPreferenceProvider(action)).value;
      if (hotkey != null) _scheduleRegistration(action, hotkey);
    }
    return widget.child;
  }

  void _scheduleRegistration(AppHotkeyAction action, HotKey hotkey) {
    final signature = hotkey.toJson().toString();
    if (_registered[action] == signature) return;
    _registered[action] = signature;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_register(action, hotkey));
    });
  }

  Future<void> _register(AppHotkeyAction action, HotKey hotkey) async {
    if (kIsWeb || !Platform.isWindows) return;
    try {
      if (_registeredHotkeys[action] case final previous?) {
        await hotKeyManager.unregister(previous);
      }
      await hotKeyManager.register(
        hotkey,
        keyDownHandler: (_) async {
          switch (action) {
            case AppHotkeyAction.summon:
              await _toggleWindowVisibility();
            case AppHotkeyAction.today:
              if (mounted) {
                ref.read(calendarControllerProvider.notifier).goToToday();
                context.go(AppRoutes.calendar);
              }
          }
        },
      );
      _registeredHotkeys[action] = hotkey;
    } on Object {
      // Widget tests and unsupported desktop sessions may not expose plugins.
    }
  }

  Future<void> _toggleWindowVisibility() async {
    if (_togglingWindow) return;
    _togglingWindow = true;
    try {
      final minimized = await windowManager.isMinimized();
      final visible = await windowManager.isVisible();
      final focused = await windowManager.isFocused();
      if (visible && !minimized && focused) {
        _restoreMaximized = await windowManager.isMaximized();
        await windowManager.minimize();
        return;
      }
      if (minimized) await windowManager.restore();
      await windowManager.show();
      if (_restoreMaximized) await windowManager.maximize();
      await windowManager.focus();
    } finally {
      _togglingWindow = false;
    }
  }
}
