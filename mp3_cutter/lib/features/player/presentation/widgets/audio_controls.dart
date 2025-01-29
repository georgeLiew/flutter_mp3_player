import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/audio_player_bloc.dart';
import '../../bloc/audio_player_event.dart';
import '../../bloc/audio_player_state.dart';

class AudioControls extends StatelessWidget {
  const AudioControls({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        final bool isPlaying = state.playbackState == PlaybackState.playing;
        final bool isLoading = state.playbackState == PlaybackState.loading;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous track button
            IconButton(
              icon: const Icon(Icons.skip_previous),
              iconSize: 40,
              onPressed: () {
                // TODO: Implement previous track functionality
              },
            ),
            const SizedBox(width: 16),
            // Play/Pause button
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      iconSize: 48,
                      onPressed: () {
                        if (isPlaying) {
                          context.read<AudioPlayerBloc>().add(PauseAudio());
                        } else {
                          context.read<AudioPlayerBloc>().add(PlayAudio());
                        }
                      },
                    ),
            ),
            const SizedBox(width: 16),
            // Next track button
            IconButton(
              icon: const Icon(Icons.skip_next),
              iconSize: 40,
              onPressed: () {
                // TODO: Implement next track functionality
              },
            ),
          ],
        );
      },
    );
  }
} 