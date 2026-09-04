import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/data_providers.dart';

abstract final class AppPreferenceKeys {
  static const themeMode = 'appearance.themeMode';
  static const primaryColor = 'appearance.primaryColor';
  static const motto = 'calendar.motto';
  static const postponeDays = 'todo.postponeDays';
  static const catalogPalette = 'catalog.colorPalette';
}

const defaultPrimaryColorValue = 0xFF788C77;

final primaryColorProvider = StreamProvider<int>((ref) {
  return ref
      .watch(settingsRepositoryProvider)
      .watch(AppPreferenceKeys.primaryColor)
      .map((setting) {
        final value = int.tryParse(setting?.value ?? '');
        return value == null || value < 0 || value > 0xFFFFFFFF
            ? defaultPrimaryColorValue
            : value;
      });
});

const defaultCalendarMotto = '请支持丸一口喵~谢谢喵~';
const defaultCatalogPalette = <int>[
  0xFF7D8F7A,
  0xFF8A7F9F,
  0xFFB07D62,
  0xFF557C8B,
  0xFFA06C78,
  0xFF8C8665,
];

final calendarMottoProvider = StreamProvider<String>((ref) {
  return ref
      .watch(settingsRepositoryProvider)
      .watch(AppPreferenceKeys.motto)
      .map((setting) => setting?.value ?? defaultCalendarMotto);
});

final postponeDaysProvider = StreamProvider<int>((ref) {
  return ref
      .watch(settingsRepositoryProvider)
      .watch(AppPreferenceKeys.postponeDays)
      .map(
        (setting) => (int.tryParse(setting?.value ?? '') ?? 1).clamp(1, 365),
      );
});

final catalogPaletteProvider = StreamProvider<List<int>>((ref) {
  return ref
      .watch(settingsRepositoryProvider)
      .watch(AppPreferenceKeys.catalogPalette)
      .map((setting) {
        if (setting == null) return defaultCatalogPalette;
        try {
          final decoded = jsonDecode(setting.value);
          if (decoded is! List) return defaultCatalogPalette;
          final values = decoded.whereType<int>().toSet().toList();
          return values.isEmpty ? defaultCatalogPalette : values;
        } on FormatException {
          return defaultCatalogPalette;
        }
      });
});

Future<void> setCalendarMotto(Ref ref, String value) {
  return ref
      .read(settingsRepositoryProvider)
      .set(AppPreferenceKeys.motto, value.trim());
}

Future<void> setPostponeDays(Ref ref, int days) {
  return ref
      .read(settingsRepositoryProvider)
      .set(AppPreferenceKeys.postponeDays, '${days.clamp(1, 365)}');
}

Future<void> setCatalogPalette(Ref ref, List<int> colors) {
  final normalized = colors.toSet().toList();
  return ref
      .read(settingsRepositoryProvider)
      .set(AppPreferenceKeys.catalogPalette, jsonEncode(normalized));
}
