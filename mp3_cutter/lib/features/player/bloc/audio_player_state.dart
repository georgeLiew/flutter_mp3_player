import 'package:equatable/equatable.dart';

enum PlaybackState { initial, playing, paused, loading, error }

class AudioPlayerState extends Equatable {
  final PlaybackState playbackState;
  final Duration position;
  final Duration duration;
  final double volume;
  final String? error;
  final String? currentTrack;
  final List<String> playlist;

  const AudioPlayerState({
    this.playbackState = PlaybackState.initial,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.error,
    this.currentTrack,
    this.playlist = const [],
  });

  AudioPlayerState copyWith({
    PlaybackState? playbackState,
    Duration? position,
    Duration? duration,
    double? volume,
    String? error,
    String? currentTrack,
    List<String>? playlist,
  }) {
    return AudioPlayerState(
      playbackState: playbackState ?? this.playbackState,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      error: error ?? this.error,
      currentTrack: currentTrack ?? this.currentTrack,
      playlist: playlist ?? this.playlist,
    );
  }

  @override
  List<Object?> get props => [
        playbackState,
        position,
        duration,
        volume,
        error,
        currentTrack,
        playlist,
      ];
} 