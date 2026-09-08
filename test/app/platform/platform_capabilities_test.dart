import 'package:echoday/src/app/platform/platform_capabilities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Windows exposes desktop capabilities only', () {
    const capabilities = PlatformCapabilities(
      isAndroid: false,
      isWindows: true,
    );

    expect(capabilities.supportsGlobalHotkeys, isTrue);
    expect(capabilities.supportsWindowManagement, isTrue);
    expect(capabilities.supportsFileSaveDialog, isTrue);
    expect(capabilities.supportsTouchDrag, isFalse);
    expect(capabilities.supportsPointerContextMenu, isTrue);
  });

  test('Android exposes touch capabilities without desktop services', () {
    const capabilities = PlatformCapabilities(
      isAndroid: true,
      isWindows: false,
    );

    expect(capabilities.supportsGlobalHotkeys, isFalse);
    expect(capabilities.supportsWindowManagement, isFalse);
    expect(capabilities.supportsFileSaveDialog, isFalse);
    expect(capabilities.supportsTouchDrag, isTrue);
    expect(capabilities.supportsPointerContextMenu, isFalse);
  });
}
