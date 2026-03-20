class Ritual {
  final String id;
  final String title;
  final String time; // e.g., "06:30 AM"
  final String? subtitle; // e.g., "12 Rounds"
  final String category; // e.g., "Morning", "Afternoon", "Evening"
  final bool isCompleted;
  final DateTime updatedAt;

  Ritual({
    required this.id,
    required this.title,
    required this.time,
    this.subtitle,
    required this.category,
    this.isCompleted = false,
    required this.updatedAt,
  });

  Ritual copyWith({
    String? title,
    String? time,
    String? subtitle,
    String? category,
    bool? isCompleted,
    DateTime? updatedAt,
  }) {
    return Ritual(
      id: id,
      title: title ?? this.title,
      time: time ?? this.time,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Ritual.fromJson(Map<String, dynamic> json) {
    return Ritual(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      time: json['time'] ?? '',
      subtitle: json['subtitle'],
      category: json['category'] ?? 'Morning',
      isCompleted: json['is_completed'] ?? false,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'].toString()) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'subtitle': subtitle,
      'category': category,
      'is_completed': isCompleted,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
