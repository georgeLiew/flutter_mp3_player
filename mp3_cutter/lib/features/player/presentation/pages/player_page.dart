import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/audio_player_bloc.dart';
import '../../bloc/audio_player_event.dart';
import '../../services/file_picker_service.dart';
import '../widgets/playlist_view.dart';

class PlayerPage extends StatelessWidget {
  final FilePickerService _filePickerService = FilePickerService();

  PlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AudioPlayerBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MP3 Player'),
        ),
        body: Column(
          children: [
            const Expanded(
              child: PlaylistView(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final audioPath = await _filePickerService.pickAudioFile();
            if (audioPath != null) {
              if (context.mounted) {
                context.read<AudioPlayerBloc>().add(AddToPlaylist(audioPath));
                context.read<AudioPlayerBloc>().add(PlayAudio(audioPath));
              }
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
} 