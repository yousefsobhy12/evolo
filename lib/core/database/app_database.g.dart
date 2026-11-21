// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $HabitsTable extends Habits with TableInfo<$HabitsTable, HabitRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<HabitColor, String> color =
      GeneratedColumn<String>(
        'color',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<HabitColor>($HabitsTable.$convertercolor);
  static const VerificationMeta _dailyTargetMeta = const VerificationMeta(
    'dailyTarget',
  );
  @override
  late final GeneratedColumn<int> dailyTarget = GeneratedColumn<int>(
    'daily_target',
    aliasedName,
    false,
    check: () => ComparableExpr(dailyTarget).isBiggerOrEqualValue(1),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<HabitSchedule, int> schedule =
      GeneratedColumn<int>(
        'schedule',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<HabitSchedule>($HabitsTable.$converterschedule);
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    iconKey,
    color,
    dailyTarget,
    schedule,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitRow> instance, {
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
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_iconKeyMeta);
    }
    if (data.containsKey('daily_target')) {
      context.handle(
        _dailyTargetMeta,
        dailyTarget.isAcceptableOrUnknown(
          data['daily_target']!,
          _dailyTargetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dailyTargetMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      color: $HabitsTable.$convertercolor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}color'],
        )!,
      ),
      dailyTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_target'],
      )!,
      schedule: $HabitsTable.$converterschedule.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}schedule'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<HabitColor, String, String> $convertercolor =
      const EnumNameConverter<HabitColor>(HabitColor.values);
  static TypeConverter<HabitSchedule, int> $converterschedule =
      const HabitScheduleConverter();
}

