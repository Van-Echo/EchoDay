import 'package:echoday/src/app/providers/data_providers.dart';
import 'package:echoday/src/features/settings/application/app_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/in_memory_settings_repository.dart';

void main() {
  for (final source in <String?>[
    null,
    '',
    '0',
    '-1',
    '3601',
    '1.5',
    'NaN',
    'abc',
    '1',
    '3600',
    '27',
  ]) {
    test('ticker interval validates saved value $source', () async {
      final settings = InMemorySettingsRepository();
      if (source != null) {
        await settings.set(
          AppPreferenceKeys.futureTodoTickerIntervalSeconds,
          source,
        );
      }
      final container = ProviderContainer(
        overrides: [settingsRepositoryProvider.overrideWithValue(settings)],
      );
      container.listen(futureTodoTickerIntervalSecondsProvider, (_, _) {});
      container.listen(futureTodoTickerNumberedProvider, (_, _) {});
      addTearDown(() async {
        container.dispose();
        await settings.dispose();
      });
      final parsed = int.tryParse(source ?? '');
      expect(
        await container.read(futureTodoTickerIntervalSecondsProvider.future),
        parsed != null && parsed >= 1 && parsed <= 3600 ? parsed : 4,
      );
      expect(
        await container.read(futureTodoTickerNumberedProvider.future),
        isFalse,
      );
    });
  }

  test(
    'ticker preferences are restored by a fresh provider container',
    () async {
      final settings = InMemorySettingsRepository();
      await settings.set(
        AppPreferenceKeys.futureTodoTickerIntervalSeconds,
        '12',
      );
      await settings.set(AppPreferenceKeys.futureTodoTickerNumbered, 'true');
      for (var attempt = 0; attempt < 2; attempt++) {
        final container = ProviderContainer(
          overrides: [settingsRepositoryProvider.overrideWithValue(settings)],
        );
        container.listen(futureTodoTickerIntervalSecondsProvider, (_, _) {});
        container.listen(futureTodoTickerNumberedProvider, (_, _) {});
        expect(
          await container.read(futureTodoTickerIntervalSecondsProvider.future),
          12,
        );
        expect(
          await container.read(futureTodoTickerNumberedProvider.future),
          isTrue,
        );
        container.dispose();
      }
      await settings.dispose();
    },
  );
}
