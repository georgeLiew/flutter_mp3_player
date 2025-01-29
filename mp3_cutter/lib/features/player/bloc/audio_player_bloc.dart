import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'audio_player_event.dart';
import 'audio_player_state.dart';

class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final AudioPlayer _audioPlayer;
  
  AudioPlayerBloc() : 
    _audioPlayer = AudioPlayer(),
    super(const AudioPlayerState()) {
    on<PlayAudio>(_onPlayAudio);
    on<PauseAudio>(_onPauseAudio);
    on<SeekAudio>(_onSeekAudio);
    on<SetVolume>(_onSetVolume);
    on<AddToPlaylist>(_onAddToPlaylist);
  }

  Future<void> _onPlayAudio(PlayAudio event, Emitter<AudioPlayerState> emit) async {
    try {
      emit(state.copyWith(playbackState: PlaybackState.loading));
      if (event.audioPath != null) {
        await _audioPlayer.setFilePath(event.audioPath!);
        emit(state.copyWith(currentTrack: event.audioPath));
      }
      await _audioPlayer.play();
    } catch (e) {
      emit(state.copyWith(
        playbackState: PlaybackState.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onPauseAudio(PauseAudio event, Emitter<AudioPlayerState> emit) async {
    await _audioPlayer.pause();
  }

  Future<void> _onSeekAudio(SeekAudio event, Emitter<AudioPlayerState> emit) async {
    await _audioPlayer.seek(event.position);
  }

  Future<void> _onSetVolume(SetVolume event, Emitter<AudioPlayerState> emit) async {
    await _audioPlayer.setVolume(event.volume);
    emit(state.copyWith(volume: event.volume));
  }

  Future<void> _onAddToPlaylist(AddToPlaylist event, Emitter<AudioPlayerState> emit) async {
    final currentPlaylist = List<String>.from(state.playlist);
    currentPlaylist.add(event.audioPath);
    emit(state.copyWith(playlist: currentPlaylist));
  }
} 