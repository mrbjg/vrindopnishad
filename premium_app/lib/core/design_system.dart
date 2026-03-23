import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'theme.dart';
import '../widgets/sacred_ritual_alert.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// SANT-VAANI PREMIUM DESIGN SYSTEM
/// "Divine & Modern" Aesthetic Extension
/// ═══════════════════════════════════════════════════════════════════════════

class PremiumTokens {
  // ═══════════════════════════════════════════════════════════════════════════
  // COLORS: Enhanced Palette
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color charcoal = Color(0xFF050510); // Indigo-tinted void
  static const Color voidBlack = Color(0xFF050510);
  static const Color voidPure = Color(0xFF000000);
  static const Color background = Color(0xFF050510);
  static const Color surfaceCharcoal = Color(
    0xFF0A0A1F,
  ); // Deep blue-tinted surface
  static const Color accentDark = Color(0xFF050510);
  static const Color nebulaBlue = Color(0xFF256AF4);
  static const Color voidBlue = Color(0xFF0A0A1A);
  static const Color primaryAccent = Color(0xFF256AF4); // Blue is now primary
  static const Color saffronGlow = Color(0xFFF2A60D); // Kept as subtle accent
  static const Color starlight = Color(0xFF93C5FD);
  static const Color silverCloud = Color(0xFFC0C0CF);
  static const Color deepGold = Color(0xFFC5A059);
  static const Color celestialGlow = Color(0xFFAC92FF);
  static const Color voidIndigo = Color(0xFF0D0D1A);
  static const Color silver = Color(0xFFC0C0C8);
  static const Color starlightBlue = Color(0xFF93C5FD);

  // ═══════════════════════════════════════════════════════════════════════════
  // GRADIENTS: Immersive & Smooth
  // ═══════════════════════════════════════════════════════════════════════════
  static const LinearGradient silverGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8)],
  );
  static const LinearGradient divineDarkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0A1F), Color(0xFF070715), Color(0xFF050510)],
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
    colors: [Color(0x33C5A059), Color(0x11C5A059)],
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
      border:
          border ??
          Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.0),
    );
  }

  static BoxDecoration indigoGlass({double opacity = 0.7}) {
    return BoxDecoration(
      color: voidIndigo.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(40),
      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
          blurRadius: 40,
          spreadRadius: 2,
        ),
      ],
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
  static const LinearGradient glassReflection = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x80FFFFFF), Color(0x00FFFFFF)],
    stops: [0.0, 0.5],
  );

  static const Duration slowPulse = Duration(milliseconds: 3000);
  static const Duration fastPulse = Duration(milliseconds: 1500);
  static const Curve meditationCurve = Curves.easeInOutSine;
  static const Curve breathingSine = _CelestialBreathingCurve();

  // ═══════════════════════════════════════════════════════════════════════════
  // TYPOGRAPHY: Soulful & Modern
  // ═══════════════════════════════════════════════════════════════════════════

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

  static TextStyle lailaStyle({
    double fontSize = 24,
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.normal,
    double? letterSpacing,
  }) {
    return GoogleFonts.laila(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    );
  }
}

class _CelestialBreathingCurve extends Curve {
  const _CelestialBreathingCurve();

  @override
  double transformInternal(double t) {
    return (math.sin(t * math.pi * 2 - math.pi / 2) + 1) / 2;
  }
}

class PremiumUI extends StatelessWidget {
  const PremiumUI({super.key});

