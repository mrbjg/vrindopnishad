import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// CUSTOM COLOR THEME — Curated Spiritual Palettes
/// Each palette is a harmonious set of accent/glow/gradient colors
/// ═══════════════════════════════════════════════════════════════════════════

enum AppColorTheme {
  nebulaBlue,      // Default — Deep Space Blue
  saffronSacred,   // Warm Saffron Orange
  lotusRose,       // Rose Pink / Magenta
  emeraldDivine,   // Sacred Emerald Green
  amethystMystic,  // Deep Purple / Violet
  celestialGold,   // Royal Gold
  oceanTeal,       // Ocean Teal / Cyan
  midnightIndigo,  // Midnight Indigo / Navy
}

class AppColorPalette {
  final String name;
  final String nameHi;
  final String nameSa;
  final String emoji;
  final Color accent;          // Primary accent (buttons, highlights)
  final Color accentLight;     // Lighter variant for backgrounds
  final Color accentDark;      // Darker variant for pressed states
  final Color glow;            // Glow/shadow color
  final List<Color> gradient;  // 2-color gradient pair

  const AppColorPalette({
    required this.name,
    required this.nameHi,
    required this.nameSa,
    required this.emoji,
    required this.accent,
    required this.accentLight,
    required this.accentDark,
    required this.glow,
    required this.gradient,
  });
}

class AppColorThemes {
  static const Map<AppColorTheme, AppColorPalette> palettes = {
    AppColorTheme.nebulaBlue: AppColorPalette(
      name: 'Nebula Blue',
      nameHi: 'नेबुला नीला',
      nameSa: 'नीहारिका नीलम्',
      emoji: '🌌',
      accent: Color(0xFF256AF4),
      accentLight: Color(0xFF4D8BFF),
      accentDark: Color(0xFF1A4FBF),
      glow: Color(0xFF256AF4),
      gradient: [Color(0xFF256AF4), Color(0xFF0A0A1A)],
    ),
    AppColorTheme.saffronSacred: AppColorPalette(
      name: 'Sacred Saffron',
      nameHi: 'पवित्र केसरिया',
      nameSa: 'केसरवर्णम्',
      emoji: '🪷',
      accent: Color(0xFFF2A60D),
      accentLight: Color(0xFFFFBF3D),
      accentDark: Color(0xFFD68A00),
      glow: Color(0xFFF2A60D),
      gradient: [Color(0xFFF2A60D), Color(0xFFD68A00)],
    ),
    AppColorTheme.lotusRose: AppColorPalette(
      name: 'Lotus Rose',
      nameHi: 'कमल गुलाबी',
      nameSa: 'पद्मरागम्',
      emoji: '🌸',
      accent: Color(0xFFE8437F),
      accentLight: Color(0xFFFF6B9D),
      accentDark: Color(0xFFC42D66),
      glow: Color(0xFFE8437F),
      gradient: [Color(0xFFE8437F), Color(0xFFBE185D)],
    ),
    AppColorTheme.emeraldDivine: AppColorPalette(
      name: 'Divine Emerald',
      nameHi: 'दिव्य पन्ना',
      nameSa: 'मरकतम्',
      emoji: '🍀',
      accent: Color(0xFF10B981),
      accentLight: Color(0xFF34D399),
      accentDark: Color(0xFF059669),
      glow: Color(0xFF10B981),
      gradient: [Color(0xFF10B981), Color(0xFF047857)],
    ),
    AppColorTheme.amethystMystic: AppColorPalette(
      name: 'Mystic Amethyst',
      nameHi: 'रहस्यमय बैंगनी',
      nameSa: 'अमृतवर्णम्',
      emoji: '🔮',
      accent: Color(0xFF8B5CF6),
      accentLight: Color(0xFFA78BFA),
      accentDark: Color(0xFF7C3AED),
      glow: Color(0xFF8B5CF6),
      gradient: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    ),
    AppColorTheme.celestialGold: AppColorPalette(
      name: 'Celestial Gold',
      nameHi: 'दिव्य स्वर्ण',
      nameSa: 'स्वर्णवर्णम्',
      emoji: '👑',
      accent: Color(0xFFD4A017),
      accentLight: Color(0xFFEABF3F),
      accentDark: Color(0xFFB8860B),
      glow: Color(0xFFD4A017),
      gradient: [Color(0xFFD4A017), Color(0xFFB8860B)],
    ),
    AppColorTheme.oceanTeal: AppColorPalette(
      name: 'Ocean Teal',
      nameHi: 'सागर नीला',
      nameSa: 'सागरनीलम्',
      emoji: '🌊',
      accent: Color(0xFF0891B2),
      accentLight: Color(0xFF22D3EE),
      accentDark: Color(0xFF0E7490),
      glow: Color(0xFF0891B2),
      gradient: [Color(0xFF0891B2), Color(0xFF164E63)],
    ),
    AppColorTheme.midnightIndigo: AppColorPalette(
      name: 'Midnight Indigo',
      nameHi: 'मध्यरात्रि जामुनी',
      nameSa: 'नीलमणिः',
      emoji: '🌙',
      accent: Color(0xFF6366F1),
      accentLight: Color(0xFF818CF8),
      accentDark: Color(0xFF4F46E5),
      glow: Color(0xFF6366F1),
      gradient: [Color(0xFF6366F1), Color(0xFF4338CA)],
    ),
  };

  static AppColorPalette getPalette(AppColorTheme theme) =>
      palettes[theme] ?? palettes[AppColorTheme.nebulaBlue]!;
}

/// ═══════════════════════════════════════════════════════════════════════════
/// STATE NOTIFIER — Persists selection in SharedPreferences
/// ═══════════════════════════════════════════════════════════════════════════

class ColorThemeNotifier extends StateNotifier<AppColorTheme> {
  final SharedPreferences prefs;
  static const _key = 'app_color_theme';

  ColorThemeNotifier(this.prefs) : super(AppColorTheme.nebulaBlue) {
    _load();
  }

  void _load() {
    final idx = prefs.getInt(_key);
    if (idx != null && idx < AppColorTheme.values.length) {
      state = AppColorTheme.values[idx];
    }
  }

  void setTheme(AppColorTheme theme) {
    state = theme;
    prefs.setInt(_key, theme.index);
  }
}

final colorThemeProvider =
    StateNotifierProvider<ColorThemeNotifier, AppColorTheme>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ColorThemeNotifier(prefs);
});

/// Convenience: current palette
final colorPaletteProvider = Provider<AppColorPalette>((ref) {
  final theme = ref.watch(colorThemeProvider);
  return AppColorThemes.getPalette(theme);
});
