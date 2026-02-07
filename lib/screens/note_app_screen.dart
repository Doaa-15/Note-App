import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:node_app/node_class.dart';
import 'package:node_app/note_dao.dart';
import 'package:node_app/views/note_app_body.dart';
import 'package:node_app/core/theme/color.dart';
import 'package:shake/shake.dart';

class NoteAppScreen extends StatefulWidget {
  final NoteDao noteDao;
  const NoteAppScreen({super.key, required this.noteDao});

  @override
  State<NoteAppScreen> createState() => _NoteAppScreenState();
}

class _NoteAppScreenState extends State<NoteAppScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final noteController = TextEditingController();
  final locationController = TextEditingController();

  bool useCurrentLocation = false;
ShakeDetector? detector;
@override
void initState() {
  super.initState();

  detector = ShakeDetector.autoStart(
    onPhoneShake: (ShakeEvent event) async {
      if (widget.noteDao != null) {
        await widget.noteDao.deleteAllNotes();
        if (mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("All notes deleted due to shake!"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    },
    shakeThresholdGravity: 2.7,
  );
}


  @override
  void dispose() {
      detector?.stopListening();
    noteController.dispose();
    locationController.dispose();
    super.dispose();
  }


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

  Future<void> checkLocationPermissionOnStart() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services')),
      );
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please allow location permission from settings')),
      );
      await Geolocator.openAppSettings();
    }
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


  Future<void> openAddNoteSheet() async {
    final result = await showModalBottomSheet(
      backgroundColor: ColorApp.second,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: SizedBox(
              height: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
   
                  TextFormField(
                    controller: noteController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: "Enter note",
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? "Please enter note" : null,
                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    controller: locationController,
                    enabled: !useCurrentLocation,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: "Enter location",
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Checkbox(
                        value: useCurrentLocation,
                        onChanged: (value) async {
                          if (value == null) return;
                          setState(() {
                            useCurrentLocation = value;
                            locationController.text =
                                useCurrentLocation ? "Getting location..." : "";
                          });

                          if (useCurrentLocation) {
                            try {
                              await checkLocationPermissionOnStart();
                              final pos = await getCurrentLocation();
                              if (pos != null) {
                                final address = await getAddressFromCoordinates(pos);
                                setState(() {
                                  locationController.text = address;
                                });
                              } else {
                                setState(() {
                                  locationController.text = "Location not available";
                                });
                              }
                            } catch (e) {
                              setState(() {
                                locationController.text = "Error getting location";
                              });
                            }
                          }
                        },
                      ),
                      const Text("Current location"),
                    ],
                  ),
                  const SizedBox(height: 10),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorApp.primary,
                    ),
                    onPressed: () async {
                      if (formKey.currentState?.validate() ?? false) {
                        final title = noteController.text.trim();
                        final location = locationController.text.trim();


                        if (widget.noteDao != null) {
                          await widget.noteDao.insertNote(
                            Note(
                              title: title.isNotEmpty ? title : "No Title",
                              location: location.isNotEmpty ? location : "No Location",
                            ),
                          );
                        }

                        // تنظيف الحقول بعد الإضافة
                        noteController.clear();
                        locationController.clear();
                        useCurrentLocation = false;

                        Navigator.pop(context, true);

                        // عرض Snackbar آمن
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Note added successfully"),
                            backgroundColor: ColorApp.primary,
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: Text(
                      "Add",
                      style: TextStyle(color: ColorApp.second),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (result == true) setState(() {}); // إعادة تحميل النوتس
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.second,
      appBar: AppBar(
        title: Text("My Notes", style: TextStyle(color: ColorApp.second)),
        backgroundColor: ColorApp.primary,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorApp.primary,
        onPressed: openAddNoteSheet,
        child: Icon(Icons.add, color: ColorApp.second),
      ),
      body: NoteAppBody(noteDao: widget.noteDao),
    );
  }
}
