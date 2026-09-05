import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/data_providers.dart';

abstract final class AppPreferenceKeys {
  static const themeMode = 'appearance.themeMode';
  static const primaryColor = 'appearance.primaryColor';
  static const motto = 'calendar.motto';
  static const mottoStyle = 'calendar.mottoStyle';
  static const calendarTodoFontSize = 'calendar.todoFontSize';
  static const sidebarTodoFontSize = 'todo.sidebarFontSize';
  static const dayTodoFontSize = 'todo.dayFontSize';
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
const defaultCalendarTodoFontSize = 11.0;
const defaultSidebarTodoFontSize = 14.0;
const defaultDayTodoFontSize = 14.0;
const defaultCalendarMottoColorValue = 0xFF8B8BF2;

final class CalendarMottoStyle {
  const CalendarMottoStyle({
    this.fontSize = 14,
    this.colorValue = defaultCalendarMottoColorValue,
    this.bold = false,
    this.italic = false,
    this.underline = false,
  });

  factory CalendarMottoStyle.fromJson(Object? source) {
    if (source is! Map<String, dynamic>) {
      return const CalendarMottoStyle();
    }
    final fontSize = source['fontSize'];
    final colorValue = source['colorValue'];
    return CalendarMottoStyle(
      fontSize: fontSize is num
          ? fontSize.toDouble().clamp(10.0, 28.0).toDouble()
          : 14,
      colorValue: colorValue is int
          ? colorValue
          : defaultCalendarMottoColorValue,
      bold: source['bold'] == true,
      italic: source['italic'] == true,
      underline: source['underline'] == true,
    );
  }

  final double fontSize;
  final int colorValue;
  final bool bold;
  final bool italic;
  final bool underline;

  CalendarMottoStyle copyWith({
    double? fontSize,
    int? colorValue,
    bool? bold,
    bool? italic,
    bool? underline,
  }) => CalendarMottoStyle(
    fontSize: fontSize ?? this.fontSize,
    colorValue: colorValue ?? this.colorValue,
    bold: bold ?? this.bold,
    italic: italic ?? this.italic,
    underline: underline ?? this.underline,
  );

  Map<String, Object> toJson() => {
    'fontSize': fontSize,
    'colorValue': colorValue,
    'bold': bold,
    'italic': italic,
    'underline': underline,
  };
}

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

final calendarMottoStyleProvider = StreamProvider<CalendarMottoStyle>((ref) {
  return ref
      .watch(settingsRepositoryProvider)
      .watch(AppPreferenceKeys.mottoStyle)
      .map((setting) {
        if (setting == null) return const CalendarMottoStyle();
        try {
          return CalendarMottoStyle.fromJson(jsonDecode(setting.value));
        } on FormatException {
          return const CalendarMottoStyle();
        }
      });
});

final calendarTodoFontSizeProvider = StreamProvider<double>((ref) {
  return ref
      .watch(settingsRepositoryProvider)
      .watch(AppPreferenceKeys.calendarTodoFontSize)
      .map(
        (setting) => _fontSize(
          setting?.value,
          fallback: defaultCalendarTodoFontSize,
          minimum: 9,
          maximum: 16,
        ),
      );
});

final sidebarTodoFontSizeProvider = StreamProvider<double>((ref) {
  return ref
      .watch(settingsRepositoryProvider)
      .watch(AppPreferenceKeys.sidebarTodoFontSize)
      .map(
        (setting) => _fontSize(
          setting?.value,
          fallback: defaultSidebarTodoFontSize,
          minimum: 12,
          maximum: 20,
        ),
      );
});

final dayTodoFontSizeProvider = StreamProvider<double>((ref) {
  return ref
      .watch(settingsRepositoryProvider)
      .watch(AppPreferenceKeys.dayTodoFontSize)
      .map(
        (setting) => _fontSize(
          setting?.value,
          fallback: defaultDayTodoFontSize,
          minimum: 12,
          maximum: 24,
        ),
      );
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

Future<void> setCalendarMottoStyle(WidgetRef ref, CalendarMottoStyle style) {
  return ref
      .read(settingsRepositoryProvider)
      .set(AppPreferenceKeys.mottoStyle, jsonEncode(style.toJson()));
}

Future<void> setTodoFontSize(WidgetRef ref, String key, double value) {
  return ref.read(settingsRepositoryProvider).set(key, '$value');
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

double _fontSize(
  String? source, {
  required double fallback,
  required double minimum,
  required double maximum,
}) {
  final parsed = double.tryParse(source ?? '');
  return parsed == null ? fallback : parsed.clamp(minimum, maximum).toDouble();
}
