import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_helper.dart';
import '../services/api_service.dart';

class SacredContent {
  final String id;
  final String title;
  final String category;
  final String sanskritText;
  final String translation;
  final String hindiMeaning;
  final String commentary;
  final String? imageUrl;
  final String? audioUrl;

  SacredContent({
    required this.id,
    required this.title,
    required this.category,
    required this.sanskritText,
    required this.translation,
    required this.hindiMeaning,
    required this.commentary,
    this.imageUrl,
    this.audioUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'sanskritText': sanskritText,
      'translation': translation,
      'hindiMeaning': hindiMeaning,
      'commentary': commentary,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
    };
  }

  factory SacredContent.fromMap(Map<String, dynamic> map) {
    return SacredContent(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      sanskritText: map['sanskritText'],
      translation: map['translation'],
      hindiMeaning: map['hindiMeaning'],
      commentary: map['commentary'],
      imageUrl: map['imageUrl'],
      audioUrl: map['audioUrl'],
    );
  }
}

class ContentNotifier extends StateNotifier<List<SacredContent>> {
  ContentNotifier() : super([]) {
    _loadFromDatabase();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> _loadFromDatabase() async {
    _isLoading = true;
    try {
      // 1. Try to fetch from Supabase (online mode)
      final apiContent = await ApiService.fetchAllContent();

      if (apiContent.isNotEmpty) {
        // 2. If successful, update local DB for offline support
        await DatabaseHelper.instance.deleteAllContent();
        for (var item in apiContent) {
          await DatabaseHelper.instance.insertContent(item);
        }
        state = apiContent;
        _isLoading = false;
        return;
      }
    } catch (e) {
      // Ignore API errors, fallback to local DB
      print("Supabase sync failed: $e");
    }

    // 3. Fallback to local DB (offline mode)
    final dbContent = await DatabaseHelper.instance.fetchAllContent();
    state = dbContent;
    _isLoading = false;
  }

  /// Refresh content from Supabase
  Future<void> refresh() async {
    await _loadFromDatabase();
  }

  /// Fetch content filtered by category
  Future<List<SacredContent>> fetchByCategory(String category) async {
    try {
      return await ApiService.fetchAllContent(category: category);
    } catch (e) {
      // Fallback to filtering local state
      return state.where((item) => 
        item.category.toLowerCase() == category.toLowerCase()
      ).toList();
    }
  }

  /// Search content
  Future<List<SacredContent>> search(String query) async {
    try {
      return await ApiService.searchContent(query);
    } catch (e) {
      // Fallback to local search
      final lowerQuery = query.toLowerCase();
      return state.where((item) =>
        item.title.toLowerCase().contains(lowerQuery) ||
        item.sanskritText.toLowerCase().contains(lowerQuery) ||
        item.hindiMeaning.toLowerCase().contains(lowerQuery) ||
        item.translation.toLowerCase().contains(lowerQuery)
      ).toList();
    }
  }

  // static final List<SacredContent> _initialContent = []; // Removed hardcoded data

  Future<void> addContent(SacredContent content) async {
    await DatabaseHelper.instance.insertContent(content);
    state = [...state, content];
  }

  Future<void> removeContent(String id) async {
    await DatabaseHelper.instance.deleteContent(id);
    state = state.where((item) => item.id != id).toList();
  }
}

final sacredContentProvider =
    StateNotifierProvider<ContentNotifier, List<SacredContent>>((ref) {
      return ContentNotifier();
    });
