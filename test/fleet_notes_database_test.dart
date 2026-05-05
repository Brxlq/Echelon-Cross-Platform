import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yummy/local/fleet_notes_database.dart';

void main() {
  test('fleet notes CRUD works with drift local database', () async {
    final db = FleetNotesDatabase(NativeDatabase.memory());

    await db.addNote(vehicleId: 'v1', vehicleName: 'Tesla Model 3', note: 'Fast pickup');
    var notes = await db.fetchRecentNotes();
    expect(notes.length, 1);
    expect(notes.first.note, 'Fast pickup');

    await db.deleteNote(notes.first.id);
    notes = await db.fetchRecentNotes();
    expect(notes, isEmpty);

    await db.close();
  });
}
