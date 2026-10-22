import 'dart:io';

import 'package:echoday/src/features/sync/server/sync_network_discovery.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('saved network survives DHCP changes and round trips JSON', () {
    final old = SyncNetworkEndpoint(
      interfaceName: 'Wi-Fi',
      address: InternetAddress('100.81.72.239'),
      kind: SyncNetworkKind.localAreaNetwork,
    );
    final current = SyncNetworkEndpoint(
      interfaceName: 'Wi-Fi',
      address: InternetAddress('100.81.72.240'),
      kind: SyncNetworkKind.localAreaNetwork,
    );
    final saved = SavedSyncNetwork.fromEndpoint(old);
    final restored = SavedSyncNetwork.fromJson(saved.toJson())!;
    expect(restored.id, saved.id);
    expect(restored.resolve([current]), current);
    expect(restored.resolve([]), isNull);
    expect(SavedSyncNetwork.fromJson({'address': 'bad'}), isNull);
  });

  test(
    'classifies only loopback, LAN, link-local, and Tailscale addresses',
    () {
      expect(
        SyncNetworkDiscovery.classify(InternetAddress.loopbackIPv4),
        SyncNetworkKind.loopback,
      );
      expect(
        SyncNetworkDiscovery.classify(InternetAddress('192.168.1.8')),
        SyncNetworkKind.localAreaNetwork,
      );
      expect(
        SyncNetworkDiscovery.classify(InternetAddress('100.100.10.8')),
        SyncNetworkKind.localAreaNetwork,
      );
      expect(
        SyncNetworkDiscovery.classify(
          InternetAddress('100.100.10.8'),
          interfaceName: 'Tailscale',
        ),
        SyncNetworkKind.tailscale,
      );
      expect(SyncNetworkDiscovery.classify(InternetAddress('8.8.8.8')), isNull);
      expect(SyncNetworkDiscovery.classify(InternetAddress.anyIPv4), isNull);
    },
  );

  test('maps bind failures to stable UI-facing states without details', () {
    final failure = SyncHostStartException.fromSocket(
      const SocketException(
        'sensitive OS text',
        osError: OSError('sensitive OS text', 10048),
      ),
    );
    expect(failure.code, SyncHostStartFailureCode.addressInUse);
    expect(failure.toString(), isNot(contains('sensitive')));
  });

  test('drops loopback and migrates a stale loopback preference', () {
    final networks = [
      SyncNetworkEndpoint(
        interfaceName: 'Loopback',
        address: InternetAddress.loopbackIPv4,
        kind: SyncNetworkKind.loopback,
      ),
      SyncNetworkEndpoint(
        interfaceName: 'WLAN',
        address: InternetAddress('100.81.72.239'),
        kind: SyncNetworkKind.localAreaNetwork,
      ),
      SyncNetworkEndpoint(
        interfaceName: 'Tailscale',
        address: InternetAddress('100.126.166.78'),
        kind: SyncNetworkKind.tailscale,
      ),
    ];

    final usable = usableSyncHostNetworks(networks);
    expect(
      usable.map((item) => item.address.address),
      isNot(contains('127.0.0.1')),
    );
    expect(selectSyncHostAddress(networks, '127.0.0.1'), '100.126.166.78');
  });
}
