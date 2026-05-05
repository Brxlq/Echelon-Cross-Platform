import 'fleet_notes_database.dart';

class FleetNotesRepository {
  FleetNotesRepository._();

  static final FleetNotesRepository instance = FleetNotesRepository._();

  final FleetNotesDatabase _db = FleetNotesDatabase();

  Stream<List<FleetNote>> watchNotes() => _db.watchRecentNotes();

  Future<void> addNote({
    required String vehicleId,
    required String vehicleName,
    required String note,
  }) {
    return _db.addNote(vehicleId: vehicleId, vehicleName: vehicleName, note: note);
  }

  Future<void> deleteNote(int id) => _db.deleteNote(id);
}
