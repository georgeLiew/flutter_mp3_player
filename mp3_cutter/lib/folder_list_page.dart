import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart'; // Import for PlatformException

class FolderListPage extends StatefulWidget {
  @override
  _FolderListPageState createState() => _FolderListPageState();
}

class _FolderListPageState extends State<FolderListPage> {
  List<String> _audioFolders = []; // To store audio folders

  @override
  void initState() {
    super.initState();
    _requestPermissions(); // Request permissions on init
    _fetchAudioFolders(); // Fetch audio folders on init
  }

  // Request storage permissions
  Future<void> _requestPermissions() async {
    await Permission.storage.request();
  }

  // Function to fetch audio folders from specific directories
  Future<void> _fetchAudioFolders() async {
    // Access the Music and Download directories
    final musicDirectory = Directory('/storage/emulated/0/Music');
    final downloadsDirectory = Directory('/storage/emulated/0/Download');

    // Check if the directories exist and fetch audio files
    if (await musicDirectory.exists()) {
      _fetchFoldersFromDirectory(musicDirectory);
    } else {
      print('Music directory does not exist.'); // Debug statement
    }

    if (await downloadsDirectory.exists()) {
      _fetchFoldersFromDirectory(downloadsDirectory);
    } else {
      print('Downloads directory does not exist.'); // Debug statement
    }

    setState(() {}); // Update UI
  }

  // Helper function to fetch folders from a given directory
  void _fetchFoldersFromDirectory(Directory directory) {
    try {
      final List<FileSystemEntity> entities = directory.listSync(recursive: true);
      for (var entity in entities) {
        if (entity is Directory) {
          final files = entity.listSync();
          for (var file in files) {
            if (file is File && file.path.endsWith('.mp3')) { // Check for audio files
              if (!_audioFolders.contains(entity.path)) {
                _audioFolders.add(entity.path);
                print('Found audio folder: ${entity.path}'); // Debug statement
              }
            }
          }
        }
      }
      print('Total audio folders found: ${_audioFolders.length}'); // Debug statement
    } catch (e) {
      print('Error accessing directory: ${directory.path} - $e'); // Handle the error
    }
  }

  // Function to show songs in a selected folder
  void _showSongsInFolder(String folderPath) {
    final directory = Directory(folderPath);
    final List<FileSystemEntity> files = directory.listSync();
    List<String> songs = files
        .where((file) => file is File && file.path.endsWith('.mp3'))
        .map((file) => file.path)
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Songs in ${folderPath.split('/').last}'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(songs[index].split('/').last),
                  onTap: () {
                    // Add song to playlist or play it
                    Navigator.of(context).pop(); // Close dialog
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Folders'),
      ),
      body: ListView.builder(
        itemCount: _audioFolders.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_audioFolders[index].split('/').last),
            onTap: () {
              // Show songs in the selected folder
              _showSongsInFolder(_audioFolders[index]);
            },
          );
        },
      ),
    );
  }
} 