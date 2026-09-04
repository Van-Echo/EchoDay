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
    return AppScaffold(
      selectedIndex: 0,
      title: localizations.calendarTitle,
      body: const _CalendarWorkspace(),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: localizations.backToToday,
        onPressed: () =>
            ref.read(calendarControllerProvider.notifier).goToToday(),
        icon: const Icon(Icons.today_rounded),
        label: Text(localizations.today),
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
    final first = dates.first;
    final last = dates.last;
    final sameMonth = first.year == last.year && first.month == last.month;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final firstText = DateFormat.yMMMM(locale)
        .format(DateTime(first.year, first.month));
    final lastText = DateFormat.yMMMM(locale)
        .format(DateTime(last.year, last.month));
    final title = sameMonth ? firstText : '$firstText — $lastText';
    final visibleYears = dates.map((date) => date.year).toSet().toList()
      ..sort();
    return SizedBox(
      height: 54,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
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
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            _HolidayCoverageIndicator(years: visibleYears),
            Text(localizations.visibleWeeks(state.visibleWeekCount)),
            IconButton(
              tooltip: localizations.showFewerWeeks,
              onPressed: state.visibleWeekCount <= 5
                  ? null
                  : () => controller.changeVisibleWeeks(-1),
              icon: const Icon(Icons.zoom_in_rounded),
            ),
            IconButton(
              tooltip: localizations.showMoreWeeks,
              onPressed: state.visibleWeekCount >= 10
                  ? null
                  : () => controller.changeVisibleWeeks(1),
              icon: const Icon(Icons.zoom_out_rounded),
            ),
          ],
        ),
      ),
    );
  }
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
            color: selected
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
                      child: Text(
                        chineseMonthNumber(date.month),
                        style: TextStyle(
                          fontFamily: 'KaiTi',
                          fontWeight: FontWeight.w500,
                          fontSize: (layout.dayCellHeight * 0.54).clamp(28, 88),
                          color: colors.onSurface.withValues(
                            alpha:
                                Theme.of(context).brightness == Brightness.light
                                ? 0.08
                                : 0.07,
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
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: isToday ? colors.onPrimary : null,
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                              ),
                            ),
                            if (constraints.maxWidth >= 66) ...[
                              const Spacer(),
                              IconButton(
                                tooltip: AppLocalizations.of(context).addTask,
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints.tightFor(
                                  width: 28,
                                  height: 28,
                                ),
                                onPressed: () =>
                                    showQuickAddTodoDialog(context, ref, date),
                                icon: const Icon(Icons.add_rounded, size: 18),
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
                                    ? AppLocalizations.of(context).holidayDayOff
                                    : AppLocalizations.of(context)
                                          .holidayWorkday,
                                style: Theme.of(context).textTheme.labelSmall
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
                                style: Theme.of(context).textTheme.labelSmall
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
                                style: Theme.of(context).textTheme.labelSmall
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
                        error: (error, stackTrace) => const SizedBox.shrink(),
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
  }
}

class _TaskPreviews extends StatelessWidget {
  const _TaskPreviews({
    required this.items,
    required this.capacity,
    required this.date,
  });

  final List<TodoItem> items;
  final DayCellCapacity capacity;
  final LocalDate date;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in items.take(capacity.visibleTodoCount))
          SizedBox(
            height: CalendarLayout.todoRowExtent,
            child: Row(
              children: [
                Icon(
                  item.isCompleted
                      ? Icons.check_rounded
                      : Icons.circle_outlined,
                  size: 9,
                  color: item.isCompleted
                      ? Theme.of(context).colorScheme.outline
                      : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      decoration: item.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: item.isCompleted
                          ? Theme.of(context).colorScheme.outline
                          : null,
                    ),
                  ),
                ),
              ],
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
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
      ],
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
