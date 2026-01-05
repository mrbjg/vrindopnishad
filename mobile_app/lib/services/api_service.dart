import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../core/content_provider.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api';
    return 'http://localhost:8000/api';
  }

  static Future<List<SacredContent>> fetchAllContent() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/content'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> contentList = data['content'];
          return contentList.map((json) => _mapJsonToContent(json)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching content: $e');
      return [];
    }
  }

  static SacredContent _mapJsonToContent(Map<String, dynamic> json) {
    return SacredContent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      sanskritText: json['sanskrit_text'] ?? '',
      translation: json['english_translation'] ?? '',
      hindiMeaning: json['hindi_text'] ?? '',
      commentary: json['description'] ?? '',
      imageUrl:
          (json['image_urls'] != null &&
              (json['image_urls'] as List).isNotEmpty)
          ? (json['image_urls'] as List)[0].toString()
          : null,
    );
  }
}
