class DailyMotivation {
  final String id;
  final String content;
  final String? source;
  final int minLevel;
  final int maxLevel;
  final String category; // general, naam_jap, reading, sadhana
  final String language;
  final DateTime createdAt;

  DailyMotivation({
    required this.id,
    required this.content,
    this.source,
    this.minLevel = 1,
    this.maxLevel = 99,
    this.category = 'general',
    this.language = 'hi',
    required this.createdAt,
  });

  factory DailyMotivation.fromJson(Map<String, dynamic> json) {
    return DailyMotivation(
      id: json['id']?.toString() ?? '',
      content: json['content'] ?? '',
      source: json['source'],
      minLevel: json['min_level'] ?? 1,
      maxLevel: json['max_level'] ?? 99,
      category: json['category'] ?? 'general',
      language: json['language'] ?? 'hi',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'content': content,
        'source': source,
        'min_level': minLevel,
        'max_level': maxLevel,
        'category': category,
        'language': language,
      };
}
