import 'dart:io';

enum SyncNetworkKind { loopback, localAreaNetwork, tailscale }

final class SyncNetworkEndpoint {
  const SyncNetworkEndpoint({
    required this.interfaceName,
    required this.address,
    required this.kind,
  });

  final String interfaceName;
  final InternetAddress address;
  final SyncNetworkKind kind;
}

/// Finds only interfaces that are safe for the local/Tailscale host service.
/// Public addresses and wildcard binds are deliberately excluded.
final class SyncNetworkDiscovery {
  const SyncNetworkDiscovery();

  Future<List<SyncNetworkEndpoint>> discover() async {
    final interfaces = await NetworkInterface.list(
      includeLoopback: true,
      includeLinkLocal: true,
    );
    final endpoints = <SyncNetworkEndpoint>[];
    final seen = <String>{};
    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        final kind = classify(address, interfaceName: interface.name);
        if (kind == null || !seen.add(address.address)) continue;
        endpoints.add(
          SyncNetworkEndpoint(
            interfaceName: interface.name,
            address: address,
            kind: kind,
          ),
        );
      }
    }
    endpoints.sort((left, right) {
      final kindOrder = left.kind.index.compareTo(right.kind.index);
      return kindOrder != 0
          ? kindOrder
          : left.address.address.compareTo(right.address.address);
    });
    return List.unmodifiable(endpoints);
  }

  static SyncNetworkKind? classify(
    InternetAddress address, {
    String? interfaceName,
  }) {
    if (address.isLoopback) return SyncNetworkKind.loopback;
    final bytes = address.rawAddress;
    if (address.type == InternetAddressType.IPv4) {
      if (bytes[0] == 100 && bytes[1] >= 64 && bytes[1] <= 127) {
        // Tailscale uses 100.64.0.0/10, but routers and campus networks may
        // also assign that CGNAT range to Wi-Fi clients. Only label an actual
        // Tailscale adapter as Tailscale; another interface in the same range
        // is still a valid directly reachable LAN endpoint.
        final normalizedName = interfaceName?.toLowerCase() ?? '';
        return normalizedName.contains('tailscale')
            ? SyncNetworkKind.tailscale
            : SyncNetworkKind.localAreaNetwork;
      }
      if (bytes[0] == 10 ||
          (bytes[0] == 172 && bytes[1] >= 16 && bytes[1] <= 31) ||
          (bytes[0] == 192 && bytes[1] == 168) ||
          (bytes[0] == 169 && bytes[1] == 254)) {
        return SyncNetworkKind.localAreaNetwork;
      }
      return null;
    }
    if (bytes.isNotEmpty &&
        (bytes[0] == 0xfc ||
            bytes[0] == 0xfd ||
            (bytes[0] == 0xfe && (bytes[1] & 0xc0) == 0x80))) {
      return SyncNetworkKind.localAreaNetwork;
    }
    return null;
  }
}

/// Removes loopback from the host choices whenever a phone-reachable address
/// exists. Keeping loopback as the last-resort fallback preserves local
/// development and test environments without allowing a stale `127.0.0.1`
/// preference to produce an unusable pairing QR on a real PC.
List<SyncNetworkEndpoint> usableSyncHostNetworks(
  List<SyncNetworkEndpoint> networks,
) {
  final reachable = networks
      .where((endpoint) => endpoint.kind != SyncNetworkKind.loopback)
      .toList(growable: false);
  return List.unmodifiable(reachable.isEmpty ? networks : reachable);
}

String? selectSyncHostAddress(
  List<SyncNetworkEndpoint> networks,
  String? preferred,
) {
  final usable = usableSyncHostNetworks(networks);
  if (preferred != null &&
      usable.any((endpoint) => endpoint.address.address == preferred)) {
    return preferred;
  }
  for (final kind in const [
    SyncNetworkKind.localAreaNetwork,
    SyncNetworkKind.tailscale,
    SyncNetworkKind.loopback,
  ]) {
    for (final endpoint in usable) {
      if (endpoint.kind == kind &&
          endpoint.address.type == InternetAddressType.IPv4) {
        return endpoint.address.address;
      }
    }
  }
  return usable.firstOrNull?.address.address;
}

enum SyncHostStartFailureCode {
  addressInUse,
  permissionDenied,
  addressUnavailable,
  networkUnavailable,
  unknown,
}

/// A stable, non-sensitive failure that the settings UI can localize in S4.
final class SyncHostStartException implements Exception {
  const SyncHostStartException(this.code);

  factory SyncHostStartException.fromSocket(SocketException error) {
    final code = error.osError?.errorCode;
    return SyncHostStartException(switch (code) {
      48 || 98 || 10048 => SyncHostStartFailureCode.addressInUse,
      13 || 10013 => SyncHostStartFailureCode.permissionDenied,
      49 || 99 || 10049 => SyncHostStartFailureCode.addressUnavailable,
      50 ||
      10050 ||
      10051 ||
      10065 => SyncHostStartFailureCode.networkUnavailable,
      _ => SyncHostStartFailureCode.unknown,
    });
  }

  final SyncHostStartFailureCode code;

  @override
  String toString() => 'SyncHostStartException(${code.name})';
}
