class SacredEvent {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final String type; // vrat, utsav, tithi, ekadashi, purnima
  final bool isRecurring;
  final String? imageUrl;
  final DateTime createdAt;

  SacredEvent({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    required this.type,
    this.isRecurring = false,
    this.imageUrl,
    required this.createdAt,
  });

  factory SacredEvent.fromJson(Map<String, dynamic> json) {
    return SacredEvent(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      date: DateTime.parse(json['date'].toString()),
      type: json['type'] ?? 'utsav',
      isRecurring: json['is_recurring'] ?? false,
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'date': date.toIso8601String().split('T')[0],
        'type': type,
        'is_recurring': isRecurring,
        'image_url': imageUrl,
      };

  /// Check if the event is today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Check if the event is upcoming (within next 7 days)
  bool get isUpcoming {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    return diff >= 0 && diff <= 7;
  }

  /// Display-friendly type label
  String get typeLabel {
    switch (type) {
      case 'vrat':
        return '🕉️ व्रत';
      case 'utsav':
        return '🎉 उत्सव';
      case 'tithi':
        return '📅 तिथि';
      case 'ekadashi':
        return '🌙 एकादशी';
      case 'purnima':
        return '🌕 पूर्णिमा';
      default:
        return '📿 आध्यात्मिक';
    }
  }
}
