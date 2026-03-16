import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/home_screen.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

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

/// Provider for Naam Jap (mantra chanting) counter
final naamJapCounterProvider = StateProvider<int>((ref) => 0);

/// Provider to track if the user has completed the onboarding flow
final hasSeenOnboardingProvider = StateProvider<bool>((ref) => false);

/// Provider for the selected category in the Sacred Library
final navigationIndexProvider = StateProvider<int>((ref) => 0);

final libraryCategoryProvider = StateProvider<String>((ref) => "ALL");
