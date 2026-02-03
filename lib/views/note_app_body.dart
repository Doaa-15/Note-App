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
        return const Center(child: Text("Error"));
      }
      final notes = snapshot.data ?? [];
      if (notes.isEmpty) {
        return const Center(child: Text("No Notes"));
      }
        return ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: notes.length,
          itemBuilder: (context, index) {
           
            return Card(
              color: ColorApp.third,
              child: ListTile(
                leading: Icon(Icons.location_pin),
                title: Text(notes[index].title),
                subtitle: Text(notes[index].location ?? "No location"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        final notecontroller = TextEditingController(text: notes[index].title);
                        final locationController =TextEditingController(text: notes[index].location);
                        await showDialog(
                          
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Edit Note"),
                            content: Column(
                              spacing: 10,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Note',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)
                                    )
                                  ),
                                  controller: notecontroller),

                                TextField(decoration: InputDecoration(
                                   labelText: 'Location',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)
                                    )
                                  ),
                                  controller: locationController),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  await widget.noteDao!.updateNote(Note(
                                      id: notes[index].id,
                                      title: notecontroller.text,
                                      location: locationController.text));
                                  Navigator.pop(context);
                                  setState(() {});
                                },
                                child: Text("Update",style: TextStyle(color: Colors.black),),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await widget.noteDao!.deleteNote(notes[index]);
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
