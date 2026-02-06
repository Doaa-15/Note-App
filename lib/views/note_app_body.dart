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
    if (widget.noteDao == null) return const SizedBox();

    return FutureBuilder<List<Note>>(
      future: widget.noteDao!.getAllNotes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error loading notes"));
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
                leading: const Icon(Icons.location_pin),
                title: Text(note.title),
                subtitle: Text(note.location ?? "No location"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit button
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final noteController =
                            TextEditingController(text: note.title);

                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Edit Note"),
                            content: TextField(
                              controller: noteController,
                              decoration: InputDecoration(
                                labelText: 'Note',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  await widget.noteDao!.updateNote(
                                    Note(
                                      id: note.id,
                                      title: noteController.text,
                                      location: note.location, // location مش يتعدل
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
                    // Delete button
                    Builder(
                      builder: (scaffoldContext) {
                        return IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            final deletedNote = note;

                            // حذف النوت
                            await widget.noteDao!.deleteNote(note);
                            setState(() {});

                            // SnackBar مع Undo ويختفي تلقائي
                            ScaffoldMessenger.of(scaffoldContext)
                              ..removeCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: const Text("Note deleted"),
                                  duration: const Duration(seconds: 2),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () async {
                                      await widget.noteDao!
                                          .insertNote(deletedNote);
                                      setState(() {});
                                    },
                                  ),
                                ),
                              );
                          },
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
