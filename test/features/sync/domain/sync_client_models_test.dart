import 'package:echoday/src/features/sync/domain/sync_client_models.dart';
import 'package:echoday/src/features/sync/domain/sync_endpoint_update.dart';
import 'package:echoday/src/features/sync/domain/sync_repository.dart';
import 'package:echoday/src/features/sync/security/sync_crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('saved endpoints retain IPv6 hosts supported by existing pairing', () {
    final endpoint = SyncSavedEndpoint(address: 'fd12::1', port: 12688);
    expect(endpoint.address, 'fd12::1');
    expect(endpoint.baseUri.toString(), 'https://[fd12::1]:12688');
    expect(SyncSavedEndpoint.fromJson(endpoint.toJson()).id, endpoint.id);
    expect(
      () => SyncSavedEndpoint(address: 'user@example.com', port: 12688),
      throwsFormatException,
    );
    expect(
      () => SyncSavedEndpoint(address: 'example.com:12688', port: 12688),
      throwsFormatException,
    );
  });

  test('legacy connection profiles seed history and a default without losing identity or cursor', () {
    final original = SyncClientProfile(
      address: '100.64.0.2',
      port: 12688,
      fingerprintSha256: 'a' * 64,
      groupId: 'group-a',
      hostDevice: const SyncDeviceRegistration(
        deviceId: 'host',
        displayName: 'PC',
        platform: 'windows',
        appVersion: '1.0.8',
        publicKey: 'key',
      ),
    );
    final legacy = original.toJson()
      ..remove('savedEndpoints')
      ..remove('defaultEndpointId');
    final loaded = SyncClientProfile.fromJson(legacy);
    expect(loaded.savedEndpoints.single.id, loaded.baseUri.toString());
    expect(loaded.defaultEndpointId, loaded.baseUri.toString());
    final wlan = SyncSavedEndpoint(
      address: '100.81.1.2',
      port: 12688,
      label: 'WLAN',
    );
    final switched = loaded.copyWith(
      address: wlan.address,
      port: wlan.port,
      savedEndpoints: [...loaded.savedEndpoints, wlan, wlan],
    );
    final restored = SyncClientProfile.decode(switched.encode());
    expect(restored.savedEndpoints, hasLength(2));
    expect(restored.defaultEndpointId, loaded.defaultEndpointId);
    expect(restored.hostDevice.publicKey, loaded.hostDevice.publicKey);
    expect(restored.remoteCursor.toJson(), loaded.remoteCursor.toJson());
    expect(
      restored.copyWith(defaultEndpointId: wlan.id).defaultEndpointId,
      wlan.id,
    );
  });

  test('endpoint update QR round-trips identity and address without a pairing token', () {
    final now = DateTime.utc(2026, 10, 22, 12);
    final update = SyncEndpointUpdate(
      endpoint: SyncSavedEndpoint(
        address: '100.81.1.2',
        port: 12688,
        label: 'WLAN',
      ),
      groupId: 'group-a',
      hostDeviceId: 'host',
      fingerprintSha256: 'a' * 64,
      expiresAt: now.add(const Duration(minutes: 10)),
    );
    final uri = SyncEndpointUpdateCodec.encode(update);
    final parsed = SyncEndpointUpdateCodec.parse(uri.toString(), now: now);
    expect(parsed.endpoint.displayName, 'WLAN · 100.81.1.2:12688');
    expect(parsed.groupId, 'group-a');
    expect(parsed.hostDeviceId, 'host');
    expect(uri.queryParameters, isNot(contains('token')));
    for (final invalid in [
      uri.replace(userInfo: 'user'),
      uri.replace(port: 1234),
      uri.replace(path: '/other'),
      uri.replace(fragment: 'other'),
    ]) {
      expect(
        () => SyncEndpointUpdateCodec.parse(invalid.toString(), now: now),
        throwsFormatException,
      );
    }
    expect(
      () =>
          SyncEndpointUpdateCodec.parse(uri.toString(), now: update.expiresAt),
      throwsFormatException,
    );
    expect(
      () => SyncEndpointUpdateCodec.parse(
        uri
            .replace(queryParameters: {...uri.queryParameters, 'port': '0'})
            .toString(),
        now: now,
      ),
      throwsFormatException,
    );
    expect(
      () => SyncEndpointUpdateCodec.parse(
        uri
            .replace(
              queryParameters: {
                ...uri.queryParameters,
                'host': 'evil.example/path',
              },
            )
            .toString(),
        now: now,
      ),
      throwsFormatException,
    );
  });

  test('pairing URI accepts the versioned pinned host format', () {
    final token = SyncCrypto.randomToken();
    final endpoint = SyncPairingUriCodec.parse(
      'echoday://pair?v=1&host=100.64.0.2&port=45678&group=group-a'
      '&fingerprint=${'a' * 64}&invite=invite-a&token=$token',
    );

    expect(endpoint.address, '100.64.0.2');
    expect(endpoint.port, 45678);
    expect(endpoint.groupId, 'group-a');
    expect(endpoint.baseUri.scheme, 'https');
  });

  test('pairing URI rejects unknown schemes and weak tokens', () {
    expect(
      () => SyncPairingUriCodec.parse(
        'https://pair?v=1&host=127.0.0.1&port=1&group=g'
        '&fingerprint=${'a' * 64}&invite=i&token=weak',
      ),
      throwsFormatException,
    );
    expect(
      () => SyncPairingUriCodec.parse(
        'echoday://pair?v=1&host=127.0.0.1&port=1&group=g'
        '&fingerprint=${'a' * 64}&invite=i&token=weak',
      ),
      throwsFormatException,
    );
  });
}
