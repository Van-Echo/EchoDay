import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:echoday/src/features/sync/server/sync_lan_pairing_discovery.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const uri =
      'echoday://pair?v=1&host=100.64.1.2&port=12380&group=group-1'
      '&fingerprint=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
      '&invite=invite-1&token=YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4';

  test('LAN pairing advertisement carries a validated one-time invite', () {
    final bytes = SyncLanPairingProtocol.encodeAdvertisement(
      name: 'Main PC',
      pairingUri: Uri.parse(uri),
    );
    final decoded = SyncLanPairingProtocol.decodeAdvertisement(
      bytes,
      InternetAddress('192.168.1.8'),
    );

    expect(decoded, isNotNull);
    expect(decoded!.name, 'Main PC');
    expect(decoded.sourceAddress, '192.168.1.8');
    expect(decoded.endpoint.port, 12380);
  });

  test('LAN discovery ignores malformed and unrelated datagrams', () {
    expect(
      SyncLanPairingProtocol.decodeAdvertisement([
        1,
        2,
        3,
      ], InternetAddress.loopbackIPv4),
      isNull,
    );
  });

  test(
    'advertiser answers only while the pairing invitation is open',
    () async {
      final advertiser = SyncLanPairingAdvertiser();
      final client = await RawDatagramSocket.bind(
        InternetAddress.loopbackIPv4,
        0,
      );
      addTearDown(() async {
        client.close();
        await advertiser.stop();
      });
      await advertiser.start(name: 'Main PC', pairingUri: Uri.parse(uri));
      final response = Completer<Datagram>();
      final subscription = client.listen((event) {
        if (event != RawSocketEvent.read || response.isCompleted) return;
        final datagram = client.receive();
        if (datagram != null) response.complete(datagram);
      });
      addTearDown(subscription.cancel);

      client.send(
        utf8.encode(SyncLanPairingProtocol.query),
        InternetAddress.loopbackIPv4,
        SyncLanPairingProtocol.port,
      );
      final datagram = await response.future.timeout(
        const Duration(seconds: 2),
      );
      final decoded = SyncLanPairingProtocol.decodeAdvertisement(
        datagram.data,
        datagram.address,
      );
      expect(decoded?.name, 'Main PC');
    },
  );
}
