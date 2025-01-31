import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart'; // Import for PlatformException
import 'package:marquee/marquee.dart'; // Import the marquee package
import 'music_player_page.dart'; // Import the MusicPlayerPage
import 'package:just_audio/just_audio.dart'; // Import just_audio for audio playback

class FolderListPage extends StatefulWidget {
  @override
  _FolderListPageState createState() => _FolderListPageState();
}

class _FolderListPageState extends State<FolderListPage> {
  List<String> _audioFolders = []; // To store audio folders
  int _selectedIndex = 0; // To track the selected menu item
  String _currentSongName = "No song playing"; // Placeholder for current song name
  final AudioPlayer _audioPlayer = AudioPlayer(); // Create an instance of AudioPlayer
  bool _isPlaying = false; // Track whether the audio is playing

  @override
  void initState() {
    super.initState();
    _requestPermissions(); // Request permissions on init
    _fetchAudioFolders(); // Fetch audio folders on init
  }

  // Request storage permissions
  Future<void> _requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
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

    // Show a dialog with the list of songs
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
                    // Set the current song name and play it in the bottom player
                    setState(() {
                      _currentSongName = songs[index].split('/').last; // Update current song name
                      _playSong(songs[index]); // Play the song
                    });
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

  // Function to play the selected song in the bottom player
  void _playSong(String path) async {
    try {
      await _audioPlayer.setFilePath(path); // Set the file path for the audio player
      _audioPlayer.play(); // Play the audio
      setState(() {
        _isPlaying = true; // Update the playing status
      });
    } catch (e) {
      print('Error playing song: $e'); // Handle any errors
    }
  }

  // Function to handle menu item selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Folders'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Implement settings functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView( // Wrap the Column in a SingleChildScrollView
        child: Column(
          children: [
            // Menu Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () => _onItemTapped(0),
                  child: Text('All Songs'),
                ),
                TextButton(
                  onPressed: () => _onItemTapped(1),
                  child: Text('Folders'),
                ),
                TextButton(
                  onPressed: () => _onItemTapped(2),
                  child: Text('Favorites'),
                ),
              ],
            ),
            // Content based on selected menu item
            _selectedIndex == 0
                ? ListView.builder(
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
                  )
                : Center(child: Text('Content for ${_selectedIndex == 1 ? "Folders" : "Favorites"}')),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0), // Add margin to the left and right
          height: 60.0, // Set a fixed height for the bottom bar
          child: BottomAppBar(
            child: Row(
              children: [
                Expanded(
                  flex: 7, // 70% width for the song name
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to MusicPlayerPage when the song name is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MusicPlayerPage(songPath: _currentSongName), // Pass the current song path
                        ),
                      );
                    },
                    child: Marquee(
                      text: _currentSongName,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Adjust font size
                      scrollAxis: Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      blankSpace: 20.0,
                      velocity: 100.0,
                      pauseAfterRound: Duration(seconds: 1),
                      accelerationDuration: Duration(seconds: 1),
                      accelerationCurve: Curves.linear,
                      decelerationDuration: Duration(milliseconds: 500),
                      decelerationCurve: Curves.easeOut,
                    ),
                  ),
                ),
                // Player controls section
                SizedBox(
                  width: 145, // Fixed width for the player controls
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start, // Align buttons to the start
                    children: [
                      IconButton(
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow), // Change icon based on playing status
                        padding: EdgeInsets.zero, // Remove padding entirely
                        constraints: BoxConstraints(), // Remove additional constraints
                        onPressed: () {
                          if (_isPlaying) {
                            _audioPlayer.pause(); // Pause the audio
                          } else {
                            _audioPlayer.play(); // Play the audio
                          }
                          setState(() {
                            _isPlaying = !_isPlaying; // Toggle playing status
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.skip_next),
                        padding: EdgeInsets.zero, // Remove padding entirely
                        constraints: BoxConstraints(), // Remove additional constraints
                        onPressed: () {
                          // Implement next song functionality
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.list),
                        padding: EdgeInsets.zero, // Remove padding entirely
                        onPressed: () {
                          // Show current playlist
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 