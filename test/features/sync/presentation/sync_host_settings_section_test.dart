import 'dart:io';

import 'package:echoday/l10n/app_localizations.dart';
import 'package:echoday/src/app/platform/platform_capabilities.dart';
import 'package:echoday/src/features/sync/application/sync_client_controller.dart';
import 'package:echoday/src/features/sync/application/sync_host_controller.dart';
import 'package:echoday/src/features/sync/presentation/sync_host_settings_section.dart';
import 'package:echoday/src/features/sync/server/secure_sync_host_service.dart';
import 'package:echoday/src/features/sync/server/sync_network_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeSyncHostController extends SyncHostController {
  @override
  SyncHostViewState build() => SyncHostViewState(
    loaded: true,
    mode: SyncOperatingMode.host,
    lifecycle: SyncHostLifecycle.running,
    selectedAddress: '127.0.0.1',
    networks: [
      SyncNetworkEndpoint(
        interfaceName: 'Loopback',
        address: InternetAddress.loopbackIPv4,
        kind: SyncNetworkKind.loopback,
      ),
    ],
    binding: SyncHostBinding(
      address: InternetAddress.loopbackIPv4,
      port: 45678,
      fingerprintSha256: 'a' * 64,
    ),
    devices: const [
      ManagedSyncDevice(
        id: 'host',
        displayName: 'EchoDay PC',
        platform: 'windows',
        appVersion: '1.0.0',
        isLocal: true,
        isOnline: true,
        syncRequested: false,
      ),
      ManagedSyncDevice(
        id: 'old-client',
        displayName: 'Old EchoDay client',
        platform: 'android',
        appVersion: '0.0.1',
        protocolVersion: 99,
        isLocal: false,
        isOnline: false,
        syncRequested: false,
      ),
    ],
  );

  @override
  Future<void> initialize() async {}
}

final class _FakeClientModeController extends SyncHostController {
  @override
  SyncHostViewState build() => const SyncHostViewState(
    loaded: true,
    mode: SyncOperatingMode.client,
    lifecycle: SyncHostLifecycle.stopped,
  );

  @override
  Future<void> initialize() async {}
}

final class _DisconnectedClientController extends SyncClientController {
  @override
  SyncClientViewState build() => const SyncClientViewState(loaded: true);

  @override
  Future<void> initialize({bool synchronizeOnLoad = true}) async {}
}

void main() {
  testWidgets('host settings expose status, endpoint, pairing and devices', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncHostControllerProvider.overrideWith(_FakeSyncHostController.new),
        ],
        child: const MaterialApp(
          locale: Locale('zh'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: SyncHostSettingsSection(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('正在运行'), findsOneWidget);
    await tester.tap(find.text('多端同步'));
    await tester.pumpAndSettle();
    expect(find.text('作为同步主机'), findsOneWidget);
    expect(find.textContaining('https://127.0.0.1:45678'), findsOneWidget);
    expect(find.byKey(const ValueKey('sync-create-pairing')), findsOneWidget);
    expect(find.text('EchoDay PC'), findsOneWidget);
    expect(find.text('本机'), findsOneWidget);
    expect(find.textContaining('需要升级'), findsOneWidget);
    expect(find.byType(Badge), findsWidgets);
    expect(find.byKey(const ValueKey('sync-all-devices')), findsOneWidget);
  });

  testWidgets('Windows mode exposes the embedded desktop client workflow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          platformCapabilitiesProvider.overrideWithValue(
            const PlatformCapabilities(isAndroid: false, isWindows: true),
          ),
          syncHostControllerProvider.overrideWith(
            _FakeClientModeController.new,
          ),
          syncClientControllerProvider.overrideWith(
            _DisconnectedClientController.new,
          ),
        ],
        child: const MaterialApp(
          locale: Locale('zh'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: SyncHostSettingsSection(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('多端同步'));
    await tester.pumpAndSettle();

    expect(find.text('连接到同步主机'), findsOneWidget);
    expect(find.byKey(const ValueKey('sync-discover-nearby')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('sync-import-pairing-file')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('sync-host-override')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('host settings fit narrow dark mode at 200% text scale', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(520, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncHostControllerProvider.overrideWith(_FakeSyncHostController.new),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          theme: ThemeData.dark(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: const Scaffold(
                body: SingleChildScrollView(
                  padding: EdgeInsets.all(12),
                  child: SyncHostSettingsSection(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Multi-device sync'));
    await tester.pumpAndSettle();

    expect(find.text('Act as sync host'), findsOneWidget);
    expect(find.textContaining('Upgrade required'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
