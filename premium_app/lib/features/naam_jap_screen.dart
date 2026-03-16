import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/design_system.dart';

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Nebula & Starlight Effects
          Positioned.fill(child: PremiumUI.voidBackground()),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: 0,
            right: 0,
            child: Center(child: PremiumUI.nebulaGlow(size: 450, opacity: 0.8)),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopNav(context),
                const Spacer(),
                _buildCentralDisk(),
                const Spacer(),
                _buildTrackInfo(),
                _buildPlaybackControls(),
                _buildAestheticWaveform(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNav(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.expand_more, color: Colors.white70, size: 32),
          Text(
            "SANT-VAANI",
            style: PremiumTokens.sansStyle(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              letterSpacing: 4,
              color: Colors.white38,
            ),
          ),
          const Icon(Icons.more_horiz, color: Colors.white70, size: 32),
        ],
      ),
    );
  }

  Widget _buildCentralDisk() {
    return RotationTransition(
      turns: _rotationController,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Glow/Progress Ring Simulation
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: PremiumTokens.nebulaBlue.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          // "Starlight Ring"
          Container(
            width: 260,
            height: 260,
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
            blur: 20,
            borderRadius: 140,
            padding: EdgeInsets.zero,
            child: Container(
              width: 220,
              height: 220,
              alignment: Alignment.center,
              child: const Text(
                'ॐ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 80,
                  shadows: [
                    Shadow(color: Colors.white54, blurRadius: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackInfo() {
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
          "DIVINE RESONANCE",
          style: PremiumTokens.sansStyle(
            fontSize: 10,
            color: Colors.white38,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 48),
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
                    color: PremiumTokens.nebulaBlue,
                    decoration: BoxDecoration(
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
          const SizedBox(height: 40),
          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.shuffle, color: Colors.white24, size: 24),
              const Icon(Icons.skip_previous, color: Colors.white, size: 40),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.03),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 48),
              ),
              const Icon(Icons.skip_next, color: Colors.white, size: 40),
              const Icon(Icons.repeat, color: Colors.white24, size: 24),
            ],
          ),
          const SizedBox(height: 40),
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
              color: index == 10 ? PremiumTokens.nebulaBlue : Colors.white70,
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
