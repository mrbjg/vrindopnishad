import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'content_provider.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// CACHE SERVICE - Fast data loading with memory + disk caching
/// ═══════════════════════════════════════════════════════════════════════════

class CacheService {
  static CacheService? _instance;
  static CacheService get instance => _instance ??= CacheService._();

  CacheService._();

  SharedPreferences? _prefs;

  // Memory cache for instant access
  List<SacredContent>? _contentCache;
  Map<String, List<SacredContent>>? _categoryCache;
  DateTime? _lastCacheTime;

  // Cache keys
  static const String _contentCacheKey = 'cached_content';
  static const String _cacheTimeKey = 'cache_timestamp';
  static const Duration _cacheExpiry = Duration(hours: 6);

  /// Initialize cache service
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _loadFromDisk();
  }

  /// Get cached content (instant from memory)
  List<SacredContent>? getCachedContent() {
    if (_contentCache != null && _isCacheValid()) {
      return _contentCache;
    }
    return null;
  }

  /// Get cached content by category
  List<SacredContent>? getCachedByCategory(String category) {
    _categoryCache ??= {};

    // Check if we have this category cached
    if (_categoryCache!.containsKey(category.toLowerCase())) {
      return _categoryCache![category.toLowerCase()];
    }

    // Try to filter from main cache
    if (_contentCache != null) {
      final filtered = _contentCache!
          .where((c) => c.category.toLowerCase() == category.toLowerCase())
          .toList();
      _categoryCache![category.toLowerCase()] = filtered;
      return filtered;
    }

    return null;
  }

  /// Save content to cache (memory + disk)
  Future<void> cacheContent(List<SacredContent> content) async {
    _contentCache = content;
    _lastCacheTime = DateTime.now();
    _categoryCache = {}; // Clear category cache to rebuild

    // Save to disk asynchronously
    _saveToDisk(content);
  }

  /// Load cache from disk
  Future<void> _loadFromDisk() async {
    try {
      final jsonStr = _prefs?.getString(_contentCacheKey);
      final timeStr = _prefs?.getString(_cacheTimeKey);

      if (jsonStr != null && timeStr != null) {
        _lastCacheTime = DateTime.tryParse(timeStr);

        if (_isCacheValid()) {
          final List<dynamic> jsonList = json.decode(jsonStr);
          _contentCache = jsonList
              .map(
                (item) => SacredContent.fromMap(item as Map<String, dynamic>),
              )
              .toList();
        }
      }
    } catch (e) {
      print('Cache load error: $e');
    }
  }

  /// Save cache to disk
  Future<void> _saveToDisk(List<SacredContent> content) async {
    try {
      final jsonList = content.map((c) => c.toMap()).toList();
      await _prefs?.setString(_contentCacheKey, json.encode(jsonList));
      await _prefs?.setString(_cacheTimeKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Cache save error: $e');
    }
  }

  /// Check if cache is still valid
  bool _isCacheValid() {
    if (_lastCacheTime == null) return false;
    return DateTime.now().difference(_lastCacheTime!) < _cacheExpiry;
  }

  /// Clear all caches
  Future<void> clearCache() async {
    _contentCache = null;
    _categoryCache = null;
    _lastCacheTime = null;
    await _prefs?.remove(_contentCacheKey);
    await _prefs?.remove(_cacheTimeKey);
  }

  /// Get cache age string for debugging
  String? getCacheAge() {
    if (_lastCacheTime == null) return null;
    final age = DateTime.now().difference(_lastCacheTime!);
    if (age.inMinutes < 1) return 'Just now';
    if (age.inMinutes < 60) return '${age.inMinutes}m ago';
    return '${age.inHours}h ago';
  }
}