  /// Silver gradient text wrapper
  static Widget silverText(
    String text, {
    required TextStyle style,
    TextAlign textAlign = TextAlign.start,
  }) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => PremiumTokens.silverGradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style, textAlign: textAlign),
    );
  }

  /// Celestial pulsing icon for alerts
  static Widget pulsingCelestialIcon({
    required IconData icon,
    double size = 48,
  }) {
    return Container(
          width: size * 1.6,
          height: size * 1.6,
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(icon, color: PremiumTokens.silver, size: size),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .custom(
          duration: 2.seconds,
          builder: (context, value, child) => Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.2 * value),
                  blurRadius: 20 * value,
                  spreadRadius: 10 * value,
                ),
              ],
            ),
            child: child,
          ),
        );
  }

  static Widget logo({double height = 40, Color? color}) {
    // Matrix to convert luminance to alpha (removes black backgrounds)
    const luminanceToAlpha = ColorFilter.matrix([
      1,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0.2126,
      0.7152,
      0.0722,
      0,
      0,
    ]);

    Widget logoImage = SvgPicture.asset(
      'assets/vaani.svg',
      height: height,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : luminanceToAlpha,
    );

    // If a color is provided, we must strip the black background FIRST,
    // and THEN apply the srcIn tint filter to the resulting transparency.
    if (color != null) {
      return ColorFiltered(
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        child: ColorFiltered(
          colorFilter: luminanceToAlpha,
          child: SvgPicture.asset('assets/vaani.svg', height: height),
        ),
      );
    }

    return logoImage;
  }

  static Widget logoAnimated({double height = 60, Color? color}) {
    final effectiveColor = color ?? Colors.white;
    return logo(height: height, color: color)
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(
          duration: 3.seconds,
          color: effectiveColor.withValues(alpha: 0.3),
        )
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
                  color: const Color(
                    0xCC0A0A1F,
                  ), // Solid high-performance surface
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
                width: double
                    .infinity, // Ensure bounded width for children (Expanded/Row)
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
    double size = 224,
    bool isPlaying = false,
    Color? accentColor,
  }) {
    final activeColor = accentColor ?? const Color(0xFF256AF4);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: activeColor.withValues(alpha: isPlaying ? 0.4 : 0.2),
            blurRadius: isPlaying ? 60 : 40,
            spreadRadius: isPlaying ? 15 : 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Glow Ring
          Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: activeColor.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
              )
              .animate(onPlay: (c) => isPlaying ? c.repeat() : c.stop())
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 2.seconds,
                curve: Curves.easeInOut,
              ),

          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              border: Border.all(color: activeColor.withValues(alpha: 0.3)),
              image: const DecorationImage(
                image: CachedNetworkImageProvider(
                  'https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=2662&auto=format&fit=crop',
                ),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
            child: Center(child: child),
          ),
        ],
      ),
    );
  }

  /// Aesthetic Waveform Visualization
  static Widget aestheticWaveform({bool isPlaying = false, Color? color}) {
    final activeColor = color ?? PremiumTokens.nebulaBlue;
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(30, (index) {
          return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                width: 2.5,
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.5 + (index % 5 / 10)),
                  borderRadius: BorderRadius.circular(10),
                ),
              )
              .animate(
                onPlay: (c) => isPlaying ? c.repeat(reverse: true) : c.stop(),
              )
              .custom(
                duration: (500 + index * 50).ms,
                builder: (context, value, child) {
                  final double h = 10 + (value * (15 + (index % 7) * 4));
                  return SizedBox(height: h, child: child);
                },
              );
        }),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Stitch Accent Bar - Fills available height naturally
            Container(
              width: 4,
              constraints: const BoxConstraints(minHeight: 88),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.6),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(padding: padding, child: child),
            ),
          ],
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
        // Ensure width is bounded for web/desktop or large screens
        final effectiveWidth = width.isFinite
            ? width
            : MediaQuery.sizeOf(context).width;
        final slotWidth =
            (effectiveWidth - 32) / 5; // Accounting for 16px horizontal padding
        final capsuleWidth = 58.0;
        final capsuleHeight = 44.0;

        return Container(
          height: 100,
          width: effectiveWidth,
          padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              // Glass Bar Container
              Container(
                height: 70,
                width: effectiveWidth - 32, // Strictly bound to parent width
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
                      left:
                          (selectedIndex * slotWidth) +
                          (slotWidth - capsuleWidth) / 2,
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
                    SizedBox(
                      width: double.infinity,
                      height: 70,
                      child: Row(
                        children: List.generate(items.length, (index) {
                          final item = items[index];
                          final isSelected = selectedIndex == index;

                          if (index == 2)
                            return const Expanded(child: SizedBox());

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
    void Function(LongPressStartDetails)? onLongPressStart,
    void Function(LongPressMoveUpdateDetails)? onLongPressMoveUpdate,
    void Function(LongPressEndDetails)? onLongPressEnd,
    bool isActive = false,
    int? count,
  }) {
    return _SacredVoidButtonInternal(
      onTap: onTap,
      onLongPressStart: onLongPressStart,
      onLongPressMoveUpdate: onLongPressMoveUpdate,
      onLongPressEnd: onLongPressEnd,
      isActive: isActive,
      count: count,
    );
  }

  /// Premium Naam Jap Counter Widget
  static Widget naamJapCounter({
    required int count,
    required VoidCallback onTap,
    int goal = 1008,
    double size = 200,
  }) {
    return _PremiumNaamJapCounterInternal(
      count: count,
      onTap: onTap,
      goal: goal,
      size: size,
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
                  color: Colors.white.withValues(
                    alpha: opacity * 1.5,
                  ), // High-perf opacity
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
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

  /// High-end ethereal card with subtle glow and premium glassmorphism
  static Widget etherealCard({
    required Widget child,
    double borderRadius = 32,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? glowColor,
    bool showGlow = true,
    bool optimized = true, // Added optimized toggle for high-performance rebuilds
  }) {
    final activeGlow = glowColor ?? PremiumTokens.nebulaBlue;
    final cardContent = Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0x15FFFFFF),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
      ),
      child: child,
    );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: activeGlow.withValues(alpha: 0.08),
                  blurRadius: 30,
                  spreadRadius: -10,
                ),
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: optimized
            ? cardContent
            : BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: cardContent,
              ),
      ),
    );
  }


  /// Premium ethereal capsule button
  static Widget etherealButton({
    required Widget child,
    required VoidCallback onTap,
    Color? color,
    double borderRadius = 35,
    EdgeInsets? padding,
    bool optimized = true, // Added optimized toggle
  }) {
    final activeColor = color ?? PremiumTokens.nebulaBlue;
    final buttonBody = Container(
      padding:
          padding ??
          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: activeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: activeColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: child,
    );

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: activeColor.withValues(alpha: 0.15),
              blurRadius: 15,
              spreadRadius: -2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: optimized
              ? buttonBody
              : BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: buttonBody,
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
            color: PremiumTokens.nebulaBlue.withValues(
              alpha: isVoid ? 0.12 : 0.08,
            ),
          ),

          // Transitionary Elements
          if (isVoid) ...[
            _buildBokeh(
              bottom: -50,
              left: -50,
              size: 350,
              color: PremiumTokens.nebulaBlue.withValues(alpha: 0.06),
            ),
            _buildMoon(bottom: 120, left: 60, size: 80),
          ] else ...[
            _buildBokeh(
              bottom: -100,
              left: -50,
              size: 300,
              color: PremiumTokens.celestialGlow.withValues(alpha: 0.04),
            ),
            _buildMoon(top: 60, left: 40, size: 60),
          ],

          // Unified Planet (Subtle)
          _buildPlanet(
            top: isVoid ? 200 : 120,
            right: isVoid ? 80 : 60,
            size: 30,
            color: isVoid
                ? Colors.deepPurpleAccent.withValues(alpha: 0.2)
                : Colors.blueAccent.withValues(alpha: 0.15),
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
    final body = Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const CachedNetworkImageProvider(
            'https://images.unsplash.com/photo-1528715471579-d1bcf0ba5e83?auto=format&fit=crop&w=800&q=80',
          ),
          repeat: ImageRepeat.repeat,
          scale: 0.5,
          opacity: 0.5,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.1),
              Colors.transparent,
            ],
            stops: const [0.5, 1.0],
          ),
        ),
      ),
    );

    return Opacity(
      opacity: opacity,
      child: AppTheme.lowPerformanceMode
          ? body
          : ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: body,
            ),
    );
  }

  static Widget _buildBokeh({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
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
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      ),
    );
  }

  static Widget _buildMoon({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
  }) {
    final body = Container(
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
      child: CustomPaint(painter: _CrescentMoonPainter()),
    );

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: RepaintBoundary(
        child: AppTheme.lowPerformanceMode
            ? body
            : body
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(duration: 2.seconds)
                  .moveY(
                    begin: 0,
                    end: -10,
                    duration: 4.seconds,
                    curve: Curves.easeInOut,
                  ),
      ),
    );
  }

  static Widget _buildPlanet({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
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
              colors: [
                color.withValues(alpha: 0.8),
                color.withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 20),
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
    bool isToggled = false,
    VoidCallback? onTap,
  }) {
    return _PremiumInteractiveIcon(
      folder: folder,
      fileName: fileName,
      size: size,
      color: color,
      autoPlay: autoPlay,
      resetAfterPlay: resetAfterPlay,
      isToggled: isToggled,
      onTap: onTap,
    );
  }

  /// Premium Custom Icon (SVG)
  static Widget customIcon({
    required String fileName,
    double size = 24,
    Color? color,
  }) {
    final String path = fileName.startsWith('assets/')
        ? fileName
        : '$svgRoot$fileName';
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
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

    if (url.startsWith('assets/')) {
      final imageWidget = Image.asset(
        url,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: PremiumTokens.accentDark,
          child: const Icon(Icons.broken_image, color: Colors.redAccent, size: 20),
        ),
      );
      if (borderRadius != null) {
        return ClipRRect(borderRadius: borderRadius, child: imageWidget);
      }
      return imageWidget;
    }

    final imageWidget = CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: width != null
          ? (width * 2).toInt() // Standard HD scaling
          : 600, // Reasonable default to prevent memory exhaustion
      memCacheHeight: height != null
          ? (height * 2).toInt()
          : null,
      maxWidthDiskCache: 1200, // Prevent huge disk cache
      maxHeightDiskCache: 1200,
      errorWidget: (context, url, error) {
        print("Image Loading Error: $error");
        return Container(
          width: width,
          height: height,
          color: PremiumTokens.accentDark,
          child: const Icon(
            Icons.broken_image,
            color: Colors.redAccent,
            size: 20,
          ),
        );
      },
      placeholder: (context, url) =>
          placeholder ??
          Container(
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
      child: IgnorePointer(ignoring: isFocusMode, child: child),
    );
  }

  /// SacredDivider: A spiritual separator with a central icon
  static Widget sacredDivider({Color? color, double width = 60}) {
    final activeColor = color ?? Colors.white.withValues(alpha: 0.1);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: width,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.transparent, activeColor]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "ॐ",
            style: GoogleFonts.spectral(color: activeColor, fontSize: 18),
          ),
        ),
        Container(
          width: width,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [activeColor, Colors.transparent]),
          ),
        ),
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
    return child
        .animate(onPlay: (c) => c.repeat(reverse: true))
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

  /// Premium Notification / Custom SnackBar
  static void showNotification(
    BuildContext context,
    String message, {
    IconData? icon,
    Color? color,
  }) {
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _PremiumNotificationOverlay(
        message: message,
        icon: icon,
        color: color ?? PremiumTokens.nebulaBlue,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

  /// Premium Sacred Search Bar (Variant 1_8)
  static Widget sacredSearchBar({
    required TextEditingController controller,
    required String hintText,
    required ValueChanged<String> onChanged,
    VoidCallback? onClear,
  }) {
    return Container(
      decoration: PremiumTokens.indigoGlass(opacity: 0.1),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.spectral(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.spectral(
            color: Colors.white.withValues(alpha: 0.2),
            fontSize: 18,
          ),
          prefixIcon: Icon(
            Iconsax.search_normal,
            color: PremiumTokens.starlightBlue.withValues(alpha: 0.5),
            size: 20,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.white38, size: 18),
                  onPressed: onClear,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: PremiumTokens.starlightBlue,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          filled: false,
        ),
      ),
    );
  }

  /// Premium Sacred Call Alert (Ritual Reminder)
  static void showSacredCall(
    BuildContext context, {
    required String ritualName,
    required String nextStep,
    required VoidCallback onBegin,
  }) {
    SacredRitualAlert.show(
      context,
      title: "Sacred Call",
      description: nextStep,
      ritualTitle: ritualName,
      onBegin: onBegin,
      onRemind: () => Navigator.pop(context),
    );
  }


  /// Sync System Status Bar with Sacred Void Aesthetic
  static void setSacredStatus() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: PremiumTokens.voidBlack,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _PremiumNotificationOverlay extends StatefulWidget {
  final String message;
  final IconData? icon;
  final Color color;
  final VoidCallback onDismiss;

  const _PremiumNotificationOverlay({
    required this.message,
    this.icon,
    required this.color,
    required this.onDismiss,
  });

  @override
  State<_PremiumNotificationOverlay> createState() =>
      _PremiumNotificationOverlayState();
}

class _PremiumNotificationOverlayState
    extends State<_PremiumNotificationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 24,
      right: 24,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _offsetAnimation,
          child: _SacredNotification(
            message: widget.message,
            icon: widget.icon,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}

class _SacredNotification extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Color color;

  const _SacredNotification({
    required this.message,
    this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: AppTheme.lowPerformanceMode
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        _buildNotificationIcon(),
                        const SizedBox(width: 16),
                        _buildNotificationContent(),
                      ],
                    ),
                  )
                : BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          _buildNotificationIcon(),
                          const SizedBox(width: 16),
                          _buildNotificationContent(),
                        ],
                      ),
                    ),
                  ),
          ),
        )
        .animate()
        .slideY(
          begin: -1.0,
          end: 0.0,
          curve: Curves.easeOutQuart,
          duration: 600.ms,
        )
        .fadeIn(duration: 300.ms);
  }

  Widget _buildNotificationIcon() {
    return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, color: PremiumTokens.silver, size: 28)
                : PremiumUI.logo(height: 28, color: PremiumTokens.silver),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 3.seconds,
          color: Colors.white.withValues(alpha: 0.2),
        );
  }

  Widget _buildNotificationContent() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "SANT-VAANI",
                style: PremiumTokens.sansStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: PremiumTokens.silver.withValues(alpha: 0.6),
                  letterSpacing: 2,
                ),
              ),
              Text(
                "now",
                style: PremiumTokens.sansStyle(
                  fontSize: 10,
                  color: PremiumTokens.silver.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          ShaderMask(
            shaderCallback: (bounds) =>
                PremiumTokens.silverGradient.createShader(bounds),
            child: Text(
              message.split('\n')[0],
              style: GoogleFonts.spectral(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          if (message.contains('\n'))
            Text(
              message.split('\n').sublist(1).join(' '),
              style: PremiumTokens.sansStyle(
                fontSize: 12,
                color: PremiumTokens.silver.withValues(alpha: 0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
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
    final rect = Rect.fromCenter(
      center: center,
      width: size.width * 1.8,
      height: size.height * 0.4,
    );

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
      ..addOval(
        Rect.fromCircle(
          center: center.translate(radius * 0.4, -radius * 0.15),
          radius: radius * 0.95,
        ),
      );

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
  final void Function(LongPressStartDetails)? onLongPressStart;
  final void Function(LongPressMoveUpdateDetails)? onLongPressMoveUpdate;
  final void Function(LongPressEndDetails)? onLongPressEnd;
  final bool isActive;
  final int? count;

  const _SacredVoidButtonInternal({
    required this.onTap,
    this.onLongPressStart,
    this.onLongPressMoveUpdate,
    this.onLongPressEnd,
    this.isActive = false,
    this.count,
  });

  @override
  State<_SacredVoidButtonInternal> createState() =>
      _SacredVoidButtonInternalState();
}

class _SacredVoidButtonInternalState extends State<_SacredVoidButtonInternal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Default duration
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _SacredVoidButtonInternal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (_controller.duration != null) {
        if (widget.isActive) {
          _controller.forward(from: _controller.value);
        } else {
          _controller.reverse(from: _controller.value);
        }
      }
    }
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    widget.onTap();
    if (_controller.duration != null) {
      _controller.forward(from: 0.0).then((_) {
        if (mounted && !widget.isActive) {
          _controller.value = 0.0;
        }
      });
    }
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    if (widget.onLongPressStart != null) {
      HapticFeedback.heavyImpact();
      widget.onLongPressStart!(details);
    }
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (widget.onLongPressMoveUpdate != null) {
      widget.onLongPressMoveUpdate!(details);
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    if (widget.onLongPressEnd != null) {
      widget.onLongPressEnd!(details);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onLongPressStart: _handleLongPressStart,
      onLongPressMoveUpdate: _handleLongPressMoveUpdate,
      onLongPressEnd: _handleLongPressEnd,
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
                  color:
                      (widget.isActive
                              ? PremiumTokens.saffronGlow
                              : PremiumTokens.nebulaBlue)
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
              color: const Color(
                0xFF03030F,
              ).withValues(alpha: 0.9), // Near-black void
              border: Border.all(
                color:
                    (widget.isActive ? PremiumTokens.saffronGlow : Colors.white)
                        .withValues(alpha: 0.4),
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
              child: widget.count != null && widget.count! > 0
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min, // Ensure min size
                        children: [
                          const Icon(
                                Iconsax.heart5,
                                color: Colors.white,
                                size: 24,
                              )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .scale(
                                begin: const Offset(1, 1),
                                end: const Offset(1.2, 1.2),
                                duration: 800.ms,
                              ),
                          const SizedBox(height: 2),
                          Text(
                            widget.count.toString(),
                            style: GoogleFonts.spectral(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(12),
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
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
  State<_PremiumAnimatedNavButton> createState() =>
      _PremiumAnimatedNavButtonState();
}

class _PremiumAnimatedNavButtonState extends State<_PremiumAnimatedNavButton>
    with SingleTickerProviderStateMixin {
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
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
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
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: PremiumUI.customIcon(
              fileName: widget.isSelected
                  ? widget.item.activeIconSvg
                  : widget.item.iconSvg,
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
  final bool isToggled;
  final VoidCallback? onTap;

  const _PremiumInteractiveIcon({
    required this.folder,
    required this.fileName,
    this.size = 24,
    this.color,
    this.autoPlay = false,
    this.resetAfterPlay = true,
    this.isToggled = false,
    this.onTap,
  });

  @override
  State<_PremiumInteractiveIcon> createState() =>
      _PremiumInteractiveIconState();
}

class _PremiumInteractiveIconState extends State<_PremiumInteractiveIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Default duration
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_PremiumInteractiveIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isToggled != oldWidget.isToggled) {
      if (_controller.duration != null) {
        if (widget.isToggled) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      } else if (widget.isToggled) {
        _controller.value = 1.0;
      } else {
        _controller.value = 0.0;
      }
    }
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    if (widget.onTap != null) {
      widget.onTap!();
    }

    // Manual trigger for non-toggle icons (like share, send, or back button)
    // For toggle icons, didUpdateWidget handles the animation transition
    if (_controller.duration != null &&
        !widget.isToggled &&
        widget.resetAfterPlay) {
      _controller.forward(from: 0.0).then((_) {
        if (mounted && !widget.isToggled) {
          _controller.value = 0.0;
        }
      });
    }
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
        if (widget.isToggled) {
          _controller.value = 1.0;
        } else if (widget.autoPlay) {
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
      child: SizedBox(width: widget.size, height: widget.size, child: lottie),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// SACRED ACTION MENU - Pinterest-style Circular Menu for High-End UX
/// ═══════════════════════════════════════════════════════════════════════════

class SacredActionMenu extends StatefulWidget {
  final Offset position;
  final List<SacredMenuItem> items;
  final VoidCallback onClose;
  final ValueNotifier<Offset?>? pointerPosition;

  const SacredActionMenu({
    super.key,
    required this.position,
    required this.items,
    required this.onClose,
    this.pointerPosition,
  });

  @override
  State<SacredActionMenu> createState() => SacredActionMenuState();
}

class SacredActionMenuState extends State<SacredActionMenu> {
  bool _isVisible = false;
  int _hoveredIndex = -1;

  // Public method to be called via GlobalKey by the trigger (button)
  void handleRelease() {
    if (_hoveredIndex != -1) {
      HapticFeedback.mediumImpact();
      widget.items[_hoveredIndex].onTap();
    }

    if (mounted) {
      setState(() => _isVisible = false);
      Future.delayed(const Duration(milliseconds: 300), widget.onClose);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 10), () {
      if (mounted) setState(() => _isVisible = true);
    });

    // Listen to pointer movements from the button
    widget.pointerPosition?.addListener(_updateHover);
  }

  @override
  void dispose() {
    widget.pointerPosition?.removeListener(_updateHover);
    super.dispose();
  }

  void _updateHover() {
    final pointer = widget.pointerPosition?.value;
    if (pointer == null) {
      if (_hoveredIndex != -1) setState(() => _hoveredIndex = -1);
      return;
    }

    int closestIndex = -1;
    double minDistance = 80.0; // Hit threshold increased for larger radius

    for (int i = 0; i < widget.items.length; i++) {
      final itemPos = _getItemPosition(i);
      final distance = (pointer - itemPos).distance;
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    if (closestIndex != _hoveredIndex) {
      HapticFeedback.lightImpact();
      setState(() => _hoveredIndex = closestIndex);
    }
  }

  Offset _getItemPosition(int index) {
    const double startAngle = 3.14159 + 0.3;
    const double endAngle = 2 * 3.14159 - 0.3;
    final double angleStep =
        (endAngle - startAngle) / (widget.items.length - 1);
    final double angle = startAngle + (index * angleStep);
    const double radius = 140.0;

    return widget.position +
        Offset(radius * math.cos(angle), radius * math.sin(angle));
  }

  void _handleClose() {
    // Standard close (e.g. tap on background)
    setState(() => _isVisible = false);
    Future.delayed(const Duration(milliseconds: 300), widget.onClose);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Blur/Dim Background
          GestureDetector(
            onTap: _handleClose,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _isVisible ? 1 : 0),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) => Container(
                color: Colors.black.withValues(alpha: value * 0.7),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: value * 5,
                    sigmaY: value * 5,
                  ),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
          ),

          // Menu Items in an Arc
          ...List.generate(widget.items.length, (index) {
            final item = widget.items[index];

            // Layout logic: Items spread in an arc above the tap point
            final double screenWidth = MediaQuery.sizeOf(context).width;
            final double minDimension = math.min(screenWidth, MediaQuery.sizeOf(context).height);
            final double radius = math.min(140.0, minDimension * 0.35); // Responsive radius

            const double startAngle = 3.14159 + 0.3; // Top-leftish
            const double endAngle = 2 * 3.14159 - 0.3; // Top-rightish
            final double angleStep =
                (endAngle - startAngle) / (widget.items.length - 1);
            final double angle = startAngle + (index * angleStep);

            final double offsetX = radius * math.cos(angle);
            final double offsetY = radius * math.sin(angle);

            return AnimatedPositioned(
              duration: Duration(milliseconds: 300 + (index * 60)),
              curve: Curves.elasticOut,
              left: widget.position.dx + (_isVisible ? offsetX : 0) - 60,
              top: widget.position.dy + (_isVisible ? offsetY : 0) - 60,
              child: SizedBox(
                width: 120,
                height: 120,
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isVisible ? 1 : 0,
                    child: _buildMenuItem(item, index == _hoveredIndex),
                  ),
                ),
              ),
            );
          }),

          // Original Tap Point Indicator / Icon Sync
          Positioned(
                left: widget.position.dx - 35,
                top: widget.position.dy - 35,
                child: GestureDetector(
                  onTap: _handleClose,
                  child: Hero(
                    tag: 'sacred_void_center',
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _hoveredIndex != -1
                            ? widget.items[_hoveredIndex].color.withValues(
                                alpha: 0.2,
                              )
                            : Colors.white.withValues(alpha: 0.1),
                        border: Border.all(
                          color: _hoveredIndex != -1
                              ? widget.items[_hoveredIndex].color.withValues(
                                  alpha: 0.6,
                                )
                              : Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          if (_hoveredIndex != -1)
                            BoxShadow(
                              color: widget.items[_hoveredIndex].color
                                  .withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                        ],
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _hoveredIndex != -1
                              ? widget.items[_hoveredIndex].icon
                              : Icons.close,
                          key: ValueKey(_hoveredIndex),
                          color: _hoveredIndex != -1
                              ? widget.items[_hoveredIndex].color
                              : Colors.white,
                          size: _hoveredIndex != -1 ? 30 : 24,
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .animate(target: _isVisible ? 1 : 0)
              .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(SacredMenuItem item, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 80 : 65,
              height: isSelected ? 80 : 65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? item.color.withValues(alpha: 0.9)
                    : PremiumTokens.voidBlack.withValues(alpha: 0.9),
                border: Border.all(
                  color: item.color.withValues(alpha: isSelected ? 0.8 : 0.4),
                  width: isSelected ? 3 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: item.color.withValues(alpha: isSelected ? 0.6 : 0.2),
                    blurRadius: isSelected ? 25 : 15,
                    spreadRadius: isSelected ? 5 : 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  item.icon,
                  color: isSelected ? PremiumTokens.voidBlack : Colors.white,
                  size: isSelected ? 32 : 26,
                ),
              ),
            )
            .animate(target: _isVisible ? 1 : 0)
            .scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              curve: Curves.elasticOut,
              duration: 500.ms,
            )
            .fadeIn(duration: 200.ms),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: Text(
            item.label.toUpperCase(),
            style: PremiumTokens.sansStyle(
              fontSize: isSelected ? 11 : 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ).animate(target: _isVisible ? 1 : 0).fadeIn(delay: 200.ms),
      ],
    );
  }
}

class SacredMenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  SacredMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

/// Helper to trigger the Pinterest-style Overlay Menu
void showSacredMenu(
  BuildContext context,
  Offset position,
  List<SacredMenuItem> items,
  ValueNotifier<Offset?>? pointerPosition, {
  Key? key,
}) {
  HapticFeedback.heavyImpact();
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => SacredActionMenu(
      key: key,
      position: position,
      items: items,
      pointerPosition: pointerPosition,
      onClose: () => entry.remove(),
    ),
  );
  Overlay.of(context).insert(entry);
}

class _PremiumNaamJapCounterInternal extends StatefulWidget {
  final int count;
  final VoidCallback onTap;
  final int goal;
  final double size;

  const _PremiumNaamJapCounterInternal({
    required this.count,
    required this.onTap,
    required this.goal,
    required this.size,
  });

  @override
  State<_PremiumNaamJapCounterInternal> createState() =>
      _PremiumNaamJapCounterInternalState();
}

class _PremiumNaamJapCounterInternalState
    extends State<_PremiumNaamJapCounterInternal>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _pressController;
  late Animation<double> _pressAnimation;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutCubic),
    );

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pressAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOutCubic),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pressController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_PremiumNaamJapCounterInternal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count) {
      _pulseController
          .forward(from: 0.0)
          .then((_) => _pulseController.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    final int completedMalas = widget.count ~/ 108;
    final int currentBead = widget.count == 0 ? 0 : (widget.count - 1) % 108 + 1;
    final progress = (currentBead / 108.0).clamp(0.0, 1.0);

    return GestureDetector(
      onTapDown: (_) {
        _pressController.animateTo(
          1.0,
          curve: Curves.easeOutCubic,
          duration: const Duration(milliseconds: 150),
        );
      },
      onTapUp: (_) {
        _pressController.animateTo(
          0.0,
          curve: Curves.easeOutBack,
          duration: const Duration(milliseconds: 400),
        );
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      onTapCancel: () {
        _pressController.animateTo(
          0.0,
          curve: Curves.easeOutCubic,
          duration: const Duration(milliseconds: 100),
        );
      },
      child: ScaleTransition(
        scale: _pressAnimation,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Aura
              PremiumUI.nebulaGlow(size: widget.size * 1.5, opacity: 0.4),

              // Rotating Background Disk
              RepaintBoundary(
                child: RotationTransition(
                  turns: _rotationController,
                  child: Container(
                    width: widget.size * 0.8,
                    height: widget.size * 0.8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          PremiumTokens.nebulaBlue.withValues(alpha: 0.18),
                          PremiumTokens.nebulaBlue.withValues(alpha: 0.04),
                          PremiumTokens.voidBlack,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                    child: PremiumUI.mandalaOverlay(opacity: 0.06),
                  ),
                ),
              ),

              // Progress Ring (Bead Progress)
              RepaintBoundary(
                child: SizedBox(
                  width: widget.size * 0.85,
                  height: widget.size * 0.85,
                  child: CustomPaint(
                    painter: _NaamJapProgressPainter(
                      progress: progress,
                      color: PremiumTokens.nebulaBlue,
                      glowColor: PremiumTokens.celestialGlow,
                    ),
                  ),
                ),
              ),

              // Center Content with Pulse
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: widget.size * 0.55,
                  height: widget.size * 0.55,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF020205).withValues(
                      alpha: 0.98,
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: PremiumTokens.nebulaBlue.withValues(alpha: 0.25),
                        blurRadius: 40,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'BEAD',
                          style: PremiumTokens.sansStyle(
                            fontSize: widget.size * 0.035,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: PremiumTokens.nebulaBlue,
                          ),
                        ),
                        Text(
                          currentBead.toString(),
                          style: PremiumTokens.lailaStyle(
                            fontSize: widget.size * 0.18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'MALA $completedMalas',
                          style: PremiumTokens.sansStyle(
                            fontSize: widget.size * 0.045,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NaamJapProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color glowColor;

  _NaamJapProgressPainter({
    required this.progress,
    required this.color,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;
    const strokeWidth = 8.0;

    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [color, glowColor],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );

    if (progress > 0 && !AppTheme.lowPerformanceMode) {
      final tightGlowPaint = Paint()
        ..color = glowColor.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 1.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        tightGlowPaint,
      );

      final broadGlowPaint = Paint()
        ..color = glowColor.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 4.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25)
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        broadGlowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NaamJapProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
