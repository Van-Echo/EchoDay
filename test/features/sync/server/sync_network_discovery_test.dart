import 'dart:io';

import 'package:echoday/src/features/sync/server/sync_network_discovery.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
    expect(selectSyncHostAddress(networks, '127.0.0.1'), '100.81.72.239');
  });
}
