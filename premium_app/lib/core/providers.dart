import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_provider.dart';
import 'stats_provider.dart';
import 'cache_service.dart';
import '../services/gamification_service.dart';

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

class NaamJapState {
  final int total;
  final int today;

  NaamJapState({required this.total, required this.today});
}

class NaamJapNotifier extends StateNotifier<NaamJapState> {
  final SharedPreferences prefs;
  final Ref ref;
  int _unsyncedCount = 0;

  NaamJapNotifier(this.prefs, this.ref) : super(NaamJapState(total: 0, today: 0)) {
    _init();
  }

  void _init() {
    final total = prefs.getInt('naam_jap_count') ?? 0;
    final lastDate = prefs.getString('naam_jap_last_date') ?? '';
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    
    int today = prefs.getInt('naam_jap_today_count') ?? 0;
    
    // Day reset logic
    if (lastDate != todayStr) {
      today = 0;
      prefs.setInt('naam_jap_today_count', 0);
      prefs.setString('naam_jap_last_date', todayStr);
    }
    
    state = NaamJapState(total: total, today: today);
  }

  DateTime _lastIncrementTime = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> increment(BuildContext context) async {
    final now = DateTime.now();
    // Throttle: max 3 taps per second (~333ms delay)
    if (now.difference(_lastIncrementTime).inMilliseconds < 333) {
      return;
    }
    _lastIncrementTime = now;

    final newTotal = state.total + 1;
    final newToday = state.today + 1;
    _unsyncedCount++;
    
    state = NaamJapState(total: newTotal, today: newToday);
    
    // Sync with prefs on every tap for local persistence
    await prefs.setInt('naam_jap_count', newTotal);
    await prefs.setInt('naam_jap_today_count', newToday);
    await prefs.setString('naam_jap_last_date', now.toIso8601String().split('T')[0]);

    // Update local UI state (optimistic)
    final statsNotifier = ref.read(userStatsProvider.notifier);
    if (ref.read(userStatsProvider).hasValue) {
      statsNotifier.updateTotalJapLocally(newTotal, newToday);
    }

    // Professional Milestone Sync (Every 27/quarter or 108/full Mala)
    // We log every 27 counts to ensure history is granular but not excessive
    if (_unsyncedCount >= 27 || newTotal % 108 == 0) {
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        final int syncNow = _unsyncedCount;
        _unsyncedCount = 0;
        
        // Log to Supabase (History + Total + Highest)
        await ref.read(statsServiceProvider).logJapActivity(
          user.uid, 
          syncNow, 
          todayCount: newToday,
        );
        
        // Complete Mala XP Award (Every 108)
        if (newTotal % 108 == 0 && context.mounted) {
          await ref.read(gamificationServiceProvider).awardXP(
            context,
            216, // 108 chants * 2 XP
            'Completed 1 Mala',
          );
        }
        
        // Refresh history and stats to keep everything in sync
        ref.invalidate(japHistoryProvider);
        ref.read(userStatsProvider.notifier).refresh();
      }
    }
  }

  Future<void> reset() async {
    state = NaamJapState(total: 0, today: 0);
    await prefs.setInt('naam_jap_count', 0);
    await prefs.setInt('naam_jap_today_count', 0);
  }
}

final naamJapStateProvider = StateNotifierProvider<NaamJapNotifier, NaamJapState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return NaamJapNotifier(prefs, ref);
});

class OnboardingNotifier extends StateNotifier<bool> {
  final SharedPreferences prefs;
  final Ref ref;

  OnboardingNotifier(this.prefs, this.ref) : super(false) {
    state = prefs.getBool('has_seen_onboarding') ?? false;
  }

  Future<void> completeOnboarding() async {
    state = true;
    await prefs.setBool('has_seen_onboarding', true);
  }

  Future<void> completeOnboardingWithAssessment({
    required String level,
    required int dailyGoal,
  }) async {
    state = true;
    await prefs.setBool('has_seen_onboarding', true);
    
    // Sync with Supabase if user is logged in
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      try {
        await ref.read(statsServiceProvider).updateStats(user.uid, {
          'spirituality_level': level,
          'daily_mala_goal': dailyGoal,
          'onboarding_completed': true,
        });
      } catch (e) {
        debugPrint('Error syncing onboarding stats: $e');
      }
    }
  }
}

/// Provider to track if the user has completed the onboarding flow
final hasSeenOnboardingProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingNotifier(prefs, ref);
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

/// Provider to enable/disable dynamic app icon evolution
final dynamicIconEnabledProvider = StateProvider<bool>((ref) {
  final stats = ref.watch(userStatsProvider).value;
  return stats?.dynamicIconEnabled ?? true;
});
