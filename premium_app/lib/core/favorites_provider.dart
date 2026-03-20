import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing favorites with Supabase sync
class FavoritesNotifier extends StateNotifier<Set<String>> {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _storageKey = 'saved_sacred_content_ids';

  FavoritesNotifier() : super({}) {
    _initAndLoad();
  }

  User? get _currentUser => _supabase.auth.currentUser;

  /// Initialize and load favorites with multi-tier priority
  Future<void> _initAndLoad() async {
    // 1. FAST: Load from local storage immediately
    await _loadFromLocal();
    
    // 2. SYNC: Load from Supabase in background
    if (_currentUser != null) {
      _loadFromSupabase();
    }
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_storageKey);
      if (saved != null) {
        state = saved.toSet();
      }
    } catch (e) {
    }
  }

  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, state.toList());
    } catch (e) {
    }
  }

  /// Load favorites from Supabase for the current user
  Future<void> _loadFromSupabase() async {
    if (_currentUser == null) return;

    try {
      final response = await _supabase
          .from('favorites')
          .select('content_id')
          .eq('user_id', _currentUser!.id);

      final favoriteIds = (response as List)
          .map((item) => item['content_id'] as String)
          .toSet();

      if (favoriteIds.isNotEmpty) {
        state = {...state, ...favoriteIds};
        await _saveToLocal();
      }
    } catch (e) {
    }
  }

  /// Check if a content item is favorited
  bool isFavorite(String contentId) {
    return state.contains(contentId);
  }

  /// Toggle favorite status for a content item
  Future<void> toggleFavorite(String contentId) async {
    if (isFavorite(contentId)) {
      await removeFavorite(contentId);
    } else {
      await addFavorite(contentId);
    }
  }

  /// Add a content item to favorites
  Future<void> addFavorite(String contentId) async {
    // Always update local state for immediate feedback and guest support
    state = {...state, contentId};
    await _saveToLocal();

    // Sync with Supabase only if authenticated
    if (_currentUser != null) {
      try {
        await _supabase.from('favorites').insert({
          'user_id': _currentUser!.id,
          'content_id': contentId,
        });
      } catch (e) {
        // Log error but keep local state
      }
    }
  }

  /// Remove a content item from favorites
  Future<void> removeFavorite(String contentId) async {
    // Always update local state
    final newState = {...state};
    newState.remove(contentId);
    state = newState;
    await _saveToLocal();

    // Sync with Supabase only if authenticated
    if (_currentUser != null) {
      try {
        await _supabase
            .from('favorites')
            .delete()
            .eq('user_id', _currentUser!.id)
            .eq('content_id', contentId);
      } catch (e) {
        // Log error
      }
    }
  }

  /// Refresh favorites from server
  Future<void> refresh() async {
    await _loadFromSupabase();
  }

  /// Get all favorite content IDs
  List<String> get favoriteIds => state.toList();
}

/// Provider for favorites
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>(
  (ref) {
    return FavoritesNotifier();
  },
);

/// Provider to check if a specific content is favorited
final isFavoriteProvider = Provider.family<bool, String>((ref, contentId) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.contains(contentId);
});
