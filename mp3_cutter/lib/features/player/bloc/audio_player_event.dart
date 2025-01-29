import 'package:equatable/equatable.dart';

abstract class AudioPlayerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PlayAudio extends AudioPlayerEvent {
  final String? audioPath;
  PlayAudio([this.audioPath]);
  
  @override
  List<Object?> get props => [audioPath];
}

class PauseAudio extends AudioPlayerEvent {}

class SeekAudio extends AudioPlayerEvent {
  final Duration position;
  SeekAudio(this.position);
  
  @override
  List<Object> get props => [position];
}

class SetVolume extends AudioPlayerEvent {
  final double volume;
  SetVolume(this.volume);
  
  @override
  List<Object> get props => [volume];
}

class AddToPlaylist extends AudioPlayerEvent {
  final String audioPath;
  AddToPlaylist(this.audioPath);
  
  @override
  List<Object> get props => [audioPath];
} 