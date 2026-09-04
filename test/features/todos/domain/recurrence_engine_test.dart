import 'package:echoday/src/features/todos/domain/local_date.dart';
import 'package:echoday/src/features/todos/domain/recurrence_engine.dart';
import 'package:echoday/src/features/todos/domain/recurrence_series.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = RecurrenceEngine();
  const codec = RecurrenceRuleCodec();
  final start = LocalDate(2026, 9, 1);

  test('expands daily intervals with an inclusive end date', () {
    final result = engine.expand(
      startDate: start,
      rule: RecurrenceRule(
        frequency: RecurrenceFrequency.daily,
        interval: 2,
        untilDate: LocalDate(2026, 9, 7),
      ),
      fromDate: start,
      toDate: LocalDate(2026, 9, 10),
    );

    expect(result.dates.map((date) => date.toString()), [
      '2026-09-01',
      '2026-09-03',
      '2026-09-05',
      '2026-09-07',
    ]);
  });

  test('expands selected weekdays and limits occurrence count', () {
    final result = engine.expand(
      startDate: start,
      rule: RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        weekDays: {DateTime.monday, DateTime.friday},
        maxOccurrences: 3,
      ),
      fromDate: start,
      toDate: LocalDate(2026, 9, 30),
    );

    expect(result.dates.map((date) => date.toString()), [
      '2026-09-04',
      '2026-09-07',
      '2026-09-11',
    ]);
  });

  test('weekdays use the explicit fallback status', () {
    final result = engine.expand(
      startDate: LocalDate(2026, 9, 4),
      rule: RecurrenceRule(frequency: RecurrenceFrequency.weekdays),
      fromDate: LocalDate(2026, 9, 4),
      toDate: LocalDate(2026, 9, 7),
    );

    expect(result.usedFallback, isTrue);
    expect(result.dates.map((date) => date.toString()), [
      '2026-09-04',
      '2026-09-07',
    ]);
  });

  test('monthly rules skip months without the selected day', () {
    final result = engine.expand(
      startDate: LocalDate(2026, 1, 31),
      rule: RecurrenceRule(
        frequency: RecurrenceFrequency.monthly,
        monthDay: 31,
      ),
      fromDate: LocalDate(2026, 1, 1),
      toDate: LocalDate(2026, 4, 30),
    );

    expect(result.dates.map((date) => date.toString()), [
      '2026-01-31',
      '2026-03-31',
    ]);
  });

  test('rule codec round-trips every optional field', () {
    final rule = RecurrenceRule(
      frequency: RecurrenceFrequency.custom,
      interval: 3,
      weekDays: {1, 5},
      monthDay: 12,
      customUnit: RecurrenceUnit.week,
      untilDate: LocalDate(2027, 1, 1),
      maxOccurrences: 9,
    );

    final decoded = codec.decode(codec.encode(rule));
    expect(decoded.frequency, rule.frequency);
    expect(decoded.interval, 3);
    expect(decoded.weekDays, {1, 5});
    expect(decoded.monthDay, 12);
    expect(decoded.customUnit, RecurrenceUnit.week);
    expect(decoded.untilDate, LocalDate(2027, 1, 1));
    expect(decoded.maxOccurrences, 9);
  });
}
