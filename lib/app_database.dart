import 'dart:async';
import 'package:floor/floor.dart';

import 'package:node_app/node_class.dart';

import 'note_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'app_database.g.dart'; // Generated code

@Database(version: 1, entities: [Note])
abstract class AppDatabase extends FloorDatabase {
  NoteDao get noteDao;
}