import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../features/settings/application/app_preferences.dart';
import 'platform/platform_capabilities.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_mode_controller.dart';
import 'widgets/app_lifecycle_refresh_host.dart';
import 'widgets/backup_lifecycle_host.dart';
import 'widgets/hotkey_host.dart';
import 'widgets/sync_client_lifecycle_host.dart';
import 'widgets/sync_desktop_lifecycle_host.dart';

class EchoDayApp extends ConsumerWidget {
  const EchoDayApp({super.key, this.locale});

  final Locale? locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final capabilities = ref.watch(platformCapabilitiesProvider);
    final themeMode = ref.watch(themeModeProvider);
    final appLanguage =
        ref.watch(appLanguageProvider).value ?? AppLanguage.chinese;
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
      locale: locale ?? Locale(appLanguage.languageCode),
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
      builder: (context, child) {
        Widget result = child ?? const SizedBox.shrink();
        if (capabilities.isAndroid) {
          final brightness = Theme.of(context).brightness;
          final iconBrightness = brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark;
          result = MediaQuery.removeViewPadding(
            context: context,
            removeLeft: true,
            removeTop: true,
            removeRight: true,
            removeBottom: true,
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: iconBrightness,
                systemNavigationBarColor: Colors.transparent,
                systemNavigationBarDividerColor: Colors.transparent,
                systemNavigationBarIconBrightness: iconBrightness,
              ),
              child: result,
            ),
          );
        }
        return SyncDesktopLifecycleHost(
          child: SyncClientLifecycleHost(
            child: BackupLifecycleHost(
              child: AppLifecycleRefreshHost(child: HotkeyHost(child: result)),
            ),
          ),
        );
      },
    );
  }
}
