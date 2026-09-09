import 'package:echoday/l10n/app_localizations.dart';
import 'package:echoday/src/app/platform/platform_capabilities.dart';
import 'package:echoday/src/features/sync/application/sync_client_controller.dart';
import 'package:echoday/src/features/sync/presentation/sync_client_settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final class _DisconnectedSyncClientController extends SyncClientController {
  @override
  SyncClientViewState build() => const SyncClientViewState(loaded: true);

  @override
  Future<void> initialize({bool synchronizeOnLoad = true}) async {}
}

void main() {
  testWidgets('Android settings offer opt-in scan and paste pairing', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          platformCapabilitiesProvider.overrideWithValue(
            const PlatformCapabilities(isAndroid: true, isWindows: false),
          ),
          syncClientControllerProvider.overrideWith(
            _DisconnectedSyncClientController.new,
          ),
        ],
        child: const MaterialApp(
          locale: Locale('zh'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(child: SyncClientSettingsSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('尚未连接同步主机'), findsOneWidget);
    expect(find.byKey(const ValueKey('sync-scan-qr')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('sync-pairing-code-input')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('sync-connect-code')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Windows client offers pairing file and endpoint override', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          platformCapabilitiesProvider.overrideWithValue(
            const PlatformCapabilities(isAndroid: false, isWindows: true),
          ),
          syncClientControllerProvider.overrideWith(
            _DisconnectedSyncClientController.new,
          ),
        ],
        child: const MaterialApp(
          locale: Locale('zh'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(child: SyncClientSettingsSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('sync-scan-qr')), findsNothing);
    expect(find.byKey(const ValueKey('sync-discover-nearby')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('sync-import-pairing-file')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('sync-host-override')), findsOneWidget);
    expect(find.byKey(const ValueKey('sync-port-override')), findsOneWidget);
    expect(find.byKey(const ValueKey('sync-connect-code')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Windows client controls fit a narrow 200% text layout', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(440, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          platformCapabilitiesProvider.overrideWithValue(
            const PlatformCapabilities(isAndroid: false, isWindows: true),
          ),
          syncClientControllerProvider.overrideWith(
            _DisconnectedSyncClientController.new,
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: const Scaffold(
                body: SingleChildScrollView(
                  padding: EdgeInsets.all(12),
                  child: SyncClientSettingsSection(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('sync-host-override')), findsOneWidget);
    expect(find.byKey(const ValueKey('sync-port-override')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
