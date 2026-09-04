import 'dart:convert';

import 'package:drift/native.dart';
import 'package:echoday/src/data/database/app_database.dart';
import 'package:echoday/src/features/holidays/data/gov_cn_holiday_source.dart';
import 'package:echoday/src/features/holidays/data/holiday_sources.dart';
import 'package:echoday/src/features/holidays/data/holiday_year_codec.dart';
import 'package:echoday/src/features/holidays/data/layered_holiday_repository.dart';
import 'package:echoday/src/features/holidays/domain/holiday_workday_calendar.dart';
import 'package:echoday/src/features/holidays/domain/holiday_year.dart';
import 'package:echoday/src/features/holidays/domain/solar_terms.dart';
import 'package:echoday/src/features/todos/data/local_recurrence_repository.dart';
import 'package:echoday/src/features/todos/data/local_todo_repository.dart';
import 'package:echoday/src/features/todos/domain/local_date.dart';
import 'package:echoday/src/features/todos/domain/recurrence_engine.dart';
import 'package:echoday/src/features/todos/domain/recurrence_series.dart';
import 'package:echoday/src/features/todos/domain/todo_item.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final class _RemotePayload implements RemoteHolidaySource {
  const _RemotePayload(this.payload);

  final String? payload;

  @override
  Future<String?> fetchYear(int year) async => payload;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const codec = HolidayYearCodec();

  test('bundled holiday JSON passes schema and SHA-256 validation', () async {
    final payload = await rootBundle.loadString('assets/holidays/2026.json');
    final year = codec.decode(payload);

    expect(year.year, 2026);
    expect(year.days, hasLength(39));
    expect(year.checksum, startsWith('sha256:'));
    expect(
      () => codec.decode(payload.replaceFirst('元旦', '被篡改的节日')),
      throwsFormatException,
    );
  });

  test('official adjustments override weekdays and weekends', () async {
    final payload = await rootBundle.loadString('assets/holidays/2026.json');
    final calendar = HolidayWorkdayCalendar([codec.decode(payload)]);

    final sundayShift = calendar.resolve(LocalDate(2026, 9, 20));
    expect(sundayShift.isWorkday, isTrue);
    expect(sundayShift.knowledge, WorkdayKnowledge.authoritative);

    final fridayHoliday = calendar.resolve(LocalDate(2026, 9, 25));
    expect(fridayHoliday.isWorkday, isFalse);
    expect(fridayHoliday.knowledge, WorkdayKnowledge.authoritative);

    final unknownYear = calendar.resolve(LocalDate(2027, 9, 5));
    expect(unknownYear.isWorkday, isFalse);
    expect(unknownYear.knowledge, WorkdayKnowledge.fallbackWeekdays);
  });

  test('workday recurrence consumes the cached official calendar', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final payload = await rootBundle.loadString('assets/holidays/2026.json');
    await CachedHolidaySource(database).save(codec.decode(payload));
    final recurrences = LocalRecurrenceRepository(database);
    final todos = LocalTodoRepository(database);
    final start = LocalDate(2026, 9, 18);
    final series = await recurrences.create(
      start,
      RecurrenceRule(frequency: RecurrenceFrequency.weekdays),
    );
    await todos.create(
      TodoDraft(
        title: '工作日任务',
        localDate: start,
        recurrenceSeriesId: series.id,
        occurrenceDate: start,
      ),
    );

    expect(await todos.getByDate(LocalDate(2026, 9, 20)), hasLength(1));
    expect(await todos.getByDate(LocalDate(2026, 9, 25)), isEmpty);
  });

  test('layered source caches bundled data and rejects a bad update', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final cached = CachedHolidaySource(database);
    final bundled = await rootBundle.loadString('assets/holidays/2026.json');
    final repository = LayeredHolidayRepository(
      cached,
      const BundledHolidaySource(),
      _RemotePayload(bundled.replaceFirst('元旦', '错误数据')),
    );

    expect((await repository.getYear(2026))?.year, 2026);
    expect(await cached.getYear(2026), isNotNull);
    final refresh = await repository.refresh(2026);
    expect(refresh.status, HolidayRefreshStatus.failedValidation);
    expect(refresh.year?.days.first.name, '元旦');
  });

  test(
    'government source discovers, parses and signs an official notice',
    () async {
      final client = MockClient((request) async {
        if (request.url.host == 'sousuo.www.gov.cn') {
          return http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'code': 200,
                'searchVO': {
                  'listVO': [
                    {
                      'title': '<em>国务院办公厅</em>关于2025年部分节假日安排的通知',
                      'puborg': '国务院办公厅',
                      'url': 'https://www.gov.cn/zhengce/example.htm',
                      'pcode': '国办发明电〔2024〕12号',
                      'pubtimeStr': '2024.11.12',
                      'ptime': 1731402000000,
                    },
                  ],
                },
              }),
            ),
            200,
          );
        }
        return http.Response.bytes(
          utf8.encode('''
          <html><body>
          <h1>国务院办公厅关于2025年部分节假日安排的通知</h1>
          <p>一、元旦：1月1日（周三）放假1天，不调休。</p>
          <p>二、春节：1月28日（周二）至2月4日（周二）放假调休，共8天。1月26日（周日）、2月8日（周六）上班。</p>
          <p>三、清明节：4月4日（周五）至6日（周日）放假，共3天。</p>
          <p>四、劳动节：5月1日（周四）至5日（周一）放假调休，共5天。4月27日（周日）上班。</p>
          <p>五、端午节：5月31日（周六）至6月2日（周一）放假，共3天。</p>
          <p>六、国庆节、中秋节：10月1日（周三）至8日（周三）放假调休，共8天。9月28日（周日）、10月11日（周六）上班。</p>
          <p>国务院办公厅</p>
          </body></html>
        '''),
          200,
          request: request,
        );
      });

      final payload = await GovCnHolidaySource(client).fetchYear(2025);
      final year = codec.decode(payload!);
      expect(year.sourceUrl, 'https://www.gov.cn/zhengce/example.htm');
      expect(
        year.days.where((day) => day.date == '2025-02-04').single.isDayOff,
        isTrue,
      );
      expect(
        year.days.where((day) => day.date == '2025-01-26').single.isDayOff,
        isFalse,
      );
      expect(
        year.days.where((day) => day.date == '2025-10-11').single.name,
        '国庆节/中秋节调休',
      );
    },
  );

  test(
    'refresh reports no result only when database and website both fail',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = LayeredHolidayRepository(
        CachedHolidaySource(database),
        const BundledHolidaySource(),
        const _RemotePayload(null),
      );

      final result = await repository.refresh(2030);
      expect(result.status, HolidayRefreshStatus.unavailable);
      expect(result.year, isNull);
    },
  );

  test('solar terms match the 2026 HKO calendar and guard boundaries', () {
    const service = SolarTermService();
    final dates = service
        .forYear(2026)
        .map((term) => '${term.name}:${term.date}');

    expect(dates, [
      '小寒:2026-01-05',
      '大寒:2026-01-20',
      '立春:2026-02-04',
      '雨水:2026-02-18',
      '惊蛰:2026-03-05',
      '春分:2026-03-20',
      '清明:2026-04-05',
      '谷雨:2026-04-20',
      '立夏:2026-05-05',
      '小满:2026-05-21',
      '芒种:2026-06-05',
      '夏至:2026-06-21',
      '小暑:2026-07-07',
      '大暑:2026-07-23',
      '立秋:2026-08-07',
      '处暑:2026-08-23',
      '白露:2026-09-07',
      '秋分:2026-09-23',
      '寒露:2026-10-08',
      '霜降:2026-10-23',
      '立冬:2026-11-07',
      '小雪:2026-11-22',
      '大雪:2026-12-07',
      '冬至:2026-12-22',
    ]);
    expect(service.forYear(1899), isEmpty);
    expect(service.forYear(2101), isEmpty);
    expect(service.forYear(1900), hasLength(24));
    expect(service.forYear(2100), hasLength(24));
  });
}
