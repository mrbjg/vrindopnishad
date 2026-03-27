import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../models/daily_motivation.dart';
import '../models/daily_gyaan.dart';
import '../models/sacred_event.dart';
import '../models/achievement.dart';
import '../models/daily_challenge.dart';

class SpiritualContentService {
  final sb.SupabaseClient _supabase = sb.Supabase.instance.client;

  // ─── Daily Motivation ───────────────────────────────────────

  /// Fetch a motivation appropriate for user's level
  Future<DailyMotivation?> getDailyMotivation(int userLevel) async {
    try {
      final response = await _supabase
          .from('daily_motivations')
          .select()
          .lte('min_level', userLevel)
          .gte('max_level', userLevel)
          .limit(10);

      final list = (response as List).cast<Map<String, dynamic>>();
      if (list.isEmpty) return null;

      // Pick a pseudo-random one based on today's date for consistency
      final dayIndex = DateTime.now().day % list.length;
      return DailyMotivation.fromJson(list[dayIndex]);
    } catch (e) {
      debugPrint('Error fetching motivation: $e');
      return null;
    }
  }

  /// Fetch motivations by category
  Future<List<DailyMotivation>> getMotivationsByCategory(
      String category, int userLevel) async {
    try {
      final response = await _supabase
          .from('daily_motivations')
          .select()
          .eq('category', category)
          .lte('min_level', userLevel)
          .gte('max_level', userLevel)
          .order('created_at', ascending: false)
          .limit(20);

      return (response as List)
          .cast<Map<String, dynamic>>()
          .map((e) => DailyMotivation.fromJson(e))
          .toList();
    } catch (e) {
      debugPrint('Error fetching motivations by category: $e');
      return [];
    }
  }

  // ─── Daily Gyaan ────────────────────────────────────────────

