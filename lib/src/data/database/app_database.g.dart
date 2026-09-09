// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<double> sortOrder = GeneratedColumn<double>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    colorValue,
    sortOrder,
    createdAt,
    updatedAt,
    deletedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String id;
  final String name;
  final int colorValue;
  final double sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int revision;
  const CategoryRow({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color_value'] = Variable<int>(colorValue);
    map['sort_order'] = Variable<double>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['revision'] = Variable<int>(revision);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      colorValue: Value(colorValue),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      revision: Value(revision),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      sortOrder: serializer.fromJson<double>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'colorValue': serializer.toJson<int>(colorValue),
      'sortOrder': serializer.toJson<double>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  CategoryRow copyWith({
    String? id,
    String? name,
    int? colorValue,
    double? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? revision,
  }) => CategoryRow(
    id: id ?? this.id,
    name: name ?? this.name,
    colorValue: colorValue ?? this.colorValue,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    revision: revision ?? this.revision,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    colorValue,
    sortOrder,
    createdAt,
    updatedAt,
    deletedAt,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorValue == this.colorValue &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.revision == this.revision);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> colorValue;
  final Value<double> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required int colorValue,
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       colorValue = Value(colorValue),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? colorValue,
    Expression<double>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorValue != null) 'color_value': colorValue,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? colorValue,
    Value<double>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<double>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurrenceSeriesEntriesTable extends RecurrenceSeriesEntries
    with TableInfo<$RecurrenceSeriesEntriesTable, RecurrenceSeriesRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurrenceSeriesEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruleJsonMeta = const VerificationMeta(
    'ruleJson',
  );
  @override
  late final GeneratedColumn<String> ruleJson = GeneratedColumn<String>(
    'rule_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeZoneIdMeta = const VerificationMeta(
    'timeZoneId',
  );
  @override
  late final GeneratedColumn<String> timeZoneId = GeneratedColumn<String>(
    'time_zone_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startDate,
    ruleJson,
    timeZoneId,
    createdAt,
    updatedAt,
    deletedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurrence_series';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurrenceSeriesRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('rule_json')) {
      context.handle(
        _ruleJsonMeta,
        ruleJson.isAcceptableOrUnknown(data['rule_json']!, _ruleJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleJsonMeta);
    }
    if (data.containsKey('time_zone_id')) {
      context.handle(
        _timeZoneIdMeta,
        timeZoneId.isAcceptableOrUnknown(
          data['time_zone_id']!,
          _timeZoneIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurrenceSeriesRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurrenceSeriesRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      )!,
      ruleJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_json'],
      )!,
      timeZoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_zone_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $RecurrenceSeriesEntriesTable createAlias(String alias) {
    return $RecurrenceSeriesEntriesTable(attachedDatabase, alias);
  }
}

class RecurrenceSeriesRow extends DataClass
    implements Insertable<RecurrenceSeriesRow> {
  final String id;
  final String startDate;
  final String ruleJson;
  final String? timeZoneId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int revision;
  const RecurrenceSeriesRow({
    required this.id,
    required this.startDate,
    required this.ruleJson,
    this.timeZoneId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['start_date'] = Variable<String>(startDate);
    map['rule_json'] = Variable<String>(ruleJson);
    if (!nullToAbsent || timeZoneId != null) {
      map['time_zone_id'] = Variable<String>(timeZoneId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['revision'] = Variable<int>(revision);
    return map;
  }

  RecurrenceSeriesEntriesCompanion toCompanion(bool nullToAbsent) {
    return RecurrenceSeriesEntriesCompanion(
      id: Value(id),
      startDate: Value(startDate),
      ruleJson: Value(ruleJson),
      timeZoneId: timeZoneId == null && nullToAbsent
          ? const Value.absent()
          : Value(timeZoneId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      revision: Value(revision),
    );
  }

  factory RecurrenceSeriesRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurrenceSeriesRow(
      id: serializer.fromJson<String>(json['id']),
      startDate: serializer.fromJson<String>(json['startDate']),
      ruleJson: serializer.fromJson<String>(json['ruleJson']),
      timeZoneId: serializer.fromJson<String?>(json['timeZoneId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startDate': serializer.toJson<String>(startDate),
      'ruleJson': serializer.toJson<String>(ruleJson),
      'timeZoneId': serializer.toJson<String?>(timeZoneId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  RecurrenceSeriesRow copyWith({
    String? id,
    String? startDate,
    String? ruleJson,
    Value<String?> timeZoneId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? revision,
  }) => RecurrenceSeriesRow(
    id: id ?? this.id,
    startDate: startDate ?? this.startDate,
    ruleJson: ruleJson ?? this.ruleJson,
    timeZoneId: timeZoneId.present ? timeZoneId.value : this.timeZoneId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    revision: revision ?? this.revision,
  );
  RecurrenceSeriesRow copyWithCompanion(RecurrenceSeriesEntriesCompanion data) {
    return RecurrenceSeriesRow(
      id: data.id.present ? data.id.value : this.id,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      ruleJson: data.ruleJson.present ? data.ruleJson.value : this.ruleJson,
      timeZoneId: data.timeZoneId.present
          ? data.timeZoneId.value
          : this.timeZoneId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurrenceSeriesRow(')
          ..write('id: $id, ')
          ..write('startDate: $startDate, ')
          ..write('ruleJson: $ruleJson, ')
          ..write('timeZoneId: $timeZoneId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startDate,
    ruleJson,
    timeZoneId,
    createdAt,
    updatedAt,
    deletedAt,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurrenceSeriesRow &&
          other.id == this.id &&
          other.startDate == this.startDate &&
          other.ruleJson == this.ruleJson &&
          other.timeZoneId == this.timeZoneId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.revision == this.revision);
}

class RecurrenceSeriesEntriesCompanion
    extends UpdateCompanion<RecurrenceSeriesRow> {
  final Value<String> id;
  final Value<String> startDate;
  final Value<String> ruleJson;
  final Value<String?> timeZoneId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const RecurrenceSeriesEntriesCompanion({
    this.id = const Value.absent(),
    this.startDate = const Value.absent(),
    this.ruleJson = const Value.absent(),
    this.timeZoneId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurrenceSeriesEntriesCompanion.insert({
    required String id,
    required String startDate,
    required String ruleJson,
    this.timeZoneId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startDate = Value(startDate),
       ruleJson = Value(ruleJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<RecurrenceSeriesRow> custom({
    Expression<String>? id,
    Expression<String>? startDate,
    Expression<String>? ruleJson,
    Expression<String>? timeZoneId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startDate != null) 'start_date': startDate,
      if (ruleJson != null) 'rule_json': ruleJson,
      if (timeZoneId != null) 'time_zone_id': timeZoneId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurrenceSeriesEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? startDate,
    Value<String>? ruleJson,
    Value<String?>? timeZoneId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return RecurrenceSeriesEntriesCompanion(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      ruleJson: ruleJson ?? this.ruleJson,
      timeZoneId: timeZoneId ?? this.timeZoneId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (ruleJson.present) {
      map['rule_json'] = Variable<String>(ruleJson.value);
    }
    if (timeZoneId.present) {
      map['time_zone_id'] = Variable<String>(timeZoneId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurrenceSeriesEntriesCompanion(')
          ..write('id: $id, ')
          ..write('startDate: $startDate, ')
          ..write('ruleJson: $ruleJson, ')
          ..write('timeZoneId: $timeZoneId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TodosTable extends Todos with TableInfo<$TodosTable, TodoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedAtMeta = const VerificationMeta(
    'plannedAt',
  );
  @override
  late final GeneratedColumn<DateTime> plannedAt = GeneratedColumn<DateTime>(
    'planned_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deadlineAtMeta = const VerificationMeta(
    'deadlineAt',
  );
  @override
  late final GeneratedColumn<DateTime> deadlineAt = GeneratedColumn<DateTime>(
    'deadline_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeZoneIdMeta = const VerificationMeta(
    'timeZoneId',
  );
  @override
  late final GeneratedColumn<String> timeZoneId = GeneratedColumn<String>(
    'time_zone_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _manualOrderMeta = const VerificationMeta(
    'manualOrder',
  );
  @override
  late final GeneratedColumn<double> manualOrder = GeneratedColumn<double>(
    'manual_order',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _recurrenceSeriesIdMeta =
      const VerificationMeta('recurrenceSeriesId');
  @override
  late final GeneratedColumn<String> recurrenceSeriesId =
      GeneratedColumn<String>(
        'recurrence_series_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES recurrence_series (id) ON DELETE SET NULL',
        ),
      );
  static const VerificationMeta _occurrenceDateMeta = const VerificationMeta(
    'occurrenceDate',
  );
  @override
  late final GeneratedColumn<String> occurrenceDate = GeneratedColumn<String>(
    'occurrence_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    localDate,
    isCompleted,
    createdAt,
    updatedAt,
    plannedAt,
    priority,
    categoryId,
    notes,
    deadlineAt,
    timeZoneId,
    completedAt,
    deletedAt,
    manualOrder,
    revision,
    recurrenceSeriesId,
    occurrenceDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todos';
  @override
  VerificationContext validateIntegrity(
    Insertable<TodoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('planned_at')) {
      context.handle(
        _plannedAtMeta,
        plannedAt.isAcceptableOrUnknown(data['planned_at']!, _plannedAtMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('deadline_at')) {
      context.handle(
        _deadlineAtMeta,
        deadlineAt.isAcceptableOrUnknown(data['deadline_at']!, _deadlineAtMeta),
      );
    }
    if (data.containsKey('time_zone_id')) {
      context.handle(
        _timeZoneIdMeta,
        timeZoneId.isAcceptableOrUnknown(
          data['time_zone_id']!,
          _timeZoneIdMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('manual_order')) {
      context.handle(
        _manualOrderMeta,
        manualOrder.isAcceptableOrUnknown(
          data['manual_order']!,
          _manualOrderMeta,
        ),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('recurrence_series_id')) {
      context.handle(
        _recurrenceSeriesIdMeta,
        recurrenceSeriesId.isAcceptableOrUnknown(
          data['recurrence_series_id']!,
          _recurrenceSeriesIdMeta,
        ),
      );
    }
    if (data.containsKey('occurrence_date')) {
      context.handle(
        _occurrenceDateMeta,
        occurrenceDate.isAcceptableOrUnknown(
          data['occurrence_date']!,
          _occurrenceDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TodoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TodoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      plannedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}planned_at'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      deadlineAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deadline_at'],
      ),
      timeZoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_zone_id'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      manualOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}manual_order'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      recurrenceSeriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_series_id'],
      ),
      occurrenceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurrence_date'],
      ),
    );
  }

  @override
  $TodosTable createAlias(String alias) {
    return $TodosTable(attachedDatabase, alias);
  }
}

class TodoRow extends DataClass implements Insertable<TodoRow> {
  final String id;
  final String title;
  final String localDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? plannedAt;
  final int priority;
  final String? categoryId;
  final String? notes;
  final DateTime? deadlineAt;
  final String? timeZoneId;
  final DateTime? completedAt;
  final DateTime? deletedAt;
  final double manualOrder;
  final int revision;
  final String? recurrenceSeriesId;
  final String? occurrenceDate;
  const TodoRow({
    required this.id,
    required this.title,
    required this.localDate,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.plannedAt,
    required this.priority,
    this.categoryId,
    this.notes,
    this.deadlineAt,
    this.timeZoneId,
    this.completedAt,
    this.deletedAt,
    required this.manualOrder,
    required this.revision,
    this.recurrenceSeriesId,
    this.occurrenceDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['local_date'] = Variable<String>(localDate);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || plannedAt != null) {
      map['planned_at'] = Variable<DateTime>(plannedAt);
    }
    map['priority'] = Variable<int>(priority);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || deadlineAt != null) {
      map['deadline_at'] = Variable<DateTime>(deadlineAt);
    }
    if (!nullToAbsent || timeZoneId != null) {
      map['time_zone_id'] = Variable<String>(timeZoneId);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['manual_order'] = Variable<double>(manualOrder);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || recurrenceSeriesId != null) {
      map['recurrence_series_id'] = Variable<String>(recurrenceSeriesId);
    }
    if (!nullToAbsent || occurrenceDate != null) {
      map['occurrence_date'] = Variable<String>(occurrenceDate);
    }
    return map;
  }

  TodosCompanion toCompanion(bool nullToAbsent) {
    return TodosCompanion(
      id: Value(id),
      title: Value(title),
      localDate: Value(localDate),
      isCompleted: Value(isCompleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      plannedAt: plannedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedAt),
      priority: Value(priority),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      deadlineAt: deadlineAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deadlineAt),
      timeZoneId: timeZoneId == null && nullToAbsent
          ? const Value.absent()
          : Value(timeZoneId),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      manualOrder: Value(manualOrder),
      revision: Value(revision),
      recurrenceSeriesId: recurrenceSeriesId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceSeriesId),
      occurrenceDate: occurrenceDate == null && nullToAbsent
          ? const Value.absent()
          : Value(occurrenceDate),
    );
  }

  factory TodoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TodoRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      localDate: serializer.fromJson<String>(json['localDate']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      plannedAt: serializer.fromJson<DateTime?>(json['plannedAt']),
      priority: serializer.fromJson<int>(json['priority']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      notes: serializer.fromJson<String?>(json['notes']),
      deadlineAt: serializer.fromJson<DateTime?>(json['deadlineAt']),
      timeZoneId: serializer.fromJson<String?>(json['timeZoneId']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      manualOrder: serializer.fromJson<double>(json['manualOrder']),
      revision: serializer.fromJson<int>(json['revision']),
      recurrenceSeriesId: serializer.fromJson<String?>(
        json['recurrenceSeriesId'],
      ),
      occurrenceDate: serializer.fromJson<String?>(json['occurrenceDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'localDate': serializer.toJson<String>(localDate),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'plannedAt': serializer.toJson<DateTime?>(plannedAt),
      'priority': serializer.toJson<int>(priority),
      'categoryId': serializer.toJson<String?>(categoryId),
      'notes': serializer.toJson<String?>(notes),
      'deadlineAt': serializer.toJson<DateTime?>(deadlineAt),
      'timeZoneId': serializer.toJson<String?>(timeZoneId),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'manualOrder': serializer.toJson<double>(manualOrder),
      'revision': serializer.toJson<int>(revision),
      'recurrenceSeriesId': serializer.toJson<String?>(recurrenceSeriesId),
      'occurrenceDate': serializer.toJson<String?>(occurrenceDate),
    };
  }

  TodoRow copyWith({
    String? id,
    String? title,
    String? localDate,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> plannedAt = const Value.absent(),
    int? priority,
    Value<String?> categoryId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> deadlineAt = const Value.absent(),
    Value<String?> timeZoneId = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    double? manualOrder,
    int? revision,
    Value<String?> recurrenceSeriesId = const Value.absent(),
    Value<String?> occurrenceDate = const Value.absent(),
  }) => TodoRow(
    id: id ?? this.id,
    title: title ?? this.title,
    localDate: localDate ?? this.localDate,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    plannedAt: plannedAt.present ? plannedAt.value : this.plannedAt,
    priority: priority ?? this.priority,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    notes: notes.present ? notes.value : this.notes,
    deadlineAt: deadlineAt.present ? deadlineAt.value : this.deadlineAt,
    timeZoneId: timeZoneId.present ? timeZoneId.value : this.timeZoneId,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    manualOrder: manualOrder ?? this.manualOrder,
    revision: revision ?? this.revision,
    recurrenceSeriesId: recurrenceSeriesId.present
        ? recurrenceSeriesId.value
        : this.recurrenceSeriesId,
    occurrenceDate: occurrenceDate.present
        ? occurrenceDate.value
        : this.occurrenceDate,
  );
  TodoRow copyWithCompanion(TodosCompanion data) {
    return TodoRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      plannedAt: data.plannedAt.present ? data.plannedAt.value : this.plannedAt,
      priority: data.priority.present ? data.priority.value : this.priority,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      notes: data.notes.present ? data.notes.value : this.notes,
      deadlineAt: data.deadlineAt.present
          ? data.deadlineAt.value
          : this.deadlineAt,
      timeZoneId: data.timeZoneId.present
          ? data.timeZoneId.value
          : this.timeZoneId,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      manualOrder: data.manualOrder.present
          ? data.manualOrder.value
          : this.manualOrder,
      revision: data.revision.present ? data.revision.value : this.revision,
      recurrenceSeriesId: data.recurrenceSeriesId.present
          ? data.recurrenceSeriesId.value
          : this.recurrenceSeriesId,
      occurrenceDate: data.occurrenceDate.present
          ? data.occurrenceDate.value
          : this.occurrenceDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TodoRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('localDate: $localDate, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('plannedAt: $plannedAt, ')
          ..write('priority: $priority, ')
          ..write('categoryId: $categoryId, ')
          ..write('notes: $notes, ')
          ..write('deadlineAt: $deadlineAt, ')
          ..write('timeZoneId: $timeZoneId, ')
          ..write('completedAt: $completedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('manualOrder: $manualOrder, ')
          ..write('revision: $revision, ')
          ..write('recurrenceSeriesId: $recurrenceSeriesId, ')
          ..write('occurrenceDate: $occurrenceDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    localDate,
    isCompleted,
    createdAt,
    updatedAt,
    plannedAt,
    priority,
    categoryId,
    notes,
    deadlineAt,
    timeZoneId,
    completedAt,
    deletedAt,
    manualOrder,
    revision,
    recurrenceSeriesId,
    occurrenceDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TodoRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.localDate == this.localDate &&
          other.isCompleted == this.isCompleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.plannedAt == this.plannedAt &&
          other.priority == this.priority &&
          other.categoryId == this.categoryId &&
          other.notes == this.notes &&
          other.deadlineAt == this.deadlineAt &&
          other.timeZoneId == this.timeZoneId &&
          other.completedAt == this.completedAt &&
          other.deletedAt == this.deletedAt &&
          other.manualOrder == this.manualOrder &&
          other.revision == this.revision &&
          other.recurrenceSeriesId == this.recurrenceSeriesId &&
          other.occurrenceDate == this.occurrenceDate);
}

class TodosCompanion extends UpdateCompanion<TodoRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> localDate;
  final Value<bool> isCompleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> plannedAt;
  final Value<int> priority;
  final Value<String?> categoryId;
  final Value<String?> notes;
  final Value<DateTime?> deadlineAt;
  final Value<String?> timeZoneId;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> deletedAt;
  final Value<double> manualOrder;
  final Value<int> revision;
  final Value<String?> recurrenceSeriesId;
  final Value<String?> occurrenceDate;
  final Value<int> rowid;
  const TodosCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.localDate = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.plannedAt = const Value.absent(),
    this.priority = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.notes = const Value.absent(),
    this.deadlineAt = const Value.absent(),
    this.timeZoneId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.manualOrder = const Value.absent(),
    this.revision = const Value.absent(),
    this.recurrenceSeriesId = const Value.absent(),
    this.occurrenceDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TodosCompanion.insert({
    required String id,
    required String title,
    required String localDate,
    this.isCompleted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.plannedAt = const Value.absent(),
    this.priority = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.notes = const Value.absent(),
    this.deadlineAt = const Value.absent(),
    this.timeZoneId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.manualOrder = const Value.absent(),
    this.revision = const Value.absent(),
    this.recurrenceSeriesId = const Value.absent(),
    this.occurrenceDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       localDate = Value(localDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TodoRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? localDate,
    Expression<bool>? isCompleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? plannedAt,
    Expression<int>? priority,
    Expression<String>? categoryId,
    Expression<String>? notes,
    Expression<DateTime>? deadlineAt,
    Expression<String>? timeZoneId,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? deletedAt,
    Expression<double>? manualOrder,
    Expression<int>? revision,
    Expression<String>? recurrenceSeriesId,
    Expression<String>? occurrenceDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (localDate != null) 'local_date': localDate,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (plannedAt != null) 'planned_at': plannedAt,
      if (priority != null) 'priority': priority,
      if (categoryId != null) 'category_id': categoryId,
      if (notes != null) 'notes': notes,
      if (deadlineAt != null) 'deadline_at': deadlineAt,
      if (timeZoneId != null) 'time_zone_id': timeZoneId,
      if (completedAt != null) 'completed_at': completedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (manualOrder != null) 'manual_order': manualOrder,
      if (revision != null) 'revision': revision,
      if (recurrenceSeriesId != null)
        'recurrence_series_id': recurrenceSeriesId,
      if (occurrenceDate != null) 'occurrence_date': occurrenceDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TodosCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? localDate,
    Value<bool>? isCompleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? plannedAt,
    Value<int>? priority,
    Value<String?>? categoryId,
    Value<String?>? notes,
    Value<DateTime?>? deadlineAt,
    Value<String?>? timeZoneId,
    Value<DateTime?>? completedAt,
    Value<DateTime?>? deletedAt,
    Value<double>? manualOrder,
    Value<int>? revision,
    Value<String?>? recurrenceSeriesId,
    Value<String?>? occurrenceDate,
    Value<int>? rowid,
  }) {
    return TodosCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      localDate: localDate ?? this.localDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      plannedAt: plannedAt ?? this.plannedAt,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      notes: notes ?? this.notes,
      deadlineAt: deadlineAt ?? this.deadlineAt,
      timeZoneId: timeZoneId ?? this.timeZoneId,
      completedAt: completedAt ?? this.completedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      manualOrder: manualOrder ?? this.manualOrder,
      revision: revision ?? this.revision,
      recurrenceSeriesId: recurrenceSeriesId ?? this.recurrenceSeriesId,
      occurrenceDate: occurrenceDate ?? this.occurrenceDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (plannedAt.present) {
      map['planned_at'] = Variable<DateTime>(plannedAt.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (deadlineAt.present) {
      map['deadline_at'] = Variable<DateTime>(deadlineAt.value);
    }
    if (timeZoneId.present) {
      map['time_zone_id'] = Variable<String>(timeZoneId.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (manualOrder.present) {
      map['manual_order'] = Variable<double>(manualOrder.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (recurrenceSeriesId.present) {
      map['recurrence_series_id'] = Variable<String>(recurrenceSeriesId.value);
    }
    if (occurrenceDate.present) {
      map['occurrence_date'] = Variable<String>(occurrenceDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodosCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('localDate: $localDate, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('plannedAt: $plannedAt, ')
          ..write('priority: $priority, ')
          ..write('categoryId: $categoryId, ')
          ..write('notes: $notes, ')
          ..write('deadlineAt: $deadlineAt, ')
          ..write('timeZoneId: $timeZoneId, ')
          ..write('completedAt: $completedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('manualOrder: $manualOrder, ')
          ..write('revision: $revision, ')
          ..write('recurrenceSeriesId: $recurrenceSeriesId, ')
          ..write('occurrenceDate: $occurrenceDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, TagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<double> sortOrder = GeneratedColumn<double>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    colorValue,
    sortOrder,
    createdAt,
    updatedAt,
    deletedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class TagRow extends DataClass implements Insertable<TagRow> {
  final String id;
  final String name;
  final int colorValue;
  final double sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int revision;
  const TagRow({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color_value'] = Variable<int>(colorValue);
    map['sort_order'] = Variable<double>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['revision'] = Variable<int>(revision);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      colorValue: Value(colorValue),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      revision: Value(revision),
    );
  }

  factory TagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      sortOrder: serializer.fromJson<double>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'colorValue': serializer.toJson<int>(colorValue),
      'sortOrder': serializer.toJson<double>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  TagRow copyWith({
    String? id,
    String? name,
    int? colorValue,
    double? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? revision,
  }) => TagRow(
    id: id ?? this.id,
    name: name ?? this.name,
    colorValue: colorValue ?? this.colorValue,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    revision: revision ?? this.revision,
  );
  TagRow copyWithCompanion(TagsCompanion data) {
    return TagRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    colorValue,
    sortOrder,
    createdAt,
    updatedAt,
    deletedAt,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorValue == this.colorValue &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.revision == this.revision);
}

class TagsCompanion extends UpdateCompanion<TagRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> colorValue;
  final Value<double> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    required int colorValue,
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       colorValue = Value(colorValue),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TagRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? colorValue,
    Expression<double>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorValue != null) 'color_value': colorValue,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? colorValue,
    Value<double>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<double>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TodoTagsTable extends TodoTags
    with TableInfo<$TodoTagsTable, TodoTagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodoTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _todoIdMeta = const VerificationMeta('todoId');
  @override
  late final GeneratedColumn<String> todoId = GeneratedColumn<String>(
    'todo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES todos (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [todoId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todo_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TodoTagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('todo_id')) {
      context.handle(
        _todoIdMeta,
        todoId.isAcceptableOrUnknown(data['todo_id']!, _todoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_todoIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {todoId, tagId};
  @override
  TodoTagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TodoTagRow(
      todoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}todo_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $TodoTagsTable createAlias(String alias) {
    return $TodoTagsTable(attachedDatabase, alias);
  }
}

class TodoTagRow extends DataClass implements Insertable<TodoTagRow> {
  final String todoId;
  final String tagId;
  const TodoTagRow({required this.todoId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['todo_id'] = Variable<String>(todoId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  TodoTagsCompanion toCompanion(bool nullToAbsent) {
    return TodoTagsCompanion(todoId: Value(todoId), tagId: Value(tagId));
  }

  factory TodoTagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TodoTagRow(
      todoId: serializer.fromJson<String>(json['todoId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'todoId': serializer.toJson<String>(todoId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  TodoTagRow copyWith({String? todoId, String? tagId}) =>
      TodoTagRow(todoId: todoId ?? this.todoId, tagId: tagId ?? this.tagId);
  TodoTagRow copyWithCompanion(TodoTagsCompanion data) {
    return TodoTagRow(
      todoId: data.todoId.present ? data.todoId.value : this.todoId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TodoTagRow(')
          ..write('todoId: $todoId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(todoId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TodoTagRow &&
          other.todoId == this.todoId &&
          other.tagId == this.tagId);
}

class TodoTagsCompanion extends UpdateCompanion<TodoTagRow> {
  final Value<String> todoId;
  final Value<String> tagId;
  final Value<int> rowid;
  const TodoTagsCompanion({
    this.todoId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TodoTagsCompanion.insert({
    required String todoId,
    required String tagId,
    this.rowid = const Value.absent(),
  }) : todoId = Value(todoId),
       tagId = Value(tagId);
  static Insertable<TodoTagRow> custom({
    Expression<String>? todoId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (todoId != null) 'todo_id': todoId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TodoTagsCompanion copyWith({
    Value<String>? todoId,
    Value<String>? tagId,
    Value<int>? rowid,
  }) {
    return TodoTagsCompanion(
      todoId: todoId ?? this.todoId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (todoId.present) {
      map['todo_id'] = Variable<String>(todoId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodoTagsCompanion(')
          ..write('todoId: $todoId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurrenceExceptionsTable extends RecurrenceExceptions
    with TableInfo<$RecurrenceExceptionsTable, RecurrenceExceptionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurrenceExceptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<String> seriesId = GeneratedColumn<String>(
    'series_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recurrence_series (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _occurrenceDateMeta = const VerificationMeta(
    'occurrenceDate',
  );
  @override
  late final GeneratedColumn<String> occurrenceDate = GeneratedColumn<String>(
    'occurrence_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _overrideJsonMeta = const VerificationMeta(
    'overrideJson',
  );
  @override
  late final GeneratedColumn<String> overrideJson = GeneratedColumn<String>(
    'override_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSkippedMeta = const VerificationMeta(
    'isSkipped',
  );
  @override
  late final GeneratedColumn<bool> isSkipped = GeneratedColumn<bool>(
    'is_skipped',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_skipped" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    seriesId,
    occurrenceDate,
    overrideJson,
    isSkipped,
    createdAt,
    updatedAt,
    deletedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurrence_exceptions';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurrenceExceptionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_seriesIdMeta);
    }
    if (data.containsKey('occurrence_date')) {
      context.handle(
        _occurrenceDateMeta,
        occurrenceDate.isAcceptableOrUnknown(
          data['occurrence_date']!,
          _occurrenceDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurrenceDateMeta);
    }
    if (data.containsKey('override_json')) {
      context.handle(
        _overrideJsonMeta,
        overrideJson.isAcceptableOrUnknown(
          data['override_json']!,
          _overrideJsonMeta,
        ),
      );
    }
    if (data.containsKey('is_skipped')) {
      context.handle(
        _isSkippedMeta,
        isSkipped.isAcceptableOrUnknown(data['is_skipped']!, _isSkippedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurrenceExceptionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurrenceExceptionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_id'],
      )!,
      occurrenceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurrence_date'],
      )!,
      overrideJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}override_json'],
      ),
      isSkipped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_skipped'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $RecurrenceExceptionsTable createAlias(String alias) {
    return $RecurrenceExceptionsTable(attachedDatabase, alias);
  }
}

class RecurrenceExceptionRow extends DataClass
    implements Insertable<RecurrenceExceptionRow> {
  final String id;
  final String seriesId;
  final String occurrenceDate;
  final String? overrideJson;
  final bool isSkipped;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int revision;
  const RecurrenceExceptionRow({
    required this.id,
    required this.seriesId,
    required this.occurrenceDate,
    this.overrideJson,
    required this.isSkipped,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['series_id'] = Variable<String>(seriesId);
    map['occurrence_date'] = Variable<String>(occurrenceDate);
    if (!nullToAbsent || overrideJson != null) {
      map['override_json'] = Variable<String>(overrideJson);
    }
    map['is_skipped'] = Variable<bool>(isSkipped);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['revision'] = Variable<int>(revision);
    return map;
  }

  RecurrenceExceptionsCompanion toCompanion(bool nullToAbsent) {
    return RecurrenceExceptionsCompanion(
      id: Value(id),
      seriesId: Value(seriesId),
      occurrenceDate: Value(occurrenceDate),
      overrideJson: overrideJson == null && nullToAbsent
          ? const Value.absent()
          : Value(overrideJson),
      isSkipped: Value(isSkipped),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      revision: Value(revision),
    );
  }

  factory RecurrenceExceptionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurrenceExceptionRow(
      id: serializer.fromJson<String>(json['id']),
      seriesId: serializer.fromJson<String>(json['seriesId']),
      occurrenceDate: serializer.fromJson<String>(json['occurrenceDate']),
      overrideJson: serializer.fromJson<String?>(json['overrideJson']),
      isSkipped: serializer.fromJson<bool>(json['isSkipped']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'seriesId': serializer.toJson<String>(seriesId),
      'occurrenceDate': serializer.toJson<String>(occurrenceDate),
      'overrideJson': serializer.toJson<String?>(overrideJson),
      'isSkipped': serializer.toJson<bool>(isSkipped),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  RecurrenceExceptionRow copyWith({
    String? id,
    String? seriesId,
    String? occurrenceDate,
    Value<String?> overrideJson = const Value.absent(),
    bool? isSkipped,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? revision,
  }) => RecurrenceExceptionRow(
    id: id ?? this.id,
    seriesId: seriesId ?? this.seriesId,
    occurrenceDate: occurrenceDate ?? this.occurrenceDate,
    overrideJson: overrideJson.present ? overrideJson.value : this.overrideJson,
    isSkipped: isSkipped ?? this.isSkipped,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    revision: revision ?? this.revision,
  );
  RecurrenceExceptionRow copyWithCompanion(RecurrenceExceptionsCompanion data) {
    return RecurrenceExceptionRow(
      id: data.id.present ? data.id.value : this.id,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      occurrenceDate: data.occurrenceDate.present
          ? data.occurrenceDate.value
          : this.occurrenceDate,
      overrideJson: data.overrideJson.present
          ? data.overrideJson.value
          : this.overrideJson,
      isSkipped: data.isSkipped.present ? data.isSkipped.value : this.isSkipped,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurrenceExceptionRow(')
          ..write('id: $id, ')
          ..write('seriesId: $seriesId, ')
          ..write('occurrenceDate: $occurrenceDate, ')
          ..write('overrideJson: $overrideJson, ')
          ..write('isSkipped: $isSkipped, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    seriesId,
    occurrenceDate,
    overrideJson,
    isSkipped,
    createdAt,
    updatedAt,
    deletedAt,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurrenceExceptionRow &&
          other.id == this.id &&
          other.seriesId == this.seriesId &&
          other.occurrenceDate == this.occurrenceDate &&
          other.overrideJson == this.overrideJson &&
          other.isSkipped == this.isSkipped &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.revision == this.revision);
}

class RecurrenceExceptionsCompanion
    extends UpdateCompanion<RecurrenceExceptionRow> {
  final Value<String> id;
  final Value<String> seriesId;
  final Value<String> occurrenceDate;
  final Value<String?> overrideJson;
  final Value<bool> isSkipped;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const RecurrenceExceptionsCompanion({
    this.id = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.occurrenceDate = const Value.absent(),
    this.overrideJson = const Value.absent(),
    this.isSkipped = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurrenceExceptionsCompanion.insert({
    required String id,
    required String seriesId,
    required String occurrenceDate,
    this.overrideJson = const Value.absent(),
    this.isSkipped = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       seriesId = Value(seriesId),
       occurrenceDate = Value(occurrenceDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<RecurrenceExceptionRow> custom({
    Expression<String>? id,
    Expression<String>? seriesId,
    Expression<String>? occurrenceDate,
    Expression<String>? overrideJson,
    Expression<bool>? isSkipped,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seriesId != null) 'series_id': seriesId,
      if (occurrenceDate != null) 'occurrence_date': occurrenceDate,
      if (overrideJson != null) 'override_json': overrideJson,
      if (isSkipped != null) 'is_skipped': isSkipped,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurrenceExceptionsCompanion copyWith({
    Value<String>? id,
    Value<String>? seriesId,
    Value<String>? occurrenceDate,
    Value<String?>? overrideJson,
    Value<bool>? isSkipped,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return RecurrenceExceptionsCompanion(
      id: id ?? this.id,
      seriesId: seriesId ?? this.seriesId,
      occurrenceDate: occurrenceDate ?? this.occurrenceDate,
      overrideJson: overrideJson ?? this.overrideJson,
      isSkipped: isSkipped ?? this.isSkipped,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<String>(seriesId.value);
    }
    if (occurrenceDate.present) {
      map['occurrence_date'] = Variable<String>(occurrenceDate.value);
    }
    if (overrideJson.present) {
      map['override_json'] = Variable<String>(overrideJson.value);
    }
    if (isSkipped.present) {
      map['is_skipped'] = Variable<bool>(isSkipped.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurrenceExceptionsCompanion(')
          ..write('id: $id, ')
          ..write('seriesId: $seriesId, ')
          ..write('occurrenceDate: $occurrenceDate, ')
          ..write('overrideJson: $overrideJson, ')
          ..write('isSkipped: $isSkipped, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HolidayYearsTable extends HolidayYears
    with TableInfo<$HolidayYearsTable, HolidayYearRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HolidayYearsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataVersionMeta = const VerificationMeta(
    'dataVersion',
  );
  @override
  late final GeneratedColumn<String> dataVersion = GeneratedColumn<String>(
    'data_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checksumMeta = const VerificationMeta(
    'checksum',
  );
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
    'checksum',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    year,
    sourceUrl,
    dataVersion,
    checksum,
    payloadJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'holiday_years';
  @override
  VerificationContext validateIntegrity(
    Insertable<HolidayYearRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceUrlMeta);
    }
    if (data.containsKey('data_version')) {
      context.handle(
        _dataVersionMeta,
        dataVersion.isAcceptableOrUnknown(
          data['data_version']!,
          _dataVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataVersionMeta);
    }
    if (data.containsKey('checksum')) {
      context.handle(
        _checksumMeta,
        checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta),
      );
    } else if (isInserting) {
      context.missing(_checksumMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {year};
  @override
  HolidayYearRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HolidayYearRow(
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      )!,
      dataVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_version'],
      )!,
      checksum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checksum'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $HolidayYearsTable createAlias(String alias) {
    return $HolidayYearsTable(attachedDatabase, alias);
  }
}

class HolidayYearRow extends DataClass implements Insertable<HolidayYearRow> {
  final int year;
  final String sourceUrl;
  final String dataVersion;
  final String checksum;
  final String payloadJson;
  final DateTime updatedAt;
  const HolidayYearRow({
    required this.year,
    required this.sourceUrl,
    required this.dataVersion,
    required this.checksum,
    required this.payloadJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['year'] = Variable<int>(year);
    map['source_url'] = Variable<String>(sourceUrl);
    map['data_version'] = Variable<String>(dataVersion);
    map['checksum'] = Variable<String>(checksum);
    map['payload_json'] = Variable<String>(payloadJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  HolidayYearsCompanion toCompanion(bool nullToAbsent) {
    return HolidayYearsCompanion(
      year: Value(year),
      sourceUrl: Value(sourceUrl),
      dataVersion: Value(dataVersion),
      checksum: Value(checksum),
      payloadJson: Value(payloadJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory HolidayYearRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HolidayYearRow(
      year: serializer.fromJson<int>(json['year']),
      sourceUrl: serializer.fromJson<String>(json['sourceUrl']),
      dataVersion: serializer.fromJson<String>(json['dataVersion']),
      checksum: serializer.fromJson<String>(json['checksum']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'year': serializer.toJson<int>(year),
      'sourceUrl': serializer.toJson<String>(sourceUrl),
      'dataVersion': serializer.toJson<String>(dataVersion),
      'checksum': serializer.toJson<String>(checksum),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  HolidayYearRow copyWith({
    int? year,
    String? sourceUrl,
    String? dataVersion,
    String? checksum,
    String? payloadJson,
    DateTime? updatedAt,
  }) => HolidayYearRow(
    year: year ?? this.year,
    sourceUrl: sourceUrl ?? this.sourceUrl,
    dataVersion: dataVersion ?? this.dataVersion,
    checksum: checksum ?? this.checksum,
    payloadJson: payloadJson ?? this.payloadJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  HolidayYearRow copyWithCompanion(HolidayYearsCompanion data) {
    return HolidayYearRow(
      year: data.year.present ? data.year.value : this.year,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      dataVersion: data.dataVersion.present
          ? data.dataVersion.value
          : this.dataVersion,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HolidayYearRow(')
          ..write('year: $year, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('dataVersion: $dataVersion, ')
          ..write('checksum: $checksum, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    year,
    sourceUrl,
    dataVersion,
    checksum,
    payloadJson,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HolidayYearRow &&
          other.year == this.year &&
          other.sourceUrl == this.sourceUrl &&
          other.dataVersion == this.dataVersion &&
          other.checksum == this.checksum &&
          other.payloadJson == this.payloadJson &&
          other.updatedAt == this.updatedAt);
}

class HolidayYearsCompanion extends UpdateCompanion<HolidayYearRow> {
  final Value<int> year;
  final Value<String> sourceUrl;
  final Value<String> dataVersion;
  final Value<String> checksum;
  final Value<String> payloadJson;
  final Value<DateTime> updatedAt;
  const HolidayYearsCompanion({
    this.year = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.dataVersion = const Value.absent(),
    this.checksum = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  HolidayYearsCompanion.insert({
    this.year = const Value.absent(),
    required String sourceUrl,
    required String dataVersion,
    required String checksum,
    required String payloadJson,
    required DateTime updatedAt,
  }) : sourceUrl = Value(sourceUrl),
       dataVersion = Value(dataVersion),
       checksum = Value(checksum),
       payloadJson = Value(payloadJson),
       updatedAt = Value(updatedAt);
  static Insertable<HolidayYearRow> custom({
    Expression<int>? year,
    Expression<String>? sourceUrl,
    Expression<String>? dataVersion,
    Expression<String>? checksum,
    Expression<String>? payloadJson,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (year != null) 'year': year,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (dataVersion != null) 'data_version': dataVersion,
      if (checksum != null) 'checksum': checksum,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  HolidayYearsCompanion copyWith({
    Value<int>? year,
    Value<String>? sourceUrl,
    Value<String>? dataVersion,
    Value<String>? checksum,
    Value<String>? payloadJson,
    Value<DateTime>? updatedAt,
  }) {
    return HolidayYearsCompanion(
      year: year ?? this.year,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      dataVersion: dataVersion ?? this.dataVersion,
      checksum: checksum ?? this.checksum,
      payloadJson: payloadJson ?? this.payloadJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (dataVersion.present) {
      map['data_version'] = Variable<String>(dataVersion.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HolidayYearsCompanion(')
          ..write('year: $year, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('dataVersion: $dataVersion, ')
          ..write('checksum: $checksum, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt, revision];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  final DateTime updatedAt;
  final int revision;
  const SettingRow({
    required this.key,
    required this.value,
    required this.updatedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['revision'] = Variable<int>(revision);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
      revision: Value(revision),
    );
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  SettingRow copyWith({
    String? key,
    String? value,
    DateTime? updatedAt,
    int? revision,
  }) => SettingRow(
    key: key ?? this.key,
    value: value ?? this.value,
    updatedAt: updatedAt ?? this.updatedAt,
    revision: revision ?? this.revision,
  );
  SettingRow copyWithCompanion(SettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt, revision);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt &&
          other.revision == this.revision);
}

class SettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncGroupsTable extends SyncGroups
    with TableInfo<$SyncGroupsTable, SyncGroupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hostDeviceIdMeta = const VerificationMeta(
    'hostDeviceId',
  );
  @override
  late final GeneratedColumn<String> hostDeviceId = GeneratedColumn<String>(
    'host_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _protocolVersionMeta = const VerificationMeta(
    'protocolVersion',
  );
  @override
  late final GeneratedColumn<int> protocolVersion = GeneratedColumn<int>(
    'protocol_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    role,
    hostDeviceId,
    protocolVersion,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncGroupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('host_device_id')) {
      context.handle(
        _hostDeviceIdMeta,
        hostDeviceId.isAcceptableOrUnknown(
          data['host_device_id']!,
          _hostDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hostDeviceIdMeta);
    }
    if (data.containsKey('protocol_version')) {
      context.handle(
        _protocolVersionMeta,
        protocolVersion.isAcceptableOrUnknown(
          data['protocol_version']!,
          _protocolVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_protocolVersionMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncGroupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncGroupRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      hostDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host_device_id'],
      )!,
      protocolVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}protocol_version'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SyncGroupsTable createAlias(String alias) {
    return $SyncGroupsTable(attachedDatabase, alias);
  }
}

class SyncGroupRow extends DataClass implements Insertable<SyncGroupRow> {
  final String id;
  final String role;
  final String hostDeviceId;
  final int protocolVersion;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SyncGroupRow({
    required this.id,
    required this.role,
    required this.hostDeviceId,
    required this.protocolVersion,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['role'] = Variable<String>(role);
    map['host_device_id'] = Variable<String>(hostDeviceId);
    map['protocol_version'] = Variable<int>(protocolVersion);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncGroupsCompanion toCompanion(bool nullToAbsent) {
    return SyncGroupsCompanion(
      id: Value(id),
      role: Value(role),
      hostDeviceId: Value(hostDeviceId),
      protocolVersion: Value(protocolVersion),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncGroupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncGroupRow(
      id: serializer.fromJson<String>(json['id']),
      role: serializer.fromJson<String>(json['role']),
      hostDeviceId: serializer.fromJson<String>(json['hostDeviceId']),
      protocolVersion: serializer.fromJson<int>(json['protocolVersion']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'role': serializer.toJson<String>(role),
      'hostDeviceId': serializer.toJson<String>(hostDeviceId),
      'protocolVersion': serializer.toJson<int>(protocolVersion),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncGroupRow copyWith({
    String? id,
    String? role,
    String? hostDeviceId,
    int? protocolVersion,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SyncGroupRow(
    id: id ?? this.id,
    role: role ?? this.role,
    hostDeviceId: hostDeviceId ?? this.hostDeviceId,
    protocolVersion: protocolVersion ?? this.protocolVersion,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SyncGroupRow copyWithCompanion(SyncGroupsCompanion data) {
    return SyncGroupRow(
      id: data.id.present ? data.id.value : this.id,
      role: data.role.present ? data.role.value : this.role,
      hostDeviceId: data.hostDeviceId.present
          ? data.hostDeviceId.value
          : this.hostDeviceId,
      protocolVersion: data.protocolVersion.present
          ? data.protocolVersion.value
          : this.protocolVersion,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncGroupRow(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('hostDeviceId: $hostDeviceId, ')
          ..write('protocolVersion: $protocolVersion, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    role,
    hostDeviceId,
    protocolVersion,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncGroupRow &&
          other.id == this.id &&
          other.role == this.role &&
          other.hostDeviceId == this.hostDeviceId &&
          other.protocolVersion == this.protocolVersion &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SyncGroupsCompanion extends UpdateCompanion<SyncGroupRow> {
  final Value<String> id;
  final Value<String> role;
  final Value<String> hostDeviceId;
  final Value<int> protocolVersion;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SyncGroupsCompanion({
    this.id = const Value.absent(),
    this.role = const Value.absent(),
    this.hostDeviceId = const Value.absent(),
    this.protocolVersion = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncGroupsCompanion.insert({
    required String id,
    required String role,
    required String hostDeviceId,
    required int protocolVersion,
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       role = Value(role),
       hostDeviceId = Value(hostDeviceId),
       protocolVersion = Value(protocolVersion),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SyncGroupRow> custom({
    Expression<String>? id,
    Expression<String>? role,
    Expression<String>? hostDeviceId,
    Expression<int>? protocolVersion,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (role != null) 'role': role,
      if (hostDeviceId != null) 'host_device_id': hostDeviceId,
      if (protocolVersion != null) 'protocol_version': protocolVersion,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncGroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? role,
    Value<String>? hostDeviceId,
    Value<int>? protocolVersion,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SyncGroupsCompanion(
      id: id ?? this.id,
      role: role ?? this.role,
      hostDeviceId: hostDeviceId ?? this.hostDeviceId,
      protocolVersion: protocolVersion ?? this.protocolVersion,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (hostDeviceId.present) {
      map['host_device_id'] = Variable<String>(hostDeviceId.value);
    }
    if (protocolVersion.present) {
      map['protocol_version'] = Variable<int>(protocolVersion.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncGroupsCompanion(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('hostDeviceId: $hostDeviceId, ')
          ..write('protocolVersion: $protocolVersion, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncDevicesTable extends SyncDevices
    with TableInfo<$SyncDevicesTable, SyncDeviceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncDevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncGroupIdMeta = const VerificationMeta(
    'syncGroupId',
  );
  @override
  late final GeneratedColumn<String> syncGroupId = GeneratedColumn<String>(
    'sync_group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sync_groups (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appVersionMeta = const VerificationMeta(
    'appVersion',
  );
  @override
  late final GeneratedColumn<String> appVersion = GeneratedColumn<String>(
    'app_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _protocolVersionMeta = const VerificationMeta(
    'protocolVersion',
  );
  @override
  late final GeneratedColumn<int> protocolVersion = GeneratedColumn<int>(
    'protocol_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publicKeyMeta = const VerificationMeta(
    'publicKey',
  );
  @override
  late final GeneratedColumn<String> publicKey = GeneratedColumn<String>(
    'public_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revokedAtMeta = const VerificationMeta(
    'revokedAt',
  );
  @override
  late final GeneratedColumn<DateTime> revokedAt = GeneratedColumn<DateTime>(
    'revoked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    deviceId,
    syncGroupId,
    displayName,
    note,
    platform,
    appVersion,
    protocolVersion,
    publicKey,
    createdAt,
    updatedAt,
    lastSeenAt,
    revokedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncDeviceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('sync_group_id')) {
      context.handle(
        _syncGroupIdMeta,
        syncGroupId.isAcceptableOrUnknown(
          data['sync_group_id']!,
          _syncGroupIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_syncGroupIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('app_version')) {
      context.handle(
        _appVersionMeta,
        appVersion.isAcceptableOrUnknown(data['app_version']!, _appVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_appVersionMeta);
    }
    if (data.containsKey('protocol_version')) {
      context.handle(
        _protocolVersionMeta,
        protocolVersion.isAcceptableOrUnknown(
          data['protocol_version']!,
          _protocolVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_protocolVersionMeta);
    }
    if (data.containsKey('public_key')) {
      context.handle(
        _publicKeyMeta,
        publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_publicKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    }
    if (data.containsKey('revoked_at')) {
      context.handle(
        _revokedAtMeta,
        revokedAt.isAcceptableOrUnknown(data['revoked_at']!, _revokedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId};
  @override
  SyncDeviceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncDeviceRow(
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      syncGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_group_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      appVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_version'],
      )!,
      protocolVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}protocol_version'],
      )!,
      publicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_key'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      ),
      revokedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}revoked_at'],
      ),
    );
  }

  @override
  $SyncDevicesTable createAlias(String alias) {
    return $SyncDevicesTable(attachedDatabase, alias);
  }
}

class SyncDeviceRow extends DataClass implements Insertable<SyncDeviceRow> {
  final String deviceId;
  final String syncGroupId;
  final String displayName;
  final String? note;
  final String platform;
  final String appVersion;
  final int protocolVersion;
  final String publicKey;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSeenAt;
  final DateTime? revokedAt;
  const SyncDeviceRow({
    required this.deviceId,
    required this.syncGroupId,
    required this.displayName,
    this.note,
    required this.platform,
    required this.appVersion,
    required this.protocolVersion,
    required this.publicKey,
    required this.createdAt,
    required this.updatedAt,
    this.lastSeenAt,
    this.revokedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    map['sync_group_id'] = Variable<String>(syncGroupId);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['platform'] = Variable<String>(platform);
    map['app_version'] = Variable<String>(appVersion);
    map['protocol_version'] = Variable<int>(protocolVersion);
    map['public_key'] = Variable<String>(publicKey);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastSeenAt != null) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    }
    if (!nullToAbsent || revokedAt != null) {
      map['revoked_at'] = Variable<DateTime>(revokedAt);
    }
    return map;
  }

  SyncDevicesCompanion toCompanion(bool nullToAbsent) {
    return SyncDevicesCompanion(
      deviceId: Value(deviceId),
      syncGroupId: Value(syncGroupId),
      displayName: Value(displayName),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      platform: Value(platform),
      appVersion: Value(appVersion),
      protocolVersion: Value(protocolVersion),
      publicKey: Value(publicKey),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSeenAt: lastSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAt),
      revokedAt: revokedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(revokedAt),
    );
  }

  factory SyncDeviceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncDeviceRow(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      syncGroupId: serializer.fromJson<String>(json['syncGroupId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      note: serializer.fromJson<String?>(json['note']),
      platform: serializer.fromJson<String>(json['platform']),
      appVersion: serializer.fromJson<String>(json['appVersion']),
      protocolVersion: serializer.fromJson<int>(json['protocolVersion']),
      publicKey: serializer.fromJson<String>(json['publicKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastSeenAt: serializer.fromJson<DateTime?>(json['lastSeenAt']),
      revokedAt: serializer.fromJson<DateTime?>(json['revokedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'syncGroupId': serializer.toJson<String>(syncGroupId),
      'displayName': serializer.toJson<String>(displayName),
      'note': serializer.toJson<String?>(note),
      'platform': serializer.toJson<String>(platform),
      'appVersion': serializer.toJson<String>(appVersion),
      'protocolVersion': serializer.toJson<int>(protocolVersion),
      'publicKey': serializer.toJson<String>(publicKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastSeenAt': serializer.toJson<DateTime?>(lastSeenAt),
      'revokedAt': serializer.toJson<DateTime?>(revokedAt),
    };
  }

  SyncDeviceRow copyWith({
    String? deviceId,
    String? syncGroupId,
    String? displayName,
    Value<String?> note = const Value.absent(),
    String? platform,
    String? appVersion,
    int? protocolVersion,
    String? publicKey,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastSeenAt = const Value.absent(),
    Value<DateTime?> revokedAt = const Value.absent(),
  }) => SyncDeviceRow(
    deviceId: deviceId ?? this.deviceId,
    syncGroupId: syncGroupId ?? this.syncGroupId,
    displayName: displayName ?? this.displayName,
    note: note.present ? note.value : this.note,
    platform: platform ?? this.platform,
    appVersion: appVersion ?? this.appVersion,
    protocolVersion: protocolVersion ?? this.protocolVersion,
    publicKey: publicKey ?? this.publicKey,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastSeenAt: lastSeenAt.present ? lastSeenAt.value : this.lastSeenAt,
    revokedAt: revokedAt.present ? revokedAt.value : this.revokedAt,
  );
  SyncDeviceRow copyWithCompanion(SyncDevicesCompanion data) {
    return SyncDeviceRow(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      syncGroupId: data.syncGroupId.present
          ? data.syncGroupId.value
          : this.syncGroupId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      note: data.note.present ? data.note.value : this.note,
      platform: data.platform.present ? data.platform.value : this.platform,
      appVersion: data.appVersion.present
          ? data.appVersion.value
          : this.appVersion,
      protocolVersion: data.protocolVersion.present
          ? data.protocolVersion.value
          : this.protocolVersion,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      revokedAt: data.revokedAt.present ? data.revokedAt.value : this.revokedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncDeviceRow(')
          ..write('deviceId: $deviceId, ')
          ..write('syncGroupId: $syncGroupId, ')
          ..write('displayName: $displayName, ')
          ..write('note: $note, ')
          ..write('platform: $platform, ')
          ..write('appVersion: $appVersion, ')
          ..write('protocolVersion: $protocolVersion, ')
          ..write('publicKey: $publicKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('revokedAt: $revokedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    deviceId,
    syncGroupId,
    displayName,
    note,
    platform,
    appVersion,
    protocolVersion,
    publicKey,
    createdAt,
    updatedAt,
    lastSeenAt,
    revokedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncDeviceRow &&
          other.deviceId == this.deviceId &&
          other.syncGroupId == this.syncGroupId &&
          other.displayName == this.displayName &&
          other.note == this.note &&
          other.platform == this.platform &&
          other.appVersion == this.appVersion &&
          other.protocolVersion == this.protocolVersion &&
          other.publicKey == this.publicKey &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSeenAt == this.lastSeenAt &&
          other.revokedAt == this.revokedAt);
}

class SyncDevicesCompanion extends UpdateCompanion<SyncDeviceRow> {
  final Value<String> deviceId;
  final Value<String> syncGroupId;
  final Value<String> displayName;
  final Value<String?> note;
  final Value<String> platform;
  final Value<String> appVersion;
  final Value<int> protocolVersion;
  final Value<String> publicKey;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastSeenAt;
  final Value<DateTime?> revokedAt;
  final Value<int> rowid;
  const SyncDevicesCompanion({
    this.deviceId = const Value.absent(),
    this.syncGroupId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.note = const Value.absent(),
    this.platform = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.protocolVersion = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.revokedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncDevicesCompanion.insert({
    required String deviceId,
    required String syncGroupId,
    required String displayName,
    this.note = const Value.absent(),
    required String platform,
    required String appVersion,
    required int protocolVersion,
    required String publicKey,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.lastSeenAt = const Value.absent(),
    this.revokedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : deviceId = Value(deviceId),
       syncGroupId = Value(syncGroupId),
       displayName = Value(displayName),
       platform = Value(platform),
       appVersion = Value(appVersion),
       protocolVersion = Value(protocolVersion),
       publicKey = Value(publicKey),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SyncDeviceRow> custom({
    Expression<String>? deviceId,
    Expression<String>? syncGroupId,
    Expression<String>? displayName,
    Expression<String>? note,
    Expression<String>? platform,
    Expression<String>? appVersion,
    Expression<int>? protocolVersion,
    Expression<String>? publicKey,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSeenAt,
    Expression<DateTime>? revokedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (syncGroupId != null) 'sync_group_id': syncGroupId,
      if (displayName != null) 'display_name': displayName,
      if (note != null) 'note': note,
      if (platform != null) 'platform': platform,
      if (appVersion != null) 'app_version': appVersion,
      if (protocolVersion != null) 'protocol_version': protocolVersion,
      if (publicKey != null) 'public_key': publicKey,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (revokedAt != null) 'revoked_at': revokedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncDevicesCompanion copyWith({
    Value<String>? deviceId,
    Value<String>? syncGroupId,
    Value<String>? displayName,
    Value<String?>? note,
    Value<String>? platform,
    Value<String>? appVersion,
    Value<int>? protocolVersion,
    Value<String>? publicKey,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastSeenAt,
    Value<DateTime?>? revokedAt,
    Value<int>? rowid,
  }) {
    return SyncDevicesCompanion(
      deviceId: deviceId ?? this.deviceId,
      syncGroupId: syncGroupId ?? this.syncGroupId,
      displayName: displayName ?? this.displayName,
      note: note ?? this.note,
      platform: platform ?? this.platform,
      appVersion: appVersion ?? this.appVersion,
      protocolVersion: protocolVersion ?? this.protocolVersion,
      publicKey: publicKey ?? this.publicKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      revokedAt: revokedAt ?? this.revokedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (syncGroupId.present) {
      map['sync_group_id'] = Variable<String>(syncGroupId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (appVersion.present) {
      map['app_version'] = Variable<String>(appVersion.value);
    }
    if (protocolVersion.present) {
      map['protocol_version'] = Variable<int>(protocolVersion.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<String>(publicKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (revokedAt.present) {
      map['revoked_at'] = Variable<DateTime>(revokedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncDevicesCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('syncGroupId: $syncGroupId, ')
          ..write('displayName: $displayName, ')
          ..write('note: $note, ')
          ..write('platform: $platform, ')
          ..write('appVersion: $appVersion, ')
          ..write('protocolVersion: $protocolVersion, ')
          ..write('publicKey: $publicKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('revokedAt: $revokedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncPairingInvitesTable extends SyncPairingInvites
    with TableInfo<$SyncPairingInvitesTable, SyncPairingInviteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncPairingInvitesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncGroupIdMeta = const VerificationMeta(
    'syncGroupId',
  );
  @override
  late final GeneratedColumn<String> syncGroupId = GeneratedColumn<String>(
    'sync_group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sync_groups (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tokenHashMeta = const VerificationMeta(
    'tokenHash',
  );
  @override
  late final GeneratedColumn<String> tokenHash = GeneratedColumn<String>(
    'token_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _hostFingerprintMeta = const VerificationMeta(
    'hostFingerprint',
  );
  @override
  late final GeneratedColumn<String> hostFingerprint = GeneratedColumn<String>(
    'host_fingerprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _maximumAttemptsMeta = const VerificationMeta(
    'maximumAttempts',
  );
  @override
  late final GeneratedColumn<int> maximumAttempts = GeneratedColumn<int>(
    'maximum_attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _consumedAtMeta = const VerificationMeta(
    'consumedAt',
  );
  @override
  late final GeneratedColumn<DateTime> consumedAt = GeneratedColumn<DateTime>(
    'consumed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncGroupId,
    tokenHash,
    hostFingerprint,
    expiresAt,
    attemptCount,
    maximumAttempts,
    createdAt,
    consumedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_pairing_invites';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncPairingInviteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sync_group_id')) {
      context.handle(
        _syncGroupIdMeta,
        syncGroupId.isAcceptableOrUnknown(
          data['sync_group_id']!,
          _syncGroupIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_syncGroupIdMeta);
    }
    if (data.containsKey('token_hash')) {
      context.handle(
        _tokenHashMeta,
        tokenHash.isAcceptableOrUnknown(data['token_hash']!, _tokenHashMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenHashMeta);
    }
    if (data.containsKey('host_fingerprint')) {
      context.handle(
        _hostFingerprintMeta,
        hostFingerprint.isAcceptableOrUnknown(
          data['host_fingerprint']!,
          _hostFingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hostFingerprintMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('maximum_attempts')) {
      context.handle(
        _maximumAttemptsMeta,
        maximumAttempts.isAcceptableOrUnknown(
          data['maximum_attempts']!,
          _maximumAttemptsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_maximumAttemptsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('consumed_at')) {
      context.handle(
        _consumedAtMeta,
        consumedAt.isAcceptableOrUnknown(data['consumed_at']!, _consumedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncPairingInviteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncPairingInviteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_group_id'],
      )!,
      tokenHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token_hash'],
      )!,
      hostFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host_fingerprint'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      maximumAttempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}maximum_attempts'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      consumedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}consumed_at'],
      ),
    );
  }

  @override
  $SyncPairingInvitesTable createAlias(String alias) {
    return $SyncPairingInvitesTable(attachedDatabase, alias);
  }
}

class SyncPairingInviteRow extends DataClass
    implements Insertable<SyncPairingInviteRow> {
  final String id;
  final String syncGroupId;
  final String tokenHash;
  final String hostFingerprint;
  final DateTime expiresAt;
  final int attemptCount;
  final int maximumAttempts;
  final DateTime createdAt;
  final DateTime? consumedAt;
  const SyncPairingInviteRow({
    required this.id,
    required this.syncGroupId,
    required this.tokenHash,
    required this.hostFingerprint,
    required this.expiresAt,
    required this.attemptCount,
    required this.maximumAttempts,
    required this.createdAt,
    this.consumedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sync_group_id'] = Variable<String>(syncGroupId);
    map['token_hash'] = Variable<String>(tokenHash);
    map['host_fingerprint'] = Variable<String>(hostFingerprint);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    map['attempt_count'] = Variable<int>(attemptCount);
    map['maximum_attempts'] = Variable<int>(maximumAttempts);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || consumedAt != null) {
      map['consumed_at'] = Variable<DateTime>(consumedAt);
    }
    return map;
  }

  SyncPairingInvitesCompanion toCompanion(bool nullToAbsent) {
    return SyncPairingInvitesCompanion(
      id: Value(id),
      syncGroupId: Value(syncGroupId),
      tokenHash: Value(tokenHash),
      hostFingerprint: Value(hostFingerprint),
      expiresAt: Value(expiresAt),
      attemptCount: Value(attemptCount),
      maximumAttempts: Value(maximumAttempts),
      createdAt: Value(createdAt),
      consumedAt: consumedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(consumedAt),
    );
  }

  factory SyncPairingInviteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncPairingInviteRow(
      id: serializer.fromJson<String>(json['id']),
      syncGroupId: serializer.fromJson<String>(json['syncGroupId']),
      tokenHash: serializer.fromJson<String>(json['tokenHash']),
      hostFingerprint: serializer.fromJson<String>(json['hostFingerprint']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      maximumAttempts: serializer.fromJson<int>(json['maximumAttempts']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      consumedAt: serializer.fromJson<DateTime?>(json['consumedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncGroupId': serializer.toJson<String>(syncGroupId),
      'tokenHash': serializer.toJson<String>(tokenHash),
      'hostFingerprint': serializer.toJson<String>(hostFingerprint),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'maximumAttempts': serializer.toJson<int>(maximumAttempts),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'consumedAt': serializer.toJson<DateTime?>(consumedAt),
    };
  }

  SyncPairingInviteRow copyWith({
    String? id,
    String? syncGroupId,
    String? tokenHash,
    String? hostFingerprint,
    DateTime? expiresAt,
    int? attemptCount,
    int? maximumAttempts,
    DateTime? createdAt,
    Value<DateTime?> consumedAt = const Value.absent(),
  }) => SyncPairingInviteRow(
    id: id ?? this.id,
    syncGroupId: syncGroupId ?? this.syncGroupId,
    tokenHash: tokenHash ?? this.tokenHash,
    hostFingerprint: hostFingerprint ?? this.hostFingerprint,
    expiresAt: expiresAt ?? this.expiresAt,
    attemptCount: attemptCount ?? this.attemptCount,
    maximumAttempts: maximumAttempts ?? this.maximumAttempts,
    createdAt: createdAt ?? this.createdAt,
    consumedAt: consumedAt.present ? consumedAt.value : this.consumedAt,
  );
  SyncPairingInviteRow copyWithCompanion(SyncPairingInvitesCompanion data) {
    return SyncPairingInviteRow(
      id: data.id.present ? data.id.value : this.id,
      syncGroupId: data.syncGroupId.present
          ? data.syncGroupId.value
          : this.syncGroupId,
      tokenHash: data.tokenHash.present ? data.tokenHash.value : this.tokenHash,
      hostFingerprint: data.hostFingerprint.present
          ? data.hostFingerprint.value
          : this.hostFingerprint,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      maximumAttempts: data.maximumAttempts.present
          ? data.maximumAttempts.value
          : this.maximumAttempts,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      consumedAt: data.consumedAt.present
          ? data.consumedAt.value
          : this.consumedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncPairingInviteRow(')
          ..write('id: $id, ')
          ..write('syncGroupId: $syncGroupId, ')
          ..write('tokenHash: $tokenHash, ')
          ..write('hostFingerprint: $hostFingerprint, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('maximumAttempts: $maximumAttempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('consumedAt: $consumedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncGroupId,
    tokenHash,
    hostFingerprint,
    expiresAt,
    attemptCount,
    maximumAttempts,
    createdAt,
    consumedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncPairingInviteRow &&
          other.id == this.id &&
          other.syncGroupId == this.syncGroupId &&
          other.tokenHash == this.tokenHash &&
          other.hostFingerprint == this.hostFingerprint &&
          other.expiresAt == this.expiresAt &&
          other.attemptCount == this.attemptCount &&
          other.maximumAttempts == this.maximumAttempts &&
          other.createdAt == this.createdAt &&
          other.consumedAt == this.consumedAt);
}

class SyncPairingInvitesCompanion
    extends UpdateCompanion<SyncPairingInviteRow> {
  final Value<String> id;
  final Value<String> syncGroupId;
  final Value<String> tokenHash;
  final Value<String> hostFingerprint;
  final Value<DateTime> expiresAt;
  final Value<int> attemptCount;
  final Value<int> maximumAttempts;
  final Value<DateTime> createdAt;
  final Value<DateTime?> consumedAt;
  final Value<int> rowid;
  const SyncPairingInvitesCompanion({
    this.id = const Value.absent(),
    this.syncGroupId = const Value.absent(),
    this.tokenHash = const Value.absent(),
    this.hostFingerprint = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.maximumAttempts = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.consumedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncPairingInvitesCompanion.insert({
    required String id,
    required String syncGroupId,
    required String tokenHash,
    required String hostFingerprint,
    required DateTime expiresAt,
    this.attemptCount = const Value.absent(),
    required int maximumAttempts,
    required DateTime createdAt,
    this.consumedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       syncGroupId = Value(syncGroupId),
       tokenHash = Value(tokenHash),
       hostFingerprint = Value(hostFingerprint),
       expiresAt = Value(expiresAt),
       maximumAttempts = Value(maximumAttempts),
       createdAt = Value(createdAt);
  static Insertable<SyncPairingInviteRow> custom({
    Expression<String>? id,
    Expression<String>? syncGroupId,
    Expression<String>? tokenHash,
    Expression<String>? hostFingerprint,
    Expression<DateTime>? expiresAt,
    Expression<int>? attemptCount,
    Expression<int>? maximumAttempts,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? consumedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncGroupId != null) 'sync_group_id': syncGroupId,
      if (tokenHash != null) 'token_hash': tokenHash,
      if (hostFingerprint != null) 'host_fingerprint': hostFingerprint,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (maximumAttempts != null) 'maximum_attempts': maximumAttempts,
      if (createdAt != null) 'created_at': createdAt,
      if (consumedAt != null) 'consumed_at': consumedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncPairingInvitesCompanion copyWith({
    Value<String>? id,
    Value<String>? syncGroupId,
    Value<String>? tokenHash,
    Value<String>? hostFingerprint,
    Value<DateTime>? expiresAt,
    Value<int>? attemptCount,
    Value<int>? maximumAttempts,
    Value<DateTime>? createdAt,
    Value<DateTime?>? consumedAt,
    Value<int>? rowid,
  }) {
    return SyncPairingInvitesCompanion(
      id: id ?? this.id,
      syncGroupId: syncGroupId ?? this.syncGroupId,
      tokenHash: tokenHash ?? this.tokenHash,
      hostFingerprint: hostFingerprint ?? this.hostFingerprint,
      expiresAt: expiresAt ?? this.expiresAt,
      attemptCount: attemptCount ?? this.attemptCount,
      maximumAttempts: maximumAttempts ?? this.maximumAttempts,
      createdAt: createdAt ?? this.createdAt,
      consumedAt: consumedAt ?? this.consumedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncGroupId.present) {
      map['sync_group_id'] = Variable<String>(syncGroupId.value);
    }
    if (tokenHash.present) {
      map['token_hash'] = Variable<String>(tokenHash.value);
    }
    if (hostFingerprint.present) {
      map['host_fingerprint'] = Variable<String>(hostFingerprint.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (maximumAttempts.present) {
      map['maximum_attempts'] = Variable<int>(maximumAttempts.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (consumedAt.present) {
      map['consumed_at'] = Variable<DateTime>(consumedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncPairingInvitesCompanion(')
          ..write('id: $id, ')
          ..write('syncGroupId: $syncGroupId, ')
          ..write('tokenHash: $tokenHash, ')
          ..write('hostFingerprint: $hostFingerprint, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('maximumAttempts: $maximumAttempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('consumedAt: $consumedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncChangesTable extends SyncChanges
    with TableInfo<$SyncChangesTable, SyncChangeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncChangesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
    'operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncGroupIdMeta = const VerificationMeta(
    'syncGroupId',
  );
  @override
  late final GeneratedColumn<String> syncGroupId = GeneratedColumn<String>(
    'sync_group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sync_groups (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceDeviceIdMeta = const VerificationMeta(
    'sourceDeviceId',
  );
  @override
  late final GeneratedColumn<String> sourceDeviceId = GeneratedColumn<String>(
    'source_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sync_devices (device_id)',
    ),
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
    'operation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldGroupMeta = const VerificationMeta(
    'fieldGroup',
  );
  @override
  late final GeneratedColumn<String> fieldGroup = GeneratedColumn<String>(
    'field_group',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadFormatVersionMeta =
      const VerificationMeta('payloadFormatVersion');
  @override
  late final GeneratedColumn<int> payloadFormatVersion = GeneratedColumn<int>(
    'payload_format_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcPhysicalMsMeta = const VerificationMeta(
    'hlcPhysicalMs',
  );
  @override
  late final GeneratedColumn<int> hlcPhysicalMs = GeneratedColumn<int>(
    'hlc_physical_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcLogicalMeta = const VerificationMeta(
    'hlcLogical',
  );
  @override
  late final GeneratedColumn<int> hlcLogical = GeneratedColumn<int>(
    'hlc_logical',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcDeviceIdMeta = const VerificationMeta(
    'hlcDeviceId',
  );
  @override
  late final GeneratedColumn<String> hlcDeviceId = GeneratedColumn<String>(
    'hlc_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _causalCursorJsonMeta = const VerificationMeta(
    'causalCursorJson',
  );
  @override
  late final GeneratedColumn<String> causalCursorJson = GeneratedColumn<String>(
    'causal_cursor_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedAtMeta = const VerificationMeta(
    'appliedAt',
  );
  @override
  late final GeneratedColumn<DateTime> appliedAt = GeneratedColumn<DateTime>(
    'applied_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    operationId,
    syncGroupId,
    sourceDeviceId,
    sequence,
    transactionId,
    entityType,
    entityId,
    operationType,
    fieldGroup,
    payloadFormatVersion,
    payloadJson,
    hlcPhysicalMs,
    hlcLogical,
    hlcDeviceId,
    causalCursorJson,
    createdAt,
    appliedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_changes';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncChangeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('operation_id')) {
      context.handle(
        _operationIdMeta,
        operationId.isAcceptableOrUnknown(
          data['operation_id']!,
          _operationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('sync_group_id')) {
      context.handle(
        _syncGroupIdMeta,
        syncGroupId.isAcceptableOrUnknown(
          data['sync_group_id']!,
          _syncGroupIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_syncGroupIdMeta);
    }
    if (data.containsKey('source_device_id')) {
      context.handle(
        _sourceDeviceIdMeta,
        sourceDeviceId.isAcceptableOrUnknown(
          data['source_device_id']!,
          _sourceDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceDeviceIdMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation_type')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operation_type']!,
          _operationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('field_group')) {
      context.handle(
        _fieldGroupMeta,
        fieldGroup.isAcceptableOrUnknown(data['field_group']!, _fieldGroupMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldGroupMeta);
    }
    if (data.containsKey('payload_format_version')) {
      context.handle(
        _payloadFormatVersionMeta,
        payloadFormatVersion.isAcceptableOrUnknown(
          data['payload_format_version']!,
          _payloadFormatVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadFormatVersionMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('hlc_physical_ms')) {
      context.handle(
        _hlcPhysicalMsMeta,
        hlcPhysicalMs.isAcceptableOrUnknown(
          data['hlc_physical_ms']!,
          _hlcPhysicalMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hlcPhysicalMsMeta);
    }
    if (data.containsKey('hlc_logical')) {
      context.handle(
        _hlcLogicalMeta,
        hlcLogical.isAcceptableOrUnknown(data['hlc_logical']!, _hlcLogicalMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcLogicalMeta);
    }
    if (data.containsKey('hlc_device_id')) {
      context.handle(
        _hlcDeviceIdMeta,
        hlcDeviceId.isAcceptableOrUnknown(
          data['hlc_device_id']!,
          _hlcDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hlcDeviceIdMeta);
    }
    if (data.containsKey('causal_cursor_json')) {
      context.handle(
        _causalCursorJsonMeta,
        causalCursorJson.isAcceptableOrUnknown(
          data['causal_cursor_json']!,
          _causalCursorJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_causalCursorJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('applied_at')) {
      context.handle(
        _appliedAtMeta,
        appliedAt.isAcceptableOrUnknown(data['applied_at']!, _appliedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_appliedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {operationId};
  @override
  SyncChangeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncChangeRow(
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_id'],
      )!,
      syncGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_group_id'],
      )!,
      sourceDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_device_id'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_type'],
      )!,
      fieldGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_group'],
      )!,
      payloadFormatVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payload_format_version'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      hlcPhysicalMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hlc_physical_ms'],
      )!,
      hlcLogical: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hlc_logical'],
      )!,
      hlcDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc_device_id'],
      )!,
      causalCursorJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}causal_cursor_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      appliedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}applied_at'],
      )!,
    );
  }

  @override
  $SyncChangesTable createAlias(String alias) {
    return $SyncChangesTable(attachedDatabase, alias);
  }
}

class SyncChangeRow extends DataClass implements Insertable<SyncChangeRow> {
  final String operationId;
  final String syncGroupId;
  final String sourceDeviceId;
  final int sequence;
  final String transactionId;
  final String entityType;
  final String entityId;
  final String operationType;
  final String fieldGroup;
  final int payloadFormatVersion;
  final String payloadJson;
  final int hlcPhysicalMs;
  final int hlcLogical;
  final String hlcDeviceId;
  final String causalCursorJson;
  final DateTime createdAt;
  final DateTime appliedAt;
  const SyncChangeRow({
    required this.operationId,
    required this.syncGroupId,
    required this.sourceDeviceId,
    required this.sequence,
    required this.transactionId,
    required this.entityType,
    required this.entityId,
    required this.operationType,
    required this.fieldGroup,
    required this.payloadFormatVersion,
    required this.payloadJson,
    required this.hlcPhysicalMs,
    required this.hlcLogical,
    required this.hlcDeviceId,
    required this.causalCursorJson,
    required this.createdAt,
    required this.appliedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['operation_id'] = Variable<String>(operationId);
    map['sync_group_id'] = Variable<String>(syncGroupId);
    map['source_device_id'] = Variable<String>(sourceDeviceId);
    map['sequence'] = Variable<int>(sequence);
    map['transaction_id'] = Variable<String>(transactionId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation_type'] = Variable<String>(operationType);
    map['field_group'] = Variable<String>(fieldGroup);
    map['payload_format_version'] = Variable<int>(payloadFormatVersion);
    map['payload_json'] = Variable<String>(payloadJson);
    map['hlc_physical_ms'] = Variable<int>(hlcPhysicalMs);
    map['hlc_logical'] = Variable<int>(hlcLogical);
    map['hlc_device_id'] = Variable<String>(hlcDeviceId);
    map['causal_cursor_json'] = Variable<String>(causalCursorJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['applied_at'] = Variable<DateTime>(appliedAt);
    return map;
  }

  SyncChangesCompanion toCompanion(bool nullToAbsent) {
    return SyncChangesCompanion(
      operationId: Value(operationId),
      syncGroupId: Value(syncGroupId),
      sourceDeviceId: Value(sourceDeviceId),
      sequence: Value(sequence),
      transactionId: Value(transactionId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operationType: Value(operationType),
      fieldGroup: Value(fieldGroup),
      payloadFormatVersion: Value(payloadFormatVersion),
      payloadJson: Value(payloadJson),
      hlcPhysicalMs: Value(hlcPhysicalMs),
      hlcLogical: Value(hlcLogical),
      hlcDeviceId: Value(hlcDeviceId),
      causalCursorJson: Value(causalCursorJson),
      createdAt: Value(createdAt),
      appliedAt: Value(appliedAt),
    );
  }

  factory SyncChangeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncChangeRow(
      operationId: serializer.fromJson<String>(json['operationId']),
      syncGroupId: serializer.fromJson<String>(json['syncGroupId']),
      sourceDeviceId: serializer.fromJson<String>(json['sourceDeviceId']),
      sequence: serializer.fromJson<int>(json['sequence']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operationType: serializer.fromJson<String>(json['operationType']),
      fieldGroup: serializer.fromJson<String>(json['fieldGroup']),
      payloadFormatVersion: serializer.fromJson<int>(
        json['payloadFormatVersion'],
      ),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      hlcPhysicalMs: serializer.fromJson<int>(json['hlcPhysicalMs']),
      hlcLogical: serializer.fromJson<int>(json['hlcLogical']),
      hlcDeviceId: serializer.fromJson<String>(json['hlcDeviceId']),
      causalCursorJson: serializer.fromJson<String>(json['causalCursorJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      appliedAt: serializer.fromJson<DateTime>(json['appliedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'operationId': serializer.toJson<String>(operationId),
      'syncGroupId': serializer.toJson<String>(syncGroupId),
      'sourceDeviceId': serializer.toJson<String>(sourceDeviceId),
      'sequence': serializer.toJson<int>(sequence),
      'transactionId': serializer.toJson<String>(transactionId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operationType': serializer.toJson<String>(operationType),
      'fieldGroup': serializer.toJson<String>(fieldGroup),
      'payloadFormatVersion': serializer.toJson<int>(payloadFormatVersion),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'hlcPhysicalMs': serializer.toJson<int>(hlcPhysicalMs),
      'hlcLogical': serializer.toJson<int>(hlcLogical),
      'hlcDeviceId': serializer.toJson<String>(hlcDeviceId),
      'causalCursorJson': serializer.toJson<String>(causalCursorJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'appliedAt': serializer.toJson<DateTime>(appliedAt),
    };
  }

  SyncChangeRow copyWith({
    String? operationId,
    String? syncGroupId,
    String? sourceDeviceId,
    int? sequence,
    String? transactionId,
    String? entityType,
    String? entityId,
    String? operationType,
    String? fieldGroup,
    int? payloadFormatVersion,
    String? payloadJson,
    int? hlcPhysicalMs,
    int? hlcLogical,
    String? hlcDeviceId,
    String? causalCursorJson,
    DateTime? createdAt,
    DateTime? appliedAt,
  }) => SyncChangeRow(
    operationId: operationId ?? this.operationId,
    syncGroupId: syncGroupId ?? this.syncGroupId,
    sourceDeviceId: sourceDeviceId ?? this.sourceDeviceId,
    sequence: sequence ?? this.sequence,
    transactionId: transactionId ?? this.transactionId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operationType: operationType ?? this.operationType,
    fieldGroup: fieldGroup ?? this.fieldGroup,
    payloadFormatVersion: payloadFormatVersion ?? this.payloadFormatVersion,
    payloadJson: payloadJson ?? this.payloadJson,
    hlcPhysicalMs: hlcPhysicalMs ?? this.hlcPhysicalMs,
    hlcLogical: hlcLogical ?? this.hlcLogical,
    hlcDeviceId: hlcDeviceId ?? this.hlcDeviceId,
    causalCursorJson: causalCursorJson ?? this.causalCursorJson,
    createdAt: createdAt ?? this.createdAt,
    appliedAt: appliedAt ?? this.appliedAt,
  );
  SyncChangeRow copyWithCompanion(SyncChangesCompanion data) {
    return SyncChangeRow(
      operationId: data.operationId.present
          ? data.operationId.value
          : this.operationId,
      syncGroupId: data.syncGroupId.present
          ? data.syncGroupId.value
          : this.syncGroupId,
      sourceDeviceId: data.sourceDeviceId.present
          ? data.sourceDeviceId.value
          : this.sourceDeviceId,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      fieldGroup: data.fieldGroup.present
          ? data.fieldGroup.value
          : this.fieldGroup,
      payloadFormatVersion: data.payloadFormatVersion.present
          ? data.payloadFormatVersion.value
          : this.payloadFormatVersion,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      hlcPhysicalMs: data.hlcPhysicalMs.present
          ? data.hlcPhysicalMs.value
          : this.hlcPhysicalMs,
      hlcLogical: data.hlcLogical.present
          ? data.hlcLogical.value
          : this.hlcLogical,
      hlcDeviceId: data.hlcDeviceId.present
          ? data.hlcDeviceId.value
          : this.hlcDeviceId,
      causalCursorJson: data.causalCursorJson.present
          ? data.causalCursorJson.value
          : this.causalCursorJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      appliedAt: data.appliedAt.present ? data.appliedAt.value : this.appliedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncChangeRow(')
          ..write('operationId: $operationId, ')
          ..write('syncGroupId: $syncGroupId, ')
          ..write('sourceDeviceId: $sourceDeviceId, ')
          ..write('sequence: $sequence, ')
          ..write('transactionId: $transactionId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operationType: $operationType, ')
          ..write('fieldGroup: $fieldGroup, ')
          ..write('payloadFormatVersion: $payloadFormatVersion, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('hlcPhysicalMs: $hlcPhysicalMs, ')
          ..write('hlcLogical: $hlcLogical, ')
          ..write('hlcDeviceId: $hlcDeviceId, ')
          ..write('causalCursorJson: $causalCursorJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('appliedAt: $appliedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    operationId,
    syncGroupId,
    sourceDeviceId,
    sequence,
    transactionId,
    entityType,
    entityId,
    operationType,
    fieldGroup,
    payloadFormatVersion,
    payloadJson,
    hlcPhysicalMs,
    hlcLogical,
    hlcDeviceId,
    causalCursorJson,
    createdAt,
    appliedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncChangeRow &&
          other.operationId == this.operationId &&
          other.syncGroupId == this.syncGroupId &&
          other.sourceDeviceId == this.sourceDeviceId &&
          other.sequence == this.sequence &&
          other.transactionId == this.transactionId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operationType == this.operationType &&
          other.fieldGroup == this.fieldGroup &&
          other.payloadFormatVersion == this.payloadFormatVersion &&
          other.payloadJson == this.payloadJson &&
          other.hlcPhysicalMs == this.hlcPhysicalMs &&
          other.hlcLogical == this.hlcLogical &&
          other.hlcDeviceId == this.hlcDeviceId &&
          other.causalCursorJson == this.causalCursorJson &&
          other.createdAt == this.createdAt &&
          other.appliedAt == this.appliedAt);
}

class SyncChangesCompanion extends UpdateCompanion<SyncChangeRow> {
  final Value<String> operationId;
  final Value<String> syncGroupId;
  final Value<String> sourceDeviceId;
  final Value<int> sequence;
  final Value<String> transactionId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operationType;
  final Value<String> fieldGroup;
  final Value<int> payloadFormatVersion;
  final Value<String> payloadJson;
  final Value<int> hlcPhysicalMs;
  final Value<int> hlcLogical;
  final Value<String> hlcDeviceId;
  final Value<String> causalCursorJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> appliedAt;
  final Value<int> rowid;
  const SyncChangesCompanion({
    this.operationId = const Value.absent(),
    this.syncGroupId = const Value.absent(),
    this.sourceDeviceId = const Value.absent(),
    this.sequence = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operationType = const Value.absent(),
    this.fieldGroup = const Value.absent(),
    this.payloadFormatVersion = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.hlcPhysicalMs = const Value.absent(),
    this.hlcLogical = const Value.absent(),
    this.hlcDeviceId = const Value.absent(),
    this.causalCursorJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.appliedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncChangesCompanion.insert({
    required String operationId,
    required String syncGroupId,
    required String sourceDeviceId,
    required int sequence,
    required String transactionId,
    required String entityType,
    required String entityId,
    required String operationType,
    required String fieldGroup,
    required int payloadFormatVersion,
    required String payloadJson,
    required int hlcPhysicalMs,
    required int hlcLogical,
    required String hlcDeviceId,
    required String causalCursorJson,
    required DateTime createdAt,
    required DateTime appliedAt,
    this.rowid = const Value.absent(),
  }) : operationId = Value(operationId),
       syncGroupId = Value(syncGroupId),
       sourceDeviceId = Value(sourceDeviceId),
       sequence = Value(sequence),
       transactionId = Value(transactionId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operationType = Value(operationType),
       fieldGroup = Value(fieldGroup),
       payloadFormatVersion = Value(payloadFormatVersion),
       payloadJson = Value(payloadJson),
       hlcPhysicalMs = Value(hlcPhysicalMs),
       hlcLogical = Value(hlcLogical),
       hlcDeviceId = Value(hlcDeviceId),
       causalCursorJson = Value(causalCursorJson),
       createdAt = Value(createdAt),
       appliedAt = Value(appliedAt);
  static Insertable<SyncChangeRow> custom({
    Expression<String>? operationId,
    Expression<String>? syncGroupId,
    Expression<String>? sourceDeviceId,
    Expression<int>? sequence,
    Expression<String>? transactionId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operationType,
    Expression<String>? fieldGroup,
    Expression<int>? payloadFormatVersion,
    Expression<String>? payloadJson,
    Expression<int>? hlcPhysicalMs,
    Expression<int>? hlcLogical,
    Expression<String>? hlcDeviceId,
    Expression<String>? causalCursorJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? appliedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (operationId != null) 'operation_id': operationId,
      if (syncGroupId != null) 'sync_group_id': syncGroupId,
      if (sourceDeviceId != null) 'source_device_id': sourceDeviceId,
      if (sequence != null) 'sequence': sequence,
      if (transactionId != null) 'transaction_id': transactionId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operationType != null) 'operation_type': operationType,
      if (fieldGroup != null) 'field_group': fieldGroup,
      if (payloadFormatVersion != null)
        'payload_format_version': payloadFormatVersion,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (hlcPhysicalMs != null) 'hlc_physical_ms': hlcPhysicalMs,
      if (hlcLogical != null) 'hlc_logical': hlcLogical,
      if (hlcDeviceId != null) 'hlc_device_id': hlcDeviceId,
      if (causalCursorJson != null) 'causal_cursor_json': causalCursorJson,
      if (createdAt != null) 'created_at': createdAt,
      if (appliedAt != null) 'applied_at': appliedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncChangesCompanion copyWith({
    Value<String>? operationId,
    Value<String>? syncGroupId,
    Value<String>? sourceDeviceId,
    Value<int>? sequence,
    Value<String>? transactionId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operationType,
    Value<String>? fieldGroup,
    Value<int>? payloadFormatVersion,
    Value<String>? payloadJson,
    Value<int>? hlcPhysicalMs,
    Value<int>? hlcLogical,
    Value<String>? hlcDeviceId,
    Value<String>? causalCursorJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? appliedAt,
    Value<int>? rowid,
  }) {
    return SyncChangesCompanion(
      operationId: operationId ?? this.operationId,
      syncGroupId: syncGroupId ?? this.syncGroupId,
      sourceDeviceId: sourceDeviceId ?? this.sourceDeviceId,
      sequence: sequence ?? this.sequence,
      transactionId: transactionId ?? this.transactionId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operationType: operationType ?? this.operationType,
      fieldGroup: fieldGroup ?? this.fieldGroup,
      payloadFormatVersion: payloadFormatVersion ?? this.payloadFormatVersion,
      payloadJson: payloadJson ?? this.payloadJson,
      hlcPhysicalMs: hlcPhysicalMs ?? this.hlcPhysicalMs,
      hlcLogical: hlcLogical ?? this.hlcLogical,
      hlcDeviceId: hlcDeviceId ?? this.hlcDeviceId,
      causalCursorJson: causalCursorJson ?? this.causalCursorJson,
      createdAt: createdAt ?? this.createdAt,
      appliedAt: appliedAt ?? this.appliedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (syncGroupId.present) {
      map['sync_group_id'] = Variable<String>(syncGroupId.value);
    }
    if (sourceDeviceId.present) {
      map['source_device_id'] = Variable<String>(sourceDeviceId.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (fieldGroup.present) {
      map['field_group'] = Variable<String>(fieldGroup.value);
    }
    if (payloadFormatVersion.present) {
      map['payload_format_version'] = Variable<int>(payloadFormatVersion.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (hlcPhysicalMs.present) {
      map['hlc_physical_ms'] = Variable<int>(hlcPhysicalMs.value);
    }
    if (hlcLogical.present) {
      map['hlc_logical'] = Variable<int>(hlcLogical.value);
    }
    if (hlcDeviceId.present) {
      map['hlc_device_id'] = Variable<String>(hlcDeviceId.value);
    }
    if (causalCursorJson.present) {
      map['causal_cursor_json'] = Variable<String>(causalCursorJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (appliedAt.present) {
      map['applied_at'] = Variable<DateTime>(appliedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncChangesCompanion(')
          ..write('operationId: $operationId, ')
          ..write('syncGroupId: $syncGroupId, ')
          ..write('sourceDeviceId: $sourceDeviceId, ')
          ..write('sequence: $sequence, ')
          ..write('transactionId: $transactionId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operationType: $operationType, ')
          ..write('fieldGroup: $fieldGroup, ')
          ..write('payloadFormatVersion: $payloadFormatVersion, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('hlcPhysicalMs: $hlcPhysicalMs, ')
          ..write('hlcLogical: $hlcLogical, ')
          ..write('hlcDeviceId: $hlcDeviceId, ')
          ..write('causalCursorJson: $causalCursorJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncEntityVersionsTable extends SyncEntityVersions
    with TableInfo<$SyncEntityVersionsTable, SyncEntityVersionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncEntityVersionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncGroupIdMeta = const VerificationMeta(
    'syncGroupId',
  );
  @override
  late final GeneratedColumn<String> syncGroupId = GeneratedColumn<String>(
    'sync_group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sync_groups (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldGroupMeta = const VerificationMeta(
    'fieldGroup',
  );
  @override
  late final GeneratedColumn<String> fieldGroup = GeneratedColumn<String>(
    'field_group',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _winningOperationIdMeta =
      const VerificationMeta('winningOperationId');
  @override
  late final GeneratedColumn<String> winningOperationId =
      GeneratedColumn<String>(
        'winning_operation_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _hlcPhysicalMsMeta = const VerificationMeta(
    'hlcPhysicalMs',
  );
  @override
  late final GeneratedColumn<int> hlcPhysicalMs = GeneratedColumn<int>(
    'hlc_physical_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcLogicalMeta = const VerificationMeta(
    'hlcLogical',
  );
  @override
  late final GeneratedColumn<int> hlcLogical = GeneratedColumn<int>(
    'hlc_logical',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcDeviceIdMeta = const VerificationMeta(
    'hlcDeviceId',
  );
  @override
  late final GeneratedColumn<String> hlcDeviceId = GeneratedColumn<String>(
    'hlc_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _causalCursorJsonMeta = const VerificationMeta(
    'causalCursorJson',
  );
  @override
  late final GeneratedColumn<String> causalCursorJson = GeneratedColumn<String>(
    'causal_cursor_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncGroupId,
    entityType,
    entityId,
    fieldGroup,
    winningOperationId,
    hlcPhysicalMs,
    hlcLogical,
    hlcDeviceId,
    causalCursorJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_entity_versions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncEntityVersionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_group_id')) {
      context.handle(
        _syncGroupIdMeta,
        syncGroupId.isAcceptableOrUnknown(
          data['sync_group_id']!,
          _syncGroupIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_syncGroupIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('field_group')) {
      context.handle(
        _fieldGroupMeta,
        fieldGroup.isAcceptableOrUnknown(data['field_group']!, _fieldGroupMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldGroupMeta);
    }
    if (data.containsKey('winning_operation_id')) {
      context.handle(
        _winningOperationIdMeta,
        winningOperationId.isAcceptableOrUnknown(
          data['winning_operation_id']!,
          _winningOperationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_winningOperationIdMeta);
    }
    if (data.containsKey('hlc_physical_ms')) {
      context.handle(
        _hlcPhysicalMsMeta,
        hlcPhysicalMs.isAcceptableOrUnknown(
          data['hlc_physical_ms']!,
          _hlcPhysicalMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hlcPhysicalMsMeta);
    }
    if (data.containsKey('hlc_logical')) {
      context.handle(
        _hlcLogicalMeta,
        hlcLogical.isAcceptableOrUnknown(data['hlc_logical']!, _hlcLogicalMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcLogicalMeta);
    }
    if (data.containsKey('hlc_device_id')) {
      context.handle(
        _hlcDeviceIdMeta,
        hlcDeviceId.isAcceptableOrUnknown(
          data['hlc_device_id']!,
          _hlcDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hlcDeviceIdMeta);
    }
    if (data.containsKey('causal_cursor_json')) {
      context.handle(
        _causalCursorJsonMeta,
        causalCursorJson.isAcceptableOrUnknown(
          data['causal_cursor_json']!,
          _causalCursorJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_causalCursorJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    syncGroupId,
    entityType,
    entityId,
    fieldGroup,
  };
  @override
  SyncEntityVersionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncEntityVersionRow(
      syncGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_group_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      fieldGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_group'],
      )!,
      winningOperationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}winning_operation_id'],
      )!,
      hlcPhysicalMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hlc_physical_ms'],
      )!,
      hlcLogical: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hlc_logical'],
      )!,
      hlcDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc_device_id'],
      )!,
      causalCursorJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}causal_cursor_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SyncEntityVersionsTable createAlias(String alias) {
    return $SyncEntityVersionsTable(attachedDatabase, alias);
  }
}

class SyncEntityVersionRow extends DataClass
    implements Insertable<SyncEntityVersionRow> {
  final String syncGroupId;
  final String entityType;
  final String entityId;
  final String fieldGroup;
  final String winningOperationId;
  final int hlcPhysicalMs;
  final int hlcLogical;
  final String hlcDeviceId;
  final String causalCursorJson;
  final DateTime updatedAt;
  const SyncEntityVersionRow({
    required this.syncGroupId,
    required this.entityType,
    required this.entityId,
    required this.fieldGroup,
    required this.winningOperationId,
    required this.hlcPhysicalMs,
    required this.hlcLogical,
    required this.hlcDeviceId,
    required this.causalCursorJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_group_id'] = Variable<String>(syncGroupId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['field_group'] = Variable<String>(fieldGroup);
    map['winning_operation_id'] = Variable<String>(winningOperationId);
    map['hlc_physical_ms'] = Variable<int>(hlcPhysicalMs);
    map['hlc_logical'] = Variable<int>(hlcLogical);
    map['hlc_device_id'] = Variable<String>(hlcDeviceId);
    map['causal_cursor_json'] = Variable<String>(causalCursorJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncEntityVersionsCompanion toCompanion(bool nullToAbsent) {
    return SyncEntityVersionsCompanion(
      syncGroupId: Value(syncGroupId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      fieldGroup: Value(fieldGroup),
      winningOperationId: Value(winningOperationId),
      hlcPhysicalMs: Value(hlcPhysicalMs),
      hlcLogical: Value(hlcLogical),
      hlcDeviceId: Value(hlcDeviceId),
      causalCursorJson: Value(causalCursorJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncEntityVersionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncEntityVersionRow(
      syncGroupId: serializer.fromJson<String>(json['syncGroupId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      fieldGroup: serializer.fromJson<String>(json['fieldGroup']),
      winningOperationId: serializer.fromJson<String>(
        json['winningOperationId'],
      ),
      hlcPhysicalMs: serializer.fromJson<int>(json['hlcPhysicalMs']),
      hlcLogical: serializer.fromJson<int>(json['hlcLogical']),
      hlcDeviceId: serializer.fromJson<String>(json['hlcDeviceId']),
      causalCursorJson: serializer.fromJson<String>(json['causalCursorJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncGroupId': serializer.toJson<String>(syncGroupId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'fieldGroup': serializer.toJson<String>(fieldGroup),
      'winningOperationId': serializer.toJson<String>(winningOperationId),
      'hlcPhysicalMs': serializer.toJson<int>(hlcPhysicalMs),
      'hlcLogical': serializer.toJson<int>(hlcLogical),
      'hlcDeviceId': serializer.toJson<String>(hlcDeviceId),
      'causalCursorJson': serializer.toJson<String>(causalCursorJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncEntityVersionRow copyWith({
    String? syncGroupId,
    String? entityType,
    String? entityId,
    String? fieldGroup,
    String? winningOperationId,
    int? hlcPhysicalMs,
    int? hlcLogical,
    String? hlcDeviceId,
    String? causalCursorJson,
    DateTime? updatedAt,
  }) => SyncEntityVersionRow(
    syncGroupId: syncGroupId ?? this.syncGroupId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    fieldGroup: fieldGroup ?? this.fieldGroup,
    winningOperationId: winningOperationId ?? this.winningOperationId,
    hlcPhysicalMs: hlcPhysicalMs ?? this.hlcPhysicalMs,
    hlcLogical: hlcLogical ?? this.hlcLogical,
    hlcDeviceId: hlcDeviceId ?? this.hlcDeviceId,
    causalCursorJson: causalCursorJson ?? this.causalCursorJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SyncEntityVersionRow copyWithCompanion(SyncEntityVersionsCompanion data) {
    return SyncEntityVersionRow(
      syncGroupId: data.syncGroupId.present
          ? data.syncGroupId.value
          : this.syncGroupId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      fieldGroup: data.fieldGroup.present
          ? data.fieldGroup.value
          : this.fieldGroup,
      winningOperationId: data.winningOperationId.present
          ? data.winningOperationId.value
          : this.winningOperationId,
      hlcPhysicalMs: data.hlcPhysicalMs.present
          ? data.hlcPhysicalMs.value
          : this.hlcPhysicalMs,
      hlcLogical: data.hlcLogical.present
          ? data.hlcLogical.value
          : this.hlcLogical,
      hlcDeviceId: data.hlcDeviceId.present
          ? data.hlcDeviceId.value
          : this.hlcDeviceId,
      causalCursorJson: data.causalCursorJson.present
          ? data.causalCursorJson.value
          : this.causalCursorJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncEntityVersionRow(')
          ..write('syncGroupId: $syncGroupId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('fieldGroup: $fieldGroup, ')
          ..write('winningOperationId: $winningOperationId, ')
          ..write('hlcPhysicalMs: $hlcPhysicalMs, ')
          ..write('hlcLogical: $hlcLogical, ')
          ..write('hlcDeviceId: $hlcDeviceId, ')
          ..write('causalCursorJson: $causalCursorJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncGroupId,
    entityType,
    entityId,
    fieldGroup,
    winningOperationId,
    hlcPhysicalMs,
    hlcLogical,
    hlcDeviceId,
    causalCursorJson,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncEntityVersionRow &&
          other.syncGroupId == this.syncGroupId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.fieldGroup == this.fieldGroup &&
          other.winningOperationId == this.winningOperationId &&
          other.hlcPhysicalMs == this.hlcPhysicalMs &&
          other.hlcLogical == this.hlcLogical &&
          other.hlcDeviceId == this.hlcDeviceId &&
          other.causalCursorJson == this.causalCursorJson &&
          other.updatedAt == this.updatedAt);
}

class SyncEntityVersionsCompanion
    extends UpdateCompanion<SyncEntityVersionRow> {
  final Value<String> syncGroupId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> fieldGroup;
  final Value<String> winningOperationId;
  final Value<int> hlcPhysicalMs;
  final Value<int> hlcLogical;
  final Value<String> hlcDeviceId;
  final Value<String> causalCursorJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SyncEntityVersionsCompanion({
    this.syncGroupId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.fieldGroup = const Value.absent(),
    this.winningOperationId = const Value.absent(),
    this.hlcPhysicalMs = const Value.absent(),
    this.hlcLogical = const Value.absent(),
    this.hlcDeviceId = const Value.absent(),
    this.causalCursorJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncEntityVersionsCompanion.insert({
    required String syncGroupId,
    required String entityType,
    required String entityId,
    required String fieldGroup,
    required String winningOperationId,
    required int hlcPhysicalMs,
    required int hlcLogical,
    required String hlcDeviceId,
    required String causalCursorJson,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : syncGroupId = Value(syncGroupId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       fieldGroup = Value(fieldGroup),
       winningOperationId = Value(winningOperationId),
       hlcPhysicalMs = Value(hlcPhysicalMs),
       hlcLogical = Value(hlcLogical),
       hlcDeviceId = Value(hlcDeviceId),
       causalCursorJson = Value(causalCursorJson),
       updatedAt = Value(updatedAt);
  static Insertable<SyncEntityVersionRow> custom({
    Expression<String>? syncGroupId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? fieldGroup,
    Expression<String>? winningOperationId,
    Expression<int>? hlcPhysicalMs,
    Expression<int>? hlcLogical,
    Expression<String>? hlcDeviceId,
    Expression<String>? causalCursorJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncGroupId != null) 'sync_group_id': syncGroupId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (fieldGroup != null) 'field_group': fieldGroup,
      if (winningOperationId != null)
        'winning_operation_id': winningOperationId,
      if (hlcPhysicalMs != null) 'hlc_physical_ms': hlcPhysicalMs,
      if (hlcLogical != null) 'hlc_logical': hlcLogical,
      if (hlcDeviceId != null) 'hlc_device_id': hlcDeviceId,
      if (causalCursorJson != null) 'causal_cursor_json': causalCursorJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncEntityVersionsCompanion copyWith({
    Value<String>? syncGroupId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? fieldGroup,
    Value<String>? winningOperationId,
    Value<int>? hlcPhysicalMs,
    Value<int>? hlcLogical,
    Value<String>? hlcDeviceId,
    Value<String>? causalCursorJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SyncEntityVersionsCompanion(
      syncGroupId: syncGroupId ?? this.syncGroupId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      fieldGroup: fieldGroup ?? this.fieldGroup,
      winningOperationId: winningOperationId ?? this.winningOperationId,
      hlcPhysicalMs: hlcPhysicalMs ?? this.hlcPhysicalMs,
      hlcLogical: hlcLogical ?? this.hlcLogical,
      hlcDeviceId: hlcDeviceId ?? this.hlcDeviceId,
      causalCursorJson: causalCursorJson ?? this.causalCursorJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncGroupId.present) {
      map['sync_group_id'] = Variable<String>(syncGroupId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (fieldGroup.present) {
      map['field_group'] = Variable<String>(fieldGroup.value);
    }
    if (winningOperationId.present) {
      map['winning_operation_id'] = Variable<String>(winningOperationId.value);
    }
    if (hlcPhysicalMs.present) {
      map['hlc_physical_ms'] = Variable<int>(hlcPhysicalMs.value);
    }
    if (hlcLogical.present) {
      map['hlc_logical'] = Variable<int>(hlcLogical.value);
    }
    if (hlcDeviceId.present) {
      map['hlc_device_id'] = Variable<String>(hlcDeviceId.value);
    }
    if (causalCursorJson.present) {
      map['causal_cursor_json'] = Variable<String>(causalCursorJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncEntityVersionsCompanion(')
          ..write('syncGroupId: $syncGroupId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('fieldGroup: $fieldGroup, ')
          ..write('winningOperationId: $winningOperationId, ')
          ..write('hlcPhysicalMs: $hlcPhysicalMs, ')
          ..write('hlcLogical: $hlcLogical, ')
          ..write('hlcDeviceId: $hlcDeviceId, ')
          ..write('causalCursorJson: $causalCursorJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncRelationDotsTable extends SyncRelationDots
    with TableInfo<$SyncRelationDotsTable, SyncRelationDotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncRelationDotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncGroupIdMeta = const VerificationMeta(
    'syncGroupId',
  );
  @override
  late final GeneratedColumn<String> syncGroupId = GeneratedColumn<String>(
    'sync_group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sync_groups (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _todoIdMeta = const VerificationMeta('todoId');
  @override
  late final GeneratedColumn<String> todoId = GeneratedColumn<String>(
    'todo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addOperationIdMeta = const VerificationMeta(
    'addOperationId',
  );
  @override
  late final GeneratedColumn<String> addOperationId = GeneratedColumn<String>(
    'add_operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedByDeviceIdMeta = const VerificationMeta(
    'addedByDeviceId',
  );
  @override
  late final GeneratedColumn<String> addedByDeviceId = GeneratedColumn<String>(
    'added_by_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedSequenceMeta = const VerificationMeta(
    'addedSequence',
  );
  @override
  late final GeneratedColumn<int> addedSequence = GeneratedColumn<int>(
    'added_sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _removedByOperationIdMeta =
      const VerificationMeta('removedByOperationId');
  @override
  late final GeneratedColumn<String> removedByOperationId =
      GeneratedColumn<String>(
        'removed_by_operation_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _removedAtMeta = const VerificationMeta(
    'removedAt',
  );
  @override
  late final GeneratedColumn<DateTime> removedAt = GeneratedColumn<DateTime>(
    'removed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncGroupId,
    todoId,
    tagId,
    addOperationId,
    addedByDeviceId,
    addedSequence,
    removedByOperationId,
    createdAt,
    removedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_relation_dots';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncRelationDotRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_group_id')) {
      context.handle(
        _syncGroupIdMeta,
        syncGroupId.isAcceptableOrUnknown(
          data['sync_group_id']!,
          _syncGroupIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_syncGroupIdMeta);
    }
    if (data.containsKey('todo_id')) {
      context.handle(
        _todoIdMeta,
        todoId.isAcceptableOrUnknown(data['todo_id']!, _todoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_todoIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    if (data.containsKey('add_operation_id')) {
      context.handle(
        _addOperationIdMeta,
        addOperationId.isAcceptableOrUnknown(
          data['add_operation_id']!,
          _addOperationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_addOperationIdMeta);
    }
    if (data.containsKey('added_by_device_id')) {
      context.handle(
        _addedByDeviceIdMeta,
        addedByDeviceId.isAcceptableOrUnknown(
          data['added_by_device_id']!,
          _addedByDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_addedByDeviceIdMeta);
    }
    if (data.containsKey('added_sequence')) {
      context.handle(
        _addedSequenceMeta,
        addedSequence.isAcceptableOrUnknown(
          data['added_sequence']!,
          _addedSequenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_addedSequenceMeta);
    }
    if (data.containsKey('removed_by_operation_id')) {
      context.handle(
        _removedByOperationIdMeta,
        removedByOperationId.isAcceptableOrUnknown(
          data['removed_by_operation_id']!,
          _removedByOperationIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('removed_at')) {
      context.handle(
        _removedAtMeta,
        removedAt.isAcceptableOrUnknown(data['removed_at']!, _removedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {syncGroupId, addOperationId};
  @override
  SyncRelationDotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncRelationDotRow(
      syncGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_group_id'],
      )!,
      todoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}todo_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
      addOperationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}add_operation_id'],
      )!,
      addedByDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}added_by_device_id'],
      )!,
      addedSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}added_sequence'],
      )!,
      removedByOperationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}removed_by_operation_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      removedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}removed_at'],
      ),
    );
  }

  @override
  $SyncRelationDotsTable createAlias(String alias) {
    return $SyncRelationDotsTable(attachedDatabase, alias);
  }
}

class SyncRelationDotRow extends DataClass
    implements Insertable<SyncRelationDotRow> {
  final String syncGroupId;
  final String todoId;
  final String tagId;
  final String addOperationId;
  final String addedByDeviceId;
  final int addedSequence;
  final String? removedByOperationId;
  final DateTime createdAt;
  final DateTime? removedAt;
  const SyncRelationDotRow({
    required this.syncGroupId,
    required this.todoId,
    required this.tagId,
    required this.addOperationId,
    required this.addedByDeviceId,
    required this.addedSequence,
    this.removedByOperationId,
    required this.createdAt,
    this.removedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_group_id'] = Variable<String>(syncGroupId);
    map['todo_id'] = Variable<String>(todoId);
    map['tag_id'] = Variable<String>(tagId);
    map['add_operation_id'] = Variable<String>(addOperationId);
    map['added_by_device_id'] = Variable<String>(addedByDeviceId);
    map['added_sequence'] = Variable<int>(addedSequence);
    if (!nullToAbsent || removedByOperationId != null) {
      map['removed_by_operation_id'] = Variable<String>(removedByOperationId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || removedAt != null) {
      map['removed_at'] = Variable<DateTime>(removedAt);
    }
    return map;
  }

  SyncRelationDotsCompanion toCompanion(bool nullToAbsent) {
    return SyncRelationDotsCompanion(
      syncGroupId: Value(syncGroupId),
      todoId: Value(todoId),
      tagId: Value(tagId),
      addOperationId: Value(addOperationId),
      addedByDeviceId: Value(addedByDeviceId),
      addedSequence: Value(addedSequence),
      removedByOperationId: removedByOperationId == null && nullToAbsent
          ? const Value.absent()
          : Value(removedByOperationId),
      createdAt: Value(createdAt),
      removedAt: removedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(removedAt),
    );
  }

  factory SyncRelationDotRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncRelationDotRow(
      syncGroupId: serializer.fromJson<String>(json['syncGroupId']),
      todoId: serializer.fromJson<String>(json['todoId']),
      tagId: serializer.fromJson<String>(json['tagId']),
      addOperationId: serializer.fromJson<String>(json['addOperationId']),
      addedByDeviceId: serializer.fromJson<String>(json['addedByDeviceId']),
      addedSequence: serializer.fromJson<int>(json['addedSequence']),
      removedByOperationId: serializer.fromJson<String?>(
        json['removedByOperationId'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      removedAt: serializer.fromJson<DateTime?>(json['removedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncGroupId': serializer.toJson<String>(syncGroupId),
      'todoId': serializer.toJson<String>(todoId),
      'tagId': serializer.toJson<String>(tagId),
      'addOperationId': serializer.toJson<String>(addOperationId),
      'addedByDeviceId': serializer.toJson<String>(addedByDeviceId),
      'addedSequence': serializer.toJson<int>(addedSequence),
      'removedByOperationId': serializer.toJson<String?>(removedByOperationId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'removedAt': serializer.toJson<DateTime?>(removedAt),
    };
  }

  SyncRelationDotRow copyWith({
    String? syncGroupId,
    String? todoId,
    String? tagId,
    String? addOperationId,
    String? addedByDeviceId,
    int? addedSequence,
    Value<String?> removedByOperationId = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> removedAt = const Value.absent(),
  }) => SyncRelationDotRow(
    syncGroupId: syncGroupId ?? this.syncGroupId,
    todoId: todoId ?? this.todoId,
    tagId: tagId ?? this.tagId,
    addOperationId: addOperationId ?? this.addOperationId,
    addedByDeviceId: addedByDeviceId ?? this.addedByDeviceId,
    addedSequence: addedSequence ?? this.addedSequence,
    removedByOperationId: removedByOperationId.present
        ? removedByOperationId.value
        : this.removedByOperationId,
    createdAt: createdAt ?? this.createdAt,
    removedAt: removedAt.present ? removedAt.value : this.removedAt,
  );
  SyncRelationDotRow copyWithCompanion(SyncRelationDotsCompanion data) {
    return SyncRelationDotRow(
      syncGroupId: data.syncGroupId.present
          ? data.syncGroupId.value
          : this.syncGroupId,
      todoId: data.todoId.present ? data.todoId.value : this.todoId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      addOperationId: data.addOperationId.present
          ? data.addOperationId.value
          : this.addOperationId,
      addedByDeviceId: data.addedByDeviceId.present
          ? data.addedByDeviceId.value
          : this.addedByDeviceId,
      addedSequence: data.addedSequence.present
          ? data.addedSequence.value
          : this.addedSequence,
      removedByOperationId: data.removedByOperationId.present
          ? data.removedByOperationId.value
          : this.removedByOperationId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      removedAt: data.removedAt.present ? data.removedAt.value : this.removedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncRelationDotRow(')
          ..write('syncGroupId: $syncGroupId, ')
          ..write('todoId: $todoId, ')
          ..write('tagId: $tagId, ')
          ..write('addOperationId: $addOperationId, ')
          ..write('addedByDeviceId: $addedByDeviceId, ')
          ..write('addedSequence: $addedSequence, ')
          ..write('removedByOperationId: $removedByOperationId, ')
          ..write('createdAt: $createdAt, ')
          ..write('removedAt: $removedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncGroupId,
    todoId,
    tagId,
    addOperationId,
    addedByDeviceId,
    addedSequence,
    removedByOperationId,
    createdAt,
    removedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncRelationDotRow &&
          other.syncGroupId == this.syncGroupId &&
          other.todoId == this.todoId &&
          other.tagId == this.tagId &&
          other.addOperationId == this.addOperationId &&
          other.addedByDeviceId == this.addedByDeviceId &&
          other.addedSequence == this.addedSequence &&
          other.removedByOperationId == this.removedByOperationId &&
          other.createdAt == this.createdAt &&
          other.removedAt == this.removedAt);
}

class SyncRelationDotsCompanion extends UpdateCompanion<SyncRelationDotRow> {
  final Value<String> syncGroupId;
  final Value<String> todoId;
  final Value<String> tagId;
  final Value<String> addOperationId;
  final Value<String> addedByDeviceId;
  final Value<int> addedSequence;
  final Value<String?> removedByOperationId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> removedAt;
  final Value<int> rowid;
  const SyncRelationDotsCompanion({
    this.syncGroupId = const Value.absent(),
    this.todoId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.addOperationId = const Value.absent(),
    this.addedByDeviceId = const Value.absent(),
    this.addedSequence = const Value.absent(),
    this.removedByOperationId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.removedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncRelationDotsCompanion.insert({
    required String syncGroupId,
    required String todoId,
    required String tagId,
    required String addOperationId,
    required String addedByDeviceId,
    required int addedSequence,
    this.removedByOperationId = const Value.absent(),
    required DateTime createdAt,
    this.removedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : syncGroupId = Value(syncGroupId),
       todoId = Value(todoId),
       tagId = Value(tagId),
       addOperationId = Value(addOperationId),
       addedByDeviceId = Value(addedByDeviceId),
       addedSequence = Value(addedSequence),
       createdAt = Value(createdAt);
  static Insertable<SyncRelationDotRow> custom({
    Expression<String>? syncGroupId,
    Expression<String>? todoId,
    Expression<String>? tagId,
    Expression<String>? addOperationId,
    Expression<String>? addedByDeviceId,
    Expression<int>? addedSequence,
    Expression<String>? removedByOperationId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? removedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncGroupId != null) 'sync_group_id': syncGroupId,
      if (todoId != null) 'todo_id': todoId,
      if (tagId != null) 'tag_id': tagId,
      if (addOperationId != null) 'add_operation_id': addOperationId,
      if (addedByDeviceId != null) 'added_by_device_id': addedByDeviceId,
      if (addedSequence != null) 'added_sequence': addedSequence,
      if (removedByOperationId != null)
        'removed_by_operation_id': removedByOperationId,
      if (createdAt != null) 'created_at': createdAt,
      if (removedAt != null) 'removed_at': removedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncRelationDotsCompanion copyWith({
    Value<String>? syncGroupId,
    Value<String>? todoId,
    Value<String>? tagId,
    Value<String>? addOperationId,
    Value<String>? addedByDeviceId,
    Value<int>? addedSequence,
    Value<String?>? removedByOperationId,
    Value<DateTime>? createdAt,
    Value<DateTime?>? removedAt,
    Value<int>? rowid,
  }) {
    return SyncRelationDotsCompanion(
      syncGroupId: syncGroupId ?? this.syncGroupId,
      todoId: todoId ?? this.todoId,
      tagId: tagId ?? this.tagId,
      addOperationId: addOperationId ?? this.addOperationId,
      addedByDeviceId: addedByDeviceId ?? this.addedByDeviceId,
      addedSequence: addedSequence ?? this.addedSequence,
      removedByOperationId: removedByOperationId ?? this.removedByOperationId,
      createdAt: createdAt ?? this.createdAt,
      removedAt: removedAt ?? this.removedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncGroupId.present) {
      map['sync_group_id'] = Variable<String>(syncGroupId.value);
    }
    if (todoId.present) {
      map['todo_id'] = Variable<String>(todoId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (addOperationId.present) {
      map['add_operation_id'] = Variable<String>(addOperationId.value);
    }
    if (addedByDeviceId.present) {
      map['added_by_device_id'] = Variable<String>(addedByDeviceId.value);
    }
    if (addedSequence.present) {
      map['added_sequence'] = Variable<int>(addedSequence.value);
    }
    if (removedByOperationId.present) {
      map['removed_by_operation_id'] = Variable<String>(
        removedByOperationId.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (removedAt.present) {
      map['removed_at'] = Variable<DateTime>(removedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncRelationDotsCompanion(')
          ..write('syncGroupId: $syncGroupId, ')
          ..write('todoId: $todoId, ')
          ..write('tagId: $tagId, ')
          ..write('addOperationId: $addOperationId, ')
          ..write('addedByDeviceId: $addedByDeviceId, ')
          ..write('addedSequence: $addedSequence, ')
          ..write('removedByOperationId: $removedByOperationId, ')
          ..write('createdAt: $createdAt, ')
          ..write('removedAt: $removedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors
    with TableInfo<$SyncCursorsTable, SyncCursorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncGroupIdMeta = const VerificationMeta(
    'syncGroupId',
  );
  @override
  late final GeneratedColumn<String> syncGroupId = GeneratedColumn<String>(
    'sync_group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sync_groups (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _peerDeviceIdMeta = const VerificationMeta(
    'peerDeviceId',
  );
  @override
  late final GeneratedColumn<String> peerDeviceId = GeneratedColumn<String>(
    'peer_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceDeviceIdMeta = const VerificationMeta(
    'sourceDeviceId',
  );
  @override
  late final GeneratedColumn<String> sourceDeviceId = GeneratedColumn<String>(
    'source_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _acknowledgedSequenceMeta =
      const VerificationMeta('acknowledgedSequence');
  @override
  late final GeneratedColumn<int> acknowledgedSequence = GeneratedColumn<int>(
    'acknowledged_sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncGroupId,
    peerDeviceId,
    sourceDeviceId,
    acknowledgedSequence,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCursorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_group_id')) {
      context.handle(
        _syncGroupIdMeta,
        syncGroupId.isAcceptableOrUnknown(
          data['sync_group_id']!,
          _syncGroupIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_syncGroupIdMeta);
    }
    if (data.containsKey('peer_device_id')) {
      context.handle(
        _peerDeviceIdMeta,
        peerDeviceId.isAcceptableOrUnknown(
          data['peer_device_id']!,
          _peerDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_peerDeviceIdMeta);
    }
    if (data.containsKey('source_device_id')) {
      context.handle(
        _sourceDeviceIdMeta,
        sourceDeviceId.isAcceptableOrUnknown(
          data['source_device_id']!,
          _sourceDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceDeviceIdMeta);
    }
    if (data.containsKey('acknowledged_sequence')) {
      context.handle(
        _acknowledgedSequenceMeta,
        acknowledgedSequence.isAcceptableOrUnknown(
          data['acknowledged_sequence']!,
          _acknowledgedSequenceMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    syncGroupId,
    peerDeviceId,
    sourceDeviceId,
  };
  @override
  SyncCursorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursorRow(
      syncGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_group_id'],
      )!,
      peerDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}peer_device_id'],
      )!,
      sourceDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_device_id'],
      )!,
      acknowledgedSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}acknowledged_sequence'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class SyncCursorRow extends DataClass implements Insertable<SyncCursorRow> {
  final String syncGroupId;
  final String peerDeviceId;
  final String sourceDeviceId;
  final int acknowledgedSequence;
  final DateTime updatedAt;
  const SyncCursorRow({
    required this.syncGroupId,
    required this.peerDeviceId,
    required this.sourceDeviceId,
    required this.acknowledgedSequence,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_group_id'] = Variable<String>(syncGroupId);
    map['peer_device_id'] = Variable<String>(peerDeviceId);
    map['source_device_id'] = Variable<String>(sourceDeviceId);
    map['acknowledged_sequence'] = Variable<int>(acknowledgedSequence);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      syncGroupId: Value(syncGroupId),
      peerDeviceId: Value(peerDeviceId),
      sourceDeviceId: Value(sourceDeviceId),
      acknowledgedSequence: Value(acknowledgedSequence),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncCursorRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursorRow(
      syncGroupId: serializer.fromJson<String>(json['syncGroupId']),
      peerDeviceId: serializer.fromJson<String>(json['peerDeviceId']),
      sourceDeviceId: serializer.fromJson<String>(json['sourceDeviceId']),
      acknowledgedSequence: serializer.fromJson<int>(
        json['acknowledgedSequence'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncGroupId': serializer.toJson<String>(syncGroupId),
      'peerDeviceId': serializer.toJson<String>(peerDeviceId),
      'sourceDeviceId': serializer.toJson<String>(sourceDeviceId),
      'acknowledgedSequence': serializer.toJson<int>(acknowledgedSequence),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncCursorRow copyWith({
    String? syncGroupId,
    String? peerDeviceId,
    String? sourceDeviceId,
    int? acknowledgedSequence,
    DateTime? updatedAt,
  }) => SyncCursorRow(
    syncGroupId: syncGroupId ?? this.syncGroupId,
    peerDeviceId: peerDeviceId ?? this.peerDeviceId,
    sourceDeviceId: sourceDeviceId ?? this.sourceDeviceId,
    acknowledgedSequence: acknowledgedSequence ?? this.acknowledgedSequence,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SyncCursorRow copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursorRow(
      syncGroupId: data.syncGroupId.present
          ? data.syncGroupId.value
          : this.syncGroupId,
      peerDeviceId: data.peerDeviceId.present
          ? data.peerDeviceId.value
          : this.peerDeviceId,
      sourceDeviceId: data.sourceDeviceId.present
          ? data.sourceDeviceId.value
          : this.sourceDeviceId,
      acknowledgedSequence: data.acknowledgedSequence.present
          ? data.acknowledgedSequence.value
          : this.acknowledgedSequence,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorRow(')
          ..write('syncGroupId: $syncGroupId, ')
          ..write('peerDeviceId: $peerDeviceId, ')
          ..write('sourceDeviceId: $sourceDeviceId, ')
          ..write('acknowledgedSequence: $acknowledgedSequence, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncGroupId,
    peerDeviceId,
    sourceDeviceId,
    acknowledgedSequence,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursorRow &&
          other.syncGroupId == this.syncGroupId &&
          other.peerDeviceId == this.peerDeviceId &&
          other.sourceDeviceId == this.sourceDeviceId &&
          other.acknowledgedSequence == this.acknowledgedSequence &&
          other.updatedAt == this.updatedAt);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursorRow> {
  final Value<String> syncGroupId;
  final Value<String> peerDeviceId;
  final Value<String> sourceDeviceId;
  final Value<int> acknowledgedSequence;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.syncGroupId = const Value.absent(),
    this.peerDeviceId = const Value.absent(),
    this.sourceDeviceId = const Value.absent(),
    this.acknowledgedSequence = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    required String syncGroupId,
    required String peerDeviceId,
    required String sourceDeviceId,
    this.acknowledgedSequence = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : syncGroupId = Value(syncGroupId),
       peerDeviceId = Value(peerDeviceId),
       sourceDeviceId = Value(sourceDeviceId),
       updatedAt = Value(updatedAt);
  static Insertable<SyncCursorRow> custom({
    Expression<String>? syncGroupId,
    Expression<String>? peerDeviceId,
    Expression<String>? sourceDeviceId,
    Expression<int>? acknowledgedSequence,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncGroupId != null) 'sync_group_id': syncGroupId,
      if (peerDeviceId != null) 'peer_device_id': peerDeviceId,
      if (sourceDeviceId != null) 'source_device_id': sourceDeviceId,
      if (acknowledgedSequence != null)
        'acknowledged_sequence': acknowledgedSequence,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith({
    Value<String>? syncGroupId,
    Value<String>? peerDeviceId,
    Value<String>? sourceDeviceId,
    Value<int>? acknowledgedSequence,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SyncCursorsCompanion(
      syncGroupId: syncGroupId ?? this.syncGroupId,
      peerDeviceId: peerDeviceId ?? this.peerDeviceId,
      sourceDeviceId: sourceDeviceId ?? this.sourceDeviceId,
      acknowledgedSequence: acknowledgedSequence ?? this.acknowledgedSequence,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncGroupId.present) {
      map['sync_group_id'] = Variable<String>(syncGroupId.value);
    }
    if (peerDeviceId.present) {
      map['peer_device_id'] = Variable<String>(peerDeviceId.value);
    }
    if (sourceDeviceId.present) {
      map['source_device_id'] = Variable<String>(sourceDeviceId.value);
    }
    if (acknowledgedSequence.present) {
      map['acknowledged_sequence'] = Variable<int>(acknowledgedSequence.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('syncGroupId: $syncGroupId, ')
          ..write('peerDeviceId: $peerDeviceId, ')
          ..write('sourceDeviceId: $sourceDeviceId, ')
          ..write('acknowledgedSequence: $acknowledgedSequence, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncConflictsTable extends SyncConflicts
    with TableInfo<$SyncConflictsTable, SyncConflictRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncGroupIdMeta = const VerificationMeta(
    'syncGroupId',
  );
  @override
  late final GeneratedColumn<String> syncGroupId = GeneratedColumn<String>(
    'sync_group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sync_groups (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldGroupMeta = const VerificationMeta(
    'fieldGroup',
  );
  @override
  late final GeneratedColumn<String> fieldGroup = GeneratedColumn<String>(
    'field_group',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _winnerOperationIdMeta = const VerificationMeta(
    'winnerOperationId',
  );
  @override
  late final GeneratedColumn<String> winnerOperationId =
      GeneratedColumn<String>(
        'winner_operation_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _loserOperationIdMeta = const VerificationMeta(
    'loserOperationId',
  );
  @override
  late final GeneratedColumn<String> loserOperationId = GeneratedColumn<String>(
    'loser_operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _losingPayloadJsonMeta = const VerificationMeta(
    'losingPayloadJson',
  );
  @override
  late final GeneratedColumn<String> losingPayloadJson =
      GeneratedColumn<String>(
        'losing_payload_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resolutionOperationIdMeta =
      const VerificationMeta('resolutionOperationId');
  @override
  late final GeneratedColumn<String> resolutionOperationId =
      GeneratedColumn<String>(
        'resolution_operation_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncGroupId,
    entityType,
    entityId,
    fieldGroup,
    kind,
    winnerOperationId,
    loserOperationId,
    losingPayloadJson,
    createdAt,
    resolvedAt,
    resolutionOperationId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncConflictRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sync_group_id')) {
      context.handle(
        _syncGroupIdMeta,
        syncGroupId.isAcceptableOrUnknown(
          data['sync_group_id']!,
          _syncGroupIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_syncGroupIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('field_group')) {
      context.handle(
        _fieldGroupMeta,
        fieldGroup.isAcceptableOrUnknown(data['field_group']!, _fieldGroupMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldGroupMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('winner_operation_id')) {
      context.handle(
        _winnerOperationIdMeta,
        winnerOperationId.isAcceptableOrUnknown(
          data['winner_operation_id']!,
          _winnerOperationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_winnerOperationIdMeta);
    }
    if (data.containsKey('loser_operation_id')) {
      context.handle(
        _loserOperationIdMeta,
        loserOperationId.isAcceptableOrUnknown(
          data['loser_operation_id']!,
          _loserOperationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_loserOperationIdMeta);
    }
    if (data.containsKey('losing_payload_json')) {
      context.handle(
        _losingPayloadJsonMeta,
        losingPayloadJson.isAcceptableOrUnknown(
          data['losing_payload_json']!,
          _losingPayloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_losingPayloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    if (data.containsKey('resolution_operation_id')) {
      context.handle(
        _resolutionOperationIdMeta,
        resolutionOperationId.isAcceptableOrUnknown(
          data['resolution_operation_id']!,
          _resolutionOperationIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncConflictRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncConflictRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_group_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      fieldGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_group'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      winnerOperationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}winner_operation_id'],
      )!,
      loserOperationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}loser_operation_id'],
      )!,
      losingPayloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}losing_payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
      resolutionOperationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution_operation_id'],
      ),
    );
  }

  @override
  $SyncConflictsTable createAlias(String alias) {
    return $SyncConflictsTable(attachedDatabase, alias);
  }
}

class SyncConflictRow extends DataClass implements Insertable<SyncConflictRow> {
  final String id;
  final String syncGroupId;
  final String entityType;
  final String entityId;
  final String fieldGroup;
  final String kind;
  final String winnerOperationId;
  final String loserOperationId;
  final String losingPayloadJson;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolutionOperationId;
  const SyncConflictRow({
    required this.id,
    required this.syncGroupId,
    required this.entityType,
    required this.entityId,
    required this.fieldGroup,
    required this.kind,
    required this.winnerOperationId,
    required this.loserOperationId,
    required this.losingPayloadJson,
    required this.createdAt,
    this.resolvedAt,
    this.resolutionOperationId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sync_group_id'] = Variable<String>(syncGroupId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['field_group'] = Variable<String>(fieldGroup);
    map['kind'] = Variable<String>(kind);
    map['winner_operation_id'] = Variable<String>(winnerOperationId);
    map['loser_operation_id'] = Variable<String>(loserOperationId);
    map['losing_payload_json'] = Variable<String>(losingPayloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    if (!nullToAbsent || resolutionOperationId != null) {
      map['resolution_operation_id'] = Variable<String>(resolutionOperationId);
    }
    return map;
  }

  SyncConflictsCompanion toCompanion(bool nullToAbsent) {
    return SyncConflictsCompanion(
      id: Value(id),
      syncGroupId: Value(syncGroupId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      fieldGroup: Value(fieldGroup),
      kind: Value(kind),
      winnerOperationId: Value(winnerOperationId),
      loserOperationId: Value(loserOperationId),
      losingPayloadJson: Value(losingPayloadJson),
      createdAt: Value(createdAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
      resolutionOperationId: resolutionOperationId == null && nullToAbsent
          ? const Value.absent()
          : Value(resolutionOperationId),
    );
  }

  factory SyncConflictRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncConflictRow(
      id: serializer.fromJson<String>(json['id']),
      syncGroupId: serializer.fromJson<String>(json['syncGroupId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      fieldGroup: serializer.fromJson<String>(json['fieldGroup']),
      kind: serializer.fromJson<String>(json['kind']),
      winnerOperationId: serializer.fromJson<String>(json['winnerOperationId']),
      loserOperationId: serializer.fromJson<String>(json['loserOperationId']),
      losingPayloadJson: serializer.fromJson<String>(json['losingPayloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
      resolutionOperationId: serializer.fromJson<String?>(
        json['resolutionOperationId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncGroupId': serializer.toJson<String>(syncGroupId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'fieldGroup': serializer.toJson<String>(fieldGroup),
      'kind': serializer.toJson<String>(kind),
      'winnerOperationId': serializer.toJson<String>(winnerOperationId),
      'loserOperationId': serializer.toJson<String>(loserOperationId),
      'losingPayloadJson': serializer.toJson<String>(losingPayloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
      'resolutionOperationId': serializer.toJson<String?>(
        resolutionOperationId,
      ),
    };
  }

  SyncConflictRow copyWith({
    String? id,
    String? syncGroupId,
    String? entityType,
    String? entityId,
    String? fieldGroup,
    String? kind,
    String? winnerOperationId,
    String? loserOperationId,
    String? losingPayloadJson,
    DateTime? createdAt,
    Value<DateTime?> resolvedAt = const Value.absent(),
    Value<String?> resolutionOperationId = const Value.absent(),
  }) => SyncConflictRow(
    id: id ?? this.id,
    syncGroupId: syncGroupId ?? this.syncGroupId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    fieldGroup: fieldGroup ?? this.fieldGroup,
    kind: kind ?? this.kind,
    winnerOperationId: winnerOperationId ?? this.winnerOperationId,
    loserOperationId: loserOperationId ?? this.loserOperationId,
    losingPayloadJson: losingPayloadJson ?? this.losingPayloadJson,
    createdAt: createdAt ?? this.createdAt,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
    resolutionOperationId: resolutionOperationId.present
        ? resolutionOperationId.value
        : this.resolutionOperationId,
  );
  SyncConflictRow copyWithCompanion(SyncConflictsCompanion data) {
    return SyncConflictRow(
      id: data.id.present ? data.id.value : this.id,
      syncGroupId: data.syncGroupId.present
          ? data.syncGroupId.value
          : this.syncGroupId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      fieldGroup: data.fieldGroup.present
          ? data.fieldGroup.value
          : this.fieldGroup,
      kind: data.kind.present ? data.kind.value : this.kind,
      winnerOperationId: data.winnerOperationId.present
          ? data.winnerOperationId.value
          : this.winnerOperationId,
      loserOperationId: data.loserOperationId.present
          ? data.loserOperationId.value
          : this.loserOperationId,
      losingPayloadJson: data.losingPayloadJson.present
          ? data.losingPayloadJson.value
          : this.losingPayloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
      resolutionOperationId: data.resolutionOperationId.present
          ? data.resolutionOperationId.value
          : this.resolutionOperationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictRow(')
          ..write('id: $id, ')
          ..write('syncGroupId: $syncGroupId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('fieldGroup: $fieldGroup, ')
          ..write('kind: $kind, ')
          ..write('winnerOperationId: $winnerOperationId, ')
          ..write('loserOperationId: $loserOperationId, ')
          ..write('losingPayloadJson: $losingPayloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('resolutionOperationId: $resolutionOperationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncGroupId,
    entityType,
    entityId,
    fieldGroup,
    kind,
    winnerOperationId,
    loserOperationId,
    losingPayloadJson,
    createdAt,
    resolvedAt,
    resolutionOperationId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncConflictRow &&
          other.id == this.id &&
          other.syncGroupId == this.syncGroupId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.fieldGroup == this.fieldGroup &&
          other.kind == this.kind &&
          other.winnerOperationId == this.winnerOperationId &&
          other.loserOperationId == this.loserOperationId &&
          other.losingPayloadJson == this.losingPayloadJson &&
          other.createdAt == this.createdAt &&
          other.resolvedAt == this.resolvedAt &&
          other.resolutionOperationId == this.resolutionOperationId);
}

class SyncConflictsCompanion extends UpdateCompanion<SyncConflictRow> {
  final Value<String> id;
  final Value<String> syncGroupId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> fieldGroup;
  final Value<String> kind;
  final Value<String> winnerOperationId;
  final Value<String> loserOperationId;
  final Value<String> losingPayloadJson;
  final Value<DateTime> createdAt;
  final Value<DateTime?> resolvedAt;
  final Value<String?> resolutionOperationId;
  final Value<int> rowid;
  const SyncConflictsCompanion({
    this.id = const Value.absent(),
    this.syncGroupId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.fieldGroup = const Value.absent(),
    this.kind = const Value.absent(),
    this.winnerOperationId = const Value.absent(),
    this.loserOperationId = const Value.absent(),
    this.losingPayloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.resolutionOperationId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncConflictsCompanion.insert({
    required String id,
    required String syncGroupId,
    required String entityType,
    required String entityId,
    required String fieldGroup,
    required String kind,
    required String winnerOperationId,
    required String loserOperationId,
    required String losingPayloadJson,
    required DateTime createdAt,
    this.resolvedAt = const Value.absent(),
    this.resolutionOperationId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       syncGroupId = Value(syncGroupId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       fieldGroup = Value(fieldGroup),
       kind = Value(kind),
       winnerOperationId = Value(winnerOperationId),
       loserOperationId = Value(loserOperationId),
       losingPayloadJson = Value(losingPayloadJson),
       createdAt = Value(createdAt);
  static Insertable<SyncConflictRow> custom({
    Expression<String>? id,
    Expression<String>? syncGroupId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? fieldGroup,
    Expression<String>? kind,
    Expression<String>? winnerOperationId,
    Expression<String>? loserOperationId,
    Expression<String>? losingPayloadJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? resolvedAt,
    Expression<String>? resolutionOperationId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncGroupId != null) 'sync_group_id': syncGroupId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (fieldGroup != null) 'field_group': fieldGroup,
      if (kind != null) 'kind': kind,
      if (winnerOperationId != null) 'winner_operation_id': winnerOperationId,
      if (loserOperationId != null) 'loser_operation_id': loserOperationId,
      if (losingPayloadJson != null) 'losing_payload_json': losingPayloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (resolutionOperationId != null)
        'resolution_operation_id': resolutionOperationId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncConflictsCompanion copyWith({
    Value<String>? id,
    Value<String>? syncGroupId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? fieldGroup,
    Value<String>? kind,
    Value<String>? winnerOperationId,
    Value<String>? loserOperationId,
    Value<String>? losingPayloadJson,
    Value<DateTime>? createdAt,
    Value<DateTime?>? resolvedAt,
    Value<String?>? resolutionOperationId,
    Value<int>? rowid,
  }) {
    return SyncConflictsCompanion(
      id: id ?? this.id,
      syncGroupId: syncGroupId ?? this.syncGroupId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      fieldGroup: fieldGroup ?? this.fieldGroup,
      kind: kind ?? this.kind,
      winnerOperationId: winnerOperationId ?? this.winnerOperationId,
      loserOperationId: loserOperationId ?? this.loserOperationId,
      losingPayloadJson: losingPayloadJson ?? this.losingPayloadJson,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolutionOperationId:
          resolutionOperationId ?? this.resolutionOperationId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncGroupId.present) {
      map['sync_group_id'] = Variable<String>(syncGroupId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (fieldGroup.present) {
      map['field_group'] = Variable<String>(fieldGroup.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (winnerOperationId.present) {
      map['winner_operation_id'] = Variable<String>(winnerOperationId.value);
    }
    if (loserOperationId.present) {
      map['loser_operation_id'] = Variable<String>(loserOperationId.value);
    }
    if (losingPayloadJson.present) {
      map['losing_payload_json'] = Variable<String>(losingPayloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (resolutionOperationId.present) {
      map['resolution_operation_id'] = Variable<String>(
        resolutionOperationId.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictsCompanion(')
          ..write('id: $id, ')
          ..write('syncGroupId: $syncGroupId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('fieldGroup: $fieldGroup, ')
          ..write('kind: $kind, ')
          ..write('winnerOperationId: $winnerOperationId, ')
          ..write('loserOperationId: $loserOperationId, ')
          ..write('losingPayloadJson: $losingPayloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('resolutionOperationId: $resolutionOperationId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncRuntimeStatesTable extends SyncRuntimeStates
    with TableInfo<$SyncRuntimeStatesTable, SyncRuntimeStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncRuntimeStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_runtime_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncRuntimeStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncRuntimeStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncRuntimeStateRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SyncRuntimeStatesTable createAlias(String alias) {
    return $SyncRuntimeStatesTable(attachedDatabase, alias);
  }
}

class SyncRuntimeStateRow extends DataClass
    implements Insertable<SyncRuntimeStateRow> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const SyncRuntimeStateRow({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncRuntimeStatesCompanion toCompanion(bool nullToAbsent) {
    return SyncRuntimeStatesCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncRuntimeStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncRuntimeStateRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncRuntimeStateRow copyWith({
    String? key,
    String? value,
    DateTime? updatedAt,
  }) => SyncRuntimeStateRow(
    key: key ?? this.key,
    value: value ?? this.value,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SyncRuntimeStateRow copyWithCompanion(SyncRuntimeStatesCompanion data) {
    return SyncRuntimeStateRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncRuntimeStateRow(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncRuntimeStateRow &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class SyncRuntimeStatesCompanion extends UpdateCompanion<SyncRuntimeStateRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SyncRuntimeStatesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncRuntimeStatesCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<SyncRuntimeStateRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncRuntimeStatesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SyncRuntimeStatesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncRuntimeStatesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $RecurrenceSeriesEntriesTable recurrenceSeriesEntries =
      $RecurrenceSeriesEntriesTable(this);
  late final $TodosTable todos = $TodosTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $TodoTagsTable todoTags = $TodoTagsTable(this);
  late final $RecurrenceExceptionsTable recurrenceExceptions =
      $RecurrenceExceptionsTable(this);
  late final $HolidayYearsTable holidayYears = $HolidayYearsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $SyncGroupsTable syncGroups = $SyncGroupsTable(this);
  late final $SyncDevicesTable syncDevices = $SyncDevicesTable(this);
  late final $SyncPairingInvitesTable syncPairingInvites =
      $SyncPairingInvitesTable(this);
  late final $SyncChangesTable syncChanges = $SyncChangesTable(this);
  late final $SyncEntityVersionsTable syncEntityVersions =
      $SyncEntityVersionsTable(this);
  late final $SyncRelationDotsTable syncRelationDots = $SyncRelationDotsTable(
    this,
  );
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  late final $SyncConflictsTable syncConflicts = $SyncConflictsTable(this);
  late final $SyncRuntimeStatesTable syncRuntimeStates =
      $SyncRuntimeStatesTable(this);
  late final Index todosDateActive = Index(
    'todos_date_active',
    'CREATE INDEX todos_date_active ON todos (local_date, deleted_at)',
  );
  late final Index todosDeadline = Index(
    'todos_deadline',
    'CREATE INDEX todos_deadline ON todos (deadline_at)',
  );
  late final Index todosUpdated = Index(
    'todos_updated',
    'CREATE INDEX todos_updated ON todos (updated_at)',
  );
  late final Index todosActiveDateCompletion = Index(
    'todos_active_date_completion',
    'CREATE INDEX todos_active_date_completion ON todos (deleted_at, local_date, is_completed)',
  );
  late final Index categoriesActiveOrder = Index(
    'categories_active_order',
    'CREATE INDEX categories_active_order ON categories (deleted_at, sort_order)',
  );
  late final Index tagsActiveOrder = Index(
    'tags_active_order',
    'CREATE INDEX tags_active_order ON tags (deleted_at, sort_order)',
  );
  late final Index todoTagsTag = Index(
    'todo_tags_tag',
    'CREATE INDEX todo_tags_tag ON todo_tags (tag_id)',
  );
  late final Index recurrenceExceptionsSeriesDate = Index(
    'recurrence_exceptions_series_date',
    'CREATE UNIQUE INDEX recurrence_exceptions_series_date ON recurrence_exceptions (series_id, occurrence_date)',
  );
  late final Index syncDevicesGroupRevoked = Index(
    'sync_devices_group_revoked',
    'CREATE INDEX sync_devices_group_revoked ON sync_devices (sync_group_id, revoked_at)',
  );
  late final Index syncChangesSourceSequence = Index(
    'sync_changes_source_sequence',
    'CREATE UNIQUE INDEX sync_changes_source_sequence ON sync_changes (sync_group_id, source_device_id, sequence)',
  );
  late final Index syncChangesEntity = Index(
    'sync_changes_entity',
    'CREATE INDEX sync_changes_entity ON sync_changes (sync_group_id, entity_type, entity_id)',
  );
  late final Index syncChangesTransaction = Index(
    'sync_changes_transaction',
    'CREATE INDEX sync_changes_transaction ON sync_changes (transaction_id)',
  );
  late final Index syncRelationDotsMembership = Index(
    'sync_relation_dots_membership',
    'CREATE INDEX sync_relation_dots_membership ON sync_relation_dots (sync_group_id, todo_id, tag_id, removed_by_operation_id)',
  );
  late final Index syncConflictsUnresolved = Index(
    'sync_conflicts_unresolved',
    'CREATE INDEX sync_conflicts_unresolved ON sync_conflicts (sync_group_id, resolved_at, created_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    recurrenceSeriesEntries,
    todos,
    tags,
    todoTags,
    recurrenceExceptions,
    holidayYears,
    settings,
    syncGroups,
    syncDevices,
    syncPairingInvites,
    syncChanges,
    syncEntityVersions,
    syncRelationDots,
    syncCursors,
    syncConflicts,
    syncRuntimeStates,
    todosDateActive,
    todosDeadline,
    todosUpdated,
    todosActiveDateCompletion,
    categoriesActiveOrder,
    tagsActiveOrder,
    todoTagsTag,
    recurrenceExceptionsSeriesDate,
    syncDevicesGroupRevoked,
    syncChangesSourceSequence,
    syncChangesEntity,
    syncChangesTransaction,
    syncRelationDotsMembership,
    syncConflictsUnresolved,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('todos', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'recurrence_series',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('todos', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'todos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('todo_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('todo_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'recurrence_series',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('recurrence_exceptions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sync_groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sync_devices', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sync_groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sync_pairing_invites', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sync_groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sync_changes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sync_groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sync_entity_versions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sync_groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sync_relation_dots', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sync_groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sync_cursors', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sync_groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sync_conflicts', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  required String name,
  required int colorValue,
  Value<double> sortOrder,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> revision,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> colorValue,
  Value<double> sortOrder,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> revision,
  Value<int> rowid,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TodosTable, List<TodoRow>> _todosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.todos,
    aliasName: 'categories__id__todos__category_id',
  );

  $$TodosTableProcessedTableManager get todosRefs {
    final manager = $$TodosTableTableManager(
      $_db,
      $_db.todos,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_todosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> todosRefs(
    Expression<bool> Function($$TodosTableFilterComposer f) f,
  ) {
    final $$TodosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.todos,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodosTableFilterComposer(
            $db: $db,
            $table: $db.todos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  Expression<T> todosRefs<T extends Object>(
    Expression<T> Function($$TodosTableAnnotationComposer a) f,
  ) {
    final $$TodosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.todos,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodosTableAnnotationComposer(
            $db: $db,
            $table: $db.todos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (CategoryRow, $$CategoriesTableReferences),
          CategoryRow,
          PrefetchHooks Function({bool todosRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<double> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                colorValue: colorValue,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int colorValue,
                Value<double> sortOrder = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                colorValue: colorValue,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, CategoryRow>(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({todosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (todosRefs) db.todos],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (todosRefs)
                    await $_getPrefetchedData<
                      CategoryRow,
                      $CategoriesTable,
                      TodoRow
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._todosRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(db, table, p0).todosRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (CategoryRow, $$CategoriesTableReferences),
      CategoryRow,
      PrefetchHooks Function({bool todosRefs})
    >;
typedef $$RecurrenceSeriesEntriesTableCreateCompanionBuilder =
    RecurrenceSeriesEntriesCompanion Function({
      required String id,
      required String startDate,
      required String ruleJson,
      Value<String?> timeZoneId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> revision,
      Value<int> rowid,
    });
typedef $$RecurrenceSeriesEntriesTableUpdateCompanionBuilder =
    RecurrenceSeriesEntriesCompanion Function({
      Value<String> id,
      Value<String> startDate,
      Value<String> ruleJson,
      Value<String?> timeZoneId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> revision,
      Value<int> rowid,
    });

final class $$RecurrenceSeriesEntriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RecurrenceSeriesEntriesTable,
          RecurrenceSeriesRow
        > {
  $$RecurrenceSeriesEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TodosTable, List<TodoRow>> _todosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.todos,
    aliasName: 'recurrence_series__id__todos__recurrence_series_id',
  );

  $$TodosTableProcessedTableManager get todosRefs {
    final manager = $$TodosTableTableManager($_db, $_db.todos).filter(
      (f) => f.recurrenceSeriesId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_todosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $RecurrenceExceptionsTable,
    List<RecurrenceExceptionRow>
  >
  _recurrenceExceptionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recurrenceExceptions,
        aliasName: 'recurrence_series__id__recurrence_exceptions__series_id',
      );

  $$RecurrenceExceptionsTableProcessedTableManager
  get recurrenceExceptionsRefs {
    final manager = $$RecurrenceExceptionsTableTableManager(
      $_db,
      $_db.recurrenceExceptions,
    ).filter((f) => f.seriesId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recurrenceExceptionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RecurrenceSeriesEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurrenceSeriesEntriesTable> {
  $$RecurrenceSeriesEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleJson => $composableBuilder(
    column: $table.ruleJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeZoneId => $composableBuilder(
    column: $table.timeZoneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> todosRefs(
    Expression<bool> Function($$TodosTableFilterComposer f) f,
  ) {
    final $$TodosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.todos,
      getReferencedColumn: (t) => t.recurrenceSeriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodosTableFilterComposer(
            $db: $db,
            $table: $db.todos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recurrenceExceptionsRefs(
    Expression<bool> Function($$RecurrenceExceptionsTableFilterComposer f) f,
  ) {
    final $$RecurrenceExceptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recurrenceExceptions,
      getReferencedColumn: (t) => t.seriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurrenceExceptionsTableFilterComposer(
            $db: $db,
            $table: $db.recurrenceExceptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecurrenceSeriesEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurrenceSeriesEntriesTable> {
  $$RecurrenceSeriesEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleJson => $composableBuilder(
    column: $table.ruleJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeZoneId => $composableBuilder(
    column: $table.timeZoneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecurrenceSeriesEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurrenceSeriesEntriesTable> {
  $$RecurrenceSeriesEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get ruleJson =>
      $composableBuilder(column: $table.ruleJson, builder: (column) => column);

  GeneratedColumn<String> get timeZoneId => $composableBuilder(
    column: $table.timeZoneId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  Expression<T> todosRefs<T extends Object>(
    Expression<T> Function($$TodosTableAnnotationComposer a) f,
  ) {
    final $$TodosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.todos,
      getReferencedColumn: (t) => t.recurrenceSeriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodosTableAnnotationComposer(
            $db: $db,
            $table: $db.todos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recurrenceExceptionsRefs<T extends Object>(
    Expression<T> Function($$RecurrenceExceptionsTableAnnotationComposer a) f,
  ) {
    final $$RecurrenceExceptionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurrenceExceptions,
          getReferencedColumn: (t) => t.seriesId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurrenceExceptionsTableAnnotationComposer(
                $db: $db,
                $table: $db.recurrenceExceptions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RecurrenceSeriesEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurrenceSeriesEntriesTable,
          RecurrenceSeriesRow,
          $$RecurrenceSeriesEntriesTableFilterComposer,
          $$RecurrenceSeriesEntriesTableOrderingComposer,
          $$RecurrenceSeriesEntriesTableAnnotationComposer,
          $$RecurrenceSeriesEntriesTableCreateCompanionBuilder,
          $$RecurrenceSeriesEntriesTableUpdateCompanionBuilder,
          (RecurrenceSeriesRow, $$RecurrenceSeriesEntriesTableReferences),
          RecurrenceSeriesRow,
          PrefetchHooks Function({
            bool todosRefs,
            bool recurrenceExceptionsRefs,
          })
        > {
  $$RecurrenceSeriesEntriesTableTableManager(
    _$AppDatabase db,
    $RecurrenceSeriesEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurrenceSeriesEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RecurrenceSeriesEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecurrenceSeriesEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> startDate = const Value.absent(),
                Value<String> ruleJson = const Value.absent(),
                Value<String?> timeZoneId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurrenceSeriesEntriesCompanion(
                id: id,
                startDate: startDate,
                ruleJson: ruleJson,
                timeZoneId: timeZoneId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String startDate,
                required String ruleJson,
                Value<String?> timeZoneId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurrenceSeriesEntriesCompanion.insert(
                id: id,
                startDate: startDate,
                ruleJson: ruleJson,
                timeZoneId: timeZoneId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $RecurrenceSeriesEntriesTable,
                    RecurrenceSeriesRow
                  >(table),
                  $$RecurrenceSeriesEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({todosRefs = false, recurrenceExceptionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (todosRefs) db.todos,
                    if (recurrenceExceptionsRefs) db.recurrenceExceptions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (todosRefs)
                        await $_getPrefetchedData<
                          RecurrenceSeriesRow,
                          $RecurrenceSeriesEntriesTable,
                          TodoRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$RecurrenceSeriesEntriesTableReferences
                                  ._todosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecurrenceSeriesEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).todosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recurrenceSeriesId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recurrenceExceptionsRefs)
                        await $_getPrefetchedData<
                          RecurrenceSeriesRow,
                          $RecurrenceSeriesEntriesTable,
                          RecurrenceExceptionRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$RecurrenceSeriesEntriesTableReferences
                                  ._recurrenceExceptionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecurrenceSeriesEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).recurrenceExceptionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.seriesId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RecurrenceSeriesEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurrenceSeriesEntriesTable,
      RecurrenceSeriesRow,
      $$RecurrenceSeriesEntriesTableFilterComposer,
      $$RecurrenceSeriesEntriesTableOrderingComposer,
      $$RecurrenceSeriesEntriesTableAnnotationComposer,
      $$RecurrenceSeriesEntriesTableCreateCompanionBuilder,
      $$RecurrenceSeriesEntriesTableUpdateCompanionBuilder,
      (RecurrenceSeriesRow, $$RecurrenceSeriesEntriesTableReferences),
      RecurrenceSeriesRow,
      PrefetchHooks Function({bool todosRefs, bool recurrenceExceptionsRefs})
    >;
typedef $$TodosTableCreateCompanionBuilder = TodosCompanion Function({
  required String id,
  required String title,
  required String localDate,
  Value<bool> isCompleted,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> plannedAt,
  Value<int> priority,
  Value<String?> categoryId,
  Value<String?> notes,
  Value<DateTime?> deadlineAt,
  Value<String?> timeZoneId,
  Value<DateTime?> completedAt,
  Value<DateTime?> deletedAt,
  Value<double> manualOrder,
  Value<int> revision,
  Value<String?> recurrenceSeriesId,
  Value<String?> occurrenceDate,
  Value<int> rowid,
});
typedef $$TodosTableUpdateCompanionBuilder = TodosCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> localDate,
  Value<bool> isCompleted,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> plannedAt,
  Value<int> priority,
  Value<String?> categoryId,
  Value<String?> notes,
  Value<DateTime?> deadlineAt,
  Value<String?> timeZoneId,
  Value<DateTime?> completedAt,
  Value<DateTime?> deletedAt,
  Value<double> manualOrder,
  Value<int> revision,
  Value<String?> recurrenceSeriesId,
  Value<String?> occurrenceDate,
  Value<int> rowid,
});

final class $$TodosTableReferences
    extends BaseReferences<_$AppDatabase, $TodosTable, TodoRow> {
  $$TodosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('todos__category_id__categories__id');

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<String>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RecurrenceSeriesEntriesTable _recurrenceSeriesIdTable(
    _$AppDatabase db,
  ) => db.recurrenceSeriesEntries.createAlias(
    'todos__recurrence_series_id__recurrence_series__id',
  );

  $$RecurrenceSeriesEntriesTableProcessedTableManager? get recurrenceSeriesId {
    final $_column = $_itemColumn<String>('recurrence_series_id');
    if ($_column == null) return null;
    final manager = $$RecurrenceSeriesEntriesTableTableManager(
      $_db,
      $_db.recurrenceSeriesEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recurrenceSeriesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TodoTagsTable, List<TodoTagRow>>
  _todoTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.todoTags,
    aliasName: 'todos__id__todo_tags__todo_id',
  );

  $$TodoTagsTableProcessedTableManager get todoTagsRefs {
    final manager = $$TodoTagsTableTableManager(
      $_db,
      $_db.todoTags,
    ).filter((f) => f.todoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_todoTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TodosTableFilterComposer extends Composer<_$AppDatabase, $TodosTable> {
  $$TodosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get plannedAt => $composableBuilder(
    column: $table.plannedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deadlineAt => $composableBuilder(
    column: $table.deadlineAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeZoneId => $composableBuilder(
    column: $table.timeZoneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get manualOrder => $composableBuilder(
    column: $table.manualOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occurrenceDate => $composableBuilder(
    column: $table.occurrenceDate,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecurrenceSeriesEntriesTableFilterComposer get recurrenceSeriesId {
    final $$RecurrenceSeriesEntriesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.recurrenceSeriesId,
          referencedTable: $db.recurrenceSeriesEntries,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurrenceSeriesEntriesTableFilterComposer(
                $db: $db,
                $table: $db.recurrenceSeriesEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<bool> todoTagsRefs(
    Expression<bool> Function($$TodoTagsTableFilterComposer f) f,
  ) {
    final $$TodoTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.todoTags,
      getReferencedColumn: (t) => t.todoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodoTagsTableFilterComposer(
            $db: $db,
            $table: $db.todoTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TodosTableOrderingComposer
    extends Composer<_$AppDatabase, $TodosTable> {
  $$TodosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get plannedAt => $composableBuilder(
    column: $table.plannedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deadlineAt => $composableBuilder(
    column: $table.deadlineAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeZoneId => $composableBuilder(
    column: $table.timeZoneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get manualOrder => $composableBuilder(
    column: $table.manualOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occurrenceDate => $composableBuilder(
    column: $table.occurrenceDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecurrenceSeriesEntriesTableOrderingComposer get recurrenceSeriesId {
    final $$RecurrenceSeriesEntriesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.recurrenceSeriesId,
          referencedTable: $db.recurrenceSeriesEntries,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurrenceSeriesEntriesTableOrderingComposer(
                $db: $db,
                $table: $db.recurrenceSeriesEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$TodosTableAnnotationComposer
    extends Composer<_$AppDatabase, $TodosTable> {
  $$TodosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get plannedAt =>
      $composableBuilder(column: $table.plannedAt, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get deadlineAt => $composableBuilder(
    column: $table.deadlineAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timeZoneId => $composableBuilder(
    column: $table.timeZoneId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<double> get manualOrder => $composableBuilder(
    column: $table.manualOrder,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get occurrenceDate => $composableBuilder(
    column: $table.occurrenceDate,
    builder: (column) => column,
  );

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecurrenceSeriesEntriesTableAnnotationComposer get recurrenceSeriesId {
    final $$RecurrenceSeriesEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.recurrenceSeriesId,
          referencedTable: $db.recurrenceSeriesEntries,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurrenceSeriesEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.recurrenceSeriesEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> todoTagsRefs<T extends Object>(
    Expression<T> Function($$TodoTagsTableAnnotationComposer a) f,
  ) {
    final $$TodoTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.todoTags,
      getReferencedColumn: (t) => t.todoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodoTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.todoTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TodosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TodosTable,
          TodoRow,
          $$TodosTableFilterComposer,
          $$TodosTableOrderingComposer,
          $$TodosTableAnnotationComposer,
          $$TodosTableCreateCompanionBuilder,
          $$TodosTableUpdateCompanionBuilder,
          (TodoRow, $$TodosTableReferences),
          TodoRow,
          PrefetchHooks Function({
            bool categoryId,
            bool recurrenceSeriesId,
            bool todoTagsRefs,
          })
        > {
  $$TodosTableTableManager(_$AppDatabase db, $TodosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TodosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TodosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TodosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> plannedAt = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> deadlineAt = const Value.absent(),
                Value<String?> timeZoneId = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<double> manualOrder = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String?> recurrenceSeriesId = const Value.absent(),
                Value<String?> occurrenceDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TodosCompanion(
                id: id,
                title: title,
                localDate: localDate,
                isCompleted: isCompleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                plannedAt: plannedAt,
                priority: priority,
                categoryId: categoryId,
                notes: notes,
                deadlineAt: deadlineAt,
                timeZoneId: timeZoneId,
                completedAt: completedAt,
                deletedAt: deletedAt,
                manualOrder: manualOrder,
                revision: revision,
                recurrenceSeriesId: recurrenceSeriesId,
                occurrenceDate: occurrenceDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String localDate,
                Value<bool> isCompleted = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> plannedAt = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> deadlineAt = const Value.absent(),
                Value<String?> timeZoneId = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<double> manualOrder = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String?> recurrenceSeriesId = const Value.absent(),
                Value<String?> occurrenceDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TodosCompanion.insert(
                id: id,
                title: title,
                localDate: localDate,
                isCompleted: isCompleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                plannedAt: plannedAt,
                priority: priority,
                categoryId: categoryId,
                notes: notes,
                deadlineAt: deadlineAt,
                timeZoneId: timeZoneId,
                completedAt: completedAt,
                deletedAt: deletedAt,
                manualOrder: manualOrder,
                revision: revision,
                recurrenceSeriesId: recurrenceSeriesId,
                occurrenceDate: occurrenceDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TodosTable, TodoRow>(table),
                  $$TodosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryId = false,
                recurrenceSeriesId = false,
                todoTagsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (todoTagsRefs) db.todoTags],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.categoryId,
                            referencedTable: $$TodosTableReferences
                                ._categoryIdTable(db),
                            referencedColumn: $$TodosTableReferences
                                ._categoryIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (recurrenceSeriesId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.recurrenceSeriesId,
                            referencedTable: $$TodosTableReferences
                                ._recurrenceSeriesIdTable(db),
                            referencedColumn: $$TodosTableReferences
                                ._recurrenceSeriesIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (todoTagsRefs)
                        await $_getPrefetchedData<
                          TodoRow,
                          $TodosTable,
                          TodoTagRow
                        >(
                          currentTable: table,
                          referencedTable: $$TodosTableReferences
                              ._todoTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TodosTableReferences(
                                db,
                                table,
                                p0,
                              ).todoTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.todoId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TodosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TodosTable,
      TodoRow,
      $$TodosTableFilterComposer,
      $$TodosTableOrderingComposer,
      $$TodosTableAnnotationComposer,
      $$TodosTableCreateCompanionBuilder,
      $$TodosTableUpdateCompanionBuilder,
      (TodoRow, $$TodosTableReferences),
      TodoRow,
      PrefetchHooks Function({
        bool categoryId,
        bool recurrenceSeriesId,
        bool todoTagsRefs,
      })
    >;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  required String id,
  required String name,
  required int colorValue,
  Value<double> sortOrder,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> revision,
  Value<int> rowid,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> colorValue,
  Value<double> sortOrder,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> revision,
  Value<int> rowid,
});

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, TagRow> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TodoTagsTable, List<TodoTagRow>>
  _todoTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.todoTags,
    aliasName: 'tags__id__todo_tags__tag_id',
  );

  $$TodoTagsTableProcessedTableManager get todoTagsRefs {
    final manager = $$TodoTagsTableTableManager(
      $_db,
      $_db.todoTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_todoTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> todoTagsRefs(
    Expression<bool> Function($$TodoTagsTableFilterComposer f) f,
  ) {
    final $$TodoTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.todoTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodoTagsTableFilterComposer(
            $db: $db,
            $table: $db.todoTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  Expression<T> todoTagsRefs<T extends Object>(
    Expression<T> Function($$TodoTagsTableAnnotationComposer a) f,
  ) {
    final $$TodoTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.todoTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodoTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.todoTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          TagRow,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (TagRow, $$TagsTableReferences),
          TagRow,
          PrefetchHooks Function({bool todoTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<double> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                name: name,
                colorValue: colorValue,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int colorValue,
                Value<double> sortOrder = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                name: name,
                colorValue: colorValue,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TagsTable, TagRow>(table),
                  $$TagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({todoTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (todoTagsRefs) db.todoTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (todoTagsRefs)
                    await $_getPrefetchedData<TagRow, $TagsTable, TodoTagRow>(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences._todoTagsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).todoTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      TagRow,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (TagRow, $$TagsTableReferences),
      TagRow,
      PrefetchHooks Function({bool todoTagsRefs})
    >;
typedef $$TodoTagsTableCreateCompanionBuilder = TodoTagsCompanion Function({
  required String todoId,
  required String tagId,
  Value<int> rowid,
});
typedef $$TodoTagsTableUpdateCompanionBuilder = TodoTagsCompanion Function({
  Value<String> todoId,
  Value<String> tagId,
  Value<int> rowid,
});

final class $$TodoTagsTableReferences
    extends BaseReferences<_$AppDatabase, $TodoTagsTable, TodoTagRow> {
  $$TodoTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TodosTable _todoIdTable(_$AppDatabase db) =>
      db.todos.createAlias('todo_tags__todo_id__todos__id');

  $$TodosTableProcessedTableManager get todoId {
    final $_column = $_itemColumn<String>('todo_id')!;

    final manager = $$TodosTableTableManager(
      $_db,
      $_db.todos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_todoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('todo_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TodoTagsTableFilterComposer
    extends Composer<_$AppDatabase, $TodoTagsTable> {
  $$TodoTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$TodosTableFilterComposer get todoId {
    final $$TodosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.todoId,
      referencedTable: $db.todos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodosTableFilterComposer(
            $db: $db,
            $table: $db.todos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TodoTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $TodoTagsTable> {
  $$TodoTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$TodosTableOrderingComposer get todoId {
    final $$TodosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.todoId,
      referencedTable: $db.todos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodosTableOrderingComposer(
            $db: $db,
            $table: $db.todos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TodoTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TodoTagsTable> {
  $$TodoTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$TodosTableAnnotationComposer get todoId {
    final $$TodosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.todoId,
      referencedTable: $db.todos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodosTableAnnotationComposer(
            $db: $db,
            $table: $db.todos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TodoTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TodoTagsTable,
          TodoTagRow,
          $$TodoTagsTableFilterComposer,
          $$TodoTagsTableOrderingComposer,
          $$TodoTagsTableAnnotationComposer,
          $$TodoTagsTableCreateCompanionBuilder,
          $$TodoTagsTableUpdateCompanionBuilder,
          (TodoTagRow, $$TodoTagsTableReferences),
          TodoTagRow,
          PrefetchHooks Function({bool todoId, bool tagId})
        > {
  $$TodoTagsTableTableManager(_$AppDatabase db, $TodoTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TodoTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TodoTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TodoTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> todoId = const Value.absent(),
            Value<String> tagId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => TodoTagsCompanion(todoId: todoId, tagId: tagId, rowid: rowid),
          createCompanionCallback:
              ({
                required String todoId,
                required String tagId,
                Value<int> rowid = const Value.absent(),
              }) => TodoTagsCompanion.insert(
                todoId: todoId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TodoTagsTable, TodoTagRow>(table),
                  $$TodoTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({todoId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (todoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.todoId,
                        referencedTable: $$TodoTagsTableReferences._todoIdTable(
                          db,
                        ),
                        referencedColumn: $$TodoTagsTableReferences
                            ._todoIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (tagId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tagId,
                        referencedTable: $$TodoTagsTableReferences._tagIdTable(
                          db,
                        ),
                        referencedColumn: $$TodoTagsTableReferences
                            ._tagIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TodoTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TodoTagsTable,
      TodoTagRow,
      $$TodoTagsTableFilterComposer,
      $$TodoTagsTableOrderingComposer,
      $$TodoTagsTableAnnotationComposer,
      $$TodoTagsTableCreateCompanionBuilder,
      $$TodoTagsTableUpdateCompanionBuilder,
      (TodoTagRow, $$TodoTagsTableReferences),
      TodoTagRow,
      PrefetchHooks Function({bool todoId, bool tagId})
    >;
typedef $$RecurrenceExceptionsTableCreateCompanionBuilder =
    RecurrenceExceptionsCompanion Function({
      required String id,
      required String seriesId,
      required String occurrenceDate,
      Value<String?> overrideJson,
      Value<bool> isSkipped,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> revision,
      Value<int> rowid,
    });
typedef $$RecurrenceExceptionsTableUpdateCompanionBuilder =
    RecurrenceExceptionsCompanion Function({
      Value<String> id,
      Value<String> seriesId,
      Value<String> occurrenceDate,
      Value<String?> overrideJson,
      Value<bool> isSkipped,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> revision,
      Value<int> rowid,
    });

final class $$RecurrenceExceptionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RecurrenceExceptionsTable,
          RecurrenceExceptionRow
        > {
  $$RecurrenceExceptionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RecurrenceSeriesEntriesTable _seriesIdTable(_$AppDatabase db) => db
      .recurrenceSeriesEntries
      .createAlias('recurrence_exceptions__series_id__recurrence_series__id');

  $$RecurrenceSeriesEntriesTableProcessedTableManager get seriesId {
    final $_column = $_itemColumn<String>('series_id')!;

    final manager = $$RecurrenceSeriesEntriesTableTableManager(
      $_db,
      $_db.recurrenceSeriesEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seriesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecurrenceExceptionsTableFilterComposer
    extends Composer<_$AppDatabase, $RecurrenceExceptionsTable> {
  $$RecurrenceExceptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occurrenceDate => $composableBuilder(
    column: $table.occurrenceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overrideJson => $composableBuilder(
    column: $table.overrideJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSkipped => $composableBuilder(
    column: $table.isSkipped,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  $$RecurrenceSeriesEntriesTableFilterComposer get seriesId {
    final $$RecurrenceSeriesEntriesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.seriesId,
          referencedTable: $db.recurrenceSeriesEntries,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurrenceSeriesEntriesTableFilterComposer(
                $db: $db,
                $table: $db.recurrenceSeriesEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$RecurrenceExceptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurrenceExceptionsTable> {
  $$RecurrenceExceptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occurrenceDate => $composableBuilder(
    column: $table.occurrenceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overrideJson => $composableBuilder(
    column: $table.overrideJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSkipped => $composableBuilder(
    column: $table.isSkipped,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  $$RecurrenceSeriesEntriesTableOrderingComposer get seriesId {
    final $$RecurrenceSeriesEntriesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.seriesId,
          referencedTable: $db.recurrenceSeriesEntries,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurrenceSeriesEntriesTableOrderingComposer(
                $db: $db,
                $table: $db.recurrenceSeriesEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$RecurrenceExceptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurrenceExceptionsTable> {
  $$RecurrenceExceptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get occurrenceDate => $composableBuilder(
    column: $table.occurrenceDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get overrideJson => $composableBuilder(
    column: $table.overrideJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSkipped =>
      $composableBuilder(column: $table.isSkipped, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  $$RecurrenceSeriesEntriesTableAnnotationComposer get seriesId {
    final $$RecurrenceSeriesEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.seriesId,
          referencedTable: $db.recurrenceSeriesEntries,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurrenceSeriesEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.recurrenceSeriesEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$RecurrenceExceptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurrenceExceptionsTable,
          RecurrenceExceptionRow,
          $$RecurrenceExceptionsTableFilterComposer,
          $$RecurrenceExceptionsTableOrderingComposer,
          $$RecurrenceExceptionsTableAnnotationComposer,
          $$RecurrenceExceptionsTableCreateCompanionBuilder,
          $$RecurrenceExceptionsTableUpdateCompanionBuilder,
          (RecurrenceExceptionRow, $$RecurrenceExceptionsTableReferences),
          RecurrenceExceptionRow,
          PrefetchHooks Function({bool seriesId})
        > {
  $$RecurrenceExceptionsTableTableManager(
    _$AppDatabase db,
    $RecurrenceExceptionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurrenceExceptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurrenceExceptionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecurrenceExceptionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> seriesId = const Value.absent(),
                Value<String> occurrenceDate = const Value.absent(),
                Value<String?> overrideJson = const Value.absent(),
                Value<bool> isSkipped = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurrenceExceptionsCompanion(
                id: id,
                seriesId: seriesId,
                occurrenceDate: occurrenceDate,
                overrideJson: overrideJson,
                isSkipped: isSkipped,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String seriesId,
                required String occurrenceDate,
                Value<String?> overrideJson = const Value.absent(),
                Value<bool> isSkipped = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurrenceExceptionsCompanion.insert(
                id: id,
                seriesId: seriesId,
                occurrenceDate: occurrenceDate,
                overrideJson: overrideJson,
                isSkipped: isSkipped,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $RecurrenceExceptionsTable,
                    RecurrenceExceptionRow
                  >(table),
                  $$RecurrenceExceptionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({seriesId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (seriesId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.seriesId,
                        referencedTable: $$RecurrenceExceptionsTableReferences
                            ._seriesIdTable(db),
                        referencedColumn: $$RecurrenceExceptionsTableReferences
                            ._seriesIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RecurrenceExceptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurrenceExceptionsTable,
      RecurrenceExceptionRow,
      $$RecurrenceExceptionsTableFilterComposer,
      $$RecurrenceExceptionsTableOrderingComposer,
      $$RecurrenceExceptionsTableAnnotationComposer,
      $$RecurrenceExceptionsTableCreateCompanionBuilder,
      $$RecurrenceExceptionsTableUpdateCompanionBuilder,
      (RecurrenceExceptionRow, $$RecurrenceExceptionsTableReferences),
      RecurrenceExceptionRow,
      PrefetchHooks Function({bool seriesId})
    >;
typedef $$HolidayYearsTableCreateCompanionBuilder =
    HolidayYearsCompanion Function({
      Value<int> year,
      required String sourceUrl,
      required String dataVersion,
      required String checksum,
      required String payloadJson,
      required DateTime updatedAt,
    });
typedef $$HolidayYearsTableUpdateCompanionBuilder =
    HolidayYearsCompanion Function({
      Value<int> year,
      Value<String> sourceUrl,
      Value<String> dataVersion,
      Value<String> checksum,
      Value<String> payloadJson,
      Value<DateTime> updatedAt,
    });

class $$HolidayYearsTableFilterComposer
    extends Composer<_$AppDatabase, $HolidayYearsTable> {
  $$HolidayYearsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataVersion => $composableBuilder(
    column: $table.dataVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HolidayYearsTableOrderingComposer
    extends Composer<_$AppDatabase, $HolidayYearsTable> {
  $$HolidayYearsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataVersion => $composableBuilder(
    column: $table.dataVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HolidayYearsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HolidayYearsTable> {
  $$HolidayYearsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get dataVersion => $composableBuilder(
    column: $table.dataVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$HolidayYearsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HolidayYearsTable,
          HolidayYearRow,
          $$HolidayYearsTableFilterComposer,
          $$HolidayYearsTableOrderingComposer,
          $$HolidayYearsTableAnnotationComposer,
          $$HolidayYearsTableCreateCompanionBuilder,
          $$HolidayYearsTableUpdateCompanionBuilder,
          (
            HolidayYearRow,
            BaseReferences<_$AppDatabase, $HolidayYearsTable, HolidayYearRow>,
          ),
          HolidayYearRow,
          PrefetchHooks Function()
        > {
  $$HolidayYearsTableTableManager(_$AppDatabase db, $HolidayYearsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HolidayYearsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HolidayYearsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HolidayYearsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> year = const Value.absent(),
                Value<String> sourceUrl = const Value.absent(),
                Value<String> dataVersion = const Value.absent(),
                Value<String> checksum = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => HolidayYearsCompanion(
                year: year,
                sourceUrl: sourceUrl,
                dataVersion: dataVersion,
                checksum: checksum,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> year = const Value.absent(),
                required String sourceUrl,
                required String dataVersion,
                required String checksum,
                required String payloadJson,
                required DateTime updatedAt,
              }) => HolidayYearsCompanion.insert(
                year: year,
                sourceUrl: sourceUrl,
                dataVersion: dataVersion,
                checksum: checksum,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HolidayYearsTable, HolidayYearRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $HolidayYearsTable,
                    HolidayYearRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HolidayYearsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HolidayYearsTable,
      HolidayYearRow,
      $$HolidayYearsTableFilterComposer,
      $$HolidayYearsTableOrderingComposer,
      $$HolidayYearsTableAnnotationComposer,
      $$HolidayYearsTableCreateCompanionBuilder,
      $$HolidayYearsTableUpdateCompanionBuilder,
      (
        HolidayYearRow,
        BaseReferences<_$AppDatabase, $HolidayYearsTable, HolidayYearRow>,
      ),
      HolidayYearRow,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  required DateTime updatedAt,
  Value<int> revision,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<DateTime> updatedAt,
  Value<int> revision,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, SettingRow>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $$SyncGroupsTableCreateCompanionBuilder = SyncGroupsCompanion Function({
  required String id,
  required String role,
  required String hostDeviceId,
  required int protocolVersion,
  Value<bool> isActive,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$SyncGroupsTableUpdateCompanionBuilder = SyncGroupsCompanion Function({
  Value<String> id,
  Value<String> role,
  Value<String> hostDeviceId,
  Value<int> protocolVersion,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$SyncGroupsTableReferences
    extends BaseReferences<_$AppDatabase, $SyncGroupsTable, SyncGroupRow> {
  $$SyncGroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SyncDevicesTable, List<SyncDeviceRow>>
  _syncDevicesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.syncDevices,
    aliasName: 'sync_groups__id__sync_devices__sync_group_id',
  );

  $$SyncDevicesTableProcessedTableManager get syncDevicesRefs {
    final manager = $$SyncDevicesTableTableManager(
      $_db,
      $_db.syncDevices,
    ).filter((f) => f.syncGroupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_syncDevicesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $SyncPairingInvitesTable,
    List<SyncPairingInviteRow>
  >
  _syncPairingInvitesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.syncPairingInvites,
        aliasName: 'sync_groups__id__sync_pairing_invites__sync_group_id',
      );

  $$SyncPairingInvitesTableProcessedTableManager get syncPairingInvitesRefs {
    final manager = $$SyncPairingInvitesTableTableManager(
      $_db,
      $_db.syncPairingInvites,
    ).filter((f) => f.syncGroupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _syncPairingInvitesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SyncChangesTable, List<SyncChangeRow>>
  _syncChangesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.syncChanges,
    aliasName: 'sync_groups__id__sync_changes__sync_group_id',
  );

  $$SyncChangesTableProcessedTableManager get syncChangesRefs {
    final manager = $$SyncChangesTableTableManager(
      $_db,
      $_db.syncChanges,
    ).filter((f) => f.syncGroupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_syncChangesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $SyncEntityVersionsTable,
    List<SyncEntityVersionRow>
  >
  _syncEntityVersionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.syncEntityVersions,
        aliasName: 'sync_groups__id__sync_entity_versions__sync_group_id',
      );

  $$SyncEntityVersionsTableProcessedTableManager get syncEntityVersionsRefs {
    final manager = $$SyncEntityVersionsTableTableManager(
      $_db,
      $_db.syncEntityVersions,
    ).filter((f) => f.syncGroupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _syncEntityVersionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SyncRelationDotsTable, List<SyncRelationDotRow>>
  _syncRelationDotsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.syncRelationDots,
    aliasName: 'sync_groups__id__sync_relation_dots__sync_group_id',
  );

  $$SyncRelationDotsTableProcessedTableManager get syncRelationDotsRefs {
    final manager = $$SyncRelationDotsTableTableManager(
      $_db,
      $_db.syncRelationDots,
    ).filter((f) => f.syncGroupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _syncRelationDotsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SyncCursorsTable, List<SyncCursorRow>>
  _syncCursorsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.syncCursors,
    aliasName: 'sync_groups__id__sync_cursors__sync_group_id',
  );

  $$SyncCursorsTableProcessedTableManager get syncCursorsRefs {
    final manager = $$SyncCursorsTableTableManager(
      $_db,
      $_db.syncCursors,
    ).filter((f) => f.syncGroupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_syncCursorsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SyncConflictsTable, List<SyncConflictRow>>
  _syncConflictsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.syncConflicts,
    aliasName: 'sync_groups__id__sync_conflicts__sync_group_id',
  );

  $$SyncConflictsTableProcessedTableManager get syncConflictsRefs {
    final manager = $$SyncConflictsTableTableManager(
      $_db,
      $_db.syncConflicts,
    ).filter((f) => f.syncGroupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_syncConflictsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SyncGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncGroupsTable> {
  $$SyncGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hostDeviceId => $composableBuilder(
    column: $table.hostDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get protocolVersion => $composableBuilder(
    column: $table.protocolVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> syncDevicesRefs(
    Expression<bool> Function($$SyncDevicesTableFilterComposer f) f,
  ) {
    final $$SyncDevicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.syncDevices,
      getReferencedColumn: (t) => t.syncGroupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncDevicesTableFilterComposer(
            $db: $db,
            $table: $db.syncDevices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> syncPairingInvitesRefs(
    Expression<bool> Function($$SyncPairingInvitesTableFilterComposer f) f,
  ) {
    final $$SyncPairingInvitesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.syncPairingInvites,
      getReferencedColumn: (t) => t.syncGroupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncPairingInvitesTableFilterComposer(
            $db: $db,
            $table: $db.syncPairingInvites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> syncChangesRefs(
    Expression<bool> Function($$SyncChangesTableFilterComposer f) f,
  ) {
    final $$SyncChangesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.syncChanges,
      getReferencedColumn: (t) => t.syncGroupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncChangesTableFilterComposer(
            $db: $db,
            $table: $db.syncChanges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> syncEntityVersionsRefs(
    Expression<bool> Function($$SyncEntityVersionsTableFilterComposer f) f,
  ) {
    final $$SyncEntityVersionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.syncEntityVersions,
      getReferencedColumn: (t) => t.syncGroupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncEntityVersionsTableFilterComposer(
            $db: $db,
            $table: $db.syncEntityVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> syncRelationDotsRefs(
    Expression<bool> Function($$SyncRelationDotsTableFilterComposer f) f,
  ) {
    final $$SyncRelationDotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.syncRelationDots,
      getReferencedColumn: (t) => t.syncGroupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncRelationDotsTableFilterComposer(
            $db: $db,
            $table: $db.syncRelationDots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> syncCursorsRefs(
    Expression<bool> Function($$SyncCursorsTableFilterComposer f) f,
  ) {
    final $$SyncCursorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.syncCursors,
      getReferencedColumn: (t) => t.syncGroupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncCursorsTableFilterComposer(
            $db: $db,
            $table: $db.syncCursors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> syncConflictsRefs(
    Expression<bool> Function($$SyncConflictsTableFilterComposer f) f,
  ) {
    final $$SyncConflictsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.syncConflicts,
      getReferencedColumn: (t) => t.syncGroupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncConflictsTableFilterComposer(
            $db: $db,
            $table: $db.syncConflicts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SyncGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncGroupsTable> {
  $$SyncGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hostDeviceId => $composableBuilder(
    column: $table.hostDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get protocolVersion => $composableBuilder(
    column: $table.protocolVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncGroupsTable> {
  $$SyncGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get hostDeviceId => $composableBuilder(
    column: $table.hostDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get protocolVersion => $composableBuilder(
    column: $table.protocolVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> syncDevicesRefs<T extends Object>(
    Expression<T> Function($$SyncDevicesTableAnnotationComposer a) f,
  ) {
    final $$SyncDevicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.syncDevices,
      getReferencedColumn: (t) => t.syncGroupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncDevicesTableAnnotationComposer(
            $db: $db,
            $table: $db.syncDevices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> syncPairingInvitesRefs<T extends Object>(
    Expression<T> Function($$SyncPairingInvitesTableAnnotationComposer a) f,
  ) {
    final $$SyncPairingInvitesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.syncPairingInvites,
          getReferencedColumn: (t) => t.syncGroupId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SyncPairingInvitesTableAnnotationComposer(
                $db: $db,
                $table: $db.syncPairingInvites,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> syncChangesRefs<T extends Object>(
    Expression<T> Function($$SyncChangesTableAnnotationComposer a) f,
  ) {
    final $$SyncChangesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.syncChanges,
      getReferencedColumn: (t) => t.syncGroupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncChangesTableAnnotationComposer(
            $db: $db,
            $table: $db.syncChanges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> syncEntityVersionsRefs<T extends Object>(
    Expression<T> Function($$SyncEntityVersionsTableAnnotationComposer a) f,
  ) {
    final $$SyncEntityVersionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.syncEntityVersions,
          getReferencedColumn: (t) => t.syncGroupId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SyncEntityVersionsTableAnnotationComposer(
                $db: $db,
                $table: $db.syncEntityVersions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> syncRelationDotsRefs<T extends Object>(
    Expression<T> Function($$SyncRelationDotsTableAnnotationComposer a) f,
  ) {
    final $$SyncRelationDotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.syncRelationDots,
      getReferencedColumn: (t) => t.syncGroupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncRelationDotsTableAnnotationComposer(
            $db: $db,
            $table: $db.syncRelationDots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> syncCursorsRefs<T extends Object>(
    Expression<T> Function($$SyncCursorsTableAnnotationComposer a) f,
  ) {
    final $$SyncCursorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.syncCursors,
      getReferencedColumn: (t) => t.syncGroupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncCursorsTableAnnotationComposer(
            $db: $db,
            $table: $db.syncCursors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> syncConflictsRefs<T extends Object>(
    Expression<T> Function($$SyncConflictsTableAnnotationComposer a) f,
  ) {
    final $$SyncConflictsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.syncConflicts,
      getReferencedColumn: (t) => t.syncGroupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncConflictsTableAnnotationComposer(
            $db: $db,
            $table: $db.syncConflicts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SyncGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncGroupsTable,
          SyncGroupRow,
          $$SyncGroupsTableFilterComposer,
          $$SyncGroupsTableOrderingComposer,
          $$SyncGroupsTableAnnotationComposer,
          $$SyncGroupsTableCreateCompanionBuilder,
          $$SyncGroupsTableUpdateCompanionBuilder,
          (SyncGroupRow, $$SyncGroupsTableReferences),
          SyncGroupRow,
          PrefetchHooks Function({
            bool syncDevicesRefs,
            bool syncPairingInvitesRefs,
            bool syncChangesRefs,
            bool syncEntityVersionsRefs,
            bool syncRelationDotsRefs,
            bool syncCursorsRefs,
            bool syncConflictsRefs,
          })
        > {
  $$SyncGroupsTableTableManager(_$AppDatabase db, $SyncGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> hostDeviceId = const Value.absent(),
                Value<int> protocolVersion = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncGroupsCompanion(
                id: id,
                role: role,
                hostDeviceId: hostDeviceId,
                protocolVersion: protocolVersion,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String role,
                required String hostDeviceId,
                required int protocolVersion,
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncGroupsCompanion.insert(
                id: id,
                role: role,
                hostDeviceId: hostDeviceId,
                protocolVersion: protocolVersion,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncGroupsTable, SyncGroupRow>(table),
                  $$SyncGroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                syncDevicesRefs = false,
                syncPairingInvitesRefs = false,
                syncChangesRefs = false,
                syncEntityVersionsRefs = false,
                syncRelationDotsRefs = false,
                syncCursorsRefs = false,
                syncConflictsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (syncDevicesRefs) db.syncDevices,
                    if (syncPairingInvitesRefs) db.syncPairingInvites,
                    if (syncChangesRefs) db.syncChanges,
                    if (syncEntityVersionsRefs) db.syncEntityVersions,
                    if (syncRelationDotsRefs) db.syncRelationDots,
                    if (syncCursorsRefs) db.syncCursors,
                    if (syncConflictsRefs) db.syncConflicts,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (syncDevicesRefs)
                        await $_getPrefetchedData<
                          SyncGroupRow,
                          $SyncGroupsTable,
                          SyncDeviceRow
                        >(
                          currentTable: table,
                          referencedTable: $$SyncGroupsTableReferences
                              ._syncDevicesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SyncGroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).syncDevicesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.syncGroupId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (syncPairingInvitesRefs)
                        await $_getPrefetchedData<
                          SyncGroupRow,
                          $SyncGroupsTable,
                          SyncPairingInviteRow
                        >(
                          currentTable: table,
                          referencedTable: $$SyncGroupsTableReferences
                              ._syncPairingInvitesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SyncGroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).syncPairingInvitesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.syncGroupId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (syncChangesRefs)
                        await $_getPrefetchedData<
                          SyncGroupRow,
                          $SyncGroupsTable,
                          SyncChangeRow
                        >(
                          currentTable: table,
                          referencedTable: $$SyncGroupsTableReferences
                              ._syncChangesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SyncGroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).syncChangesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.syncGroupId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (syncEntityVersionsRefs)
                        await $_getPrefetchedData<
                          SyncGroupRow,
                          $SyncGroupsTable,
                          SyncEntityVersionRow
                        >(
                          currentTable: table,
                          referencedTable: $$SyncGroupsTableReferences
                              ._syncEntityVersionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SyncGroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).syncEntityVersionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.syncGroupId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (syncRelationDotsRefs)
                        await $_getPrefetchedData<
                          SyncGroupRow,
                          $SyncGroupsTable,
                          SyncRelationDotRow
                        >(
                          currentTable: table,
                          referencedTable: $$SyncGroupsTableReferences
                              ._syncRelationDotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SyncGroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).syncRelationDotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.syncGroupId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (syncCursorsRefs)
                        await $_getPrefetchedData<
                          SyncGroupRow,
                          $SyncGroupsTable,
                          SyncCursorRow
                        >(
                          currentTable: table,
                          referencedTable: $$SyncGroupsTableReferences
                              ._syncCursorsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SyncGroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).syncCursorsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.syncGroupId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (syncConflictsRefs)
                        await $_getPrefetchedData<
                          SyncGroupRow,
                          $SyncGroupsTable,
                          SyncConflictRow
                        >(
                          currentTable: table,
                          referencedTable: $$SyncGroupsTableReferences
                              ._syncConflictsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SyncGroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).syncConflictsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.syncGroupId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SyncGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncGroupsTable,
      SyncGroupRow,
      $$SyncGroupsTableFilterComposer,
      $$SyncGroupsTableOrderingComposer,
      $$SyncGroupsTableAnnotationComposer,
      $$SyncGroupsTableCreateCompanionBuilder,
      $$SyncGroupsTableUpdateCompanionBuilder,
      (SyncGroupRow, $$SyncGroupsTableReferences),
      SyncGroupRow,
      PrefetchHooks Function({
        bool syncDevicesRefs,
        bool syncPairingInvitesRefs,
        bool syncChangesRefs,
        bool syncEntityVersionsRefs,
        bool syncRelationDotsRefs,
        bool syncCursorsRefs,
        bool syncConflictsRefs,
      })
    >;
typedef $$SyncDevicesTableCreateCompanionBuilder =
    SyncDevicesCompanion Function({
      required String deviceId,
      required String syncGroupId,
      required String displayName,
      Value<String?> note,
      required String platform,
      required String appVersion,
      required int protocolVersion,
      required String publicKey,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> lastSeenAt,
      Value<DateTime?> revokedAt,
      Value<int> rowid,
    });
typedef $$SyncDevicesTableUpdateCompanionBuilder =
    SyncDevicesCompanion Function({
      Value<String> deviceId,
      Value<String> syncGroupId,
      Value<String> displayName,
      Value<String?> note,
      Value<String> platform,
      Value<String> appVersion,
      Value<int> protocolVersion,
      Value<String> publicKey,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSeenAt,
      Value<DateTime?> revokedAt,
      Value<int> rowid,
    });

final class $$SyncDevicesTableReferences
    extends BaseReferences<_$AppDatabase, $SyncDevicesTable, SyncDeviceRow> {
  $$SyncDevicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SyncGroupsTable _syncGroupIdTable(_$AppDatabase db) =>
      db.syncGroups.createAlias('sync_devices__sync_group_id__sync_groups__id');

  $$SyncGroupsTableProcessedTableManager get syncGroupId {
    final $_column = $_itemColumn<String>('sync_group_id')!;

    final manager = $$SyncGroupsTableTableManager(
      $_db,
      $_db.syncGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_syncGroupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SyncChangesTable, List<SyncChangeRow>>
  _syncChangesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.syncChanges,
    aliasName: 'sync_devices__device_id__sync_changes__source_device_id',
  );

  $$SyncChangesTableProcessedTableManager get syncChangesRefs {
    final manager = $$SyncChangesTableTableManager($_db, $_db.syncChanges)
        .filter(
          (f) => f.sourceDeviceId.deviceId.sqlEquals(
            $_itemColumn<String>('device_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_syncChangesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SyncDevicesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncDevicesTable> {
  $$SyncDevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get protocolVersion => $composableBuilder(
    column: $table.protocolVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get revokedAt => $composableBuilder(
    column: $table.revokedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SyncGroupsTableFilterComposer get syncGroupId {
    final $$SyncGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.syncGroupId,
      referencedTable: $db.syncGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncGroupsTableFilterComposer(
            $db: $db,
            $table: $db.syncGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> syncChangesRefs(
    Expression<bool> Function($$SyncChangesTableFilterComposer f) f,
  ) {
    final $$SyncChangesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.syncChanges,
      getReferencedColumn: (t) => t.sourceDeviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncChangesTableFilterComposer(
            $db: $db,
            $table: $db.syncChanges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SyncDevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncDevicesTable> {
  $$SyncDevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get protocolVersion => $composableBuilder(
    column: $table.protocolVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get revokedAt => $composableBuilder(
    column: $table.revokedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SyncGroupsTableOrderingComposer get syncGroupId {
    final $$SyncGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.syncGroupId,
      referencedTable: $db.syncGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.syncGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncDevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncDevicesTable> {
  $$SyncDevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get protocolVersion => $composableBuilder(
    column: $table.protocolVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get revokedAt =>
      $composableBuilder(column: $table.revokedAt, builder: (column) => column);

  $$SyncGroupsTableAnnotationComposer get syncGroupId {
    final $$SyncGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.syncGroupId,
      referencedTable: $db.syncGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.syncGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> syncChangesRefs<T extends Object>(
    Expression<T> Function($$SyncChangesTableAnnotationComposer a) f,
  ) {
    final $$SyncChangesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.syncChanges,
      getReferencedColumn: (t) => t.sourceDeviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncChangesTableAnnotationComposer(
            $db: $db,
            $table: $db.syncChanges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SyncDevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncDevicesTable,
          SyncDeviceRow,
          $$SyncDevicesTableFilterComposer,
          $$SyncDevicesTableOrderingComposer,
          $$SyncDevicesTableAnnotationComposer,
          $$SyncDevicesTableCreateCompanionBuilder,
          $$SyncDevicesTableUpdateCompanionBuilder,
          (SyncDeviceRow, $$SyncDevicesTableReferences),
          SyncDeviceRow,
          PrefetchHooks Function({bool syncGroupId, bool syncChangesRefs})
        > {
  $$SyncDevicesTableTableManager(_$AppDatabase db, $SyncDevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncDevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncDevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncDevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> deviceId = const Value.absent(),
                Value<String> syncGroupId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String> appVersion = const Value.absent(),
                Value<int> protocolVersion = const Value.absent(),
                Value<String> publicKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<DateTime?> revokedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncDevicesCompanion(
                deviceId: deviceId,
                syncGroupId: syncGroupId,
                displayName: displayName,
                note: note,
                platform: platform,
                appVersion: appVersion,
                protocolVersion: protocolVersion,
                publicKey: publicKey,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSeenAt: lastSeenAt,
                revokedAt: revokedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String deviceId,
                required String syncGroupId,
                required String displayName,
                Value<String?> note = const Value.absent(),
                required String platform,
                required String appVersion,
                required int protocolVersion,
                required String publicKey,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<DateTime?> revokedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncDevicesCompanion.insert(
                deviceId: deviceId,
                syncGroupId: syncGroupId,
                displayName: displayName,
                note: note,
                platform: platform,
                appVersion: appVersion,
                protocolVersion: protocolVersion,
                publicKey: publicKey,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSeenAt: lastSeenAt,
                revokedAt: revokedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncDevicesTable, SyncDeviceRow>(table),
                  $$SyncDevicesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({syncGroupId = false, syncChangesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (syncChangesRefs) db.syncChanges,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (syncGroupId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.syncGroupId,
                            referencedTable: $$SyncDevicesTableReferences
                                ._syncGroupIdTable(db),
                            referencedColumn: $$SyncDevicesTableReferences
                                ._syncGroupIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (syncChangesRefs)
                        await $_getPrefetchedData<
                          SyncDeviceRow,
                          $SyncDevicesTable,
                          SyncChangeRow
                        >(
                          currentTable: table,
                          referencedTable: $$SyncDevicesTableReferences
                              ._syncChangesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SyncDevicesTableReferences(
                                db,
                                table,
                                p0,
                              ).syncChangesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceDeviceId == item.deviceId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SyncDevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncDevicesTable,
      SyncDeviceRow,
      $$SyncDevicesTableFilterComposer,
      $$SyncDevicesTableOrderingComposer,
      $$SyncDevicesTableAnnotationComposer,
      $$SyncDevicesTableCreateCompanionBuilder,
      $$SyncDevicesTableUpdateCompanionBuilder,
      (SyncDeviceRow, $$SyncDevicesTableReferences),
      SyncDeviceRow,
      PrefetchHooks Function({bool syncGroupId, bool syncChangesRefs})
    >;
typedef $$SyncPairingInvitesTableCreateCompanionBuilder =
    SyncPairingInvitesCompanion Function({
      required String id,
      required String syncGroupId,
      required String tokenHash,
      required String hostFingerprint,
      required DateTime expiresAt,
      Value<int> attemptCount,
      required int maximumAttempts,
      required DateTime createdAt,
      Value<DateTime?> consumedAt,
      Value<int> rowid,
    });
typedef $$SyncPairingInvitesTableUpdateCompanionBuilder =
    SyncPairingInvitesCompanion Function({
      Value<String> id,
      Value<String> syncGroupId,
      Value<String> tokenHash,
      Value<String> hostFingerprint,
      Value<DateTime> expiresAt,
      Value<int> attemptCount,
      Value<int> maximumAttempts,
      Value<DateTime> createdAt,
      Value<DateTime?> consumedAt,
      Value<int> rowid,
    });

final class $$SyncPairingInvitesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SyncPairingInvitesTable,
          SyncPairingInviteRow
        > {
  $$SyncPairingInvitesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SyncGroupsTable _syncGroupIdTable(_$AppDatabase db) => db.syncGroups
      .createAlias('sync_pairing_invites__sync_group_id__sync_groups__id');

  $$SyncGroupsTableProcessedTableManager get syncGroupId {
    final $_column = $_itemColumn<String>('sync_group_id')!;

    final manager = $$SyncGroupsTableTableManager(
      $_db,
      $_db.syncGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_syncGroupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SyncPairingInvitesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncPairingInvitesTable> {
  $$SyncPairingInvitesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tokenHash => $composableBuilder(
    column: $table.tokenHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hostFingerprint => $composableBuilder(
    column: $table.hostFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maximumAttempts => $composableBuilder(
    column: $table.maximumAttempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get consumedAt => $composableBuilder(
    column: $table.consumedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SyncGroupsTableFilterComposer get syncGroupId {
    final $$SyncGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.syncGroupId,
      referencedTable: $db.syncGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncGroupsTableFilterComposer(
            $db: $db,
            $table: $db.syncGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncPairingInvitesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncPairingInvitesTable> {
  $$SyncPairingInvitesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tokenHash => $composableBuilder(
    column: $table.tokenHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hostFingerprint => $composableBuilder(
    column: $table.hostFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maximumAttempts => $composableBuilder(
    column: $table.maximumAttempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get consumedAt => $composableBuilder(
    column: $table.consumedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SyncGroupsTableOrderingComposer get syncGroupId {
    final $$SyncGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.syncGroupId,
      referencedTable: $db.syncGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.syncGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncPairingInvitesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncPairingInvitesTable> {
  $$SyncPairingInvitesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tokenHash =>
      $composableBuilder(column: $table.tokenHash, builder: (column) => column);

  GeneratedColumn<String> get hostFingerprint => $composableBuilder(
    column: $table.hostFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maximumAttempts => $composableBuilder(
    column: $table.maximumAttempts,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get consumedAt => $composableBuilder(
    column: $table.consumedAt,
    builder: (column) => column,
  );

  $$SyncGroupsTableAnnotationComposer get syncGroupId {
    final $$SyncGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.syncGroupId,
      referencedTable: $db.syncGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.syncGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncPairingInvitesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncPairingInvitesTable,
          SyncPairingInviteRow,
          $$SyncPairingInvitesTableFilterComposer,
          $$SyncPairingInvitesTableOrderingComposer,
          $$SyncPairingInvitesTableAnnotationComposer,
          $$SyncPairingInvitesTableCreateCompanionBuilder,
          $$SyncPairingInvitesTableUpdateCompanionBuilder,
          (SyncPairingInviteRow, $$SyncPairingInvitesTableReferences),
          SyncPairingInviteRow,
          PrefetchHooks Function({bool syncGroupId})
        > {
  $$SyncPairingInvitesTableTableManager(
    _$AppDatabase db,
    $SyncPairingInvitesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncPairingInvitesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncPairingInvitesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncPairingInvitesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncGroupId = const Value.absent(),
                Value<String> tokenHash = const Value.absent(),
                Value<String> hostFingerprint = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<int> maximumAttempts = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> consumedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncPairingInvitesCompanion(
                id: id,
                syncGroupId: syncGroupId,
                tokenHash: tokenHash,
                hostFingerprint: hostFingerprint,
                expiresAt: expiresAt,
                attemptCount: attemptCount,
                maximumAttempts: maximumAttempts,
                createdAt: createdAt,
                consumedAt: consumedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String syncGroupId,
                required String tokenHash,
                required String hostFingerprint,
                required DateTime expiresAt,
                Value<int> attemptCount = const Value.absent(),
                required int maximumAttempts,
                required DateTime createdAt,
                Value<DateTime?> consumedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncPairingInvitesCompanion.insert(
                id: id,
                syncGroupId: syncGroupId,
                tokenHash: tokenHash,
                hostFingerprint: hostFingerprint,
                expiresAt: expiresAt,
                attemptCount: attemptCount,
                maximumAttempts: maximumAttempts,
                createdAt: createdAt,
                consumedAt: consumedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncPairingInvitesTable, SyncPairingInviteRow>(
                    table,
                  ),
                  $$SyncPairingInvitesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({syncGroupId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (syncGroupId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.syncGroupId,
                        referencedTable: $$SyncPairingInvitesTableReferences
                            ._syncGroupIdTable(db),
                        referencedColumn: $$SyncPairingInvitesTableReferences
                            ._syncGroupIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SyncPairingInvitesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncPairingInvitesTable,
      SyncPairingInviteRow,
      $$SyncPairingInvitesTableFilterComposer,
      $$SyncPairingInvitesTableOrderingComposer,
      $$SyncPairingInvitesTableAnnotationComposer,
      $$SyncPairingInvitesTableCreateCompanionBuilder,
      $$SyncPairingInvitesTableUpdateCompanionBuilder,
      (SyncPairingInviteRow, $$SyncPairingInvitesTableReferences),
      SyncPairingInviteRow,
      PrefetchHooks Function({bool syncGroupId})
    >;
typedef $$SyncChangesTableCreateCompanionBuilder =
    SyncChangesCompanion Function({
      required String operationId,
      required String syncGroupId,
      required String sourceDeviceId,
      required int sequence,
      required String transactionId,
      required String entityType,
      required String entityId,
      required String operationType,
      required String fieldGroup,
      required int payloadFormatVersion,
      required String payloadJson,
      required int hlcPhysicalMs,
      required int hlcLogical,
      required String hlcDeviceId,
      required String causalCursorJson,
      required DateTime createdAt,
      required DateTime appliedAt,
      Value<int> rowid,
    });
typedef $$SyncChangesTableUpdateCompanionBuilder =
    SyncChangesCompanion Function({
      Value<String> operationId,
      Value<String> syncGroupId,
      Value<String> sourceDeviceId,
      Value<int> sequence,
      Value<String> transactionId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> operationType,
      Value<String> fieldGroup,
      Value<int> payloadFormatVersion,
      Value<String> payloadJson,
      Value<int> hlcPhysicalMs,
      Value<int> hlcLogical,
      Value<String> hlcDeviceId,
      Value<String> causalCursorJson,
      Value<DateTime> createdAt,
      Value<DateTime> appliedAt,
      Value<int> rowid,
    });

final class $$SyncChangesTableReferences
    extends BaseReferences<_$AppDatabase, $SyncChangesTable, SyncChangeRow> {
  $$SyncChangesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SyncGroupsTable _syncGroupIdTable(_$AppDatabase db) =>
      db.syncGroups.createAlias('sync_changes__sync_group_id__sync_groups__id');

  $$SyncGroupsTableProcessedTableManager get syncGroupId {
    final $_column = $_itemColumn<String>('sync_group_id')!;

    final manager = $$SyncGroupsTableTableManager(
      $_db,
      $_db.syncGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_syncGroupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SyncDevicesTable _sourceDeviceIdTable(_$AppDatabase db) => db
      .syncDevices
      .createAlias('sync_changes__source_device_id__sync_devices__device_id');

  $$SyncDevicesTableProcessedTableManager get sourceDeviceId {
    final $_column = $_itemColumn<String>('source_device_id')!;

    final manager = $$SyncDevicesTableTableManager(
      $_db,
      $_db.syncDevices,
    ).filter((f) => f.deviceId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceDeviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SyncChangesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncChangesTable> {
  $$SyncChangesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldGroup => $composableBuilder(
    column: $table.fieldGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get payloadFormatVersion => $composableBuilder(
    column: $table.payloadFormatVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hlcPhysicalMs => $composableBuilder(
    column: $table.hlcPhysicalMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hlcLogical => $composableBuilder(
    column: $table.hlcLogical,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlcDeviceId => $composableBuilder(
    column: $table.hlcDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get causalCursorJson => $composableBuilder(
    column: $table.causalCursorJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SyncGroupsTableFilterComposer get syncGroupId {
    final $$SyncGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.syncGroupId,
      referencedTable: $db.syncGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncGroupsTableFilterComposer(
            $db: $db,
            $table: $db.syncGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SyncDevicesTableFilterComposer get sourceDeviceId {
    final $$SyncDevicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceDeviceId,
      referencedTable: $db.syncDevices,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncDevicesTableFilterComposer(
            $db: $db,
            $table: $db.syncDevices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncChangesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncChangesTable> {
  $$SyncChangesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldGroup => $composableBuilder(
    column: $table.fieldGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get payloadFormatVersion => $composableBuilder(
    column: $table.payloadFormatVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hlcPhysicalMs => $composableBuilder(
    column: $table.hlcPhysicalMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hlcLogical => $composableBuilder(
    column: $table.hlcLogical,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlcDeviceId => $composableBuilder(
    column: $table.hlcDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get causalCursorJson => $composableBuilder(
    column: $table.causalCursorJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SyncGroupsTableOrderingComposer get syncGroupId {
    final $$SyncGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.syncGroupId,
      referencedTable: $db.syncGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.syncGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SyncDevicesTableOrderingComposer get sourceDeviceId {
    final $$SyncDevicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceDeviceId,
      referencedTable: $db.syncDevices,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncDevicesTableOrderingComposer(
            $db: $db,
            $table: $db.syncDevices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncChangesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncChangesTable> {
  $$SyncChangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fieldGroup => $composableBuilder(
    column: $table.fieldGroup,
    builder: (column) => column,
  );

  GeneratedColumn<int> get payloadFormatVersion => $composableBuilder(
    column: $table.payloadFormatVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hlcPhysicalMs => $composableBuilder(
    column: $table.hlcPhysicalMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hlcLogical => $composableBuilder(
    column: $table.hlcLogical,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hlcDeviceId => $composableBuilder(
    column: $table.hlcDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get causalCursorJson => $composableBuilder(
    column: $table.causalCursorJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get appliedAt =>
      $composableBuilder(column: $table.appliedAt, builder: (column) => column);

  $$SyncGroupsTableAnnotationComposer get syncGroupId {
    final $$SyncGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.syncGroupId,
      referencedTable: $db.syncGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.syncGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SyncDevicesTableAnnotationComposer get sourceDeviceId {
    final $$SyncDevicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceDeviceId,
      referencedTable: $db.syncDevices,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncDevicesTableAnnotationComposer(
            $db: $db,
            $table: $db.syncDevices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncChangesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncChangesTable,
          SyncChangeRow,
          $$SyncChangesTableFilterComposer,
          $$SyncChangesTableOrderingComposer,
          $$SyncChangesTableAnnotationComposer,
          $$SyncChangesTableCreateCompanionBuilder,
          $$SyncChangesTableUpdateCompanionBuilder,
          (SyncChangeRow, $$SyncChangesTableReferences),
          SyncChangeRow,
          PrefetchHooks Function({bool syncGroupId, bool sourceDeviceId})
        > {
  $$SyncChangesTableTableManager(_$AppDatabase db, $SyncChangesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncChangesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncChangesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncChangesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> operationId = const Value.absent(),
                Value<String> syncGroupId = const Value.absent(),
                Value<String> sourceDeviceId = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<String> fieldGroup = const Value.absent(),
                Value<int> payloadFormatVersion = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> hlcPhysicalMs = const Value.absent(),
                Value<int> hlcLogical = const Value.absent(),
                Value<String> hlcDeviceId = const Value.absent(),
                Value<String> causalCursorJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> appliedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncChangesCompanion(
                operationId: operationId,
                syncGroupId: syncGroupId,
                sourceDeviceId: sourceDeviceId,
                sequence: sequence,
                transactionId: transactionId,
                entityType: entityType,
                entityId: entityId,
                operationType: operationType,
                fieldGroup: fieldGroup,
                payloadFormatVersion: payloadFormatVersion,
                payloadJson: payloadJson,
                hlcPhysicalMs: hlcPhysicalMs,
                hlcLogical: hlcLogical,
                hlcDeviceId: hlcDeviceId,
                causalCursorJson: causalCursorJson,
                createdAt: createdAt,
                appliedAt: appliedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String operationId,
                required String syncGroupId,
                required String sourceDeviceId,
                required int sequence,
                required String transactionId,
                required String entityType,
                required String entityId,
                required String operationType,
                required String fieldGroup,
                required int payloadFormatVersion,
                required String payloadJson,
                required int hlcPhysicalMs,
                required int hlcLogical,
                required String hlcDeviceId,
                required String causalCursorJson,
                required DateTime createdAt,
                required DateTime appliedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncChangesCompanion.insert(
                operationId: operationId,
                syncGroupId: syncGroupId,
                sourceDeviceId: sourceDeviceId,
                sequence: sequence,
                transactionId: transactionId,
                entityType: entityType,
                entityId: entityId,
                operationType: operationType,
                fieldGroup: fieldGroup,
                payloadFormatVersion: payloadFormatVersion,
                payloadJson: payloadJson,
                hlcPhysicalMs: hlcPhysicalMs,
                hlcLogical: hlcLogical,
                hlcDeviceId: hlcDeviceId,
                causalCursorJson: causalCursorJson,
                createdAt: createdAt,
                appliedAt: appliedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncChangesTable, SyncChangeRow>(table),
                  $$SyncChangesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({syncGroupId = false, sourceDeviceId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (syncGroupId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.syncGroupId,
                            referencedTable: $$SyncChangesTableReferences
                                ._syncGroupIdTable(db),
                            referencedColumn: $$SyncChangesTableReferences
                                ._syncGroupIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (sourceDeviceId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sourceDeviceId,
                            referencedTable: $$SyncChangesTableReferences
                                ._sourceDeviceIdTable(db),
                            referencedColumn: $$SyncChangesTableReferences
                                ._sourceDeviceIdTable(db)
                                .deviceId,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$SyncChangesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncChangesTable,
      SyncChangeRow,
      $$SyncChangesTableFilterComposer,
      $$SyncChangesTableOrderingComposer,
      $$SyncChangesTableAnnotationComposer,
      $$SyncChangesTableCreateCompanionBuilder,
      $$SyncChangesTableUpdateCompanionBuilder,
      (SyncChangeRow, $$SyncChangesTableReferences),
      SyncChangeRow,
      PrefetchHooks Function({bool syncGroupId, bool sourceDeviceId})
    >;
typedef $$SyncEntityVersionsTableCreateCompanionBuilder =
    SyncEntityVersionsCompanion Function({
      required String syncGroupId,
      required String entityType,
      required String entityId,
      required String fieldGroup,
      required String winningOperationId,
      required int hlcPhysicalMs,
      required int hlcLogical,
      required String hlcDeviceId,
      required String causalCursorJson,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SyncEntityVersionsTableUpdateCompanionBuilder =
    SyncEntityVersionsCompanion Function({
      Value<String> syncGroupId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> fieldGroup,
      Value<String> winningOperationId,
      Value<int> hlcPhysicalMs,
      Value<int> hlcLogical,
      Value<String> hlcDeviceId,
      Value<String> causalCursorJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$SyncEntityVersionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SyncEntityVersionsTable,
          SyncEntityVersionRow
        > {
  $$SyncEntityVersionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SyncGroupsTable _syncGroupIdTable(_$AppDatabase db) => db.syncGroups
      .createAlias('sync_entity_versions__sync_group_id__sync_groups__id');

  $$SyncGroupsTableProcessedTableManager get syncGroupId {
    final $_column = $_itemColumn<String>('sync_group_id')!;

    final manager = $$SyncGroupsTableTableManager(
      $_db,
      $_db.syncGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_syncGroupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SyncEntityVersionsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncEntityVersionsTable> {
  $$SyncEntityVersionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldGroup => $composableBuilder(
    column: $table.fieldGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get winningOperationId => $composableBuilder(
    column: $table.winningOperationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hlcPhysicalMs => $composableBuilder(
    column: $table.hlcPhysicalMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hlcLogical => $composableBuilder(
    column: $table.hlcLogical,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlcDeviceId => $composableBuilder(
    column: $table.hlcDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get causalCursorJson => $composableBuilder(
    column: $table.causalCursorJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SyncGroupsTableFilterComposer get syncGroupId {
    final $$SyncGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.syncGroupId,
      referencedTable: $db.syncGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncGroupsTableFilterComposer(
            $db: $db,
            $table: $db.syncGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncEntityVersionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncEntityVersionsTable> {
  $$SyncEntityVersionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldGroup => $composableBuilder(
    column: $table.fieldGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get winningOperationId => $composableBuilder(
    column: $table.winningOperationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hlcPhysicalMs => $composableBuilder(
    column: $table.hlcPhysicalMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hlcLogical => $composableBuilder(
    column: $table.hlcLogical,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlcDeviceId => $composableBuilder(
    column: $table.hlcDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get causalCursorJson => $composableBuilder(
    column: $table.causalCursorJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SyncGroupsTableOrderingComposer get syncGroupId {
    final $$SyncGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.syncGroupId,
      referencedTable: $db.syncGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.syncGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncEntityVersionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncEntityVersionsTable> {
  $$SyncEntityVersionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get fieldGroup => $composableBuilder(
    column: $table.fieldGroup,
    builder: (column) => column,
  );

  GeneratedColumn<String> get winningOperationId => $composableBuilder(
    column: $table.winningOperationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hlcPhysicalMs => $composableBuilder(
    column: $table.hlcPhysicalMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hlcLogical => $composableBuilder(
    column: $table.hlcLogical,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hlcDeviceId => $composableBuilder(
    column: $table.hlcDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get causalCursorJson => $composableBuilder(
    column: $table.causalCursorJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SyncGroupsTableAnnotationComposer get syncGroupId {
    final $$SyncGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.syncGroupId,
      referencedTable: $db.syncGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.syncGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncEntityVersionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncEntityVersionsTable,
          SyncEntityVersionRow,
          $$SyncEntityVersionsTableFilterComposer,
          $$SyncEntityVersionsTableOrderingComposer,
          $$SyncEntityVersionsTableAnnotationComposer,
          $$SyncEntityVersionsTableCreateCompanionBuilder,
          $$SyncEntityVersionsTableUpdateCompanionBuilder,
          (SyncEntityVersionRow, $$SyncEntityVersionsTableReferences),
          SyncEntityVersionRow,
          PrefetchHooks Function({bool syncGroupId})
        > {
  $$SyncEntityVersionsTableTableManager(
    _$AppDatabase db,
    $SyncEntityVersionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncEntityVersionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncEntityVersionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncEntityVersionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> syncGroupId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> fieldGroup = const Value.absent(),
                Value<String> winningOperationId = const Value.absent(),
                Value<int> hlcPhysicalMs = const Value.absent(),
                Value<int> hlcLogical = const Value.absent(),
                Value<String> hlcDeviceId = const Value.absent(),
                Value<String> causalCursorJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncEntityVersionsCompanion(
                syncGroupId: syncGroupId,
                entityType: entityType,
                entityId: entityId,
                fieldGroup: fieldGroup,
                winningOperationId: winningOperationId,
                hlcPhysicalMs: hlcPhysicalMs,
                hlcLogical: hlcLogical,
                hlcDeviceId: hlcDeviceId,
                causalCursorJson: causalCursorJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String syncGroupId,
                required String entityType,
                required String entityId,
                required String fieldGroup,
                required String winningOperationId,
                required int hlcPhysicalMs,
                required int hlcLogical,
                required String hlcDeviceId,
                required String causalCursorJson,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncEntityVersionsCompanion.insert(
                syncGroupId: syncGroupId,
                entityType: entityType,
                entityId: entityId,
                fieldGroup: fieldGroup,
                winningOperationId: winningOperationId,
                hlcPhysicalMs: hlcPhysicalMs,
                hlcLogical: hlcLogical,
                hlcDeviceId: hlcDeviceId,
                causalCursorJson: causalCursorJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncEntityVersionsTable, SyncEntityVersionRow>(
                    table,
                  ),
                  $$SyncEntityVersionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({syncGroupId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (syncGroupId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.syncGroupId,
                        referencedTable: $$SyncEntityVersionsTableReferences
                            ._syncGroupIdTable(db),
                        referencedColumn: $$SyncEntityVersionsTableReferences
                            ._syncGroupIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SyncEntityVersionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncEntityVersionsTable,
      SyncEntityVersionRow,
      $$SyncEntityVersionsTableFilterComposer,
      $$SyncEntityVersionsTableOrderingComposer,
      $$SyncEntityVersionsTableAnnotationComposer,
      $$SyncEntityVersionsTableCreateCompanionBuilder,
      $$SyncEntityVersionsTableUpdateCompanionBuilder,
      (SyncEntityVersionRow, $$SyncEntityVersionsTableReferences),
      SyncEntityVersionRow,
      PrefetchHooks Function({bool syncGroupId})
    >;
typedef $$SyncRelationDotsTableCreateCompanionBuilder =
    SyncRelationDotsCompanion Function({
      required String syncGroupId,
      required String todoId,
      required String tagId,
      required String addOperationId,
      required String addedByDeviceId,
      required int addedSequence,
      Value<String?> removedByOperationId,
      required DateTime createdAt,
      Value<DateTime?> removedAt,
      Value<int> rowid,
    });
typedef $$SyncRelationDotsTableUpdateCompanionBuilder =
    SyncRelationDotsCompanion Function({
      Value<String> syncGroupId,
      Value<String> todoId,
      Value<String> tagId,
      Value<String> addOperationId,
      Value<String> addedByDeviceId,
      Value<int> addedSequence,
      Value<String?> removedByOperationId,
      Value<DateTime> createdAt,
      Value<DateTime?> removedAt,
      Value<int> rowid,
    });

final class $$SyncRelationDotsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SyncRelationDotsTable,
          SyncRelationDotRow
        > {
  $$SyncRelationDotsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SyncGroupsTable _syncGroupIdTable(_$AppDatabase db) => db.syncGroups
      .createAlias('sync_relation_dots__sync_group_id__sync_groups__id');

  $$SyncGroupsTableProcessedTableManager get syncGroupId {
    final $_column = $_itemColumn<String>('sync_group_id')!;

    final manager = $$SyncGroupsTableTableManager(
      $_db,
      $_db.syncGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_syncGroupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SyncRelationDotsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncRelationDotsTable> {
  $$SyncRelationDotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get todoId => $composableBuilder(
    column: $table.todoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagId => $composableBuilder(
    column: $table.tagId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addOperationId => $composableBuilder(
    column: $table.addOperationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addedByDeviceId => $composableBuilder(
    column: $table.addedByDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get addedSequence => $composableBuilder(
    column: $table.addedSequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get removedByOperationId => $composableBuilder(
    column: $table.removedByOperationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get removedAt => $composableBuilder(
    column: $table.removedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SyncGroupsTableFilterComposer get syncGroupId {
    final $$SyncGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.syncGroupId,
      referencedTable: $db.syncGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncGroupsTableFilterComposer(
            $db: $db,
            $table: $db.syncGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncRelationDotsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncRelationDotsTable> {
  $$SyncRelationDotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get todoId => $composableBuilder(
    column: $table.todoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagId => $composableBuilder(
    column: $table.tagId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addOperationId => $composableBuilder(
    column: $table.addOperationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addedByDeviceId => $composableBuilder(
    column: $table.addedByDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get addedSequence => $composableBuilder(
    column: $table.addedSequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get removedByOperationId => $composableBuilder(
    column: $table.removedByOperationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get removedAt => $composableBuilder(
    column: $table.removedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SyncGroupsTableOrderingComposer get syncGroupId {
    final $$SyncGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.syncGroupId,
      referencedTable: $db.syncGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.syncGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncRelationDotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncRelationDotsTable> {
  $$SyncRelationDotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get todoId =>
      $composableBuilder(column: $table.todoId, builder: (column) => column);

  GeneratedColumn<String> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => column);

  GeneratedColumn<String> get addOperationId => $composableBuilder(
    column: $table.addOperationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get addedByDeviceId => $composableBuilder(
    column: $table.addedByDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get addedSequence => $composableBuilder(
    column: $table.addedSequence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get removedByOperationId => $composableBuilder(
    column: $table.removedByOperationId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get removedAt =>
      $composableBuilder(column: $table.removedAt, builder: (column) => column);

  $$SyncGroupsTableAnnotationComposer get syncGroupId {
    final $$SyncGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.syncGroupId,
      referencedTable: $db.syncGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.syncGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncRelationDotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncRelationDotsTable,
          SyncRelationDotRow,
          $$SyncRelationDotsTableFilterComposer,
          $$SyncRelationDotsTableOrderingComposer,
          $$SyncRelationDotsTableAnnotationComposer,
          $$SyncRelationDotsTableCreateCompanionBuilder,
          $$SyncRelationDotsTableUpdateCompanionBuilder,
          (SyncRelationDotRow, $$SyncRelationDotsTableReferences),
          SyncRelationDotRow,
          PrefetchHooks Function({bool syncGroupId})
        > {
  $$SyncRelationDotsTableTableManager(
    _$AppDatabase db,
    $SyncRelationDotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncRelationDotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncRelationDotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncRelationDotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> syncGroupId = const Value.absent(),
                Value<String> todoId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<String> addOperationId = const Value.absent(),
                Value<String> addedByDeviceId = const Value.absent(),
                Value<int> addedSequence = const Value.absent(),
                Value<String?> removedByOperationId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> removedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncRelationDotsCompanion(
                syncGroupId: syncGroupId,
                todoId: todoId,
                tagId: tagId,
                addOperationId: addOperationId,
                addedByDeviceId: addedByDeviceId,
                addedSequence: addedSequence,
                removedByOperationId: removedByOperationId,
                createdAt: createdAt,
                removedAt: removedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String syncGroupId,
                required String todoId,
                required String tagId,
                required String addOperationId,
                required String addedByDeviceId,
                required int addedSequence,
                Value<String?> removedByOperationId = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> removedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncRelationDotsCompanion.insert(
                syncGroupId: syncGroupId,
                todoId: todoId,
                tagId: tagId,
                addOperationId: addOperationId,
                addedByDeviceId: addedByDeviceId,
                addedSequence: addedSequence,
                removedByOperationId: removedByOperationId,
                createdAt: createdAt,
                removedAt: removedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncRelationDotsTable, SyncRelationDotRow>(
                    table,
                  ),
                  $$SyncRelationDotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({syncGroupId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (syncGroupId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.syncGroupId,
                        referencedTable: $$SyncRelationDotsTableReferences
                            ._syncGroupIdTable(db),
                        referencedColumn: $$SyncRelationDotsTableReferences
                            ._syncGroupIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SyncRelationDotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncRelationDotsTable,
      SyncRelationDotRow,
      $$SyncRelationDotsTableFilterComposer,
      $$SyncRelationDotsTableOrderingComposer,
      $$SyncRelationDotsTableAnnotationComposer,
      $$SyncRelationDotsTableCreateCompanionBuilder,
      $$SyncRelationDotsTableUpdateCompanionBuilder,
      (SyncRelationDotRow, $$SyncRelationDotsTableReferences),
      SyncRelationDotRow,
      PrefetchHooks Function({bool syncGroupId})
    >;
typedef $$SyncCursorsTableCreateCompanionBuilder =
    SyncCursorsCompanion Function({
      required String syncGroupId,
      required String peerDeviceId,
      required String sourceDeviceId,
      Value<int> acknowledgedSequence,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SyncCursorsTableUpdateCompanionBuilder =
    SyncCursorsCompanion Function({
      Value<String> syncGroupId,
      Value<String> peerDeviceId,
      Value<String> sourceDeviceId,
      Value<int> acknowledgedSequence,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$SyncCursorsTableReferences
    extends BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursorRow> {
  $$SyncCursorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SyncGroupsTable _syncGroupIdTable(_$AppDatabase db) =>
      db.syncGroups.createAlias('sync_cursors__sync_group_id__sync_groups__id');

  $$SyncGroupsTableProcessedTableManager get syncGroupId {
    final $_column = $_itemColumn<String>('sync_group_id')!;

    final manager = $$SyncGroupsTableTableManager(
      $_db,
      $_db.syncGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_syncGroupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SyncCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get peerDeviceId => $composableBuilder(
    column: $table.peerDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceDeviceId => $composableBuilder(
    column: $table.sourceDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get acknowledgedSequence => $composableBuilder(
    column: $table.acknowledgedSequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SyncGroupsTableFilterComposer get syncGroupId {
    final $$SyncGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.syncGroupId,
      referencedTable: $db.syncGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncGroupsTableFilterComposer(
            $db: $db,
            $table: $db.syncGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get peerDeviceId => $composableBuilder(
    column: $table.peerDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceDeviceId => $composableBuilder(
    column: $table.sourceDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get acknowledgedSequence => $composableBuilder(
    column: $table.acknowledgedSequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SyncGroupsTableOrderingComposer get syncGroupId {
    final $$SyncGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.syncGroupId,
      referencedTable: $db.syncGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.syncGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get peerDeviceId => $composableBuilder(
    column: $table.peerDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceDeviceId => $composableBuilder(
    column: $table.sourceDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get acknowledgedSequence => $composableBuilder(
    column: $table.acknowledgedSequence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SyncGroupsTableAnnotationComposer get syncGroupId {
    final $$SyncGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.syncGroupId,
      referencedTable: $db.syncGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.syncGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncCursorsTable,
          SyncCursorRow,
          $$SyncCursorsTableFilterComposer,
          $$SyncCursorsTableOrderingComposer,
          $$SyncCursorsTableAnnotationComposer,
          $$SyncCursorsTableCreateCompanionBuilder,
          $$SyncCursorsTableUpdateCompanionBuilder,
          (SyncCursorRow, $$SyncCursorsTableReferences),
          SyncCursorRow,
          PrefetchHooks Function({bool syncGroupId})
        > {
  $$SyncCursorsTableTableManager(_$AppDatabase db, $SyncCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> syncGroupId = const Value.absent(),
                Value<String> peerDeviceId = const Value.absent(),
                Value<String> sourceDeviceId = const Value.absent(),
                Value<int> acknowledgedSequence = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion(
                syncGroupId: syncGroupId,
                peerDeviceId: peerDeviceId,
                sourceDeviceId: sourceDeviceId,
                acknowledgedSequence: acknowledgedSequence,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String syncGroupId,
                required String peerDeviceId,
                required String sourceDeviceId,
                Value<int> acknowledgedSequence = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion.insert(
                syncGroupId: syncGroupId,
                peerDeviceId: peerDeviceId,
                sourceDeviceId: sourceDeviceId,
                acknowledgedSequence: acknowledgedSequence,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncCursorsTable, SyncCursorRow>(table),
                  $$SyncCursorsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({syncGroupId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (syncGroupId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.syncGroupId,
                        referencedTable: $$SyncCursorsTableReferences
                            ._syncGroupIdTable(db),
                        referencedColumn: $$SyncCursorsTableReferences
                            ._syncGroupIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SyncCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncCursorsTable,
      SyncCursorRow,
      $$SyncCursorsTableFilterComposer,
      $$SyncCursorsTableOrderingComposer,
      $$SyncCursorsTableAnnotationComposer,
      $$SyncCursorsTableCreateCompanionBuilder,
      $$SyncCursorsTableUpdateCompanionBuilder,
      (SyncCursorRow, $$SyncCursorsTableReferences),
      SyncCursorRow,
      PrefetchHooks Function({bool syncGroupId})
    >;
typedef $$SyncConflictsTableCreateCompanionBuilder =
    SyncConflictsCompanion Function({
      required String id,
      required String syncGroupId,
      required String entityType,
      required String entityId,
      required String fieldGroup,
      required String kind,
      required String winnerOperationId,
      required String loserOperationId,
      required String losingPayloadJson,
      required DateTime createdAt,
      Value<DateTime?> resolvedAt,
      Value<String?> resolutionOperationId,
      Value<int> rowid,
    });
typedef $$SyncConflictsTableUpdateCompanionBuilder =
    SyncConflictsCompanion Function({
      Value<String> id,
      Value<String> syncGroupId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> fieldGroup,
      Value<String> kind,
      Value<String> winnerOperationId,
      Value<String> loserOperationId,
      Value<String> losingPayloadJson,
      Value<DateTime> createdAt,
      Value<DateTime?> resolvedAt,
      Value<String?> resolutionOperationId,
      Value<int> rowid,
    });

final class $$SyncConflictsTableReferences
    extends
        BaseReferences<_$AppDatabase, $SyncConflictsTable, SyncConflictRow> {
  $$SyncConflictsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SyncGroupsTable _syncGroupIdTable(_$AppDatabase db) => db.syncGroups
      .createAlias('sync_conflicts__sync_group_id__sync_groups__id');

  $$SyncGroupsTableProcessedTableManager get syncGroupId {
    final $_column = $_itemColumn<String>('sync_group_id')!;

    final manager = $$SyncGroupsTableTableManager(
      $_db,
      $_db.syncGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_syncGroupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SyncConflictsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldGroup => $composableBuilder(
    column: $table.fieldGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get winnerOperationId => $composableBuilder(
    column: $table.winnerOperationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loserOperationId => $composableBuilder(
    column: $table.loserOperationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get losingPayloadJson => $composableBuilder(
    column: $table.losingPayloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolutionOperationId => $composableBuilder(
    column: $table.resolutionOperationId,
    builder: (column) => ColumnFilters(column),
  );

  $$SyncGroupsTableFilterComposer get syncGroupId {
    final $$SyncGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.syncGroupId,
      referencedTable: $db.syncGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncGroupsTableFilterComposer(
            $db: $db,
            $table: $db.syncGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncConflictsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldGroup => $composableBuilder(
    column: $table.fieldGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get winnerOperationId => $composableBuilder(
    column: $table.winnerOperationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loserOperationId => $composableBuilder(
    column: $table.loserOperationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get losingPayloadJson => $composableBuilder(
    column: $table.losingPayloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolutionOperationId => $composableBuilder(
    column: $table.resolutionOperationId,
    builder: (column) => ColumnOrderings(column),
  );

  $$SyncGroupsTableOrderingComposer get syncGroupId {
    final $$SyncGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.syncGroupId,
      referencedTable: $db.syncGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.syncGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncConflictsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get fieldGroup => $composableBuilder(
    column: $table.fieldGroup,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get winnerOperationId => $composableBuilder(
    column: $table.winnerOperationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get loserOperationId => $composableBuilder(
    column: $table.loserOperationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get losingPayloadJson => $composableBuilder(
    column: $table.losingPayloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resolutionOperationId => $composableBuilder(
    column: $table.resolutionOperationId,
    builder: (column) => column,
  );

  $$SyncGroupsTableAnnotationComposer get syncGroupId {
    final $$SyncGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.syncGroupId,
      referencedTable: $db.syncGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.syncGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncConflictsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncConflictsTable,
          SyncConflictRow,
          $$SyncConflictsTableFilterComposer,
          $$SyncConflictsTableOrderingComposer,
          $$SyncConflictsTableAnnotationComposer,
          $$SyncConflictsTableCreateCompanionBuilder,
          $$SyncConflictsTableUpdateCompanionBuilder,
          (SyncConflictRow, $$SyncConflictsTableReferences),
          SyncConflictRow,
          PrefetchHooks Function({bool syncGroupId})
        > {
  $$SyncConflictsTableTableManager(_$AppDatabase db, $SyncConflictsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncGroupId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> fieldGroup = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> winnerOperationId = const Value.absent(),
                Value<String> loserOperationId = const Value.absent(),
                Value<String> losingPayloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<String?> resolutionOperationId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion(
                id: id,
                syncGroupId: syncGroupId,
                entityType: entityType,
                entityId: entityId,
                fieldGroup: fieldGroup,
                kind: kind,
                winnerOperationId: winnerOperationId,
                loserOperationId: loserOperationId,
                losingPayloadJson: losingPayloadJson,
                createdAt: createdAt,
                resolvedAt: resolvedAt,
                resolutionOperationId: resolutionOperationId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String syncGroupId,
                required String entityType,
                required String entityId,
                required String fieldGroup,
                required String kind,
                required String winnerOperationId,
                required String loserOperationId,
                required String losingPayloadJson,
                required DateTime createdAt,
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<String?> resolutionOperationId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion.insert(
                id: id,
                syncGroupId: syncGroupId,
                entityType: entityType,
                entityId: entityId,
                fieldGroup: fieldGroup,
                kind: kind,
                winnerOperationId: winnerOperationId,
                loserOperationId: loserOperationId,
                losingPayloadJson: losingPayloadJson,
                createdAt: createdAt,
                resolvedAt: resolvedAt,
                resolutionOperationId: resolutionOperationId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncConflictsTable, SyncConflictRow>(table),
                  $$SyncConflictsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({syncGroupId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (syncGroupId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.syncGroupId,
                        referencedTable: $$SyncConflictsTableReferences
                            ._syncGroupIdTable(db),
                        referencedColumn: $$SyncConflictsTableReferences
                            ._syncGroupIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SyncConflictsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncConflictsTable,
      SyncConflictRow,
      $$SyncConflictsTableFilterComposer,
      $$SyncConflictsTableOrderingComposer,
      $$SyncConflictsTableAnnotationComposer,
      $$SyncConflictsTableCreateCompanionBuilder,
      $$SyncConflictsTableUpdateCompanionBuilder,
      (SyncConflictRow, $$SyncConflictsTableReferences),
      SyncConflictRow,
      PrefetchHooks Function({bool syncGroupId})
    >;
typedef $$SyncRuntimeStatesTableCreateCompanionBuilder =
    SyncRuntimeStatesCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SyncRuntimeStatesTableUpdateCompanionBuilder =
    SyncRuntimeStatesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SyncRuntimeStatesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncRuntimeStatesTable> {
  $$SyncRuntimeStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncRuntimeStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncRuntimeStatesTable> {
  $$SyncRuntimeStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncRuntimeStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncRuntimeStatesTable> {
  $$SyncRuntimeStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncRuntimeStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncRuntimeStatesTable,
          SyncRuntimeStateRow,
          $$SyncRuntimeStatesTableFilterComposer,
          $$SyncRuntimeStatesTableOrderingComposer,
          $$SyncRuntimeStatesTableAnnotationComposer,
          $$SyncRuntimeStatesTableCreateCompanionBuilder,
          $$SyncRuntimeStatesTableUpdateCompanionBuilder,
          (
            SyncRuntimeStateRow,
            BaseReferences<
              _$AppDatabase,
              $SyncRuntimeStatesTable,
              SyncRuntimeStateRow
            >,
          ),
          SyncRuntimeStateRow,
          PrefetchHooks Function()
        > {
  $$SyncRuntimeStatesTableTableManager(
    _$AppDatabase db,
    $SyncRuntimeStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncRuntimeStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncRuntimeStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncRuntimeStatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncRuntimeStatesCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncRuntimeStatesCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncRuntimeStatesTable, SyncRuntimeStateRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncRuntimeStatesTable,
                    SyncRuntimeStateRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncRuntimeStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncRuntimeStatesTable,
      SyncRuntimeStateRow,
      $$SyncRuntimeStatesTableFilterComposer,
      $$SyncRuntimeStatesTableOrderingComposer,
      $$SyncRuntimeStatesTableAnnotationComposer,
      $$SyncRuntimeStatesTableCreateCompanionBuilder,
      $$SyncRuntimeStatesTableUpdateCompanionBuilder,
      (
        SyncRuntimeStateRow,
        BaseReferences<
          _$AppDatabase,
          $SyncRuntimeStatesTable,
          SyncRuntimeStateRow
        >,
      ),
      SyncRuntimeStateRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$RecurrenceSeriesEntriesTableTableManager get recurrenceSeriesEntries =>
      $$RecurrenceSeriesEntriesTableTableManager(
        _db,
        _db.recurrenceSeriesEntries,
      );
  $$TodosTableTableManager get todos =>
      $$TodosTableTableManager(_db, _db.todos);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$TodoTagsTableTableManager get todoTags =>
      $$TodoTagsTableTableManager(_db, _db.todoTags);
  $$RecurrenceExceptionsTableTableManager get recurrenceExceptions =>
      $$RecurrenceExceptionsTableTableManager(_db, _db.recurrenceExceptions);
  $$HolidayYearsTableTableManager get holidayYears =>
      $$HolidayYearsTableTableManager(_db, _db.holidayYears);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$SyncGroupsTableTableManager get syncGroups =>
      $$SyncGroupsTableTableManager(_db, _db.syncGroups);
  $$SyncDevicesTableTableManager get syncDevices =>
      $$SyncDevicesTableTableManager(_db, _db.syncDevices);
  $$SyncPairingInvitesTableTableManager get syncPairingInvites =>
      $$SyncPairingInvitesTableTableManager(_db, _db.syncPairingInvites);
  $$SyncChangesTableTableManager get syncChanges =>
      $$SyncChangesTableTableManager(_db, _db.syncChanges);
  $$SyncEntityVersionsTableTableManager get syncEntityVersions =>
      $$SyncEntityVersionsTableTableManager(_db, _db.syncEntityVersions);
  $$SyncRelationDotsTableTableManager get syncRelationDots =>
      $$SyncRelationDotsTableTableManager(_db, _db.syncRelationDots);
  $$SyncCursorsTableTableManager get syncCursors =>
      $$SyncCursorsTableTableManager(_db, _db.syncCursors);
  $$SyncConflictsTableTableManager get syncConflicts =>
      $$SyncConflictsTableTableManager(_db, _db.syncConflicts);
  $$SyncRuntimeStatesTableTableManager get syncRuntimeStates =>
      $$SyncRuntimeStatesTableTableManager(_db, _db.syncRuntimeStates);
}
