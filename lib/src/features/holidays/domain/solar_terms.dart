import 'dart:math' as math;

import '../../todos/domain/local_date.dart';

final class SolarTerm {
  const SolarTerm(this.name, this.date);

  final String name;
  final LocalDate date;
}

final class SolarTermService {
  const SolarTermService();

  static const _names = [
    '小寒',
    '大寒',
    '立春',
    '雨水',
    '惊蛰',
    '春分',
    '清明',
    '谷雨',
    '立夏',
    '小满',
    '芒种',
    '夏至',
    '小暑',
    '大暑',
    '立秋',
    '处暑',
    '白露',
    '秋分',
    '寒露',
    '霜降',
    '立冬',
    '小雪',
    '大雪',
    '冬至',
  ];

  static const _initialDates = <(int, int)>[
    (1, 5),
    (1, 20),
    (2, 4),
    (2, 19),
    (3, 5),
    (3, 20),
    (4, 5),
    (4, 20),
    (5, 5),
    (5, 21),
    (6, 5),
    (6, 21),
    (7, 7),
    (7, 23),
    (8, 7),
    (8, 23),
    (9, 7),
    (9, 23),
    (10, 8),
    (10, 23),
    (11, 7),
    (11, 22),
    (12, 7),
    (12, 22),
  ];

  List<SolarTerm> forYear(int year) {
    if (year < 1900 || year > 2100) return const [];
    return [
      for (var index = 0; index < _names.length; index++)
        SolarTerm(_names[index], _calculateDate(year, index)),
    ];
  }

  SolarTerm? onDate(LocalDate date) {
    return forYear(date.year).where((term) => term.date == date).firstOrNull;
  }

  LocalDate _calculateDate(int year, int index) {
    final (month, day) = _initialDates[index];
    var julianDay =
        DateTime.utc(year, month, day, 12).millisecondsSinceEpoch /
            Duration.millisecondsPerDay +
        2440587.5;
    final targetLongitude = _normalize(285 + index * 15);
    for (var iteration = 0; iteration < 8; iteration++) {
      final error = _signedDifference(
        _solarLongitude(julianDay),
        targetLongitude,
      );
      julianDay -= error / 0.98564736;
    }
    final milliseconds = ((julianDay - 2440587.5) * Duration.millisecondsPerDay)
        .round();
    final chinaTime = DateTime.fromMillisecondsSinceEpoch(
      milliseconds,
      isUtc: true,
    ).add(const Duration(hours: 8));
    return LocalDate(chinaTime.year, chinaTime.month, chinaTime.day);
  }

  double _solarLongitude(double julianDay) {
    final centuries = (julianDay - 2451545) / 36525;
    final meanLongitude = _normalize(
      280.46646 + 36000.76983 * centuries + 0.0003032 * centuries * centuries,
    );
    final meanAnomaly = _toRadians(
      357.52911 + 35999.05029 * centuries - 0.0001537 * centuries * centuries,
    );
    final equation =
        math.sin(meanAnomaly) *
            (1.914602 -
                0.004817 * centuries -
                0.000014 * centuries * centuries) +
        math.sin(2 * meanAnomaly) * (0.019993 - 0.000101 * centuries) +
        math.sin(3 * meanAnomaly) * 0.000289;
    final omega = _toRadians(125.04 - 1934.136 * centuries);
    return _normalize(
      meanLongitude + equation - 0.00569 - 0.00478 * math.sin(omega),
    );
  }

  double _signedDifference(double value, double target) {
    final difference = _normalize(value - target);
    return difference > 180 ? difference - 360 : difference;
  }

  double _normalize(num value) {
    final result = value % 360;
    return result < 0 ? result + 360 : result.toDouble();
  }

  double _toRadians(num degrees) => degrees * math.pi / 180;
}
