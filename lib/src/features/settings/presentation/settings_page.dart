import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../app/providers/data_providers.dart';
import '../../../app/theme/theme_mode_controller.dart';
import '../../../app/widgets/app_scaffold.dart';
import '../../backup/domain/backup_repository.dart';
import '../../calendar/application/calendar_controller.dart';
import '../../holidays/domain/holiday_year.dart';
import '../../todos/application/todo_providers.dart';
import '../../todos/domain/todo_sort.dart';
import '../application/app_preferences.dart';
import '../application/hotkey_preferences.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  var _refreshingHolidays = false;
  late int _selectedHolidayYear;
  final _mottoController = TextEditingController();
  var _mottoLoaded = false;
  var _backupBusy = false;

  @override
  void initState() {
    super.initState();
    _selectedHolidayYear = DateTime.now().year;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(calendarControllerProvider.notifier).loadPreferences();
    });
  }

  @override
  void dispose() {
    _mottoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final primaryColorValue =
        ref.watch(primaryColorProvider).value ?? defaultPrimaryColorValue;
    final calendarState = ref.watch(calendarControllerProvider);
    final sortMode =
        ref.watch(todoSortModeProvider).value ?? TodoSortMode.composite;
    final years = ref.watch(holidayAvailableYearsProvider);
    final currentYear = DateTime.now().year;
    final holidayYear = ref.watch(holidayYearProvider(_selectedHolidayYear));
    final motto = ref.watch(calendarMottoProvider);
    if (!_mottoLoaded && motto.hasValue) {
      _mottoController.text = motto.value ?? defaultCalendarMotto;
      _mottoLoaded = true;
    }
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
              _ExpandableSettingsCard(
                key: const ValueKey('theme-settings'),
                icon: Icons.palette_outlined,
                title: localizations.themeModeLabel,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
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
                    const SizedBox(height: 20),
                    Text(
                      localizations.primaryColorLabel,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final value in _primaryColorOptions)
                          ChoiceChip(
                            key: ValueKey('primary-color-$value'),
                            label: const SizedBox(width: 20),
                            avatar: CircleAvatar(backgroundColor: Color(value)),
                            selected: primaryColorValue == value,
                            onSelected: (_) => ref
                                .read(settingsRepositoryProvider)
                                .set(AppPreferenceKeys.primaryColor, '$value'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ExpandableSettingsCard(
                key: const ValueKey('calendar-task-settings'),
                icon: Icons.view_week_outlined,
                title: localizations.calendarTaskSettingsTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(localizations.calendarPreviewLabel),
                        ),
                        Text(
                          localizations.calendarPreviewValue(
                            calendarState.previewLimit,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      key: const ValueKey('calendar-preview-slider'),
                      value: calendarState.previewLimit.toDouble(),
                      min: 1,
                      max: 12,
                      divisions: 11,
                      label: '${calendarState.previewLimit}',
                      onChanged: (value) => ref
                          .read(calendarControllerProvider.notifier)
                          .setPreviewLimit(value.round()),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TodoSortMode>(
                      key: const ValueKey('default-sort-field'),
                      initialValue: sortMode,
                      decoration: InputDecoration(
                        labelText: localizations.defaultSortLabel,
                      ),
                      items: [
                        for (final mode in TodoSortMode.values)
                          DropdownMenuItem(
                            value: mode,
                            child: Text(_sortName(localizations, mode)),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) setTodoSortMode(ref, value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ExpandableSettingsCard(
                key: const ValueKey('hotkey-settings'),
                icon: Icons.keyboard_outlined,
                title: localizations.hotkeysTitle,
                child: Column(
                  children: [
                    _HotkeySettingRow(
                      action: AppHotkeyAction.summon,
                      label: localizations.summonHotkey,
                    ),
                    const Divider(height: 20),
                    _HotkeySettingRow(
                      action: AppHotkeyAction.today,
                      label: localizations.todayHotkey,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ExpandableSettingsCard(
                key: const ValueKey('backup-settings'),
                icon: Icons.security_outlined,
                title: localizations.dataSafetyTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(localizations.dataSafetyDescription),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          key: const ValueKey('export-backup-button'),
                          onPressed: _backupBusy ? null : _exportBackup,
                          icon: const Icon(Icons.download_outlined),
                          label: Text(localizations.exportBackup),
                        ),
                        OutlinedButton.icon(
                          key: const ValueKey('import-backup-button'),
                          onPressed: _backupBusy ? null : _importBackup,
                          icon: const Icon(Icons.upload_file_outlined),
                          label: Text(localizations.importBackup),
                        ),
                        if (_backupBusy)
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ExpandableSettingsCard(
                key: const ValueKey('motto-settings'),
                icon: Icons.chat_bubble_outline_rounded,
                title: localizations.mottoTitle,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        key: const ValueKey('motto-field'),
                        controller: _mottoController,
                        maxLength: 80,
                        minLines: 2,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: localizations.mottoLabel,
                          alignLabelWithHint: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                        ),
                        onSubmitted: (_) => _saveMotto(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _saveMotto,
                      icon: const Icon(Icons.save_outlined),
                      label: Text(localizations.save),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ExpandableSettingsCard(
                key: const ValueKey('holiday-settings'),
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

  Future<void> _exportBackup() async {
    const typeGroup = XTypeGroup(
      label: 'EchoDay JSON backup',
      extensions: ['json'],
    );
    final location = await getSaveLocation(
      suggestedName: standardBackupFileName(DateTime.now()),
      acceptedTypeGroups: const [typeGroup],
    );
    if (location == null || !mounted) return;
    setState(() => _backupBusy = true);
    try {
      await ref.read(backupRepositoryProvider).exportTo(location.path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).backupExported)),
      );
    } on Object catch (error) {
      _showBackupError(error);
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  Future<void> _importBackup() async {
    const typeGroup = XTypeGroup(
      label: 'EchoDay JSON backup',
      extensions: ['json'],
    );
    final file = await openFile(acceptedTypeGroups: const [typeGroup]);
    if (file == null || !mounted) return;
    setState(() => _backupBusy = true);
    try {
      final repository = ref.read(backupRepositoryProvider);
      final preview = await repository.inspect(file.path);
      if (!mounted) return;
      if (!preview.isValid) {
        final strings = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.backupInvalid(preview.error ?? 'Unknown')),
          ),
        );
        return;
      }
      final choice = await _showImportPreview(preview);
      if (choice == null || !mounted) return;
      if (choice == _ImportChoice.replace && !await _confirmReplace()) return;
      final result = switch (choice) {
        _ImportChoice.merge => await repository.merge(file.path),
        _ImportChoice.replace => await repository.replace(file.path),
      };
      if (!mounted) return;
      ref.invalidate(calendarControllerProvider);
      ref.invalidate(themeModeProvider);
      ref.invalidate(primaryColorProvider);
      ref.invalidate(todoSortModeProvider);
      final strings = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.backupImportCompleted(
              result.importedCount,
              result.skippedCount,
            ),
          ),
        ),
      );
      if (result.safetyBackupPath case final path?) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.backupSafetyCreated(path))),
        );
      }
    } on Object catch (error) {
      _showBackupError(error);
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  Future<_ImportChoice?> _showImportPreview(ImportPreview preview) {
    final strings = AppLocalizations.of(context);
    final exported = preview.exportedAt?.toLocal();
    final exportedText = exported == null
        ? '-'
        : '${exported.year}-${_two(exported.month)}-${_two(exported.day)} '
              '${_two(exported.hour)}:${_two(exported.minute)}';
    return showDialog<_ImportChoice>(
      context: context,
      builder: (context) => AlertDialog(
        key: const ValueKey('backup-preview-dialog'),
        title: Text(strings.backupPreviewTitle),
        content: Text(
          strings.backupPreviewBody(
            preview.formatVersion,
            preview.appVersion ?? '-',
            exportedText,
            preview.todoCount,
            preview.totalRecordCount,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, _ImportChoice.merge),
            child: Text(strings.mergeImport),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _ImportChoice.replace),
            child: Text(strings.replaceRestore),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmReplace() async {
    final strings = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            key: const ValueKey('replace-backup-confirm-dialog'),
            title: Text(strings.replaceConfirmTitle),
            content: Text(strings.replaceConfirmBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(strings.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(strings.replaceConfirmAction),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showBackupError(Object error) {
    if (!mounted) return;
    final strings = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.backupOperationFailed('$error'))),
    );
  }

  Future<void> _saveMotto() async {
    await ref
        .read(settingsRepositoryProvider)
        .set(AppPreferenceKeys.motto, _mottoController.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).mottoSaved)),
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

enum _ImportChoice { merge, replace }

const _primaryColorOptions = <int>[
  0xFF788C77,
  0xFF667E8C,
  0xFF8A7F9F,
  0xFFA06C78,
  0xFF9A795F,
  0xFF6F817B,
];

String _two(int value) => value.toString().padLeft(2, '0');

String _sortName(AppLocalizations strings, TodoSortMode mode) {
  return switch (mode) {
    TodoSortMode.manual => strings.sortManual,
    TodoSortMode.createdAtAscending => strings.sortCreatedAscending,
    TodoSortMode.createdAtDescending => strings.sortCreatedDescending,
    TodoSortMode.plannedTime => strings.sortPlannedTime,
    TodoSortMode.priority => strings.sortPriority,
    TodoSortMode.composite => strings.sortComposite,
  };
}

class _ExpandableSettingsCard extends StatelessWidget {
  const _ExpandableSettingsCard({
    required this.icon,
    required this.title,
    required this.child,
    super.key,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        childrenPadding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        children: [child],
      ),
    );
  }
}

class _HotkeySettingRow extends ConsumerWidget {
  const _HotkeySettingRow({required this.action, required this.label});

  final AppHotkeyAction action;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hotkey =
        ref.watch(hotkeyPreferenceProvider(action)).value ??
        defaultHotkey(action);
    return Row(
      children: [
        Expanded(child: Text(label)),
        HotKeyVirtualView(hotKey: hotkey),
        const SizedBox(width: 8),
        IconButton.outlined(
          tooltip: AppLocalizations.of(context).editHotkey,
          onPressed: () => _edit(context, ref, hotkey),
          icon: const Icon(Icons.edit_outlined),
        ),
      ],
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    HotKey initial,
  ) async {
    var selected = initial;
    final strings = AppLocalizations.of(context);
    final result = await showDialog<HotKey>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(strings.editHotkey),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(strings.recordHotkeyHint),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: HotKeyRecorder(
                  initalHotKey: selected,
                  onHotKeyRecorded: (hotkey) {
                    selected = hotkey;
                    setDialogState(() {});
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, selected),
              child: Text(strings.save),
            ),
          ],
        ),
      ),
    );
    if (result != null) await saveHotkey(ref, action, result);
  }
}
