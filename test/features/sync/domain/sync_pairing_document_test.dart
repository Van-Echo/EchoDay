import 'package:echoday/src/features/sync/domain/sync_client_models.dart';
import 'package:echoday/src/features/sync/domain/sync_pairing_document.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const uri =
      'echoday://pair?v=1&host=100.64.1.2&port=12380&group=group-1'
      '&fingerprint=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
      '&invite=invite-1&token=YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4';

  test('round trips a versioned pairing file and rejects expiry', () {
    final now = DateTime.utc(2026, 9, 9, 12);
    final encoded = SyncPairingDocumentCodec.encode(
      pairingUri: Uri.parse(uri),
      createdAt: now,
      expiresAt: now.add(const Duration(minutes: 5)),
    );
    expect(SyncPairingDocumentCodec.decode(encoded, now: now), uri);
    expect(
      () => SyncPairingDocumentCodec.decode(
        encoded,
        now: now.add(const Duration(minutes: 6)),
      ),
      throwsFormatException,
    );
  });

  test('accepts Tailscale MagicDNS names as a secure endpoint override', () {
    expect(
      SyncPairingUriCodec.normalizeHost('main-pc.tailnet-name.ts.net'),
      'main-pc.tailnet-name.ts.net',
    );
    expect(
      () => SyncPairingUriCodec.normalizeHost('https://bad.example/path'),
      throwsFormatException,
    );
  });
}
