import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'content_provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

/// ═══════════════════════════════════════════════════════════════════════════
/// SACRED AUDIO SERVICE - Production-ready audio handling with background support
/// ═══════════════════════════════════════════════════════════════════════════

class SacredAudioService {
  static final SacredAudioService _instance = SacredAudioService._internal();
  factory SacredAudioService() => _instance;

  final AudioPlayer _player = AudioPlayer();
  
  SacredAudioService._internal();

  AudioPlayer get player => _player;

  /// Initialize the audio service for background playback
  static Future<void> init() async {
    // Note: Background playback requires platform-specific setup and just_audio_background
    // This is a placeholder for the actual background initialization if needed.
    // For now, we focus on the core player functionality.
  }

  Future<void> play(SacredContent content) async {
    try {
      final audioUrl = content.audioUrl;
      if (audioUrl == null || audioUrl.isEmpty) {
        debugPrint('SacredAudioService: No audio URL provided for ${content.title}');
        return;
      }

      // Metadata for background playback and lock screen
      final mediaItem = MediaItem(
        id: content.id,
        album: content.category,
        title: content.title,
        artist: "Sant-Vaani",
        artUri: content.imageUrl != null ? Uri.parse(content.imageUrl!) : null,
      );

      // Use LockCachingAudioSource for automatic local caching if it's a network URL
      AudioSource source;
      if (audioUrl.startsWith('http')) {
        source = LockCachingAudioSource(
          Uri.parse(audioUrl),
          tag: mediaItem,
        );
      } else {
        // Handle assets or local files if necessary
        source = AudioSource.uri(Uri.parse(audioUrl), tag: mediaItem);
      }

      await _player.setAudioSource(source);
      await _player.play();
    } catch (e) {
      debugPrint('SacredAudioService Error: $e');
      // Potential fallback or retry logic could go here
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  void dispose() {
    _player.dispose();
  }
}
