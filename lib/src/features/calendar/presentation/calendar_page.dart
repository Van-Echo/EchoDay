import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../app/providers/data_providers.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/widgets/app_scaffold.dart';
import '../../../app/widgets/echoday_date_picker.dart';
import '../../settings/application/app_preferences.dart';
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
    final today = LocalDate.fromDateTime(DateTime.now());
    final selectedIsToday = state.selectedDate == today;
    return AppScaffold(
      selectedIndex: 0,
      title: localizations.calendarTitle,
      body: const _CalendarWorkspace(),
      floatingActionButton: Row(
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
            onPressed: () =>
                ref.read(calendarControllerProvider.notifier).goToToday(),
            icon: const Icon(Icons.today_rounded),
            label: Text(localizations.today),
          ),
        ],
      ),
    );
  }
}

class _CalendarWorkspace extends ConsumerWidget {
  const _CalendarWorkspace();

  static const double _splitterWidth = 8;
  static const double _dualPaneBreakpoint = 960;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarControllerProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        final dualPane = constraints.maxWidth >= _dualPaneBreakpoint;
        if (!dualPane) return _CalendarPane(state: state);
        final paneWidth = constraints.maxWidth - _splitterWidth;
        final sidebarWidth = paneWidth * state.sidebarRatio;
        return Row(
          children: [
            Expanded(child: _CalendarPane(state: state)),
            _SidebarSplitter(availableWidth: paneWidth),
            SizedBox(
              key: const ValueKey('selected-day-sidebar'),
              width: sidebarWidth,
              child: _SelectedDaySidebar(date: state.selectedDate),
            ),
          ],
        );
      },
    );
  }
}

class _CalendarPane extends ConsumerWidget {
  const _CalendarPane({required this.state});

