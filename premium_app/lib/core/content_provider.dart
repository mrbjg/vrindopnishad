import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
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

  // Computed properties for high-performance rendering
  String get displayTitle => title.replaceAll('\n', ', ');

  String get displayImageUrl {
    // 1. If we have a custom, valid image URL (not empty, and not the fallback placeholder vaani_icon), use it
    if (imageUrl != null &&
        imageUrl!.isNotEmpty &&
        imageUrl != 'assets/vaani_icon.png') {
      return imageUrl!;
    }

    // 2. Curate stunning, fast-loading Unsplash URLs per category to give variety
    final h = id.hashCode.abs();
    final categoryClean = category.trim().toLowerCase();

    // Sacred Shloka background images (ancient scriptures, sunset temples, oil lamps, holy rivers)
    final shlokaImages = [
      'https://images.unsplash.com/photo-1609137144813-7d7277884d20?auto=format&fit=crop&w=500&q=80', // Diya in dark
      'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=500&q=80', // Sunrise mountains
      'https://images.unsplash.com/photo-1470813740244-df37b8c1edcb?auto=format&fit=crop&w=500&q=80', // Starry night river
      'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?auto=format&fit=crop&w=500&q=80', // Temple silhouette at sunset
      'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=500&q=80', // Morning meditation
    ];

    // Devotional Bhajan images (flute, devotional instruments, peacock feather, chanting kirtan)
    final bhajanImages = [
      'https://images.unsplash.com/photo-1615412727883-f8a6797f883a?auto=format&fit=crop&w=500&q=80', // Indian traditional flute
      'https://images.unsplash.com/photo-1545127398-14699f92334b?auto=format&fit=crop&w=500&q=80', // Cymbals / Kirtan
      'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=500&q=80', // Fire ceremony / Diya light
      'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=500&q=80', // Classical musical vibes
    ];

    // Sacred Mantra images (glowing lotus, meditation posture, holy dawn)
    final mantraImages = [
      'https://images.unsplash.com/photo-1520262454112-9fe481d36ec3?auto=format&fit=crop&w=500&q=80', // Floating pink lotus flower
      'https://images.unsplash.com/photo-1512290923902-8a9f81dc236c?auto=format&fit=crop&w=500&q=80', // Warm glowing light
      'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?auto=format&fit=crop&w=500&q=80', // Peaceful nature walk
      'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=500&q=80', // Yoga / Lotus position silhouette
    ];

    // Satsang / Wisdom images (sages, holy discourse, spiritual assembly, forest trees)
    final satsangImages = [
      'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=500&q=80', // Sage studying / teaching
      'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?auto=format&fit=crop&w=500&q=80', // Peaceful sunset walk / landscape
      'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=500&q=80', // Sunlight through forest canopy
    ];

    // Dham / Temple images (Vrindavan, Yamuna river, ghats, ancient temples)
    final dhamImages = [
      'https://images.unsplash.com/photo-1590050752117-238cb0612b1b?auto=format&fit=crop&w=500&q=80', // Boats on river at sunrise
      'https://images.unsplash.com/photo-1564507592937-25994a9015b2?auto=format&fit=crop&w=500&q=80', // Majestic temple facade
      'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?auto=format&fit=crop&w=500&q=80', // Sunrise at a holy shrine
    ];

    // Saint / Guru / Sadhu images
    final saintImages = [
      'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=500&q=80', // Saffron monk
      'https://images.unsplash.com/photo-1470813740244-df37b8c1edcb?auto=format&fit=crop&w=500&q=80', // Morning river prayer
    ];

    // General / Fallback images (nature, peacocks, flowers)
    final generalImages = [
      'https://images.unsplash.com/photo-1528319725582-ddc096101511?auto=format&fit=crop&w=500&q=80', // Vibrant peacock feathers
      'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?auto=format&fit=crop&w=500&q=80', // Mystical forest haven
      'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=500&q=80', // Serene meditation vibe
    ];

    if (categoryClean.contains('shloka')) {
      return shlokaImages[h % shlokaImages.length];
    } else if (categoryClean.contains('bhajan') || categoryClean.contains('music') || categoryClean.contains('kirtan')) {
      return bhajanImages[h % bhajanImages.length];
    } else if (categoryClean.contains('mantra') || categoryClean.contains('japa')) {
      return mantraImages[h % mantraImages.length];
    } else if (categoryClean.contains('satsang') || categoryClean.contains('wisdom') || categoryClean.contains('general')) {
      return satsangImages[h % satsangImages.length];
    } else if (categoryClean.contains('dham') || categoryClean.contains('temple') || categoryClean.contains('mandir')) {
      return dhamImages[h % dhamImages.length];
    } else if (categoryClean.contains('saint') || categoryClean.contains('guru') || categoryClean.contains('sadhu')) {
      return saintImages[h % saintImages.length];
    }

    return generalImages[h % generalImages.length];
  }

  String get sanskritPreview {
    final parts = sanskritText
        .split(RegExp(r'[।॥\|!?,.\n]'))
        .where((s) => s.trim().isNotEmpty)
        .toList();
    return parts.isEmpty ? sanskritText : parts.take(2).join(', ');
  }

  IconData get categoryIcon {
    switch (category.toLowerCase()) {
      case 'mantras': return Iconsax.mask_1;
      case 'shlokas': return Iconsax.message_text;
      case 'bhajans': return Iconsax.music;
      case 'wisdom': return Iconsax.lamp_charge;
      case 'stories': return Iconsax.status_up;
      default: return Iconsax.folder_open;
    }
  }

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
  })  : _contentTags = contentTags ?? const [],
        _audioTags = audioTags ?? const [],
        _videoTags = videoTags ?? const [],
        _imageTags = imageTags ?? const [];

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
        imageUrl: _sanitizeImageUrl(map['imageUrl'] ?? map['image_url']),
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

  static String? _sanitizeImageUrl(dynamic url) {
    if (url == null) return null;
    final urlStr = url.toString();
    
    // Known 404 and Placeholder URL Interception
    if (urlStr.contains('photo-1518005020480-1090c13ce911') || 
        urlStr.contains('santvaani.app')) {
      return 'assets/vaani_icon.png';
    }
    
    return urlStr;
  }
}

