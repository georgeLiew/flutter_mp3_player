import 'package:flutter/material.dart';
import 'folder_list_page.dart'; // Import the FolderListPage

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
      home: FolderListPage(), // Set FolderListPage as the home page
    );
  }
}
