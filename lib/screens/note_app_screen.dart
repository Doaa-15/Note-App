import 'package:flutter/material.dart';
import 'package:node_app/app_database.dart';
import 'package:node_app/node_class.dart';
import 'package:node_app/note_dao.dart';
import 'package:node_app/views/note_app_body.dart';
import 'package:node_app/core/theme/color.dart';

class NoteAppScreen extends StatefulWidget {
  const NoteAppScreen({super.key});

  @override
  State<NoteAppScreen> createState() => _NoteAppScreenState();
}

class _NoteAppScreenState extends State<NoteAppScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final noteController = TextEditingController();
  final locationController = TextEditingController();

  AppDatabase? database;
  NoteDao? noteDao;

  @override
  void initState() {
    super.initState();
    initDb();
  }

  Future<void> initDb() async {
    database = await $FloorAppDatabase
        .databaseBuilder('app_database.db')
        .build();
    noteDao = database!.noteDao;
    
  }

  @override
  void dispose() {
    noteController.dispose();
    locationController.dispose();
    super.dispose();
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
        onPressed: () {
          showModalBottomSheet(
            backgroundColor: ColorApp.second,
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: formKey,
                  child: Container(
                    height: 500,
                    child: Column(
                      spacing: 20,
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
                              value!.isEmpty ? "Please enter note" : null,
                        ),
                     
                        TextFormField(
                          controller: locationController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            hintText: "Enter location",
                          ),
                        ),
                                     
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorApp.primary,
                          ),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              await noteDao!.insertNote(Note(
                                  title: noteController.text,
                                  location: locationController.text.isEmpty
                                      ? null
                                      : locationController.text));
                              noteController.clear();
                              locationController.clear();
                              Navigator.pop(context);
                              setState(() {});
                            }
                          },
                          child: Text("Add", style: TextStyle(color: ColorApp.second)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: Icon(Icons.add, color: ColorApp.second),
      ),
      body: NoteAppBody(noteDao: noteDao),
    );
  }
}
