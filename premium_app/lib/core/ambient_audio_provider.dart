import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class AmbientSoundscape {
  final String id;
  final String name;
  final String icon;
  final String audioUrl;

  const AmbientSoundscape({
    required this.id,
    required this.name,
    required this.icon,
    required this.audioUrl,
  });
}

class AmbientAudioState {
  final AmbientSoundscape? currentSoundscape;
  final bool isPlaying;
  final double volume;
  final bool isLoading;

  const AmbientAudioState({
    this.currentSoundscape,
    this.isPlaying = false,
    this.volume = 0.5,
    this.isLoading = false,
  });

  AmbientAudioState copyWith({
    AmbientSoundscape? currentSoundscape,
    bool? isPlaying,
    double? volume,
    bool? isLoading,
  }) {
    return AmbientAudioState(
      currentSoundscape: currentSoundscape ?? this.currentSoundscape,
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AmbientAudioNotifier extends StateNotifier<AmbientAudioState> {
  final AudioPlayer _player = AudioPlayer();

  static const List<AmbientSoundscape> soundscapes = [
    AmbientSoundscape(
      id: 'flute',
      name: 'Divine Flute',
      icon: '🪈',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    ),
    AmbientSoundscape(
      id: 'tanpura',
      name: 'Sacred Tanpura',
      icon: '🪕',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-16.mp3',
    ),
    AmbientSoundscape(
      id: 'yamuna',
      name: 'Yamuna Birds & Stream',
      icon: '🌊',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
    ),
    AmbientSoundscape(
      id: 'bells',
      name: 'Temple Bells',
      icon: '🔔',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-12.mp3',
    ),
  ];

  AmbientAudioNotifier() : super(const AmbientAudioState()) {
    _init();
  }

  void _init() {
    _player.setLoopMode(LoopMode.one);
    _player.setVolume(state.volume);

    _player.playerStateStream.listen((playerState) {
      state = state.copyWith(
        isPlaying: playerState.playing,
        isLoading: playerState.processingState == ProcessingState.loading ||
                   playerState.processingState == ProcessingState.buffering,
      );
    });
  }

  Future<void> selectSoundscape(AmbientSoundscape soundscape) async {
    try {
      state = state.copyWith(
        currentSoundscape: soundscape,
        isLoading: true,
      );
      
      await _player.setUrl(soundscape.audioUrl);
      await _player.play();
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint('Error loading ambient sound: $e');
    }
  }

  Future<void> togglePlay() async {
    if (state.currentSoundscape == null) {
      // Auto-select first soundscape if none chosen
      await selectSoundscape(soundscapes.first);
      return;
    }

    if (state.isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> stop() async {
    await _player.stop();
    state = const AmbientAudioState();
  }

  Future<void> setVolume(double val) async {
    final clamped = val.clamp(0.0, 1.0);
    state = state.copyWith(volume: clamped);
    await _player.setVolume(clamped);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

final ambientAudioProvider =
    StateNotifierProvider<AmbientAudioNotifier, AmbientAudioState>((ref) {
  return AmbientAudioNotifier();
});
