final class HolidayDay {
  const HolidayDay({
    required this.date,
    required this.name,
    required this.isDayOff,
  });

  final String date;
  final String name;
  final bool isDayOff;
}

final class HolidayYear {
  const HolidayYear({
    required this.year,
    required this.sourceUrl,
    required this.dataVersion,
    required this.checksum,
    required this.updatedAt,
    required this.days,
  });

  final int year;
  final String sourceUrl;
  final String dataVersion;
  final String checksum;
  final DateTime updatedAt;
  final List<HolidayDay> days;
}

enum HolidayRefreshStatus { updated, unchanged, unavailable, failedValidation }

final class HolidayRefreshResult {
  const HolidayRefreshResult(this.status, {this.year});

  final HolidayRefreshStatus status;
  final HolidayYear? year;
}
