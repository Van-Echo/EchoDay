final class LocalDate implements Comparable<LocalDate> {
  LocalDate(int year, int month, int day)
    : _date = DateTime.utc(year, month, day) {
    if (_date.year != year || _date.month != month || _date.day != day) {
      throw ArgumentError.value('$year-$month-$day', 'date', 'is invalid');
    }
  }

  factory LocalDate.fromDateTime(DateTime value) {
    return LocalDate(value.year, value.month, value.day);
  }

  factory LocalDate.parse(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) {
      throw FormatException('Expected a date in YYYY-MM-DD format.', value);
    }
    return LocalDate(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  final DateTime _date;

  int get year => _date.year;
  int get month => _date.month;
  int get day => _date.day;

  LocalDate addDays(int days) =>
      LocalDate.fromDateTime(_date.add(Duration(days: days)));

  @override
  int compareTo(LocalDate other) => _date.compareTo(other._date);

  @override
  String toString() {
    final monthText = month.toString().padLeft(2, '0');
    final dayText = day.toString().padLeft(2, '0');
    return '$year-$monthText-$dayText';
  }

  @override
  bool operator ==(Object other) => other is LocalDate && other._date == _date;

  @override
  int get hashCode => _date.hashCode;
}
