import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class DeviceSecretStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Uses Android encrypted storage and Windows Credential Manager-backed
/// encrypted storage through the platform plugin.
final class PlatformDeviceSecretStore implements DeviceSecretStore {
  const PlatformDeviceSecretStore({
    this.storage = const FlutterSecureStorage(),
  });

  final FlutterSecureStorage storage;

  @override
  Future<String?> read(String key) => storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => storage.delete(key: key);
}

final class MemoryDeviceSecretStore implements DeviceSecretStore {
  final Map<String, String> _values = {};

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;
}
