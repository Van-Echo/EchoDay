import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final class PlatformCapabilities {
  const PlatformCapabilities({
    required this.isAndroid,
    required this.isWindows,
  });

  factory PlatformCapabilities.current() => PlatformCapabilities(
    isAndroid: Platform.isAndroid,
    isWindows: Platform.isWindows,
  );

  final bool isAndroid;
  final bool isWindows;

  bool get supportsGlobalHotkeys => isWindows;
  bool get supportsWindowManagement => isWindows;
  bool get supportsFileSaveDialog => isWindows;
  bool get supportsSystemShare => false;
  bool get supportsTouchDrag => isAndroid;
  bool get supportsPointerContextMenu => !isAndroid;
}

final platformCapabilitiesProvider = Provider<PlatformCapabilities>((ref) {
  return PlatformCapabilities.current();
});
