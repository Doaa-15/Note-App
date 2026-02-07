class Note {
  final int? id;
  final String title;

  final String? location;
  final double? latitude;
  final double? longitude;

  Note({
    this.id,
    required this.title,
    this.location,
    this.latitude,
    this.longitude, 
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      location: map['location'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}
