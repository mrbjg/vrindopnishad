import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// SANT-VAANI PREMIUM DESIGN SYSTEM
/// "Divine & Modern" Aesthetic Extension
/// ═══════════════════════════════════════════════════════════════════════════

class PremiumTokens {
  // ═══════════════════════════════════════════════════════════════════════════
  // COLORS: Enhanced Palette
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color charcoal = Color(0xFF0F0F0F); // Matches background-dark
  static const Color background = Color(0xFF0F0F0F);
  static const Color accentDark = Color(0xFF1E1B15);
  static const Color voidBlue = Color(0xFF0A0C1A);
  static const Color voidAccent = Color(0xFFA5B4FC);
  static const Color saffronGlow = Color(0xFFF2A60D);
  static const Color deepGold = Color(0xFFC5A059);
  static const Color divineTeal = Color(0xFF00897B);
  static const Color celestialGlow = Color(0xFFAC92FF);
  static const Color voidDeep = Color(0xFF020205);
  
  // ═══════════════════════════════════════════════════════════════════════════
  // GRADIENTS: Immersive & Smooth
  // ═══════════════════════════════════════════════════════════════════════════
  static const LinearGradient divineDarkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A160F), Color(0xFF2D2516), Color(0xFF40341A)],
  );

  static const LinearGradient spaceVoidGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0814), Color(0xFF1A1C2E), Color(0xFF020205)],
  );

  static const LinearGradient saffronPremiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF2A60D), Color(0xFFD97706)],
  );

  static const LinearGradient goldGlassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x33C5A059),
      Color(0x11C5A059),
    ],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // GLASSMORPHISM: Crystal Clear & Sophisticated
  // ═══════════════════════════════════════════════════════════════════════════
  static BoxDecoration glassDecoration({
    double blur = 15.0,
    double opacity = 0.1,
    double borderRadius = 24.0,
    Color? color,
    Border? border,
  }) {
    return BoxDecoration(
      color: (color ?? Colors.white).withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: border ?? Border.all(
        color: Colors.white.withOpacity(0.1),
        width: 1.0,
      ),
    );
  }

  static BoxDecoration evolvingAura({
    required Color color,
    double intensity = 0.5,
  }) {
    return BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.4 * intensity),
          blurRadius: 20 * intensity,
          spreadRadius: 2 * intensity,
        ),
        BoxShadow(
          color: const Color(0xFFC0C0C0).withOpacity(0.2 * intensity), // aura-silver
          blurRadius: 40 * intensity,
          spreadRadius: 5 * intensity,
        ),
        BoxShadow(
          color: const Color(0xFF4B0082).withOpacity(0.15 * intensity), // aura-indigo
          blurRadius: 60 * intensity,
          spreadRadius: 10 * intensity,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ANIMATIONS: Meditative Pacing
  // ═══════════════════════════════════════════════════════════════════════════
  static const Duration slowPulse = Duration(milliseconds: 3000);
  static const Duration fastPulse = Duration(milliseconds: 1500);
  static const Curve meditationCurve = Curves.easeInOutSine;

  static TextStyle displayStyle({
    double fontSize = 24,
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.bold,
    double? letterSpacing,
  }) {
    return GoogleFonts.notoSerif(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle sansStyle({
    double fontSize = 16,
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.normal,
    double? letterSpacing,
  }) {
    return GoogleFonts.manrope(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    );
  }
}

class PremiumUI extends StatelessWidget {
  const PremiumUI({super.key});

  /// Premium Card with subtle glow and glass effect
  static Widget glassCard({
    required Widget child,
    double blur = 12,
    double opacity = 0.08,
    double borderRadius = 24,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? width,
    double? height,
  }) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: PremiumTokens.glassDecoration(
              blur: blur,
              opacity: opacity,
              borderRadius: borderRadius,
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Web-safe Network Image Loader to resolve "EncodingError"
  static Widget networkImage({
    required String? url,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    Widget? placeholder,
    BorderRadius? borderRadius,
  }) {
    if (url == null || url.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: PremiumTokens.accentDark,
        child: const Icon(Icons.person, color: Colors.white24),
      );
    }

    final imageWidget = Image.network(
      url,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        print("Image Loading Error: $error");
        return Container(
          width: width,
          height: height,
          color: PremiumTokens.accentDark,
          child: const Icon(Icons.broken_image, color: Colors.redAccent, size: 20),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? Container(
          width: width,
          height: height,
          color: PremiumTokens.accentDark.withOpacity(0.5),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(PremiumTokens.saffronGlow),
            ),
          ),
        );
      },
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius, child: imageWidget);
    }
    return imageWidget;
  }

  /// Premium Button with Saffron Gradient
  static Widget primaryButton({
    required String text,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          gradient: PremiumTokens.saffronPremiumGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: PremiumTokens.saffronGlow.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
            ],
            Text(
              text,
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
