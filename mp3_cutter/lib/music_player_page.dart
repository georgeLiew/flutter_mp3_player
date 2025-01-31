import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async'; // Add this import for StreamController
import 'package:path_provider/path_provider.dart'; // Add this import
import 'dart:io'; // Add this import for File
import 'folder_list_page.dart'; // Import the new folder list page

class MusicPlayerPage extends StatefulWidget {
  const MusicPlayerPage({super.key});

  @override
  MusicPlayerPageState createState() => MusicPlayerPageState();
}

class MusicPlayerPageState extends State<MusicPlayerPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  double _volume = 0.5; // Default volume
  bool _isPlaying = false;
  String? _currentSongTitle;
  late StreamSubscription<Duration> _positionSubscription; // For tracking position
  late RecorderController _recorderController; // Add this line
  List<String> _playlist = []; // To store the playlist
  List<String> _audioFolders = []; // To store audio folders

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _audioPlayer.setVolume(_volume); // Set initial volume
    _recorderController = RecorderController(); // Initialize the recorder controller
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      setState(() {
        // Update the UI with the current position
      });
    });
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });
    _fetchAudioFolders(); // Fetch audio folders on init
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _recorderController.dispose(); // Dispose of the recorder controller
    _positionSubscription.cancel(); // Cancel the subscription
    super.dispose();
  }

  // Request storage permissions
  Future<void> _requestPermissions() async {
    await Permission.storage.request();
  }

  // Function to pick and load audio file
  Future<void> _pickAndPlayAudio() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result != null) {
        // Load and play the selected audio file
        await _audioPlayer.setFilePath(result.files.single.path!);
        if (mounted) {
          setState(() {
            _currentSongTitle = result.files.single.name;
            _isPlaying = true;
          });
        }
        _audioPlayer.play();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading audio file: $e')),
        );
      }
    }
  }

  // Updated toggle play/pause function
  void _togglePlayPause() async {
    if (_audioPlayer.audioSource == null) {
      await _pickAndPlayAudio();
    } else {
      if (_isPlaying) {
        _audioPlayer.pause();
      } else {
        _audioPlayer.play();
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    }
  }

  // Function to seek audio
  void _seekAudio(double value) {
    final newPosition = Duration(milliseconds: (value * _audioPlayer.duration!.inMilliseconds).toInt());
    _audioPlayer.seek(newPosition);
  }

  // Function to change volume
  void _changeVolume(double value) {
    setState(() {
      _volume = value;
      _audioPlayer.setVolume(_volume);
    });
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

  // Function to add song to playlist
  void _addToPlaylist(String songPath) {
    if (!_playlist.contains(songPath)) {
      setState(() {
        _playlist.add(songPath);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to playlist: ${songPath.split('/').last}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Player'),
        actions: [
          IconButton(
            icon: Icon(Icons.file_open),
            onPressed: _pickAndPlayAudio,
          ),
          IconButton(
            icon: Icon(Icons.folder),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FolderListPage()), // Navigate to FolderListPage
              );
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Album art and song title
          Container(
            height: 200,
            width: 200,
            color: Colors.grey,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Album Art'),
                  if (_currentSongTitle != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _currentSongTitle!,
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          // Play/Pause Button with updated icon
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: _togglePlayPause,
            iconSize: 64,
          ),
          SizedBox(height: 20),
          // Time display with padding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Add horizontal padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_audioPlayer.position),
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  _audioPlayer.duration != null
                      ? _formatDuration(_audioPlayer.duration!)
                      : '0:00', // Default to '0:00' if duration is null
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          // Seek Bar
          Slider(
            value: (_audioPlayer.position.inMilliseconds.toDouble() /
                (_audioPlayer.duration?.inMilliseconds.toDouble() ?? 1)), // Prevent division by zero
            onChanged: _seekAudio,
            min: 0.0,
            max: 1.0,
          ),
          SizedBox(height: 20),
          // Waveform Visualization
          AudioWaveforms(
            size: Size(MediaQuery.of(context).size.width, 100),
            recorderController: _recorderController, // Pass the recorder controller
            waveStyle: WaveStyle(
              showMiddleLine: false,
              extendWaveform: true,
            ),
          ),
          // Display audio folders
          Expanded(
            child: ListView.builder(
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
          ),
        ],
      ),
    );
  }

  // Function to format duration to mm:ss
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
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
                    _addToPlaylist(songs[index]); // Add song to playlist
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
} 