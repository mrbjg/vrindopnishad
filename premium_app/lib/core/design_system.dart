import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'theme.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// SANT-VAANI PREMIUM DESIGN SYSTEM
/// "Divine & Modern" Aesthetic Extension
/// ═══════════════════════════════════════════════════════════════════════════

class PremiumTokens {
  // ═══════════════════════════════════════════════════════════════════════════
  // COLORS: Enhanced Palette
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color charcoal = Color(0xFF020205); // Unified to voidBlack
  static const Color voidBlack = Color(0xFF020205); 
  static const Color voidPure = Color(0xFF000000); 
  static const Color background = Color(0xFF020205);
  static const Color surfaceCharcoal = Color(0xFF0A0A1F); // Deep blue-tinted surface
  static const Color accentDark = Color(0xFF050510);
  static const Color nebulaBlue = Color(0xFF256AF4); 
  static const Color voidBlue = Color(0xFF0A0A1A); 
  static const Color primaryAccent = Color(0xFF256AF4); // Blue is now primary
  static const Color saffronGlow = Color(0xFFF2A60D); // Kept as subtle accent
  static const Color silverCloud = Color(0xFFC0C0CF); 
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
    colors: [Color(0xFF256AF4), Color(0xFF1A1C2E)], // Unified to Nebula
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
          color: color.withValues(alpha: 0.3 * intensity),
          blurRadius: 30 * intensity,
          spreadRadius: 2 * intensity,
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

  static Widget logo({double height = 40, Color? color}) {
    // Matrix to convert luminance to alpha (removes black backgrounds)
    const luminanceToAlpha = ColorFilter.matrix([
      1, 0, 0, 0, 0,
      0, 1, 0, 0, 0,
      0, 0, 1, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
    ]);

    Widget logoImage = SvgPicture.asset(
      'assets/logo.svg',
      height: height,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : luminanceToAlpha,
    );

    // If a color is provided, we must strip the black background FIRST, 
    // and THEN apply the srcIn tint filter to the resulting transparency.
    if (color != null) {
      return ColorFiltered(
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        child: ColorFiltered(
          colorFilter: luminanceToAlpha,
          child: SvgPicture.asset(
            'assets/logo.svg',
            height: height,
          ),
        ),
      );
    }

    return logoImage;
  }

