class DailyGyaan {
  final String id;
  final String title;
  final String content;
  final String? mediaUrl;
  final String? mediaType; // image, video, audio
  final int difficulty; // 1=beginner, 2=intermediate, 3=advanced
  final String? category;
  final DateTime createdAt;

  DailyGyaan({
    required this.id,
    required this.title,
    required this.content,
    this.mediaUrl,
    this.mediaType,
    this.difficulty = 1,
    this.category,
    required this.createdAt,
  });

  factory DailyGyaan.fromJson(Map<String, dynamic> json) {
    return DailyGyaan(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      mediaUrl: json['media_url'],
      mediaType: json['media_type'],
      difficulty: json['difficulty'] ?? 1,
      category: json['category'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'media_url': mediaUrl,
        'media_type': mediaType,
        'difficulty': difficulty,
        'category': category,
      };
}
