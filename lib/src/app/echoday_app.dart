import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../features/settings/application/app_preferences.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_mode_controller.dart';
import 'widgets/hotkey_host.dart';

class EchoDayApp extends ConsumerWidget {
  const EchoDayApp({super.key, this.locale});

  final Locale? locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final primaryColorValue =
        ref.watch(primaryColorProvider).value ?? defaultPrimaryColorValue;
    final lightPrimary = Color(primaryColorValue);
    final darkPrimary = HSLColor.fromColor(lightPrimary)
        .withLightness(0.66)
        .withSaturation(
          (HSLColor.fromColor(lightPrimary).saturation * 0.72).clamp(0, 1),
        )
        .toColor();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      locale: locale,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightWith(lightPrimary),
      darkTheme: AppTheme.darkWith(darkPrimary),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) =>
          HotkeyHost(child: child ?? const SizedBox.shrink()),
    );
  }
}
