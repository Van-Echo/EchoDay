import 'dart:convert';

import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import '../../todos/domain/local_date.dart';
import '../domain/holiday_year.dart';
import 'holiday_sources.dart';
import 'holiday_year_codec.dart';

final class GovCnHolidaySource implements RemoteHolidaySource {
  const GovCnHolidaySource([this._client]);

  static const _timeout = Duration(seconds: 15);
  static const _userAgent =
      'EchoDay/0.1 (Windows desktop calendar; official holiday update)';

  final http.Client? _client;

  @override
  Future<String?> fetchYear(int year) async {
    if (year < 2008 || year > 2200) return null;
    final ownedClient = _client == null ? http.Client() : null;
    final client = _client ?? ownedClient!;
    try {
      final candidate = await _findOfficialNotice(client, year);
      if (candidate == null) throw StateError('candidate');
      final response = await client
          .get(candidate.uri, headers: const {'User-Agent': _userAgent})
          .timeout(_timeout);
      if (response.statusCode != 200 ||
          !_isOfficialHost(response.request?.url.host ?? candidate.uri.host)) {
        throw StateError('notice response');
      }
      final text = html_parser
          .parse(utf8.decode(response.bodyBytes, allowMalformed: true))
          .body
          ?.text;
      if (text == null) throw StateError('notice body');
      final days = _parseNotice(text, year);
      if (days == null) throw StateError('notice parse');
      final checksum = HolidayYearCodec.calculateChecksum(
        year: year,
        sourceUrl: candidate.uri.toString(),
        dataVersion: candidate.dataVersion,
        days: days,
      );
      return const HolidayYearCodec().encode(
        HolidayYear(
          year: year,
          sourceUrl: candidate.uri.toString(),
          dataVersion: candidate.dataVersion,
          checksum: checksum,
          updatedAt: candidate.publishedAt,
          days: days,
        ),
      );
    } on Object {
      return null;
    } finally {
      ownedClient?.close();
    }
  }

