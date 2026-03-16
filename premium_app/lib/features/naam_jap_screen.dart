import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/design_system.dart';
import '../core/providers.dart';
import '../widgets/animated_effects.dart';

class NaamJapScreen extends ConsumerStatefulWidget {
  const NaamJapScreen({super.key});

  @override
  ConsumerState<NaamJapScreen> createState() => _NaamJapScreenState();
}

class _NaamJapScreenState extends ConsumerState<NaamJapScreen>
    with SingleTickerProviderStateMixin {
  bool _canTap = true;
  late AnimationController _pulseController;
  static const int _cooldownMs = 300;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!_canTap) return;
    _pulseController.forward().then((_) => _pulseController.reverse());
    HapticFeedback.lightImpact();
    ref.read(naamJapCounterProvider.notifier).state++;
    setState(() => _canTap = false);
    Future.delayed(const Duration(milliseconds: _cooldownMs), () {
      if (mounted) setState(() => _canTap = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(naamJapCounterProvider);
    final malaCount = count ~/ 108;
    final currentInMala = count % 108;
    final progress = currentInMala / 108;

    return Scaffold(
      backgroundColor: PremiumTokens.charcoal,
      body: GestureDetector(
        onTap: _onTap,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            const Positioned.fill(child: AnimatedSacredBackground()),
            
            // Decorative elements
            Positioned(
              bottom: -150,
              left: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PremiumTokens.saffronGlow.withOpacity(0.03),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      // Header
                      Row(
                        children: [
                          PremiumUI.glassCard(
                            padding: const EdgeInsets.all(12),
                            child: const Icon(Iconsax.heart, color: PremiumTokens.saffronGlow, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'नाम जप',
                                  style: SacredStyles.devanagariMain.copyWith(
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Tap anywhere to chant',
                                  style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          if (count > 0)
                            IconButton(
                              icon: const Icon(Iconsax.refresh, color: Colors.white24),
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                ref.read(naamJapCounterProvider.notifier).state = 0;
                              },
                            ),
                        ],
                      ),

                      const SizedBox(height: 48),

                      // Stat Cards
                      Row(
                        children: [
                          Expanded(
                            child: PremiumUI.glassCard(
                              child: Column(
                                children: [
                                  Text(
                                    '$malaCount',
                                    style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: PremiumTokens.saffronGlow),
                                  ),
                                  const Text('MALAS', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: PremiumUI.glassCard(
                              child: Column(
                                children: [
                                  Text(
                                    '$currentInMala',
                                    style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const Text('CURRENT', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 80),

                      // Main Sacred Button
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final scale = 1.0 - (_pulseController.value * 0.1);
                          return Transform.scale(scale: scale, child: child);
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 240,
                              height: 240,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 4,
                                backgroundColor: Colors.white12,
                                valueColor: const AlwaysStoppedAnimation(PremiumTokens.saffronGlow),
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Container(
                              width: 190,
                              height: 190,
                              decoration: BoxDecoration(
                                gradient: PremiumTokens.saffronPremiumGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: PremiumTokens.saffronGlow.withOpacity(0.3),
                                    blurRadius: 40,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'ॐ',
                                  style: TextStyle(fontSize: 84, color: Colors.white, fontWeight: FontWeight.normal),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Total counter
                      PremiumUI.glassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        child: Column(
                          children: [
                            const Text('TOTAL CHANTS', style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2)),
                            const SizedBox(height: 8),
                            Text(
                              '$count',
                              style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
