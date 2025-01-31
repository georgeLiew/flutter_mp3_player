import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class FolderListPage extends StatefulWidget {
  @override
  _FolderListPageState createState() => _FolderListPageState();
}

class _FolderListPageState extends State<FolderListPage> {
  List<String> _audioFolders = []; // To store audio folders

  @override
  void initState() {
    super.initState();
    _fetchAudioFolders(); // Fetch audio folders on init
  }

  // Function to fetch audio folders
  Future<void> _fetchAudioFolders() async {
    final directory = await getExternalStorageDirectory(); // Get external storage directory
    if (directory != null) {
      final List<FileSystemEntity> entities = directory.listSync(recursive: true);
      for (var entity in entities) {
        if (entity is Directory) {
          final files = entity.listSync();
          for (var file in files) {
            if (file is File && file.path.endsWith('.mp3')) { // Check for audio files
              if (!_audioFolders.contains(entity.path)) {
                _audioFolders.add(entity.path);
              }
            }
          }
        }
      }
      setState(() {}); // Update UI
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