import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
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
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumTokens.voidBlack,
      body: Stack(
        children: [
          Positioned.fill(child: PremiumUI.voidBackground()),
          
          SafeArea(
            child: Column(
              children: [
                // Top Navigation Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCircleIconButton(Iconsax.arrow_left_2),
                      Column(
                        children: [
                          Text(
                            'NOW PLAYING',
                            style: GoogleFonts.manrope(
                              color: PremiumTokens.saffronGlow,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3,
                            ),
                          ),
                          Text(
                            'Shrimad Bhagavad Gita',
                            style: GoogleFonts.newsreader(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      _buildCircleIconButton(Iconsax.more_2),
                    ],
                  ),
                ),

                const Spacer(),

                // Central Nebula Disk with Rotation
                RotationTransition(
                  turns: _rotationController,
                  child: PremiumUI.nebulaDisk(
                    size: 280,
                    child: ClipOval(
                      child: PremiumUI.networkImage(
                        url: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBn4KXlGdM09V_vyL6FYniGawEBhjjVTHPtWkncMv7AsR6PnDmJx7em82khx96o3tU2b3i1Xv29wn9YRQoYyoZeajegx50mvb2FhsVMMSfaFhybyyp4s5nWVhvjM-Xy_QSV-yOBYDJ2x9MEKcOFTdGbZgUrn0UE6v0p2K2PQWyKunglhZdM8Zl3m2CwulCpccA2dLrSOn__UtnRnXD-8qj4bbhKvT8rR2TwLW9SujHlkdwDM9eRnU6XwEIsGvxdMY1xt3PWf0sISOE',
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Track Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      Text(
                        'CHAPTER 02, VERSE 20',
                        style: GoogleFonts.manrope(
                          color: PremiumTokens.saffronGlow,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Eternal Soul',
                        style: GoogleFonts.newsreader(
                          color: Colors.white,
                          fontSize: 28,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        'The nature of the self',
                        style: GoogleFonts.manrope(
                          color: Colors.white38,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Playback Controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      // Progress Bar
                      Row(
                        children: [
                          Text('01:24', style: GoogleFonts.manrope(color: Colors.white38, fontSize: 12)),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4,
                                activeTrackColor: PremiumTokens.saffronGlow,
                                inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                                thumbColor: Colors.white,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                overlayColor: PremiumTokens.saffronGlow.withValues(alpha: 0.2),
                              ),
                              child: Slider(value: 0.45, onChanged: (_) {}),
                            ),
                          ),
                          Text('04:52', style: GoogleFonts.manrope(color: Colors.white38, fontSize: 12)),
                        ],
                      ),
                      
                      const SizedBox(height: 32),

                      // Main Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(Iconsax.repeate_one, color: Colors.white38, size: 24),
                          Icon(Iconsax.previous5, color: Colors.white, size: 32),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  blurRadius: 30,
                                ),
                              ],
                            ),
                            child: const Icon(Iconsax.play5, color: PremiumTokens.voidBlack, size: 40),
                          ),
                          Icon(Iconsax.next5, color: Colors.white, size: 32),
                          Icon(Iconsax.shuffle, color: Colors.white38, size: 24),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Bottom Panel Shortcut
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: PremiumUI.voidGlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Iconsax.music_playlist, color: PremiumTokens.saffronGlow, size: 20),
                        const SizedBox(width: 16),
                        Text(
                          'UP NEXT: CHAPTER 02, VERSE 21',
                          style: GoogleFonts.manrope(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Iconsax.arrow_up_2, color: Colors.white24, size: 16),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}
