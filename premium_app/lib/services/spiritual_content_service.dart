import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/daily_motivation.dart';
import '../models/daily_gyaan.dart';
import '../models/sacred_event.dart';
import '../models/achievement.dart';
import '../models/daily_challenge.dart';
import '../core/cache_service.dart';

class SpiritualContentService {
  // ─── Daily Motivation ───────────────────────────────────────

  /// Fetch a motivation appropriate for user's level
  Future<DailyMotivation?> getDailyMotivation(int userLevel) async {
    try {
      // Try local cache first
      final cached = CacheService.instance.getCachedDailyMotivation();
      if (cached != null) {
        return cached;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('daily_motivations')
          .get();

      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).where((data) {
        final minLevel = data['min_level'] as int? ?? 1;
        final maxLevel = data['max_level'] as int? ?? 99;
        return userLevel >= minLevel && userLevel <= maxLevel;
      }).toList();

      if (list.isEmpty) return null;

      // Pick a pseudo-random one based on today's date for consistency
      final dayIndex = DateTime.now().day % list.length;
      final motivation = DailyMotivation.fromJson(list[dayIndex]);
      
      // Save to cache
      await CacheService.instance.cacheDailyMotivation(motivation);
      return motivation;
    } catch (e) {
      debugPrint('Error fetching motivation: $e');
      return null;
    }
  }