  static Widget logoAnimated({double height = 60, Color? color}) {
    final effectiveColor = color ?? Colors.white;
    return logo(height: height, color: color)
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(duration: 3.seconds, color: effectiveColor.withValues(alpha: 0.3))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: 3.seconds,
          curve: Curves.easeInOutSine,
        );
  }


  /// Specific glass card for the Saffron Dashboard V2
  static Widget saffronGlassCard({
    required Widget child,
    double blur = 12,
    double borderRadius = 24,
    EdgeInsets? padding,
    EdgeInsets? margin,
    bool optimized = true,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: PremiumTokens.saffronGlow.withValues(alpha: 0.1),
            blurRadius: 15,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: optimized 
          ? Container(
              padding: padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xCC0A0A1F), // Solid high-performance surface
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: PremiumTokens.nebulaBlue.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: child,
            )
          : BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: Container(
                padding: padding ?? const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0x990A0A1F),
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: PremiumTokens.nebulaBlue.withValues(alpha: 0.1),
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
    bool optimized = true,
  }) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: optimized
          ? Container(
              padding: padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F2D), // Deep solid void
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              child: child,
            )
          : BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: Container(
                padding: padding ?? const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0x1A2B2BEE),
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

  /// Stitch-Inspired VoidCard Component
  /// High-performance card with left accent, blue-tinted glass, and optimized rendering
  static Widget voidCard({
    required Widget child,
    Color accentColor = PremiumTokens.nebulaBlue,
    double borderRadius = 16,
    EdgeInsets padding = const EdgeInsets.all(16),
    EdgeInsets? margin,
    bool optimized = true,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: const Color(0x0DFFFFFF), // Subtle glass base
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Stitch Accent Bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.6),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: padding,
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mind-Blowing Ethereal Floating NavBar
  static Widget floatingNavBar({
    required int selectedIndex,
    required List<({String iconSvg, String activeIconSvg, String label})> items,
    required Function(int) onTap,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final slotWidth = width / 5;
        final capsuleWidth = 58.0;
        final capsuleHeight = 44.0;

        return Container(
          height: 100, // Safe height for bar + Sacred Void overlap
          padding: const EdgeInsets.only(bottom: 20),
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              // Glass Bar Container
              Container(
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xE60A0A1F),
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Capsule Indicator
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.fastOutSlowIn,
                      left: (selectedIndex * slotWidth) + (slotWidth - capsuleWidth) / 2,
                      top: (70 - capsuleHeight) / 2,
                      child: Container(
                        width: capsuleWidth,
                        height: capsuleHeight,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.05),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Navigation Icons Row
                    Row(
                      children: List.generate(items.length, (index) {
                        final item = items[index];
                        final isSelected = selectedIndex == index;
                        
                        if (index == 2) return const Expanded(child: SizedBox());

                        return Expanded(
                          child: _PremiumAnimatedNavButton(
                            index: index,
                            isSelected: isSelected,
                            item: item,
                            onTap: onTap,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Sacred Void Center Button - Minimal "Glass-Void" Version
  static Widget sacredVoidButton({
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return _SacredVoidButtonInternal(onTap: onTap, isActive: isActive);
  }


  /// Generic glass card
  static Widget glassCard({
    required Widget child,
    double blur = 15,
    double opacity = 0.1,
    double borderRadius = 24,
    EdgeInsets? padding,
    EdgeInsets? margin,
    bool optimized = true,
  }) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: optimized
          ? Container(
              padding: padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: opacity * 1.5), // High-perf opacity
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              child: child,
            )
          : BackdropFilter(
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

  /// Optimized Master Background switcher to prevent overdraw
  static Widget masterBackground({required int index}) {
    // 0: Home, 1: Library, 4: Profile -> Bokeh
    // 2: Naam Jap, 3: Journal -> Void
    final isVoid = index == 2 || index == 3;
    
    return Container(
      decoration: const BoxDecoration(color: PremiumTokens.voidBlack),
      child: Stack(
        children: [
          // Base Ambient Glow (Always present)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    PremiumTokens.nebulaBlue.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Primary Nebula Flare
          _buildBokeh(
            top: -100, 
            right: -50, 
            size: 400, 
            color: PremiumTokens.nebulaBlue.withValues(alpha: isVoid ? 0.12 : 0.08)
          ),
          
          // Transitionary Elements
          if (isVoid) ...[
            _buildBokeh(bottom: -50, left: -50, size: 350, color: PremiumTokens.nebulaBlue.withValues(alpha: 0.06)),
            _buildMoon(bottom: 120, left: 60, size: 80),
          ] else ...[
             _buildBokeh(bottom: -100, left: -50, size: 300, color: PremiumTokens.celestialGlow.withValues(alpha: 0.04)),
             _buildMoon(top: 60, left: 40, size: 60),
          ],
          
          // Unified Planet (Subtle)
          _buildPlanet(
            top: isVoid ? 200 : 120, 
            right: isVoid ? 80 : 60, 
            size: 30, 
            color: isVoid ? Colors.deepPurpleAccent.withValues(alpha: 0.2) : Colors.blueAccent.withValues(alpha: 0.15)
          ),
        ],
      ),
    );
  }

  /// Deprecated in favor of masterBackground, kept for single-screen use if needed
  static Widget bokehBackground() => masterBackground(index: 0);
  static Widget voidBackground() => masterBackground(index: 2);

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

  static Widget _buildMoon({double? top, double? bottom, double? left, double? right, required double size}) {
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
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.15),
              blurRadius: 40,
              spreadRadius: 5,
            ),
          ],
        ),
        child: CustomPaint(
          painter: _CrescentMoonPainter(),
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true))
       .fadeIn(duration: 2.seconds)
       .moveY(begin: 0, end: -10, duration: 4.seconds, curve: Curves.easeInOut),
    );
  }

  static Widget _buildPlanet({double? top, double? bottom, double? left, double? right, required double size, required Color color}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Opacity(
        opacity: 0.4,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0.1), Colors.transparent],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: CustomPaint(
            painter: _PlanetRingsPainter(color: color.withValues(alpha: 0.2)),
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
                color: PremiumTokens.voidBlack,
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

  /// Web-safe Network Image Loader with Caching
  // ═══════════════════════════════════════════════════════════════════════════
  // ICONS: Animated & Custom Assets
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const String animRoot = 'assets/animated_icons/';
  static const String svgRoot = 'assets/iconsax/';

  /// Premium Animated Icon (Lottie)
  /// Automatically handles color tinting via delegates
  static Widget animatedIcon({
    required String folder,
    required String fileName,
    double size = 24,
    Color? color,
    bool autoPlay = false,
    bool resetAfterPlay = true,
    VoidCallback? onTap,
  }) {
    return _PremiumInteractiveIcon(
      folder: folder,
      fileName: fileName,
      size: size,
      color: color,
      autoPlay: autoPlay,
      resetAfterPlay: resetAfterPlay,
      onTap: onTap,
    );
  }

  /// Premium Custom Icon (SVG)
  static Widget customIcon({
    required String fileName,
    double size = 24,
    Color? color,
  }) {
    final String path = fileName.startsWith('assets/') ? fileName : '$svgRoot$fileName';
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      fit: BoxFit.contain,
    );
  }

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

    final imageWidget = CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: width != null ? (width * 2).toInt() : null, // Limit memory cache
      errorWidget: (context, url, error) {
        print("Image Loading Error: $error");
        return Container(
          width: width,
          height: height,
          color: PremiumTokens.accentDark,
          child: const Icon(Icons.broken_image, color: Colors.redAccent, size: 20),
        );
      },
      placeholder: (context, url) => placeholder ?? Container(
        width: width,
        height: height,
        color: PremiumTokens.accentDark.withValues(alpha: 0.5),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(PremiumTokens.nebulaBlue),
          ),
        ),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius, child: imageWidget);
    }
    return imageWidget;
  }

  /// FocusContainer: Fades children based on focus mode
  static Widget focusContainer({
    required bool isFocusMode,
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return AnimatedOpacity(
      duration: duration,
      opacity: isFocusMode ? 0.0 : 1.0,
      curve: Curves.easeInOut,
      child: IgnorePointer(
        ignoring: isFocusMode,
        child: child,
      ),
    );
  }

  /// SacredDivider: A spiritual separator with a central icon
  static Widget sacredDivider({Color? color, double width = 60}) {
    final activeColor = color ?? Colors.white.withValues(alpha: 0.1);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: width, height: 1, decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.transparent, activeColor])
        )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text("ॐ", style: GoogleFonts.spectral(color: activeColor, fontSize: 18)),
        ),
        Container(width: width, height: 1, decoration: BoxDecoration(
          gradient: LinearGradient(colors: [activeColor, Colors.transparent])
        )),
      ],
    );
  }

  /// AuraBreathingAnimation: A subtle pulse effect for immersive screens
  static Widget auraBreathing({
    required Widget child,
    double beginScale = 1.0,
    double endScale = 1.05,
    Duration duration = const Duration(milliseconds: 4000),
  }) {
    return child.animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: Offset(beginScale, beginScale),
          end: Offset(endScale, endScale),
          duration: duration,
          curve: Curves.easeInOutSine,
        );
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

