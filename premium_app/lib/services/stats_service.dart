import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../models/user_stats.dart';

class StatsService {
  final sb.SupabaseClient _supabase = sb.Supabase.instance.client;

  /// Fetch or initialize user stats from Supabase
  Future<UserStats?> getOrCreateStats(String uid) async {
    try {
      final response = await _supabase
          .from('user_stats')
          .select()
          .eq('firebase_uid', uid)
          .maybeSingle();

      if (response == null) {
        // Initialize new stats for first-time user
        final newStats = {
          'firebase_uid': uid,
          'level': 1,
          'experience_points': 0,
          'streak_count': 0,
          'total_reading_minutes': 0,
          'total_shlokas_read': 0,
          'total_jap_count': 0,
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        final created = await _supabase
            .from('user_stats')
            .insert(newStats)
            .select()
            .single();
            
        return UserStats.fromJson(created);
      }
      
      return UserStats.fromJson(response);
    } catch (e) {
      debugPrint('Error handling user stats: $e');
      return null;
    }
  }

  /// Update user stats (Experience, Reading Time, etc.)
  Future<void> updateStats(String uid, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('user_stats')
          .update({...updates, 'updated_at': DateTime.now().toIso8601String()})
          .eq('firebase_uid', uid);
    } catch (e) {
      debugPrint('Error updating stats: $e');
    }
  }

  /// Log a reading activity
  Future<void> logReadingActivity(String uid, {
    required String contentId,
    String? title,
    String? category,
  }) async {
    try {
      await _supabase.from('reading_history').insert({
        'firebase_uid': uid,
        'content_id': contentId,
        'title': title,
        'category': category,
        'read_at': DateTime.now().toIso8601String(),
      });
      
      // Also update total shlokas count in stats
      final stats = await getOrCreateStats(uid);
      if (stats != null) {
        final newXp = stats.experiencePoints + 50; // 50 XP per shloka read
        final newLevel = (newXp / 1000).floor() + 1; // 1000 XP per level
        
        await updateStats(uid, {
          'total_shlokas_read': stats.totalShlokasRead + 1,
          'experience_points': newXp,
          'level': newLevel,
        });
      }
    } catch (e) {
      debugPrint('Error logging activity: $e');
    }
  }

  /// Fetch user's reading history
  Future<List<ReadingHistoryItem>> getReadingHistory(String uid) async {
    try {
      final response = await _supabase
          .from('reading_history')
          .select()
          .eq('firebase_uid', uid)
          .order('read_at', ascending: false)
          .limit(50);
          
      return (response as List).map((item) => ReadingHistoryItem.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error fetching history: $e');
      return [];
    }
  }

  /// Update and calculate streaks
  Future<int> syncStreak(String uid) async {
    try {
      final stats = await getOrCreateStats(uid);
      if (stats == null) return 0;

      final now = DateTime.now();
      final lastActive = stats.lastActiveDate;
      
      int newStreak = stats.streakCount;
      
      if (lastActive == null) {
        newStreak = 1;
      } else {
        final difference = now.difference(lastActive).inDays;
        
        if (difference == 1) {
          // Worked out yesterday, increment streak
          newStreak++;
        } else if (difference > 1) {
          // Missed a day, reset streak
          newStreak = 1;
        }
        // If difference == 0, already tracked today, no change
      }

      await updateStats(uid, {
        'streak_count': newStreak,
        'last_active_date': now.toIso8601String().split('T')[0],
      });
      
      return newStreak;
    } catch (e) {
      debugPrint('Error syncing streak: $e');
      return 0;
    }
  }
}
