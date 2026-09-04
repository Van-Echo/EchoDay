import 'package:echoday/src/features/todos/domain/local_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalDate', () {
    test('uses strict YYYY-MM-DD round trips', () {
      final date = LocalDate.parse('2026-09-03');

      expect(date.year, 2026);
      expect(date.month, 9);
      expect(date.day, 3);
      expect(date.toString(), '2026-09-03');
    });

    test('rejects invalid or non-canonical dates', () {
      expect(() => LocalDate.parse('2026-9-3'), throwsFormatException);
      expect(() => LocalDate.parse('2026-02-29'), throwsArgumentError);
    });

    test('adds and compares across month boundaries', () {
      final lastDay = LocalDate(2026, 9, 30);

      expect(lastDay.addDays(1), LocalDate(2026, 10, 1));
      expect(lastDay.compareTo(LocalDate(2026, 10, 1)), lessThan(0));
    });
  });
}
