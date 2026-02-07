import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_helper.dart';
import 'cache_service.dart';
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
    _initAndLoad();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final CacheService _cache = CacheService.instance;

  /// Initialize cache and load data with priority
  Future<void> _initAndLoad() async {
    _isLoading = true;

    // 1. Initialize cache service
    await _cache.init();

    // 2. INSTANT: Load from memory cache if available
    final cachedContent = _cache.getCachedContent();
    if (cachedContent != null && cachedContent.isNotEmpty) {
      state = cachedContent;
      _isLoading = false;

      // Background refresh from API for freshness
      _backgroundRefresh();
      return;
    }

    // 3. FAST: Load from local SQLite DB
    final dbContent = await DatabaseHelper.instance.fetchAllContent();
    if (dbContent.isNotEmpty) {
      state = dbContent;
      await _cache.cacheContent(dbContent);
      _isLoading = false;

      // Background refresh from API
      _backgroundRefresh();
      return;
    }

    // 4. SLOW: Fetch from Supabase API (first load or empty cache)
    await _fetchFromApi();
    _isLoading = false;
  }

  /// Background refresh from API (doesn't block UI)
  Future<void> _backgroundRefresh() async {
    try {
      final apiContent = await ApiService.fetchAllContent();
      if (apiContent.isNotEmpty) {
        // Update local DB
        await DatabaseHelper.instance.deleteAllContent();
        for (var item in apiContent) {
          await DatabaseHelper.instance.insertContent(item);
        }
        // Update cache
        await _cache.cacheContent(apiContent);
        // Update state (smooth transition)
        state = apiContent;
      }
    } catch (e) {
      // Silent fail - we already have cached data
      print('Background refresh failed: $e');
    }
  }

  /// Fetch from API (blocking)
  Future<void> _fetchFromApi() async {
    try {
      final apiContent = await ApiService.fetchAllContent();
      if (apiContent.isNotEmpty) {
        await DatabaseHelper.instance.deleteAllContent();
        for (var item in apiContent) {
          await DatabaseHelper.instance.insertContent(item);
        }
        await _cache.cacheContent(apiContent);
        state = apiContent;
      }
    } catch (e) {
      print('API fetch failed: $e');
    }
  }

  /// Force refresh content from Supabase
  Future<void> refresh() async {
    _isLoading = true;
    await _fetchFromApi();
    _isLoading = false;
  }

  /// Fetch content filtered by category (with caching)
  Future<List<SacredContent>> fetchByCategory(String category) async {
    // Check cache first
    final cached = _cache.getCachedByCategory(category);
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    try {
      return await ApiService.fetchAllContent(category: category);
    } catch (e) {
      // Fallback to filtering local state
      return state
          .where(
            (item) => item.category.toLowerCase() == category.toLowerCase(),
          )
          .toList();
    }
  }

  /// Search content
  Future<List<SacredContent>> search(String query) async {
    try {
      return await ApiService.searchContent(query);
    } catch (e) {
      // Fallback to local search
      final lowerQuery = query.toLowerCase();
      return state
          .where(
            (item) =>
                item.title.toLowerCase().contains(lowerQuery) ||
                item.sanskritText.toLowerCase().contains(lowerQuery) ||
                item.hindiMeaning.toLowerCase().contains(lowerQuery) ||
                item.translation.toLowerCase().contains(lowerQuery),
          )
          .toList();
    }
  }

  Future<void> addContent(SacredContent content) async {
    await DatabaseHelper.instance.insertContent(content);
    state = [...state, content];
    await _cache.cacheContent(state);
  }

  Future<void> removeContent(String id) async {
    await DatabaseHelper.instance.deleteContent(id);
    state = state.where((item) => item.id != id).toList();
    await _cache.cacheContent(state);
  }
}

final sacredContentProvider =
    StateNotifierProvider<ContentNotifier, List<SacredContent>>((ref) {
      return ContentNotifier();
    });
