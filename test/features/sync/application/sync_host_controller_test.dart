import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:echoday/src/app/platform/platform_capabilities.dart';
import 'package:echoday/src/app/providers/data_providers.dart';
import 'package:echoday/src/core/config/app_config.dart';
import 'package:echoday/src/data/database/app_database.dart';
import 'package:echoday/src/features/backup/application/backup_maintenance_service.dart';
import 'package:echoday/src/features/backup/data/backup_directory_resolver.dart';
import 'package:echoday/src/features/backup/data/local_backup_repository.dart';
import 'package:echoday/src/features/sync/application/sync_host_controller.dart';
import 'package:echoday/src/features/sync/data/local_sync_repository.dart';
import 'package:echoday/src/features/sync/domain/sync_endpoint_update.dart';
import 'package:echoday/src/features/sync/domain/sync_repository.dart';
import 'package:echoday/src/features/sync/security/device_secret_store.dart';
import 'package:echoday/src/features/sync/server/secure_sync_host_service.dart';
import 'package:echoday/src/features/sync/server/sync_network_discovery.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/in_memory_settings_repository.dart';

final class _TestDiscovery extends SyncNetworkDiscovery {
  List<SyncNetworkEndpoint> networks = [
    endpoint('Tailscale', '100.64.0.10'),
    endpoint('Wi-Fi', '100.80.2.10'),
  ];

  static SyncNetworkEndpoint endpoint(String name, String address) =>
      SyncNetworkEndpoint(
        interfaceName: name,
        address: InternetAddress(address),
        kind: name == 'Tailscale'
            ? SyncNetworkKind.tailscale
            : SyncNetworkKind.localAreaNetwork,
      );

  @override
  Future<List<SyncNetworkEndpoint>> discover() async => List.of(networks);
}

