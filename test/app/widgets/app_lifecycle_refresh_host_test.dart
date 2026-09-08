import 'package:echoday/src/app/widgets/app_lifecycle_refresh_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('resuming the app triggers an immediate clock refresh', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: AppLifecycleRefreshHost(child: SizedBox()),
        ),
      ),
    );

    expect(container.read(appRefreshRevisionProvider), 0);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(container.read(appRefreshRevisionProvider), 0);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(container.read(appRefreshRevisionProvider), 1);
  });
}
