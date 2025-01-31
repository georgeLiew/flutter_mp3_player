import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class MusicPlayerPage extends StatefulWidget {
  const MusicPlayerPage({super.key});

  @override
  _MusicPlayerPageState createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  double _volume = 0.5; // Default volume
  bool _isPlaying = false;
  String? _currentSongTitle;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
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
        setState(() {
          _currentSongTitle = result.files.single.name;
          _isPlaying = true;
        });
        _audioPlayer.play();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading audio file: $e')),
      );
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
    // Implement seek functionality
  }

  // Function to change volume
  void _changeVolume(double value) {
    setState(() {
      _volume = value;
      _audioPlayer.setVolume(_volume);
    });
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
          // Seek Bar
          Slider(
            value: 0.0, // Update with current position
            onChanged: _seekAudio,
            min: 0.0,
            max: 1.0, // Update with audio duration
          ),
          SizedBox(height: 20),
          // Volume Control
          Slider(
            value: _volume,
            onChanged: _changeVolume,
            min: 0.0,
            max: 1.0,
          ),
          SizedBox(height: 20),
          // Waveform Visualization
          AudioWaveforms(
            size: Size(MediaQuery.of(context).size.width, 100),
            recorderController: RecorderController(),
            waveStyle: WaveStyle(
              showMiddleLine: false,
              extendWaveform: true,
            ),
          ),
        ],
      ),
    );
  }
} 