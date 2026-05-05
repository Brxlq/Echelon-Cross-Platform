import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'fleet_notes_database.g.dart';

class FleetNotes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get vehicleId => text()();
  TextColumn get vehicleName => text()();
  TextColumn get note => text()();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [FleetNotes])
class FleetNotesDatabase extends _$FleetNotesDatabase {
  FleetNotesDatabase([QueryExecutor? executor])
      : super(
          executor ??
              driftDatabase(
                name: 'fleet_notes_db',
                native: const DriftNativeOptions(),
                web: DriftWebOptions(
                  sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                  driftWorker: Uri.parse('drift_worker.js'),
                ),
              ),
        );

  @override
  int get schemaVersion => 1;

  Future<List<FleetNote>> fetchRecentNotes() async {
    final rows = await (select(
      fleetNotes,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
    return rows;
  }

  Stream<List<FleetNote>> watchRecentNotes() {
    return (select(
      fleetNotes,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch().map(
      (rows) => rows,
    );
  }

  Future<void> addNote({
    required String vehicleId,
    required String vehicleName,
    required String note,
  }) async {
    await into(fleetNotes).insert(
      FleetNotesCompanion.insert(
        vehicleId: vehicleId,
        vehicleName: vehicleName,
        note: note,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> deleteNote(int id) async {
    await (delete(fleetNotes)..where((t) => t.id.equals(id))).go();
  }
}
