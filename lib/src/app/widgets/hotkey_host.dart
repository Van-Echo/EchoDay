import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../../features/calendar/application/calendar_controller.dart';
import '../../features/settings/application/hotkey_preferences.dart';
import '../platform/platform_capabilities.dart';
import '../platform/windows_desktop_runtime.dart';
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

  @override
  Widget build(BuildContext context) {
    final capabilities = ref.watch(platformCapabilitiesProvider);
    if (!capabilities.supportsGlobalHotkeys) return widget.child;
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
    if (!ref.read(platformCapabilitiesProvider).supportsGlobalHotkeys) return;
    final runtime = ref.read(desktopRuntimeProvider);
    try {
      if (_registeredHotkeys[action] case final previous?) {
        await runtime.unregisterHotkey(previous);
      }
      await runtime.registerHotkey(hotkey, () async {
        switch (action) {
          case AppHotkeyAction.summon:
            await runtime.toggleWindowVisibility();
          case AppHotkeyAction.today:
            if (mounted) {
              ref.read(calendarControllerProvider.notifier).goToToday();
              context.go(AppRoutes.calendar);
            }
        }
      });
      _registeredHotkeys[action] = hotkey;
    } on Object {
      // Widget tests and unsupported desktop sessions may not expose plugins.
    }
  }
}
