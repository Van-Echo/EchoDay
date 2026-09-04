import 'holiday_year.dart';

abstract interface class HolidayRepository {
  Future<HolidayYear?> getYear(int year);
  Future<HolidayRefreshResult> refresh(int year);
  Future<Set<int>> getAvailableYears();
}
