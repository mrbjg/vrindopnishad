class JournalEntry {
  final String id;
  final String firebaseUid;
  final String title;
  final String content;
  final DateTime createdAt;
  final String? moonPhase;
  final List<String> likedBy;

  JournalEntry({
    required this.id,
    required this.firebaseUid,
    required this.title,
    required this.content,
    required this.createdAt,
    this.moonPhase,
    this.likedBy = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebase_uid': firebaseUid,
      'title': title,
      'content': content,
      'created_at': createdAt.toUtc().toIso8601String(),
      'moon_phase': moonPhase,
      'liked_by': likedBy,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'],
      firebaseUid: json['firebase_uid'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      moonPhase: json['moon_phase'],
      likedBy: List<String>.from(json['liked_by'] ?? []),
    );
  }

  JournalEntry copyWith({
    String? title,
    String? content,
    DateTime? createdAt,
    String? moonPhase,
    List<String>? likedBy,
  }) {
    return JournalEntry(
      id: id,
      firebaseUid: firebaseUid,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      moonPhase: moonPhase ?? this.moonPhase,
      likedBy: likedBy ?? this.likedBy,
    );
  }
}
