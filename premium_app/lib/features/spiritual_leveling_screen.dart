import 'package:flutter/material.dart'; // Sanctuary UI Base
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
    final xp = statsAsync.value?.experiencePoints ?? 0;

    return Scaffold(
      backgroundColor: PremiumTokens.charcoal,
      body: Stack(
        children: [
          // Generative Aura Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    PremiumTokens.nebulaBlue.withValues(alpha: 0.2), // primary aura
                    PremiumTokens.celestialGlow.withValues(alpha: 0.1), // celestial aura
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, PremiumTokens.charcoal],
                ),
              ),
            ),
          ),
          
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(context),
              SliverToBoxAdapter(child: _buildAuraDisplay(user, level)),
              SliverToBoxAdapter(child: _buildSoulBadges()),
              SliverToBoxAdapter(child: _buildSacredInsights()),
              SliverToBoxAdapter(child: _buildResonancePath()),
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
        "Sanctuary Profile",
        style: PremiumTokens.sansStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: Icon(Iconsax.setting_2, color: PremiumTokens.nebulaBlue),
          onPressed: () {},
        ),
      ],
      pinned: true,
      centerTitle: true,
    );
  }

  Widget _buildAuraDisplay(User? user, int level) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          // Evolution Aura Sphere
          Container(
            padding: const EdgeInsets.all(8),
            decoration: PremiumTokens.evolvingAura(
              color: PremiumTokens.nebulaBlue,
              intensity: 1.0,
            ),
            child: Container(
              width: 160,
              height: 160,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [PremiumTokens.nebulaBlue, PremiumTokens.celestialGlow, PremiumTokens.voidBlue],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: PremiumTokens.charcoal,
                    image: DecorationImage(
                      image: NetworkImage(user?.photoURL ?? 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=400&q=80'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Void Seeker",
            style: PremiumTokens.displayStyle(fontSize: 32, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: PremiumTokens.nebulaBlue.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: PremiumTokens.nebulaBlue.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, color: PremiumTokens.nebulaBlue, size: 16),
                const SizedBox(width: 8),
                Text(
                  "AURA LEVEL $level",
                  style: PremiumTokens.sansStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              '"Evolving silver-and-indigo energy field reflecting deep stillness."',
              textAlign: TextAlign.center,
              style: PremiumTokens.sansStyle(
                fontSize: 14,
                color: Colors.white54,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoulBadges() {
    final badges = [
      {"icon": Icons.brightness_7, "name": "Void Seeker"},
      {"icon": Icons.dark_mode, "name": "Eternal Peace"},
      {"icon": Icons.self_improvement, "name": "Stillness Master"},
      {"icon": Icons.groups_3, "name": "Sangat Guide"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text(
            "SOUL BADGES",
            style: PremiumTokens.sansStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white38,
              letterSpacing: 2,
            ),
          ),
        ),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: PremiumUI.glassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  borderRadius: 16,
                  child: Row(
                    children: [
                      Icon(badge['icon'] as IconData, color: PremiumTokens.nebulaBlue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        badge['name'] as String,
                        style: PremiumTokens.sansStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSacredInsights() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SACRED INSIGHTS",
            style: PremiumTokens.sansStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white38,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1, // Increased height for children
            children: [
              _buildInsightCard(Iconsax.timer, "1,240", "Stillness"),
              _buildInsightCard(Iconsax.hierarchy, "84", "Sangat"),
              _buildInsightCard(Iconsax.book, "312", "Reflections"),
              _buildInsightCard(Iconsax.heart, "1.2k", "Resonance"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(IconData icon, String value, String label) {
    return PremiumUI.glassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: PremiumTokens.nebulaBlue, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: PremiumTokens.sansStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            label.toUpperCase(),
            style: PremiumTokens.sansStyle(
              fontSize: 9,
              color: Colors.white38,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResonancePath() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: PremiumUI.glassCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 24,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Resonance Path",
                  style: PremiumTokens.sansStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Last 7 Days",
                  style: PremiumTokens.sansStyle(
                    fontSize: 12,
                    color: PremiumTokens.nebulaBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar(0.4),
                  _buildBar(0.6),
                  _buildBar(0.3),
                  _buildBar(0.85, isHighlighted: true),
                  _buildBar(0.5),
                  _buildBar(0.95, isHighlighted: true),
                  _buildBar(0.7),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
                  .map((d) => Text(
                        d,
                        style: PremiumTokens.sansStyle(
                          fontSize: 10,
                          color: Colors.white24,
                          fontWeight: FontWeight.bold,
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(double heightFactor, {bool isHighlighted = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          height: 100 * heightFactor,
          decoration: BoxDecoration(
            color: PremiumTokens.nebulaBlue.withValues(alpha: isHighlighted ? 0.7 : 0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: isHighlighted ? Border.all(color: PremiumTokens.nebulaBlue, width: 1.5) : null,
          ),
        ),
      ),
    );
  }
}
