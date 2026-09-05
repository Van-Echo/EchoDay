// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'EchoDay';

  @override
  String get appSubtitle => '丸成';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navDayTodos => 'Day TODOs';

  @override
  String get navSearch => 'Search';

  @override
  String get navSettings => 'Settings';

  @override
  String get navAbout => 'About';

  @override
  String get expandNavigation => 'Show navigation labels';

  @override
  String get collapseNavigation => 'Show navigation icons only';

  @override
  String get calendarTitle => 'Calendar workspace';

  @override
  String get calendarDescription =>
      'The continuous-week calendar arrives in M2.';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get today => 'Today';

  @override
  String get backToToday => 'Back to today';

  @override
  String get backToSelectedDate => 'Back to selected date';

  @override
  String visibleWeeks(int count) {
    return '$count weeks';
  }

  @override
  String get showFewerWeeks => 'Show fewer weeks';

  @override
  String get showMoreWeeks => 'Show more weeks';

  @override
  String get mondayShort => 'Mon';

  @override
  String get tuesdayShort => 'Tue';

  @override
  String get wednesdayShort => 'Wed';

  @override
  String get thursdayShort => 'Thu';

  @override
  String get fridayShort => 'Fri';

  @override
  String get saturdayShort => 'Sat';

  @override
  String get sundayShort => 'Sun';

  @override
  String get quickAddTitle => 'Quick add TODO';

  @override
  String get todoTitleHint => 'What needs to be done?';

  @override
  String get addTask => 'Add';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get clear => 'Clear';

  @override
  String get editTask => 'Edit task';

  @override
  String get deleteTask => 'Delete task';

  @override
  String get markComplete => 'Mark complete';

  @override
  String get restoreTask => 'Restore task';

  @override
  String get undo => 'Undo';

  @override
  String get taskDeleted => 'Task deleted';

  @override
  String get incompleteTasks => 'To do';

  @override
  String get completedTasks => 'Completed';

  @override
  String get overdue => 'Overdue';

  @override
  String get sortTasks => 'Sort tasks';

  @override
  String get filterTasks => 'Filter tasks';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get applyFilters => 'Apply filters';

  @override
  String get sortManual => 'Manual';

  @override
  String get sortCreatedAscending => 'Created (oldest first)';

  @override
  String get sortCreatedDescending => 'Created (newest first)';

  @override
  String get sortPlannedTime => 'Planned time';

  @override
  String get sortPriority => 'Priority';

  @override
  String get sortComposite => 'Smart sort';

  @override
  String get dragToReorder => 'Drag to reorder';

  @override
  String get taskDetails => 'Task details';

  @override
  String get titleLabel => 'Content';

  @override
  String get dateLabel => 'Date';

  @override
  String get plannedAtLabel => 'Planned time';

  @override
  String get deadlineAtLabel => 'Planned deadline';

  @override
  String get priorityLabel => 'Priority';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityNone => 'None';

  @override
  String get categoryLabel => 'Category';

  @override
  String get tagsLabel => 'Tags';

  @override
  String get notesLabel => 'Notes';

  @override
  String get createCategory => 'New category';

  @override
  String get createTag => 'New tag';

  @override
  String get selectCategory => 'Choose category';

  @override
  String get catalogEditHint => 'Click to select; double-click to edit';

  @override
  String get editCategory => 'Edit category';

  @override
  String get editTag => 'Edit tag';

  @override
  String get deleteCategory => 'Delete category';

  @override
  String get deleteTag => 'Delete tag';

  @override
  String get deleteCatalogTitle => 'Confirm deletion?';

  @override
  String get deleteCatalogMessage =>
      'The tasks will be kept, but this category or tag will no longer be shown.';

  @override
  String get nameHint => 'Enter a name';

  @override
  String get colorLabel => 'Color';

  @override
  String get addCustomColor => 'Add color from picker';

  @override
  String get removeSelectedColor => 'Remove selected color';

  @override
  String get hueLabel => 'Hue';

  @override
  String get saturationLabel => 'Saturation';

  @override
  String get brightnessLabel => 'Value';

  @override
  String get repeatRuleLabel => 'Repeat rule';

  @override
  String get repeatRuleM4Hint => 'Does not repeat';

  @override
  String get repeatDaily => 'Daily';

  @override
  String get repeatWeekdays => 'Every workday';

  @override
  String get repeatWeekly => 'Weekly';

  @override
  String get repeatMonthly => 'Monthly';

  @override
  String get repeatCustom => 'Custom interval';

  @override
  String get repeatInterval => 'Interval';

  @override
  String get repeatUnitDay => 'Day';

  @override
  String get repeatUnitWeek => 'Week';

  @override
  String get repeatUnitMonth => 'Month';

  @override
  String get repeatUntil => 'End date';

  @override
  String get repeatCount => 'Occurrence count';

  @override
  String get repeatWorkdayFallback =>
      'Covered years use China\'s official holiday adjustments; missing years fall back to Monday–Friday and are flagged in the calendar';

  @override
  String get recurrenceScopeTitle => 'Apply to repeating task';

  @override
  String get onlyThisOccurrence => 'This occurrence only';

  @override
  String get thisAndFuture => 'This and future occurrences';

  @override
  String get chooseDateTime => 'Choose date and time';

  @override
  String get chooseTime => 'Choose time';

  @override
  String get chooseDate => 'Choose date';

  @override
  String get yearLabel => 'Year';

  @override
  String get monthLabel => 'Month';

  @override
  String monthValue(int month) {
    return 'Month $month';
  }

  @override
  String get taskSaveFailed => 'Could not save. Try again.';

  @override
  String get taskActionFailed => 'Could not complete the action. Try again.';

  @override
  String get postponeIncomplete => 'Move incomplete tasks to the next day';

  @override
  String postponeIncompleteDays(int days) {
    return 'Move incomplete tasks by $days days (right-click to configure)';
  }

  @override
  String get configurePostponeDays => 'Configure postponement';

  @override
  String get postponeDaysLabel => 'Move by X days';

  @override
  String get postponeDaysRange =>
      'Enter 1–365 days; shared by batch and single-task actions';

  @override
  String postponeDialogBodyDays(int count, String date, int days) {
    return 'Move this day\'s $count incomplete tasks to $date, $days days later. Planned times and deadlines will move too.';
  }

  @override
  String postponedTasksDays(int count, int days) {
    return 'Moved $count incomplete tasks by $days days';
  }

  @override
  String postponeOneTaskDays(int days) {
    return 'Move this task by $days days';
  }

  @override
  String postponedOneTask(int days) {
    return 'Moved the task by $days days';
  }

  @override
  String get postponeDialogTitle => 'Move incomplete tasks?';

  @override
  String postponeDialogBody(int count, String date) {
    return 'Move this day\'s $count incomplete tasks to $date. Planned times and deadlines will also move forward one day.';
  }

  @override
  String get postponeAction => 'Move';

  @override
  String postponedTasks(int count) {
    return 'Moved $count incomplete tasks';
  }

  @override
  String get noTasksForDate => 'No TODOs for this day';

  @override
  String get todoLoadFailed => 'Could not load TODOs';

  @override
  String moreTasks(int count) {
    return '$count more';
  }

  @override
  String get openFullScreen => 'Open day TODOs full screen';

  @override
  String get backToCalendar => 'Back to calendar';

  @override
  String get holidayDayOff => 'Off';

  @override
  String get holidayWorkday => 'Work';

  @override
  String get holidayCoverageMissingShort => 'Holiday data missing';

  @override
  String holidayCoverageMissing(String years) {
    return 'Official holiday adjustments for $years are not available; weekday recurrence temporarily uses Monday through Friday.';
  }

  @override
  String get dayTodosTitle => 'Day TODOs';

  @override
  String get dayTodosDescription => 'Manage the day\'s work and life plans.';

  @override
  String get searchTitle => 'Global search';

  @override
  String get searchDescription => 'Search titles, notes, categories, and tags.';

  @override
  String get searchHint => 'Search TODO content, notes, categories, or tags';

  @override
  String get searchAll => 'All';

  @override
  String get searchIncomplete => 'Incomplete';

  @override
  String get searchCompleted => 'Completed';

  @override
  String get dateRangeLabel => 'Date range';

  @override
  String get noSearchResults => 'No matching TODOs';

  @override
  String get searchLoadFailed => 'Search failed. Try again.';

  @override
  String resultCount(int count) {
    return '$count results';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsDescription => 'Theme and local preference scaffolding.';

  @override
  String get mottoTitle => 'Calendar note~';

  @override
  String get mottoLabel => 'A short message above the calendar';

  @override
  String get mottoSaved => 'Calendar note saved';

  @override
  String get editMotto => 'Edit calendar note';

  @override
  String get hotkeysTitle => 'Keyboard shortcuts';

  @override
  String get summonHotkey => 'Summon “EchoDay” globally';

  @override
  String get todayHotkey => 'Go to “Today”';

  @override
  String get editHotkey => 'Edit shortcut';

  @override
  String get recordHotkeyHint => 'Press the new shortcut combination';

  @override
  String get holidayDataTitle => 'China public holiday data';

  @override
  String get holidayYearLabel => 'Year to update';

  @override
  String holidayCoverage(String years) {
    return 'Covered years: $years';
  }

  @override
  String holidaySource(String source) {
    return 'Selected-year source: $source';
  }

  @override
  String get checkHolidayUpdates => 'Check for updates';

  @override
  String get holidayUpdateUnavailable =>
      'The remote source is not configured; verified bundled data remains active';

  @override
  String get holidayUpdateLocalFallback =>
      'China\'s government website could not be reached; verified database data remains active';

  @override
  String get holidayUpdateFailed =>
      'No valid holiday schedule for this year was found in the database or on China\'s government website';

  @override
  String get holidayUpdated => 'Holiday data updated';

  @override
  String get holidayUnchanged => 'Holiday data is current';

  @override
  String get holidayValidationFailed =>
      'Update validation failed; existing data was preserved';

  @override
  String get aboutTitle => 'About EchoDay';

  @override
  String get aboutDescription => 'EchoDay / 丸成\nCreated by Van Echo / 丸一口';

  @override
  String get aboutBrand => '丸成 | EchoDay';

  @override
  String get aboutCreator => 'Created by 丸一口 / Van Echo with ChatGPT 5.6 Sol';

  @override
  String get aboutWelcome => 'Support us on';

  @override
  String get supportCharging => 'Bilibili';

  @override
  String get aboutAnd => 'or report issues on';

  @override
  String get bugFeedback => 'GitHub';

  @override
  String get aboutTilde => '~';

  @override
  String get aboutLicensePrefix => 'This project is licensed under the';

  @override
  String get aboutLicenseName => 'GNU Affero General Public License v3.0';

  @override
  String get aboutLicenseSuffix => '';

  @override
  String get communityLicenseDialogTitle =>
      'GNU Affero General Public License v3.0';

  @override
  String get communityLicenseDialogSubtitle =>
      'SPDX: AGPL-3.0-only · OSI-approved strong copyleft license';

  @override
  String get communityLicenseLoading => 'Loading license…';

  @override
  String get communityLicenseLoadFailed =>
      'The license could not be loaded. See the LICENSE file in the application directory.';

  @override
  String get close => 'Close';

  @override
  String get aboutPersonalUse =>
      'Personal, organizational, and commercial use are permitted.';

  @override
  String get aboutCommercialUse =>
      'Distributed modifications and modified network services must follow AGPLv3 and provide the corresponding source.';

  @override
  String aboutVersion(String version, String date) {
    return 'v$version | $date';
  }

  @override
  String get linkOpenFailed =>
      'Could not open the link. Check the system default browser.';

  @override
  String get themeModeLabel => 'Theme mode';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get primaryColorLabel => 'Primary color';

  @override
  String get calendarTaskSettingsTitle => 'Calendar and tasks';

  @override
  String get calendarPreviewLabel => 'TODO previews per day';

  @override
  String calendarPreviewValue(int count) {
    return 'Up to $count';
  }

  @override
  String get defaultSortLabel => 'Default task sorting';

  @override
  String get dataSafetyTitle => 'Backup and restore';

  @override
  String get dataSafetyDescription =>
      'Backups include tasks, categories, tags, recurrence rules, and user settings. Public-holiday cache data is excluded.';

  @override
  String get exportBackup => 'Export JSON backup';

  @override
  String get importBackup => 'Import JSON backup';

  @override
  String get clearData => 'Clear data';

  @override
  String get clearDataConfirmTitle => 'Clear all user data?';

  @override
  String get clearDataConfirmBody =>
      'TODOs, categories, tags, recurrence rules, and all user settings will be cleared. Public-holiday cache data will remain. EchoDay creates a safety backup first.';

  @override
  String get clearDataConfirmAction => 'Clear data';

  @override
  String clearDataCompleted(int count) {
    return 'Cleared $count records';
  }

  @override
  String clearDataSafetyCreated(String path) {
    return 'Pre-clear safety backup: $path';
  }

  @override
  String get backupExported => 'Backup exported';

  @override
  String backupOperationFailed(String reason) {
    return 'Operation failed: $reason';
  }

  @override
  String backupInvalid(String reason) {
    return 'Backup inspection failed: $reason';
  }

  @override
  String get backupPreviewTitle => 'Backup inspection passed';

  @override
  String backupPreviewBody(
    int formatVersion,
    String appVersion,
    String exportedAt,
    int todoCount,
    int totalCount,
  ) {
    return 'Format v$formatVersion · App v$appVersion\nExported: $exportedAt\nTODOs: $todoCount · All records: $totalCount';
  }

  @override
  String get mergeImport => 'Merge import';

  @override
  String get replaceRestore => 'Replace and restore';

  @override
  String get replaceConfirmTitle => 'Replace current data?';

  @override
  String get replaceConfirmBody =>
      'Current tasks and settings will be replaced. EchoDay first creates a safety backup in its app-data directory; a failed import leaves the database unchanged.';

  @override
  String get replaceConfirmAction => 'Replace data';

  @override
  String backupImportCompleted(int imported, int skipped) {
    return 'Imported $imported; skipped $skipped';
  }

  @override
  String backupSafetyCreated(String path) {
    return 'Pre-restore safety backup: $path';
  }

  @override
  String get routeNotFound => 'Page not found';

  @override
  String get unexpectedError => 'EchoDay encountered an unexpected error';

  @override
  String get unexpectedErrorHint =>
      'Restart the app. Diagnostic details were written to the log.';
}
