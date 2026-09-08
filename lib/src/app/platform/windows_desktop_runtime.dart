import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

abstract interface class DesktopRuntime {
  Future<void> initialize();

  Future<void> registerHotkey(HotKey hotkey, void Function() onPressed);

  Future<void> unregisterHotkey(HotKey hotkey);

  Future<void> toggleWindowVisibility();
}

final class WindowsDesktopRuntime implements DesktopRuntime {
  WindowsDesktopRuntime();

  bool _restoreMaximized = false;
  bool _togglingWindow = false;

  @override
  Future<void> initialize() async {
    await windowManager.ensureInitialized();
    await hotKeyManager.unregisterAll();
  }

  @override
  Future<void> registerHotkey(HotKey hotkey, void Function() onPressed) {
    return hotKeyManager.register(hotkey, keyDownHandler: (_) => onPressed());
  }

  @override
  Future<void> unregisterHotkey(HotKey hotkey) {
    return hotKeyManager.unregister(hotkey);
  }

  @override
  Future<void> toggleWindowVisibility() async {
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

final desktopRuntimeProvider = Provider<DesktopRuntime>((ref) {
  return WindowsDesktopRuntime();
});
