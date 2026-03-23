class JournalEntry {
  final String id;
  final String firebaseUid;
  final String title;
  final String content;
  final DateTime createdAt;
  final String? moonPhase;

  JournalEntry({
    required this.id,
    required this.firebaseUid,
    required this.title,
    required this.content,
    required this.createdAt,
    this.moonPhase,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebase_uid': firebaseUid,
      'title': title,
      'content': content,
      'created_at': createdAt.toUtc().toIso8601String(),
      'moon_phase': moonPhase,
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
    );
  }

  JournalEntry copyWith({
    String? title,
    String? content,
    DateTime? createdAt,
    String? moonPhase,
  }) {
    return JournalEntry(
      id: id,
      firebaseUid: firebaseUid,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      moonPhase: moonPhase ?? this.moonPhase,
    );
  }
}
