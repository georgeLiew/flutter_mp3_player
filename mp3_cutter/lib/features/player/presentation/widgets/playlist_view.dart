import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/audio_player_bloc.dart';
import '../../bloc/audio_player_event.dart';
import '../../bloc/audio_player_state.dart';

class PlaylistView extends StatelessWidget {
  const PlaylistView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        if (state.playlist.isEmpty) {
          return const Center(
            child: Text('No tracks in playlist'),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: state.playlist.length,
          itemBuilder: (context, index) {
            final track = state.playlist[index];
            final isPlaying = track == state.currentTrack;

            return ListTile(
              leading: Icon(
                isPlaying ? Icons.music_note : Icons.music_note_outlined,
                color: isPlaying ? Theme.of(context).primaryColor : null,
              ),
              title: Text(
                track.split('/').last,
                style: TextStyle(
                  color: isPlaying ? Theme.of(context).primaryColor : null,
                  fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () {
                context.read<AudioPlayerBloc>().add(PlayAudio(track));
              },
            );
          },
        );
      },
    );
  }
} 