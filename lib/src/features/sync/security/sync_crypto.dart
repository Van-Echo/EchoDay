import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart' as hashes;
import 'package:cryptography/cryptography.dart';

abstract final class SyncCrypto {
  static final Random _random = Random.secure();
  static final Ed25519 _signatures = Ed25519();

  static String randomToken({int bytes = 32}) {
    if (bytes < 16) throw ArgumentError.value(bytes, 'bytes');
    return base64UrlEncode(
      List<int>.generate(bytes, (_) => _random.nextInt(256)),
    ).replaceAll('=', '');
  }

  static String sha256Text(String value) =>
      hashes.sha256.convert(utf8.encode(value)).toString();

  static String sha256Bytes(List<int> value) =>
      hashes.sha256.convert(value).toString();

  static List<int> decodeBase64Url(String value) {
    try {
      return base64Url.decode(base64Url.normalize(value));
    } on FormatException {
      throw const FormatException('Invalid base64url value.');
    }
  }

  static Future<bool> verifyEd25519({
    required String publicKeyBase64Url,
    required String signatureBase64Url,
    required String message,
  }) async {
    final publicKeyBytes = decodeBase64Url(publicKeyBase64Url);
    final signatureBytes = decodeBase64Url(signatureBase64Url);
    if (publicKeyBytes.length != 32 || signatureBytes.length != 64) {
      return false;
    }
    return _signatures.verify(
      utf8.encode(message),
      signature: Signature(
        signatureBytes,
        publicKey: SimplePublicKey(publicKeyBytes, type: KeyPairType.ed25519),
      ),
    );
  }

  static bool constantTimeEquals(String left, String right) {
    final a = utf8.encode(left);
    final b = utf8.encode(right);
    if (a.isEmpty || b.isEmpty) return a.isEmpty && b.isEmpty;
    var difference = a.length ^ b.length;
    final length = a.length > b.length ? a.length : b.length;
    for (var index = 0; index < length; index++) {
      difference |= a[index % a.length] ^ b[index % b.length];
    }
    return difference == 0;
  }
}
