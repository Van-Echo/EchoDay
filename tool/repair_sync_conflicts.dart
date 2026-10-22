// Explicit maintenance entrypoint; never opens the default application database.
// flutter test tool/repair_sync_conflicts.dart --dart-define=ECHODAY_CONFLICT_DB=<absolute backed-up path>
// Add --dart-define=ECHODAY_APPLY_REPAIR=true to persist audited false-positive resolutions.
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:echoday/src/data/database/app_database.dart';
import 'package:echoday/src/features/sync/data/local_sync_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'validate and optionally repair explicitly selected backed-up database',
    () async {
      const path = String.fromEnvironment('ECHODAY_CONFLICT_DB');
      const apply = bool.fromEnvironment('ECHODAY_APPLY_REPAIR');
      if (path.isEmpty || !File(path).isAbsolute || !File(path).existsSync()) {
        throw StateError(
          'Supply an existing absolute ECHODAY_CONFLICT_DB path; no default database is selected.',
        );
      }
      final database = AppDatabase.forTesting(NativeDatabase(File(path)));
      addTearDown(database.close);
      final before = await _fingerprints(database);
      final conflictsBefore = await database
          .customSelect(
            'SELECT count(*) n FROM sync_conflicts WHERE resolved_at IS NULL',
          )
          .getSingle();
      final changes = await database
          .customSelect('SELECT count(*) n FROM sync_changes')
          .getSingle();
      final tasks = await database
          .customSelect('SELECT count(*) n FROM todos')
          .getSingle();
      final repaired = apply
          ? await LocalSyncRepository(database).reconcileEquivalentConflicts()
          : 0;
      final after = await _fingerprints(database);
      expect(
        after,
        before,
        reason: 'All tables except audited conflict resolutions must remain exactly unchanged.',
      );
      final conflictsAfter = await database
          .customSelect(
            'SELECT count(*) n FROM sync_conflicts WHERE resolved_at IS NULL',
          )
          .getSingle();
      final integrity = await database
          .customSelect('PRAGMA integrity_check')
          .getSingle();
      expect(integrity.data.values.single, 'ok');
      // Counts and hashes only: never log task contents, credentials, or addresses.
      // ignore: avoid_print
      print(
        jsonEncode({
          'applied': apply,
          'repaired': repaired,
          'unresolvedBefore': conflictsBefore.read<int>('n'),
          'unresolvedAfter': conflictsAfter.read<int>('n'),
          'tasks': tasks.read<int>('n'),
          'operations': changes.read<int>('n'),
          'unchangedTables': before.length,
          'integrity': 'ok',
        }),
      );
    },
  );
}

Future<Map<String, String>> _fingerprints(AppDatabase database) async {
  final tables = await database
      .customSelect(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name <> 'sync_conflicts' ORDER BY name",
      )
      .get();
  final result = <String, String>{};
  for (final table in tables) {
    final name = table.read<String>('name');
    final escaped = name.replaceAll('"', '""');
    final rows = await database
        .customSelect('SELECT * FROM "$escaped" ORDER BY rowid')
        .get();
    result[name] = sha256
        .convert(utf8.encode(jsonEncode(rows.map((row) => row.data).toList())))
        .toString();
  }
  return result;
}
