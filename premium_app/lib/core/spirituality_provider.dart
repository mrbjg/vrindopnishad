import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/spiritual_content_service.dart';
import '../models/daily_motivation.dart';
import '../models/daily_gyaan.dart';
import '../models/sacred_event.dart';
import '../models/achievement.dart';
import '../models/daily_challenge.dart';
import 'spirituality_engine.dart';
import 'stats_provider.dart';

/// Singleton service provider
final spiritualContentServiceProvider = Provider<SpiritualContentService>((ref) {
  return SpiritualContentService();
});

/// User's spirituality level tier
final spiritualityLevelProvider = Provider<SpiritualityLevel>((ref) {
  final statsAsync = ref.watch(userStatsProvider);
  return statsAsync.whenOrNull(
    data: (stats) => SpiritualityEngine.detectLevel(stats?.level ?? 1),
  ) ?? SpiritualityLevel.seeker;
});

/// Daily motivation for the user
final dailyMotivationProvider = FutureProvider<DailyMotivation?>((ref) async {
  final service = ref.read(spiritualContentServiceProvider);
  final statsAsync = ref.watch(userStatsProvider);
  final level = statsAsync.whenOrNull(data: (stats) => stats?.level ?? 1) ?? 1;
  return service.getDailyMotivation(level);
});

/// Daily Gyaan for the user
final dailyGyaanProvider = FutureProvider<DailyGyaan?>((ref) async {
  final service = ref.read(spiritualContentServiceProvider);
  final statsAsync = ref.watch(userStatsProvider);
  final level = statsAsync.whenOrNull(data: (stats) => stats?.level ?? 1) ?? 1;
  return service.getDailyGyaan(level);
});

/// All gyaan content for browsing
final allGyaanProvider = FutureProvider<List<DailyGyaan>>((ref) async {
  final service = ref.read(spiritualContentServiceProvider);
  return service.getAllGyaan();
});

/// Upcoming sacred events
final upcomingEventsProvider = FutureProvider<List<SacredEvent>>((ref) async {
  final service = ref.read(spiritualContentServiceProvider);
  return service.getUpcomingEvents(limit: 10);
});

/// Today's sacred events
final todayEventsProvider = FutureProvider<List<SacredEvent>>((ref) async {
  final service = ref.read(spiritualContentServiceProvider);
  return service.getTodayEvents();
});

/// Events for a specific month (parameterized)
final monthlyEventsProvider =
    FutureProvider.family<List<SacredEvent>, ({int year, int month})>(
        (ref, params) async {
  final service = ref.read(spiritualContentServiceProvider);
  return service.getEventsForMonth(params.year, params.month);
});

/// User's unlocked achievements
final userAchievementsProvider =
    FutureProvider<List<UserAchievement>>((ref) async {
  final service = ref.read(spiritualContentServiceProvider);
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];
  return service.getUserAchievements(user.uid);
});

/// Full achievement list with unlock status
final achievementsWithStatusProvider =
    FutureProvider<List<Achievement>>((ref) async {
  final unlocked = await ref.watch(userAchievementsProvider.future);
  final unlockedIds = unlocked.map((e) => e.achievementId).toSet();

  return Achievement.allAchievements.map((a) {
    if (unlockedIds.contains(a.id)) {
      return Achievement(
        id: a.id,
        title: a.title,
        description: a.description,
        icon: a.icon,
        xpBonus: a.xpBonus,
        condition: a.condition,
        targetValue: a.targetValue,
        isUnlocked: true,
        unlockedAt: unlocked
            .firstWhere((u) => u.achievementId == a.id)
            .unlockedAt,
      );
    }
    return a;
  }).toList();
});

/// Daily challenges with progress
final dailyChallengesProvider =
    FutureProvider<List<DailyChallenge>>((ref) async {
  final service = ref.read(spiritualContentServiceProvider);
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];

  final statsAsync = ref.watch(userStatsProvider);
  final level = statsAsync.whenOrNull(data: (stats) => stats?.level ?? 1) ?? 1;

  return service.getDailyChallenges(user.uid, level);
});

/// Contextual motivation message
final contextualMotivationProvider = Provider<String>((ref) {
  final statsAsync = ref.watch(userStatsProvider);
  return statsAsync.whenOrNull(
    data: (stats) {
      if (stats == null) {
        return 'आज से अपनी आध्यात्मिक यात्रा शुरू करें! 🌱';
      }
      return SpiritualityEngine.getContextualMotivation(
        streakCount: stats.streakCount,
        level: stats.level,
        todayJapCount: 0, // Will be refined with actual today count
        dailyGoal: stats.dailyMalaGoal,
      );
    },
  ) ?? 'हरि ॐ! आज का दिन शुभ हो। 🙏';
});

/// XP multiplier based on streak
final xpMultiplierProvider = Provider<double>((ref) {
  final statsAsync = ref.watch(userStatsProvider);
  return statsAsync.whenOrNull(
    data: (stats) => SpiritualityEngine.xpMultiplier(stats?.streakCount ?? 0),
  ) ?? 1.0;
});