class ContentNotifier extends StateNotifier<List<SacredContent>> {
  ContentNotifier() : super([]) {
    // Start with the featured samples so it's never truly empty
    state = _featuredSamples;
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
      state = [..._featuredSamples, ...cachedContent];
      _isLoading = false;

      // Background refresh from API only if cache is expired/invalid
      if (!_cache.isCacheValid()) {
        _backgroundRefresh();
      }
      return;
    }

    // 4. FAST: Load from local SQLite DB
    final dbContent = await DatabaseHelper.instance.fetchAllContent();
    if (dbContent.isNotEmpty) {
      state = [..._featuredSamples, ...dbContent];
      await _cache.cacheContent(dbContent);
      _isLoading = false;

      // SQLite loaded, but sync if cache is invalid
      if (!_cache.isCacheValid()) {
        _backgroundRefresh();
      }
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
        // Compare with current state (excluding samples) to avoid unnecessary rebuilds
        final sampleIds = _featuredSamples.map((s) => s.id).toSet();
        final currentContent = state.where((item) => !sampleIds.contains(item.id)).toList();
        
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
          state = [..._featuredSamples, ...apiContent];
        }
      }
    } catch (e) {
      // Silent fail - ensure we at least keep the sample if state was empty
      if (state.isEmpty) state = _featuredSamples;
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
        state = [..._featuredSamples, ...apiContent];
      } else if (state.isEmpty) {
        state = _featuredSamples;
      }
    } catch (e) {
      if (state.isEmpty) state = _featuredSamples;
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
  static final List<SacredContent> _featuredSamples = [
    SacredContent(
      id: 'stream-sample-001',
      title: 'Aise Kaal Bitayo Nis Din',
      category: 'Bhajans',
      sanskritText: 'ऐसे काल बितायो निस दिन...',
      translation: 'How time was spent, day and night...',
      hindiMeaning: 'इस प्रकार दिन-रात काल व्यतीत हुआ। ब्रज के रसिक संत श्री वंशी अली जी का भजन भाव।',
      commentary: 'A soulful bhajan expressing devotion and the passage of time in spiritual practice.',
      audioUrl: 'https://archive.org/download/aise-kaal-bitayo-nis-din/aise%20kaal%20bitayo%20nis%20din.mp3',
      imageUrl: 'https://images.unsplash.com/photo-1528319725582-ddc096101511?auto=format&fit=crop&w=800&q=80',
      author: 'Shri Vanshi Ali Ji',
      book: 'Rasik Vaani',
      chapter: 'Utsav Bela',
      contentTags: ['Bhakti', 'Vrindavan', 'Siddha-Vaani'],
      audioTags: ['Classical', 'Soothing'],
      videoTags: ['Live Darshan'],
    ),
    SacredContent(
      id: 'stream-sample-002',
      title: 'Mahamantra Japa',
      category: 'Mantras',
      sanskritText: 'हरे कृष्ण हरे कृष्ण कृष्ण कृष्ण हरे हरे...',
      translation: 'Hare Krishna Mahamantra...',
      hindiMeaning: 'दिव्य महामंत्र का जाप जो मन को शांति और आनंद प्रदान करता है।',
      commentary: 'The ultimate mantra for spiritual realization and inner peace.',
      audioUrl: 'https://archive.org/download/HareKrsnaMahamantra/2009-02-14-6-Bhajans-SriPrahlad.mp3',
      imageUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=400&q=80',
      author: 'Sri Prahlad Prabhu',
      contentTags: ['Mantra', 'Japa', 'Peace', 'Kirtan'],
    ),
    SacredContent(
      id: 'stream-sample-003',
      title: 'Gita Shloka 2.47',
      category: 'Shlokas',
      sanskritText: 'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।',
      translation: 'You have a right to perform your prescribed duties...',
      hindiMeaning: 'तुम्हारा अधिकार केवल कर्म करने में है, उसके फलों में कभी नहीं।',
      commentary: 'Lord Krishna teaching the essence of Karma Yoga to Arjuna.',
      imageUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=400&q=80',
      audioUrl: 'https://www.gitasupersite.iitk.ac.in/sites/default/files/audio/CHAP2/2-47.MP3',
      author: 'Lord Krishna',
      book: 'Bhagavad Gita',
      chapter: 'Chapter 2',
      contentTags: ['Wisdom', 'Karma', 'Yoga'],
    ),
  ];
}

