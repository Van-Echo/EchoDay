import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/application/app_preferences.dart';
import '../providers/data_providers.dart';

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  StreamSubscription<dynamic>? _subscription;

  @override
  ThemeMode build() {
    final repository = ref.watch(settingsRepositoryProvider);
    _subscription = repository.watch(AppPreferenceKeys.themeMode).listen((
      setting,
    ) {
      state = ThemeMode.values.firstWhere(
        (mode) => mode.name == setting?.value,
        orElse: () => ThemeMode.system,
      );
    });
    ref.onDispose(() => unawaited(_subscription?.cancel()));
    return ThemeMode.system;
  }

  void setMode(ThemeMode mode) {
    state = mode;
    unawaited(
      ref
          .read(settingsRepositoryProvider)
          .set(AppPreferenceKeys.themeMode, mode.name),
    );
  }
}
