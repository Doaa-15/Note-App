import 'package:floor/floor.dart';
import 'package:node_app/node_class.dart';

@dao
abstract class NoteDao {
  @Query('SELECT * FROM Note')
  Future<List<Note>> getAllNotes();

  @insert
  Future<void> insertNote(Note note);

  @update
  Future<void> updateNote(Note note);

  @delete
  Future<void> deleteNote(Note note);

  @Query('DELETE FROM Note')
  Future<void> deleteAllNotes();
}