final sacredContentProvider =
    StateNotifierProvider<ContentNotifier, List<SacredContent>>((ref) {
  return ContentNotifier();
});

/// UI category data model for deriving category metadata
class CategoryInfo {
  final String name;
  final int count;
  final String imageUrl;

  CategoryInfo({
    required this.name,
    required this.count,
    required this.imageUrl,
  });
}

/// Provider that calculates unique categories and their associated metadata
final sacredCategoriesProvider = Provider<List<CategoryInfo>>((ref) {
  final content = ref.watch(sacredContentProvider);
  if (content.isEmpty) return [];

  final categoriesMap = <String, int>{};
  final categoryImages = <String, String>{};

  for (final item in content) {
    final cat = item.category;
    categoriesMap[cat] = (categoriesMap[cat] ?? 0) + 1;
    if (item.imageUrl != null && !categoryImages.containsKey(cat)) {
      categoryImages[cat] = item.imageUrl!;
    }
  }

  // Fallback images for common categories if not found in content
  final fallbackImages = {
    'Mantras': 'https://images.unsplash.com/photo-1520262454112-9fe481d36ec3?auto=format&fit=crop&w=400&q=80',
    'Shlokas': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=400&q=80',
    'Bhajans': 'https://images.unsplash.com/photo-1470813740244-df37b8c1edcb?auto=format&fit=crop&w=400&q=80',
    'Satsang': 'https://images.unsplash.com/photo-1545127398-14699f92334b?auto=format&fit=crop&w=400&q=80',
    'Stories': 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?auto=format&fit=crop&w=400&q=80',
    'General': 'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?auto=format&fit=crop&w=400&q=80',
    'Saint': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=400&q=80',
    'Dham': 'https://images.unsplash.com/photo-1590050752117-238cb0612b1b?auto=format&fit=crop&w=400&q=80',
  };

  return categoriesMap.entries.map((e) {
    return CategoryInfo(
      name: e.key,
      count: e.value,
      imageUrl: categoryImages[e.key] ??
          fallbackImages[e.key] ??
          'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=800&q=80',
    );
  }).toList();
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