  /// Fetch today's gyaan based on difficulty matching user level
  Future<DailyGyaan?> getDailyGyaan(int userLevel) async {
    try {
      // Map user level to difficulty: 1-10 = beginner, 11-20 = intermediate, 21+ = advanced
      int difficulty = 1;
      if (userLevel > 20) {
        difficulty = 3;
      } else if (userLevel > 10) {
        difficulty = 2;
      }

      final response = await _supabase
          .from('daily_gyaan')
          .select()
          .lte('difficulty', difficulty)
          .order('created_at', ascending: false)
          .limit(10);

      final list = (response as List).cast<Map<String, dynamic>>();
      if (list.isEmpty) return null;

      // Pick a pseudo-random one based on today's date for consistency
      if (list.isNotEmpty) {
        final dayIndex = DateTime.now().day % list.length;
        return DailyGyaan.fromJson(list[dayIndex]);
      }
      
      // Fallback Sample Data for UI Demo
      return DailyGyaan(
        id: 'sample_today',
        title: 'The Eternal Witness',
        content: 'Know that you are the eternal witness, untouched by the tides of time. In the silence of your heart, the universe speaks.',
        difficulty: 2,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error fetching gyaan: $e');
      return DailyGyaan(
        id: 'sample_error',
        title: 'The Path of Peace',
        content: 'Peace is not the absence of conflict, but the presence of God in every breath.',
        difficulty: 1,
        createdAt: DateTime.now(),
      );
    }
  }

  /// Fetch all gyaan for browse
  Future<List<DailyGyaan>> getAllGyaan({int? difficulty}) async {
    try {
      var query = _supabase.from('daily_gyaan').select();
      if (difficulty != null) {
        query = query.eq('difficulty', difficulty);
      }
      final response =
          await query.order('created_at', ascending: false).limit(50);

      final apiList = (response as List)
          .cast<Map<String, dynamic>>()
          .map((e) => DailyGyaan.fromJson(e))
          .toList();

      // Add high-quality samples for UI demonstration
      return [
        ...apiList,
        DailyGyaan(
            id: 's1',
            title: 'Transcending Ego',
            content: 'The ego is a veil between the soul and the world. Lift it with humility.',
            difficulty: 3,
            createdAt: DateTime.now().subtract(const Duration(days: 1))),
        DailyGyaan(
            id: 's2',
            title: 'Radha-Krishna Prem',
            content: 'Pure love is the highest form of knowledge. It dissolves all boundaries.',
            difficulty: 1,
            createdAt: DateTime.now().subtract(const Duration(days: 2))),
        DailyGyaan(
            id: 's3',
            title: 'The Power of Mantra',
            content: 'Sound is the primordial vibration. Chanting clears the mind like a summer rain.',
            difficulty: 2,
            createdAt: DateTime.now().subtract(const Duration(days: 3))),
      ];
    } catch (e) {
      debugPrint('Error fetching all gyaan: $e');
      return [];
    }
  }

  // ─── Sacred Calendar ────────────────────────────────────────

  /// Fetch upcoming events
  Future<List<SacredEvent>> getUpcomingEvents({int limit = 10}) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final response = await _supabase
          .from('sacred_calendar')
          .select()
          .gte('date', today)
          .order('date', ascending: true)
          .limit(limit);

      final apiList = (response as List)
          .cast<Map<String, dynamic>>()
          .map((e) => SacredEvent.fromJson(e))
          .toList();

      // Prepend Sample Data for UI Demo
      return [
        SacredEvent(
          id: 'e1',
          title: 'Full Moon Meditation',
          date: DateTime.now().add(const Duration(days: 2)),
          type: 'utsav',
          description: 'A time for deep inner work under the celestial glow.',
          createdAt: DateTime.now(),
        ),
        SacredEvent(
          id: 'e2',
          title: 'Pradosh Vrat',
          date: DateTime.now().add(const Duration(days: 5)),
          type: 'vrat',
          description: 'Focused prayer and fasting for Lord Shiva.',
          createdAt: DateTime.now(),
        ),
        ...apiList,
      ];
    } catch (e) {
      debugPrint('Error fetching events: $e');
      return [];
    }
  }

  /// Fetch events for a specific month
  Future<List<SacredEvent>> getEventsForMonth(int year, int month) async {
    try {
      final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
      final endMonth = month == 12 ? 1 : month + 1;
      final endYear = month == 12 ? year + 1 : year;
      final endDate = '$endYear-${endMonth.toString().padLeft(2, '0')}-01';

      final response = await _supabase
          .from('sacred_calendar')
          .select()
          .gte('date', startDate)
          .lt('date', endDate)
          .order('date', ascending: true);

      return (response as List)
          .cast<Map<String, dynamic>>()
          .map((e) => SacredEvent.fromJson(e))
          .toList();
    } catch (e) {
      debugPrint('Error fetching monthly events: $e');
      return [];
    }
  }

  /// Fetch today's events
  Future<List<SacredEvent>> getTodayEvents() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final response = await _supabase
          .from('sacred_calendar')
          .select()
          .eq('date', today);

      final apiList = (response as List)
          .cast<Map<String, dynamic>>()
          .map((e) => SacredEvent.fromJson(e))
          .toList();
          
      // Ensure Today has an event for UI Demo
      if (apiList.isEmpty) {
        return [
          SacredEvent(
            id: 'today_sample',
            title: 'Celestial Alignment Day',
            date: DateTime.now(),
            type: 'tithi',
            description: 'The stars are aligned for spiritual progress today.',
            createdAt: DateTime.now(),
          ),
        ];
      }
      return apiList;
    } catch (e) {
      debugPrint('Error fetching today events: $e');
      return [
        SacredEvent(
          id: 'error_sample',
          title: 'Divine Grace Moment',
          date: DateTime.now(),
          type: 'utsav',
          description: 'Every moment is a gift when lived in awareness.',
          createdAt: DateTime.now(),
        ),
      ];
    }
  }

  // ─── Achievements ──────────────────────────────────────────

  /// Fetch user's unlocked achievements
  Future<List<UserAchievement>> getUserAchievements(String uid) async {
    try {
      final response = await _supabase
          .from('user_achievements')
          .select()
          .eq('firebase_uid', uid);

      return (response as List)
          .cast<Map<String, dynamic>>()
          .map((e) => UserAchievement.fromJson(e))
          .toList();
    } catch (e) {
      debugPrint('Error fetching achievements: $e');
      return [];
    }
  }

  /// Unlock an achievement
  Future<bool> unlockAchievement(String uid, String achievementId) async {
    try {
      await _supabase.from('user_achievements').upsert({
        'firebase_uid': uid,
        'achievement_id': achievementId,
        'unlocked_at': DateTime.now().toUtc().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Error unlocking achievement: $e');
      return false;
    }
  }

  // ─── Daily Challenges ──────────────────────────────────────

  /// Fetch today's challenges appropriate for user level
  Future<List<DailyChallenge>> getDailyChallenges(
      String uid, int userLevel) async {
    try {
      // Get challenges matching user level
      final response = await _supabase
          .from('daily_challenges')
          .select()
          .lte('min_level', userLevel)
          .limit(3);

      final challenges = (response as List)
          .cast<Map<String, dynamic>>()
          .map((e) => DailyChallenge.fromJson(e))
          .toList();

      // Fetch user progress for these challenges
      if (challenges.isEmpty) return [];

      final progressResponse = await _supabase
          .from('user_challenge_progress')
          .select()
          .eq('firebase_uid', uid)
          .inFilter(
              'challenge_id', challenges.map((c) => c.id).toList());

      final progressMap = <String, Map<String, dynamic>>{};
      for (var p in (progressResponse as List).cast<Map<String, dynamic>>()) {
        progressMap[p['challenge_id']] = p;
      }

      // Merge progress into challenges
      return challenges.map((challenge) {
        final progress = progressMap[challenge.id];
        if (progress != null) {
          return challenge.copyWith(
            currentValue: progress['current_value'] ?? 0,
            isCompleted: progress['is_completed'] ?? false,
            completedAt: progress['completed_at'] != null
                ? DateTime.parse(progress['completed_at'])
                : null,
          );
        }
        return challenge;
      }).toList();
    } catch (e) {
      debugPrint('Error fetching challenges: $e');
      return [];
    }
  }

  /// Update challenge progress
  Future<void> updateChallengeProgress(
      String uid, String challengeId, int newValue, bool completed) async {
    try {
      await _supabase.from('user_challenge_progress').upsert({
        'firebase_uid': uid,
        'challenge_id': challengeId,
        'current_value': newValue,
        'is_completed': completed,
        if (completed)
          'completed_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error updating challenge progress: $e');
    }
  }
}
