// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fleet_notes_database.dart';

// ignore_for_file: type=lint
class $FleetNotesTable extends FleetNotes
    with TableInfo<$FleetNotesTable, FleetNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FleetNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _vehicleIdMeta =
      const VerificationMeta('vehicleId');
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
      'vehicle_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vehicleNameMeta =
      const VerificationMeta('vehicleName');
  @override
  late final GeneratedColumn<String> vehicleName = GeneratedColumn<String>(
      'vehicle_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, vehicleId, vehicleName, note, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fleet_notes';
  @override
  VerificationContext validateIntegrity(Insertable<FleetNote> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(_vehicleIdMeta,
          vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta));
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('vehicle_name')) {
      context.handle(
          _vehicleNameMeta,
          vehicleName.isAcceptableOrUnknown(
              data['vehicle_name']!, _vehicleNameMeta));
    } else if (isInserting) {
      context.missing(_vehicleNameMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FleetNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FleetNote(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      vehicleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vehicle_id'])!,
      vehicleName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vehicle_name'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $FleetNotesTable createAlias(String alias) {
    return $FleetNotesTable(attachedDatabase, alias);
  }
}

class FleetNote extends DataClass implements Insertable<FleetNote> {
  final int id;
  final String vehicleId;
  final String vehicleName;
  final String note;
  final DateTime createdAt;
  const FleetNote(
      {required this.id,
      required this.vehicleId,
      required this.vehicleName,
      required this.note,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['vehicle_name'] = Variable<String>(vehicleName);
    map['note'] = Variable<String>(note);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FleetNotesCompanion toCompanion(bool nullToAbsent) {
    return FleetNotesCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      vehicleName: Value(vehicleName),
      note: Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory FleetNote.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FleetNote(
      id: serializer.fromJson<int>(json['id']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      vehicleName: serializer.fromJson<String>(json['vehicleName']),
      note: serializer.fromJson<String>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'vehicleName': serializer.toJson<String>(vehicleName),
      'note': serializer.toJson<String>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FleetNote copyWith(
          {int? id,
          String? vehicleId,
          String? vehicleName,
          String? note,
          DateTime? createdAt}) =>
      FleetNote(
        id: id ?? this.id,
        vehicleId: vehicleId ?? this.vehicleId,
        vehicleName: vehicleName ?? this.vehicleName,
        note: note ?? this.note,
        createdAt: createdAt ?? this.createdAt,
      );
  FleetNote copyWithCompanion(FleetNotesCompanion data) {
    return FleetNote(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      vehicleName:
          data.vehicleName.present ? data.vehicleName.value : this.vehicleName,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FleetNote(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('vehicleName: $vehicleName, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, vehicleId, vehicleName, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FleetNote &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.vehicleName == this.vehicleName &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class FleetNotesCompanion extends UpdateCompanion<FleetNote> {
  final Value<int> id;
  final Value<String> vehicleId;
  final Value<String> vehicleName;
  final Value<String> note;
  final Value<DateTime> createdAt;
  const FleetNotesCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.vehicleName = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FleetNotesCompanion.insert({
    this.id = const Value.absent(),
    required String vehicleId,
    required String vehicleName,
    required String note,
    required DateTime createdAt,
  })  : vehicleId = Value(vehicleId),
        vehicleName = Value(vehicleName),
        note = Value(note),
        createdAt = Value(createdAt);
  static Insertable<FleetNote> custom({
    Expression<int>? id,
    Expression<String>? vehicleId,
    Expression<String>? vehicleName,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (vehicleName != null) 'vehicle_name': vehicleName,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FleetNotesCompanion copyWith(
      {Value<int>? id,
      Value<String>? vehicleId,
      Value<String>? vehicleName,
      Value<String>? note,
      Value<DateTime>? createdAt}) {
    return FleetNotesCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleName: vehicleName ?? this.vehicleName,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (vehicleName.present) {
      map['vehicle_name'] = Variable<String>(vehicleName.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FleetNotesCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('vehicleName: $vehicleName, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$FleetNotesDatabase extends GeneratedDatabase {
  _$FleetNotesDatabase(QueryExecutor e) : super(e);
  $FleetNotesDatabaseManager get managers => $FleetNotesDatabaseManager(this);
  late final $FleetNotesTable fleetNotes = $FleetNotesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [fleetNotes];
}

typedef $$FleetNotesTableCreateCompanionBuilder = FleetNotesCompanion Function({
  Value<int> id,
  required String vehicleId,
  required String vehicleName,
  required String note,
  required DateTime createdAt,
});
typedef $$FleetNotesTableUpdateCompanionBuilder = FleetNotesCompanion Function({
  Value<int> id,
  Value<String> vehicleId,
  Value<String> vehicleName,
  Value<String> note,
  Value<DateTime> createdAt,
});

class $$FleetNotesTableFilterComposer
    extends Composer<_$FleetNotesDatabase, $FleetNotesTable> {
  $$FleetNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vehicleId => $composableBuilder(
      column: $table.vehicleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vehicleName => $composableBuilder(
      column: $table.vehicleName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$FleetNotesTableOrderingComposer
    extends Composer<_$FleetNotesDatabase, $FleetNotesTable> {
  $$FleetNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vehicleId => $composableBuilder(
      column: $table.vehicleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vehicleName => $composableBuilder(
      column: $table.vehicleName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$FleetNotesTableAnnotationComposer
    extends Composer<_$FleetNotesDatabase, $FleetNotesTable> {
  $$FleetNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get vehicleId =>
      $composableBuilder(column: $table.vehicleId, builder: (column) => column);

  GeneratedColumn<String> get vehicleName => $composableBuilder(
      column: $table.vehicleName, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FleetNotesTableTableManager extends RootTableManager<
    _$FleetNotesDatabase,
    $FleetNotesTable,
    FleetNote,
    $$FleetNotesTableFilterComposer,
    $$FleetNotesTableOrderingComposer,
    $$FleetNotesTableAnnotationComposer,
    $$FleetNotesTableCreateCompanionBuilder,
    $$FleetNotesTableUpdateCompanionBuilder,
    (
      FleetNote,
      BaseReferences<_$FleetNotesDatabase, $FleetNotesTable, FleetNote>
    ),
    FleetNote,
    PrefetchHooks Function()> {
  $$FleetNotesTableTableManager(_$FleetNotesDatabase db, $FleetNotesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FleetNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FleetNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FleetNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> vehicleId = const Value.absent(),
            Value<String> vehicleName = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              FleetNotesCompanion(
            id: id,
            vehicleId: vehicleId,
            vehicleName: vehicleName,
            note: note,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String vehicleId,
            required String vehicleName,
            required String note,
            required DateTime createdAt,
          }) =>
              FleetNotesCompanion.insert(
            id: id,
            vehicleId: vehicleId,
            vehicleName: vehicleName,
            note: note,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FleetNotesTableProcessedTableManager = ProcessedTableManager<
    _$FleetNotesDatabase,
    $FleetNotesTable,
    FleetNote,
    $$FleetNotesTableFilterComposer,
    $$FleetNotesTableOrderingComposer,
    $$FleetNotesTableAnnotationComposer,
    $$FleetNotesTableCreateCompanionBuilder,
    $$FleetNotesTableUpdateCompanionBuilder,
    (
      FleetNote,
      BaseReferences<_$FleetNotesDatabase, $FleetNotesTable, FleetNote>
    ),
    FleetNote,
    PrefetchHooks Function()>;

class $FleetNotesDatabaseManager {
  final _$FleetNotesDatabase _db;
  $FleetNotesDatabaseManager(this._db);
  $$FleetNotesTableTableManager get fleetNotes =>
      $$FleetNotesTableTableManager(_db, _db.fleetNotes);
}
