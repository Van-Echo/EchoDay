import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../../features/sync/application/sync_client_controller.dart';
import '../../features/sync/application/sync_host_controller.dart';
import '../platform/platform_capabilities.dart';

class SyncDesktopLifecycleHost extends ConsumerStatefulWidget {
  const SyncDesktopLifecycleHost({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<SyncDesktopLifecycleHost> createState() =>
      _SyncDesktopLifecycleHostState();
}

class _SyncDesktopLifecycleHostState
    extends ConsumerState<SyncDesktopLifecycleHost>
    with WindowListener, TrayListener {
  bool? _trayEnabled;
  bool _allowClose = false;
  bool _backgroundLaunchHandled = false;
  bool _windowWasUnfocused = false;
  late final bool _isWindows;

  @override
  void initState() {
    super.initState();
    _isWindows = ref.read(platformCapabilitiesProvider).isWindows;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isWindows) {
        return;
      }
      windowManager.addListener(this);
      trayManager.addListener(this);
      unawaited(_initializeSync());
    });
  }

  Future<void> _initializeSync() async {
    await ref.read(syncHostControllerProvider.notifier).initialize();
    if (!mounted ||
        ref.read(syncHostControllerProvider).mode != SyncOperatingMode.client) {
      return;
    }
    await ref.read(syncClientControllerProvider.notifier).initialize();
  }

  @override
  void dispose() {
    if (_isWindows) {
      windowManager.removeListener(this);
      trayManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(platformCapabilitiesProvider).isWindows) {
      final sync = ref.watch(syncHostControllerProvider);
      final enabled =
          sync.mode == SyncOperatingMode.host && sync.keepRunningInTray;
      if (_trayEnabled != enabled) {
        _trayEnabled = enabled;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) unawaited(_configureTray(enabled));
        });
      }
    }
    return widget.child;
  }

  Future<void> _configureTray(bool enabled) async {
    try {
      await windowManager.setPreventClose(enabled);
      if (!enabled) {
        await trayManager.destroy();
        return;
      }
      await trayManager.setIcon('windows/runner/resources/app_icon.ico');
      await trayManager.setToolTip('丸成 EchoDay');
      await trayManager.setContextMenu(
        Menu(
          items: [
            MenuItem(key: 'show', label: '打开丸成 / Open EchoDay'),
            MenuItem.separator(),
            MenuItem(key: 'exit', label: '退出 / Exit'),
          ],
        ),
      );
      if (!_backgroundLaunchHandled &&
          Platform.executableArguments.contains('--background')) {
        _backgroundLaunchHandled = true;
        await windowManager.hide();
      }
    } on Object {
      // Unsupported test shells and locked-down Windows sessions keep the app
      // functional; the settings page will still expose the host state.
    }
  }

  @override
  Future<void> onWindowClose() async {
    if (_allowClose || _trayEnabled != true) return;
    await windowManager.hide();
  }

  @override
  void onWindowFocus() {
    if (!_windowWasUnfocused) return;
    _windowWasUnfocused = false;
    final mode = ref.read(syncHostControllerProvider).mode;
    if (mode == SyncOperatingMode.host) {
      unawaited(
        ref
            .read(syncHostControllerProvider.notifier)
            .recoverHostIfNeeded(forceNetworkRefresh: true),
      );
      return;
    }
    if (mode == SyncOperatingMode.client) {
      unawaited(ref.read(syncClientControllerProvider.notifier).synchronize());
    }
  }

  @override
  void onWindowBlur() => _windowWasUnfocused = true;

  @override
  void onTrayIconMouseDown() => unawaited(_showWindow());

  @override
  void onTrayIconRightMouseDown() => unawaited(trayManager.popUpContextMenu());

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show':
        unawaited(_showWindow());
      case 'exit':
        unawaited(_exitApplication());
    }
  }

  Future<void> _showWindow() async {
    if (await windowManager.isMinimized()) await windowManager.restore();
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> _exitApplication() async {
    _allowClose = true;
    await ref.read(syncHostControllerProvider.notifier).stopForExit();
    await trayManager.destroy();
    await windowManager.setPreventClose(false);
    await windowManager.destroy();
  }
}
