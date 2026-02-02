import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;



@entity
class Note {
  @primaryKey
  final int? id;
  final String title;
  final String? location;

  Note({this.id, required this.title, this.location});
}