  /// Fetch motivations by category
  Future<List<DailyMotivation>> getMotivationsByCategory(
      String category, int userLevel) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('daily_motivations')
          .where('category', isEqualTo: category)
          .get();

      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).where((data) {
        final minLevel = data['min_level'] as int? ?? 1;
        final maxLevel = data['max_level'] as int? ?? 99;
        return userLevel >= minLevel && userLevel <= maxLevel;
      }).toList();

      // Sort by created_at desc in-memory
      list.sort((a, b) {
        final aTime = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      return list.map((e) => DailyMotivation.fromJson(e)).take(20).toList();
    } catch (e) {
      debugPrint('Error fetching motivations by category: $e');
      return [];
    }
  }

  // ─── Daily Gyaan ────────────────────────────────────────────

  /// Fetch today's gyaan based on difficulty matching user level
  Future<DailyGyaan?> getDailyGyaan(int userLevel) async {
    try {
      // Try local cache first
      final cached = CacheService.instance.getCachedDailyGyaan();
      if (cached != null) {
        return cached;
      }

      // Map user level to difficulty: 1-10 = beginner, 11-20 = intermediate, 21+ = advanced
      int difficulty = 1;
      if (userLevel > 20) {
        difficulty = 3;
      } else if (userLevel > 10) {
        difficulty = 2;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('daily_gyaan')
          .get();

      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).where((data) {
        final diff = data['difficulty'] as int? ?? 1;
        return diff <= difficulty;
      }).toList();

      // Sort by created_at desc
      list.sort((a, b) {
        final aTime = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      DailyGyaan? todayGyaan;
      // Pick a pseudo-random one based on today's date for consistency
      if (list.isNotEmpty) {
        final dayIndex = DateTime.now().day % list.length;
        todayGyaan = DailyGyaan.fromJson(list[dayIndex]);
      } else {
        // Fallback Sample Data for UI Demo
        todayGyaan = DailyGyaan(
          id: 'sample_today',
          title: 'The Eternal Witness',
          content: 'Know that you are the eternal witness, untouched by the tides of time. In the silence of your heart, the universe speaks.',
          difficulty: 2,
          createdAt: DateTime.now(),
        );
      }

      // Cache for today
      await CacheService.instance.cacheDailyGyaan(todayGyaan);
      return todayGyaan;
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
      List<DailyGyaan> list = [];
      final cached = CacheService.instance.getCachedAllGyaan();
      if (cached != null) {
        list = cached;
      } else {
        final snapshot = await FirebaseFirestore.instance
            .collection('daily_gyaan')
            .get();

        final apiList = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return DailyGyaan.fromJson(data);
        }).toList();

        // Sort by created_at desc
        apiList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        list = apiList;
        await CacheService.instance.cacheAllGyaan(list);
      }

      // Filter by difficulty locally
      if (difficulty != null) {
        list = list.where((e) => e.difficulty == difficulty).toList();
      }

      // Add high-quality samples for UI demonstration
      return [
        ...list,
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
      // Try cache first
      final cached = CacheService.instance.getCachedUpcomingEvents();
      if (cached != null) {
        return cached;
      }

      final today = DateTime.now().toIso8601String().split('T')[0];
      
      final snapshot = await FirebaseFirestore.instance
          .collection('sacred_calendar')
          .get();

      final apiList = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return SacredEvent.fromJson(data);
      }).where((e) {
        final dateStr = e.date.toIso8601String().split('T')[0];
        return dateStr.compareTo(today) >= 0;
      }).toList();

      // Sort by date ascending
      apiList.sort((a, b) => a.date.compareTo(b.date));

      final resultList = [
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

      // Save to cache
      await CacheService.instance.cacheUpcomingEvents(resultList);
      return resultList.take(limit).toList();
    } catch (e) {
      debugPrint('Error fetching events: $e');
      return [];
    }
  }

  /// Fetch events for a specific month
  Future<List<SacredEvent>> getEventsForMonth(int year, int month) async {
    try {
      // Try cache first
      final cached = CacheService.instance.getCachedMonthlyEvents(year, month);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('sacred_calendar')
          .get();

      var resultList = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return SacredEvent.fromJson(data);
      }).where((e) {
        return e.date.year == year && e.date.month == month;
      }).toList();

      if (resultList.isEmpty) {
        resultList = _generateMockEventsForMonth(year, month);
      }

      // Sort ascending by date
      resultList.sort((a, b) => a.date.compareTo(b.date));

      // Save to cache
      await CacheService.instance.cacheMonthlyEvents(year, month, resultList);
      return resultList;
    } catch (e) {
      debugPrint('Error fetching monthly events: $e');
      return _generateMockEventsForMonth(year, month);
    }
  }

  List<SacredEvent> _generateMockEventsForMonth(int year, int month) {
    final List<SacredEvent> list = [];

    // 1. Ekadashi 1 (11th)
    list.add(
      SacredEvent(
        id: 'mock-ekadashi-1-$month',
        title: 'Sharda Ekadashi Vrat',
        date: DateTime(year, month, 11),
        type: 'ekadashi',
        description: 'Fasting and meditation on the 11th lunar day to purify mind and senses.',
        createdAt: DateTime.now(),
      ),
    );

    // 2. Pradosh Vrat (13th)
    list.add(
      SacredEvent(
        id: 'mock-pradosh-1-$month',
        title: 'Pradosh Vrat',
        date: DateTime(year, month, 13),
        type: 'vrat',
        description: 'Fasting and twilight devotion dedicated to Lord Shiva.',
        createdAt: DateTime.now(),
      ),
    );

    // 3. Purnima (15th)
    list.add(
      SacredEvent(
        id: 'mock-purnima-$month',
        title: 'Purnima Snan & Daan',
        date: DateTime(year, month, 15),
        type: 'purnima',
        description: 'Sacred bathing and charitable giving under the full moon.',
        createdAt: DateTime.now(),
      ),
    );

    // 4. Ekadashi 2 (25th)
    list.add(
      SacredEvent(
        id: 'mock-ekadashi-2-$month',
        title: 'Kamada Ekadashi Vrat',
        date: DateTime(year, month, 25),
        type: 'ekadashi',
        description: 'Vrat to release spiritual blockages and bring purity.',
        createdAt: DateTime.now(),
      ),
    );

    // 5. Surya Sankranti (14th)
    list.add(
      SacredEvent(
        id: 'mock-sankranti-$month',
        title: 'Surya Sankranti',
        date: DateTime(year, month, 14),
        type: 'tithi',
        description: 'Sun transition marking the entry into a new zodiac sign.',
        createdAt: DateTime.now(),
      ),
    );

    // Month-specific festivals
    switch (month) {
      case 1:
        list.add(SacredEvent(id: 'fest-1-$month', title: 'Makar Sankranti / Pongal', date: DateTime(year, month, 14), type: 'utsav', description: 'Harvest festival celebrating the transition of the Sun to Uttarayan.', createdAt: DateTime.now()));
        break;
      case 2:
        list.add(SacredEvent(id: 'fest-2-$month', title: 'Maha Shivratri', date: DateTime(year, month, 24), type: 'utsav', description: 'The great night of Shiva celebrating the cosmic dance of creation.', createdAt: DateTime.now()));
        break;
      case 3:
        list.add(SacredEvent(id: 'fest-3-$month', title: 'Holi / Gaura Purnima', date: DateTime(year, month, 28), type: 'utsav', description: 'Festival of colors and appearance day of Sri Chaitanya Mahaprabhu.', createdAt: DateTime.now()));
        break;
      case 4:
        list.add(SacredEvent(id: 'fest-4-$month', title: 'Rama Navami', date: DateTime(year, month, 9), type: 'utsav', description: 'Celebration of the appearance day of Lord Sri Ramachandra.', createdAt: DateTime.now()));
        break;
      case 5:
        list.add(SacredEvent(id: 'fest-5-$month', title: 'Narasimha Jayanti', date: DateTime(year, month, 22), type: 'utsav', description: 'Appearance day of Lord Narasimhadeva, the divine protector.', createdAt: DateTime.now()));
        break;
      case 6:
        list.add(SacredEvent(id: 'fest-6-$month', title: 'Ganga Dussehra', date: DateTime(year, month, 18), type: 'utsav', description: 'Descent of Holy River Ganga to the earthly plane.', createdAt: DateTime.now()));
        break;
      case 7:
        list.add(SacredEvent(id: 'fest-7-$month', title: 'Guru Purnima', date: DateTime(year, month, 19), type: 'utsav', description: 'Honoring spiritual masters, sages, and Vyasadeva.', createdAt: DateTime.now()));
        break;
      case 8:
        list.add(SacredEvent(id: 'fest-8-$month', title: 'Sri Krishna Janmashtami', date: DateTime(year, month, 25), type: 'utsav', description: 'The historic appearance of Lord Krishna, speaker of Bhagavad Gita.', createdAt: DateTime.now()));
        break;
      case 9:
        list.add(SacredEvent(id: 'fest-9-$month', title: 'Radhashtami', date: DateTime(year, month, 10), type: 'utsav', description: 'The divine appearance day of Srimati Radharani.', createdAt: DateTime.now()));
        break;
      case 10:
        list.add(SacredEvent(id: 'fest-10-$month', title: 'Vijayadashami / Dussehra', date: DateTime(year, month, 12), type: 'utsav', description: 'Triumph of righteousness over evil, Lord Rama defeating Ravana.', createdAt: DateTime.now()));
        break;
      case 11:
        list.add(SacredEvent(id: 'fest-11-$month', title: 'Diwali / Kartik Deepotsav', date: DateTime(year, month, 1), type: 'utsav', description: 'Festival of lights marking the return of Lord Rama to Ayodhya.', createdAt: DateTime.now()));
        break;
      case 12:
        list.add(SacredEvent(id: 'fest-12-$month', title: 'Gita Jayanti', date: DateTime(year, month, 21), type: 'utsav', description: 'The day Lord Krishna spoke the Bhagavad Gita to Arjuna.', createdAt: DateTime.now()));
        break;
    }

    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  /// Fetch today's events
  Future<List<SacredEvent>> getTodayEvents() async {
    try {
      // Try cache first
      final cached = CacheService.instance.getCachedTodayEvents();
      if (cached != null) {
        return cached;
      }

      final today = DateTime.now().toIso8601String().split('T')[0];
      
      final snapshot = await FirebaseFirestore.instance
          .collection('sacred_calendar')
          .get();

      final apiList = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return SacredEvent.fromJson(data);
      }).where((e) {
        final dateStr = e.date.toIso8601String().split('T')[0];
        return dateStr == today;
      }).toList();
          
      List<SacredEvent> resultList = apiList;
      // Ensure Today has an event for UI Demo
      if (apiList.isEmpty) {
        resultList = [
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

      // Save to cache
      await CacheService.instance.cacheTodayEvents(resultList);
      return resultList;
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
      final snapshot = await FirebaseFirestore.instance
          .collection('user_achievements')
          .where('firebase_uid', isEqualTo: uid)
          .get();

      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return UserAchievement.fromJson(data);
          })
          .toList();
    } catch (e) {
      debugPrint('Error fetching achievements: $e');
      return [];
    }
  }

  /// Unlock an achievement
  Future<bool> unlockAchievement(String uid, String achievementId) async {
    try {
      final id = '${uid}_$achievementId';
      await FirebaseFirestore.instance.collection('user_achievements').doc(id).set({
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
      // Try local cache first
      final cached = CacheService.instance.getCachedDailyChallenges();
      if (cached != null) {
        return cached;
      }

      // Get challenges matching user level
      final snapshot = await FirebaseFirestore.instance
          .collection('daily_challenges')
          .get();

      final challenges = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return DailyChallenge.fromJson(data);
      }).where((c) => c.minLevel <= userLevel).take(3).toList();

      if (challenges.isEmpty) return [];

      // Fetch user progress for these challenges
      final progressSnapshot = await FirebaseFirestore.instance
          .collection('user_challenge_progress')
          .where('firebase_uid', isEqualTo: uid)
          .get();

      final progressMap = <String, Map<String, dynamic>>{};
      for (var doc in progressSnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        final challengeId = data['challenge_id']?.toString();
        if (challengeId != null) {
          progressMap[challengeId] = data;
        }
      }

      // Merge progress into challenges
      final merged = challenges.map((challenge) {
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

      // Save to cache
      await CacheService.instance.cacheDailyChallenges(merged);
      return merged;
    } catch (e) {
      debugPrint('Error fetching challenges: $e');
      return [];
    }
  }

  /// Update challenge progress
  Future<void> updateChallengeProgress(
      String uid, String challengeId, int newValue, bool completed) async {
    // Optimistically update local cache
    try {
      final cached = CacheService.instance.getCachedDailyChallenges();
      if (cached != null) {
        final updated = cached.map((c) {
          if (c.id == challengeId) {
            return c.copyWith(
              currentValue: newValue,
              isCompleted: completed,
              completedAt: completed ? DateTime.now() : null,
            );
          }
          return c;
        }).toList();
        await CacheService.instance.cacheDailyChallenges(updated);
      }
    } catch (e) {
      debugPrint('Error updating local challenge cache: $e');
    }

    // Sync with Firestore in background
    try {
      final progressId = '${uid}_$challengeId';
      await FirebaseFirestore.instance
          .collection('user_challenge_progress')
          .doc(progressId)
          .set({
            'firebase_uid': uid,
            'challenge_id': challengeId,
            'current_value': newValue,
            'is_completed': completed,
            if (completed)
              'completed_at': DateTime.now().toUtc().toIso8601String(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating challenge progress: $e');
    }
  }
}
