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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'echoday'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
