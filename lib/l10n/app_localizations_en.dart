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
  String get previousWeek => 'Previous week';

  @override
  String get nextWeek => 'Next week';

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
  String get calendarTodoFontSizeLabel => 'Calendar-cell TODO font size';

  @override
  String get calendarCellExpansionEnabled => 'Enable calendar-cell expansion';

  @override
  String get expandTodayByDefault => 'Expand today\'s cell by default';

  @override
  String get sidebarTodoFontSizeLabel => 'Sidebar TODOList font size';

  @override
  String get dayTodoFontSizeLabel => 'Day TODO font size';

  @override
  String get mottoFontSizeLabel => 'Calendar-note font size';

  @override
  String get mottoColorLabel => 'Calendar-note color';

  @override
  String get mottoBoldLabel => 'Bold';

  @override
  String get mottoItalicLabel => 'Italic';

  @override
  String get mottoUnderlineLabel => 'Underline';

  @override
  String get dragTodoToDate => 'Drag to another date';

  @override
  String get moveToDate => 'Move to date';

  @override
  String get taskActions => 'Task actions';

  @override
  String taskMovedToDate(String date) {
    return 'Moved task to $date';
  }

  @override
  String get hotkeysTitle => 'Keyboard shortcuts';

  @override
  String get summonHotkey => 'Summon “EchoDay” globally';

  @override
  String get todayHotkey => 'Go to “Today”';

  @override
  String get addTodoHotkey => 'Add TODO on the selected date';

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
  String get languageLabel => 'Language';

  @override
  String get languageChinese => '中文';

  @override
  String get languageEnglish => 'English';

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
      'Backups include tasks, categories, tags, recurrence rules, and portable user settings. Public-holiday caches and device-local folder settings are excluded.';

  @override
  String get defaultBackupDirectoryTitle => 'Default backup folder';

  @override
  String get backupDirectorySystemDefault => 'System default folder';

  @override
  String backupDirectoryFallback(String path) {
    return 'The custom folder is unavailable. EchoDay is temporarily using: $path';
  }

  @override
  String get chooseBackupDirectory => 'Choose folder';

  @override
  String get openBackupDirectory => 'Open folder';

  @override
  String get testBackupDirectory => 'Test write';

  @override
  String get resetBackupDirectory => 'Use default';

  @override
  String get backupDirectorySaved => 'Default backup folder saved';

  @override
  String get backupDirectoryReset => 'System default backup folder restored';

  @override
  String get backupDirectoryTestPassed => 'The folder is writable';

  @override
  String get backupNow => 'Back up now to default folder';

  @override
  String backupCreatedAt(String path) {
    return 'Backup created: $path';
  }

  @override
  String get automaticBackupTitle => 'Daily automatic backup';

  @override
  String get automaticBackupDescription =>
      'Creates at most one backup when EchoDay is first opened or resumed each day. Sync will reuse it before the first daily sync.';

  @override
  String get automaticBackupRetention => 'Automatic backup retention';

  @override
  String automaticBackupRetentionValue(int count) {
    return 'Keep $count';
  }

  @override
  String get syncHostTitle => 'Multi-device sync';

  @override
  String get syncHostDescription =>
      'One Windows PC acts as the host. LAN or Tailscale provides connectivity while every device keeps a local copy of its tasks.';

  @override
  String get syncModeLabel => 'Sync mode';

  @override
  String get syncModeOff => 'Sync off';

  @override
  String get syncModeHost => 'Act as sync host';

  @override
  String get syncModeClient => 'Connect to a sync host';

  @override
  String get syncStatusStopped => 'Stopped';

  @override
  String get syncStatusStarting => 'Starting';

  @override
  String get syncStatusRunning => 'Running';

  @override
  String get syncStatusStopping => 'Stopping';

  @override
  String get syncStatusFailed => 'Failed';

  @override
  String get syncAddressLabel => 'Listening interface';

  @override
  String get syncRefreshNetworks => 'Refresh networks';

  @override
  String get syncRestartHost => 'Restart service';

  @override
  String syncEndpointLabel(String endpoint) {
    return 'Service endpoint: $endpoint';
  }

  @override
  String syncFingerprintLabel(String fingerprint) {
    return 'Host fingerprint: $fingerprint';
  }

  @override
  String get syncCreatePairing => 'Add device';

  @override
  String get syncPairingTitle => 'Pair a new device';

  @override
  String get syncPairingHint =>
      'Scan the QR code on the client or copy the complete connection code, then compare the six-digit verification code on both devices.';

  @override
  String get syncConnectionCode => 'One-time connection code';

  @override
  String syncExpiresAt(String time) {
    return 'Expires at $time';
  }

  @override
  String get syncCopy => 'Copy';

  @override
  String get syncCopied => 'Copied to clipboard';

  @override
  String get syncPendingPairings => 'Devices awaiting approval';

  @override
  String syncVerificationCode(String code) {
    return 'Verification code $code';
  }

  @override
  String get syncApprove => 'Approve pairing';

  @override
  String get syncReject => 'Reject';

  @override
  String get syncDevicesTitle => 'Connected devices';

  @override
  String get syncLocalDevice => 'This PC';

  @override
  String get syncOnline => 'Online';

  @override
  String get syncOffline => 'Offline';

  @override
  String get syncWaiting => 'Sync pending';

  @override
  String get syncRevoked => 'Revoked';

  @override
  String get syncNeedsUpgrade => 'Upgrade required';

  @override
  String get syncNeverSynced => 'Not synced yet';

  @override
  String syncLastSynced(String time) {
    return 'Last sync: $time';
  }

  @override
  String get syncEditNote => 'Edit note';

  @override
  String get syncDeviceNote => 'Device note';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncAll => 'Sync all devices';

  @override
  String syncRequestedCount(int count) {
    return 'Sent a sync request to $count devices. Offline devices will receive it when they reconnect.';
  }

  @override
  String get syncRevoke => 'Revoke device';

  @override
  String get syncRevokeConfirmTitle => 'Revoke this device?';

  @override
  String get syncRevokeConfirmBody =>
      'Current sessions will stop immediately. The device must pair again to rejoin; its local tasks will not be deleted.';

  @override
  String syncConflicts(int count) {
    return 'Sync conflicts ($count)';
  }

  @override
  String syncConflictsNeedAttention(int count) {
    return '$count sync conflicts need attention';
  }

  @override
  String get syncAttentionSemantics => 'Multi-device sync needs attention';

  @override
  String get syncConflictTitle => 'Unresolved sync conflicts';

  @override
  String get syncConflictEmpty => 'No unresolved conflicts';

  @override
  String get syncRestoreVersion => 'Restore this version';

  @override
  String get syncLaunchAtStartup => 'Start EchoDay after Windows sign-in';

  @override
  String get syncKeepInTray =>
      'Keep running in the tray after closing the window';

  @override
  String get syncHostStartFailed =>
      'The sync host could not start. Check the selected network, port use, and Windows Firewall.';

  @override
  String get syncInitializationFailed =>
      'Sync settings could not be loaded. Try again later.';

  @override
  String get syncInviteFailed =>
      'A pairing invitation could not be created. Check that the host service is running.';

  @override
  String get syncOperationFailed =>
      'The sync operation failed. Try again later.';

  @override
  String get syncRoleChangeBlocked =>
      'This device is already the sync-group host and cannot become a client directly. Migrate the host or clear its sync-group identity first.';

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
  String get syncClientTitle => 'Multi-device sync';

  @override
  String get syncClientDescription =>
      'Connect to your main PC over LAN or Tailscale. The phone remains usable offline and syncs only on launch, resume, or manual action.';

  @override
  String get syncClientDesktopDescription =>
      'Connect this PC to the main PC as a client. LAN, Tailscale IP, and MagicDNS are supported; offline edits upload when the window is reopened or sync is requested.';

  @override
  String get syncClientDisconnected => 'No sync host connected';

  @override
  String get syncClientConnecting => 'Connecting to host…';

  @override
  String get syncClientWaitingApproval => 'Waiting for host approval';

  @override
  String get syncClientSyncing => 'Syncing…';

  @override
  String get syncClientSynced => 'Synced';

  @override
  String get syncClientOffline =>
      'Host is currently unreachable; offline editing remains available';

  @override
  String get syncClientError => 'Sync needs attention';

  @override
  String get syncScanQr => 'Scan host QR code';

  @override
  String get syncPasteCode => 'Paste connection code';

  @override
  String get syncPairingCodeLabel => 'Full connection code';

  @override
  String get syncImportPairingFile => 'Import pairing file';

  @override
  String get syncExportPairingFile => 'Export pairing file';

  @override
  String get syncDiscoverNearby => 'Discover nearby host';

  @override
  String get syncNoNearbyHost =>
      'No host is currently advertising a pairing invitation. Open Add device on the main PC and try again.';

  @override
  String get syncChooseNearbyHost => 'Choose a nearby host';

  @override
  String syncNearbyHostFound(String name) {
    return 'Found $name. Select Connect, then compare the verification code on the host.';
  }

  @override
  String get syncDiscoveryFailed =>
      'Nearby-host discovery failed. You can still paste a connection code or import a pairing file.';

  @override
  String get syncPairingFileExported => 'Pairing file exported';

  @override
  String get syncPairingFileInvalid =>
      'The pairing file is invalid, damaged, or expired.';

  @override
  String get syncHostOverride => 'Host address (optional override)';

  @override
  String get syncHostOverrideHint =>
      'The full connection code still provides security verification. This field can replace its address with a reachable LAN IP, Tailscale IP, or MagicDNS name.';

  @override
  String get syncHostAddress => 'Host address';

  @override
  String get syncPort => 'Port';

  @override
  String get syncSaveAndRetry => 'Save and retry';

  @override
  String get syncConnect => 'Connect';

  @override
  String get syncScannerTitle => 'Scan EchoDay pairing code';

  @override
  String get syncScannerHint =>
      'Place the QR code from the main PC inside the frame';

  @override
  String get syncScannerPermissionDenied =>
      'Camera permission is required to scan. You can go back and paste the connection code instead.';

  @override
  String get syncClientVerificationHint =>
      'Confirm that the main PC shows the same six-digit code, then approve this device on the PC.';

  @override
  String get syncClientHost => 'Sync host';

  @override
  String syncClientAddress(String address) {
    return 'Address: $address';
  }

  @override
  String syncClientLastResult(int uploaded, int downloaded, int conflicts) {
    return 'Uploaded $uploaded, downloaded $downloaded, conflicts $conflicts';
  }

  @override
  String get syncClientDisconnect => 'Disconnect this device';

  @override
  String get syncClientDisconnectTitle => 'Disconnect from the host?';

  @override
  String get syncClientDisconnectBody =>
      'TODO data stays on this device and a safety backup is created first. Sync identity and cursors are removed, so reconnecting requires pairing again.';

  @override
  String get syncClientDisconnectAction => 'Disconnect';

  @override
  String get syncClientInvalidCode =>
      'The connection code is invalid or damaged.';

  @override
  String get syncClientHostUnreachable =>
      'Cannot reach the host. Check that the PC Server service is running and that LAN or Tailscale is connected.';

  @override
  String get syncClientPairRejected =>
      'The host rejected this pairing request.';

  @override
  String get syncClientInviteExpired =>
      'The pairing invitation expired. Generate a new one on the PC.';

  @override
  String get syncClientFingerprintMismatch =>
      'The host security fingerprint did not match, so the connection was rejected.';

  @override
  String get syncClientProtocolIncompatible =>
      'The PC and phone use incompatible EchoDay versions. Upgrade and try again.';

  @override
  String get syncClientAlreadyConnected =>
      'This device already belongs to a sync group. Disconnect it first.';

  @override
  String get syncClientDeviceRevoked =>
      'The host revoked this device. Local data remains available. Disconnect and pair again to rejoin.';

  @override
  String get syncClientAuthenticationFailed =>
      'Sync authentication failed. Local data remains available; check the host device list or pair again.';

  @override
  String get syncClientSyncFailed =>
      'Sync failed without losing local data. Try again later.';

  @override
  String get syncClientDisconnectFailed =>
      'Could not disconnect. Try again later.';

  @override
  String get syncInvalidHostAddress =>
      'The host address or port is invalid. Enter an IP address or MagicDNS name and check the port range.';

  @override
  String get routeNotFound => 'Page not found';

  @override
  String get unexpectedError => 'EchoDay encountered an unexpected error';

  @override
  String get unexpectedErrorHint =>
      'Restart the app. Diagnostic details were written to the log.';
}