class _PlanetRingsPainter extends CustomPainter {
  final Color color;
  _PlanetRingsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCenter(center: center, width: size.width * 1.8, height: size.height * 0.4);
    
    // Rotate the rings slightly
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(0.5);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawOval(rect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CrescentMoonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;

    final moonPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          Colors.white.withValues(alpha: 0.8),
          Colors.white.withValues(alpha: 0.1),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final path1 = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    final path2 = Path()
      ..addOval(Rect.fromCircle(
        center: center.translate(radius * 0.4, -radius * 0.15),
        radius: radius * 0.95,
      ));

    // Subtract path2 from path1 to create a crescent
    final crescentPath = Path.combine(PathOperation.difference, path1, path2);

    canvas.drawPath(crescentPath, moonPaint);
    
    // Add a tiny glow to the tips
    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(crescentPath, glowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _SacredVoidButtonInternal extends StatefulWidget {
  final VoidCallback onTap;
  final bool isActive;

  const _SacredVoidButtonInternal({
    required this.onTap,
    this.isActive = false,
  });

  @override
  State<_SacredVoidButtonInternal> createState() => _SacredVoidButtonInternalState();
}

class _SacredVoidButtonInternalState extends State<_SacredVoidButtonInternal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_SacredVoidButtonInternal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward(from: _controller.value);
      } else {
        _controller.reverse(from: _controller.value);
      }
    }
  }

  void _handleTap() {
    HapticFeedback.heavyImpact();
    widget.onTap();
    _controller.forward(from: 0.0).then((_) {
      // Reset to outline frame after animation completes ONLY IF not active
      if (mounted && !widget.isActive) {
        _controller.value = 0.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Glow Aura (Subtle Breathing)
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (widget.isActive ? PremiumTokens.saffronGlow : PremiumTokens.nebulaBlue)
                      .withValues(alpha: widget.isActive ? 0.3 : 0.25),
                  blurRadius: widget.isActive ? 30 : 25,
                  spreadRadius: widget.isActive ? 2 : 1,
                ),
              ],
            ),
          ),

          // Main Button Body
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF03030F).withValues(alpha: 0.9), // Near-black void
              border: Border.all(
                color: (widget.isActive ? PremiumTokens.saffronGlow : Colors.white).withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                if (widget.isActive)
                  BoxShadow(
                    color: PremiumTokens.saffronGlow.withValues(alpha: 0.5),
                    blurRadius: 15,
                    spreadRadius: -2,
                  ),
              ],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  child: Lottie.asset(
                    'assets/animated_icons/Heart/heart.json',
                    controller: _controller,
                    width: 44,
                    height: 44,
                    repeat: false,
                    animate: false,
                    onLoaded: (composition) {
                      _controller.duration = composition.duration;
                      _controller.value = 0.0;
                    },
                  ),
                ),
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}

