import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for managing favorites with Supabase sync
class FavoritesNotifier extends StateNotifier<Set<String>> {
  final SupabaseClient _supabase = Supabase.instance.client;

  FavoritesNotifier() : super({}) {
    _loadFavorites();
  }

  User? get _currentUser => _supabase.auth.currentUser;

  /// Load favorites from Supabase for the current user
  Future<void> _loadFavorites() async {
    if (_currentUser == null) {
      state = {};
      return;
    }

    try {
      final response = await _supabase
          .from('favorites')
          .select('content_id')
          .eq('user_id', _currentUser!.id);

      final favoriteIds = (response as List)
          .map((item) => item['content_id'] as String)
          .toSet();

      state = favoriteIds;
    } catch (e) {
      // Gracefully handle missing table - use local-only favorites
      print('Favorites sync unavailable (table may not exist): $e');
      // Keep current state, don't reset to empty
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
    if (_currentUser == null) return;

    // Optimistic update
    state = {...state, contentId};

    try {
      await _supabase.from('favorites').insert({
        'user_id': _currentUser!.id,
        'content_id': contentId,
      });
    } catch (e) {
      // Keep local state even if server sync fails
      print('Favorites sync failed (continuing locally): $e');
    }
  }

  /// Remove a content item from favorites
  Future<void> removeFavorite(String contentId) async {
    if (_currentUser == null) return;

    // Optimistic update
    final newState = {...state};
    newState.remove(contentId);
    state = newState;

    try {
      await _supabase
          .from('favorites')
          .delete()
          .eq('user_id', _currentUser!.id)
          .eq('content_id', contentId);
    } catch (e) {
      // Keep local state even if server sync fails
      print('Favorites sync failed (continuing locally): $e');
    }
  }

  /// Refresh favorites from server
  Future<void> refresh() async {
    await _loadFavorites();
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
