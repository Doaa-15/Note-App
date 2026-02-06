
import 'package:floor/floor.dart';




@entity
class Note {
  @primaryKey
  final int? id;
  final String title;
  final String? location;

  Note({this.id, required this.title, this.location});
}