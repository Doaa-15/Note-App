import 'package:flutter/material.dart';
import 'package:node_app/node_class.dart';
import 'package:node_app/note_dao.dart';

import 'package:node_app/core/theme/color.dart';

class NoteAppBody extends StatefulWidget {
  final NoteDao? noteDao;
  const NoteAppBody({super.key, required this.noteDao});

  @override
  State<NoteAppBody> createState() => _NoteAppBodyState();
}

class _NoteAppBodyState extends State<NoteAppBody> {
  @override
  Widget build(BuildContext context) {
  if (widget.noteDao == null) {
    return const SizedBox(); 
  }
    return FutureBuilder<List<Note>>(
    future: widget.noteDao!.getAllNotes(),
    builder: (context, snapshot) {
    
      if (snapshot.connectionState != ConnectionState.done) {
        return const SizedBox();
      }
      if (snapshot.hasError) {
        return const Center(child: Text("Error loading notes"));
      }
      final notes = snapshot.data ?? [];
      if (notes.isEmpty) {
        return const Center(child: Text("No Notes Yet"));
      }
        return ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return Card(
              color: ColorApp.third,
              child: ListTile(
                leading: Icon(Icons.location_pin),
                title: Text(note.title),
                subtitle: Text(note.location ?? "No location"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        final notecontroller = TextEditingController(text: note.title);
                        final locationController =TextEditingController(text: note.location);
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Edit Note"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(controller: notecontroller),
                                TextField(controller: locationController),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  await widget.noteDao!.updateNote(Note(
                                      id: note.id,
                                      title: notecontroller.text,
                                      location: locationController.text));
                                  Navigator.pop(context);
                                  setState(() {});
                                },
                                child: Text("Update"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await widget.noteDao!.deleteNote(note);
                        setState(() {});
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
