import 'package:echoday/src/features/sync/domain/sync_client_models.dart';
import 'package:echoday/src/features/sync/security/sync_crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
