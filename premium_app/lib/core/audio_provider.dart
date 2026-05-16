import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'audio_service.dart';
import 'content_provider.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// AUDIO PROVIDER - Global state management for audio playback
/// ═══════════════════════════════════════════════════════════════════════════

class AudioState {
  final SacredContent? currentContent;
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final PlayerState playerState;
  final List<SacredContent> playlist;
  final int currentIndex;

  AudioState({
    this.currentContent,
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    required this.playerState,
    this.playlist = const [],
    this.currentIndex = 0,
  });

  AudioState copyWith({
    SacredContent? currentContent,
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    PlayerState? playerState,
    List<SacredContent>? playlist,
    int? currentIndex,
  }) {
    return AudioState(
      currentContent: currentContent ?? this.currentContent,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      playerState: playerState ?? this.playerState,
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class AudioNotifier extends StateNotifier<AudioState> {
  final SacredAudioService _service = SacredAudioService();

  AudioNotifier() : super(AudioState(playerState: PlayerState(false, ProcessingState.idle))) {
    _init();
  }

  void _init() {
    // Listen to player state changes
    _service.player.playerStateStream.listen((playerState) {
      state = state.copyWith(
        playerState: playerState,
        isPlaying: playerState.playing,
        isLoading: playerState.processingState == ProcessingState.loading || 
                   playerState.processingState == ProcessingState.buffering,
      );
    });

    // Listen to current index changes (Important for playlists)
    _service.player.currentIndexStream.listen((index) {
      if (index != null && index < state.playlist.length) {
        state = state.copyWith(
          currentIndex: index,
          currentContent: state.playlist[index],
        );
      }
    });

    // Listen to position changes
    _service.player.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });

    // Listen to duration changes
    _service.player.durationStream.listen((duration) {
      if (duration != null) {
        state = state.copyWith(duration: duration);
      }
    });

    // Handle song completion - now handled by currentIndexStream for playlists
    // but we can still reset state if truly finished
    _service.player.processingStateStream.listen((processingState) {
      if (processingState == ProcessingState.completed) {
        state = state.copyWith(isPlaying: false, position: Duration.zero);
      }
    });

    // Handle errors to prevent permanent loading state
    _service.player.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace st) {
      state = state.copyWith(isLoading: false, isPlaying: false);
      debugPrint('Audio Playback Error: $e');
    });
  }

  Future<void> playWithPlaylist(SacredContent content, List<SacredContent> playlist) async {
    final index = playlist.indexWhere((item) => item.id == content.id);
    final initialIndex = index != -1 ? index : 0;

    state = state.copyWith(
      playlist: playlist,
      currentIndex: initialIndex,
      currentContent: content,
      isLoading: true,
    );

    await _service.setPlaylist(playlist, initialIndex: initialIndex);
  }

  Future<void> nextTrack() async {
    await _service.next();
  }

  Future<void> previousTrack() async {
    await _service.previous();
  }

  Future<void> play(SacredContent content) async {
    if (state.currentContent?.id == content.id) {
      if (state.isPlaying) {
        await _service.pause();
      } else {
        await _service.resume();
      }
      return;
    }

    state = state.copyWith(currentContent: content, isLoading: true);
    await _service.play(content);
  }

  Future<void> pause() async {
    await _service.pause();
  }

  Future<void> resume() async {
    await _service.resume();
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> seek(Duration position) async {
    await _service.seek(position);
  }

  Future<void> skipForward() async {
    final newPosition = state.position + const Duration(seconds: 10);
    if (newPosition < state.duration) {
      await seek(newPosition);
    } else {
      await seek(state.duration);
    }
  }

  Future<void> skipBackward() async {
    final newPosition = state.position - const Duration(seconds: 10);
    if (newPosition > Duration.zero) {
      await seek(newPosition);
    } else {
      await seek(Duration.zero);
    }
  }

  Future<void> stop() async {
    state = AudioState(
      currentContent: null,
      isPlaying: false,
      isLoading: false,
      position: Duration.zero,
      duration: Duration.zero,
      playerState: PlayerState(false, ProcessingState.idle),
    );
    await _service.pause();
  }
}

final audioProvider = StateNotifierProvider<AudioNotifier, AudioState>((ref) {
  return AudioNotifier();
});
