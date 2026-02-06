import 'package:flutter/material.dart';
import 'package:node_app/main.dart';
import 'package:node_app/screens/note_app_screen.dart';

class NoteApp extends StatelessWidget {
  const NoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NoteAppScreen(noteDao: noteDao,),
    );
  }
}