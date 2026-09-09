import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;

void main() {
  const expected = {
    'drift_schemas/app_database/drift_schema_v1.json':
        '669db0514ec8898bbe690d3add460c27c513320ae0d7715ba55e7d4c97507926',
    'drift_schemas/app_database/drift_schema_v2.json':
        '3e4c5d8e86039710be487187d6d9e1d46c9e60e8cda808e522af0a0ce701d1b2',
    'drift_schemas/app_database/drift_schema_v3.json':
        '7354d87ff0f312732c900e4ffb62b5ee25aa031d50ec31ea0638b9845bd3f2d7',
    'test/fixtures/migrations/schema_v1_seed.sql':
        '06cc800522455f7cdf554f6c6eb14ec74b37424bafe0e4dd4affbbd982fb8bc3',
    'test/fixtures/migrations/schema_v2_seed.sql':
        '23a090f7f48a9c3c16efd2535ce0cbcde2e2365978b01160c14dcd58e6dddd25',
    'test/fixtures/migrations/schema_v3_seed.sql':
        '6b4787eadca3c0f205fdd593d4aefc8f099a866b0d14c3a5a9e4c3845050c7ca',
  };

  test('published Drift schema snapshots remain immutable', () async {
    for (final entry in expected.entries) {
      final file = File(entry.key);
      expect(await file.exists(), isTrue, reason: '${entry.key} is missing');
      final source = await file.readAsString();
      final canonicalSource = source
          .replaceAll('\r\n', '\n')
          .replaceAll('\r', '\n');
      final digest = sha256.convert(utf8.encode(canonicalSource)).toString();
      expect(digest, entry.value, reason: '${entry.key} was modified in place');
    }
  });

  test('v1 representative seed loads into the published schema', () async {
    final database = v1.DatabaseAtV1(NativeDatabase.memory());
    addTearDown(database.close);

    await _runSeed(database, 'test/fixtures/migrations/schema_v1_seed.sql');

    expect(await database.select(database.todos).get(), hasLength(1));
    expect(await database.select(database.todoTags).get(), hasLength(1));
    expect(await database.select(database.settings).get(), hasLength(1));
  });

  test('v2 representative seed loads into the published schema', () async {
    final database = v2.DatabaseAtV2(NativeDatabase.memory());
    addTearDown(database.close);

    await _runSeed(database, 'test/fixtures/migrations/schema_v2_seed.sql');

    final todos = await database.select(database.todos).get();
    expect(todos, hasLength(1));
    expect(todos.single.isCompleted, 1);
    expect(await database.select(database.todoTags).get(), hasLength(1));
    expect(await database.select(database.settings).get(), hasLength(1));
  });

  test('v3 representative seed loads into the published schema', () async {
    final database = v3.DatabaseAtV3(NativeDatabase.memory());
    addTearDown(database.close);

    await _runSeed(database, 'test/fixtures/migrations/schema_v3_seed.sql');

    expect(await database.select(database.todos).get(), hasLength(1));
    expect(await database.select(database.syncGroups).get(), hasLength(1));
    expect(await database.select(database.syncDevices).get(), hasLength(1));
    expect(await database.select(database.syncChanges).get(), hasLength(1));
    expect(await database.select(database.syncConflicts).get(), hasLength(1));
  });
}

Future<void> _runSeed(GeneratedDatabase database, String path) async {
  final source = await File(path).readAsString();
  for (final statement in source.split(';')) {
    final sql = statement.trim();
    if (sql.isNotEmpty) await database.customStatement(sql);
  }
}
