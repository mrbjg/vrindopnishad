class DailyChallenge {
  final String id;
  final String title;
  final String? description;
  final String type; // naam_jap, reading, ritual, meditation
  final int targetValue;
  final int xpReward;
  final int minLevel;
  final DateTime? date;
  final DateTime createdAt;

  // User-specific progress
  final int currentValue;
  final bool isCompleted;
  final DateTime? completedAt;

  DailyChallenge({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.targetValue,
    this.xpReward = 100,
    this.minLevel = 1,
    this.date,
    required this.createdAt,
    this.currentValue = 0,
    this.isCompleted = false,
    this.completedAt,
  });

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      type: json['type'] ?? 'naam_jap',
      targetValue: json['target_value'] ?? 108,
      xpReward: json['xp_reward'] ?? 100,
      minLevel: json['min_level'] ?? 1,
      date: json['date'] != null ? DateTime.parse(json['date'].toString()) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      currentValue: json['current_value'] ?? 0,
      isCompleted: json['is_completed'] ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'type': type,
        'target_value': targetValue,
        'xp_reward': xpReward,
        'min_level': minLevel,
        'date': date?.toIso8601String().split('T')[0],
      };

  double get progressPercent =>
      targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;

  String get typeIcon {
    switch (type) {
      case 'naam_jap':
        return '📿';
      case 'reading':
        return '📖';
      case 'ritual':
        return '🕉️';
      case 'meditation':
        return '🧘';
      default:
        return '⭐';
    }
  }

  String get typeLabel {
    switch (type) {
      case 'naam_jap':
        return 'Naam Jap';
      case 'reading':
        return 'Reading';
      case 'ritual':
        return 'Ritual';
      case 'meditation':
        return 'Meditation';
      default:
        return 'Spiritual';
    }
  }

  DailyChallenge copyWith({
    int? currentValue,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return DailyChallenge(
      id: id,
      title: title,
      description: description,
      type: type,
      targetValue: targetValue,
      xpReward: xpReward,
      minLevel: minLevel,
      date: date,
      createdAt: createdAt,
      currentValue: currentValue ?? this.currentValue,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
