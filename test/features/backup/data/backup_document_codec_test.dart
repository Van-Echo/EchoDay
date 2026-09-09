import 'dart:convert';

import 'package:echoday/src/features/backup/data/backup_document_codec.dart';
import 'package:echoday/src/features/backup/domain/backup_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const codec = BackupDocumentCodec();

  test('decodes the existing minimal JSON v1 representation', () {
    const source = '''
{
  "formatVersion": 1,
  "exportedAt": "2026-09-05T12:34:56.000Z",
  "appVersion": "0.1.0",
  "data": {
    "categories": [],
    "tags": [],
    "recurrenceSeries": [],
    "todos": [],
    "todoTags": [],
    "recurrenceExceptions": []
  },
  "settings": []
}
''';

    final document = codec.decode(source);
    final encoded = jsonDecode(codec.encode(document)) as Map<String, dynamic>;

    expect(document.formatVersion, 1);
    expect(document.exportedAt, DateTime.utc(2026, 9, 5, 12, 34, 56));
    expect(document.totalRecordCount, 0);
    expect(encoded['formatVersion'], 1);
    expect((encoded['data'] as Map<String, dynamic>).keys, {
      'categories',
      'tags',
      'recurrenceSeries',
      'todos',
      'todoTags',
      'recurrenceExceptions',
    });
  });

  test('rejects an unsupported backup format version', () {
    const source = '''
{
  "formatVersion": 2,
  "exportedAt": "2026-09-05T12:34:56.000Z",
  "appVersion": "1.0.0",
  "data": {},
  "settings": []
}
''';

    expect(() => codec.decode(source), throwsA(isA<BackupFormatException>()));
  });
}
