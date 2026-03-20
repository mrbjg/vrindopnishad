class UserStats {
  final String firebaseUid;
  final int level;
  final int experiencePoints;
  final int streakCount;
  final DateTime? lastActiveDate;
  final int totalReadingMinutes;
  final int totalShlokasRead;
  final int totalJapCount;
  final DateTime updatedAt;

  UserStats({
    required this.firebaseUid,
    this.level = 1,
    this.experiencePoints = 0,
    this.streakCount = 0,
    this.lastActiveDate,
    this.totalReadingMinutes = 0,
    this.totalShlokasRead = 0,
    this.totalJapCount = 0,
    required this.updatedAt,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      firebaseUid: json['firebase_uid'] ?? '',
      level: json['level'] ?? 1,
      experiencePoints: json['experience_points'] ?? 0,
      streakCount: json['streak_count'] ?? 0,
      lastActiveDate: json['last_active_date'] != null 
          ? DateTime.tryParse(json['last_active_date'].toString()) 
          : null,
      totalReadingMinutes: json['total_reading_minutes'] ?? 0,
      totalShlokasRead: json['total_shlokas_read'] ?? 0,
      totalJapCount: json['total_jap_count'] ?? 0,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'].toString()) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firebase_uid': firebaseUid,
      'level': level,
      'experience_points': experiencePoints,
      'streak_count': streakCount,
      'last_active_date': lastActiveDate?.toIso8601String().split('T')[0],
      'total_reading_minutes': totalReadingMinutes,
      'total_shlokas_read': totalShlokasRead,
      'total_jap_count': totalJapCount,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ReadingHistoryItem {
  final String id;
  final String firebaseUid;
  final String contentId;
  final String? title;
  final String? category;
  final DateTime readAt;

  ReadingHistoryItem({
    required this.id,
    required this.firebaseUid,
    required this.contentId,
    this.title,
    this.category,
    required this.readAt,
  });

  factory ReadingHistoryItem.fromJson(Map<String, dynamic> json) {
    return ReadingHistoryItem(
      id: json['id']?.toString() ?? '',
      firebaseUid: json['firebase_uid'] ?? '',
      contentId: json['content_id'] ?? '',
      title: json['title'],
      category: json['category'],
      readAt: json['read_at'] != null 
          ? DateTime.parse(json['read_at'].toString()) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firebase_uid': firebaseUid,
      'content_id': contentId,
      'title': title,
      'category': category,
      'read_at': readAt.toIso8601String(),
    };
  }
}
