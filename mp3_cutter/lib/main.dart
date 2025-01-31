import 'package:flutter/material.dart';
import 'music_player_page.dart'; // Import the music player page

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MusicPlayerPage(), // Set the home to MusicPlayerPage
    );
  }
}
