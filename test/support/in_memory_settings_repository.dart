import 'dart:async';

import 'package:echoday/src/features/settings/domain/app_setting.dart';

final class InMemorySettingsRepository implements SettingsRepository {
  final Map<String, AppSetting> _values = {};
  final Map<String, StreamController<AppSetting?>> _controllers = {};

  @override
  Future<AppSetting?> get(String key) async => _values[key];

  @override
  Future<void> remove(String key) async {
    _values.remove(key);
    _controllers[key]?.add(null);
  }

  @override
  Future<void> set(String key, String value) async {
    final previous = _values[key];
    _values[key] = AppSetting(
      key: key,
      value: value,
      updatedAt: DateTime.now().toUtc(),
      revision: (previous?.revision ?? 0) + 1,
    );
    _controllers[key]?.add(_values[key]);
  }

  @override
  Stream<AppSetting?> watch(String key) async* {
    yield _values[key];
    yield* _controllers
        .putIfAbsent(key, StreamController<AppSetting?>.broadcast)
        .stream;
  }

  Future<void> dispose() async {
    for (final controller in _controllers.values) {
      await controller.close();
    }
  }
}