class HabitRow extends DataClass implements Insertable<HabitRow> {
  final String id;
  final String name;
  final String iconKey;
  final HabitColor color;
  final int dailyTarget;
  final HabitSchedule schedule;
  final DateTime createdAt;
  const HabitRow({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.color,
    required this.dailyTarget,
    required this.schedule,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon_key'] = Variable<String>(iconKey);
    {
      map['color'] = Variable<String>(
        $HabitsTable.$convertercolor.toSql(color),
      );
    }
    map['daily_target'] = Variable<int>(dailyTarget);
    {
      map['schedule'] = Variable<int>(
        $HabitsTable.$converterschedule.toSql(schedule),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: Value(id),
      name: Value(name),
      iconKey: Value(iconKey),
      color: Value(color),
      dailyTarget: Value(dailyTarget),
      schedule: Value(schedule),
      createdAt: Value(createdAt),
    );
  }

  factory HabitRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      color: $HabitsTable.$convertercolor.fromJson(
        serializer.fromJson<String>(json['color']),
      ),
      dailyTarget: serializer.fromJson<int>(json['dailyTarget']),
      schedule: serializer.fromJson<HabitSchedule>(json['schedule']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'iconKey': serializer.toJson<String>(iconKey),
      'color': serializer.toJson<String>(
        $HabitsTable.$convertercolor.toJson(color),
      ),
      'dailyTarget': serializer.toJson<int>(dailyTarget),
      'schedule': serializer.toJson<HabitSchedule>(schedule),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HabitRow copyWith({
    String? id,
    String? name,
    String? iconKey,
    HabitColor? color,
    int? dailyTarget,
    HabitSchedule? schedule,
    DateTime? createdAt,
  }) => HabitRow(
    id: id ?? this.id,
    name: name ?? this.name,
    iconKey: iconKey ?? this.iconKey,
    color: color ?? this.color,
    dailyTarget: dailyTarget ?? this.dailyTarget,
    schedule: schedule ?? this.schedule,
    createdAt: createdAt ?? this.createdAt,
  );
  HabitRow copyWithCompanion(HabitsCompanion data) {
    return HabitRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      color: data.color.present ? data.color.value : this.color,
      dailyTarget: data.dailyTarget.present
          ? data.dailyTarget.value
          : this.dailyTarget,
      schedule: data.schedule.present ? data.schedule.value : this.schedule,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconKey: $iconKey, ')
          ..write('color: $color, ')
          ..write('dailyTarget: $dailyTarget, ')
          ..write('schedule: $schedule, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, iconKey, color, dailyTarget, schedule, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconKey == this.iconKey &&
          other.color == this.color &&
          other.dailyTarget == this.dailyTarget &&
          other.schedule == this.schedule &&
          other.createdAt == this.createdAt);
}

class HabitsCompanion extends UpdateCompanion<HabitRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> iconKey;
  final Value<HabitColor> color;
  final Value<int> dailyTarget;
  final Value<HabitSchedule> schedule;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.color = const Value.absent(),
    this.dailyTarget = const Value.absent(),
    this.schedule = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitsCompanion.insert({
    required String id,
    required String name,
    required String iconKey,
    required HabitColor color,
    required int dailyTarget,
    required HabitSchedule schedule,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       iconKey = Value(iconKey),
       color = Value(color),
       dailyTarget = Value(dailyTarget),
       schedule = Value(schedule),
       createdAt = Value(createdAt);
  static Insertable<HabitRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? iconKey,
    Expression<String>? color,
    Expression<int>? dailyTarget,
    Expression<int>? schedule,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconKey != null) 'icon_key': iconKey,
      if (color != null) 'color': color,
      if (dailyTarget != null) 'daily_target': dailyTarget,
      if (schedule != null) 'schedule': schedule,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? iconKey,
    Value<HabitColor>? color,
    Value<int>? dailyTarget,
    Value<HabitSchedule>? schedule,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return HabitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      color: color ?? this.color,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      schedule: schedule ?? this.schedule,
      createdAt: createdAt ?? this.createdAt,
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
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(
        $HabitsTable.$convertercolor.toSql(color.value),
      );
    }
    if (dailyTarget.present) {
      map['daily_target'] = Variable<int>(dailyTarget.value);
    }
    if (schedule.present) {
      map['schedule'] = Variable<int>(
        $HabitsTable.$converterschedule.toSql(schedule.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconKey: $iconKey, ')
          ..write('color: $color, ')
          ..write('dailyTarget: $dailyTarget, ')
          ..write('schedule: $schedule, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final HabitsDao habitsDao = HabitsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [habits];
}

typedef $$HabitsTableCreateCompanionBuilder = HabitsCompanion Function({
  required String id,
  required String name,
  required String iconKey,
  required HabitColor color,
  required int dailyTarget,
  required HabitSchedule schedule,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$HabitsTableUpdateCompanionBuilder = HabitsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> iconKey,
  Value<HabitColor> color,
  Value<int> dailyTarget,
  Value<HabitSchedule> schedule,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$HabitsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableFilterComposer({
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

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<HabitColor, HabitColor, String> get color =>
      $composableBuilder(
        column: $table.color,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get dailyTarget => $composableBuilder(
    column: $table.dailyTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<HabitSchedule, HabitSchedule, int>
  get schedule => $composableBuilder(
    column: $table.schedule,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableOrderingComposer({
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

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyTarget => $composableBuilder(
    column: $table.dailyTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schedule => $composableBuilder(
    column: $table.schedule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
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

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumnWithTypeConverter<HabitColor, String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get dailyTarget => $composableBuilder(
    column: $table.dailyTarget,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<HabitSchedule, int> get schedule =>
      $composableBuilder(column: $table.schedule, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HabitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitsTable,
          HabitRow,
          $$HabitsTableFilterComposer,
          $$HabitsTableOrderingComposer,
          $$HabitsTableAnnotationComposer,
          $$HabitsTableCreateCompanionBuilder,
          $$HabitsTableUpdateCompanionBuilder,
          (HabitRow, BaseReferences<_$AppDatabase, $HabitsTable, HabitRow>),
          HabitRow,
          PrefetchHooks Function()
        > {
  $$HabitsTableTableManager(_$AppDatabase db, $HabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<HabitColor> color = const Value.absent(),
                Value<int> dailyTarget = const Value.absent(),
                Value<HabitSchedule> schedule = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitsCompanion(
                id: id,
                name: name,
                iconKey: iconKey,
                color: color,
                dailyTarget: dailyTarget,
                schedule: schedule,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String iconKey,
                required HabitColor color,
                required int dailyTarget,
                required HabitSchedule schedule,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => HabitsCompanion.insert(
                id: id,
                name: name,
                iconKey: iconKey,
                color: color,
                dailyTarget: dailyTarget,
                schedule: schedule,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HabitsTable, HabitRow>(table),
                  BaseReferences<_$AppDatabase, $HabitsTable, HabitRow>(
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

typedef $$HabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitsTable,
      HabitRow,
      $$HabitsTableFilterComposer,
      $$HabitsTableOrderingComposer,
      $$HabitsTableAnnotationComposer,
      $$HabitsTableCreateCompanionBuilder,
      $$HabitsTableUpdateCompanionBuilder,
      (HabitRow, BaseReferences<_$AppDatabase, $HabitsTable, HabitRow>),
      HabitRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
}
