import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

final class EchoDayDateRangeResult {
  const EchoDayDateRangeResult(this.range);

  final DateTimeRange? range;
}

Future<DateTime?> showEchoDayDatePicker({
  required BuildContext context,
  required DateTime initialDate,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (context) =>
        _EchoDayDatePickerDialog(initialDate: initialDate, rangeMode: false),
  );
}

Future<EchoDayDateRangeResult?> showEchoDayDateRangePicker({
  required BuildContext context,
  DateTimeRange? initialRange,
}) {
  final now = DateTime.now();
  return showDialog<EchoDayDateRangeResult>(
    context: context,
    builder: (context) => _EchoDayDatePickerDialog(
      initialDate: initialRange?.start ?? now,
      initialRange: initialRange,
      rangeMode: true,
    ),
  );
}

class _EchoDayDatePickerDialog extends StatefulWidget {
  const _EchoDayDatePickerDialog({
    required this.initialDate,
    required this.rangeMode,
    this.initialRange,
  });

  final DateTime initialDate;
  final DateTimeRange? initialRange;
  final bool rangeMode;

  @override
  State<_EchoDayDatePickerDialog> createState() =>
      _EchoDayDatePickerDialogState();
}

class _EchoDayDatePickerDialogState extends State<_EchoDayDatePickerDialog> {
  late int _year;
  late int _month;
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    _year = widget.initialDate.year;
    _month = widget.initialDate.month;
    _start =
        widget.initialRange?.start ??
        (widget.rangeMode ? null : _dateOnly(widget.initialDate));
    _end = widget.initialRange?.end;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final first = DateTime(_year, _month, 1);
    final leading = first.weekday - DateTime.monday;
    final dayCount = DateTime(_year, _month + 1, 0).day;
    return AlertDialog(
      title: Text(
        widget.rangeMode ? strings.dateRangeLabel : strings.chooseDate,
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: strings.previousMonth,
                  onPressed: () => _shiftMonth(-1),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    key: const ValueKey('date-picker-year'),
                    initialValue: _year,
                    isDense: true,
                    decoration: InputDecoration(labelText: strings.yearLabel),
                    items: [
                      for (var year = 1970; year <= 2200; year++)
                        DropdownMenuItem(value: year, child: Text('$year')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _year = value);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    key: const ValueKey('date-picker-month'),
                    initialValue: _month,
                    isDense: true,
                    decoration: InputDecoration(labelText: strings.monthLabel),
                    items: [
                      for (var month = 1; month <= 12; month++)
                        DropdownMenuItem(
                          value: month,
                          child: Text(strings.monthValue(month)),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _month = value);
                    },
                  ),
                ),
                IconButton(
                  tooltip: strings.nextMonth,
                  onPressed: () => _shiftMonth(1),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (final weekday in [
                  strings.mondayShort,
                  strings.tuesdayShort,
                  strings.wednesdayShort,
                  strings.thursdayShort,
                  strings.fridayShort,
                  strings.saturdayShort,
                  strings.sundayShort,
                ])
                  Expanded(
                    child: Center(
                      child: Text(
                        weekday,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            GridView.builder(
              shrinkWrap: true,
              itemCount: 42,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.4,
              ),
              itemBuilder: (context, index) {
                final day = index - leading + 1;
                if (day < 1 || day > dayCount) {
                  return const SizedBox.shrink();
                }
                final date = DateTime(_year, _month, day);
                final selected = _isSelected(date);
                final inRange = _isInRange(date);
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _select(date),
                  onDoubleTap: () => _selectAndConfirm(date),
                  child: Container(
                    key: ValueKey('date-picker-day-$day'),
                    margin: const EdgeInsets.all(2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : inRange
                          ? Theme.of(context).colorScheme.primaryContainer
                                .withValues(alpha: 0.55)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: selected
                            ? Theme.of(context).colorScheme.onPrimary
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        if (widget.rangeMode)
          TextButton(
            key: const ValueKey('date-picker-clear'),
            onPressed: () =>
                Navigator.pop(context, const EchoDayDateRangeResult(null)),
            child: Text(strings.clear),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.cancel),
        ),
        FilledButton(
          key: const ValueKey('date-picker-save'),
          onPressed: _canConfirm ? _confirm : null,
          child: Text(strings.save),
        ),
      ],
    );
  }

  bool get _canConfirm => _start != null && (!widget.rangeMode || _end != null);

  void _shiftMonth(int delta) {
    final target = DateTime(_year, _month + delta);
    setState(() {
      _year = target.year;
      _month = target.month;
    });
  }

  void _select(DateTime date) {
    setState(() {
      if (!widget.rangeMode) {
        _start = date;
      } else if (_start == null || _end != null) {
        _start = date;
        _end = null;
      } else if (date.isBefore(_start!)) {
        _end = _start;
        _start = date;
      } else {
        _end = date;
      }
    });
  }

  void _selectAndConfirm(DateTime date) {
    if (!widget.rangeMode) {
      _start = date;
    } else if (_start == null || _end != null) {
      _start = date;
      _end = date;
    } else if (date.isBefore(_start!)) {
      _end = _start;
      _start = date;
    } else {
      _end = date;
    }
    _confirm();
  }

  void _confirm() {
    if (!_canConfirm) return;
    if (widget.rangeMode) {
      Navigator.pop(
        context,
        EchoDayDateRangeResult(DateTimeRange(start: _start!, end: _end!)),
      );
    } else {
      Navigator.pop(context, _start);
    }
  }

  bool _isSelected(DateTime date) =>
      _sameDate(date, _start) || _sameDate(date, _end);

  bool _isInRange(DateTime date) =>
      _start != null &&
      _end != null &&
      !date.isBefore(_start!) &&
      !date.isAfter(_end!);
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

bool _sameDate(DateTime value, DateTime? other) =>
    other != null &&
    value.year == other.year &&
    value.month == other.month &&
    value.day == other.day;
