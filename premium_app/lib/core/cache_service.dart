import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'content_provider.dart';
import '../models/daily_motivation.dart';
import '../models/daily_gyaan.dart';
import '../models/sacred_event.dart';
import '../models/daily_challenge.dart';

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
  static const Duration _cacheExpiry = Duration(hours: 24); // Increased to 24 hours to reduce egress


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
      // Ignore cache loading errors
    }
  }

  /// Save cache to disk
  Future<void> _saveToDisk(List<SacredContent> content) async {
    try {
      final jsonList = content.map((c) => c.toMap()).toList();
      await _prefs?.setString(_contentCacheKey, json.encode(jsonList));
      await _prefs?.setString(_cacheTimeKey, DateTime.now().toIso8601String());
    } catch (e) {
      // Ignore cache saving errors
    }
  }

  /// Check if cache is still valid
  bool _isCacheValid() {
    if (_lastCacheTime == null) return false;
    return DateTime.now().difference(_lastCacheTime!) < _cacheExpiry;
  }

  /// Public accessor for cache validity
  bool isCacheValid() => _isCacheValid();

  /// Clear all caches
  Future<void> clearCache() async {
    _contentCache = null;
    _categoryCache = null;
    _lastCacheTime = null;
    await _prefs?.remove(_contentCacheKey);
    await _prefs?.remove(_cacheTimeKey);
  }

  /// Get any string from disk cache
  Future<String?> get(String key) async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getString(key);
  }

  /// Save any string to disk cache
  Future<void> set(String key, String value) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(key, value);
  }

  /// Get cache age string for debugging
  String? getCacheAge() {
    if (_lastCacheTime == null) return null;
    final age = DateTime.now().difference(_lastCacheTime!);
    if (age.inMinutes < 1) return 'Just now';
    if (age.inMinutes < 60) return '${age.inMinutes}m ago';
    return '${age.inHours}h ago';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DAILY DISK CACHING UTILITIES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Save object to cache (disk) with day-level validation
  Future<void> cacheDailyString(String key, String jsonStr) async {
    _prefs ??= await SharedPreferences.getInstance();
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    await _prefs!.setString('${key}_data', jsonStr);
    await _prefs!.setString('${key}_date', todayStr);
  }

  /// Get cached daily string if valid for today
  String? getDailyString(String key) {
    if (_prefs == null) return null;
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final cachedDate = _prefs!.getString('${key}_date');
    if (cachedDate == todayStr) {
      return _prefs!.getString('${key}_data');
    }
    return null;
  }

  // ─── Daily Motivation Cache ──────────────────────────────────

  Future<void> cacheDailyMotivation(DailyMotivation motivation) async {
    final Map<String, dynamic> data = {
      'id': motivation.id,
      'content': motivation.content,
      'source': motivation.source,
      'min_level': motivation.minLevel,
      'max_level': motivation.maxLevel,
      'category': motivation.category,
      'language': motivation.language,
      'created_at': motivation.createdAt.toIso8601String(),
    };
    await cacheDailyString('daily_motivation', json.encode(data));
  }

  DailyMotivation? getCachedDailyMotivation() {
    final str = getDailyString('daily_motivation');
    if (str != null) {
      try {
        return DailyMotivation.fromJson(json.decode(str));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // ─── Daily Gyaan Cache ────────────────────────────────────────

  Future<void> cacheDailyGyaan(DailyGyaan gyaan) async {
    final Map<String, dynamic> data = {
      'id': gyaan.id,
      'title': gyaan.title,
      'content': gyaan.content,
      'media_url': gyaan.mediaUrl,
      'media_type': gyaan.mediaType,
      'difficulty': gyaan.difficulty,
      'category': gyaan.category,
      'created_at': gyaan.createdAt.toIso8601String(),
    };
    await cacheDailyString('daily_gyaan', json.encode(data));
  }

  DailyGyaan? getCachedDailyGyaan() {
    final str = getDailyString('daily_gyaan');
    if (str != null) {
      try {
        return DailyGyaan.fromJson(json.decode(str));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // ─── All Gyaan List Cache ─────────────────────────────────────

  Future<void> cacheAllGyaan(List<DailyGyaan> list) async {
    final serialized = list.map((g) => {
      'id': g.id,
      'title': g.title,
      'content': g.content,
      'media_url': g.mediaUrl,
      'media_type': g.mediaType,
      'difficulty': g.difficulty,
      'category': g.category,
      'created_at': g.createdAt.toIso8601String(),
    }).toList();
    await cacheDailyString('all_gyaan', json.encode(serialized));
  }

  List<DailyGyaan>? getCachedAllGyaan() {
    final str = getDailyString('all_gyaan');
    if (str != null) {
      try {
        final List<dynamic> list = json.decode(str);
        return list.map((item) => DailyGyaan.fromJson(item)).toList();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // ─── Daily Challenges Cache ──────────────────────────────────

  Future<void> cacheDailyChallenges(List<DailyChallenge> challenges) async {
    final list = challenges.map((c) => {
      'id': c.id,
      'title': c.title,
      'description': c.description,
      'type': c.type,
      'target_value': c.targetValue,
      'xp_reward': c.xpReward,
      'min_level': c.minLevel,
      'date': c.date?.toIso8601String(),
      'created_at': c.createdAt.toIso8601String(),
      'current_value': c.currentValue,
      'is_completed': c.isCompleted,
      'completed_at': c.completedAt?.toIso8601String(),
    }).toList();
    await cacheDailyString('daily_challenges', json.encode(list));
  }

  List<DailyChallenge>? getCachedDailyChallenges() {
    final str = getDailyString('daily_challenges');
    if (str != null) {
      try {
        final List<dynamic> list = json.decode(str);
        return list.map((item) => DailyChallenge.fromJson(item)).toList();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // ─── Sacred Events Cache (Today & Upcoming & Monthly) ────────

  Future<void> cacheUpcomingEvents(List<SacredEvent> list) async {
    final serialized = list.map((e) => {
      'id': e.id,
      'title': e.title,
      'description': e.description,
      'date': e.date.toIso8601String(),
      'type': e.type,
      'is_recurring': e.isRecurring,
      'image_url': e.imageUrl,
      'created_at': e.createdAt.toIso8601String(),
    }).toList();
    await cacheDailyString('upcoming_events', json.encode(serialized));
  }

  List<SacredEvent>? getCachedUpcomingEvents() {
    final str = getDailyString('upcoming_events');
    if (str != null) {
      try {
        final List<dynamic> list = json.decode(str);
        return list.map((item) => SacredEvent.fromJson(item)).toList();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> cacheTodayEvents(List<SacredEvent> list) async {
    final serialized = list.map((e) => {
      'id': e.id,
      'title': e.title,
      'description': e.description,
      'date': e.date.toIso8601String(),
      'type': e.type,
      'is_recurring': e.isRecurring,
      'image_url': e.imageUrl,
      'created_at': e.createdAt.toIso8601String(),
    }).toList();
    await cacheDailyString('today_events', json.encode(serialized));
  }

  List<SacredEvent>? getCachedTodayEvents() {
    final str = getDailyString('today_events');
    if (str != null) {
      try {
        final List<dynamic> list = json.decode(str);
        return list.map((item) => SacredEvent.fromJson(item)).toList();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> cacheMonthlyEvents(int year, int month, List<SacredEvent> list) async {
    final serialized = list.map((e) => {
      'id': e.id,
      'title': e.title,
      'description': e.description,
      'date': e.date.toIso8601String(),
      'type': e.type,
      'is_recurring': e.isRecurring,
      'image_url': e.imageUrl,
      'created_at': e.createdAt.toIso8601String(),
    }).toList();
    await cacheDailyString('monthly_events_${year}_$month', json.encode(serialized));
  }

  List<SacredEvent>? getCachedMonthlyEvents(int year, int month) {
    final str = getDailyString('monthly_events_${year}_$month');
    if (str != null) {
      try {
        final List<dynamic> list = json.decode(str);
        return list.map((item) => SacredEvent.fromJson(item)).toList();
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

