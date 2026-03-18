import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/audio_provider.dart';
import '../core/design_system.dart';
import '../core/content_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';

class GlobalPlayerScreen extends ConsumerStatefulWidget {
  const GlobalPlayerScreen({super.key});

  @override
  ConsumerState<GlobalPlayerScreen> createState() => _GlobalPlayerScreenState();
}

class _GlobalPlayerScreenState extends ConsumerState<GlobalPlayerScreen> with TickerProviderStateMixin {
  late AnimationController _diskController;
  bool _isDragging = false;
  double _dragValue = 0.0;

  @override
  void initState() {
    super.initState();
    _diskController = AnimationController(vsync: this, duration: 20.seconds);
  }

  @override
  void dispose() {
    _diskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioProvider);
    final isPlaying = audioState.isPlaying;
    final currentContent = audioState.currentContent;

    if (isPlaying) {
      _diskController.repeat();
    } else {
      _diskController.stop();
    }

    final accentColor = _getCategoryColor(currentContent?.category ?? "");

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background
          Positioned.fill(child: PremiumUI.masterBackground(index: 2)),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                const Spacer(flex: 1),
                
                // Divine Disk
                Center(
                  child: RotationTransition(
                    turns: _diskController,
                    child: PremiumUI.nebulaDisk(
                      size: MediaQuery.of(context).size.width * 0.7,
                      isPlaying: isPlaying,
                      accentColor: accentColor,
                      child: Text(
                        'ॐ',
                        style: GoogleFonts.spectral(
                          fontSize: 80,
                          color: Colors.white.withOpacity(0.9),
                          shadows: [
                            Shadow(color: accentColor, blurRadius: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
                
                const Spacer(flex: 1),
                
                // Track Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      Text(
                        currentContent?.title ?? "Sacred Silence",
                        textAlign: TextAlign.center,
                        style: PremiumTokens.soulStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 8),
                      Text(
                        currentContent?.category?.toUpperCase() ?? "DIVINE WISDOM",
                        style: PremiumTokens.sansStyle(
                          fontSize: 12,
                          color: accentColor,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Waveform
                PremiumUI.aestheticWaveform(isPlaying: isPlaying, color: accentColor),
                
                const SizedBox(height: 40),
                
                // Controls
                _buildControls(audioState, accentColor),
                
                const SizedBox(height: 40),
                
                // Progress
                _buildProgressBar(audioState, accentColor),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    category = category.toLowerCase();
    if (category.contains('shloka')) return PremiumTokens.nebulaBlue;
    if (category.contains('mantra')) return PremiumTokens.saffronGlow;
    if (category.contains('poem')) return PremiumTokens.celestialGlow;
    return PremiumTokens.nebulaBlue;
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: PremiumUI.glassCard(
              padding: const EdgeInsets.all(12),
              borderRadius: 16,
              child: const Icon(Iconsax.arrow_down_1, color: Colors.white, size: 24),
            ),
          ),
          Text(
            "NOW PLAYING",
            style: PremiumTokens.sansStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.white54,
            ),
          ),
          PremiumUI.glassCard(
            padding: const EdgeInsets.all(12),
            borderRadius: 16,
            child: const Icon(Iconsax.more, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(AudioState state, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous/Rewind
          _buildSmallControl(Iconsax.backward_10_seconds, () => ref.read(audioProvider.notifier).skipBackward()),
          
          // Play/Pause
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              if (state.isPlaying) {
                ref.read(audioProvider.notifier).pause();
              } else {
                ref.read(audioProvider.notifier).resume();
              }
            },
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accentColor, accentColor.withOpacity(0.6)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.4),
                    blurRadius: 40,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: state.isLoading 
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                  : Icon(
                      state.isPlaying ? Iconsax.pause : Iconsax.play,
                      color: Colors.white,
                      size: 36,
                    ),
              ),
            ),
          ),
          
          // Next/Forward
          _buildSmallControl(Iconsax.forward_10_seconds, () => ref.read(audioProvider.notifier).skipForward()),
        ],
      ),
    );
  }

  Widget _buildSmallControl(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildProgressBar(AudioState state, Color accentColor) {
    final duration = state.duration;
    final position = state.position;
    
    // Use local drag value if currently dragging, otherwise use state progress
    final progress = _isDragging 
        ? _dragValue 
        : (duration.inMilliseconds > 0 ? position.inMilliseconds / duration.inMilliseconds : 0.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: _CustomGlowingThumbShape(color: Colors.white, glowColor: accentColor),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
              activeTrackColor: accentColor,
              inactiveTrackColor: Colors.white.withOpacity(0.05),
              activeTickMarkColor: Colors.transparent,
              inactiveTickMarkColor: Colors.transparent,
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: (value) {
                setState(() {
                  _isDragging = true;
                  _dragValue = value;
                });
              },
              onChangeEnd: (value) {
                final newPos = Duration(milliseconds: (value * duration.inMilliseconds).toInt());
                ref.read(audioProvider.notifier).seek(newPos);
                setState(() {
                  _isDragging = false;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_isDragging 
                      ? Duration(milliseconds: (_dragValue * duration.inMilliseconds).toInt()) 
                      : position),
                  style: PremiumTokens.sansStyle(
                    fontSize: 10, 
                    color: _isDragging ? Colors.white : Colors.white38,
                    fontWeight: _isDragging ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  _formatDuration(duration),
                  style: PremiumTokens.sansStyle(fontSize: 10, color: Colors.white38),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inMilliseconds < 0) return "00:00";
    String two(int n) => n.toString().padLeft(2, '0');
    final minutes = two(d.inMinutes.remainder(60));
    final seconds = two(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// CUSTOM GLOWING THUMB
/// ═══════════════════════════════════════════════════════════════════════════
class _CustomGlowingThumbShape extends SliderComponentShape {
  final Color color;
  final Color glowColor;
  final double thumbRadius;

  _CustomGlowingThumbShape({
    required this.color,
    required this.glowColor,
    this.thumbRadius = 6.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.fromRadius(thumbRadius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Outer glow
    final Paint glowPaint = Paint()
      ..color = glowColor.withOpacity(0.5 * activationAnimation.value)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, thumbRadius * 2.5, glowPaint);

    // Inner glow / border
    final Paint borderPaint = Paint()
      ..color = glowColor.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, thumbRadius + 1, borderPaint);

    // Main thumb
    final Paint mainPaint = Paint()..color = color;
    canvas.drawCircle(center, thumbRadius, mainPaint);
  }
}
