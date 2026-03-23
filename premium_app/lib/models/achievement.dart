class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon; // emoji
  final int xpBonus;
  final String condition; // e.g. 'streak_7', 'malas_108', 'shlokas_50'
  final int targetValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.xpBonus = 100,
    required this.condition,
    required this.targetValue,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  /// All possible achievements defined client-side
  static List<Achievement> get allAchievements => [
        Achievement(
          id: 'pranaam',
          title: 'प्रणाम',
          description: 'Complete your first spiritual session',
          icon: '🌅',
          xpBonus: 50,
          condition: 'total_jap_count',
          targetValue: 1,
        ),
        Achievement(
          id: 'agni_7',
          title: 'अग्नि',
          description: 'Maintain a 7-day streak',
          icon: '🔥',
          xpBonus: 200,
          condition: 'streak_count',
          targetValue: 7,
        ),
        Achievement(
          id: 'agni_30',
          title: 'महाअग्नि',
          description: 'Maintain a 30-day streak',
          icon: '🔥',
          xpBonus: 1000,
          condition: 'streak_count',
          targetValue: 30,
        ),
        Achievement(
          id: 'mala_master',
          title: 'माला मास्टर',
          description: 'Complete 108 malas total',
          icon: '📿',
          xpBonus: 500,
          condition: 'total_malas',
          targetValue: 108,
        ),
        Achievement(
          id: 'vidya',
          title: 'विद्या',
          description: 'Read 50 shlokas',
          icon: '📖',
          xpBonus: 300,
          condition: 'total_shlokas_read',
          targetValue: 50,
        ),
        Achievement(
          id: 'dhyana',
          title: 'ध्यान',
          description: 'Complete 30 rituals',
          icon: '🧘',
          xpBonus: 400,
          condition: 'rituals_completed',
          targetValue: 30,
        ),
        Achievement(
          id: 'tapasvi',
          title: 'तपस्वी',
          description: 'Reach Level 16',
          icon: '⭐',
          xpBonus: 1000,
          condition: 'level',
          targetValue: 16,
        ),
        Achievement(
          id: 'siddha',
          title: 'सिद्ध',
          description: 'Reach Level 31',
          icon: '🏔️',
          xpBonus: 2000,
          condition: 'level',
          targetValue: 31,
        ),
        Achievement(
          id: 'sahasra',
          title: 'सहस्र',
          description: 'Complete 1008 chants in a single day',
          icon: '👑',
          xpBonus: 500,
          condition: 'daily_jap_count',
          targetValue: 1008,
        ),
      ];

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['achievement_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🏆',
      xpBonus: json['xp_bonus'] ?? 100,
      condition: json['condition'] ?? '',
      targetValue: json['target_value'] ?? 0,
      isUnlocked: json['unlocked_at'] != null,
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.parse(json['unlocked_at'].toString())
          : null,
    );
  }
}

class UserAchievement {
  final String id;
  final String firebaseUid;
  final String achievementId;
  final DateTime unlockedAt;

  UserAchievement({
    required this.id,
    required this.firebaseUid,
    required this.achievementId,
    required this.unlockedAt,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      id: json['id']?.toString() ?? '',
      firebaseUid: json['firebase_uid'] ?? '',
      achievementId: json['achievement_id'] ?? '',
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.parse(json['unlocked_at'].toString())
          : DateTime.now(),
    );
  }
}