  Future<_NoticeCandidate?> _findOfficialNotice(
    http.Client client,
    int year,
  ) async {
    final expectedTitle = '国务院办公厅关于$year年部分节假日安排的通知';
    final uri = Uri.https('sousuo.www.gov.cn', '/search-gov/data', {
      't': 'zhengcelibrary_gw',
      'q': expectedTitle,
      'searchfield': 'title',
      'sort': 'score',
      'sortType': '1',
      'p': '1',
      'n': '5',
      'type': 'gwyzcwjk',
    });
    final response = await client
        .get(uri, headers: const {'User-Agent': _userAgent})
        .timeout(_timeout);
    if (response.statusCode != 200) return null;
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic> || decoded['code'] != 200) return null;
    final search = decoded['searchVO'];
    if (search is! Map<String, dynamic> || search['listVO'] is! List) {
      return null;
    }
    for (final raw in search['listVO'] as List) {
      if (raw is! Map<String, dynamic>) continue;
      final title = _stripMarkup(raw['title'] as String? ?? '');
      final organization = raw['puborg'] as String? ?? '';
      final source = Uri.tryParse(raw['url'] as String? ?? '');
      final documentNumber = raw['pcode'] as String? ?? '';
      final publishedText = raw['pubtimeStr'] as String? ?? '';
      final timestamp = raw['ptime'];
      if (title.replaceAll(RegExp(r'\s+'), '') != expectedTitle ||
          organization != '国务院办公厅' ||
          source == null ||
          source.scheme != 'https' ||
          !_isOfficialHost(source.host) ||
          !documentNumber.startsWith('国办发明电') ||
          timestamp is! num) {
        continue;
      }
      return _NoticeCandidate(
        source,
        '$documentNumber@${publishedText.replaceAll('.', '-')}',
        DateTime.fromMillisecondsSinceEpoch(timestamp.toInt(), isUtc: true),
      );
    }
    return null;
  }

  List<HolidayDay>? _parseNotice(String source, int year) {
    final normalized = source
        .replaceAll('\u00a0', ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
    if (!normalized.replaceAll(' ', '').contains('国务院办公厅关于$year年部分节假日安排的通知')) {
      throw StateError('title parse');
    }
    const holidayNames = r'(?:元旦|春节|清明节|劳动节|端午节|国庆节、中秋节|中秋节|国庆节)';
    final sectionPattern = RegExp(
      '[一二三四五六七八九]、($holidayNames)：'
      '(.+?)(?=[一二三四五六七八九]、$holidayNames|鼓励|节假日期间|国务院办公厅)',
    );
    final sections = sectionPattern.allMatches(normalized).toList();
    final joinedNames = sections.map((match) => match.group(1)).join();
    const requiredHolidays = ['元旦', '春节', '清明', '劳动', '端午', '中秋', '国庆'];
    if (sections.length < 6 ||
        requiredHolidays.any((name) => !joinedNames.contains(name))) {
      throw StateError('sections ${sections.length}: $joinedNames');
    }

    final byDate = <LocalDate, HolidayDay>{};
    for (final section in sections) {
      final name = section.group(1)!.replaceAll('、', '/').trim();
      final body = section.group(2)!;
      var offCount = 0;
      for (final sentence in body.split('。')) {
        if (sentence.contains('放假')) {
          final prefix = sentence.substring(0, sentence.indexOf('放假'));
          final dates = _parseDates(prefix, year);
          offCount += dates.length;
          for (final date in dates) {
            byDate[date] = HolidayDay(
              date: date.toString(),
              name: name,
              isDayOff: true,
            );
          }
        }
        if (sentence.contains('上班')) {
          final prefix = sentence.substring(0, sentence.indexOf('上班'));
          for (final date in _parseDates(prefix, year)) {
            byDate[date] = HolidayDay(
              date: date.toString(),
              name: '$name调休',
              isDayOff: false,
            );
          }
        }
      }
      final claimed = RegExp(r'共(\d+)天').firstMatch(body)?.group(1);
      if (offCount == 0 ||
          (claimed != null && offCount != int.parse(claimed))) {
        throw StateError('section $name count $offCount/$claimed: $body');
      }
    }
    if (byDate.values.where((day) => day.isDayOff).length < 7) {
      throw StateError('too few dates');
    }
    final days = byDate.values.toList()
      ..sort((left, right) => left.date.compareTo(right.date));
    return List.unmodifiable(days);
  }

  List<LocalDate> _parseDates(String source, int year) {
    final withoutNotes = source.replaceAll(RegExp(r'（[^）]*）'), '');
    final pattern = RegExp(
      r'(\d{1,2})月(\d{1,2})日(?:至(?:(\d{1,2})月)?(\d{1,2})日)?',
    );
    final dates = <LocalDate>[];
    for (final match in pattern.allMatches(withoutNotes)) {
      final startMonth = int.parse(match.group(1)!);
      final startDay = int.parse(match.group(2)!);
      final endMonth = int.tryParse(match.group(3) ?? '') ?? startMonth;
      final endDay = int.tryParse(match.group(4) ?? '') ?? startDay;
      final start = DateTime.utc(year, startMonth, startDay);
      final end = DateTime.utc(year, endMonth, endDay);
      if (start.month != startMonth ||
          start.day != startDay ||
          end.month != endMonth ||
          end.day != endDay ||
          end.isBefore(start) ||
          end.difference(start).inDays > 31) {
        throw const FormatException('Invalid holiday date range.');
      }
      for (
        var value = start;
        !value.isAfter(end);
        value = value.add(const Duration(days: 1))
      ) {
        dates.add(LocalDate(value.year, value.month, value.day));
      }
    }
    return dates;
  }

  bool _isOfficialHost(String host) => host == 'www.gov.cn' || host == 'gov.cn';

  String _stripMarkup(String value) {
    return html_parser.parseFragment(value).text?.trim() ?? '';
  }
}

final class _NoticeCandidate {
  const _NoticeCandidate(this.uri, this.dataVersion, this.publishedAt);

  final Uri uri;
  final String dataVersion;
  final DateTime publishedAt;
}
