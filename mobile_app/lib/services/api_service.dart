import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/content_provider.dart';

/// API Service that fetches data directly from Supabase
class ApiService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all content from the Supabase 'content' table
  static Future<List<SacredContent>> fetchAllContent({String? category}) async {
    try {
      var query = _supabase
          .from('content')
          .select()
          .order('created_at', ascending: false);

      if (category != null && category.isNotEmpty) {
        query = _supabase
            .from('content')
            .select()
            .eq('category', category)
            .order('created_at', ascending: false);
      }

      final List<dynamic> data = await query;
      return data.map((json) => _mapJsonToContent(json)).toList();
    } catch (e) {
      debugPrint('Error fetching content from Supabase: $e');
      return [];
    }
  }

  /// Fetch a single content item by ID
  static Future<SacredContent?> fetchContentById(String id) async {
    try {
      final data = await _supabase
          .from('content')
          .select()
          .eq('id', id)
          .single();

      return _mapJsonToContent(data);
    } catch (e) {
      debugPrint('Error fetching content by ID: $e');
      return null;
    }
  }

  /// Fetch all unique categories from the content table
  static Future<List<String>> fetchCategories() async {
    try {
      final List<dynamic> data = await _supabase
          .from('content')
          .select('category');

      final categories = data
          .map((item) => item['category'] as String?)
          .where((cat) => cat != null && cat.isNotEmpty)
          .toSet()
          .cast<String>()
          .toList();

      return categories;
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }

  /// Search content by title or description
  static Future<List<SacredContent>> searchContent(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final List<dynamic> data = await _supabase
          .from('content')
          .select()
          .or('title.ilike.%$query%,sanskrit_text.ilike.%$query%,hindi_text.ilike.%$query%,english_translation.ilike.%$query%')
          .order('created_at', ascending: false)
          .limit(50);

      return data.map((json) => _mapJsonToContent(json)).toList();
    } catch (e) {
      debugPrint('Error searching content: $e');
      return [];
    }
  }

  /// Map Supabase JSON to SacredContent model
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
    );
  }
}
