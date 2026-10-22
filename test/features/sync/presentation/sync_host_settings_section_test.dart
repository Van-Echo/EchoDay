import 'dart:io';

import 'package:echoday/l10n/app_localizations.dart';
import 'package:echoday/src/app/platform/platform_capabilities.dart';
import 'package:echoday/src/features/sync/application/sync_client_controller.dart';
import 'package:echoday/src/features/sync/application/sync_host_controller.dart';
import 'package:echoday/src/features/sync/domain/sync_client_models.dart';
import 'package:echoday/src/features/sync/domain/sync_endpoint_update.dart';
import 'package:echoday/src/features/sync/domain/sync_repository.dart';
import 'package:echoday/src/features/sync/presentation/sync_host_settings_section.dart';
import 'package:echoday/src/features/sync/security/sync_pairing_service.dart';
import 'package:echoday/src/features/sync/server/secure_sync_host_service.dart';
import 'package:echoday/src/features/sync/server/sync_network_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeSyncHostController extends SyncHostController {
  bool failApproval = false;
  int refreshes = 0;
  final approved = <String>[];
  @override
  SyncHostViewState build() => SyncHostViewState(
    loaded: true,
    mode: SyncOperatingMode.host,
    lifecycle: SyncHostLifecycle.running,
    selectedAddress: '127.0.0.1',
    savedNetworks: const [
      SavedSyncNetwork(
        interfaceName: 'Loopback',
        address: '127.0.0.1',
        ipv6: false,
      ),
    ],
    defaultNetworkId: 'Loopback|ipv4',
    networks: [
      SyncNetworkEndpoint(
        interfaceName: 'Loopback',
        address: InternetAddress.loopbackIPv4,
        kind: SyncNetworkKind.loopback,
      ),
      SyncNetworkEndpoint(
        interfaceName: 'Wi-Fi',
        address: InternetAddress('192.168.1.20'),
        kind: SyncNetworkKind.localAreaNetwork,
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
        displayName: 'localhost',
        note: '小米15Pro',
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

  @override
  Future<void> refreshNetworks() async {}

  @override
  Future<void> refreshAdminData() async {
    refreshes++;
  }

  @override
  Future<SyncPairingInvite?> createPairingInvite() async => SyncPairingInvite(
    id: 'invite-a',
    token: 'a' * 32,
    hostFingerprint: 'a' * 64,
    expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 10)),
  );

  @override
  Future<Uri> pairingUri(SyncPairingInvite invite) async => Uri(
    scheme: 'echoday',
    host: 'pair',
    queryParameters: {
      'v': '1',
      'host': '127.0.0.1',
      'port': '45678',
      'group': 'group-a',
      'fingerprint': invite.hostFingerprint,
      'invite': invite.id,
      'token': invite.token,
    },
  );

  @override
  Future<Uri> endpointUpdateUri() async => SyncEndpointUpdateCodec.encode(
    SyncEndpointUpdate(
      endpoint: SyncSavedEndpoint(
        address: '127.0.0.1',
        port: 45678,
        label: 'WLAN',
      ),
      groupId: 'group-a',
      hostDeviceId: 'host',
      fingerprintSha256: 'a' * 64,
      expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 10)),
    ),
  );

  void receiveRequests() {
    PendingPairingRequest request(String id, String invite, String name) =>
        PendingPairingRequest(
          id: id,
          inviteId: invite,
          verificationCode: '123456',
          expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
          device: SyncDeviceRegistration(
            deviceId: id,
            displayName: name,
            platform: 'android',
            appVersion: '1.0.8',
            publicKey: 'key',
          ),
        );
    state = state.copyWith(
      pendingPairings: [
        request('phone-a', 'invite-a', 'Test phone'),
        request('phone-b', 'invite-b', 'Unrelated phone'),
      ],
    );
  }

  @override
  Future<void> approvePairing(String id) async {
    if (failApproval) throw StateError('Simulated approval failure');
    approved.add(id);
    state = state.copyWith(
      pendingPairings: state.pendingPairings
          .where((item) => item.id != id)
          .toList(),
    );
  }

  @override
  Future<void> addNetwork(SyncNetworkEndpoint endpoint) async {
    state = state.copyWith(
      savedNetworks: [
        ...state.savedNetworks,
        SavedSyncNetwork.fromEndpoint(endpoint),
      ],
      selectedAddress: endpoint.address.address,
    );
  }

  @override
  Future<void> updateDeviceNote(String deviceId, String note) async {
    state = state.copyWith(
      devices: [
        for (final device in state.devices)
          if (device.id != deviceId)
            device
          else
            ManagedSyncDevice(
              id: device.id,
              displayName: device.displayName,
              note: note.trim().isEmpty ? null : note.trim(),
              platform: device.platform,
              appVersion: device.appVersion,
              isLocal: device.isLocal,
              isOnline: device.isOnline,
              syncRequested: device.syncRequested,
              protocolVersion: device.protocolVersion,
              lastSyncAt: device.lastSyncAt,
              revokedAt: device.revokedAt,
            ),
      ],
    );
  }
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
  testWidgets(
    'pairing dialog displays matching device code and closes only after successful approval',
    (tester) async {
      final controller = _FakeSyncHostController();
      await tester.binding.setSurfaceSize(const Size(1000, 1050));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncHostControllerProvider.overrideWith(() => controller),
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
              body: SingleChildScrollView(child: SyncHostSettingsSection()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('多端同步'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('sync-create-pairing')),
      );
      await tester.tap(find.byKey(const ValueKey('sync-create-pairing')));
      await tester.pumpAndSettle();
      final dialog = find.byKey(const ValueKey('sync-pairing-dialog'));
      expect(dialog, findsOneWidget);
      controller.receiveRequests();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(controller.refreshes, greaterThan(0));
      expect(
        find.descendant(of: dialog, matching: find.text('Test phone')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: dialog, matching: find.text('Unrelated phone')),
        findsNothing,
      );
      expect(
        find.descendant(of: dialog, matching: find.textContaining('123456')),
        findsOneWidget,
      );
      final approve = find.descendant(
        of: dialog,
        matching: find.byKey(const ValueKey('sync-approve-phone-a')),
      );
      await tester.ensureVisible(approve);
      controller.failApproval = true;
      await tester.tap(approve);
      await tester.pumpAndSettle();
      expect(dialog, findsOneWidget);
      controller.failApproval = false;
      await tester.tap(approve);
      await tester.pumpAndSettle();
      expect(dialog, findsNothing);
      expect(controller.approved, ['phone-a']);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

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
    final deviceTitle = find.byKey(
      const ValueKey('sync-device-title-old-client'),
    );
    expect(tester.widget<Text>(deviceTitle).data, '小米15Pro');
    expect(find.text('localhost'), findsNothing);
    for (final prefix in [
      'sync-repair-device',
      'sync-rename-device',
      'sync-device-now',
      'sync-revoke-device',
    ]) {
      final button = find.byKey(ValueKey('$prefix-old-client'));
      expect(
        tester.getCenter(button).dy,
        closeTo(tester.getCenter(deviceTitle).dy, 1),
      );
      expect(
        tester.getCenter(button).dx,
        greaterThan(tester.getCenter(deviceTitle).dx),
      );
    }
    final rename = find.byKey(const ValueKey('sync-rename-device-old-client'));
    await tester.ensureVisible(rename);
    await tester.tap(rename);
    await tester.pumpAndSettle();
    final nameInput = find.byKey(const ValueKey('sync-device-name-input'));
    expect(tester.widget<TextField>(nameInput).controller!.text, '小米15Pro');
    await tester.enterText(nameInput, '我的手机');
    await tester.tap(find.byKey(const ValueKey('sync-device-name-save')));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(deviceTitle).data, '我的手机');
    expect(find.text('小米15Pro'), findsNothing);
    await tester.tap(rename);
    await tester.pumpAndSettle();
    await tester.enterText(nameInput, '');
    await tester.tap(find.byKey(const ValueKey('sync-device-name-save')));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(deviceTitle).data, 'localhost');
    final dropdown = find.byKey(const ValueKey('sync-address-field'));
    expect(tester.widget<DropdownButton<String>>(dropdown).items, hasLength(2));
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('新增…').last);
    await tester.pumpAndSettle();
    expect(find.text('添加监听网络接口'), findsOneWidget);
    expect(find.text('Wi-Fi'), findsOneWidget);
    await tester.tap(find.text('关闭').last);
    await tester.pumpAndSettle();
    expect(tester.widget<DropdownButton<String>>(dropdown).value, '127.0.0.1');
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('新增…').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wi-Fi'));
    await tester.pumpAndSettle();
    expect(tester.widget<DropdownButton<String>>(dropdown).items, hasLength(3));
    expect(
      tester.widget<DropdownButton<String>>(dropdown).value,
      '192.168.1.20',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('sync-update-wlan')));
    await tester.tap(find.byKey(const ValueKey('sync-update-wlan')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('sync-endpoint-update-qr')),
      findsOneWidget,
    );
    await tester.tap(find.text('关闭').last);
    await tester.pumpAndSettle();
    final repair = find.byKey(const ValueKey('sync-repair-device-old-client'));
    await tester.ensureVisible(repair);
    await tester.tap(repair);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('sync-pairing-dialog')), findsOneWidget);
    expect(find.text('重新配对'), findsOneWidget);
    await tester.tap(find.text('关闭').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
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
