import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// VRINDAVAANI DESIGN SYSTEM
/// Modern, minimal, reading-focused UI inspired by Uber/Zomato polish
/// ═══════════════════════════════════════════════════════════════════════════

class AppTheme {
  // ═══════════════════════════════════════════════════════════════════════════
  // PERFORMANCE MODE - For low-RAM devices
  // ═══════════════════════════════════════════════════════════════════════════
  static const bool lowPerformanceMode = true; // Enabled for extreme smoothness

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIMARY PALETTE - "Divine Minimal" Vibrant Marigold
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color primaryColor = Color(0xFFFF9100); // Vibrant Marigold
  static const Color primaryDark = Color(0xFFFF6D00); // Deep Orange Marigold
  static const Color primaryLight = Color(0xFFFFF8E1); // Warm Amber Light
  static const Color accentColor = Color(0xFFFFD600); // Bright Gold Accent

  // ═══════════════════════════════════════════════════════════════════════════
  // JEWEL ACCENTS - Premium & Spiritual
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color sacredViolet = Color(0xFF6200EA); // Deep Amethyst
  static const Color sereneTeal = Color(0xFF00BFA5); // Sacred Emerald/Teal
  static const Color lotusRose = Color(0xFFD81B60); // Rich Lotus Pink
  static const Color deepSaffron = Color(0xFFFF3D00); // Electric Saffron
  static const Color peacockBlue = Color(0xFF0091EA); // Divine Sky Blue

  // Glow color aliases
  static const Color glowPink = lotusRose;
  static const Color glowBlue = peacockBlue;
  static const Color glowPurple = sacredViolet;
  static const Color glowTeal = sereneTeal;
  static const Color glowOrange = deepSaffron;

  // ═══════════════════════════════════════════════════════════════════════════
  // MODERNIZED THEMES
  // ═══════════════════════════════════════════════════════════════════════════

