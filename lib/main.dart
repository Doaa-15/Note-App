import 'package:flutter/material.dart';
import 'package:node_app/note_app.dart';
import 'package:node_app/app_database.dart';
import 'package:node_app/note_dao.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:flutter/services.dart';

late final AppDatabase database;
late final NoteDao noteDao;

Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();

  await initDatabase();

  runApp(const NoteApp());
}

Future<void> copyDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final path = join(dir.path, 'notes.db');

  if (File(path).existsSync()) return;

  ByteData data = await rootBundle.load('assets/database/notes.db');
  List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

  await File(path).writeAsBytes(bytes);
  print("Database copied to $path");
}

Future<void> initDatabase() async {
  await copyDatabase();

  final dir = await getApplicationDocumentsDirectory();
  final dbPath = join(dir.path, 'notes.db');

  database = await $FloorAppDatabase.databaseBuilder(dbPath).build();
  noteDao = database.noteDao; 
}
