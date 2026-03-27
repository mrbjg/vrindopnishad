import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import 'package:flutter/services.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// PRESSABLE SCALE - Immediate press animation with haptic feedback
/// Uses GestureDetector with proper tap vs scroll handling
/// ═══════════════════════════════════════════════════════════════════════════

class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleFactor;
  final bool haptic;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleFactor = 0.97,
    this.haptic = true,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    if (widget.haptic) {
      HapticFeedback.selectionClick();
    }
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleFactor : 1.0,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _isPressed ? 0.85 : 1.0,
          duration: const Duration(milliseconds: 80),
          child: widget.child,
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// ANIMATED LOAD ITEM - Plays animation once when item first appears
/// Used for "Load More" items, doesn't re-animate on scroll
/// ═══════════════════════════════════════════════════════════════════════════

class AnimatedLoadItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;

  const AnimatedLoadItem({
    super.key,
    required this.child,
    required this.index,
    this.delay = Duration.zero,
  });

  @override
  State<AnimatedLoadItem> createState() => _AnimatedLoadItemState();
}

class _AnimatedLoadItemState extends State<AnimatedLoadItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Stagger the animation based on index within the new batch
    Future.delayed(Duration(milliseconds: 50 * (widget.index % 5)), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// ANIMATED SACRED BACKGROUND - Floating ॐ particles and sacred geometry
/// Creates a mesmerizing, peaceful ambient background
/// ═══════════════════════════════════════════════════════════════════════════

class AnimatedSacredBackground extends StatefulWidget {
  final Widget? child;
  final int particleCount;
  final bool showGeometry;

  const AnimatedSacredBackground({
    super.key,
    this.child,
    this.particleCount = 8,
    this.showGeometry = false,
  });

  @override
  State<AnimatedSacredBackground> createState() =>
      _AnimatedSacredBackgroundState();
}

class _AnimatedSacredBackgroundState extends State<AnimatedSacredBackground> {
  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Stack(
      children: [
        // Elegant gradient background - Isolated with RepaintBoundary
        RepaintBoundary(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF0F0F14),
                            const Color(0xFF1A1A28),
                            const Color(0xFF0F0F14),
                          ]
                        : [
                            const Color(0xFFFDFBF7),
                            const Color(0xFFFFF8EB),
                            const Color(0xFFFDFBF7),
                          ],
                  ),
                ),
              ),
              if (widget.showGeometry)
                Center(child: _SacredGeometry(isDark: isDark)),
            ],
          ),
        ),
        // Child content (typically a scroll view) - Isolated from background
        if (widget.child != null)
          RepaintBoundary(
            key: const ValueKey('sacred_background_content'),
            child: widget.child!,
          ),
      ],
    );
  }
}

class _SacredGeometry extends StatelessWidget {
  final bool isDark;

  const _SacredGeometry({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: CustomPaint(painter: _FlowerOfLifePainter(isDark: isDark)),
    ).animate(onPlay: (c) => c.repeat()).rotate(duration: 60.seconds);
  }
}

class _FlowerOfLifePainter extends CustomPainter {
  final bool isDark;

  _FlowerOfLifePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : AppTheme.primaryColor).withValues(alpha: 0.05,)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 4;

    // Draw center circle
    canvas.drawCircle(center, radius, paint);

    // Draw 6 surrounding circles
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final offset = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawCircle(offset, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ═══════════════════════════════════════════════════════════════════════════
/// GLASSMORPHISM CARD - Frosted glass effect with blur (optimized)
/// ═══════════════════════════════════════════════════════════════════════════

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 2, // Reduced from 4 for better performance
    this.opacity = 0.08,
    this.borderRadius,
    this.padding,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final radius = borderRadius ?? BorderRadius.circular(AppTheme.radiusLarge);

    Widget contents = Container(
      padding: padding ?? const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: (isDark ? Colors.black : Colors.white).withValues(alpha: AppTheme.lowPerformanceMode ? opacity * 1.5 : opacity,),
        borderRadius: radius,
        border: Border.all(
          color:
              borderColor ??
              (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
          width: 0.8,
        ),
      ),
      child: child,
    );

    // Wrap with RepaintBoundary to prevent cascading repaints
    contents = RepaintBoundary(child: contents);

    if (onTap != null) {
      // Use PressableScale for immediate tap feedback
      contents = PressableScale(onTap: onTap, child: contents);
    }

    // Skip BackdropFilter AND ClipRRect entirely if blur is 0 or lowPerformanceMode is on
    // This is a CRITICAL optimization for scroll smoothness
    if (blur <= 0 || AppTheme.lowPerformanceMode) {
      return contents;
    }

    Widget card = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: contents,
      ),
    );

    return card;
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// SHIMMER LOADING - Beautiful skeleton loader
/// ═══════════════════════════════════════════════════════════════════════════

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
            borderRadius:
                borderRadius ?? BorderRadius.circular(AppTheme.radiusSmall),
          ),
        )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1500.ms,
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.8),
        );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// GRADIENT CATEGORY CARD - Stunning category display
/// ═══════════════════════════════════════════════════════════════════════════

class GradientCategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback? onTap;
  final int itemCount;

  const GradientCategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.gradientColors,
    this.onTap,
    this.itemCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(AppTheme.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (itemCount > 0)
                    Text(
                      '$itemCount items',
                      style: GoogleFonts.outfit(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// ANIMATED GREETING - Sacred Hindi greetings with time-based blessings
/// ═══════════════════════════════════════════════════════════════════════════

class AnimatedGreeting extends StatelessWidget {
  const AnimatedGreeting({super.key});

  // Sacred greetings that rotate based on time
  static const List<String> _sacredGreetings = [
    'श्री राधे',
    'श्री हरिवंश',
    'श्री हरिदास',
    'राधे राधे',
    'जय श्री कृष्ण',
    'हरे कृष्ण',
    'निताई गौर हरि बोल',
    'श्यामा श्याम',
    'प्यारी लाल',
  ];

  String get _greeting {
    // Rotate through sacred greetings based on day of week
    final dayIndex = DateTime.now().weekday % _sacredGreetings.length;
    return _sacredGreetings[dayIndex];
  }

  String get _subtitle {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'ब्रह्म मुहूर्त में स्वागत है';
    if (hour < 12) return 'आज का दिन मंगलमय हो';
    if (hour < 17) return 'आध्यात्मिक यात्रा जारी रखें';
    if (hour < 21) return 'संध्या वंदन का समय';
    return 'शांति से विश्राम करें';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greeting,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
            letterSpacing: 0.5,
          ),
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0),
        const SizedBox(height: 4),
        Text(
              _subtitle,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textMuted(context),
              ),
            )
            .animate()
            .fadeIn(delay: 200.ms, duration: 600.ms)
            .slideX(begin: -0.1, end: 0),
      ],
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// PULSING OM BUTTON - Animated sacred button
/// ═══════════════════════════════════════════════════════════════════════════

class PulsingOmButton extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;

  const PulsingOmButton({super.key, this.size = 60, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          Container(
                width: size * 1.4,
                height: size * 1.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.3),
                      AppTheme.primaryColor.withValues(alpha: 0),
                    ],
                  ),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1),
                duration: 2.seconds,
              ),
          // Inner circle
          Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                  ),
                  boxShadow: AppTheme.glowShadow(AppTheme.primaryColor),
                ),
                child: Center(
                  child: Padding(
                    // Small offset to visually center the ॐ character
                    padding: EdgeInsets.only(top: size * 0.02),
                    child: Text(
                      'ॐ',
                      style: TextStyle(
                        fontSize: size * 0.5,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        height: 1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.05, 1.05),
                duration: 1.5.seconds,
                curve: Curves.easeInOut,
              ),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// RADIAL MENU - Beautiful circular action menu
/// ═══════════════════════════════════════════════════════════════════════════

class RadialMenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const RadialMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });
}

class RadialMenu extends StatefulWidget {
  final List<RadialMenuItem> items;
  final Widget child;

  const RadialMenu({super.key, required this.items, required this.child});

  @override
  State<RadialMenu> createState() => _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      _isOpen ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Menu items
        ...List.generate(widget.items.length, (index) {
          final item = widget.items[index];
          final angle = (index - widget.items.length / 2 + 0.5) * 0.5;

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final offset = Offset(
                math.sin(angle) * 80 * _controller.value,
                -math.cos(angle) * 80 * _controller.value,
              );
              return Transform.translate(
                offset: offset,
                child: Opacity(
                  opacity: _controller.value,
                  child: Transform.scale(
                    scale: _controller.value,
                    child: GestureDetector(
                      onTap: () {
                        item.onTap?.call();
                        _toggle();
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: item.color.withValues(alpha: 0.4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(item.icon, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
        // Main button
        GestureDetector(onTap: _toggle, child: widget.child),
      ],
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// QUOTE OF THE DAY CARD - Inspirational quote display
/// ═══════════════════════════════════════════════════════════════════════════

class QuoteCard extends StatelessWidget {
  final String quote;
  final String? source;

  const QuoteCard({super.key, required this.quote, this.source});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Container(
      padding: const EdgeInsets.all(AppTheme.space24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
              : [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppTheme.sacredViolet : AppTheme.primaryColor)
                .withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote,
            size: 32,
            color: isDark
                ? Colors.white24
                : AppTheme.primaryColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppTheme.space12),
          Text(
            quote,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : AppTheme.lightTextPrimary,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (source != null) ...[
            const SizedBox(height: AppTheme.space16),
            Text(
              '— $source',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : AppTheme.lightTextSecondary,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SACRED OM SYMBOL - Decorative element
// ═══════════════════════════════════════════════════════════════════════════════
class SacredOm extends StatelessWidget {
  final double size;
  final Color? color;
  final double opacity;

  const SacredOm({super.key, this.size = 40, this.color, this.opacity = 0.15});

  @override
  Widget build(BuildContext context) {
    return Text(
      'ॐ',
      style: TextStyle(
        fontSize: size,
        color: (color ?? AppTheme.primaryColor).withValues(alpha: opacity),
        fontWeight: FontWeight.w300,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CATEGORY PILL - Minimal category chip
// ═══════════════════════════════════════════════════════════════════════════════
class CategoryPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;

  const CategoryPill({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.space16,
          vertical: AppTheme.space8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : isDark
              ? AppTheme.darkSurface
              : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : isDark
                ? AppTheme.darkBorder
                : AppTheme.lightBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : AppTheme.textSecondary(context),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : AppTheme.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// READING TIME BADGE
// ═══════════════════════════════════════════════════════════════════════════════
class ReadingTimeBadge extends StatelessWidget {
  final int minutes;

  const ReadingTimeBadge({super.key, required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space8,
        vertical: AppTheme.space4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 12,
            color: AppTheme.textMuted(context),
          ),
          const SizedBox(width: 4),
          Text(
            '$minutes min',
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: AppTheme.textMuted(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
