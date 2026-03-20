import 'package:flutter/material.dart'; // Sanctuary UI Base
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/design_system.dart';
import '../core/auth_provider.dart';
import '../core/stats_provider.dart';

class SpiritualLevelingScreen extends ConsumerWidget {
  const SpiritualLevelingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final statsAsync = ref.watch(userStatsProvider);
    final level = statsAsync.value?.level ?? 1;
    final totalJapCount = statsAsync.value?.totalJapCount ?? 0;
    
    // Derived stats for the "Orbit" feel
    final japHours = (totalJapCount * 2 / 3600).toStringAsFixed(1); // Assuming 2 seconds per Jap
    final malaStreaks = (totalJapCount / 108).floor();

    return Scaffold(
      backgroundColor: const Color(0xFF050510), // Ultra-deep void
      body: Stack(
        children: [
          // Celestial Constellation Background
          Positioned.fill(child: PremiumUI.bokehBackground()),
          Positioned.fill(child: PremiumUI.mandalaOverlay(opacity: 0.05)),
          
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(context),
              SliverToBoxAdapter(child: _buildOrbitConstellation(user, level)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildAdvancedStatsRow(japHours, malaStreaks),
                      const SizedBox(height: 24),
                      _buildSoulBadges(),
                      const SizedBox(height: 32),
                      _buildResonancePath(),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: PremiumTokens.nebulaBlue, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "JOURNEY STATS",
        style: GoogleFonts.spectral(
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      pinned: true,
      centerTitle: true,
    );
  }

  Widget _buildOrbitConstellation(User? user, int level) {
    return Container(
      height: 380,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated Orbit Rings
          _buildOrbitRing(200, 200, 2000),
          _buildOrbitRing(280, 280, 3500),
          _buildOrbitRing(340, 340, 5000),

          // Constellation Points (Simulated)
          _buildConstellationPoint(160, 100, "Awakened"),
          _buildConstellationPoint(280, 140, "7 Day Streak"),
          _buildConstellationPoint(220, 280, "108 Mantras"),

          // Center Level Node
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "CURRENT ORBIT",
                style: GoogleFonts.spectral(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: PremiumTokens.nebulaBlue.withValues(alpha: 0.6),
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Level $level",
                style: GoogleFonts.spectral(
                  fontSize: 48,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 20),
              // Profile Aura
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: PremiumTokens.nebulaBlue.withValues(alpha: 0.3), width: 1),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: CachedNetworkImageProvider(user?.photoURL ?? 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=400&q=80'),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .shimmer(duration: 2.seconds, color: PremiumTokens.nebulaBlue.withValues(alpha: 0.2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrbitRing(double width, double height, int durationMs) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
      ),
    ).animate(onPlay: (c) => c.repeat())
     .rotate(duration: durationMs.ms);
  }

  Widget _buildConstellationPoint(double top, double left, String label) {
    return Positioned(
      top: top,
      left: left,
      child: Column(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.white.withValues(alpha: 0.8), blurRadius: 10, spreadRadius: 1),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.spectral(fontSize: 8, color: Colors.white24, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildAdvancedStatsRow(String japHours, int malaStreaks) {
    return Row(
      children: [
        Expanded(
          child: PremiumUI.glassCard(
            padding: const EdgeInsets.all(20),
            borderRadius: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Iconsax.timer, color: PremiumTokens.nebulaBlue, size: 24),
                const SizedBox(height: 12),
                Text(
                  "Total Jap Hours",
                  style: GoogleFonts.spectral(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                const SizedBox(height: 4),
                Text(
                  "$japHours hrs",
                  style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w300, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: PremiumUI.glassCard(
            padding: const EdgeInsets.all(20),
            borderRadius: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Iconsax.hierarchy, color: PremiumTokens.nebulaBlue, size: 24),
                const SizedBox(height: 12),
                Text(
                  "Mala Streaks",
                  style: GoogleFonts.spectral(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                const SizedBox(height: 4),
                Text(
                  "$malaStreaks days",
                  style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w300, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSoulBadges() {
    final badges = [
      {"icon": Icons.brightness_7, "name": "Void Seeker"},
      {"icon": Icons.dark_mode, "name": "Eternal Peace"},
      {"icon": Icons.self_improvement, "name": "Stillness Master"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("SOUL BADGES"),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: badges.map((badge) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: PremiumUI.glassCard(
                padding: const EdgeInsets.symmetric(vertical: 16),
                borderRadius: 20,
                child: Column(
                  children: [
                    Icon(badge['icon'] as IconData, color: PremiumTokens.nebulaBlue, size: 20),
                    const SizedBox(height: 8),
                    Text(
                      badge['name'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Colors.white24,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.05))),
      ],
    );
  }

  Widget _buildResonancePath() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("RESONANCE PATH"),
        const SizedBox(height: 16),
        PremiumUI.glassCard(
          padding: const EdgeInsets.all(24),
          borderRadius: 24,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Weekly Stillness",
                    style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white70),
                  ),
                  const Text(
                    "Last 7 Days",
                    style: TextStyle(fontSize: 10, color: PremiumTokens.nebulaBlue, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [0.4, 0.6, 0.3, 0.85, 0.5, 0.95, 0.7].map((h) => _buildBar(h)).toList(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ["M", "T", "W", "T", "F", "S", "S"].map((d) => Text(d, style: const TextStyle(fontSize: 10, color: Colors.white24))).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBar(double heightFactor) {
    return Container(
      width: 12,
      height: 80 * heightFactor,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [PremiumTokens.nebulaBlue.withValues(alpha: 0.1), PremiumTokens.nebulaBlue.withValues(alpha: 0.6)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