class _PremiumAnimatedNavButton extends StatefulWidget {
  final int index;
  final bool isSelected;
  final ({String iconSvg, String activeIconSvg, String label}) item;
  final Function(int) onTap;

  const _PremiumAnimatedNavButton({
    required this.index,
    required this.isSelected,
    required this.item,
    required this.onTap,
  });

  @override
  State<_PremiumAnimatedNavButton> createState() => _PremiumAnimatedNavButtonState();
}

class _PremiumAnimatedNavButtonState extends State<_PremiumAnimatedNavButton> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
    ]).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onTap(widget.index);
    _pulseController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: PremiumUI.customIcon(
              fileName: widget.isSelected ? widget.item.activeIconSvg : widget.item.iconSvg,
              color: widget.isSelected ? Colors.white : Colors.white24,
              size: 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.item.label,
            style: GoogleFonts.manrope(
              fontSize: 8,
              color: widget.isSelected ? Colors.white : Colors.white24,
              fontWeight: widget.isSelected ? FontWeight.w800 : FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumInteractiveIcon extends StatefulWidget {
  final String folder;
  final String fileName;
  final double size;
  final Color? color;
  final bool autoPlay;
  final bool resetAfterPlay;
  final VoidCallback? onTap;

  const _PremiumInteractiveIcon({
    required this.folder,
    required this.fileName,
    this.size = 24,
    this.color,
    this.autoPlay = false,
    this.resetAfterPlay = true,
    this.onTap,
  });

  @override
  State<_PremiumInteractiveIcon> createState() => _PremiumInteractiveIconState();
}

class _PremiumInteractiveIconState extends State<_PremiumInteractiveIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap != null) widget.onTap!();
    _controller.forward(from: 0.0).then((_) {
      if (widget.resetAfterPlay && mounted) {
        _controller.value = 0.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget lottie = Lottie.asset(
      '${PremiumUI.animRoot}${widget.folder}/${widget.fileName}',
      controller: _controller,
      repeat: false,
      animate: widget.autoPlay,
      onLoaded: (composition) {
        _controller.duration = composition.duration;
        if (widget.autoPlay) {
          _controller.forward();
        } else if (mounted) {
          _controller.value = 0.0;
        }
      },
    );

    if (widget.color != null) {
      lottie = ColorFiltered(
        colorFilter: ColorFilter.mode(widget.color!, BlendMode.srcIn),
        child: lottie,
      );
    }

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: lottie,
      ),
    );
  }
}
