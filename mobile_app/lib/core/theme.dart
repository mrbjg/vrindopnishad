import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ═══════════════════════════════════════════════════════════════════════════
  // PRIMARY PALETTE - Warm Spiritual Amber/Gold with Modern Twists
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color primaryColor = Color(0xFFE8A838);
  static const Color primaryDark = Color(0xFFD4922A);
  static const Color primaryLight = Color(0xFFFFF3E0);
  static const Color accentColor = Color(0xFFD4AF37);

  // Glowing accent colors (2025 Trend: AI/Tech glow effects)
  static const Color glowPurple = Color(0xFF8B5CF6);
  static const Color glowBlue = Color(0xFF3B82F6);
  static const Color glowTeal = Color(0xFF14B8A6);
  static const Color glowPink = Color(0xFFEC4899);
  static const Color glowOrange = Color(0xFFF97316);

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME COLORS - Soft, Premium, Spatial Feel
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color lightBackground = Color(0xFFFAF9F7);
  static const Color lightCard = Colors.white;
  static const Color lightSurface = Color(0xFFF8F6F3);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF4A4A5A);
  static const Color lightTextMuted = Color(0xFF8E8E9A);

  // Glassmorphism colors for light mode
  static const Color lightGlassColor = Color(0xCCFFFFFF);
  static const Color lightGlassBorder = Color(0x33FFFFFF);

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK THEME COLORS - Deep, Futuristic, Glow-Ready
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color darkBackground = Color(0xFF0A0A0F);
  static const Color darkCard = Color(0xFF16161F);
  static const Color darkSurface = Color(0xFF1E1E28);
  static const Color darkTextPrimary = Color(0xFFF7F7F8);
  static const Color darkTextSecondary = Color(0xFFB8B8C0);
  static const Color darkTextMuted = Color(0xFF6B6B78);

  // Glassmorphism colors for dark mode
  static const Color darkGlassColor = Color(0x40FFFFFF);
  static const Color darkGlassBorder = Color(0x20FFFFFF);

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS - Theme-Aware Colors
  // ═══════════════════════════════════════════════════════════════════════════
  static Color backgroundColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkBackground
      : lightBackground;

  static Color cardColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCard : lightCard;

  static Color surfaceColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkSurface
      : lightSurface;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkTextPrimary
      : lightTextPrimary;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkTextSecondary
      : lightTextSecondary;

  static Color textMuted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkTextMuted
      : lightTextMuted;

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // ═══════════════════════════════════════════════════════════════════════════
  // GLASSMORPHISM & LIQUID GLASS STYLING (2025 Trend)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Glass color for translucent panels
  static Color glassColor(BuildContext context) =>
      isDark(context) ? darkGlassColor : lightGlassColor;

  /// Border color for glass panels
  static Color glassBorder(BuildContext context) =>
      isDark(context) ? darkGlassBorder : lightGlassBorder;

  /// Glassmorphism decoration with blur effect
  static BoxDecoration glassDecoration(
    BuildContext context, {
    double borderRadius = 24,
    double blur = 20,
    bool hasBorder = true,
    bool hasGlow = false,
    Color? glowColor,
  }) {
    final isDarkMode = isDark(context);
    return BoxDecoration(
      color: isDarkMode
          ? Colors.white.withOpacity(0.08)
          : Colors.white.withOpacity(0.7),
      borderRadius: BorderRadius.circular(borderRadius),
      border: hasBorder
          ? Border.all(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.5),
              width: 1.5,
            )
          : null,
      boxShadow: [
        // Subtle outer shadow
        BoxShadow(
          color: isDarkMode
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        // Glow effect if enabled
        if (hasGlow)
          BoxShadow(
            color: (glowColor ?? primaryColor).withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: -10,
          ),
      ],
    );
  }

  /// Frosted glass container widget
  static Widget glassContainer({
    required BuildContext context,
    required Widget child,
    double borderRadius = 24,
    EdgeInsets? padding,
    double blur = 15,
    bool hasGlow = false,
    Color? glowColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: glassDecoration(
            context,
            borderRadius: borderRadius,
            hasGlow: hasGlow,
            glowColor: glowColor,
          ),
          child: child,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GRADIENTS - Premium Modern Gradients
  // ═══════════════════════════════════════════════════════════════════════════

  static LinearGradient headerGradient(BuildContext context) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDark(context)
        ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
        : [const Color(0xFFFEF3C7), const Color(0xFFFBD38D)],
  );

  static LinearGradient primaryGradient(BuildContext context) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDark(context)
        ? [
            const Color(0xFFD4922A),
            const Color(0xFFE8A838),
            const Color(0xFFF59E0B),
          ]
        : [const Color(0xFFFBD38D), primaryColor, primaryDark],
  );

  /// Futuristic glow gradient (2025 AI/Tech aesthetic)
  static LinearGradient glowGradient({
    Color startColor = glowPurple,
    Color endColor = glowBlue,
  }) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [startColor, endColor],
  );

  /// Mesh-style gradient for premium backgrounds
  static LinearGradient meshGradient(BuildContext context) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: isDark(context)
        ? [
            const Color(0xFF0A0A0F),
            const Color(0xFF0F0F18),
            const Color(0xFF1A1A2E),
          ]
        : [
            const Color(0xFFFFFBF5),
            const Color(0xFFFAF8F5),
            const Color(0xFFF5F0EB),
          ],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SHADOWS - Soft, Elevated, Premium
  // ═══════════════════════════════════════════════════════════════════════════

  static List<BoxShadow> softShadow(BuildContext context) => [
    BoxShadow(
      color: isDark(context)
          ? Colors.black.withOpacity(0.4)
          : Colors.black.withOpacity(0.04),
      blurRadius: 16,
      offset: const Offset(0, 6),
      spreadRadius: -2,
    ),
  ];

  static List<BoxShadow> cardShadow(BuildContext context) => [
    BoxShadow(
      color: isDark(context)
          ? Colors.black.withOpacity(0.5)
          : primaryColor.withOpacity(0.1),
      blurRadius: 24,
      offset: const Offset(0, 12),
      spreadRadius: -4,
    ),
  ];

  /// Glow shadow effect (2025 Trend)
  static List<BoxShadow> glowShadow(Color color, {double intensity = 0.4}) => [
    BoxShadow(
      color: color.withOpacity(intensity),
      blurRadius: 30,
      spreadRadius: -5,
    ),
    BoxShadow(
      color: color.withOpacity(intensity * 0.5),
      blurRadius: 60,
      spreadRadius: -10,
    ),
  ];

  /// Floating element shadow
  static List<BoxShadow> floatingShadow(BuildContext context) => [
    BoxShadow(
      color: isDark(context)
          ? Colors.black.withOpacity(0.5)
          : Colors.black.withOpacity(0.08),
      blurRadius: 32,
      offset: const Offset(0, 16),
      spreadRadius: -8,
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // BORDER RADIUS - Organic, Pill-Shaped, Modern
  // ═══════════════════════════════════════════════════════════════════════════
  static const double radiusSmall = 14;
  static const double radiusMedium = 22;
  static const double radiusLarge = 32;
  static const double radiusXL = 40;

  // ═══════════════════════════════════════════════════════════════════════════
  // ANIMATION DURATIONS - Smooth Micro-Animations
  // ═══════════════════════════════════════════════════════════════════════════
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 250);
  static const Duration animSlow = Duration(milliseconds: 400);
  static const Duration animSlower = Duration(milliseconds: 600);

  // Animation curves for "squishy" button feel
  static const Curve animCurve = Curves.easeOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME DATA
  // ═══════════════════════════════════════════════════════════════════════════
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: lightSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.spectral(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: lightTextPrimary,
          letterSpacing: -0.5,
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
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        contentPadding: const EdgeInsets.all(20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        hintStyle: GoogleFonts.outfit(color: lightTextMuted),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: lightCard,
        selectedItemColor: primaryColor,
        unselectedItemColor: lightTextMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.outfit(fontSize: 12),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK THEME DATA
  // ═══════════════════════════════════════════════════════════════════════════
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: darkSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.spectral(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          letterSpacing: -0.5,
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
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.all(20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        hintStyle: GoogleFonts.outfit(color: darkTextMuted),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkCard,
        selectedItemColor: primaryColor,
        unselectedItemColor: darkTextMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.outfit(fontSize: 12),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT THEME - Modern Typography with Inter/Outfit
  // ═══════════════════════════════════════════════════════════════════════════
  static TextTheme _buildTextTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final textPrimary = isLight ? lightTextPrimary : darkTextPrimary;
    final textSecondary = isLight ? lightTextSecondary : darkTextSecondary;

    return TextTheme(
      displayLarge: GoogleFonts.spectral(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        height: 1.15,
        letterSpacing: -1.5,
      ),
      displayMedium: GoogleFonts.spectral(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        letterSpacing: -1,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.5,
      ),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 16,
        color: textSecondary,
        height: 1.7,
        letterSpacing: 0.1,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 14,
        color: textSecondary,
        letterSpacing: 0.1,
      ),
      labelLarge: GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PREMIUM ANIMATED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

/// A pressable container with "squishy" animation effect (2025 Micro-animation)
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleFactor;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleFactor = 0.96,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onLongPress: widget.onLongPress,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}

/// Glowing icon container for AI/Tech aesthetic
class GlowingIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double glowIntensity;

  const GlowingIcon({
    super.key,
    required this.icon,
    this.color = AppTheme.primaryColor,
    this.size = 24,
    this.glowIntensity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: AppTheme.glowShadow(color, intensity: glowIntensity),
      ),
      child: Icon(icon, color: color, size: size),
    );
  }
}

/// Gradient text widget for premium headings
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;

  const GradientText({
    super.key,
    required this.text,
    this.style,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
      ),
    );
  }
}
