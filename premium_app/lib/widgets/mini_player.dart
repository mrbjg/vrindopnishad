import 'package:premium_app/core/providers.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/audio_provider.dart';
import '../core/design_system.dart';
import '../features/global_player_screen.dart';

class MiniPlayer extends ConsumerStatefulWidget {
  const MiniPlayer({super.key});

  @override
  ConsumerState<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends ConsumerState<MiniPlayer> {
  double _dragOffset = 0;
  bool _isDismissing = false;

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioProvider);
    final content = audioState.currentContent;
    
    if (content == null || _isDismissing) return const SizedBox.shrink();

    final isPlaying = audioState.isPlaying;
    final progress = audioState.duration.inMilliseconds > 0 
        ? audioState.position.inMilliseconds / audioState.duration.inMilliseconds 
        : 0.0;
    
    final accentColor = _getCategoryColor(content.category);

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta! > 0) {
          setState(() {
            _dragOffset += details.primaryDelta!;
          });
        }
      },
      onVerticalDragEnd: (details) {
        if (_dragOffset > 80) {
          setState(() => _isDismissing = true);
          AppHapticFeedback.mediumImpact();
          ref.read(audioProvider.notifier).stop().then((_) {
            if (mounted) {
              setState(() {
                _dragOffset = 0;
                _isDismissing = false;
              });
            }
          });
        } else {
          setState(() {
            _dragOffset = 0;
          });
        }
      },
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const GlobalPlayerScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: Transform.translate(
        offset: Offset(0, _dragOffset),
        child: Opacity(
          opacity: (1 - (_dragOffset / 200)).clamp(0.0, 1.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth.isFinite ? constraints.maxWidth : MediaQuery.sizeOf(context).width;
              
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                height: 68, 
                width: width - 24, // Accommodate margin
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: PremiumTokens.isDark ? 0.45 : 0.08,
                      ),
                      blurRadius: 16,
                      spreadRadius: -2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: PremiumTokens.surfaceCard.withValues(
                          alpha: PremiumTokens.isDark ? 0.72 : 0.85,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: PremiumTokens.textPrimary.withValues(
                            alpha: PremiumTokens.isDark ? 0.15 : 0.18,
                          ),
                          width: 0.8,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Progress Background
                          FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    accentColor.withValues(alpha: 0.0),
                                    accentColor.withValues(alpha: 0.15),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          // Content
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                _buildDisk(accentColor, isPlaying, audioState.isLoading),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        content.title,
                                        style: GoogleFonts.manrope(
                                          color: PremiumTokens.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        audioState.isLoading ? "Tuning Ethereal Frequencies..." : content.category.toUpperCase(),
                                        style: GoogleFonts.manrope(
                                          color: audioState.isLoading ? PremiumTokens.saffronGlow : accentColor.withValues(alpha: 0.6),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                IconButton(
                                  icon: Icon(Iconsax.backward_10_seconds, color: PremiumTokens.textPrimary.withValues(alpha: 0.4), size: 18),
                                  onPressed: () {
                                    AppHapticFeedback.lightImpact();
                                    ref.read(audioProvider.notifier).skipBackward();
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 8),
                                // Improved Play Button with explicit sizing
                                SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: IconButton(
                                    icon: audioState.isLoading 
                                      ? SizedBox(
                                          width: 20, 
                                          height: 20, 
                                          child: CircularProgressIndicator(strokeWidth: 2, color: accentColor)
                                        )
                                      : Icon(isPlaying ? Iconsax.pause5 : Iconsax.play5, color: PremiumTokens.textPrimary, size: 28),
                                    onPressed: () {
                                      AppHapticFeedback.mediumImpact();
                                      ref.read(audioProvider.notifier).togglePlayPause();
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Progress Line
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: 2,
                              width: double.infinity,
                              color: PremiumTokens.borderSubtle,
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress.clamp(0.0, 1.0),
                                child: Container(color: accentColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
        ),
      ),
    );
  }

  Widget _buildDisk(Color accentColor, bool isPlaying, bool isLoading) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accentColor.withValues(alpha: 0.1),
        border: Border.all(color: accentColor.withValues(alpha: 0.2), width: 1),
        boxShadow: isLoading ? [
          BoxShadow(color: accentColor.withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 2)
        ] : [],
      ),
      child: Center(
        child: RepaintBoundary(
          child: SvgPicture.asset(
            'assets/shriJiMukut.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              accentColor, 
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    ).animate(
      onPlay: (controller) {
        if (isPlaying) {
          controller.repeat();
        } else {
          controller.stop();
        }
      },
    )
    .shimmer(
      duration: 2.seconds,
      color: PremiumTokens.borderMedium,
    )
    .custom(
      builder: (context, value, child) {
        return RotationTransition(
          turns: AlwaysStoppedAnimation(value),
          child: child,
        );
      },
      duration: 12.seconds,
    );
  }

  Color _getCategoryColor(String category) {
    category = category.toLowerCase();
    if (category.contains('shloka')) return PremiumTokens.activeAccent;
    if (category.contains('mantra')) return PremiumTokens.saffronGlow;
    if (category.contains('poem')) return PremiumTokens.celestialGlow;
    return PremiumTokens.activeAccent;
  }
}
