import 'package:floor/floor.dart';

@entity // تأكدي من وجود هذه الكلمة
class Note {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  
  final String title;
  final String location;
  final double? latitude;
  final double? longitude;

  // يجب أن يكون الـ constructor بنفس اسم الكلاس
  Note({
    this.id, 
    required this.title, 
    required this.location, 
    this.latitude, 
    this.longitude
  });
}