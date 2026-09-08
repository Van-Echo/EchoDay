import 'package:echoday/src/app/platform/platform_capabilities.dart';
import 'package:echoday/src/app/platform/windows_desktop_runtime.dart';
import 'package:echoday/src/app/widgets/hotkey_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

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
}

final class _RecordingDesktopRuntime implements DesktopRuntime {
  int callCount = 0;

  @override
  Future<void> initialize() async => callCount++;

  @override
  Future<void> registerHotkey(HotKey hotkey, void Function() onPressed) async =>
      callCount++;

  @override
  Future<void> toggleWindowVisibility() async => callCount++;

  @override
  Future<void> unregisterHotkey(HotKey hotkey) async => callCount++;
}
