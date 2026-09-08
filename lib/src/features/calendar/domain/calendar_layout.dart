final class DayCellCapacity {
  const DayCellCapacity({
    required this.visibleTodoCount,
    required this.hiddenTodoCount,
  });

  final int visibleTodoCount;
  final int hiddenTodoCount;
}

final class CalendarLayout {
  const CalendarLayout({
    required this.viewportHeight,
    required this.visibleWeekCount,
    required this.dayCellHeight,
    required this.physicalTodoCapacity,
    required this.userPreviewLimit,
  });

  factory CalendarLayout.calculate({
    required double viewportHeight,
    required int visibleWeekCount,
    required int userPreviewLimit,
    double textScaleFactor = 1,
    double? dayCellWidth,
    int minimumVisibleWeekCount = minimumWeeks,
  }) {
    final minimum = minimumVisibleWeekCount.clamp(1, maximumWeeks);
    final weeks = visibleWeekCount.clamp(minimum, maximumWeeks);
    final preview = userPreviewLimit.clamp(
      minimumPreviewLimit,
      maximumPreviewLimit,
    );
    final safeHeight = viewportHeight.isFinite && viewportHeight > 0
        ? viewportHeight
        : 0.0;
    final cellHeight = safeHeight / weeks;
    final scaledRow = todoRowExtent * textScaleFactor.clamp(1, 2);
    final heightCapacity = ((cellHeight - cellHeaderExtent) / scaledRow)
        .floor()
        .clamp(0, maximumPreviewLimit);
    final widthCapacity = switch (dayCellWidth) {
      final width? when width < 44 => 0,
      final width? when width < 56 => 2,
      final width? when width < 72 => 3,
      final width? when width < 96 => 5,
      _ => maximumPreviewLimit,
    };
    final capacity = heightCapacity < widthCapacity
        ? heightCapacity
        : widthCapacity;
    return CalendarLayout(
      viewportHeight: safeHeight,
      visibleWeekCount: weeks,
      dayCellHeight: cellHeight,
      physicalTodoCapacity: capacity,
      userPreviewLimit: preview,
    );
  }

  static const int minimumWeeks = 5;
  static const int maximumWeeks = 10;
  static const int minimumPreviewLimit = 1;
  static const int maximumPreviewLimit = 12;
  static const double cellHeaderExtent = 54;
  static const double todoRowExtent = 19;

  final double viewportHeight;
  final int visibleWeekCount;
  final double dayCellHeight;
  final int physicalTodoCapacity;
  final int userPreviewLimit;

  DayCellCapacity capacityFor(int totalTodoCount) {
    if (totalTodoCount <= 0 || physicalTodoCapacity == 0) {
      return DayCellCapacity(visibleTodoCount: 0, hiddenTodoCount: 0);
    }
    final directLimit = userPreviewLimit < physicalTodoCapacity
        ? userPreviewLimit
        : physicalTodoCapacity;
    if (totalTodoCount <= directLimit) {
      return DayCellCapacity(
        visibleTodoCount: totalTodoCount,
        hiddenTodoCount: 0,
      );
    }
    final visible = (directLimit - 1).clamp(0, maximumPreviewLimit);
    return DayCellCapacity(
      visibleTodoCount: visible,
      hiddenTodoCount: totalTodoCount - visible,
    );
  }
}

double clampSidebarRatio(double value) => value.clamp(0.125, 0.5);
