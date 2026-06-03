import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers.dart';
import 'color_theme_provider.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// MOOD / NATURE THEMES — Immersive Background Atmosphere System
/// Each mood defines scaffold, surface, card, text, and border colors
/// plus a suggested default accent color pairing.
/// ═══════════════════════════════════════════════════════════════════════════

enum AppMoodTheme {
  sereneDawn,
  midnightVoid,
  cloudyCalm,
  shinyBloom,
  coldMist,
  rainyPeace,
  monsoonGreen,
  forestHaven,
  waterfallBlue,
  mountainPeak,
}

class AppMoodPalette {
  final String name;
  final String nameHi;
  final String emoji;
  final Brightness brightness;
  final Color scaffoldBg;
  final Color surfaceColor;
  final Color cardColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color borderColor;
  final List<Color> backgroundGradient;
  final AppColorTheme defaultAccent;

  const AppMoodPalette({
    required this.name,
    required this.nameHi,
    required this.emoji,
    required this.brightness,
    required this.scaffoldBg,
    required this.surfaceColor,
    required this.cardColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.borderColor,
    required this.backgroundGradient,
    required this.defaultAccent,
  });

  bool get isDark => brightness == Brightness.dark;
}

class AppMoodThemes {
  static const Map<AppMoodTheme, AppMoodPalette> palettes = {
    // ─── LIGHT MOODS ───────────────────────────────────────────────────
    AppMoodTheme.sereneDawn: AppMoodPalette(
      name: 'Serene Dawn',
      nameHi: 'प्रभात शांति',
      emoji: '🌅',
      brightness: Brightness.light,
      scaffoldBg: Color(0xFFFFFDF5),
      surfaceColor: Color(0xFFFFF9E0),
      cardColor: Color(0xFFFFFFFF),
      textPrimary: Color(0xFF2D2D2D),
      textSecondary: Color(0xFF5D5D5D),
      textMuted: Color(0xFF7A7062), // Darker warm-grey for contrast safety
      borderColor: Color(0xFFE8E0D0),
      backgroundGradient: [Color(0xFFFFFDF5), Color(0xFFFFF0D0), Color(0xFFFFFDF5)],
      defaultAccent: AppColorTheme.saffronSacred,
    ),
    AppMoodTheme.cloudyCalm: AppMoodPalette(
      name: 'Cloudy Calm',
      nameHi: 'मेघ शांति',
      emoji: '☁️',
      brightness: Brightness.light,
      scaffoldBg: Color(0xFFF0F2F5),
      surfaceColor: Color(0xFFE8ECF0),
      cardColor: Color(0xFFFFFFFF),
      textPrimary: Color(0xFF2D2D2D),
      textSecondary: Color(0xFF5D5D5D),
      textMuted: Color(0xFF707885), // Darker slate-grey for contrast safety
      borderColor: Color(0xFFD8DDE4),
      backgroundGradient: [Color(0xFFF0F2F5), Color(0xFFE4E8EE), Color(0xFFF0F2F5)],
      defaultAccent: AppColorTheme.oceanTeal,
    ),
    AppMoodTheme.shinyBloom: AppMoodPalette(
      name: 'Shiny Bloom',
      nameHi: 'धूप प्रकाश',
      emoji: '☀️',
      brightness: Brightness.light,
      scaffoldBg: Color(0xFFFFF8E8),
      surfaceColor: Color(0xFFFFEFC0),
      cardColor: Color(0xFFFFFDF5),
      textPrimary: Color(0xFF2D2D2D),
      textSecondary: Color(0xFF5D5D5D),
      textMuted: Color(0xFF8A7E62), // Darker gold-grey for contrast safety
      borderColor: Color(0xFFE8D8B0),
      backgroundGradient: [Color(0xFFFFF8E8), Color(0xFFFFEDCC), Color(0xFFFFF8E8)],
      defaultAccent: AppColorTheme.celestialGold,
    ),
    AppMoodTheme.forestHaven: AppMoodPalette(
      name: 'Forest Haven',
      nameHi: 'वन शांति',
      emoji: '🌲',
      brightness: Brightness.light,
      scaffoldBg: Color(0xFFF5F8F0),
      surfaceColor: Color(0xFFE8F0E0),
      cardColor: Color(0xFFFFFFFF),
      textPrimary: Color(0xFF2D2D2D),
      textSecondary: Color(0xFF5D5D5D),
      textMuted: Color(0xFF707D65), // Darker forest-grey for contrast safety
      borderColor: Color(0xFFD0E0C8),
      backgroundGradient: [Color(0xFFF5F8F0), Color(0xFFEAF2DD), Color(0xFFF5F8F0)],
      defaultAccent: AppColorTheme.emeraldDivine,
    ),
    AppMoodTheme.waterfallBlue: AppMoodPalette(
      name: 'Waterfall Blue',
      nameHi: 'जलप्रपात',
      emoji: '💧',
      brightness: Brightness.light,
      scaffoldBg: Color(0xFFF0F8FF),
      surfaceColor: Color(0xFFE0F0FF),
      cardColor: Color(0xFFFFFFFF),
      textPrimary: Color(0xFF2D2D2D),
      textSecondary: Color(0xFF5D5D5D),
      textMuted: Color(0xFF6B7A8C), // Darker waterfall-grey for contrast safety
      borderColor: Color(0xFFCCE0F0),
      backgroundGradient: [Color(0xFFF0F8FF), Color(0xFFE0EFFF), Color(0xFFF0F8FF)],
      defaultAccent: AppColorTheme.oceanTeal,
    ),

    // ─── DARK MOODS ────────────────────────────────────────────────────
    AppMoodTheme.midnightVoid: AppMoodPalette(
      name: 'Midnight Void',
      nameHi: 'मध्यरात्रि',
      emoji: '🌑',
      brightness: Brightness.dark,
      scaffoldBg: Color(0xFF050510),
      surfaceColor: Color(0xFF0E0E1A),
      cardColor: Color(0xFF0E0E1A),
      textPrimary: Color(0xFFF5F5F7),
      textSecondary: Color(0xFFB0B0C0),
      textMuted: Color(0xFF8A8A9E), // Brighter lavender-grey for contrast safety
      borderColor: Color(0xFF1C1C2D),
      backgroundGradient: [Color(0xFF050510), Color(0xFF0A0A1F), Color(0xFF050510)],
      defaultAccent: AppColorTheme.nebulaBlue,
    ),
    AppMoodTheme.coldMist: AppMoodPalette(
      name: 'Cold Mist',
      nameHi: 'शीत कुहासा',
      emoji: '❄️',
      brightness: Brightness.dark,
      scaffoldBg: Color(0xFF060D1A),
      surfaceColor: Color(0xFF0E172A),
      cardColor: Color(0xFF0F1B30),
      textPrimary: Color(0xFFF5F5F7),
      textSecondary: Color(0xFFB0C4DE),
      textMuted: Color(0xFF8AA4C4), // Brighter cold-grey for contrast safety
      borderColor: Color(0xFF223655),
      backgroundGradient: [Color(0xFF060D1A), Color(0xFF0C1D36), Color(0xFF060D1A)],
      defaultAccent: AppColorTheme.oceanTeal,
    ),
    AppMoodTheme.rainyPeace: AppMoodPalette(
      name: 'Rainy Peace',
      nameHi: 'वर्षा शांति',
      emoji: '🌧️',
      brightness: Brightness.dark,
      scaffoldBg: Color(0xFF0F1419),
      surfaceColor: Color(0xFF1A2030),
      cardColor: Color(0xFF141C28),
      textPrimary: Color(0xFFF5F5F7),
      textSecondary: Color(0xFFA0AABC),
      textMuted: Color(0xFF8094A8), // Brighter rainy-grey for contrast safety
      borderColor: Color(0xFF1A2038),
      backgroundGradient: [Color(0xFF0F1419), Color(0xFF141E2C), Color(0xFF0F1419)],
      defaultAccent: AppColorTheme.oceanTeal,
    ),
    AppMoodTheme.monsoonGreen: AppMoodPalette(
      name: 'Monsoon Green',
      nameHi: 'सावन हरियाली',
      emoji: '🌿',
      brightness: Brightness.dark,
      scaffoldBg: Color(0xFF050D0A),
      surfaceColor: Color(0xFF0A1A12),
      cardColor: Color(0xFF081410),
      textPrimary: Color(0xFFF5F5F7),
      textSecondary: Color(0xFF90B0A0),
      textMuted: Color(0xFF7A9C8A), // Brighter monsoon-grey for contrast safety
      borderColor: Color(0xFF0A2018),
      backgroundGradient: [Color(0xFF050D0A), Color(0xFF081810), Color(0xFF050D0A)],
      defaultAccent: AppColorTheme.emeraldDivine,
    ),
    AppMoodTheme.mountainPeak: AppMoodPalette(
      name: 'Mountain Peak',
      nameHi: 'पर्वत शिखर',
      emoji: '🏔️',
      brightness: Brightness.dark,
      scaffoldBg: Color(0xFF0D0F14),
      surfaceColor: Color(0xFF161B24),
      cardColor: Color(0xFF121620),
      textPrimary: Color(0xFFF5F5F7),
      textSecondary: Color(0xFFA0A8BC),
      textMuted: Color(0xFF8A92A8), // Brighter mountain-grey for contrast safety
      borderColor: Color(0xFF1C2030),
      backgroundGradient: [Color(0xFF0D0F14), Color(0xFF141820), Color(0xFF0D0F14)],
      defaultAccent: AppColorTheme.amethystMystic,
    ),
  };

  static AppMoodPalette getPalette(AppMoodTheme mood) =>
      palettes[mood] ?? palettes[AppMoodTheme.sereneDawn]!;
}

class MoodThemeNotifier extends StateNotifier<AppMoodTheme> {
  final SharedPreferences prefs;
  static const _key = 'app_mood_theme';

  MoodThemeNotifier(this.prefs) : super(AppMoodTheme.sereneDawn) {
    _load();
  }

  void _load() {
    final idx = prefs.getInt(_key);
    if (idx != null && idx < AppMoodTheme.values.length) {
      state = AppMoodTheme.values[idx];
    }
  }

  void setMood(AppMoodTheme mood) {
    state = mood;
    prefs.setInt(_key, mood.index);
  }
}

final moodThemeProvider =
    StateNotifierProvider<MoodThemeNotifier, AppMoodTheme>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return MoodThemeNotifier(prefs);
});

final moodPaletteProvider = Provider<AppMoodPalette>((ref) {
  final mood = ref.watch(moodThemeProvider);
  return AppMoodThemes.getPalette(mood);
});