  // LIGHT: Champagne Silk
  static const Color lightBackground = Color(0xFFFFFDF5);
  static const Color lightCard = Colors.white;
  static const Color lightSurface = Color(0xFFFFF9E6);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF424242);
  static const Color lightTextMuted = Color(0xFF9E9E9E);
  static const Color lightBorder = Color(0xFFF0E6D2);

  // DARK: Midnight Void
  static const Color darkBackground = Color(0xFF050510);
  static const Color darkCard = Color(0xFF0E0E1A);
  static const Color darkSurface = Color(0xFF141422);
  static const Color darkTextPrimary = Color(0xFFF5F5F7);
  static const Color darkTextSecondary = Color(0xFFB0B0C0);
  static const Color darkTextMuted = Color(0xFF505060);
  static const Color darkBorder = Color(0xFF1C1C2D);

  // Status
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFAB00);
  static const Color error = Color(0xFFD50000);

  // ═══════════════════════════════════════════════════════════════════════════
  // SPACING SCALE (Consistent 8pt grid)
  // ═══════════════════════════════════════════════════════════════════════════
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space48 = 48;
  static const double space64 = 64;

  // ═══════════════════════════════════════════════════════════════════════════
  // BORDER RADIUS
  // ═══════════════════════════════════════════════════════════════════════════
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXL = 24;
  static const double radiusFull = 100;

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color backgroundColor(BuildContext context) =>
      isDark(context) ? darkBackground : lightBackground;

  static Color cardColor(BuildContext context) =>
      isDark(context) ? darkCard : lightCard;

  static Color surfaceColor(BuildContext context) =>
      isDark(context) ? darkSurface : lightSurface;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? darkTextPrimary : lightTextPrimary;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? darkTextSecondary : lightTextSecondary;

  static Color textMuted(BuildContext context) =>
      isDark(context) ? darkTextMuted : lightTextMuted;

  static Color borderColor(BuildContext context) =>
      isDark(context) ? darkBorder : lightBorder;

  /// Primary button/header gradient
  static LinearGradient primaryGradient(BuildContext context) =>
      LinearGradient(begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryColor, primaryDark],
      );

  /// Hero card gradient
  static LinearGradient heroGradient(BuildContext context) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDark(context)
        ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
        : [const Color(0xFFFEF3C7), const Color(0xFFFCD34D)],
  );

  /// Sacred violet gradient
  static const LinearGradient sacredGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
  );

  /// Reading background gradient (subtle)
  static LinearGradient readingGradient(BuildContext context) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: isDark(context)
        ? [darkBackground, darkSurface]
        : [lightBackground, const Color(0xFFFFFBEB)],
  );

  /// Header gradient (for app bars and headers)
  static LinearGradient headerGradient(BuildContext context) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDark(context)
        ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
        : [const Color(0xFFFEF3C7), const Color(0xFFFBD38D)],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SHADOWS
  // ═══════════════════════════════════════════════════════════════════════════

  static List<BoxShadow> softShadow(BuildContext context) => [
    BoxShadow(
      color: isDark(context)
          ? Colors.black.withValues(alpha: 0.4)
          : Colors.black.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> cardShadow(BuildContext context) => [
    BoxShadow(
      color: isDark(context)
          ? Colors.black.withValues(alpha: 0.3)
          : Colors.black.withValues(alpha: 0.04),
      blurRadius: 12,
      offset: Offset(0, 2),
    ),
  ];

  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: -4),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // CARD DECORATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Standard card decoration
  static BoxDecoration cardDecoration(
    BuildContext context, {
    double borderRadius = radiusMedium,
    Color? color,
  }) {
    final dark = isDark(context);
    return BoxDecoration(
      color: color ?? (dark ? darkCard : lightCard),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: dark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        width: 1,
      ),
      boxShadow: cardShadow(context),
    );
  }

  /// Hero card with gradient border
  static BoxDecoration heroCardDecoration(BuildContext context) {
    return BoxDecoration(
      gradient: heroGradient(context),
      borderRadius: BorderRadius.circular(radiusXL),
      boxShadow: softShadow(context),
    );
  }

  /// Frosted glass effect
  static Widget frostedGlass({
    required BuildContext context,
    required Widget child,
    double borderRadius = radiusLarge,
    double blur = 12,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    final dark = isDark(context);
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: dark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: dark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.6),
                width: 0.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME
  // ═══════════════════════════════════════════════════════════════════════════
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: sacredViolet,
        surface: lightSurface,
        error: error,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: lightTextPrimary,
        ),
        iconTheme: const IconThemeData(color: lightTextPrimary),
      ),
      textTheme: _buildTextTheme(Brightness.light),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        hintStyle: TextStyle(color: lightTextMuted),
      ),
      dividerTheme: DividerThemeData(
        color: lightBorder,
        thickness: 1,
        space: space24,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK THEME
  // ═══════════════════════════════════════════════════════════════════════════
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: sacredViolet,
        surface: darkSurface,
        error: error,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        iconTheme: const IconThemeData(color: darkTextPrimary),
      ),
      textTheme: _buildTextTheme(Brightness.dark),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: peacockBlue, width: 2),
        ),
        hintStyle: TextStyle(color: darkTextMuted),
      ),
      dividerTheme: DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: space24,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT THEME - Typography System
  // ═══════════════════════════════════════════════════════════════════════════
  static TextTheme _buildTextTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final textColor = isLight ? lightTextPrimary : darkTextPrimary;
    final secondaryColor = isLight ? lightTextSecondary : darkTextSecondary;

    return TextTheme(
      // Display - Large headers
      displayLarge: GoogleFonts.spectral(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.spectral(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.25,
      ),
      displaySmall: GoogleFonts.spectral(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.3,
      ),
      // Headlines
      headlineLarge: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      // Body text
      bodyLarge: GoogleFonts.outfit(
        fontSize: 16,
        color: secondaryColor,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 14,
        color: secondaryColor,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.outfit(
        fontSize: 12,
        color: secondaryColor,
        height: 1.4,
      ),
      // Labels
      labelLarge: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      labelMedium: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
      ),
      labelSmall: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
        letterSpacing: 0.5,
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// PRE-MEMOIZED STYLES - Bypasses GoogleFonts overhead in lists
/// ═══════════════════════════════════════════════════════════════════════════
class SacredStyles {
  // Common Outfit styles
  static final outfitTitle = GoogleFonts.outfit(
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 1.25,
  );

  static final outfitSubtitle = GoogleFonts.outfit(fontSize: 14, height: 1.5);

  static final outfitLabel = GoogleFonts.outfit(
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );

  static final outfitMuted = GoogleFonts.outfit(fontSize: 11);

  // Sacred Devanagari styles
  static final devanagariPreview = GoogleFonts.notoSansDevanagari(
    fontSize: 11,
    height: 1.5,
  );

  static final devanagariMain = GoogleFonts.notoSansDevanagari();

  // Spectral display styles
  static final spectralHeader = GoogleFonts.spectral(
    fontWeight: FontWeight.bold,
    fontSize: 28,
  );
}
