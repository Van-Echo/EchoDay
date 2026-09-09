import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../features/backup/application/backup_maintenance_service.dart';
import '../../features/backup/data/android_document_backup_file_gateway.dart';
import '../../features/backup/data/backup_directory_resolver.dart';
import '../../features/backup/data/desktop_backup_directory_gateway.dart';
import '../../features/backup/data/file_selector_backup_file_gateway.dart';
import '../../features/backup/data/local_backup_repository.dart';
import '../../features/backup/domain/backup_directory_gateway.dart';
import '../../features/backup/domain/backup_file_gateway.dart';
import '../../features/backup/domain/backup_repository.dart';
import '../../features/holidays/data/gov_cn_holiday_source.dart';
import '../../features/holidays/data/holiday_sources.dart';
import '../../features/holidays/data/layered_holiday_repository.dart';
import '../../features/holidays/domain/holiday_repository.dart';
import '../../features/holidays/domain/holiday_year.dart';
import '../../features/holidays/domain/solar_terms.dart';
import '../../features/settings/data/local_settings_repository.dart';
import '../../features/settings/domain/app_setting.dart';
import '../../features/sync/data/database_sync_change_recorder.dart';
import '../../features/sync/data/local_sync_repository.dart';
import '../../features/sync/domain/sync_change_recorder.dart';
import '../../features/sync/domain/sync_repository.dart';
import '../../features/sync/security/device_identity.dart';
import '../../features/sync/security/device_secret_store.dart';
import '../../features/sync/security/host_tls_identity.dart';
import '../../features/sync/security/sync_session_manager.dart';
import '../../features/sync/server/secure_sync_host_service.dart';
import '../../features/sync/server/sync_lan_pairing_discovery.dart';
import '../../features/sync/server/sync_network_discovery.dart';
import '../../features/todos/data/local_category_repository.dart';
import '../../features/todos/data/local_recurrence_repository.dart';
import '../../features/todos/data/local_tag_repository.dart';
import '../../features/todos/data/local_todo_repository.dart';
import '../../features/todos/domain/repositories/category_repository.dart';
import '../../features/todos/domain/repositories/recurrence_repository.dart';
import '../../features/todos/domain/repositories/tag_repository.dart';
import '../../features/todos/domain/repositories/todo_repository.dart';
import '../platform/platform_capabilities.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => unawaited(database.close()));
  return database;
});

final syncChangeRecorderProvider = Provider<SyncChangeRecorder>((ref) {
  return DatabaseSyncChangeRecorder(ref.watch(appDatabaseProvider));
});

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return LocalSyncRepository(ref.watch(appDatabaseProvider));
});

final deviceSecretStoreProvider = Provider<DeviceSecretStore>((ref) {
  return const PlatformDeviceSecretStore();
});

final deviceIdentityStoreProvider = Provider<DeviceIdentityStore>((ref) {
  return DeviceIdentityStore(ref.watch(deviceSecretStoreProvider));
});

final hostTlsIdentityStoreProvider = Provider<HostTlsIdentityStore>((ref) {
  return HostTlsIdentityStore(ref.watch(deviceSecretStoreProvider));
});

final syncSessionManagerProvider = Provider<SyncSessionManager>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return SyncSessionManager(
    publicKeyForDevice: (deviceId) => activeDevicePublicKey(database, deviceId),
  );
});

final syncNetworkDiscoveryProvider = Provider<SyncNetworkDiscovery>((ref) {
  return const SyncNetworkDiscovery();
});

final syncLanPairingDiscoveryProvider = Provider<SyncLanPairingDiscovery>((
  ref,
) {
  return const SyncLanPairingDiscovery();
});

final secureSyncHostServiceProvider = Provider<SecureSyncHostService>((ref) {
  final service = SecureSyncHostService(
    database: ref.watch(appDatabaseProvider),
    syncRepository: ref.watch(syncRepositoryProvider),
    tlsIdentityStore: ref.watch(hostTlsIdentityStoreProvider),
    sessions: ref.watch(syncSessionManagerProvider),
  );
  ref.onDispose(() => unawaited(service.stop()));
  return service;
});

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return LocalTodoRepository(
    ref.watch(appDatabaseProvider),
    syncRecorder: ref.watch(syncChangeRecorderProvider),
  );
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return LocalCategoryRepository(
    ref.watch(appDatabaseProvider),
    syncRecorder: ref.watch(syncChangeRecorderProvider),
  );
});

final recurrenceRepositoryProvider = Provider<RecurrenceRepository>((ref) {
  return LocalRecurrenceRepository(
    ref.watch(appDatabaseProvider),
    syncRecorder: ref.watch(syncChangeRecorderProvider),
  );
});

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  return LocalTagRepository(
    ref.watch(appDatabaseProvider),
    syncRecorder: ref.watch(syncChangeRecorderProvider),
  );
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return LocalSettingsRepository(ref.watch(appDatabaseProvider));
});

final backupDirectoryResolverProvider = Provider<BackupDirectoryResolver>((
  ref,
) {
  return BackupDirectoryResolver(ref.watch(settingsRepositoryProvider));
});

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  final directories = ref.watch(backupDirectoryResolverProvider);
  return LocalBackupRepository(
    ref.watch(appDatabaseProvider),
    safetyBackupDirectory: directories.safetyDirectory,
  );
});

final backupMaintenanceServiceProvider = Provider<BackupMaintenanceService>((
  ref,
) {
  return BackupMaintenanceService(
    ref.watch(backupRepositoryProvider),
    ref.watch(settingsRepositoryProvider),
    ref.watch(backupDirectoryResolverProvider),
  );
});

final backupDirectoryGatewayProvider = Provider<BackupDirectoryGateway>((ref) {
  return const DesktopBackupDirectoryGateway();
});

final backupFileGatewayProvider = Provider<BackupFileGateway>((ref) {
  if (ref.watch(platformCapabilitiesProvider).isAndroid) {
    return AndroidDocumentBackupFileGateway();
  }
  return const FileSelectorBackupFileGateway();
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
