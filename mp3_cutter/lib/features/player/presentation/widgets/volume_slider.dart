import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/audio_player_bloc.dart';
import '../../bloc/audio_player_event.dart';
import '../../bloc/audio_player_state.dart';

class VolumeSlider extends StatelessWidget {
  const VolumeSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        return Row(
          children: [
            const Icon(Icons.volume_down),
            Expanded(
              child: Slider(
                value: state.volume,
                min: 0.0,
                max: 1.0,
                onChanged: (value) {
                  context.read<AudioPlayerBloc>().add(SetVolume(value));
                },
              ),
            ),
            const Icon(Icons.volume_up),
          ],
        );
      },
    );
  }
} 