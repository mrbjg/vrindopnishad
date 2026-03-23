import '../models/user_stats.dart';
import '../models/achievement.dart';

/// Spirituality levels inspired by Duolingo's progression system
enum SpiritualityLevel {
  seeker,   // Level 1-5: Beginners, gentle guidance
  sadhak,   // Level 6-15: Regular practitioners, intermediate
  tapasvi,  // Level 16-30: Advanced, deeper practices
  siddha,   // Level 31+: Mastery, teaching mode
}

class SpiritualityEngine {
  const SpiritualityEngine._();

  // ─── Level Detection ───────────────────────────────────────

  /// Detect the user's spirituality tier from their stats
  static SpiritualityLevel detectLevel(int userLevel) {
    if (userLevel >= 31) return SpiritualityLevel.siddha;
    if (userLevel >= 16) return SpiritualityLevel.tapasvi;
    if (userLevel >= 6) return SpiritualityLevel.sadhak;
    return SpiritualityLevel.seeker;
  }

  /// XP needed for next level (scales with level)
  static int xpForLevel(int level) => level * 1000;

  /// Calculate XP multiplier based on streak
  static double xpMultiplier(int streakCount) {
    if (streakCount >= 30) return 2.0;
    if (streakCount >= 14) return 1.5;
    if (streakCount >= 7) return 1.25;
    if (streakCount >= 3) return 1.1;
    return 1.0;
  }

  // ─── Personalized Motivation ───────────────────────────────

  /// Get a contextual encouragement message based on user state
  static String getContextualMotivation({
    required int streakCount,
    required int level,
    required int todayJapCount,
    required int dailyGoal,
  }) {
    // Streak-based messages
    if (streakCount == 0) {
      return 'आज नई शुरुआत करें! एक छोटा कदम बड़ी यात्रा की शुरुआत है। 🌱';
    }
    if (streakCount >= 30) {
      return '🔥 $streakCount दिन! आप सच्चे तपस्वी हैं। आपकी साधना प्रेरणादायक है!';
    }
    if (streakCount >= 7) {
      return '🔥 $streakCount दिनों से लगातार! अद्भुत! रुकना मत!';
    }

    // Daily progress messages
    final goalPercent = dailyGoal > 0 ? (todayJapCount / (dailyGoal * 108)) : 0.0;
    if (goalPercent >= 1.0) {
      return '🎉 आज का लक्ष्य पूरा! आप अद्भुत हैं! और जाप करें या ज्ञान पढ़ें।';
    }
    if (goalPercent >= 0.5) {
      return '💪 आधा लक्ष्य पूरा! बस थोड़ा और। हर जाप आपको करीब ला रहा है।';
    }

    // Level-based messages
    final tier = detectLevel(level);
    switch (tier) {
      case SpiritualityLevel.seeker:
        return '🌅 साधना का सफर शुरू करें। छोटी शुरुआत ही बड़ी सफलता का आधार है।';
      case SpiritualityLevel.sadhak:
        return '📿 आपकी साधना गहरी हो रही है। नियमित अभ्यास से सिद्धि मिलती है।';
      case SpiritualityLevel.tapasvi:
        return '⭐ तपस्वी, आपका तप अब फल दे रहा है। और ऊंचा उड़ें!';
      case SpiritualityLevel.siddha:
        return '🏔️ सिद्ध भक्त, आपकी साधना अनुपम है। अब दूसरों को मार्ग दिखाएं।';
    }
  }

  // ─── Achievement Checking ──────────────────────────────────

  /// Check which achievements the user has newly earned
  static List<Achievement> checkNewAchievements({
    required UserStats stats,
    required Set<String> alreadyUnlocked,
    int todayJapCount = 0,
    int ritualsCompleted = 0,
  }) {
    final newlyEarned = <Achievement>[];

    for (final achievement in Achievement.allAchievements) {
      if (alreadyUnlocked.contains(achievement.id)) continue;

      bool earned = false;

      switch (achievement.condition) {
        case 'total_jap_count':
          earned = stats.totalJapCount >= achievement.targetValue;
          break;
        case 'streak_count':
          earned = stats.streakCount >= achievement.targetValue;
          break;
        case 'total_malas':
          earned = (stats.totalJapCount ~/ 108) >= achievement.targetValue;
          break;
        case 'total_shlokas_read':
          earned = stats.totalShlokasRead >= achievement.targetValue;
          break;
        case 'level':
          earned = stats.level >= achievement.targetValue;
          break;
        case 'daily_jap_count':
          earned = todayJapCount >= achievement.targetValue;
          break;
        case 'rituals_completed':
          earned = ritualsCompleted >= achievement.targetValue;
          break;
      }

      if (earned) {
        newlyEarned.add(achievement);
      }
    }

    return newlyEarned;
  }

  // ─── Content Difficulty ────────────────────────────────────

  /// Map user level to content difficulty for gyaan
  static int contentDifficulty(int userLevel) {
    if (userLevel >= 21) return 3;
    if (userLevel >= 11) return 2;
    return 1;
  }

  /// Get the title for a spirituality level
  static String levelTitle(SpiritualityLevel level) {
    switch (level) {
      case SpiritualityLevel.seeker:
        return 'साधक (Seeker)';
      case SpiritualityLevel.sadhak:
        return 'साधक (Practitioner)';
      case SpiritualityLevel.tapasvi:
        return 'तपस्वी (Ascetic)';
      case SpiritualityLevel.siddha:
        return 'सिद्ध (Enlightened)';
    }
  }

  /// Get description for spirituality level
  static String levelDescription(SpiritualityLevel level) {
    switch (level) {
      case SpiritualityLevel.seeker:
        return 'आप अपनी आध्यात्मिक यात्रा की शुरुआत में हैं। नियमित साधना से आप आगे बढ़ेंगे।';
      case SpiritualityLevel.sadhak:
        return 'आपकी साधना नियमित हो रही है। गहरे ज्ञान और कठिन अभ्यास के लिए तैयार हो रहे हैं।';
      case SpiritualityLevel.tapasvi:
        return 'आपका तप और समर्पण अद्भुत है। अब गहन आध्यात्मिक ज्ञान आपके लिए उपलब्ध है।';
      case SpiritualityLevel.siddha:
        return 'आप सिद्धि की ओर हैं। आपकी साधना दूसरों के लिए प्रेरणा है।';
    }
  }

  // ─── Daily Challenge Generation ─────────────────────────────

  /// Suggested daily mala goal based on level
  static int suggestedDailyGoal(int userLevel) {
    if (userLevel >= 31) return 21;
    if (userLevel >= 16) return 11;
    if (userLevel >= 6) return 5;
    return 1;
  }
}
