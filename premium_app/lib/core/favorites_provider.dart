import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing favorites with Cloud Firestore sync
class FavoritesNotifier extends StateNotifier<Set<String>> {
  static const String _storageKey = 'saved_sacred_content_ids';

  FavoritesNotifier() : super({}) {
    _initAndLoad();
  }

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  /// Initialize and load favorites with multi-tier priority
  Future<void> _initAndLoad() async {
    // 1. FAST: Load from local storage immediately
    await _loadFromLocal();
    
    // 2. SYNC: Load from Firestore in background
    if (_currentUser != null) {
      _loadFromFirestore();
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
      // Ignore local load errors
    }
  }

  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, state.toList());
    } catch (e) {
      // Ignore local save errors
    }
  }

  /// Load favorites from Firestore for the current user
  Future<void> _loadFromFirestore() async {
    if (_currentUser == null) return;

    try {
      final response = await FirebaseFirestore.instance
          .collection('favorites')
          .where('user_id', isEqualTo: _currentUser!.uid)
          .get();

      final favoriteIds = response.docs
          .map((item) => item.data()['content_id'] as String)
          .toSet();

      if (favoriteIds.isNotEmpty) {
        state = {...state, ...favoriteIds};
        await _saveToLocal();
      }
    } catch (e) {
      // Ignore Firestore sync errors
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

    // Sync with Firestore only if authenticated
    if (_currentUser != null) {
      try {
        final favId = '${_currentUser!.uid}_$contentId';
        await FirebaseFirestore.instance.collection('favorites').doc(favId).set({
          'user_id': _currentUser!.uid,
          'content_id': contentId,
          'created_at': DateTime.now().toUtc().toIso8601String(),
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

    // Sync with Firestore only if authenticated
    if (_currentUser != null) {
      try {
        final favId = '${_currentUser!.uid}_$contentId';
        await FirebaseFirestore.instance
            .collection('favorites')
            .doc(favId)
            .delete();
      } catch (e) {
        // Log error
      }
    }
  }

  /// Refresh favorites from server
  Future<void> refresh() async {
    await _loadFromFirestore();
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
