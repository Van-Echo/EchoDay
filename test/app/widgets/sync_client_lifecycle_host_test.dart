import 'package:echoday/src/app/platform/platform_capabilities.dart';
import 'package:echoday/src/app/widgets/sync_client_lifecycle_host.dart';
import 'package:echoday/src/features/sync/application/sync_client_controller.dart';
import 'package:echoday/src/features/sync/domain/sync_client_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final class _LifecycleSyncController extends SyncClientController {
  int initializeCount = 0;
  int synchronizeCount = 0;

  @override
  SyncClientViewState build() => const SyncClientViewState(loaded: true);

  @override
  Future<void> initialize({bool synchronizeOnLoad = true}) async {
    initializeCount++;
  }

  @override
  Future<SyncRunResult?> synchronize() async {
    synchronizeCount++;
    return null;
  }
}

void main() {
  testWidgets('Android initializes on launch and syncs only when resumed', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        platformCapabilitiesProvider.overrideWithValue(
          const PlatformCapabilities(isAndroid: true, isWindows: false),
        ),
        syncClientControllerProvider.overrideWith(_LifecycleSyncController.new),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: SyncClientLifecycleHost(child: SizedBox()),
        ),
      ),
    );
    await tester.pump();
    final controller = container.read(
      syncClientControllerProvider.notifier,
    ) as _LifecycleSyncController;
    expect(controller.initializeCount, 1);
    expect(controller.synchronizeCount, 0);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(controller.synchronizeCount, 0);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(controller.synchronizeCount, 1);

    // Duplicate resumed notifications in the same foreground lifecycle are
    // ignored, avoiding noisy repeat attempts after one wake-up.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(controller.synchronizeCount, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(controller.synchronizeCount, 2);
  });
}
