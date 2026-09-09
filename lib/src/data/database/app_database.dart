import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('CategoryRow')
@TableIndex(name: 'categories_active_order', columns: {#deletedAt, #sortOrder})
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get colorValue => integer()();
  RealColumn get sortOrder => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get revision => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TagRow')
@TableIndex(name: 'tags_active_order', columns: {#deletedAt, #sortOrder})
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get colorValue => integer()();
  RealColumn get sortOrder => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get revision => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('RecurrenceSeriesRow')
class RecurrenceSeriesEntries extends Table {
  TextColumn get id => text()();
  TextColumn get startDate => text()();
  TextColumn get ruleJson => text()();
  TextColumn get timeZoneId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get revision => integer().withDefault(const Constant(1))();

  @override
  String get tableName => 'recurrence_series';

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TodoRow')
@TableIndex(name: 'todos_date_active', columns: {#localDate, #deletedAt})
@TableIndex(name: 'todos_deadline', columns: {#deadlineAt})
@TableIndex(name: 'todos_updated', columns: {#updatedAt})
@TableIndex(
  name: 'todos_active_date_completion',
  columns: {#deletedAt, #localDate, #isCompleted},
)
class Todos extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get localDate => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get plannedAt => dateTime().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(3))();
  TextColumn get categoryId => text().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get deadlineAt => dateTime().nullable()();
  TextColumn get timeZoneId => text().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  RealColumn get manualOrder => real().withDefault(const Constant(0))();
  IntColumn get revision => integer().withDefault(const Constant(1))();
  TextColumn get recurrenceSeriesId => text().nullable().references(
    RecurrenceSeriesEntries,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get occurrenceDate => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TodoTagRow')
@TableIndex(name: 'todo_tags_tag', columns: {#tagId})
class TodoTags extends Table {
  TextColumn get todoId =>
      text().references(Todos, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {todoId, tagId};
}

@DataClassName('RecurrenceExceptionRow')
@TableIndex(
  name: 'recurrence_exceptions_series_date',
  columns: {#seriesId, #occurrenceDate},
  unique: true,
)
class RecurrenceExceptions extends Table {
  TextColumn get id => text()();
  TextColumn get seriesId => text().references(
    RecurrenceSeriesEntries,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get occurrenceDate => text()();
  TextColumn get overrideJson => text().nullable()();
  BoolColumn get isSkipped => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get revision => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('HolidayYearRow')
class HolidayYears extends Table {
  IntColumn get year => integer()();
  TextColumn get sourceUrl => text()();
  TextColumn get dataVersion => text()();
  TextColumn get checksum => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {year};
}

@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get revision => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DataClassName('SyncGroupRow')
class SyncGroups extends Table {
  TextColumn get id => text()();
  TextColumn get role => text()();
  TextColumn get hostDeviceId => text()();
  IntColumn get protocolVersion => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SyncDeviceRow')
@TableIndex(
  name: 'sync_devices_group_revoked',
  columns: {#syncGroupId, #revokedAt},
)
class SyncDevices extends Table {
  TextColumn get deviceId => text()();
  TextColumn get syncGroupId =>
      text().references(SyncGroups, #id, onDelete: KeyAction.cascade)();
  TextColumn get displayName => text()();
  TextColumn get note => text().nullable()();
  TextColumn get platform => text()();
  TextColumn get appVersion => text()();
  IntColumn get protocolVersion => integer()();
  TextColumn get publicKey => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastSeenAt => dateTime().nullable()();
  DateTimeColumn get revokedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {deviceId};
}

@DataClassName('SyncPairingInviteRow')
class SyncPairingInvites extends Table {
  TextColumn get id => text()();
  TextColumn get syncGroupId =>
      text().references(SyncGroups, #id, onDelete: KeyAction.cascade)();
  TextColumn get tokenHash => text().unique()();
  TextColumn get hostFingerprint => text()();
  DateTimeColumn get expiresAt => dateTime()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  IntColumn get maximumAttempts => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get consumedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SyncChangeRow')
@TableIndex(
  name: 'sync_changes_source_sequence',
  columns: {#syncGroupId, #sourceDeviceId, #sequence},
  unique: true,
)
@TableIndex(
  name: 'sync_changes_entity',
  columns: {#syncGroupId, #entityType, #entityId},
)
@TableIndex(name: 'sync_changes_transaction', columns: {#transactionId})
class SyncChanges extends Table {
  TextColumn get operationId => text()();
  TextColumn get syncGroupId =>
      text().references(SyncGroups, #id, onDelete: KeyAction.cascade)();
  TextColumn get sourceDeviceId => text().references(SyncDevices, #deviceId)();
  IntColumn get sequence => integer()();
  TextColumn get transactionId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operationType => text()();
  TextColumn get fieldGroup => text()();
  IntColumn get payloadFormatVersion => integer()();
  TextColumn get payloadJson => text()();
  IntColumn get hlcPhysicalMs => integer()();
  IntColumn get hlcLogical => integer()();
  TextColumn get hlcDeviceId => text()();
  TextColumn get causalCursorJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get appliedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {operationId};
}

@DataClassName('SyncEntityVersionRow')
class SyncEntityVersions extends Table {
  TextColumn get syncGroupId =>
      text().references(SyncGroups, #id, onDelete: KeyAction.cascade)();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get fieldGroup => text()();
  TextColumn get winningOperationId => text()();
  IntColumn get hlcPhysicalMs => integer()();
  IntColumn get hlcLogical => integer()();
  TextColumn get hlcDeviceId => text()();
  TextColumn get causalCursorJson => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {
    syncGroupId,
    entityType,
    entityId,
    fieldGroup,
  };
}

@DataClassName('SyncRelationDotRow')
@TableIndex(
  name: 'sync_relation_dots_membership',
  columns: {#syncGroupId, #todoId, #tagId, #removedByOperationId},
)
class SyncRelationDots extends Table {
  TextColumn get syncGroupId =>
      text().references(SyncGroups, #id, onDelete: KeyAction.cascade)();
  TextColumn get todoId => text()();
  TextColumn get tagId => text()();
  TextColumn get addOperationId => text()();
  TextColumn get addedByDeviceId => text()();
  IntColumn get addedSequence => integer()();
  TextColumn get removedByOperationId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get removedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {syncGroupId, addOperationId};
}

@DataClassName('SyncCursorRow')
class SyncCursors extends Table {
  TextColumn get syncGroupId =>
      text().references(SyncGroups, #id, onDelete: KeyAction.cascade)();
  TextColumn get peerDeviceId => text()();
  TextColumn get sourceDeviceId => text()();
  IntColumn get acknowledgedSequence =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {
    syncGroupId,
    peerDeviceId,
    sourceDeviceId,
  };
}

@DataClassName('SyncConflictRow')
@TableIndex(
  name: 'sync_conflicts_unresolved',
  columns: {#syncGroupId, #resolvedAt, #createdAt},
)
class SyncConflicts extends Table {
  TextColumn get id => text()();
  TextColumn get syncGroupId =>
      text().references(SyncGroups, #id, onDelete: KeyAction.cascade)();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get fieldGroup => text()();
  TextColumn get kind => text()();
  TextColumn get winnerOperationId => text()();
  TextColumn get loserOperationId => text()();
  TextColumn get losingPayloadJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  TextColumn get resolutionOperationId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SyncRuntimeStateRow')
class SyncRuntimeStates extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    Todos,
    Categories,
    Tags,
    TodoTags,
    RecurrenceSeriesEntries,
    RecurrenceExceptions,
    HolidayYears,
    Settings,
    SyncGroups,
    SyncDevices,
    SyncPairingInvites,
    SyncChanges,
    SyncEntityVersions,
    SyncRelationDots,
    SyncCursors,
    SyncConflicts,
    SyncRuntimeStates,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: databaseName));

  AppDatabase.forTesting(super.executor);

  /// Resolves to `echoday.sqlite` inside the platform application-documents
  /// directory. On Android this is app-private, survives process restarts and
  /// upgrades, and is removed by Android when the app is uninstalled.
  static const databaseName = 'echoday';

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await customStatement(
          'CREATE INDEX todos_active_date_completion '
          'ON todos (deleted_at, local_date, is_completed)',
        );
      }
      if (from < 3) {
        await migrator.createTable(syncGroups);
        await migrator.createTable(syncDevices);
        await migrator.createTable(syncPairingInvites);
        await migrator.createTable(syncChanges);
        await migrator.createTable(syncEntityVersions);
        await migrator.createTable(syncRelationDots);
        await migrator.createTable(syncCursors);
        await migrator.createTable(syncConflicts);
        await migrator.createTable(syncRuntimeStates);
        await migrator.createIndex(syncDevicesGroupRevoked);
        await migrator.createIndex(syncChangesSourceSequence);
        await migrator.createIndex(syncChangesEntity);
        await migrator.createIndex(syncChangesTransaction);
        await migrator.createIndex(syncRelationDotsMembership);
        await migrator.createIndex(syncConflictsUnresolved);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
