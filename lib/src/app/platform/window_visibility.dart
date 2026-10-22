import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'platform_capabilities.dart';

abstract interface class WindowVisibilityProbe {
  Future<bool> hasVisibleArea();
}

final class NativeWindowVisibilityProbe implements WindowVisibilityProbe {
  const NativeWindowVisibilityProbe();

  static const _channel = MethodChannel('echoday/window_visibility');

  @override
  Future<bool> hasVisibleArea() async {
    try {
      return await _channel.invokeMethod<bool>('hasVisibleArea') ?? false;
    } on MissingPluginException {
      // Test shells and older runners still allow visible, unfocused windows.
      return WidgetsBinding.instance.lifecycleState !=
              AppLifecycleState.hidden &&
          WidgetsBinding.instance.lifecycleState != AppLifecycleState.paused &&
          WidgetsBinding.instance.lifecycleState != AppLifecycleState.detached;
    }
  }
}

final windowVisibilityProbeProvider = Provider<WindowVisibilityProbe>((ref) {
  ref.watch(platformCapabilitiesProvider);
  return const NativeWindowVisibilityProbe();
});
