import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_provider.dart';
import 'stats_provider.dart';
import 'cache_service.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }

  void toggleTheme(bool isDark) {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  /// Reset to follow system theme
  void useSystemTheme() {
    state = ThemeMode.system;
  }

  /// Check if currently using system theme
  bool get isSystemMode => state == ThemeMode.system;
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

enum AppLanguage { english, hindi, sanskrit }

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(AppLanguage.english);

  void setLanguage(AppLanguage language) {
    state = language;
  }

  String get languageName {
    switch (state) {
      case AppLanguage.english:
        return "English";
      case AppLanguage.hindi:
        return "Hindi";
      case AppLanguage.sanskrit:
        return "Sanskrit";
    }
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>((
  ref,
) {
  return LanguageNotifier();
});

/// Provider for managing visible item count in HomeScreen list (manual pagination)
final visibleItemCountProvider = StateProvider<int>((ref) => 5);

/// Provider to track previously animated count (items before this index won't re-animate)
final previouslyAnimatedCountProvider = StateProvider<int>((ref) => 5);

class NaamJapNotifier extends StateNotifier<int> {
  final SharedPreferences prefs;
  final Ref ref;

  NaamJapNotifier(this.prefs, this.ref) : super(0) {
    state = prefs.getInt('naam_jap_count') ?? 0;
  }

  Future<void> increment() async {
    state++;
    
    // New: Handle Mala completion (108 chants)
    if (state >= 108) {
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        // Log the completed Mala
        ref.read(statsServiceProvider).logJapActivity(user.uid, 108);
      }
      
      // Reset local counter to 0 for the next Mala
      state = 0;
      await prefs.setInt('naam_jap_count', 0);
      
      // Sync 0 to stats (though logJapActivity updates the total correctly)
      ref.read(userStatsProvider.notifier).syncJaps(0);
      return;
    }

    await prefs.setInt('naam_jap_count', state);
    
    // Sync total count (legacy sync)
    ref.read(userStatsProvider.notifier).syncJaps(state);
  }

  Future<void> reset() async {
    state = 0;
    await prefs.setInt('naam_jap_count', 0);
  }
}

final naamJapStateProvider = StateNotifierProvider<NaamJapNotifier, int>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return NaamJapNotifier(prefs, ref);
});

class OnboardingNotifier extends StateNotifier<bool> {
  final SharedPreferences prefs;

  OnboardingNotifier(this.prefs) : super(0.0 != 0.0) { // Using a dummy bool for super as it's set in constructor
    state = prefs.getBool('has_seen_onboarding') ?? false;
  }

  Future<void> completeOnboarding() async {
    state = true;
    await prefs.setBool('has_seen_onboarding', true);
  }
}

/// Provider to track if the user has completed the onboarding flow
final hasSeenOnboardingProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingNotifier(prefs);
});

/// Provider for the selected category in the Sacred Library
final navigationIndexProvider = StateProvider<int>((ref) => 0);

final libraryCategoryProvider = StateProvider<String>((ref) => "ALL");

final recentSearchesProvider = AsyncNotifierProvider<RecentSearchesNotifier, List<String>>(() {
  return RecentSearchesNotifier();
});

class RecentSearchesNotifier extends AsyncNotifier<List<String>> {
  static const _key = 'recent_sacred_searches';

  @override
  Future<List<String>> build() async {
    final cache = CacheService.instance;
    final data = await cache.get(_key);
    if (data == null) return [];
    return List<String>.from(jsonDecode(data));
  }

  Future<void> addSearch(String query) async {
    if (query.isEmpty) return;
    final current = state.value ?? [];
    final updated = [query, ...current.where((q) => q != query)].take(5).toList();
    state = AsyncValue.data(updated);
    await CacheService.instance.set(_key, jsonEncode(updated));
  }

  Future<void> clear() async {
    state = const AsyncValue.data([]);
    await CacheService.instance.set(_key, jsonEncode([]));
  }
}

/// Global Focus Mode provider for immersive spiritual experience
final focusModeProvider = StateProvider<bool>((ref) => false);
