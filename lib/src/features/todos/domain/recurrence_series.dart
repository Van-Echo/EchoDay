import 'local_date.dart';

enum RecurrenceFrequency { daily, weekdays, weekly, monthly, custom }

enum RecurrenceUnit { day, week, month }

final class RecurrenceRule {
  RecurrenceRule({
    required this.frequency,
    this.interval = 1,
    Set<int> weekDays = const {},
    this.monthDay,
    this.customUnit,
    this.untilDate,
    this.maxOccurrences,
  }) : weekDays = Set.unmodifiable(weekDays) {
    if (interval < 1) {
      throw ArgumentError.value(interval, 'interval', 'must be positive');
    }
    if (weekDays.any((day) => day < 1 || day > 7)) {
      throw ArgumentError.value(weekDays, 'weekDays', 'must use ISO 1-7');
    }
    if (monthDay != null && (monthDay! < 1 || monthDay! > 31)) {
      throw ArgumentError.value(monthDay, 'monthDay', 'must be 1-31');
    }
    if (maxOccurrences != null && maxOccurrences! < 1) {
      throw ArgumentError.value(
        maxOccurrences,
        'maxOccurrences',
        'must be positive',
      );
    }
  }

  final RecurrenceFrequency frequency;
  final int interval;
  final Set<int> weekDays;
  final int? monthDay;
  final RecurrenceUnit? customUnit;
  final LocalDate? untilDate;
  final int? maxOccurrences;
}

final class RecurrenceSeries {
  const RecurrenceSeries({
    required this.id,
    required this.startDate,
    required this.rule,
    required this.createdAt,
    required this.updatedAt,
    this.timeZoneId,
    this.deletedAt,
    this.revision = 1,
  });

  final String id;
  final LocalDate startDate;
  final RecurrenceRule rule;
  final String? timeZoneId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int revision;
}