void main() {
  test(
    'saved interfaces and startup default persist across DHCP changes',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final settings = InMemorySettingsRepository();
      final discovery = _TestDiscovery();
      ProviderContainer createContainer() => ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          settingsRepositoryProvider.overrideWithValue(settings),
          syncNetworkDiscoveryProvider.overrideWithValue(discovery),
          platformCapabilitiesProvider.overrideWithValue(
            const PlatformCapabilities(isAndroid: false, isWindows: true),
          ),
        ],
      );
      var container = createContainer();
      addTearDown(() async {
        container.dispose();
        await database.close();
      });
      var controller = container.read(syncHostControllerProvider.notifier);
      await controller.initialize();
      var state = container.read(syncHostControllerProvider);
      expect(state.savedNetworks, hasLength(1));
      expect(state.selectedAddress, '100.64.0.10');
      await controller.addNetwork(discovery.networks[1]);
      expect(
        container.read(syncHostControllerProvider).selectedAddress,
        '100.80.2.10',
      );
      await controller.selectAddress('100.64.0.10');
      await controller.setDefaultNetwork('Wi-Fi|ipv4');
      expect(
        container.read(syncHostControllerProvider).selectedAddress,
        '100.64.0.10',
      );
      expect(
        jsonDecode(
          (await settings.get(SyncHostPreferenceKeys.savedNetworks))!.value,
        ),
        hasLength(2),
      );

      container.dispose();
      discovery.networks[1] = _TestDiscovery.endpoint('Wi-Fi', '100.80.2.20');
      container = createContainer();
      controller = container.read(syncHostControllerProvider.notifier);
      await controller.initialize();
      state = container.read(syncHostControllerProvider);
      expect(state.selectedAddress, '100.80.2.20');
      expect(state.defaultNetworkId, 'Wi-Fi|ipv4');
      discovery.networks.removeAt(1);
      await controller.refreshNetworks();
      state = container.read(syncHostControllerProvider);
      expect(state.selectedAddress, '100.64.0.10');
      expect(state.savedNetworks, hasLength(2));
      expect(state.availableSavedNetworks, hasLength(1));
      expect(state.defaultNetworkId, 'Wi-Fi|ipv4');
    },
  );

  test(
    'controller starts and stops a usable host without command-line setup',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final settings = InMemorySettingsRepository();
      final temporary = await Directory.systemTemp.createTemp(
        'echoday-s4-controller-',
      );
      final backupRepository = LocalBackupRepository(
        database,
        safetyBackupDirectory: () async =>
            Directory('${temporary.path}/safety'),
      );
      final backupDirectories = BackupDirectoryResolver(
        settings,
        defaultRoot: () async => temporary,
      );
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          settingsRepositoryProvider.overrideWithValue(settings),
          deviceSecretStoreProvider.overrideWithValue(
            MemoryDeviceSecretStore(),
          ),
          backupRepositoryProvider.overrideWithValue(backupRepository),
          backupDirectoryResolverProvider.overrideWithValue(backupDirectories),
          backupMaintenanceServiceProvider.overrideWithValue(
            BackupMaintenanceService(
              backupRepository,
              settings,
              backupDirectories,
            ),
          ),
          platformCapabilitiesProvider.overrideWithValue(
            const PlatformCapabilities(isAndroid: false, isWindows: true),
          ),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await database.close();
        await temporary.delete(recursive: true);
      });

      final controller = container.read(syncHostControllerProvider.notifier);
      await controller.setMode(SyncOperatingMode.host);
      final running = container.read(syncHostControllerProvider);
      expect(running.mode, SyncOperatingMode.host);
      expect(running.lifecycle, SyncHostLifecycle.running);
      expect(running.binding, isNotNull);
      expect(running.devices, hasLength(1));
      expect(running.devices.single.isLocal, isTrue);
      expect(running.devices.single.isOnline, isTrue);
      expect(running.devices.single.lastSyncAt, isNotNull);
      expect(running.devices.single.appVersion, AppConfig.version);
      expect(
        (await settings.get(SyncHostPreferenceKeys.mode))?.value,
        SyncOperatingMode.host.name,
      );
      expect(
        (await settings.get(SyncHostPreferenceKeys.port))?.value,
        '${running.binding!.port}',
      );

      final repository = LocalSyncRepository(database);
      final endpointUri = await controller.endpointUpdateUri();
      final endpointUpdate = SyncEndpointUpdateCodec.parse(
        endpointUri.toString(),
      );
      final identity = (await repository.activeIdentity())!;
      expect(endpointUpdate.groupId, identity.groupId);
      expect(endpointUpdate.hostDeviceId, identity.localDeviceId);
      expect(endpointUpdate.endpoint.address, running.binding!.address.address);
      expect(endpointUpdate.endpoint.port, running.binding!.port);
      expect(
        endpointUpdate.fingerprintSha256,
        running.binding!.fingerprintSha256,
      );
      expect(endpointUri.queryParameters, isNot(contains('token')));
      expect(container.read(syncHostControllerProvider).devices, hasLength(1));
      expect(
        container.read(syncHostControllerProvider).pendingPairings,
        isEmpty,
      );
      await repository.registerDevice(
        const SyncDeviceRegistration(
          deviceId: 'active-client',
          displayName: 'Active phone',
          platform: 'android',
          appVersion: '1.0.1',
          publicKey: 'active-public-key',
        ),
      );
      await repository.registerDevice(
        const SyncDeviceRegistration(
          deviceId: 'revoked-client',
          displayName: 'Revoked phone',
          platform: 'android',
          appVersion: '0.1.0',
          publicKey: 'revoked-public-key',
        ),
      );
      await (database.update(
        database.syncDevices,
      )..where((row) => row.deviceId.equals('revoked-client'))).write(
        SyncDevicesCompanion(revokedAt: Value(DateTime.utc(2026, 9, 10))),
      );
      await controller.refreshAdminData();
      final visibleDevices = container.read(syncHostControllerProvider).devices;
      expect(
        visibleDevices.map((device) => device.id),
        containsAll(<String>[running.devices.single.id, 'active-client']),
      );
      expect(
        visibleDevices.map((device) => device.id),
        isNot(contains('revoked-client')),
      );
      await controller.updateDeviceNote('active-client', '  小米15Pro  ');
      var aliased = container
          .read(syncHostControllerProvider)
          .devices
          .singleWhere((device) => device.id == 'active-client');
      expect(aliased.displayLabel, '小米15Pro');
      expect(aliased.displayName, 'Active phone');
      await (database.update(database.syncDevices)
            ..where((row) => row.deviceId.equals('active-client')))
          .write(const SyncDevicesCompanion(displayName: Value('localhost')));
      await controller.refreshAdminData();
      aliased = container
          .read(syncHostControllerProvider)
          .devices
          .singleWhere((device) => device.id == 'active-client');
      expect(aliased.displayLabel, '小米15Pro');
      expect(aliased.displayName, 'localhost');
      await controller.updateDeviceNote('active-client', ' ');
      aliased = container
          .read(syncHostControllerProvider)
          .devices
          .singleWhere((device) => device.id == 'active-client');
      expect(aliased.displayLabel, 'localhost');
      expect(aliased.note, isNull);

      final invite = await controller.createPairingInvite();
      expect(invite, isNotNull);
      final uri = await controller.pairingUri(invite!);
      expect(uri.scheme, 'echoday');
      expect(uri.host, 'pair');
      expect(uri.queryParameters['token'], invite.token);
      expect(
        uri.queryParameters['fingerprint'],
        running.binding!.fingerprintSha256,
      );

      // Simulate an unexpected socket loss such as sleep/resume or a network
      // adapter reset. The lifecycle recovery path must restore the service
      // without requiring the user to toggle host mode.
      await container.read(secureSyncHostServiceProvider).stop();
      expect(
        container.read(secureSyncHostServiceProvider).lifecycle,
        SyncHostLifecycle.stopped,
      );
      await controller.recoverHostIfNeeded(forceNetworkRefresh: true);
      final recovered = container.read(syncHostControllerProvider);
      expect(recovered.lifecycle, SyncHostLifecycle.running);
      expect(recovered.binding, isNotNull);
      expect(recovered.messageCode, isNull);

      final address = recovered.binding!.address;
      final port = recovered.binding!.port;
      await controller.setMode(SyncOperatingMode.off);
      expect(
        container.read(syncHostControllerProvider).lifecycle,
        SyncHostLifecycle.stopped,
      );
      await expectLater(
        Socket.connect(address, port),
        throwsA(isA<SocketException>()),
      );
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test('Windows client mode persists without starting a host socket', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final settings = InMemorySettingsRepository();
    final temporary = await Directory.systemTemp.createTemp(
      'echoday-s6-client-mode-',
    );
    final backupRepository = LocalBackupRepository(
      database,
      safetyBackupDirectory: () async => Directory('${temporary.path}/safety'),
    );
    final backupDirectories = BackupDirectoryResolver(
      settings,
      defaultRoot: () async => temporary,
    );
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        settingsRepositoryProvider.overrideWithValue(settings),
        deviceSecretStoreProvider.overrideWithValue(MemoryDeviceSecretStore()),
        backupRepositoryProvider.overrideWithValue(backupRepository),
        backupDirectoryResolverProvider.overrideWithValue(backupDirectories),
        backupMaintenanceServiceProvider.overrideWithValue(
          BackupMaintenanceService(
            backupRepository,
            settings,
            backupDirectories,
          ),
        ),
        platformCapabilitiesProvider.overrideWithValue(
          const PlatformCapabilities(isAndroid: false, isWindows: true),
        ),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await database.close();
      await temporary.delete(recursive: true);
    });

    final controller = container.read(syncHostControllerProvider.notifier);
    await controller.setMode(SyncOperatingMode.client);

    expect(
      container.read(syncHostControllerProvider).mode,
      SyncOperatingMode.client,
    );
    expect(
      container.read(syncHostControllerProvider).lifecycle,
      SyncHostLifecycle.stopped,
    );
    expect(
      (await settings.get(SyncHostPreferenceKeys.mode))?.value,
      SyncOperatingMode.client.name,
    );
    expect(container.read(secureSyncHostServiceProvider).binding, isNull);
  });
}
