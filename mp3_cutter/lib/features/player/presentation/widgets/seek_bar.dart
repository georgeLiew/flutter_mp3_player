import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/audio_player_bloc.dart';
import '../../bloc/audio_player_event.dart';
import '../../bloc/audio_player_state.dart';

class SeekBar extends StatelessWidget {
  const SeekBar({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        return Column(
          children: [
            Slider(
              value: state.position.inMilliseconds.toDouble(),
              min: 0,
              max: state.duration.inMilliseconds.toDouble(),
              onChanged: (value) {
                final position = Duration(milliseconds: value.toInt());
                context.read<AudioPlayerBloc>().add(SeekAudio(position));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(state.position)),
                  Text(_formatDuration(state.duration)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
} 