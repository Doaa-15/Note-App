import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:node_app/node_class.dart';
import 'package:node_app/note_dao.dart';
import 'package:node_app/core/theme/color.dart';
import 'package:url_launcher/url_launcher.dart';

class NoteAppBody extends StatefulWidget {
  final NoteDao? noteDao;
  const NoteAppBody({super.key, required this.noteDao});

  @override
  State<NoteAppBody> createState() => _NoteAppBodyState();
}

class _NoteAppBodyState extends State<NoteAppBody> {
  // ===== دوال الموقع =====
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<String> getAddressFromCoordinates(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";
      }
    } catch (e) {
      print("Error in reverse geocoding: $e");
    }
    return "Address not available";
  }
Future<void> _openMap(String address) async {
  if (address.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No location available")),
    );
    return;
  }

  final query = Uri.encodeComponent(address);

  // نجرب نفتح Google Maps App الأول
  final Uri googleMapsApp = Uri.parse("geo:0,0?q=$query");

  // ولو ما اشتغلش نفتح في المتصفح
  final Uri googleMapsWeb =
      Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");

  try {
    if (await canLaunchUrl(googleMapsApp)) {
      await launchUrl(googleMapsApp);
    } else {
      await launchUrl(googleMapsWeb, mode: LaunchMode.externalApplication);
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Could not open the map")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    if (widget.noteDao == null) return const SizedBox();

    return FutureBuilder<List<Note>>(
      future: widget.noteDao!.getAllNotes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error"));
        }

        final notes = snapshot.data ?? [];

        if (notes.isEmpty) {
          return const Center(child: Text("No Notes"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return Card(
              color: ColorApp.third,
              child: ListTile(
              leading: IconButton(
  icon: Icon(Icons.location_pin, color: ColorApp.primary),
  onPressed: () {
    final location = note.location ?? "";
    _openMap(location);
  },
),

                title: Text(note.title),
                subtitle: Text(note.location ?? "No location"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // زر التعديل
                    IconButton(
                      icon: const Icon(Icons.edit,color: ColorApp.primary),
                      onPressed: () async {
                        final titleController =
                            TextEditingController(text: note.title);
                        final locationController =
                            TextEditingController(text: note.location);

                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Edit Note"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // العنوان يمكن تعديله
                                TextField(
                                  controller: titleController,
                                  decoration: InputDecoration(
                                    labelText: 'Title',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // اللوكيشن لا يمكن تعديله يدويًا
                                TextField(
                                  controller: locationController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: 'Location',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.my_location),
                                  label: const Text("Use Current Location"),
                                  onPressed: () async {
                                    final pos = await getCurrentLocation();
                                    if (pos != null) {
                                      final address =
                                          await getAddressFromCoordinates(pos);
                                      setState(() {
                                        locationController.text = address;
                                      });
                                    } else {
                                      setState(() {
                                        locationController.text =
                                            "Location not available";
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  await widget.noteDao!.updateNote(
                                    Note(
                                      id: note.id,
                                      title: titleController.text,
                                      location: locationController.text,
                                    ),
                                  );
                                  Navigator.pop(context);
                                  setState(() {});
                                },
                                child: const Text(
                                  "Update",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    // زر الحذف
              
  IconButton(
  icon: const Icon(Icons.delete,color: ColorApp.primary),
  onPressed: () async {
    // خزن النوت قبل الحذف
    final deletedNote = note;

    // احذف النوت
    await widget.noteDao!.deleteNote(note);
    setState(() {}); // تحديث الشاشة

    // عرض Snackbar مع Undo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Note deleted"),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.yellow,
          onPressed: () async {
            // استرجاع النوت المحذوفة
            await widget.noteDao!.insertNote(deletedNote);
            setState(() {}); // تحديث الشاشة
          },
        ),
      ),
    );
  },
),

                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
