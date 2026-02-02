import 'package:flutter/material.dart';
import 'package:node_app/screens/note_app_screen.dart';

class NoteApp extends StatelessWidget {
  const NoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NoteAppScreen(),
    );
  }
}