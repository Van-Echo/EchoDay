import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import 'device_secret_store.dart';

final class DeviceIdentity {
  const DeviceIdentity({
    required this.deviceId,
    required this.publicKeyBase64Url,
    required this.privateKeyBase64Url,
  });

  final String deviceId;
  final String publicKeyBase64Url;
  final String privateKeyBase64Url;
}

final class DeviceIdentityStore {
  const DeviceIdentityStore(this._secrets);

  static const _deviceIdKey = 'sync.device.id';
  static const _publicKeyKey = 'sync.device.ed25519.public';
  static const _privateKeyKey = 'sync.device.ed25519.private';

  final DeviceSecretStore _secrets;

  Future<DeviceIdentity> loadOrCreate(String Function() newDeviceId) async {
    final deviceId = await _secrets.read(_deviceIdKey);
    final publicKey = await _secrets.read(_publicKeyKey);
    final privateKey = await _secrets.read(_privateKeyKey);
    if (deviceId != null && publicKey != null && privateKey != null) {
      return DeviceIdentity(
        deviceId: deviceId,
        publicKeyBase64Url: publicKey,
        privateKeyBase64Url: privateKey,
      );
    }
    if (deviceId != null || publicKey != null || privateKey != null) {
      await _secrets.delete(_deviceIdKey);
      await _secrets.delete(_publicKeyKey);
      await _secrets.delete(_privateKeyKey);
    }
    final keyPair = await Ed25519().newKeyPair();
    final privateBytes = await keyPair.extractPrivateKeyBytes();
    final generatedPublicKey = await keyPair.extractPublicKey();
    final generated = DeviceIdentity(
      deviceId: newDeviceId(),
      publicKeyBase64Url: _encode(generatedPublicKey.bytes),
      privateKeyBase64Url: _encode(privateBytes),
    );
    await _secrets.write(_deviceIdKey, generated.deviceId);
    await _secrets.write(_publicKeyKey, generated.publicKeyBase64Url);
    try {
      await _secrets.write(_privateKeyKey, generated.privateKeyBase64Url);
    } on Object {
      await _secrets.delete(_deviceIdKey);
      await _secrets.delete(_publicKeyKey);
      rethrow;
    }
    return generated;
  }

  Future<String> sign(DeviceIdentity identity, String message) async {
    final publicBytes = base64Url.decode(
      base64Url.normalize(identity.publicKeyBase64Url),
    );
    final privateBytes = base64Url.decode(
      base64Url.normalize(identity.privateKeyBase64Url),
    );
    final signature = await Ed25519().sign(
      utf8.encode(message),
      keyPair: SimpleKeyPairData(
        privateBytes,
        publicKey: SimplePublicKey(publicBytes, type: KeyPairType.ed25519),
        type: KeyPairType.ed25519,
      ),
    );
    return _encode(signature.bytes);
  }

  static String _encode(List<int> value) =>
      base64UrlEncode(value).replaceAll('=', '');
}
