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
  static const Color charcoal = Color(0xFF1A160F); // Dashboard background-dark
  static const Color voidBlack = Color(0xFF020205); // Journal void-black
  static const Color voidPure = Color(0xFF000000); // Audio player background-dark
  static const Color background = Color(0xFF1A160F);
  static const Color surfaceCharcoal = Color(0xFF2A2316); // Dashboard surface-dark
  static const Color accentDark = Color(0xFF1E1B15);
  static const Color nebulaBlue = Color(0xFF256AF4); // Audio player primary
  static const Color voidBlue = Color(0xFF0A0A1A); // Journal background-dark
  static const Color saffronGlow = Color(0xFFF2A60D); // Premium primary
  static const Color silverCloud = Color(0xFFC0C0CF); // Journal silver
  static const Color deepGold = Color(0xFFC5A059);
  static const Color celestialGlow = Color(0xFFAC92FF);
  
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

  static const LinearGradient nebulaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF256AF4), Color(0xFF0A0A1A)],
  );

  static Gradient nebulaRadialGlow(double intensity) {
    return RadialGradient(
      center: Alignment.center,
      radius: 0.8 * intensity,
      colors: [
        Color(0xFF256AF4).withValues(alpha: 0.15 * intensity),
        Color(0xFF256AF4).withValues(alpha: 0.05 * intensity),
        Colors.transparent,
      ],
    );
  }

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
      color: (color ?? Colors.white).withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: border ?? Border.all(
        color: Colors.white.withValues(alpha: 0.1),
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
          color: color.withValues(alpha: 0.4 * intensity),
          blurRadius: 20 * intensity,
          spreadRadius: 2 * intensity,
        ),
        BoxShadow(
          color: Color(0xFFC0C0C0).withValues(alpha: 0.2 * intensity), // aura-silver
          blurRadius: 40 * intensity,
          spreadRadius: 5 * intensity,
        ),
        BoxShadow(
          color: Color(0xFF4B0082).withValues(alpha: 0.15 * intensity), // aura-indigo
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
    FontStyle fontStyle = FontStyle.normal,
    double? letterSpacing,
  }) {
    return GoogleFonts.manrope(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle soulStyle({
    double fontSize = 24,
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.w300,
    double? letterSpacing,
  }) {
    return GoogleFonts.newsreader(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    );
  }
}

class PremiumUI extends StatelessWidget {
  const PremiumUI({super.key});


  /// Specific glass card for the Saffron Dashboard V2
  static Widget saffronGlassCard({
    required Widget child,
    double blur = 12,
    double borderRadius = 24,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: PremiumTokens.saffronGlow.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0x992A2316), // rgba(42, 35, 22, 0.6)
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: PremiumTokens.saffronGlow.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Specific glass card for the Ethereal Void (Audio/Journal)
  static Widget voidGlassCard({
    required Widget child,
    double blur = 12,
    double borderRadius = 24,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0x1A2B2BEE), // rgba(43, 43, 238, 0.1)
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Rotating Nebula Disk for Audio Player
  static Widget nebulaDisk({
    required Widget child,
    double size = 224, // 56 * 4
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0xFF256AF4).withValues(alpha: 0.3),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.03),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Center(child: child),
      ),
    );
  }

  /// Generic glass card
  static Widget glassCard({
    required Widget child,
    double blur = 15,
    double opacity = 0.1,
    double borderRadius = 24,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return Container(
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

  /// Nebula Glow Effect for Void Audio/Journal
  static Widget nebulaGlow({double size = 400, double opacity = 0.6}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.15 * opacity),
            Color(0xFF256AF4).withValues(alpha: 0.05 * opacity),
            Colors.transparent,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF256AF4).withValues(alpha: 0.1 * opacity),
            blurRadius: 80 * opacity,
          ),
        ],
      ),
    );
  }

  /// Premium bokeh background for immersive screens
  static Widget bokehBackground() {
    return Container(
      decoration: BoxDecoration(color: PremiumTokens.charcoal,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    PremiumTokens.saffronGlow.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          _buildBokeh(top: -100, right: -50, size: 300, color: PremiumTokens.saffronGlow.withValues(alpha: 0.08)),
          _buildBokeh(bottom: -50, left: -50, size: 250, color: PremiumTokens.saffronGlow.withValues(alpha: 0.05)),
        ],
      ),
    );
  }

  /// Ethereal Void background for meditation/journal
  static Widget voidBackground() {
    return Container(
      decoration: BoxDecoration(color: PremiumTokens.voidBlack,
      ),
      child: Stack(
        children: [
          // Deep space radial glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Color(0xFF256AF4).withValues(alpha: 0.08),
                    PremiumTokens.voidBlack,
                  ],
                ),
              ),
            ),
          ),
          // Nebula flares
          _buildBokeh(top: -150, left: -100, size: 500, color: Color(0xFF256AF4).withValues(alpha: 0.1)),
          _buildBokeh(bottom: -100, right: -150, size: 400, color: Color(0xFF256AF4).withValues(alpha: 0.05)),
          // Star dust (simulated with small faint bokeh)
          _buildBokeh(top: 200, right: 100, size: 200, color: Colors.white.withValues(alpha: 0.02)),
        ],
      ),
    );
  }

  /// Subtle mandala pattern overlay for sacred screens
  static Widget mandalaOverlay({double opacity = 0.03}) {
    return Opacity(
      opacity: opacity,
      child: Container(
        decoration: BoxDecoration(image: DecorationImage(
            image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuC9J4nO13Fik0Au_1Tuo1M_eBAME8GcVjNnVSfbU6fysIWTWnsO91vA0tbb9LpPBBElJiQmj3ypYIio9OcPJ6ROICRKUvgSRlAkpR7PvCQH_RFO9-NhG-oirndhfV_gOm4oOPJWONG3ylcEKlmNO59670Z4FeAftQH5i9Zi3Mm_Jbb3Qddb0aA5C0e30wj77H8rNFpXhTjRB1vkjo2Lf-7snA8T_zQ8oXZe-IfvYfpsJHbFn75gBZvCkhuvcwONzXXeGBNbm4SRWNU'),
            repeat: ImageRepeat.repeat,
            scale: 0.5,
          ),
        ),
      ),
    );
  }

  static Widget _buildBokeh({double? top, double? bottom, double? left, double? right, required double size, required Color color}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
          ),
        ),
      ),
    );
  }

  /// Silver Capsule Button for Void/Journal
  static Widget capsuleButton({
    required String text,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFC0C0CF), Colors.white],
          ),
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.3),
              blurRadius: 20,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: PremiumTokens.voidBlack, size: 18),
              const SizedBox(width: 12),
            ],
            Text(
              text.toUpperCase(),
              style: GoogleFonts.manrope(
                color: PremiumTokens.voidBlack,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Saffron Solid Button for Dashboard V2
  static Widget saffronButton({
    required String text,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        decoration: BoxDecoration(
          color: PremiumTokens.saffronGlow,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: PremiumTokens.charcoal, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text.toUpperCase(),
              style: GoogleFonts.manrope(
                color: PremiumTokens.charcoal,
                fontWeight: FontWeight.w800,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
          ],
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
          color: PremiumTokens.accentDark.withValues(alpha: 0.5),
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
              color: PremiumTokens.saffronGlow.withValues(alpha: 0.3),
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
