import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:crypto/crypto.dart';

import 'device_secret_store.dart';

final class HostTlsIdentity {
  const HostTlsIdentity({
    required this.certificatePem,
    required this.privateKeyPem,
    required this.fingerprintSha256,
  });

  final String certificatePem;
  final String privateKeyPem;
  final String fingerprintSha256;
}

final class HostTlsIdentityStore {
  const HostTlsIdentityStore(this._secrets);

  static const _certificateKey = 'sync.host.tls.certificatePem';
  static const _privateKeyKey = 'sync.host.tls.privateKeyPem';

  final DeviceSecretStore _secrets;

  Future<HostTlsIdentity> loadOrCreate() async {
    final certificate = await _secrets.read(_certificateKey);
    final privateKey = await _secrets.read(_privateKeyKey);
    if (certificate != null && privateKey != null) {
      return HostTlsIdentity(
        certificatePem: certificate,
        privateKeyPem: privateKey,
        fingerprintSha256: certificateFingerprint(certificate),
      );
    }
    if (certificate != null || privateKey != null) {
      await _secrets.delete(_certificateKey);
      await _secrets.delete(_privateKeyKey);
    }
    final identity = await Isolate.run(_generateHostTlsIdentity);
    await _secrets.write(_certificateKey, identity.certificatePem);
    try {
      await _secrets.write(_privateKeyKey, identity.privateKeyPem);
    } on Object {
      await _secrets.delete(_certificateKey);
      rethrow;
    }
    return identity;
  }

  static String certificateFingerprint(String certificatePem) {
    final der = _pemBytes(certificatePem, 'CERTIFICATE');
    return sha256.convert(der).toString();
  }

  static Uint8List _pemBytes(String pem, String label) {
    final body = pem
        .replaceAll('-----BEGIN $label-----', '')
        .replaceAll('-----END $label-----', '')
        .replaceAll(RegExp(r'\s'), '');
    try {
      return Uint8List.fromList(base64.decode(body));
    } on FormatException {
      throw StateError('Stored TLS certificate is invalid.');
    }
  }
}

HostTlsIdentity _generateHostTlsIdentity() {
  final pair = CryptoUtils.generateRSAKeyPair(keySize: 2048);
  final privateKey = pair.privateKey as RSAPrivateKey;
  final publicKey = pair.publicKey as RSAPublicKey;
  final csr = X509Utils.generateRsaCsrPem(
    const {'CN': 'localhost'},
    privateKey,
    publicKey,
  );
  final certificate = X509Utils.generateSelfSignedCertificate(
    privateKey,
    csr,
    3650,
    issuer: const {'CN': 'localhost'},
  );
  final privatePem = CryptoUtils.encodeRSAPrivateKeyToPemPkcs1(privateKey);
  return HostTlsIdentity(
    certificatePem: certificate,
    privateKeyPem: privatePem,
    fingerprintSha256: HostTlsIdentityStore.certificateFingerprint(certificate),
  );
}
