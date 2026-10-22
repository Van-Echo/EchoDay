import 'package:echoday/l10n/app_localizations.dart';
import 'package:echoday/src/app/platform/platform_capabilities.dart';
import 'package:echoday/src/features/sync/application/sync_client_controller.dart';
import 'package:echoday/src/features/sync/domain/sync_client_models.dart';
import 'package:echoday/src/features/sync/domain/sync_repository.dart';
import 'package:echoday/src/features/sync/presentation/sync_client_settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final class _DisconnectedSyncClientController extends SyncClientController {
  @override
  SyncClientViewState build() => const SyncClientViewState(loaded: true);

  @override
  Future<void> initialize({bool synchronizeOnLoad = true}) async {}
}

final class _ConnectedSyncClientController extends SyncClientController {
  String? savedAddress;
  int? savedPort;
  String? selectedId;
  String? defaultId;
  String? updateCode;
  String? repairCode;

  @override
  Future<void> rePair(String source) async {
    repairCode = source;
  }

  @override
  SyncClientViewState build() => SyncClientViewState(
    loaded: true,
    phase: SyncClientPhase.offline,
    profile: SyncClientProfile(
      address: '100.64.0.10',
      port: 6732,
      groupId: 'test-group',
      fingerprintSha256: 'a' * 64,
      savedEndpoints: [
        SyncSavedEndpoint(address: '100.81.1.2', port: 12688, label: 'WLAN'),
      ],
      hostDevice: const SyncDeviceRegistration(
        deviceId: 'host',
        displayName: 'Main PC',
        platform: 'windows',
        appVersion: '1.0.8-dev.2',
        publicKey: 'test-key',
      ),
    ),
  );

  @override
  Future<void> initialize({bool synchronizeOnLoad = true}) async {}

  @override
  Future<void> updateEndpointAndSynchronize(String address, int port) async {
    savedAddress = address;
    savedPort = port;
  }

  @override
  Future<void> selectEndpointAndSynchronize(String id) async {
    selectedId = id;
    final endpoint = state.profile!.savedEndpoints.firstWhere(
      (item) => item.id == id,
    );
    state = state.copyWith(
      profile: state.profile!.copyWith(
        address: endpoint.address,
        port: endpoint.port,
      ),
    );
  }

  @override
  Future<void> setDefaultEndpoint(String id) async {
    defaultId = id;
    state = state.copyWith(
      profile: state.profile!.copyWith(defaultEndpointId: id),
    );
  }

  @override
  Future<void> applyEndpointUpdate(String source) async {
    updateCode = source;
  }
}

void main() {
  testWidgets('paired Android can correct a stale port without disconnecting', (
    tester,
  ) async {
    final controller = _ConnectedSyncClientController();
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          platformCapabilitiesProvider.overrideWithValue(
            const PlatformCapabilities(isAndroid: true, isWindows: false),
          ),
          syncClientControllerProvider.overrideWith(() => controller),
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
            body: SingleChildScrollView(child: SyncClientSettingsSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final dropdown = find.byKey(const ValueKey('sync-client-endpoints'));
    expect(tester.widget<DropdownButton<String>>(dropdown).items, hasLength(3));
    expect(
      find.byKey(const ValueKey('sync-scan-endpoint-update')),
      findsOneWidget,
    );
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('WLAN · 100.81.1.2:12688').last);
    await tester.pumpAndSettle();
    expect(controller.selectedId, 'https://100.81.1.2:12688');
    await tester.tap(
      find.byKey(const ValueKey('sync-client-default-endpoint')),
    );
    await tester.pumpAndSettle();
    expect(controller.defaultId, controller.selectedId);
    await tester.tap(find.byKey(const ValueKey('sync-paste-endpoint-update')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('sync-endpoint-code-input')),
      'echoday://endpoint?v=1',
    );
    await tester.tap(find.byKey(const ValueKey('sync-apply-endpoint-code')));
    await tester.pumpAndSettle();
    expect(controller.updateCode, 'echoday://endpoint?v=1');
    final repairButton = find.byKey(const ValueKey('sync-repair-client'));
    await tester.ensureVisible(repairButton);
    await tester.tap(repairButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('粘贴重新配对码'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('sync-endpoint-code-input')),
      'echoday://pair?v=1',
    );
    await tester.tap(find.byKey(const ValueKey('sync-apply-endpoint-code')));
    await tester.pumpAndSettle();
    expect(controller.repairCode, 'echoday://pair?v=1');
    await tester.ensureVisible(
      find.byKey(const ValueKey('sync-manual-endpoint-editor')),
    );
    await tester.tap(find.byKey(const ValueKey('sync-manual-endpoint-editor')));
    await tester.pumpAndSettle();
    final port = find.byKey(const ValueKey('sync-connected-port'));
    await tester.ensureVisible(port);
    await tester.enterText(port, '12688');
    await tester.ensureVisible(
      find.byKey(const ValueKey('sync-save-endpoint')),
    );
    await tester.tap(find.byKey(const ValueKey('sync-save-endpoint')));
    await tester.pumpAndSettle();
    expect(controller.savedAddress, '100.81.1.2');
    expect(controller.savedPort, 12688);
    await tester.ensureVisible(dropdown);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('新增…').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('sync-new-endpoint-host')),
      '100.81.1.3',
    );
    await tester.enterText(
      find.byKey(const ValueKey('sync-new-endpoint-port')),
      '12689',
    );
    await tester.tap(find.byKey(const ValueKey('sync-apply-endpoint-code')));
    await tester.pumpAndSettle();
    expect(controller.savedAddress, '100.81.1.3');
    expect(controller.savedPort, 12689);
    expect(controller.defaultId, controller.selectedId);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Android settings offer opt-in scan and paste pairing', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          platformCapabilitiesProvider.overrideWithValue(
            const PlatformCapabilities(isAndroid: true, isWindows: false),
          ),
          syncClientControllerProvider.overrideWith(
            _DisconnectedSyncClientController.new,
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
            body: SingleChildScrollView(child: SyncClientSettingsSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('尚未连接同步主机'), findsOneWidget);
    expect(find.byKey(const ValueKey('sync-scan-qr')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('sync-pairing-code-input')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('sync-connect-code')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Windows client offers pairing file and endpoint override', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          platformCapabilitiesProvider.overrideWithValue(
            const PlatformCapabilities(isAndroid: false, isWindows: true),
          ),
          syncClientControllerProvider.overrideWith(
            _DisconnectedSyncClientController.new,
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
            body: SingleChildScrollView(child: SyncClientSettingsSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('sync-scan-qr')), findsNothing);
    expect(find.byKey(const ValueKey('sync-discover-nearby')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('sync-import-pairing-file')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('sync-host-override')), findsOneWidget);
    expect(find.byKey(const ValueKey('sync-port-override')), findsOneWidget);
    expect(find.byKey(const ValueKey('sync-connect-code')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Windows client controls fit a narrow 200% text layout', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(440, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          platformCapabilitiesProvider.overrideWithValue(
            const PlatformCapabilities(isAndroid: false, isWindows: true),
          ),
          syncClientControllerProvider.overrideWith(
            _DisconnectedSyncClientController.new,
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
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
                  child: SyncClientSettingsSection(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('sync-host-override')), findsOneWidget);
    expect(find.byKey(const ValueKey('sync-port-override')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
