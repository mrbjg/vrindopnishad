import 'dart:convert';

class JournalEntry {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String? moonPhase;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.moonPhase,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'moonPhase': moonPhase,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      moonPhase: json['moonPhase'],
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
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      moonPhase: moonPhase ?? this.moonPhase,
    );
  }
}
