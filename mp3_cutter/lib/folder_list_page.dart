import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart'; // Import for PlatformException
import 'package:marquee/marquee.dart'; // Import the marquee package
import 'music_player_page.dart'; // Import the MusicPlayerPage
import 'package:just_audio/just_audio.dart'; // Import just_audio for audio playback
import 'package:flutter_media_store/flutter_media_store_platform_interface.dart'; // Import flutter_media_store_platform_interface
import 'package:flutter_logs/flutter_logs.dart'; // Import flutter_logs

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
  }

  // Request storage permissions
  Future<void> _requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  // Function to fetch audio folders using MediaStore API
  Future<void> _fetchAudioFolders() async {
    // Check for storage permission
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    try {
      await FlutterLogs.logInfo("FolderListPage", "fetchAudioFolders", "Attempting to pick audio files..."); // Log before picking files
      // Use the pickFile method to allow users to select audio files
      await FlutterMediaStorePlatformInterface.instance.pickFile(
        multipleSelect: true, // Allow multiple file selection
        onFilesPicked: (uris) async {
          await FlutterLogs.logInfo("FolderListPage", "fetchAudioFolders", "Files picked: $uris"); // Log picked URIs
          for (var uri in uris) {
            // Ensure the URI is a valid string and not already in the list
            if (uri is String) {
              if (!_audioFolders.contains(uri)) {
                _audioFolders.add(uri); // Add the picked audio file to the list
                await FlutterLogs.logInfo("FolderListPage", "fetchAudioFolders", "Added audio file: $uri"); // Log added audio file
              } else {
                await FlutterLogs.logInfo("FolderListPage", "fetchAudioFolders", "File already in list: $uri"); // Use logInfo instead of logWarning
              }
            } else {
              await FlutterLogs.logError("FolderListPage", "fetchAudioFolders", "Invalid URI type: $uri"); // Log invalid type
            }
          }
          setState(() {}); // Update UI after adding files
          await FlutterLogs.logInfo("FolderListPage", "fetchAudioFolders", "Updated UI with new files"); // Log UI update
        },
        onError: (errorMessage) async {
          await FlutterLogs.logError("FolderListPage", "fetchAudioFolders", "Error picking files: $errorMessage");
        },
      );
    } catch (e) {
      await FlutterLogs.logError("FolderListPage", "fetchAudioFolders", "Error fetching audio files: $e"); // Log any errors
    }
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
      await FlutterLogs.logError("FolderListPage", "playSong", "Error playing song: $e"); // Log any errors
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
      body: Column(
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
                child: Text('Playlist'),
              ),
              TextButton(
                onPressed: () => _onItemTapped(2),
                child: Text('Favorites'),
              ),
            ],
          ),
          // Content based on selected menu item
          Expanded(
            child: _selectedIndex == 0
                ? ListView.builder(
                    itemCount: _audioFolders.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_audioFolders[index].split('/').last),
                        onTap: () {
                          // You can implement functionality here if needed
                        },
                      );
                    },
                  )
                : Center(child: Text('Content for ${_selectedIndex == 1 ? "Playlist" : "Favorites"}')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchAudioFolders, // Call _fetchAudioFolders when the plus button is pressed
        child: Icon(Icons.add), // Plus icon
        tooltip: 'Add Audio',
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
                        constraints: BoxConstraints(), // Remove additional constraints
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