import 'package:flutter/foundation.dart';
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
  final String? author;
  final String? book;
  final String? section;
  final String? chapter;
  final String? heading;
  
  // Fail-safe persistent storage for contentTags
  final List<String>? _contentTags;
  final List<String>? _audioTags;
  final List<String>? _videoTags;
  final List<String>? _imageTags;

  // Safe Public Getters
  List<String> get contentTags => _contentTags ?? const [];
  List<String> get audioTags => _audioTags ?? const [];
  List<String> get videoTags => _videoTags ?? const [];
  List<String> get imageTags => _imageTags ?? const [];

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
    this.author,
    this.book,
    this.section,
    this.chapter,
    this.heading,
    List<String>? contentTags,
    List<String>? audioTags,
    List<String>? videoTags,
    List<String>? imageTags,
  })  : this._contentTags = contentTags ?? const [],
        this._audioTags = audioTags ?? const [],
        this._videoTags = videoTags ?? const [],
        this._imageTags = imageTags ?? const [] {
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
      'author': author,
      'book': book,
      'section': section,
      'chapter': chapter,
      'heading': heading,
      'tags': contentTags.join(','),
      'audioTags': audioTags.join(','),
      'videoTags': videoTags.join(','),
      'imageTags': imageTags.join(','),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SacredContent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          category == other.category;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ category.hashCode;

  factory SacredContent.fromMap(Map<String, dynamic> map) {
    List<String> parseList(dynamic val) {
      if (val == null) return [];
      if (val is List) return val.map((e) => e.toString()).toList();
      if (val is String) {
        if (val.trim().isEmpty) return [];
        return val
            .split(',')
            .map((e) => e.trim())
            .where((t) => t.isNotEmpty)
            .toList();
      }
      return [];
    }

    try {
      return SacredContent(
        id: (map['id'] ?? '').toString(),
        title: (map['title'] ?? '').toString(),
        category: (map['category'] ?? '').toString(),
        sanskritText: (map['sanskritText'] ?? map['sanskrit_text'] ?? '').toString(),
        translation: (map['translation'] ?? map['english_translation'] ?? '').toString(),
        hindiMeaning: (map['hindiMeaning'] ?? map['hindi_text'] ?? '').toString(),
        commentary: (map['commentary'] ?? map['description'] ?? '').toString(),
        imageUrl: map['imageUrl'] ?? map['image_url'],
        audioUrl: map['audioUrl'] ?? map['audio_url'],
        author: map['author'],
        book: map['book'],
        section: map['section'],
        chapter: map['chapter'],
        heading: map['heading'],
        contentTags: parseList(map['tags']),
        audioTags: parseList(map['audioTags'] ?? map['audio_tags']),
        videoTags: parseList(map['videoTags'] ?? map['video_tags']),
        imageTags: parseList(map['imageTags'] ?? map['image_tags']),
      );
    } catch (e) {
      debugPrint('Error mapping SacredContent: $e');
      return SacredContent(
        id: 'error',
        title: 'Error Loading Content',
        category: 'Error',
        sanskritText: '',
        translation: '',
        hindiMeaning: '',
        commentary: '',
      );
    }
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
    author: 'Shri Vanshi Ali Ji',
    book: 'Rasik Vaani',
    chapter: 'Utsav Bela',
    contentTags: ['Bhakti', 'Vrindavan', 'Siddha-Vaani'],
    audioTags: ['Classical', 'Soothing'],
    videoTags: ['Live Darshan'],
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
