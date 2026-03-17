import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/design_system.dart';
import '../core/providers.dart';
import 'package:flutter/services.dart';

class NaamJapScreen extends ConsumerStatefulWidget {
  const NaamJapScreen({super.key});

  @override
  ConsumerState<NaamJapScreen> createState() => _NaamJapScreenState();
}

class _NaamJapScreenState extends ConsumerState<NaamJapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
        vsync: this, duration: const Duration(seconds: 30))
      ..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocusMode = ref.watch(focusModeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Core background handled by Master Layer
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: 0,
            right: 0,
            child: Center(child: PremiumUI.nebulaGlow(size: isFocusMode ? 550 : 450, opacity: isFocusMode ? 1.0 : 0.8)),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopNav(context, isFocusMode),
                const Spacer(),
                _buildCentralDisk(isFocusMode),
                const Spacer(),
                PremiumUI.focusContainer(
                  isFocusMode: isFocusMode,
                  child: Column(
                    children: [
                      _buildTrackInfo(),
                      _buildPlaybackControls(),
                      _buildAestheticWaveform(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNav(BuildContext context, bool isFocusMode) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: PremiumUI.animatedIcon(
              folder: 'Chevron-left',
              fileName: 'chevron-left.json',
              size: 32,
              color: Colors.white70,
            ),
          ),
          PremiumUI.focusContainer(
            isFocusMode: isFocusMode,
            child: Text(
              "SANT-VAANI",
              style: PremiumTokens.sansStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
                letterSpacing: 4,
                color: Colors.white38,
              ),
            ),
          ),
          // Focus Toggle
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              ref.read(focusModeProvider.notifier).state = !isFocusMode;
            },
            child: PremiumUI.animatedIcon(
              folder: 'Visibility V2',
              fileName: 'visibilityV2.json',
              size: 28,
              color: isFocusMode ? PremiumTokens.nebulaBlue : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCentralDisk(bool isFocusMode) {
    return RepaintBoundary(
      child: PremiumUI.auraBreathing(
        beginScale: 1.0,
        endScale: isFocusMode ? 1.1 : 1.05,
        child: RotationTransition(
          turns: _rotationController,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Glow/Progress Ring Simulation
              Container(
                width: isFocusMode ? 320 : 280,
                height: isFocusMode ? 320 : 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: PremiumTokens.nebulaBlue.withValues(alpha: isFocusMode ? 0.4 : 0.2),
                    width: 1,
                  ),
                ),
              ),
              // "Starlight Ring"
              Container(
                width: isFocusMode ? 300 : 260,
                height: isFocusMode ? 300 : 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.transparent,
                    width: 2,
                  ),
                ),
                child: CustomPaint(
                  painter: _StarlightRingPainter(color: PremiumTokens.nebulaBlue),
                ),
              ),
              // Glass Disk
              PremiumUI.voidGlassCard(
                blur: isFocusMode ? 30 : 20,
                borderRadius: isFocusMode ? 140 : 110,
                padding: EdgeInsets.zero,
                child: Container(
                  width: isFocusMode ? 260 : 220,
                  height: isFocusMode ? 260 : 220,
                  alignment: Alignment.center,
                  child: Text(
                    'ॐ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isFocusMode ? 100 : 80,
                      shadows: [
                        Shadow(color: Colors.white54, blurRadius: isFocusMode ? 40 : 20),
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

  Widget _buildTrackInfo() {
    final count = ref.watch(naamJapStateProvider);
    return Column(
      children: [
        Text(
          "Mahamrityunjaya Mantra",
          style: PremiumTokens.soulStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "COUNT: $count",
          style: PremiumTokens.sansStyle(
            fontSize: 16,
            color: PremiumTokens.nebulaBlue,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPlaybackControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          // Custom Progress Bar
          Column(
            children: [
              Stack(
                children: [
                  Container(height: 1, color: Colors.white10),
                  Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width * 0.5,
                    decoration: BoxDecoration(
                      color: PremiumTokens.nebulaBlue,
                      boxShadow: [
                        BoxShadow(
                          color: PremiumTokens.nebulaBlue.withValues(alpha: 0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("05:30", style: PremiumTokens.sansStyle(fontSize: 10, color: Colors.white24)),
                  Text("08:45", style: PremiumTokens.sansStyle(fontSize: 10, color: Colors.white24)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.shuffle, color: Colors.white24, size: 24),
              PremiumUI.customIcon(
                fileName: 'iconsax-arrow-left-01-fslvef72-.svg',
                color: Colors.white,
                size: 40,
              ),
              GestureDetector(
                onTap: () {
                  ref.read(naamJapStateProvider.notifier).increment();
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: PremiumTokens.nebulaGradient,
                    boxShadow: [
                      BoxShadow(
                        color: PremiumTokens.nebulaBlue.withValues(alpha: 0.4),
                        blurRadius: 25,
                      ),
                    ],
                  ),
                  child: PremiumUI.customIcon(
                    fileName: 'iconsax-musical-note-ai-dpa2ppnn-.svg',
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
              PremiumUI.customIcon(
                fileName: 'iconsax-export-arrow-01-gkvet824-.svg', // Using an export arrow as next for vibe
                color: Colors.white,
                size: 40,
              ),
              const Icon(Icons.repeat, color: Colors.white24, size: 24),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAestheticWaveform() {
    return Opacity(
      opacity: 0.3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(20, (index) {
          final double h = (index % 5 + 1) * 10.0 + (index % 3) * 5.0;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 2,
            height: index == 10 ? 60 : h,
            decoration: BoxDecoration(
              color: index == 10 ? PremiumTokens.nebulaBlue : PremiumTokens.nebulaBlue.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          );
        }),
      ),
    );
  }
}

class _StarlightRingPainter extends CustomPainter {
  final Color color;
  _StarlightRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final rect = Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2);
    canvas.drawArc(rect, 0.4, 1.5, false, paint);
    canvas.drawArc(rect, 3.5, 1.2, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
