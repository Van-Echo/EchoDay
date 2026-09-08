import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../app/layout/adaptive_window.dart';
import '../../../app/platform/platform_capabilities.dart';
import '../../../app/providers/data_providers.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/widgets/app_lifecycle_refresh_host.dart';
import '../../../app/widgets/app_scaffold.dart';
import '../../../app/widgets/echoday_date_picker.dart';
import '../../settings/application/app_preferences.dart';
import '../../settings/application/hotkey_preferences.dart';
import '../../todos/application/todo_providers.dart';
import '../../todos/domain/local_date.dart';
import '../../todos/domain/todo_item.dart';
import '../../todos/presentation/day_todo_list.dart';
import '../../todos/presentation/todo_editor.dart';
import '../application/calendar_controller.dart';
import '../domain/calendar_layout.dart';
import '../domain/continuous_calendar.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref.read(calendarControllerProvider.notifier).loadPreferences(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final state = ref.watch(calendarControllerProvider);
    ref.listen<AddTodoHotkeyRequest?>(addTodoHotkeyRequestProvider, (
      previous,
      request,
    ) {
      if (request == null) return;
      ref.read(addTodoHotkeyRequestProvider.notifier).consume(request.revision);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showTodoEditor(context, ref, date: request.date);
      });
    });
    final isAndroid = ref.watch(platformCapabilitiesProvider).isAndroid;
    final today = LocalDate.fromDateTime(DateTime.now());
    final selectedIsToday = state.selectedDate == today;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compactAndroid =
            isAndroid &&
            AdaptiveWindow.classify(constraints.maxWidth).isCompact;
        return AppScaffold(
          selectedIndex: 0,
          title: localizations.calendarTitle,
          body: const _CalendarWorkspace(),
          floatingActionButton: compactAndroid
              ? null
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!selectedIsToday) ...[
                      FloatingActionButton.extended(
                        heroTag: 'selected-date',
                        tooltip: localizations.backToSelectedDate,
                        onPressed: () => ref
                            .read(calendarControllerProvider.notifier)
                            .focusSelectedDate(),
                        icon: const Icon(Icons.event_rounded),
                        label: Text(
                          '${state.selectedDate.month.toString().padLeft(2, '0')}/'
                          '${state.selectedDate.day.toString().padLeft(2, '0')}',
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    FloatingActionButton.extended(
                      heroTag: 'today',
                      tooltip: localizations.backToToday,
                      onPressed: () => ref
                          .read(calendarControllerProvider.notifier)
                          .goToToday(),
                      icon: const Icon(Icons.today_rounded),
                      label: Text(localizations.today),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _CalendarWorkspace extends ConsumerStatefulWidget {
  const _CalendarWorkspace();

  static const double _splitterWidth = 8;
  static const double _dualPaneBreakpoint = 960;

  @override
  ConsumerState<_CalendarWorkspace> createState() => _CalendarWorkspaceState();
}

class _CalendarWorkspaceState extends ConsumerState<_CalendarWorkspace> {
  var _androidFocusExpanded = false;
  var _androidFocusInitialized = false;
  LocalDate? _focusDate;

  void _setAndroidFocusExpanded(bool value) {
    if (_androidFocusExpanded != value) {
      setState(() => _androidFocusExpanded = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calendarControllerProvider);
    final expandTodayPreference = ref.watch(
      androidExpandTodayByDefaultProvider,
    );
    if (!_androidFocusInitialized && expandTodayPreference.hasValue) {
      _androidFocusInitialized = true;
      _focusDate = state.selectedDate;
      final today = LocalDate.fromDateTime(DateTime.now());
      _androidFocusExpanded =
          state.selectedDate == today && (expandTodayPreference.value ?? false);
    } else if (_focusDate != state.selectedDate) {
      _focusDate = state.selectedDate;
      _androidFocusExpanded = true;
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final isAndroid = ref.watch(platformCapabilitiesProvider).isAndroid;
        final windowClass = AdaptiveWindow.of(context);
        final useShortCalendar = isAndroid && constraints.maxHeight < 600;
        if (isAndroid && windowClass.isCompact) {
          return Column(
            children: [
              Expanded(
                key: const ValueKey('android-calendar-pane'),
                flex: 2,
                child: _CalendarPane(
                  state: state,
                  visibleWeekCount: 2,
                  showMotto: false,
                  androidFocusExpanded: _androidFocusExpanded,
                  onAndroidFocusChanged: _setAndroidFocusExpanded,
                ),
              ),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              Expanded(
                key: const ValueKey('android-todo-pane'),
                flex: 3,
                child: _SelectedDaySidebar(
                  date: state.selectedDate,
                  onTaskDragStarted: () => _setAndroidFocusExpanded(false),
                ),
              ),
            ],
          );
        }
        if (isAndroid && windowClass.isMedium) {
          return _CalendarPane(
            state: state,
            visibleWeekCount: useShortCalendar ? 2 : null,
            showMotto: false,
            androidFocusExpanded: _androidFocusExpanded,
            onAndroidFocusChanged: _setAndroidFocusExpanded,
          );
        }
        final dualPane = isAndroid
            ? windowClass.isExpanded
            : constraints.maxWidth >= _CalendarWorkspace._dualPaneBreakpoint;
        if (!dualPane) {
          return _CalendarPane(
            state: state,
            androidFocusExpanded: _androidFocusExpanded,
            onAndroidFocusChanged: _setAndroidFocusExpanded,
          );
        }
        final paneWidth =
            constraints.maxWidth - _CalendarWorkspace._splitterWidth;
        final minimumSidebarRatio = isAndroid ? 0.36 : 0.125;
        final sidebarRatio = state.sidebarRatio.clamp(minimumSidebarRatio, 0.5);
        final sidebarWidth = paneWidth * sidebarRatio;
        return Row(
          children: [
            Expanded(
              child: _CalendarPane(
                state: state,
                visibleWeekCount: useShortCalendar ? 2 : null,
                showMotto: !isAndroid,
                androidFocusExpanded: _androidFocusExpanded,
                onAndroidFocusChanged: _setAndroidFocusExpanded,
              ),
            ),
            _SidebarSplitter(
              availableWidth: paneWidth,
              minimumRatio: minimumSidebarRatio,
            ),
            SizedBox(
              key: const ValueKey('selected-day-sidebar'),
              width: sidebarWidth,
              child: _SelectedDaySidebar(
                date: state.selectedDate,
                onTaskDragStarted: isAndroid
                    ? () => _setAndroidFocusExpanded(false)
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CalendarPane extends ConsumerWidget {
  const _CalendarPane({
    required this.state,
    required this.androidFocusExpanded,
    required this.onAndroidFocusChanged,
    this.visibleWeekCount,
    this.showMotto = true,
  });

  final CalendarViewState state;
  final int? visibleWeekCount;
  final bool showMotto;
  final bool androidFocusExpanded;
  final ValueChanged<bool> onAndroidFocusChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(calendarControllerProvider.notifier);
    final localizations = AppLocalizations.of(context);
    final weekCount = visibleWeekCount ?? state.visibleWeekCount;
    final dates = continuousDates(state.anchorWeekStart, weekCount);
    final weekdays = [
      localizations.mondayShort,
      localizations.tuesdayShort,
      localizations.wednesdayShort,
      localizations.thursdayShort,
      localizations.fridayShort,
      localizations.saturdayShort,
      localizations.sundayShort,
    ];
    final isAndroid = ref.watch(platformCapabilitiesProvider).isAndroid;
    return GestureDetector(
      key: const ValueKey('calendar-touch-surface'),
      behavior: HitTestBehavior.translucent,
      onVerticalDragEnd: isAndroid
          ? (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity.abs() < 180) return;
              controller.scrollWeeks(velocity < 0 ? 1 : -1);
            }
          : null,
      child: Listener(
        onPointerSignal: (event) {
          if (event is! PointerScrollEvent || event.scrollDelta.dy == 0) return;
          final direction = event.scrollDelta.dy > 0 ? 1 : -1;
          if (HardwareKeyboard.instance.isControlPressed) {
            controller.changeVisibleWeeks(direction);
          } else {
            controller.scrollWeeks(direction);
          }
        },
        child: Column(
          children: [
            _CalendarToolbar(state: state, dates: dates, showMotto: showMotto),
            Container(
              height: 34,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Row(
                children: [
                  for (final weekday in weekdays)
                    Expanded(
                      child: Center(
                        child: Text(
                          weekday,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final layout = CalendarLayout.calculate(
                    viewportHeight: constraints.maxHeight,
                    visibleWeekCount: weekCount,
                    userPreviewLimit: state.previewLimit,
                    textScaleFactor: MediaQuery.textScalerOf(context).scale(1),
                    dayCellWidth: constraints.maxWidth / 7,
                    minimumVisibleWeekCount: visibleWeekCount == null ? 5 : 2,
                  );
                  final selectedIndex = dates.indexOf(state.selectedDate);
                  final cellWidth = constraints.maxWidth / 7;
                  final cellHeight = constraints.maxHeight / weekCount;
                  final focusStartColumn = selectedIndex < 0
                      ? 0
                      : ((selectedIndex % 7) - 1).clamp(0, 4);
                  final focusStartWeek = selectedIndex < 0
                      ? 0
                      : (selectedIndex ~/ 7).clamp(0, weekCount - 2);
                  final showAndroidFocus =
                      isAndroid &&
                      androidFocusExpanded &&
                      selectedIndex >= 0 &&
                      weekCount >= 2;
                  return Stack(
                    key: const ValueKey('calendar-week-grid'),
                    children: [
                      Column(
                        children: [
                          for (var week = 0; week < weekCount; week++)
                            Expanded(
                              child: Row(
                                key: ValueKey('calendar-week-$week'),
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (var day = 0; day < 7; day++)
                                    Expanded(
                                      child: _DayCell(
                                        date: dates[week * 7 + day],
                                        selectedDate: state.selectedDate,
                                        layout: layout,
                                        onAndroidTap: isAndroid
                                            ? (date) {
                                                if (date ==
                                                    state.selectedDate) {
                                                  onAndroidFocusChanged(
                                                    !androidFocusExpanded,
                                                  );
                                                } else {
                                                  onAndroidFocusChanged(true);
                                                  controller.selectDate(date);
                                                }
                                              }
                                            : null,
                                        onTaskDragStarted: isAndroid
                                            ? () => onAndroidFocusChanged(false)
                                            : null,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      if (showAndroidFocus)
                        Positioned(
                          left: focusStartColumn * cellWidth,
                          top: focusStartWeek * cellHeight,
                          width: cellWidth * 3,
                          height: cellHeight * 2,
                          child: DragTarget<TodoDragPayload>(
                            onWillAcceptWithDetails: (_) {
                              onAndroidFocusChanged(false);
                              return false;
                            },
                            builder: (context, candidateData, rejectedData) =>
                                _ExpandedDayCard(
                                  date: state.selectedDate,
                                  onCollapse: () =>
                                      onAndroidFocusChanged(false),
                                  onTaskDragStarted: () =>
                                      onAndroidFocusChanged(false),
                                ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarToolbar extends ConsumerWidget {
  const _CalendarToolbar({
    required this.state,
    required this.dates,
    required this.showMotto,
  });

  final CalendarViewState state;
  final List<LocalDate> dates;
  final bool showMotto;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appRefreshRevisionProvider);
    final localizations = AppLocalizations.of(context);
    final controller = ref.read(calendarControllerProvider.notifier);
    final today = LocalDate.fromDateTime(DateTime.now());
    final titleDate = state.selectedDate != today
        ? state.selectedDate
        : _dominantVisibleMonth(dates);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final title = DateFormat.yMMMM(locale)
        .format(DateTime(titleDate.year, titleDate.month));
    final visibleYears = dates.map((date) => date.year).toSet().toList()
      ..sort();
    Future<void> chooseDate() async {
      final selected = await showEchoDayDatePicker(
        context: context,
        initialDate: DateTime(
          state.selectedDate.year,
          state.selectedDate.month,
          state.selectedDate.day,
        ),
      );
      if (selected != null) {
        controller.goToDate(LocalDate.fromDateTime(selected));
      }
    }

    final compactAndroid =
        ref.watch(platformCapabilitiesProvider).isAndroid &&
        AdaptiveWindow.of(context).isCompact;
    if (compactAndroid) {
      return _CompactCalendarToolbar(
        title: title,
        visibleYears: visibleYears,
        onChooseDate: chooseDate,
        onPreviousWeek: () => controller.scrollWeeks(-1),
        onNextWeek: () => controller.scrollWeeks(1),
        onToday: controller.goToToday,
      );
    }
    final motto = showMotto
        ? ref.watch(calendarMottoProvider).value ?? defaultCalendarMotto
        : null;
    final mottoStyle = showMotto
        ? ref.watch(calendarMottoStyleProvider).value ??
              const CalendarMottoStyle()
        : null;
    return SizedBox(
      height: 54,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (showMotto)
              Positioned.fill(
                child: Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.44,
                    child: Tooltip(
                      message: localizations.editMotto,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _editMotto(context, ref, motto),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 7,
                            ),
                            child: Text(
                              motto!,
                              key: const ValueKey('calendar-motto'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontSize: mottoStyle!.fontSize,
                                    color: Color(mottoStyle.colorValue),
                                    fontWeight: mottoStyle.bold
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    fontStyle: mottoStyle.italic
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                    decoration: mottoStyle.underline
                                        ? TextDecoration.underline
                                        : TextDecoration.none,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    key: const ValueKey('calendar-date-picker'),
                    tooltip: localizations.chooseDate,
                    onPressed: chooseDate,
                    icon: const Icon(Icons.calendar_month_outlined),
                  ),
                  IconButton(
                    tooltip: localizations.previousMonth,
                    onPressed: () => controller.showAdjacentMonth(-1),
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  IconButton(
                    tooltip: localizations.nextMonth,
                    onPressed: () => controller.showAdjacentMonth(1),
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Text(
                      key: const ValueKey('calendar-month-title'),
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: _HolidayCoverageIndicator(years: visibleYears),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactCalendarToolbar extends StatelessWidget {
  const _CompactCalendarToolbar({
    required this.title,
    required this.visibleYears,
    required this.onChooseDate,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onToday,
  });

  final String title;
  final List<int> visibleYears;
  final VoidCallback onChooseDate;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    Widget action({
      required Key key,
      required String tooltip,
      required VoidCallback onPressed,
      required IconData icon,
    }) => IconButton(
      key: key,
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 44, height: 44),
      icon: Icon(icon),
    );

    return SizedBox(
      key: const ValueKey('compact-calendar-toolbar'),
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            action(
              key: const ValueKey('calendar-date-picker'),
              tooltip: strings.chooseDate,
              onPressed: onChooseDate,
              icon: Icons.calendar_month_outlined,
            ),
            action(
              key: const ValueKey('calendar-previous-week'),
              tooltip: strings.previousWeek,
              onPressed: onPreviousWeek,
              icon: Icons.chevron_left_rounded,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      key: const ValueKey('calendar-month-title'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  _HolidayCoverageIndicator(years: visibleYears, compact: true),
                ],
              ),
            ),
            action(
              key: const ValueKey('calendar-next-week'),
              tooltip: strings.nextWeek,
              onPressed: onNextWeek,
              icon: Icons.chevron_right_rounded,
            ),
            action(
              key: const ValueKey('calendar-compact-today'),
              tooltip: strings.backToToday,
              onPressed: onToday,
              icon: Icons.today_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _editMotto(
  BuildContext context,
  WidgetRef ref,
  String currentValue,
) async {
  final value = await showDialog<String>(
    context: context,
    builder: (context) => _MottoEditorDialog(initialValue: currentValue),
  );
  if (value == null) return;
  await ref
      .read(settingsRepositoryProvider)
      .set(AppPreferenceKeys.motto, value.trim());
}

class _MottoEditorDialog extends StatefulWidget {
  const _MottoEditorDialog({required this.initialValue});

  final String initialValue;

  @override
  State<_MottoEditorDialog> createState() => _MottoEditorDialogState();
}

class _MottoEditorDialogState extends State<_MottoEditorDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(strings.mottoTitle),
      content: SizedBox(
        width: 420,
        child: TextField(
          key: const ValueKey('calendar-motto-field'),
          controller: _controller,
          autofocus: true,
          maxLength: 80,
          minLines: 2,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: strings.mottoLabel,
            alignLabelWithHint: true,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(strings.save),
        ),
      ],
    );
  }
}

LocalDate _dominantVisibleMonth(List<LocalDate> dates) {
  final counts = <(int, int), int>{};
  for (final date in dates) {
    final key = (date.year, date.month);
    counts[key] = (counts[key] ?? 0) + 1;
  }
  final orderedMonths = counts.keys.toList()
    ..sort((left, right) {
      final byYear = left.$1.compareTo(right.$1);
      return byYear != 0 ? byYear : left.$2.compareTo(right.$2);
    });
  for (final month in orderedMonths) {
    final daysInMonth = DateTime(month.$1, month.$2 + 1, 0).day;
    if (counts[month] == daysInMonth) {
      return LocalDate(month.$1, month.$2, 1);
    }
  }
  final entries = counts.entries.toList()
    ..sort((left, right) {
      final byCount = right.value.compareTo(left.value);
      if (byCount != 0) return byCount;
      final byYear = left.key.$1.compareTo(right.key.$1);
      return byYear != 0 ? byYear : left.key.$2.compareTo(right.key.$2);
    });
  return LocalDate(entries.first.key.$1, entries.first.key.$2, 1);
}

String _monthWatermarkLabel(BuildContext context, int month) {
  if (Localizations.localeOf(context).languageCode == 'zh') {
    return chineseMonthNumber(month);
  }
  return '${DateFormat.MMM('en').format(DateTime(2000, month))}.';
}

class _HolidayCoverageIndicator extends ConsumerWidget {
  const _HolidayCoverageIndicator({required this.years, this.compact = false});

  final List<int> years;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missing = <int>[];
    for (final year in years) {
      final data = ref.watch(holidayYearProvider(year));
      if (data.hasValue && data.value == null) missing.add(year);
    }
    if (missing.isEmpty) return const SizedBox.shrink();
    final strings = AppLocalizations.of(context);
    final message = strings.holidayCoverageMissing(missing.join('、'));
    return Tooltip(
      message: message,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () =>
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(message))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              if (!compact) ...[
                const SizedBox(width: 4),
                Text(
                  strings.holidayCoverageMissingShort,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DayCell extends ConsumerWidget {
  const _DayCell({
    required this.date,
    required this.selectedDate,
    required this.layout,
    this.onAndroidTap,
    this.onTaskDragStarted,
  });

  final LocalDate date;
  final LocalDate selectedDate;
  final CalendarLayout layout;
  final ValueChanged<LocalDate>? onAndroidTap;
  final VoidCallback? onTaskDragStarted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(calendarControllerProvider.notifier);
    final today = LocalDate.fromDateTime(DateTime.now());
    final selected = date == selectedDate;
    final isToday = date == today;
    final tasks = ref.watch(todosByDateProvider(date));
    final holidayYear = ref.watch(holidayYearProvider(date.year)).value;
    final holiday = holidayYear?.days
        .where((day) => day.date == date.toString())
        .firstOrNull;
    final solarTerm = ref.watch(solarTermServiceProvider).onDate(date);
    final colors = Theme.of(context).colorScheme;
    final isAndroid = ref.watch(platformCapabilitiesProvider).isAndroid;
    return DragTarget<TodoDragPayload>(
      hitTestBehavior: HitTestBehavior.translucent,
      onWillAcceptWithDetails: (details) => details.data.todo.localDate != date,
      onAcceptWithDetails: (details) =>
          _moveTodoToDate(context, ref, details.data.todo, date),
      builder: (context, candidateData, rejectedData) {
        final isDropTarget = candidateData.isNotEmpty;
        return Semantics(
          key: ValueKey('day-cell-$date'),
          button: true,
          selected: selected,
          label: date.toString(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (isAndroid) {
                onAndroidTap?.call(date);
              } else {
                controller.selectDate(date);
              }
            },
            onDoubleTap: isAndroid
                ? null
                : () => context.go(AppRoutes.dayTodosForLocalDate(date)),
            onLongPress: isAndroid
                ? () {
                    HapticFeedback.selectionClick();
                    showQuickAddTodoDialog(context, ref, date);
                  }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              decoration: BoxDecoration(
                color: isDropTarget
                    ? colors.secondaryContainer.withValues(alpha: 0.88)
                    : selected
                    ? colors.primaryContainer.withValues(alpha: 0.55)
                    : colors.surface,
                border: Border(
                  right: BorderSide(color: Theme.of(context).dividerColor),
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Stack(
                children: [
                  if (date.day == 1)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                key: ValueKey('month-watermark-$date'),
                                _monthWatermarkLabel(context, date.month),
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.visible,
                                style: TextStyle(
                                  fontFamily:
                                      Localizations.localeOf(context)
                                              .languageCode ==
                                          'zh'
                                      ? 'EchoDayMonthKai'
                                      : 'EchoDaySans',
                                  fontWeight: FontWeight.w400,
                                  fontSize: (layout.dayCellHeight * 0.54).clamp(
                                    28,
                                    88,
                                  ),
                                  height: 1,
                                  color: const Color(0xFF767171)
                                      .withValues(alpha: 0.60),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (layout.dayCellHeight < CalendarLayout.cellHeaderExtent)
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          '${date.day}',
                          maxLines: 1,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: isToday ? colors.primary : null,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(7, 5, 5, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 28,
                            child: LayoutBuilder(
                              builder: (context, constraints) => Row(
                                children: [
                                  Container(
                                    width: 26,
                                    height: 26,
                                    alignment: Alignment.center,
                                    decoration: isToday
                                        ? BoxDecoration(
                                            color: colors.primary,
                                            shape: BoxShape.circle,
                                          )
                                        : null,
                                    child: Text(
                                      '${date.day}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color: isToday
                                                ? colors.onPrimary
                                                : null,
                                            fontWeight: selected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                          ),
                                    ),
                                  ),
                                  if (constraints.maxWidth >= 66) ...[
                                    const Spacer(),
                                    IconButton(
                                      tooltip: AppLocalizations.of(context)
                                          .addTask,
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      constraints:
                                          const BoxConstraints.tightFor(
                                            width: 28,
                                            height: 28,
                                          ),
                                      onPressed: () => showQuickAddTodoDialog(
                                        context,
                                        ref,
                                        date,
                                      ),
                                      icon: const Icon(
                                        Icons.add_rounded,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 16,
                            child: Row(
                              children: [
                                if (holiday != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          (holiday.isDayOff
                                                  ? colors.error
                                                  : colors.tertiary)
                                              .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      holiday.isDayOff
                                          ? AppLocalizations.of(context)
                                                .holidayDayOff
                                          : AppLocalizations.of(context)
                                                .holidayWorkday,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            fontSize: 9,
                                            color: holiday.isDayOff
                                                ? colors.error
                                                : colors.tertiary,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      holiday.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            fontSize: 9,
                                            color: holiday.isDayOff
                                                ? colors.error
                                                : colors.tertiary,
                                          ),
                                    ),
                                  ),
                                ],
                                if (holiday != null && solarTerm != null)
                                  const SizedBox(width: 4),
                                if (solarTerm != null)
                                  Flexible(
                                    child: Text(
                                      solarTerm.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            fontSize: 9,
                                            color: colors.primary,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: tasks.when(
                              data: (items) => _TaskPreviews(
                                items: items,
                                capacity: layout.capacityFor(items.length),
                                date: date,
                                onTaskDragStarted: onTaskDragStarted,
                              ),
                              loading: () => const SizedBox.shrink(),
                              error: (error, stackTrace) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ExpandedDayCard extends ConsumerWidget {
  const _ExpandedDayCard({
    required this.date,
    required this.onCollapse,
    required this.onTaskDragStarted,
  });

  final LocalDate date;
  final VoidCallback onCollapse;
  final VoidCallback onTaskDragStarted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateLabel = DateFormat.MMM(locale)
        .format(DateTime(date.year, date.month, date.day));
    final previewLimit = ref.watch(calendarControllerProvider).previewLimit;
    final tasks = ref.watch(todosByDateProvider(date));
    final isToday = date == LocalDate.fromDateTime(DateTime.now());
    return SizedBox.expand(
      key: ValueKey('expanded-day-card-$date'),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          elevation: 10,
          shadowColor: colors.shadow.withValues(alpha: 0.32),
          color: colors.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colors.primary.withValues(alpha: 0.45)),
          ),
          clipBehavior: Clip.antiAlias,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onCollapse,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 7, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 32,
                    child: Row(
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              dateLabel,
                              maxLines: 1,
                              softWrap: false,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: isToday
                              ? BoxDecoration(
                                  color: colors.primary,
                                  shape: BoxShape.circle,
                                )
                              : null,
                          child: Text(
                            '${date.day}',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: isToday ? colors.onPrimary : null,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: localizations.addTask,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                            width: 32,
                            height: 32,
                          ),
                          onPressed: () =>
                              showQuickAddTodoDialog(context, ref, date),
                          icon: const Icon(Icons.add_rounded, size: 20),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.close_fullscreen_rounded, size: 17),
                      ],
                    ),
                  ),
                  Divider(height: 9, color: colors.outlineVariant),
                  Expanded(
                    child: tasks.when(
                      data: (items) {
                        if (items.isEmpty) {
                          return Center(
                            child: Text(
                              localizations.noTasksForDate,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: colors.outline),
                            ),
                          );
                        }
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final physicalLimit =
                                (constraints.maxHeight /
                                        CalendarLayout.todoRowExtent)
                                    .floor()
                                    .clamp(0, 6);
                            final directLimit =
                                [
                                  items.length,
                                  previewLimit,
                                  physicalLimit,
                                ].reduce(
                                  (left, right) => left < right ? left : right,
                                );
                            final visibleCount = items.length > directLimit
                                ? (directLimit - 1).clamp(0, 6)
                                : directLimit;
                            return _TaskPreviews(
                              items: items,
                              capacity: DayCellCapacity(
                                visibleTodoCount: visibleCount,
                                hiddenTodoCount: items.length - visibleCount,
                              ),
                              date: date,
                              onTaskDragStarted: onTaskDragStarted,
                              keyPrefix: 'calendar-focus',
                            );
                          },
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      error: (error, stackTrace) => const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _moveTodoToDate(
  BuildContext context,
  WidgetRef ref,
  TodoItem todo,
  LocalDate targetDate,
) async {
  try {
    await ref.read(moveTodoToDateProvider).call(todo, targetDate);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).taskMovedToDate(targetDate.toString()),
        ),
      ),
    );
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).taskActionFailed)),
    );
  }
}

class _TaskPreviews extends ConsumerWidget {
  const _TaskPreviews({
    required this.items,
    required this.capacity,
    required this.date,
    this.onTaskDragStarted,
    this.keyPrefix = 'calendar',
  });

  final List<TodoItem> items;
  final DayCellCapacity capacity;
  final LocalDate date;
  final VoidCallback? onTaskDragStarted;
  final String keyPrefix;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = ref.watch(currentTimeProvider).value ?? DateTime.now().toUtc();
    final colors = Theme.of(context).colorScheme;
    final todoFontSize =
        ref.watch(calendarTodoFontSizeProvider).value ??
        defaultCalendarTodoFontSize;
    final useLongPressDrag = ref
        .watch(platformCapabilitiesProvider)
        .supportsTouchDrag;
    final stackTimes = ref.watch(platformCapabilitiesProvider).isAndroid;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in items.take(capacity.visibleTodoCount))
          _CalendarTaskDraggable(
            item: item,
            locale: locale,
            now: now,
            fontSize: todoFontSize,
            useLongPress: useLongPressDrag,
            tooltip: localizations.dragTodoToDate,
            stackTimes: stackTimes,
            onDragStarted: onTaskDragStarted,
            keyPrefix: keyPrefix,
          ),
        if (capacity.hiddenTodoCount > 0)
          InkWell(
            onTap: () => context.go(AppRoutes.dayTodosForLocalDate(date)),
            child: SizedBox(
              height: CalendarLayout.todoRowExtent,
              child: Text(
                localizations.moreTasks(capacity.hiddenTodoCount),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(fontSize: todoFontSize, color: colors.primary),
              ),
            ),
          ),
      ],
    );
  }
}

class _CalendarTaskDraggable extends StatelessWidget {
  const _CalendarTaskDraggable({
    required this.item,
    required this.locale,
    required this.now,
    required this.fontSize,
    required this.useLongPress,
    required this.tooltip,
    required this.stackTimes,
    required this.keyPrefix,
    this.onDragStarted,
  });

  final TodoItem item;
  final String locale;
  final DateTime now;
  final double fontSize;
  final bool useLongPress;
  final String tooltip;
  final bool stackTimes;
  final String keyPrefix;
  final VoidCallback? onDragStarted;

  @override
  Widget build(BuildContext context) {
    Widget preview() => _CalendarTaskPreviewRow(
      item: item,
      locale: locale,
      now: now,
      fontSize: fontSize,
      stackTimes: stackTimes,
      keyPrefix: keyPrefix,
    );

    final feedback = _CalendarTaskDragFeedback(
      title: item.title,
      fontSize: fontSize,
    );
    final childWhenDragging = Opacity(opacity: 0.35, child: preview());
    if (useLongPress) {
      return LongPressDraggable<TodoDragPayload>(
        key: ValueKey('$keyPrefix-long-press-drag-${item.id}'),
        data: TodoDragPayload(item),
        delay: const Duration(milliseconds: 350),
        dragAnchorStrategy: pointerDragAnchorStrategy,
        rootOverlay: true,
        hapticFeedbackOnStart: true,
        onDragStarted: onDragStarted,
        feedback: feedback,
        childWhenDragging: childWhenDragging,
        child: preview(),
      );
    }
    return Draggable<TodoDragPayload>(
      data: TodoDragPayload(item),
      dragAnchorStrategy: pointerDragAnchorStrategy,
      rootOverlay: true,
      feedback: feedback,
      onDragStarted: onDragStarted,
      childWhenDragging: childWhenDragging,
      child: Tooltip(
        message: tooltip,
        child: MouseRegion(cursor: SystemMouseCursors.grab, child: preview()),
      ),
    );
  }
}

class _CalendarTaskPreviewRow extends StatelessWidget {
  const _CalendarTaskPreviewRow({
    required this.item,
    required this.locale,
    required this.now,
    required this.fontSize,
    required this.stackTimes,
    required this.keyPrefix,
  });

  final TodoItem item;
  final String locale;
  final DateTime now;
  final double fontSize;
  final bool stackTimes;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final overdue = item.isOverdueAt(now);
    final itemColor = overdue ? colors.error : null;
    return SizedBox(
      key: ValueKey('$keyPrefix-task-${item.id}'),
      height: CalendarLayout.todoRowExtent,
      child: Row(
        children: [
          if (item.plannedAt != null || item.deadlineAt != null) ...[
            Flexible(
              flex: 2,
              fit: FlexFit.loose,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: stackTimes ? 48 : 76),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: _TaskPreviewTime(
                    item: item,
                    locale: locale,
                    overdue: overdue,
                    fontSize: fontSize,
                    stackTimes: stackTimes,
                    keyPrefix: keyPrefix,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          Icon(
            item.isCompleted ? Icons.check_rounded : Icons.circle_outlined,
            size: 9,
            color: item.isCompleted
                ? colors.outline
                : itemColor ?? colors.primary,
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 3,
            child: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: fontSize,
                decoration: item.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                color: item.isCompleted ? colors.outline : itemColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarTaskDragFeedback extends StatelessWidget {
  const _CalendarTaskDragFeedback({
    required this.title,
    required this.fontSize,
  });

  final String title;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.drag_indicator_rounded, size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: fontSize),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskPreviewTime extends StatelessWidget {
  const _TaskPreviewTime({
    required this.item,
    required this.locale,
    required this.overdue,
    required this.fontSize,
    required this.stackTimes,
    required this.keyPrefix,
  });

  static const plannedColor = Color(0xFF7D8F7A);

  final TodoItem item;
  final String locale;
  final bool overdue;
  final double fontSize;
  final bool stackTimes;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final completedColor = colors.outline;
    final activeColor = overdue ? colors.error : null;
    final plannedAt = item.plannedAt;
    final deadlineAt = item.deadlineAt;
    final hasBothTimes = plannedAt != null && deadlineAt != null;
    final timeFontSize = hasBothTimes
        ? fontSize * (stackTimes ? 0.5 : 0.82)
        : fontSize;
    final baseStyle = Theme.of(context).textTheme.labelSmall
        ?.copyWith(fontSize: timeFontSize, height: 1);
    final plannedStyle = baseStyle?.copyWith(
      color: item.isCompleted ? completedColor : activeColor ?? plannedColor,
    );
    final deadlineStyle = baseStyle?.copyWith(
      color: item.isCompleted ? completedColor : activeColor ?? colors.error,
    );
    if (hasBothTimes && stackTimes) {
      return Column(
        key: ValueKey('$keyPrefix-task-time-${item.id}'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat.Hm(locale).format(plannedAt.toLocal()),
            key: ValueKey('$keyPrefix-task-planned-time-${item.id}'),
            maxLines: 1,
            style: plannedStyle,
          ),
          Text(
            DateFormat.Hm(locale).format(deadlineAt.toLocal()),
            key: ValueKey('$keyPrefix-task-deadline-time-${item.id}'),
            maxLines: 1,
            style: deadlineStyle,
          ),
        ],
      );
    }
    return Text.rich(
      TextSpan(
        children: [
          if (plannedAt != null)
            TextSpan(
              text: DateFormat.Hm(locale).format(plannedAt.toLocal()),
              style: plannedStyle,
            ),
          if (plannedAt != null && deadlineAt != null)
            TextSpan(
              text: ' - ',
              style: baseStyle?.copyWith(
                color: item.isCompleted
                    ? completedColor
                    : activeColor ?? completedColor,
              ),
            ),
          if (deadlineAt != null)
            TextSpan(
              text: DateFormat.Hm(locale).format(deadlineAt.toLocal()),
              style: deadlineStyle,
            ),
        ],
      ),
      key: ValueKey('$keyPrefix-task-time-${item.id}'),
      maxLines: 1,
    );
  }
}

class _SelectedDaySidebar extends ConsumerWidget {
  const _SelectedDaySidebar({required this.date, this.onTaskDragStarted});

  final LocalDate date;
  final VoidCallback? onTaskDragStarted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateText = DateFormat.yMMMd(locale)
        .format(DateTime(date.year, date.month, date.day));
    return DecoratedBox(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dateText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  tooltip: localizations.addTask,
                  onPressed: () => showTodoEditor(context, ref, date: date),
                  icon: const Icon(Icons.add_rounded),
                ),
                IconButton(
                  tooltip: localizations.openFullScreen,
                  onPressed: () =>
                      context.go(AppRoutes.dayTodosForLocalDate(date)),
                  icon: const Icon(Icons.open_in_full_rounded),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          Expanded(
            child: DayTodoList(
              date: date,
              compact: true,
              onTaskDragStarted: onTaskDragStarted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarSplitter extends ConsumerWidget {
  const _SidebarSplitter({
    required this.availableWidth,
    this.minimumRatio = 0.125,
  });

  final double availableWidth;
  final double minimumRatio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(calendarControllerProvider.notifier);

    KeyEventResult handleKey(FocusNode node, KeyEvent event) {
      if (event is! KeyDownEvent) return KeyEventResult.ignored;
      final current = ref
          .read(calendarControllerProvider)
          .sidebarRatio
          .clamp(minimumRatio, 0.5);
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        controller.setSidebarRatio(current - 0.025);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        controller.setSidebarRatio(current + 0.025);
      } else if (event.logicalKey == LogicalKeyboardKey.home) {
        controller.setSidebarRatio(minimumRatio);
      } else if (event.logicalKey == LogicalKeyboardKey.end) {
        controller.setSidebarRatio(0.5);
      } else {
        return KeyEventResult.ignored;
      }
      controller.persistSidebarRatio();
      return KeyEventResult.handled;
    }

    return Focus(
      onKeyEvent: handleKey,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: controller.resetSidebarRatio,
          onHorizontalDragUpdate: (details) {
            final current = ref
                .read(calendarControllerProvider)
                .sidebarRatio
                .clamp(minimumRatio, 0.5);
            controller.setSidebarRatio(
              current - details.delta.dx / availableWidth,
            );
          },
          onHorizontalDragEnd: (details) => controller.persistSidebarRatio(),
          child: SizedBox(
            key: const ValueKey('calendar-sidebar-splitter'),
            width: 8,
            child: Center(
              child: Container(width: 2, color: Theme.of(context).dividerColor),
            ),
          ),
        ),
      ),
    );
  }
}
