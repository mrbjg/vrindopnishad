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

  final AudioPlayer _player = AudioPlayer(
    userAgent: 'Sant-Vaani/Premium/1.0 (Mobile; Spiritual Audio Engine)',
  );
  
  SacredAudioService._internal();

  AudioPlayer get player => _player;

  /// Initialize the audio service for background playback
  static Future<void> init() async {
    // Note: Background playback requires platform-specific setup and just_audio_background
    // This is a placeholder for the actual background initialization if needed.
    // For now, we focus on the core player functionality.
  }

  /// Load and play a playlist starting from a specific index
  Future<void> setPlaylist(List<SacredContent> items, {int initialIndex = 0}) async {
    try {
      // 1. Filter out items without a valid audio URL to prevent Source Errors
      final playableItems = items.where((item) => 
        item.audioUrl != null && 
        item.audioUrl!.isNotEmpty && 
        item.audioUrl!.startsWith('http')
      ).toList();

      if (playableItems.isEmpty) {
        debugPrint('SacredAudioService: No playable audio items found in playlist.');
        return;
      }

      // 2. Adjust initial index if the target item was filtered (fallback to 0)
      int adjustedIndex = initialIndex;
      if (initialIndex < items.length) {
        final targetItem = items[initialIndex];
        adjustedIndex = playableItems.indexWhere((item) => item.id == targetItem.id);
        if (adjustedIndex == -1) adjustedIndex = 0;
      }

      final List<AudioSource> sources = playableItems.map((content) {
        final audioUrl = content.audioUrl!;
        final mediaItem = MediaItem(
          id: content.id,
          album: content.category,
          title: content.title,
          artist: content.author ?? "Sant-Vaani",
          artUri: _getPlaybackArtUri(content.imageUrl),
        );

        return AudioSource.uri(
          Uri.parse(audioUrl), 
          tag: mediaItem,
        );
      }).toList();

      final playlistSource = ConcatenatingAudioSource(children: sources);
      await _player.setAudioSource(playlistSource, initialIndex: adjustedIndex);
      await _player.play();
    } catch (e) {
      debugPrint('SacredAudioService Playlist Error: $e');
      if (e is UnsupportedError) {
        debugPrint('Audio URL Format Error: Please verify the protocol (HTTP/HTTPS).');
      }
    }
  }

  Future<void> play(SacredContent content) async {
    await setPlaylist([content], initialIndex: 0);
  }

  Future<void> next() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    }
  }

  Future<void> previous() async {
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
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

  /// ═══════════════════════════════════════════════════════════════════════════
  /// HELPERS
  /// ═══════════════════════════════════════════════════════════════════════════

  Uri? _getPlaybackArtUri(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return null;
    
    // If it's a relative asset path, convert it to the format 
    // just_audio_background expects (asset:///assets/...)
    if (imageUrl.startsWith('assets/')) {
      return Uri.parse('asset:///$imageUrl');
    }
    
    // Fallback to network URI
    try {
      return Uri.parse(imageUrl);
    } catch (e) {
      debugPrint('SacredAudioService: Invalid artUri: $imageUrl');
      return null;
    }
  }
}
