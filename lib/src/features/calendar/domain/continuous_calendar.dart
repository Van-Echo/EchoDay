import '../../todos/domain/local_date.dart';

LocalDate startOfIsoWeek(LocalDate date) {
  final value = DateTime.utc(date.year, date.month, date.day);
  return date.addDays(1 - value.weekday);
}

List<LocalDate> continuousDates(LocalDate firstWeekStart, int weekCount) {
  final start = startOfIsoWeek(firstWeekStart);
  final safeWeekCount = weekCount.clamp(1, 52);
  return List.generate(
    safeWeekCount * DateTime.daysPerWeek,
    start.addDays,
    growable: false,
  );
}

bool dateIsInRange(LocalDate date, LocalDate start, LocalDate end) {
  return date.compareTo(start) >= 0 && date.compareTo(end) <= 0;
}

LocalDate sameDayInAdjacentMonth(LocalDate date, int monthDelta) {
  final firstOfTarget = DateTime.utc(date.year, date.month + monthDelta);
  final firstOfFollowing = DateTime.utc(
    firstOfTarget.year,
    firstOfTarget.month + 1,
  );
  final lastDay = firstOfFollowing.subtract(const Duration(days: 1)).day;
  return LocalDate(
    firstOfTarget.year,
    firstOfTarget.month,
    date.day.clamp(1, lastDay),
  );
}

String chineseMonthNumber(int month) {
  return const [
    '一',
    '二',
    '三',
    '四',
    '五',
    '六',
    '七',
    '八',
    '九',
    '十',
    '十一',
    '十二',
  ][month - 1];
}
