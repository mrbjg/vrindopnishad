import 'package:flutter/foundation.dart';
import '../models/user_stats.dart';
import '../core/firestore_service.dart';

class StatsService {
  /// Fetch or initialize user stats from Firestore
  Future<UserStats?> getOrCreateStats(String uid) async {
    try {
      final doc = await firestore
          .collection('user_stats')
          .doc(uid)
          .get();

      if (!doc.exists) {
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

        await firestore
            .collection('user_stats')
            .doc(uid)
            .set(newStats);

        return UserStats.fromJson(newStats);
      }

      return UserStats.fromJson(doc.data()!);
    } catch (e) {
      debugPrint('Error handling user stats: $e');
      rethrow;
    }
  }

  /// Update user stats (Experience, Reading Time, etc.)
  Future<void> updateStats(String uid, Map<String, dynamic> updates) async {
    try {
      await firestore
          .collection('user_stats')
          .doc(uid)
          .update({...updates, 'updated_at': DateTime.now().toUtc().toIso8601String()});
    } catch (e) {
      debugPrint('Error updating stats: $e');
    }
  }

  /// Log a jap activity (can be any number of chants)
  Future<void> logJapActivity(String uid, int count, {int? todayCount}) async {
    try {
      // 1. Insert into history
      if (count > 0) {
        await firestore.collection('jap_history').add({
          'firebase_uid': uid,
          'count': count,
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });
      }

      // 2. Also update total jap count and check for new personal best
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
      final snapshot = await firestore
          .collection('jap_history')
          .where('firebase_uid', isEqualTo: uid)
          .get();

      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Sort in memory to avoid needing compound index
      list.sort((a, b) {
        final aTime = a['created_at']?.toString() ?? '';
        final bTime = b['created_at']?.toString() ?? '';
        return bTime.compareTo(aTime);
      });

      return list.take(100).toList();
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
      await firestore.collection('reading_history').add({
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
      debugPrint('Error logging reading activity: $e');
      rethrow;
    }
  }

  /// Fetch user's reading history
  Future<List<ReadingHistoryItem>> getReadingHistory(String uid) async {
    try {
      final snapshot = await firestore
          .collection('reading_history')
          .where('firebase_uid', isEqualTo: uid)
          .get();

      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ReadingHistoryItem.fromJson(data);
      }).toList();

      // Sort in memory to avoid needing index
      list.sort((a, b) => b.readAt.compareTo(a.readAt));

      return list.take(50).toList();
    } catch (e) {
      debugPrint('Error fetching reading history: $e');
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
        // Normalise dates to compare only days
        final todayDate = DateTime(now.year, now.month, now.day);
        final lastActiveDateOnly = DateTime(lastActive.year, lastActive.month, lastActive.day);
        final difference = todayDate.difference(lastActiveDateOnly).inDays;

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

  /// Delete user's stats and history from Firestore
  Future<void> deleteUserData(String uid) async {
    try {
      // Removed local firestore assignment so global firestore getter is used
      
      // 1. Delete reading history
      final readingSnap = await firestore
          .collection('reading_history')
          .where('firebase_uid', isEqualTo: uid)
          .get();
      for (var doc in readingSnap.docs) {
        await doc.reference.delete();
      }

      // 2. Delete jap history
      final japSnap = await firestore
          .collection('jap_history')
          .where('firebase_uid', isEqualTo: uid)
          .get();
      for (var doc in japSnap.docs) {
        await doc.reference.delete();
      }

      // 3. Delete user stats
      await firestore.collection('user_stats').doc(uid).delete();
      
      // 4. Delete user challenge progress
      final progressSnap = await firestore
          .collection('user_challenge_progress')
          .where('firebase_uid', isEqualTo: uid)
          .get();
      for (var doc in progressSnap.docs) {
        await doc.reference.delete();
      }

      // 5. Delete user achievements
      final achievementSnap = await firestore
          .collection('user_achievements')
          .where('firebase_uid', isEqualTo: uid)
          .get();
      for (var doc in achievementSnap.docs) {
        await doc.reference.delete();
      }

      // 6. Delete favorites
      final favSnap = await firestore
          .collection('favorites')
          .where('user_id', isEqualTo: uid)
          .get();
      for (var doc in favSnap.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('Error deleting user data: $e');
    }
  }

  /// Clear user's reading history
  Future<void> clearReadingHistory(String uid) async {
    try {
      final readingSnap = await firestore
          .collection('reading_history')
          .where('firebase_uid', isEqualTo: uid)
          .get();
      for (var doc in readingSnap.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('Error clearing reading history: $e');
    }
  }

  Future<void> updateGoal(String uid, int goal, String? reminderTime) async {
    try {
      await firestore.collection('user_stats').doc(uid).update({
        'daily_mala_goal': goal,
        'reminder_time': reminderTime,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error updating goal: $e');
    }
  }
}
