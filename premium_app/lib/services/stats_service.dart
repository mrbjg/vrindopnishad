import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../models/user_stats.dart';

class StatsService {
  final sb.SupabaseClient _supabase = sb.Supabase.instance.client;

  /// Fetch or initialize user stats from Supabase
  Future<UserStats?> getOrCreateStats(String uid) async {
    const String fullColumns = 'firebase_uid, level, experience_points, streak_count, last_active_date, total_reading_minutes, total_shlokas_read, total_jap_count, highest_daily_japs, daily_mala_goal, reminder_time, dynamic_icon_enabled, spirituality_level, preferred_language, onboarding_completed, total_badges, updated_at';
    const String fallbackColumns = 'firebase_uid, level, experience_points, streak_count, last_active_date, total_reading_minutes, total_shlokas_read, total_jap_count, daily_mala_goal, reminder_time, dynamic_icon_enabled, spirituality_level, preferred_language, onboarding_completed, total_badges, updated_at';

    try {
      final response = await _supabase
          .from('user_stats')
          .select(fullColumns)
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
          'highest_daily_japs': 0,
          'daily_mala_goal': 11,
          'reminder_time': '08:00',
          'dynamic_icon_enabled': true,
          'spirituality_level': 'seeker',
          'preferred_language': 'hi',
          'onboarding_completed': false,
          'total_badges': 0,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        };
        
        final created = await _supabase
            .from('user_stats')
            .insert(newStats)
            .select('firebase_uid, level, experience_points, streak_count, last_active_date, total_reading_minutes, total_shlokas_read, total_jap_count, highest_daily_japs, daily_mala_goal, reminder_time, dynamic_icon_enabled, spirituality_level, preferred_language, onboarding_completed, total_badges, updated_at')
            .single();
            
        return UserStats.fromJson(created);
      }
      
      return UserStats.fromJson(response);
    } catch (e) {
      if (e is sb.PostgrestException && (e.code == '42703' || e.message.contains('highest_daily_japs'))) {
        // Fallback to query without highest_daily_japs
        try {
          final fallbackResponse = await _supabase
              .from('user_stats')
              .select(fallbackColumns)
              .eq('firebase_uid', uid)
              .maybeSingle();
              
          if (fallbackResponse == null) {
            // Re-run initialization without the missing column
            final Map<String, dynamic> newStats = {
              'firebase_uid': uid,
              'level': 1,
              'experience_points': 0,
              'streak_count': 0,
              'total_reading_minutes': 0,
              'total_shlokas_read': 0,
              'total_jap_count': 0,
              'daily_mala_goal': 11,
              'reminder_time': '08:00',
              'dynamic_icon_enabled': true,
              'spirituality_level': 'seeker',
              'preferred_language': 'hi',
              'onboarding_completed': false,
              'total_badges': 0,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            };
            
            final created = await _supabase
                .from('user_stats')
                .insert(newStats)
                .select(fallbackColumns)
                .single();
            return UserStats.fromJson(created);
          }
          return UserStats.fromJson(fallbackResponse);
        } catch (innerE) {
          debugPrint('Fatal error in stats fallback: $innerE');
        }
      }
      debugPrint('Error handling user stats: $e');
      rethrow;
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
      if (e is sb.PostgrestException && (e.code == '42703' || e.message.contains('highest_daily_japs'))) {
        // Retry update without highest_daily_japs if it's there
        if (updates.containsKey('highest_daily_japs')) {
          final safeUpdates = Map<String, dynamic>.from(updates);
          safeUpdates.remove('highest_daily_japs');
          return updateStats(uid, safeUpdates);
        }
      }
      debugPrint('Error updating stats: $e');
    }
  }

  /// Log a jap activity (can be any number of chants)
  Future<void> logJapActivity(String uid, int count, {int? todayCount}) async {
    try {
      await _supabase.from('jap_history').insert({
        'firebase_uid': uid,
        'count': count,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      // Also update total jap count and check for new personal best
      final stats = await getOrCreateStats(uid);
      if (stats != null) {
        final newXp = stats.experiencePoints + (count * 2); // 2 XP per chant
        final newLevel = (newXp / 1000).floor() + 1;
        
        final Map<String, dynamic> updates = {
          'total_jap_count': stats.totalJapCount + count,
          'experience_points': newXp,
          'level': newLevel,
        };

        // If todayCount is provided, check if it's a new personal record
        if (todayCount != null && todayCount > stats.highestDailyJaps) {
          updates['highest_daily_japs'] = todayCount;
        }
        
        await updateStats(uid, updates);
      }
    } catch (e) {
      debugPrint('Error logging jap activity: $e');
    }
  }

  /// Fetch user's jap history
  Future<List<Map<String, dynamic>>> getJapHistory(String uid) async {
    try {
      final response = await _supabase
          .from('jap_history')
          .select()
          .eq('firebase_uid', uid)
          .order('created_at', ascending: false)
          .limit(100);
          
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error fetching jap history: $e');
      return [];
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
        'read_at': DateTime.now().toUtc().toIso8601String(),
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
      rethrow;
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

  /// Delete user's stats and history from Supabase
  Future<void> deleteUserData(String uid) async {
    try {
      // 1. Delete reading history
      await _supabase
          .from('reading_history')
          .delete()
          .eq('firebase_uid', uid);
          
      // 2. Delete jap history
      await _supabase
          .from('jap_history')
          .delete()
          .eq('firebase_uid', uid);
          
      // 3. Delete user stats
      await _supabase
          .from('user_stats')
          .delete()
          .eq('firebase_uid', uid);
    } catch (e) {
      debugPrint('Error deleting user data: $e');
    }
  }

  /// Clear user's reading history
  Future<void> clearReadingHistory(String uid) async {
    try {
      await _supabase
          .from('reading_history')
          .delete()
          .eq('firebase_uid', uid);
    } catch (e) {
      debugPrint('Error clearing history: $e');
    }
  }

  Future<void> updateGoal(String uid, int goal, String? reminderTime) async {
    try {
      await _supabase.from('user_stats').update({
        'daily_mala_goal': goal,
        'reminder_time': reminderTime,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('firebase_uid', uid);
    } catch (e) {
      debugPrint('Error updating goal: $e');
    }
  }
}
