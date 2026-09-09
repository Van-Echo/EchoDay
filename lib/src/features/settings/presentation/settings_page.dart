import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../app/platform/platform_capabilities.dart';
import '../../../app/providers/data_providers.dart';
import '../../../app/theme/theme_mode_controller.dart';
import '../../../app/widgets/app_scaffold.dart';
import '../../../app/widgets/echoday_color_picker.dart';
import '../../backup/application/backup_preferences.dart';
import '../../backup/domain/backup_preferences.dart';
import '../../backup/domain/backup_repository.dart';
import '../../calendar/application/calendar_controller.dart';
import '../../holidays/domain/holiday_year.dart';
import '../../sync/presentation/sync_client_settings_section.dart';
import '../../sync/presentation/sync_host_settings_section.dart';
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
    final language =
        ref.watch(appLanguageProvider).value ?? AppLanguage.chinese;
    final capabilities = ref.watch(platformCapabilitiesProvider);
    final isAndroid = capabilities.isAndroid;
    final compact = MediaQuery.sizeOf(context).width < 600;
    final backupDirectory = ref.watch(backupDirectoryPreferenceProvider).value;
    final backupDirectoryResolution = ref
        .watch(backupDirectoryResolutionProvider)
        .value;
    final automaticBackupEnabled =
        ref.watch(automaticBackupEnabledProvider).value ??
        defaultAutomaticBackupEnabled;
    final automaticBackupRetention =
        ref.watch(automaticBackupRetentionCountProvider).value ??
        defaultAutomaticBackupRetentionCount;
    final primaryColorValue =
        ref.watch(primaryColorProvider).value ?? defaultPrimaryColorValue;
    final calendarState = ref.watch(calendarControllerProvider);
    final sortMode =
        ref.watch(todoSortModeProvider).value ?? TodoSortMode.composite;
    final calendarTodoFontSize =
        ref.watch(calendarTodoFontSizeProvider).value ??
        defaultCalendarTodoFontSize;
    final androidExpandTodayByDefault =
        ref.watch(androidExpandTodayByDefaultProvider).value ?? false;
    final sidebarTodoFontSize =
        ref.watch(sidebarTodoFontSizeProvider).value ??
        defaultSidebarTodoFontSize;
    final years = ref.watch(holidayAvailableYearsProvider);
    final currentYear = DateTime.now().year;
    final holidayYear = ref.watch(holidayYearProvider(_selectedHolidayYear));
    final motto = ref.watch(calendarMottoProvider);
    final mottoStyle =
        ref.watch(calendarMottoStyleProvider).value ??
        const CalendarMottoStyle();
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
            padding: EdgeInsets.all(compact ? 12 : 24),
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
                      child: compact
                          ? Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _ThemeChoice(
                                  value: ThemeMode.system,
                                  selected: themeMode,
                                  icon: Icons.brightness_auto_rounded,
                                  label: localizations.themeSystem,
                                ),
                                _ThemeChoice(
                                  value: ThemeMode.light,
                                  selected: themeMode,
                                  icon: Icons.light_mode_outlined,
                                  label: localizations.themeLight,
                                ),
                                _ThemeChoice(
                                  value: ThemeMode.dark,
                                  selected: themeMode,
                                  icon: Icons.dark_mode_outlined,
                                  label: localizations.themeDark,
                                ),
                              ],
                            )
                          : SegmentedButton<ThemeMode>(
                              segments: [
                                ButtonSegment(
                                  value: ThemeMode.system,
                                  label: Text(localizations.themeSystem),
                                  icon: const Icon(
                                    Icons.brightness_auto_rounded,
                                  ),
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
                key: const ValueKey('language-settings'),
                icon: Icons.language_rounded,
                title: localizations.languageLabel,
                child: Semantics(
                  label: localizations.languageLabel,
                  child: compact
                      ? Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: Text(localizations.languageChinese),
                              selected: language == AppLanguage.chinese,
                              onSelected: (_) =>
                                  setAppLanguage(ref, AppLanguage.chinese),
                            ),
                            ChoiceChip(
                              label: Text(localizations.languageEnglish),
                              selected: language == AppLanguage.english,
                              onSelected: (_) =>
                                  setAppLanguage(ref, AppLanguage.english),
                            ),
                          ],
                        )
                      : SegmentedButton<AppLanguage>(
                          segments: [
                            ButtonSegment(
                              value: AppLanguage.chinese,
                              label: Text(localizations.languageChinese),
                            ),
                            ButtonSegment(
                              value: AppLanguage.english,
                              label: Text(localizations.languageEnglish),
                            ),
                          ],
                          selected: {language},
                          onSelectionChanged: (selection) =>
                              setAppLanguage(ref, selection.single),
                        ),
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
                    if (compact)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(localizations.calendarPreviewLabel),
                          const SizedBox(height: 4),
                          Text(
                            localizations.calendarPreviewValue(
                              calendarState.previewLimit,
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      )
                    else
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
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _FontSizeDropdown(
                          key: const ValueKey('calendar-todo-font-size'),
                          label: localizations.calendarTodoFontSizeLabel,
                          value: calendarTodoFontSize,
                          values: const [
                            5,
                            6,
                            7,
                            8,
                            9,
                            10,
                            11,
                            12,
                            13,
                            14,
                            15,
                            16,
                          ],
                          onChanged: (value) => setTodoFontSize(
                            ref,
                            AppPreferenceKeys.calendarTodoFontSize,
                            value,
                          ),
                        ),
                        _FontSizeDropdown(
                          key: const ValueKey('sidebar-todo-font-size'),
                          label: localizations.sidebarTodoFontSizeLabel,
                          value: sidebarTodoFontSize,
                          values: const [12, 13, 14, 15, 16, 17, 18, 19, 20],
                          onChanged: (value) => setTodoFontSize(
                            ref,
                            AppPreferenceKeys.sidebarTodoFontSize,
                            value,
                          ),
                        ),
                      ],
                    ),
                    if (isAndroid) ...[
                      const SizedBox(height: 8),
                      SwitchListTile.adaptive(
                        key: const ValueKey('android-expand-today-by-default'),
                        contentPadding: EdgeInsets.zero,
                        title: Text(localizations.expandTodayByDefault),
                        value: androidExpandTodayByDefault,
                        onChanged: (value) =>
                            setAndroidExpandTodayByDefault(ref, value),
                      ),
                    ],
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TodoSortMode>(
                      key: const ValueKey('default-sort-field'),
                      initialValue: sortMode,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: localizations.defaultSortLabel,
                      ),
                      items: [
                        for (final mode in TodoSortMode.values)
                          DropdownMenuItem(
                            value: mode,
                            child: Text(
                              _sortName(localizations, mode),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) setTodoSortMode(ref, value);
                      },
                    ),
                  ],
                ),
              ),
              if (capabilities.supportsGlobalHotkeys) ...[
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
                      const Divider(height: 20),
                      _HotkeySettingRow(
                        action: AppHotkeyAction.addTodo,
                        label: localizations.addTodoHotkey,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _ExpandableSettingsCard(
                key: const ValueKey('backup-settings'),
                icon: Icons.security_outlined,
                title: localizations.dataSafetyTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(localizations.dataSafetyDescription),
                    if (!isAndroid) ...[
                      const SizedBox(height: 18),
                      Text(
                        localizations.defaultBackupDirectoryTitle,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        backupDirectory ??
                            backupDirectoryResolution?.effectiveRoot.path ??
                            localizations.backupDirectorySystemDefault,
                        key: const ValueKey('backup-directory-path'),
                      ),
                      if (backupDirectoryResolution?.usesFallback ?? false) ...[
                        const SizedBox(height: 6),
                        Text(
                          localizations.backupDirectoryFallback(
                            backupDirectoryResolution!.effectiveRoot.path,
                          ),
                          key: const ValueKey('backup-directory-fallback'),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          OutlinedButton.icon(
                            key: const ValueKey('choose-backup-directory'),
                            onPressed: _backupBusy
                                ? null
                                : _chooseBackupDirectory,
                            icon: const Icon(Icons.folder_outlined),
                            label: Text(localizations.chooseBackupDirectory),
                          ),
                          OutlinedButton.icon(
                            key: const ValueKey('open-backup-directory'),
                            onPressed: _backupBusy
                                ? null
                                : _openBackupDirectory,
                            icon: const Icon(Icons.folder_open_outlined),
                            label: Text(localizations.openBackupDirectory),
                          ),
                          OutlinedButton.icon(
                            key: const ValueKey('test-backup-directory'),
                            onPressed: _backupBusy
                                ? null
                                : _testBackupDirectory,
                            icon: const Icon(Icons.check_circle_outline),
                            label: Text(localizations.testBackupDirectory),
                          ),
                          if (backupDirectory != null)
                            TextButton(
                              key: const ValueKey('reset-backup-directory'),
                              onPressed: _backupBusy
                                  ? null
                                  : _resetBackupDirectory,
                              child: Text(localizations.resetBackupDirectory),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile.adaptive(
                        key: const ValueKey('automatic-backup-toggle'),
                        contentPadding: EdgeInsets.zero,
                        title: Text(localizations.automaticBackupTitle),
                        subtitle: Text(
                          localizations.automaticBackupDescription,
                        ),
                        value: automaticBackupEnabled,
                        onChanged: _backupBusy
                            ? null
                            : (value) => setAutomaticBackupEnabled(ref, value),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 240,
                        child: DropdownButtonFormField<int>(
                          key: const ValueKey('automatic-backup-retention'),
                          initialValue: automaticBackupRetention,
                          decoration: InputDecoration(
                            labelText: localizations.automaticBackupRetention,
                          ),
                          items: [
                            for (
                              var count = minimumAutomaticBackupRetentionCount;
                              count <= maximumAutomaticBackupRetentionCount;
                              count++
                            )
                              DropdownMenuItem(
                                value: count,
                                child: Text(
                                  localizations.automaticBackupRetentionValue(
                                    count,
                                  ),
                                ),
                              ),
                          ],
                          onChanged: _backupBusy
                              ? null
                              : (value) {
                                  if (value != null) {
                                    setAutomaticBackupRetentionCount(
                                      ref,
                                      value,
                                    );
                                  }
                                },
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        key: const ValueKey('backup-now-default-directory'),
                        onPressed: _backupBusy ? null : _backupNowToDefault,
                        icon: const Icon(Icons.backup_outlined),
                        label: Text(localizations.backupNow),
                      ),
                      const Divider(height: 32),
                    ],
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
                        OutlinedButton.icon(
                          key: const ValueKey('clear-data-button'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context)
                                .colorScheme
                                .error,
                          ),
                          onPressed: _backupBusy ? null : _clearData,
                          icon: const Icon(Icons.delete_sweep_outlined),
                          label: Text(localizations.clearData),
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
              if (!isAndroid) ...[
                const SizedBox(height: 16),
                _ExpandableSettingsCard(
                  key: const ValueKey('motto-settings'),
                  icon: Icons.chat_bubble_outline_rounded,
                  title: localizations.mottoTitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _FontSizeDropdown(
                            key: const ValueKey('motto-font-size'),
                            label: localizations.mottoFontSizeLabel,
                            value: mottoStyle.fontSize,
                            values: const [
                              10,
                              12,
                              14,
                              16,
                              18,
                              20,
                              22,
                              24,
                              26,
                              28,
                            ],
                            onChanged: (value) => _saveMottoStyle(
                              mottoStyle.copyWith(fontSize: value),
                            ),
                          ),
                          OutlinedButton.icon(
                            key: const ValueKey('motto-color-button'),
                            onPressed: () => _pickMottoColor(mottoStyle),
                            icon: CircleAvatar(
                              radius: 8,
                              backgroundColor: Color(mottoStyle.colorValue),
                            ),
                            label: Text(localizations.mottoColorLabel),
                          ),
                          FilterChip(
                            key: const ValueKey('motto-bold-toggle'),
                            selected: mottoStyle.bold,
                            onSelected: (value) => _saveMottoStyle(
                              mottoStyle.copyWith(bold: value),
                            ),
                            avatar: const Icon(Icons.format_bold, size: 18),
                            label: Text(localizations.mottoBoldLabel),
                          ),
                          FilterChip(
                            key: const ValueKey('motto-italic-toggle'),
                            selected: mottoStyle.italic,
                            onSelected: (value) => _saveMottoStyle(
                              mottoStyle.copyWith(italic: value),
                            ),
                            avatar: const Icon(Icons.format_italic, size: 18),
                            label: Text(localizations.mottoItalicLabel),
                          ),
                          FilterChip(
                            key: const ValueKey('motto-underline-toggle'),
                            selected: mottoStyle.underline,
                            onSelected: (value) => _saveMottoStyle(
                              mottoStyle.copyWith(underline: value),
                            ),
                            avatar: const Icon(
                              Icons.format_underlined,
                              size: 18,
                            ),
                            label: Text(localizations.mottoUnderlineLabel),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
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
              if (capabilities.isWindows) ...[
                const SizedBox(height: 16),
                const SyncHostSettingsSection(),
              ],
              if (capabilities.isAndroid) ...[
                const SizedBox(height: 16),
                const SyncClientSettingsSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportBackup() async {
    final gateway = ref.read(backupFileGatewayProvider);
    final target = await gateway.chooseExportTarget(
      suggestedName: standardBackupFileName(DateTime.now()),
    );
    if (target == null || !mounted) return;
    setState(() => _backupBusy = true);
    try {
      await ref.read(backupRepositoryProvider).exportTo(target.path);
      await gateway.commitExport(target);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).backupExported)),
      );
    } on Object catch (error) {
      _showBackupError(error);
    } finally {
      await gateway.cleanupExport(target);
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  Future<void> _chooseBackupDirectory() async {
    final gateway = ref.read(backupDirectoryGatewayProvider);
    final path = await gateway.chooseDirectory();
    if (path == null || !mounted) return;
    setState(() => _backupBusy = true);
    try {
      await gateway.verifyWritable(path);
      await setBackupDirectory(ref, path);
      ref.invalidate(backupDirectoryResolutionProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).backupDirectorySaved),
        ),
      );
    } on Object catch (error) {
      _showBackupError(error);
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  Future<void> _openBackupDirectory() async {
    setState(() => _backupBusy = true);
    try {
      final resolution = await ref
          .read(backupDirectoryResolverProvider)
          .resolve();
      await ref
          .read(backupDirectoryGatewayProvider)
          .openDirectory(resolution.effectiveRoot.path);
    } on Object catch (error) {
      _showBackupError(error);
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  Future<void> _testBackupDirectory() async {
    setState(() => _backupBusy = true);
    try {
      final configured = await ref
          .read(settingsRepositoryProvider)
          .get(BackupPreferenceKeys.directory);
      final path = configured?.value.trim();
      final effectivePath = path == null || path.isEmpty
          ? (await ref.read(backupDirectoryResolverProvider).resolve())
                .effectiveRoot
                .path
          : path;
      await ref
          .read(backupDirectoryGatewayProvider)
          .verifyWritable(effectivePath);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).backupDirectoryTestPassed),
        ),
      );
    } on Object catch (error) {
      _showBackupError(error);
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  Future<void> _resetBackupDirectory() async {
    setState(() => _backupBusy = true);
    try {
      await setBackupDirectory(ref, null);
      ref.invalidate(backupDirectoryResolutionProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).backupDirectoryReset),
        ),
      );
    } on Object catch (error) {
      _showBackupError(error);
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  Future<void> _backupNowToDefault() async {
    setState(() => _backupBusy = true);
    try {
      final result = await ref
          .read(backupMaintenanceServiceProvider)
          .createDefaultBackup();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).backupCreatedAt(result.path),
          ),
        ),
      );
    } on Object catch (error) {
      _showBackupError(error);
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  Future<void> _importBackup() async {
    final path = await ref.read(backupFileGatewayProvider).chooseImportPath();
    if (path == null || !mounted) return;
    setState(() => _backupBusy = true);
    try {
      final repository = ref.read(backupRepositoryProvider);
      final preview = await repository.inspect(path);
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
        _ImportChoice.merge => await repository.merge(path),
        _ImportChoice.replace => await repository.replace(path),
      };
      if (!mounted) return;
      _refreshPreferences();
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

  Future<void> _clearData() async {
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        key: const ValueKey('clear-data-confirm-dialog'),
        title: Text(strings.clearDataConfirmTitle),
        content: Text(strings.clearDataConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.clearDataConfirmAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _backupBusy = true);
    try {
      final result = await ref.read(backupRepositoryProvider).clearUserData();
      if (!mounted) return;
      _mottoController.text = defaultCalendarMotto;
      _mottoLoaded = true;
      _refreshPreferences();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.clearDataCompleted(result.deletedRecordCount)),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.clearDataSafetyCreated(result.safetyBackupPath),
          ),
        ),
      );
    } on Object catch (error) {
      _showBackupError(error);
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  void _refreshPreferences() {
    ref.invalidate(calendarControllerProvider);
    ref.invalidate(themeModeProvider);
    ref.invalidate(appLanguageProvider);
    ref.invalidate(primaryColorProvider);
    ref.invalidate(todoSortModeProvider);
    ref.invalidate(calendarMottoProvider);
    ref.invalidate(calendarMottoStyleProvider);
    ref.invalidate(calendarTodoFontSizeProvider);
    ref.invalidate(sidebarTodoFontSizeProvider);
    ref.invalidate(dayTodoFontSizeProvider);
    ref.invalidate(postponeDaysProvider);
    ref.invalidate(catalogPaletteProvider);
    ref.invalidate(navigationRailExtendedProvider);
    ref.invalidate(hotkeyPreferenceProvider);
    ref.invalidate(backupDirectoryPreferenceProvider);
    ref.invalidate(backupDirectoryResolutionProvider);
    ref.invalidate(automaticBackupEnabledProvider);
    ref.invalidate(automaticBackupRetentionCountProvider);
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

  Future<void> _saveMottoStyle(CalendarMottoStyle style) {
    return setCalendarMottoStyle(ref, style);
  }

  Future<void> _pickMottoColor(CalendarMottoStyle style) async {
    final strings = AppLocalizations.of(context);
    final picked = await showEchoDayColorPicker(
      context: context,
      initialColor: Color(style.colorValue),
      title: strings.mottoColorLabel,
      cancelLabel: strings.cancel,
      saveLabel: strings.save,
      hueLabel: strings.hueLabel,
      saturationLabel: strings.saturationLabel,
      brightnessLabel: strings.brightnessLabel,
      previewKey: const ValueKey('motto-color-preview'),
    );
    if (picked != null && mounted) {
      await _saveMottoStyle(style.copyWith(colorValue: picked.toARGB32()));
    }
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

class _ThemeChoice extends ConsumerWidget {
  const _ThemeChoice({
    required this.value,
    required this.selected,
    required this.icon,
    required this.label,
  });

  final ThemeMode value;
  final ThemeMode selected;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ChoiceChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      selected: value == selected,
      onSelected: (_) => ref.read(themeModeProvider.notifier).setMode(value),
    );
  }
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
    final compact = MediaQuery.sizeOf(context).width < 600;
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        childrenPadding: EdgeInsets.fromLTRB(
          compact ? 12 : 20,
          12,
          compact ? 12 : 20,
          compact ? 16 : 20,
        ),
        children: [child],
      ),
    );
  }
}

class _FontSizeDropdown extends StatelessWidget {
  const _FontSizeDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
    super.key,
  });

  final String label;
  final double value;
  final List<double> values;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width < 600 ? double.infinity : 220,
      child: DropdownButtonFormField<double>(
        initialValue: values.contains(value) ? value : values.first,
        decoration: InputDecoration(labelText: label),
        items: [
          for (final option in values)
            DropdownMenuItem(
              value: option,
              child: Text('${option.toInt()} px'),
            ),
        ],
        onChanged: (selected) {
          if (selected != null) onChanged(selected);
        },
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
