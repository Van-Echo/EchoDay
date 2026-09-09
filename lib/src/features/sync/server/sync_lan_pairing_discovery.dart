import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../domain/sync_client_models.dart';

final class DiscoveredSyncHost {
  const DiscoveredSyncHost({
    required this.name,
    required this.pairingUri,
    required this.sourceAddress,
  });

  final String name;
  final String pairingUri;
  final String sourceAddress;

  SyncPairingEndpoint get endpoint => SyncPairingUriCodec.parse(pairingUri);
}

abstract final class SyncLanPairingProtocol {
  static const port = 43821;
  static const query = 'ECHODAY_PAIR_DISCOVERY_V1';

  static List<int> encodeAdvertisement({
    required String name,
    required Uri pairingUri,
  }) => utf8.encode(
    jsonEncode({
      'protocol': query,
      'name': name,
      'pairingUri': pairingUri.toString(),
    }),
  );

  static DiscoveredSyncHost? decodeAdvertisement(
    List<int> bytes,
    InternetAddress sourceAddress,
  ) {
    if (bytes.length > 8192) return null;
    try {
      final value = jsonDecode(utf8.decode(bytes));
      if (value is! Map<String, dynamic> || value['protocol'] != query) {
        return null;
      }
      final name = value['name'];
      final pairingUri = value['pairingUri'];
      if (name is! String || pairingUri is! String) return null;
      SyncPairingUriCodec.parse(pairingUri);
      return DiscoveredSyncHost(
        name: name.trim().isEmpty ? sourceAddress.address : name.trim(),
        pairingUri: pairingUri,
        sourceAddress: sourceAddress.address,
      );
    } on Object {
      return null;
    }
  }
}

/// Advertises only the one-time invitation currently visible on the host.
/// Closing the pairing dialog disposes the socket immediately.
final class SyncLanPairingAdvertiser {
  RawDatagramSocket? _socket;
  StreamSubscription<RawSocketEvent>? _subscription;
  int _generation = 0;

  Future<void> start({required String name, required Uri pairingUri}) async {
    await stop();
    final generation = ++_generation;
    final socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      SyncLanPairingProtocol.port,
      reuseAddress: true,
    );
    if (generation != _generation) {
      socket.close();
      return;
    }
    socket.broadcastEnabled = true;
    final payload = SyncLanPairingProtocol.encodeAdvertisement(
      name: name,
      pairingUri: pairingUri,
    );
    _socket = socket;
    _subscription = socket.listen((event) {
      if (event != RawSocketEvent.read) return;
      Datagram? datagram;
      while ((datagram = socket.receive()) != null) {
        final request = datagram!;
        if (utf8.decode(request.data, allowMalformed: true) !=
            SyncLanPairingProtocol.query) {
          continue;
        }
        socket.send(payload, request.address, request.port);
      }
    });
  }

  Future<void> stop() async {
    _generation++;
    await _subscription?.cancel();
    _subscription = null;
    _socket?.close();
    _socket = null;
  }
}

final class SyncLanPairingDiscovery {
  const SyncLanPairingDiscovery();

  Future<List<DiscoveredSyncHost>> discover({
    Duration timeout = const Duration(seconds: 2),
  }) async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    socket.broadcastEnabled = true;
    final found = <String, DiscoveredSyncHost>{};
    final subscription = socket.listen((event) {
      if (event != RawSocketEvent.read) return;
      Datagram? datagram;
      while ((datagram = socket.receive()) != null) {
        final response = SyncLanPairingProtocol.decodeAdvertisement(
          datagram!.data,
          datagram.address,
        );
        if (response != null) {
          final endpoint = response.endpoint;
          found['${endpoint.groupId}:${endpoint.inviteId}'] = response;
        }
      }
    });
    try {
      socket.send(
        utf8.encode(SyncLanPairingProtocol.query),
        InternetAddress('255.255.255.255'),
        SyncLanPairingProtocol.port,
      );
      await Future<void>.delayed(timeout);
    } finally {
      await subscription.cancel();
      socket.close();
    }
    final result = found.values.toList()
      ..sort((left, right) => left.name.compareTo(right.name));
    return List.unmodifiable(result);
  }
}
