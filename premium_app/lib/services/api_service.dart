import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/content_provider.dart';

/// API Service that fetches data directly from Cloud Firestore
class ApiService {
  /// Fetch all content from the Firestore 'content' collection
  static Future<List<SacredContent>> fetchAllContent({String? category}) async {
    try {
      Query query = FirebaseFirestore.instance.collection('content');

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      QuerySnapshot snapshot;
      try {
        snapshot = await query.orderBy('created_at', descending: true).get();
      } catch (e) {
        debugPrint('Firestore orderBy created_at failed (likely missing index): $e. Querying without order.');
        snapshot = await query.get();
      }

      final List<SacredContent> contentList = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return _mapJsonToContent(data);
      }).toList();

      return contentList;
    } catch (e) {
      debugPrint('Error fetching content from Firestore: $e');
      return [];
    }
  }

  /// Fetch a single content item by ID
  static Future<SacredContent?> fetchContentById(String id) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('content')
          .doc(id)
          .get();

      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return _mapJsonToContent(data);
    } catch (e) {
      debugPrint('Error fetching content by ID: $e');
      return null;
    }
  }

  /// Fetch all unique categories from the content table
  static Future<List<String>> fetchCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('content')
          .get();

      final categories = snapshot.docs
          .map((doc) => doc.data()['category'] as String?)
          .where((cat) => cat != null && cat.isNotEmpty)
          .map((cat) => cat!)
          .toSet()
          .toList();

      return categories;
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }

  /// Search content by title or description
  static Future<List<SacredContent>> searchContent(String queryStr) async {
    try {
      if (queryStr.trim().isEmpty) return [];

      final snapshot = await FirebaseFirestore.instance
          .collection('content')
          .get();

      final lowerQuery = queryStr.toLowerCase();
      final List<SacredContent> results = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        final content = _mapJsonToContent(data);

        if (content.title.toLowerCase().contains(lowerQuery) ||
            content.sanskritText.toLowerCase().contains(lowerQuery) ||
            content.hindiMeaning.toLowerCase().contains(lowerQuery) ||
            content.translation.toLowerCase().contains(lowerQuery) ||
            content.commentary.toLowerCase().contains(lowerQuery)) {
          results.add(content);
        }
      }

      return results.take(50).toList();
    } catch (e) {
      debugPrint('Error searching content: $e');
      return [];
    }
  }

  /// Map Firestore JSON to SacredContent model
  static SacredContent _mapJsonToContent(Map<String, dynamic> json) {
    // Handle image_url (single) or image_urls (array)
    String? imageUrl;
    if (json['image_url'] != null && json['image_url'].toString().isNotEmpty) {
      imageUrl = json['image_url'];
    } else if (json['image_urls'] != null && (json['image_urls'] as List).isNotEmpty) {
      imageUrl = (json['image_urls'] as List)[0].toString();
    }

    // Handle audio_url
    String? audioUrl;
    if (json['audio_url'] != null && json['audio_url'].toString().isNotEmpty) {
      audioUrl = json['audio_url'];
    }

    return SacredContent(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      sanskritText: json['sanskrit_text'] ?? '',
      translation: json['english_translation'] ?? '',
      hindiMeaning: json['hindi_text'] ?? '',
      commentary: json['description'] ?? '',
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      author: json['author'],
      book: json['book'],
      section: json['section'],
      chapter: json['chapter'],
      heading: json['heading'],
      contentTags: _parseTags(json['tags']),
      audioTags: _parseTags(json['audio_tags']),
      videoTags: _parseTags(json['video_tags']),
      imageTags: _parseTags(json['image_tags']),
    );
  }

  static List<String> _parseTags(dynamic val) {
    if (val == null) return [];
    if (val is List) return val.map((e) => e.toString()).toList();
    if (val is String) return val.split(',').where((t) => t.trim().isNotEmpty).toList();
    return [];
  }
}
