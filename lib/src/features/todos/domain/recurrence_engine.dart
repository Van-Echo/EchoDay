import 'dart:convert';

import 'local_date.dart';
import 'recurrence_series.dart';

enum WorkdayKnowledge { authoritative, fallbackWeekdays }

final class WorkdayResult {
  const WorkdayResult(this.isWorkday, this.knowledge);

  final bool isWorkday;
  final WorkdayKnowledge knowledge;
}

abstract interface class WorkdayCalendar {
  WorkdayResult resolve(LocalDate date);
}

final class WeekdayFallbackCalendar implements WorkdayCalendar {
  const WeekdayFallbackCalendar();

  @override
  WorkdayResult resolve(LocalDate date) {
    final weekday = DateTime.utc(date.year, date.month, date.day).weekday;
    return WorkdayResult(
      weekday >= DateTime.monday && weekday <= DateTime.friday,
      WorkdayKnowledge.fallbackWeekdays,
    );
  }
}

final class RecurrenceExpansion {
  const RecurrenceExpansion({required this.dates, required this.usedFallback});

  final List<LocalDate> dates;
  final bool usedFallback;
}

final class RecurrenceEngine {
  const RecurrenceEngine();

  RecurrenceExpansion expand({
    required LocalDate startDate,
    required RecurrenceRule rule,
    required LocalDate fromDate,
    required LocalDate toDate,
    WorkdayCalendar calendar = const WeekdayFallbackCalendar(),
  }) {
    if (toDate.compareTo(fromDate) < 0 || toDate.compareTo(startDate) < 0) {
      return const RecurrenceExpansion(dates: [], usedFallback: false);
    }
    final dates = <LocalDate>[];
    var usedFallback = false;
    var occurrenceCount = 0;
    final effectiveFrom = fromDate.compareTo(startDate) < 0
        ? startDate
        : fromDate;
    for (
      var date = startDate;
      date.compareTo(toDate) <= 0;
      date = date.addDays(1)
    ) {
      if (rule.untilDate != null && date.compareTo(rule.untilDate!) > 0) break;
      final match = _matches(startDate, date, rule, calendar);
      usedFallback = usedFallback || match.usedFallback;
      if (!match.matches) continue;
      occurrenceCount++;
      if (rule.maxOccurrences != null &&
          occurrenceCount > rule.maxOccurrences!) {
        break;
      }
      if (date.compareTo(effectiveFrom) >= 0) dates.add(date);
    }
    return RecurrenceExpansion(dates: dates, usedFallback: usedFallback);
  }

  bool occursOn({
    required LocalDate startDate,
    required RecurrenceRule rule,
    required LocalDate date,
    WorkdayCalendar calendar = const WeekdayFallbackCalendar(),
  }) {
    return expand(
      startDate: startDate,
      rule: rule,
      fromDate: date,
      toDate: date,
      calendar: calendar,
    ).dates.isNotEmpty;
  }

  _RuleMatch _matches(
    LocalDate start,
    LocalDate date,
    RecurrenceRule rule,
    WorkdayCalendar calendar,
  ) {
    final dayDifference = _daysBetween(start, date);
    final weekDifference = dayDifference ~/ 7;
    final monthDifference =
        (date.year - start.year) * 12 + date.month - start.month;
    final weekday = DateTime.utc(date.year, date.month, date.day).weekday;
    switch (rule.frequency) {
      case RecurrenceFrequency.daily:
        return _RuleMatch(dayDifference % rule.interval == 0, false);
      case RecurrenceFrequency.weekdays:
        final result = calendar.resolve(date);
        return _RuleMatch(
          result.isWorkday,
          result.knowledge != WorkdayKnowledge.authoritative,
        );
      case RecurrenceFrequency.weekly:
        final weekDays = rule.weekDays.isEmpty
            ? {DateTime.utc(start.year, start.month, start.day).weekday}
            : rule.weekDays;
        return _RuleMatch(
          weekDifference % rule.interval == 0 && weekDays.contains(weekday),
          false,
        );
      case RecurrenceFrequency.monthly:
        return _RuleMatch(
          monthDifference % rule.interval == 0 &&
              date.day == (rule.monthDay ?? start.day),
          false,
        );
      case RecurrenceFrequency.custom:
        final matches = switch (rule.customUnit ?? RecurrenceUnit.day) {
          RecurrenceUnit.day => dayDifference % rule.interval == 0,
          RecurrenceUnit.week =>
            weekDifference % rule.interval == 0 &&
                weekday ==
                    DateTime.utc(start.year, start.month, start.day).weekday,
          RecurrenceUnit.month =>
            monthDifference % rule.interval == 0 && date.day == start.day,
        };
        return _RuleMatch(matches, false);
    }
  }
}

final class RecurrenceRuleCodec {
  const RecurrenceRuleCodec();

  String encode(RecurrenceRule rule) => jsonEncode({
    'frequency': rule.frequency.name,
    'interval': rule.interval,
    'weekDays': rule.weekDays.toList()..sort(),
    'monthDay': rule.monthDay,
    'customUnit': rule.customUnit?.name,
    'untilDate': rule.untilDate?.toString(),
    'maxOccurrences': rule.maxOccurrences,
  });

  RecurrenceRule decode(String value) {
    final json = jsonDecode(value);
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Recurrence rule must be a JSON object.');
    }
    T? enumValue<T extends Enum>(List<T> values, Object? name) {
      if (name == null) return null;
      return values.where((value) => value.name == name).firstOrNull;
    }

    final frequency = enumValue(RecurrenceFrequency.values, json['frequency']);
    if (frequency == null) throw const FormatException('Unknown frequency.');
    final rawWeekDays = json['weekDays'];
    return RecurrenceRule(
      frequency: frequency,
      interval: json['interval'] as int? ?? 1,
      weekDays: rawWeekDays is List
          ? rawWeekDays.whereType<int>().toSet()
          : const {},
      monthDay: json['monthDay'] as int?,
      customUnit: enumValue(RecurrenceUnit.values, json['customUnit']),
      untilDate: json['untilDate'] == null
          ? null
          : LocalDate.parse(json['untilDate'] as String),
      maxOccurrences: json['maxOccurrences'] as int?,
    );
  }
}

final class _RuleMatch {
  const _RuleMatch(this.matches, this.usedFallback);

  final bool matches;
  final bool usedFallback;
}

int _daysBetween(LocalDate start, LocalDate end) {
  return DateTime.utc(
    end.year,
    end.month,
    end.day,
  ).difference(DateTime.utc(start.year, start.month, start.day)).inDays;
}
