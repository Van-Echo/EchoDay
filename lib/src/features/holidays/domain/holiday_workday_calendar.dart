import '../../todos/domain/local_date.dart';
import '../../todos/domain/recurrence_engine.dart';
import 'holiday_year.dart';

final class HolidayWorkdayCalendar implements WorkdayCalendar {
  HolidayWorkdayCalendar(Iterable<HolidayYear> years)
    : _years = {for (final year in years) year.year: year};

  final Map<int, HolidayYear> _years;

  @override
  WorkdayResult resolve(LocalDate date) {
    final year = _years[date.year];
    if (year == null) return const WeekdayFallbackCalendar().resolve(date);
    final override = year.days
        .where((day) => day.date == date.toString())
        .firstOrNull;
    if (override != null) {
      return WorkdayResult(!override.isDayOff, WorkdayKnowledge.authoritative);
    }
    final weekday = DateTime.utc(date.year, date.month, date.day).weekday;
    return WorkdayResult(
      weekday >= DateTime.monday && weekday <= DateTime.friday,
      WorkdayKnowledge.authoritative,
    );
  }
}
