import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_helper.dart';
import 'cache_service.dart';
import '../services/api_service.dart';
import '../services/realtime_service.dart';

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

  // Pre-processed display strings for high performance
  late final String displayTitle;
  late final String sanskritPreview;

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
  }) {
    _initializePreProcessed();
  }

  void _initializePreProcessed() {
    displayTitle = title.replaceAll('\n', ', ');

    // Pre-format sanskrit preview
    final parts = sanskritText
        .split(RegExp(r'[।॥\|!?,.\n]'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      sanskritPreview = sanskritText;
    } else {
      sanskritPreview = parts.take(2).join(', ');
    }
  }

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SacredContent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          category == other.category &&
          sanskritText == other.sanskritText &&
          imageUrl == other.imageUrl &&
          audioUrl == other.audioUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      category.hashCode ^
      sanskritText.hashCode ^
      imageUrl.hashCode ^
      audioUrl.hashCode;

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
    // Start with the featured sample so it's never truly empty
    state = [_featuredSample];
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

    // 2. Start Realtime Listener (Sync with Supabase)
    RealtimeService.instance.subscribeToContentChanges(() {
      _backgroundRefresh();
    });

    // 3. INSTANT: Load from memory cache if available
    final cachedContent = _cache.getCachedContent();
    if (cachedContent != null && cachedContent.isNotEmpty) {
      state = [_featuredSample, ...cachedContent];
      _isLoading = false;

      // Background refresh from API for freshness
      _backgroundRefresh();
      return;
    }

    // 4. FAST: Load from local SQLite DB
    final dbContent = await DatabaseHelper.instance.fetchAllContent();
    if (dbContent.isNotEmpty) {
      state = [_featuredSample, ...dbContent];
      await _cache.cacheContent(dbContent);
      _isLoading = false;

      _backgroundRefresh();
      return;
    }

    // 5. SLOW: Fetch from Supabase API (first load or empty cache)
    await _fetchFromApi();
    _isLoading = false;
  }

  /// Background refresh from API (doesn't block UI)
  Future<void> _backgroundRefresh() async {
    try {
      final apiContent = await ApiService.fetchAllContent();
      if (apiContent.isNotEmpty) {
        // Compare with current state (excluding the sample) to avoid unnecessary rebuilds
        final currentContent = state.where((item) => item.id != _featuredSample.id).toList();
        
        bool isChanged = apiContent.length != currentContent.length;
        if (!isChanged) {
          for (int i = 0; i < apiContent.length; i++) {
            if (apiContent[i] != currentContent[i]) {
              isChanged = true;
              break;
            }
          }
        }

        if (isChanged) {
          // Update local DB
          await DatabaseHelper.instance.deleteAllContent();
          for (var item in apiContent) {
            await DatabaseHelper.instance.insertContent(item);
          }
          // Update cache
          await _cache.cacheContent(apiContent);
          // Update state (smooth transition)
          state = [_featuredSample, ...apiContent];
        }
      }
    } catch (e) {
      // Silent fail - ensure we at least keep the sample if state was empty
      if (state.isEmpty) state = [_featuredSample];
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
        state = [_featuredSample, ...apiContent];
      } else if (state.isEmpty) {
        state = [_featuredSample];
      }
    } catch (e) {
      if (state.isEmpty) state = [_featuredSample];
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

  /// User-requested featured streaming content
  final SacredContent _featuredSample = SacredContent(
    id: 'stream-sample-001',
    title: 'Aise Kaal Bitayo Nis Din',
    category: 'Featured Bhajan',
    sanskritText: 'ऐसे काल बितायो निस दिन...',
    translation: 'How time was spent, day and night...',
    hindiMeaning: 'इस प्रकार दिन-रात काल व्यतीत हुआ। ब्रज के रसिक संत श्री वंशी अली जी का भजन भाव।',
    commentary: 'A soulful bhajan expressing devotion and the passage of time in spiritual practice.',
    audioUrl: 'https://archive.org/download/aise-kaal-bitayo-nis-din/aise%20kaal%20bitayo%20nis%20din.mp3',
    imageUrl: 'assets/images/sant_sanatan.png',
  );
}

final sacredContentProvider =
    StateNotifierProvider<ContentNotifier, List<SacredContent>>((ref) {
      return ContentNotifier();
    });

/// ═══════════════════════════════════════════════════════════════════════════
/// MEMOIZED PROVIDERS - Prevent expensive filtering on every build/frame
/// ═══════════════════════════════════════════════════════════════════════════

/// Provider that returns content filtered by category name
final filteredContentProvider = Provider.family<List<SacredContent>, String>((
  ref,
  category,
) {
  final allContent = ref.watch(sacredContentProvider);
  if (category.isEmpty || category.toLowerCase() == 'all') return allContent;

  return allContent
      .where((item) => item.category.toLowerCase() == category.toLowerCase())
      .toList();
});

/// Provider that returns content filtered by search query
final searchedContentProvider = Provider.family<List<SacredContent>, String>((
  ref,
  query,
) {
  final allContent = ref.watch(sacredContentProvider);
  if (query.isEmpty) return [];

  final lowerQuery = query.toLowerCase();
  return allContent
      .where(
        (item) =>
            item.title.toLowerCase().contains(lowerQuery) ||
            item.translation.toLowerCase().contains(lowerQuery) ||
            item.category.toLowerCase().contains(lowerQuery),
      )
      .toList();
});
