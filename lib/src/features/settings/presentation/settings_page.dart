import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../app/providers/data_providers.dart';
import '../../../app/theme/theme_mode_controller.dart';
import '../../../app/widgets/app_scaffold.dart';
import '../../holidays/domain/holiday_year.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  var _refreshingHolidays = false;
  late int _selectedHolidayYear;

  @override
  void initState() {
    super.initState();
    _selectedHolidayYear = DateTime.now().year;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final years = ref.watch(holidayAvailableYearsProvider);
    final currentYear = DateTime.now().year;
    final holidayYear = ref.watch(holidayYearProvider(_selectedHolidayYear));
    final availableYears = years.value?.toList() ?? <int>[];
    availableYears.sort();
    final updateYears = {
      ...availableYears,
      currentYear,
      currentYear + 1,
    }.toList()..sort();

    return AppScaffold(
      selectedIndex: 3,
      title: localizations.settingsTitle,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _SettingsCard(
                icon: Icons.palette_outlined,
                title: localizations.themeModeLabel,
                child: Semantics(
                  label: localizations.themeModeLabel,
                  child: SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text(localizations.themeSystem),
                        icon: const Icon(Icons.brightness_auto_rounded),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text(localizations.themeLight),
                        icon: const Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text(localizations.themeDark),
                        icon: const Icon(Icons.dark_mode_outlined),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (selection) {
                      ref
                          .read(themeModeProvider.notifier)
                          .setMode(selection.single);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                icon: Icons.event_available_outlined,
                title: localizations.holidayDataTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.holidayCoverage(
                        availableYears.isEmpty ? '—' : availableYears.join('、'),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      localizations.holidaySource(
                        holidayYear.value?.dataVersion ?? '—',
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: 160,
                          child: DropdownButtonFormField<int>(
                            initialValue: _selectedHolidayYear,
                            decoration: InputDecoration(
                              labelText: localizations.holidayYearLabel,
                            ),
                            items: [
                              for (final year in updateYears)
                                DropdownMenuItem(
                                  value: year,
                                  child: Text('$year'),
                                ),
                            ],
                            onChanged: _refreshingHolidays
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setState(
                                        () => _selectedHolidayYear = value,
                                      );
                                    }
                                  },
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _refreshingHolidays
                              ? null
                              : () => _refreshHolidays(_selectedHolidayYear),
                          icon: _refreshingHolidays
                              ? const SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.sync_rounded),
                          label: Text(localizations.checkHolidayUpdates),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshHolidays(int year) async {
    setState(() => _refreshingHolidays = true);
    try {
      final result = await ref.read(holidayRepositoryProvider).refresh(year);
      if (!mounted) return;
      final strings = AppLocalizations.of(context);
      final message = switch (result.status) {
        HolidayRefreshStatus.updated => strings.holidayUpdated,
        HolidayRefreshStatus.unchanged => strings.holidayUnchanged,
        HolidayRefreshStatus.unavailable =>
          result.year == null
              ? strings.holidayUpdateFailed
              : strings.holidayUpdateLocalFallback,
        HolidayRefreshStatus.failedValidation =>
          strings.holidayValidationFailed,
      };
      ref.invalidate(holidayYearProvider(year));
      ref.invalidate(holidayAvailableYearsProvider);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _refreshingHolidays = false);
    }
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
