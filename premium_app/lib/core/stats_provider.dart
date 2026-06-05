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
    
    // Cache locally for offline-first reading history
    final prefs = ref.read(sharedPreferencesProvider);
    const cacheKey = 'reading_history_cache';
    final newEntry = {
      'id': 'local_${DateTime.now().millisecondsSinceEpoch}',
      'firebase_uid': user.uid,
      'content_id': contentId,
      'title': title,
      'category': category,
      'read_at': DateTime.now().toUtc().toIso8601String(),
    };
    try {
      final existing = prefs.getString(cacheKey);
      final List<dynamic> list = existing != null ? jsonDecode(existing) : [];
      list.insert(0, newEntry); // newest first
      if (list.length > 50) list.removeRange(50, list.length);
      await prefs.setString(cacheKey, jsonEncode(list));
    } catch (_) {}

    // Try remote logging (best effort)
    try {
      await ref.read(statsServiceProvider).logReadingActivity(
        user.uid, 
        contentId: contentId,
        title: title,
        category: category,
      );
    } catch (e) {
      debugPrint('Remote reading log failed: $e');
    }
    
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
  
  /// Update total jap count silently to prevent flickering (Optimistic)
  void updateTotalJapLocally(int total, int today) {
    if (state.hasValue && state.value != null) {
      var current = state.value!;
      var updated = current.copyWith(totalJapCount: total);
      
      // Update highest record locally if today's count exceeds it
      if (today > current.highestDailyJaps) {
        updated = updated.copyWith(highestDailyJaps: today);
      }
      
      state = AsyncValue.data(updated);
      _saveToCache(updated);
    }
  }
  
  /// Sync total jap count with Supabase
  Future<void> syncJaps(int count, {int? todayCount}) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    
    // Update local state immediately (Optimistic UI)
    updateTotalJapLocally(count, todayCount ?? 0);
    
    await ref.read(statsServiceProvider).logJapActivity(
      user.uid, 
      0, // Zero count increment if just syncing total (though logJapActivity usually expects an increment)
      todayCount: todayCount,
    );
    
    await refresh();
  }
}


final readingHistoryProvider = FutureProvider<List<ReadingHistoryItem>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return [];

  final prefs = ref.read(sharedPreferencesProvider);
  const cacheKey = 'reading_history_cache';

  // 1. Try remote first
  try {
    final remote = await ref.read(statsServiceProvider).getReadingHistory(user.uid);
    if (remote.isNotEmpty) {
      // Save to local cache
      final encoded = jsonEncode(remote.map((e) => e.toJson()).toList());
      await prefs.setString(cacheKey, encoded);
      return remote;
    }
  } catch (e) {
    debugPrint('Remote reading history failed, using local cache: $e');
  }

  // 2. Fallback to local cache
  final cached = prefs.getString(cacheKey);
  if (cached != null) {
    try {
      final decoded = (jsonDecode(cached) as List).cast<Map<String, dynamic>>();
      return decoded.asMap().entries.map((e) {
        final data = Map<String, dynamic>.from(e.value);
        data['id'] = data['id'] ?? 'local_${e.key}';
        return ReadingHistoryItem.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error parsing reading history cache: $e');
    }
  }

  return [];
});

/// Clear reading history from both local cache and remote Firestore.
Future<void> clearReadingHistoryEverywhere(WidgetRef ref) async {
  final prefs = ref.read(sharedPreferencesProvider);
  const cacheKey = 'reading_history_cache';

  // 1. Clear local cache immediately (guarantees UI updates)
  await prefs.remove(cacheKey);

  // 2. Try to clear remote (best-effort)
  final user = ref.read(authServiceProvider).currentUser;
  if (user != null) {
    try {
      await ref.read(statsServiceProvider).clearReadingHistory(user.uid);
    } catch (e) {
      debugPrint('Remote clear failed (expected if Firestore native disabled): $e');
    }
  }

  // 3. Refresh the provider to show empty state
  ref.invalidate(readingHistoryProvider);
}

final japHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return [];
  
  return await ref.read(statsServiceProvider).getJapHistory(user.uid);
});
