import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_stats.dart';
import '../services/stats_service.dart';
import '../services/gamification_service.dart';
import 'dart:convert';
import 'auth_provider.dart';
import 'providers.dart';

final statsServiceProvider = Provider<StatsService>((ref) => StatsService());

final userStatsProvider = AsyncNotifierProvider<UserStatsNotifier, UserStats?>(() {
  return UserStatsNotifier();
});

class UserStatsNotifier extends AsyncNotifier<UserStats?> {
  static const _cacheKey = 'user_stats_cache';

  @override
  Future<UserStats?> build() async {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return null;
    
    // 1. Try to load from cache immediately for "Instant" feel
    _loadFromCache();
    
    // 2. Sync from remote in background
    final statsService = ref.read(statsServiceProvider);
    
    try {
      // Background sync
      await statsService.syncStreak(user.uid);
      final remoteStats = await statsService.getOrCreateStats(user.uid);
      
      if (remoteStats != null) {
        _saveToCache(remoteStats);
        return remoteStats;
      }
    } catch (e) {
      debugPrint('Error syncing stats: $e');
    }
    
    return state.value; // Return cached value if remote fails
  }

  void _loadFromCache() {
    final prefs = ref.read(sharedPreferencesProvider);
    final cachedData = prefs.getString(_cacheKey);
    if (cachedData != null) {
      try {
        final stats = UserStats.fromJson(jsonDecode(cachedData));
        state = AsyncValue.data(stats);
      } catch (e) {
        debugPrint('Error loading stats cache: $e');
      }
    }
  }

  void _saveToCache(UserStats stats) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(_cacheKey, jsonEncode(stats.toJson()));
  }

  /// Manually refresh stats
  Future<void> refresh() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    
    state = await AsyncValue.guard(() async {
      final remoteStats = await ref.read(statsServiceProvider).getOrCreateStats(user.uid);
      if (remoteStats != null) {
        _saveToCache(remoteStats);
      }
      return remoteStats;
    });
  }

  /// Increment shloka read count and earn XP via GamificationService
  Future<void> recordReading(BuildContext context, String contentId, {String? title, String? category}) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    
    // Optimistic XP update could go here, but keep it simple for now
    await ref.read(statsServiceProvider).logReadingActivity(
      user.uid, 
      contentId: contentId,
      title: title,
      category: category,
    );
    
    if (context.mounted) {
      await ref.read(gamificationServiceProvider).awardXP(
        context, 
        50, 
        title ?? 'Read Sacred Text',
      );
    }
    
    await refresh();
    ref.invalidate(readingHistoryProvider);
  }
  
  /// Update total jap count silently to prevent flickering
  Future<void> syncJaps(int count) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    
    // Update local state immediately (Optimistic UI)
    if (state.hasValue && state.value != null) {
      final updated = state.value!.copyWith(totalJapCount: count);
      state = AsyncValue.data(updated);
      _saveToCache(updated);
    }
    
    await ref.read(statsServiceProvider).updateStats(user.uid, {
      'total_jap_count': count,
    });
    
    final updatedStats = await ref.read(statsServiceProvider).getOrCreateStats(user.uid);
    if (updatedStats != null) {
      _saveToCache(updatedStats);
      state = AsyncValue.data(updatedStats);
    }
  }
}


final readingHistoryProvider = FutureProvider<List<ReadingHistoryItem>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return [];
  
  return await ref.read(statsServiceProvider).getReadingHistory(user.uid);
});

final japHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return [];
  
  return await ref.read(statsServiceProvider).getJapHistory(user.uid);
});
