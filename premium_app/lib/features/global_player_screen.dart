import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/audio_provider.dart';
import '../core/design_system.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../core/favorites_provider.dart';

class GlobalPlayerScreen extends ConsumerStatefulWidget {
  const GlobalPlayerScreen({super.key});

  @override
  ConsumerState<GlobalPlayerScreen> createState() => _GlobalPlayerScreenState();
}

class _GlobalPlayerScreenState extends ConsumerState<GlobalPlayerScreen> with TickerProviderStateMixin {
  late AnimationController _diskController;
  bool _isDragging = false;
  double _dragValue = 0.0;
  
  // Sacred Menu Pointer Tracking
  final _pointerPosition = ValueNotifier<Offset?>(null);
  final _menuKey = GlobalKey<SacredActionMenuState>();

  @override
  void initState() {
    super.initState();
    _diskController = AnimationController(vsync: this, duration: 20.seconds);
  }

  @override
  void dispose() {
    _diskController.dispose();
    _pointerPosition.dispose();
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
      backgroundColor: PremiumTokens.voidPure,
      body: Stack(
        children: [
          // Background
          Positioned.fill(child: PremiumUI.masterBackground(index: 2)),
          
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenHeight = constraints.maxHeight;
                final bool isSmallScreen = screenHeight < 700;
                
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minHeight: screenHeight),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildHeader(context),
                        
                        // Divine Disk
                        Center(
                          child: RotationTransition(
                            turns: _diskController,
                            child: PremiumUI.nebulaDisk(
                              size: isSmallScreen 
                                ? MediaQuery.of(context).size.width * 0.5 
                                : MediaQuery.of(context).size.width * 0.7,
                              isPlaying: isPlaying,
                              accentColor: accentColor,
                              child: RepaintBoundary(
                                child: SvgPicture.asset(
                                  'assets/shriJiMukut.svg',
                                  width: isSmallScreen ? 70 : 100,
                                  height: isSmallScreen ? 70 : 100,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white, 
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
                        
                        // Track Info
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          child: Column(
                            children: [
                              Text(
                                currentContent?.title ?? "Sacred Silence",
                                textAlign: TextAlign.center,
                                style: PremiumTokens.soulStyle(
                                  fontSize: isSmallScreen ? 22 : 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentContent?.category.toUpperCase() ?? "DIVINE WISDOM",
                                style: PremiumTokens.sansStyle(
                                  fontSize: 10,
                                  color: PremiumTokens.celestialSilver.withValues(alpha: 0.4),
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Waveform
                        PremiumUI.aestheticWaveform(isPlaying: isPlaying, color: accentColor),
                        
                        const SizedBox(height: 20),
                        
                        // Controls
                        _buildControls(audioState, accentColor),
                        
                        const SizedBox(height: 20),
                        
                        // Progress
                        _buildProgressBar(audioState, accentColor),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    return PremiumTokens.celestialSilver;
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
            child: PremiumUI.voidCard(
              padding: const EdgeInsets.all(12),
              borderRadius: 16,
              accentColor: PremiumTokens.celestialSilver.withValues(alpha: 0.1),
              child: const Icon(Iconsax.arrow_down_1, color: PremiumTokens.celestialSilver, size: 24),
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
          GestureDetector(
            onLongPressStart: (details) {
              HapticFeedback.heavyImpact();
              _pointerPosition.value = details.globalPosition;
              
              final content = ref.read(audioProvider).currentContent;
              final isFav = content != null 
                  ? ref.read(favoritesProvider).contains(content.id) 
                  : false;
              
              showSacredMenu(
                context,
                details.globalPosition,
                [
                  SacredMenuItem(
                    icon: Iconsax.share,
                    label: "Share",
                    color: PremiumTokens.celestialSilver,
                    onTap: () {
                      if (content != null) {
                        Share.share("Listen to '${content.title}' on Sant-Vaani: Sacred Wisdom for Modern Life. 🕉️");
                      }
                    },
                  ),
                  SacredMenuItem(
                    icon: isFav ? Iconsax.heart5 : Iconsax.heart,
                    label: isFav ? "Loved" : "Love",
                    color: PremiumTokens.celestialSilver,
                    onTap: () {
                      if (content != null) {
                        ref.read(favoritesProvider.notifier).toggleFavorite(content.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isFav ? "Removed from Favorites" : "Added to Favorites"),
                            backgroundColor: PremiumTokens.voidIndigo,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                  SacredMenuItem(
                    icon: Iconsax.timer_1,
                    label: "Timer",
                    color: PremiumTokens.celestialSilver,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(
                          content: Text("Divine Sleep Timer coming soon! ✨"),
                          backgroundColor: PremiumTokens.voidIndigo,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
                pointerPosition: _pointerPosition,
                key: _menuKey,
              );
            },
            onLongPressMoveUpdate: (details) {
              _pointerPosition.value = details.globalPosition;
            },
            onLongPressEnd: (details) {
              _menuKey.currentState?.handleRelease();
              _pointerPosition.value = null;
            },
            child: PremiumUI.voidCard(
              padding: const EdgeInsets.all(12),
              borderRadius: 16,
              accentColor: PremiumTokens.celestialSilver.withValues(alpha: 0.1),
              child: const Icon(Iconsax.element_4, color: PremiumTokens.celestialSilver, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(AudioState state, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Previous Track
          _buildSmallControl(Iconsax.previous, () => ref.read(audioProvider.notifier).previousTrack()),
          
          // Rewind 10s
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
                color: PremiumTokens.voidIndigo,
                border: Border.all(color: PremiumTokens.celestialSilver.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: PremiumTokens.etherealBlue.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Center(
                child: state.isLoading 
                  ? const CircularProgressIndicator(color: PremiumTokens.celestialSilver, strokeWidth: 2)
                  : Icon(
                      state.isPlaying ? Iconsax.pause : Iconsax.play,
                      color: PremiumTokens.celestialSilver,
                      size: 32,
                    ),
              ),
            ),
          ),
          
          // Forward 10s
          _buildSmallControl(Iconsax.forward_10_seconds, () => ref.read(audioProvider.notifier).skipForward()),

          // Next Track
          _buildSmallControl(Iconsax.next, () => ref.read(audioProvider.notifier).nextTrack()),
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
          color: PremiumTokens.celestialSilver.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(color: PremiumTokens.celestialSilver.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: PremiumTokens.celestialSilver, size: 24),
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
              thumbShape: _CustomGlowingThumbShape(color: PremiumTokens.celestialSilver, glowColor: PremiumTokens.etherealBlue),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
              activeTrackColor: PremiumTokens.celestialSilver,
              inactiveTrackColor: PremiumTokens.celestialSilver.withValues(alpha: 0.05),
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
  }) : thumbRadius = 6.0;


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
      ..color = glowColor.withValues(alpha: 0.5 * activationAnimation.value)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, thumbRadius * 2.5, glowPaint);

    // Inner glow / border
    final Paint borderPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, thumbRadius + 1, borderPaint);

    // Main thumb
    final Paint mainPaint = Paint()..color = color;
    canvas.drawCircle(center, thumbRadius, mainPaint);
  }
}
