import 'package:echoday/src/features/calendar/domain/calendar_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('five weeks divide the entire viewport without a fixed resolution', () {
    for (final height in [596.0, 1316.0, 2036.0]) {
      final layout = CalendarLayout.calculate(
        viewportHeight: height,
        visibleWeekCount: 5,
        userPreviewLimit: 6,
      );

      expect(layout.dayCellHeight * 5, closeTo(height, 0.0001));
    }
  });

  test('week and preview preferences stay within product limits', () {
    final minimum = CalendarLayout.calculate(
      viewportHeight: 600,
      visibleWeekCount: 1,
      userPreviewLimit: 0,
    );
    final maximum = CalendarLayout.calculate(
      viewportHeight: 600,
      visibleWeekCount: 20,
      userPreviewLimit: 99,
    );

    expect(minimum.visibleWeekCount, 5);
    expect(minimum.userPreviewLimit, 1);
    expect(maximum.visibleWeekCount, 10);
    expect(maximum.userPreviewLimit, 12);
  });

  test('overflow reserves one physical line for the more-items label', () {
    final layout = CalendarLayout.calculate(
      viewportHeight: 690,
      visibleWeekCount: 5,
      userPreviewLimit: 6,
    );

    expect(layout.physicalTodoCapacity, 4);
    expect(layout.capacityFor(3).visibleTodoCount, 3);
    expect(layout.capacityFor(3).hiddenTodoCount, 0);
    expect(layout.capacityFor(8).visibleTodoCount, 3);
    expect(layout.capacityFor(8).hiddenTodoCount, 5);
  });

  test('sidebar ratio is strictly limited to 12.5 through 50 percent', () {
    expect(clampSidebarRatio(-1), 0.125);
    expect(clampSidebarRatio(0.3), 0.3);
    expect(clampSidebarRatio(2), 0.5);
  });
}
