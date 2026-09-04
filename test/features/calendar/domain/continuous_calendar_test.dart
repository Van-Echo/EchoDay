import 'package:echoday/src/features/calendar/domain/continuous_calendar.dart';
import 'package:echoday/src/features/todos/domain/local_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('week starts on Monday and continuous dates cross month boundaries', () {
    final start = startOfIsoWeek(LocalDate(2026, 9, 3));
    final dates = continuousDates(start, 5);

    expect(start, LocalDate(2026, 8, 31));
    expect(dates, hasLength(35));
    expect(dates.first, LocalDate(2026, 8, 31));
    expect(dates.last, LocalDate(2026, 10, 4));
  });

  test('adjacent month preserves the day or clamps to the last day', () {
    expect(
      sameDayInAdjacentMonth(LocalDate(2026, 1, 31), 1),
      LocalDate(2026, 2, 28),
    );
    expect(
      sameDayInAdjacentMonth(LocalDate(2024, 1, 31), 1),
      LocalDate(2024, 2, 29),
    );
    expect(
      sameDayInAdjacentMonth(LocalDate(2026, 1, 15), -1),
      LocalDate(2025, 12, 15),
    );
  });

  test('Chinese month numbers omit the month suffix', () {
    expect(chineseMonthNumber(1), '一');
    expect(chineseMonthNumber(11), '十一');
    expect(chineseMonthNumber(12), '十二');
  });
}
