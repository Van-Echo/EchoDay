import 'sync_client_models.dart';

/// Metadata only: updating an address never grants pairing permissions. The
/// client must match its existing host identity, pin TLS, and open a signed
/// session before remembering or using the new endpoint.
final class SyncEndpointUpdate {
  const SyncEndpointUpdate({
    required this.endpoint,
    required this.groupId,
    required this.hostDeviceId,
    required this.fingerprintSha256,
    required this.expiresAt,
  });

  final SyncSavedEndpoint endpoint;
  final String groupId;
  final String hostDeviceId;
  final String fingerprintSha256;
  final DateTime expiresAt;
}

abstract final class SyncEndpointUpdateCodec {
  static Uri encode(SyncEndpointUpdate update) => Uri(
    scheme: 'echoday',
    host: 'endpoint',
    queryParameters: {
      'v': '1',
      'host': update.endpoint.address,
      'port': '${update.endpoint.port}',
      'label': update.endpoint.label,
      'group': update.groupId,
      'device': update.hostDeviceId,
      'fingerprint': update.fingerprintSha256,
      'expires': update.expiresAt.toUtc().toIso8601String(),
    },
  );

  static SyncEndpointUpdate parse(String source, {DateTime? now}) {
    if (source.length > 4096) {
      throw const FormatException('Endpoint QR is too large.');
    }
    final uri = Uri.tryParse(source.trim());
    if (uri == null ||
        uri.scheme != 'echoday' ||
        uri.host != 'endpoint' ||
        uri.userInfo.isNotEmpty ||
        uri.hasPort ||
        uri.path.isNotEmpty ||
        uri.hasFragment) {
      throw const FormatException('Not an endpoint update QR.');
    }
    final query = uri.queryParameters;
    final port = int.tryParse(query['port'] ?? '');
    final group = query['group']?.trim() ?? '';
    final device = query['device']?.trim() ?? '';
    final fingerprint = query['fingerprint']?.toLowerCase() ?? '';
    final expires = DateTime.tryParse(query['expires'] ?? '')?.toUtc();
    if (query['v'] != '1' ||
        port == null ||
        group.isEmpty ||
        group.length > 256 ||
        device.isEmpty ||
        device.length > 256 ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(fingerprint) ||
        expires == null ||
        !(now ?? DateTime.now()).toUtc().isBefore(expires)) {
      throw const FormatException('Endpoint update QR is invalid or expired.');
    }
    return SyncEndpointUpdate(
      endpoint: SyncSavedEndpoint(
        address: query['host'] ?? '',
        port: port,
        label: query['label'] ?? '',
      ),
      groupId: group,
      hostDeviceId: device,
      fingerprintSha256: fingerprint,
      expiresAt: expires,
    );
  }
}