  final CalendarViewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(calendarControllerProvider.notifier);
    final localizations = AppLocalizations.of(context);
    final weekdays = [
      localizations.mondayShort,
      localizations.tuesdayShort,
      localizations.wednesdayShort,
      localizations.thursdayShort,
      localizations.fridayShort,
      localizations.saturdayShort,
      localizations.sundayShort,
    ];
    return Listener(
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
          _CalendarToolbar(state: state),
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
                  visibleWeekCount: state.visibleWeekCount,
                  userPreviewLimit: state.previewLimit,
                  textScaleFactor: MediaQuery.textScalerOf(context).scale(1),
                );
                final dates = state.visibleDates;
                return Column(
                  key: const ValueKey('calendar-week-grid'),
                  children: [
                    for (var week = 0; week < state.visibleWeekCount; week++)
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
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarToolbar extends ConsumerWidget {
  const _CalendarToolbar({required this.state});

  final CalendarViewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final controller = ref.read(calendarControllerProvider.notifier);
    final dates = state.visibleDates;
    final today = LocalDate.fromDateTime(DateTime.now());
    final titleDate = state.selectedDate != today
        ? state.selectedDate
        : _dominantVisibleMonth(dates);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final title = DateFormat.yMMMM(locale)
        .format(DateTime(titleDate.year, titleDate.month));
    final visibleYears = dates.map((date) => date.year).toSet().toList()
      ..sort();
    final motto =
        ref.watch(calendarMottoProvider).value ?? defaultCalendarMotto;
    final mottoStyle =
        ref.watch(calendarMottoStyleProvider).value ??
        const CalendarMottoStyle();
    return SizedBox(
      height: 54,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Stack(
          alignment: Alignment.center,
          children: [
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
                            motto,
                            key: const ValueKey('calendar-motto'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontSize: mottoStyle.fontSize,
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
                    onPressed: () async {
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
                    },
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

class _HolidayCoverageIndicator extends ConsumerWidget {
  const _HolidayCoverageIndicator({required this.years});

  final List<int> years;

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
              const SizedBox(width: 4),
              Text(
                strings.holidayCoverageMissingShort,
                style: Theme.of(context).textTheme.labelSmall,
              ),
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
  });

  final LocalDate date;
  final LocalDate selectedDate;
  final CalendarLayout layout;

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
            onTap: () => controller.selectDate(date),
            onDoubleTap: () => context.go(AppRoutes.dayTodosForLocalDate(date)),
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
                                chineseMonthNumber(date.month),
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.visible,
                                style: TextStyle(
                                  fontFamily: 'EchoDayMonthKai',
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
                                    constraints: const BoxConstraints.tightFor(
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
  });

  final List<TodoItem> items;
  final DayCellCapacity capacity;
  final LocalDate date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = ref.watch(currentTimeProvider).value ?? DateTime.now().toUtc();
    final colors = Theme.of(context).colorScheme;
    final todoFontSize =
        ref.watch(calendarTodoFontSizeProvider).value ??
        defaultCalendarTodoFontSize;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in items.take(capacity.visibleTodoCount))
          Draggable<TodoDragPayload>(
            data: TodoDragPayload(item),
            dragAnchorStrategy: pointerDragAnchorStrategy,
            rootOverlay: true,
            feedback: _CalendarTaskDragFeedback(
              title: item.title,
              fontSize: todoFontSize,
            ),
            childWhenDragging: Opacity(
              opacity: 0.35,
              child: _CalendarTaskPreviewRow(
                item: item,
                locale: locale,
                now: now,
                fontSize: todoFontSize,
              ),
            ),
            child: Tooltip(
              message: localizations.dragTodoToDate,
              child: MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: _CalendarTaskPreviewRow(
                  item: item,
                  locale: locale,
                  now: now,
                  fontSize: todoFontSize,
                ),
              ),
            ),
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

class _CalendarTaskPreviewRow extends StatelessWidget {
  const _CalendarTaskPreviewRow({
    required this.item,
    required this.locale,
    required this.now,
    required this.fontSize,
  });

  final TodoItem item;
  final String locale;
  final DateTime now;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final overdue = item.isOverdueAt(now);
    final itemColor = overdue ? colors.error : null;
    return SizedBox(
      key: ValueKey('calendar-task-${item.id}'),
      height: CalendarLayout.todoRowExtent,
      child: Row(
        children: [
          if (item.plannedAt != null || item.deadlineAt != null) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 76),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: _TaskPreviewTime(
                  item: item,
                  locale: locale,
                  overdue: overdue,
                  fontSize: fontSize,
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
  });

  static const plannedColor = Color(0xFF7D8F7A);

  final TodoItem item;
  final String locale;
  final bool overdue;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final completedColor = colors.outline;
    final activeColor = overdue ? colors.error : null;
    final plannedAt = item.plannedAt;
    final deadlineAt = item.deadlineAt;
    final timeFontSize = (fontSize - 2).clamp(8.0, 14.0).toDouble();
    final baseStyle = Theme.of(context).textTheme.labelSmall
        ?.copyWith(fontSize: timeFontSize);
    return Text.rich(
      TextSpan(
        children: [
          if (plannedAt != null)
            TextSpan(
              text: DateFormat.Hm(locale).format(plannedAt.toLocal()),
              style: baseStyle?.copyWith(
                color: item.isCompleted
                    ? completedColor
                    : activeColor ?? plannedColor,
              ),
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
              style: baseStyle?.copyWith(
                color: item.isCompleted
                    ? completedColor
                    : activeColor ?? colors.error,
              ),
            ),
        ],
      ),
      key: ValueKey('calendar-task-time-${item.id}'),
      maxLines: 1,
    );
  }
}

class _SelectedDaySidebar extends ConsumerWidget {
  const _SelectedDaySidebar({required this.date});

  final LocalDate date;

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
          Expanded(child: DayTodoList(date: date, compact: true)),
        ],
      ),
    );
  }
}

class _SidebarSplitter extends ConsumerWidget {
  const _SidebarSplitter({required this.availableWidth});

  final double availableWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(calendarControllerProvider.notifier);

    KeyEventResult handleKey(FocusNode node, KeyEvent event) {
      if (event is! KeyDownEvent) return KeyEventResult.ignored;
      final current = ref.read(calendarControllerProvider).sidebarRatio;
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        controller.setSidebarRatio(current - 0.025);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        controller.setSidebarRatio(current + 0.025);
      } else if (event.logicalKey == LogicalKeyboardKey.home) {
        controller.setSidebarRatio(0.125);
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
            final current = ref.read(calendarControllerProvider).sidebarRatio;
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
