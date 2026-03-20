import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/audio_provider.dart';
import '../core/design_system.dart';
import '../features/global_player_screen.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioProvider);
    final content = audioState.currentContent;
    
    if (content == null) return const SizedBox.shrink();

    final isPlaying = audioState.isPlaying;
    final progress = audioState.duration.inMilliseconds > 0 
        ? audioState.position.inMilliseconds / audioState.duration.inMilliseconds 
        : 0.0;
    
    final accentColor = _getCategoryColor(content.category);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => GlobalPlayerScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.isFinite ? constraints.maxWidth : MediaQuery.sizeOf(context).width;
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            height: 68, 
            width: width - 24, // Accommodate margin
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 0.5,
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
                                      color: Colors.white,
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
                              icon: Icon(Iconsax.backward_10_seconds, color: Colors.white.withValues(alpha: 0.4), size: 18),
                              onPressed: () {
                                HapticFeedback.lightImpact();
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
                                  : Icon(isPlaying ? Iconsax.pause5 : Iconsax.play5, color: Colors.white, size: 28),
                                onPressed: () {
                                  HapticFeedback.mediumImpact();
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
                          color: Colors.white.withValues(alpha: 0.05),
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
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
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
        child: Text(
          'ॐ',
          style: TextStyle(
            fontSize: 20, 
            color: accentColor, 
            shadows: [Shadow(color: accentColor, blurRadius: 8)]
          ),
        ),
      ),
    ).animate(
      onPlay: (controller) => isPlaying ? controller.repeat() : controller.stop(),
    )
    .shimmer(
      duration: 2.seconds,
      color: Colors.white.withValues(alpha: 0.1),
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
    if (category.contains('shloka')) return PremiumTokens.nebulaBlue;
    if (category.contains('mantra')) return PremiumTokens.saffronGlow;
    if (category.contains('poem')) return PremiumTokens.celestialGlow;
    return PremiumTokens.nebulaBlue;
  }
}
