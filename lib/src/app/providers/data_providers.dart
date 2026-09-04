import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../features/backup/data/local_backup_repository.dart';
import '../../features/backup/domain/backup_repository.dart';
import '../../features/holidays/data/gov_cn_holiday_source.dart';
import '../../features/holidays/data/holiday_sources.dart';
import '../../features/holidays/data/layered_holiday_repository.dart';
import '../../features/holidays/domain/holiday_repository.dart';
import '../../features/holidays/domain/holiday_year.dart';
import '../../features/holidays/domain/solar_terms.dart';
import '../../features/settings/data/local_settings_repository.dart';
import '../../features/settings/domain/app_setting.dart';
import '../../features/todos/data/local_category_repository.dart';
import '../../features/todos/data/local_recurrence_repository.dart';
import '../../features/todos/data/local_tag_repository.dart';
import '../../features/todos/data/local_todo_repository.dart';
import '../../features/todos/domain/repositories/category_repository.dart';
import '../../features/todos/domain/repositories/recurrence_repository.dart';
import '../../features/todos/domain/repositories/tag_repository.dart';
import '../../features/todos/domain/repositories/todo_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => unawaited(database.close()));
  return database;
});

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return LocalTodoRepository(ref.watch(appDatabaseProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return LocalCategoryRepository(ref.watch(appDatabaseProvider));
});

final recurrenceRepositoryProvider = Provider<RecurrenceRepository>((ref) {
  return LocalRecurrenceRepository(ref.watch(appDatabaseProvider));
});

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  return LocalTagRepository(ref.watch(appDatabaseProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return LocalSettingsRepository(ref.watch(appDatabaseProvider));
});

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  return LocalBackupRepository(ref.watch(appDatabaseProvider));
});

final holidayRepositoryProvider = Provider<HolidayRepository>((ref) {
  return LayeredHolidayRepository(
    CachedHolidaySource(ref.watch(appDatabaseProvider)),
    const BundledHolidaySource(),
    const GovCnHolidaySource(),
  );
});

final holidayYearProvider = FutureProvider.family<HolidayYear?, int>((
  ref,
  year,
) {
  return ref.watch(holidayRepositoryProvider).getYear(year);
});

final holidayAvailableYearsProvider = FutureProvider<Set<int>>((ref) {
  return ref.watch(holidayRepositoryProvider).getAvailableYears();
});

final solarTermServiceProvider = Provider<SolarTermService>((ref) {
  return const SolarTermService();
});
