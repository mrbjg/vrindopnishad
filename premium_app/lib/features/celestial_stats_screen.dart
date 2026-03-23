import 'dart:math' as math;
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
import '../models/user_stats.dart';

class CelestialStatsScreen extends ConsumerStatefulWidget {
  const CelestialStatsScreen({super.key});

  @override
  ConsumerState<CelestialStatsScreen> createState() => _CelestialStatsScreenState();
}

class _CelestialStatsScreenState extends ConsumerState<CelestialStatsScreen> with TickerProviderStateMixin {
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
    final user = ref.watch(authStateProvider).value;
    final statsAsync = ref.watch(userStatsProvider);
    final historyAsync = ref.watch(readingHistoryProvider);
    
    final stats = statsAsync.value;
    final level = stats?.level ?? 1;
    
    // Core metrics powered by UserStats
    final japHours = ((stats?.totalReadingMinutes ?? 0) / 60.0).toStringAsFixed(1);
    final malaStreaks = stats?.streakCount ?? 0;

    return Scaffold(
      backgroundColor: PremiumTokens.voidBlack,
      body: Stack(
        children: [
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
                      _buildSoulBadges(level),
                      const SizedBox(height: 32),
                      _buildResonancePath(historyAsync.value ?? []),
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
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
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
          // HIGH PERFORMANCE PAINTED ORBITS
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(340, 340),
                  painter: SacredOrbitPainter(
                    animationValue: _rotationController.value,
                    orbits: [100.0, 140.0, 170.0],
                    points: [
                      ConstellationPoint(orbitIndex: 0, initialAngle: 0.5, label: "Awakened", speed: 1.0),
                      ConstellationPoint(orbitIndex: 1, initialAngle: 2.1, label: "7 Day Streak", speed: -0.7),
                      ConstellationPoint(orbitIndex: 2, initialAngle: 4.5, label: "128 Mantras", speed: 0.5),
                    ],
                  ),
                );
              },
            ),
          ),

          // Center Level Node (Static text to prevent unnecesary rebuilds)
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

  Widget _buildAdvancedStatsRow(String japHours, int malaStreaks) {
    return Row(
      children: [
        Expanded(
          child: PremiumUI.etherealCard(
            padding: const EdgeInsets.all(20),
            borderRadius: 24,
            glowColor: PremiumTokens.nebulaBlue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Iconsax.timer, color: PremiumTokens.nebulaBlue, size: 24),
                const SizedBox(height: 12),
                Text(
                  "TOTAL JAP HOURS",
                  style: GoogleFonts.spectral(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                ),
                const SizedBox(height: 4),
                Text(
                  "$japHours hrs",
                  style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w300, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: PremiumUI.etherealCard(
            padding: const EdgeInsets.all(20),
            borderRadius: 24,
            glowColor: PremiumTokens.celestialGlow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Iconsax.hierarchy, color: PremiumTokens.celestialGlow, size: 24),
                const SizedBox(height: 12),
                Text(
                  "MALA STREAKS",
                  style: GoogleFonts.spectral(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                ),
                const SizedBox(height: 4),
                Text(
                  "$malaStreaks days",
                  style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w300, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSoulBadges(int level) {
    final badges = [
      {"icon": Icons.brightness_7, "name": "Void Seeker", "color": PremiumTokens.nebulaBlue, "minLevel": 1},
      {"icon": Icons.dark_mode, "name": "Eternal Peace", "color": PremiumTokens.celestialGlow, "minLevel": 5},
      {"icon": Icons.self_improvement, "name": "Stillness Master", "color": Colors.tealAccent, "minLevel": 10},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("SOUL BADGES"),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: badges.map((badge) {
            final isUnlocked = level >= (badge['minLevel'] as int);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: PremiumUI.etherealCard(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  borderRadius: 20,
                  glowColor: isUnlocked 
                      ? (badge['color'] as Color).withValues(alpha: 0.2)
                      : Colors.transparent,
                  child: Opacity(
                    opacity: isUnlocked ? 1.0 : 0.2,
                    child: Column(
                      children: [
                        Icon(badge['icon'] as IconData, color: badge['color'] as Color, size: 20),
                        const SizedBox(height: 8),
                        Text(
                          badge['name'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
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

  Widget _buildResonancePath(List<ReadingHistoryItem> history) {
    // Generate last 7 days
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return DateTime(date.year, date.month, date.day);
    });

    // Count shlokas per day
    final counts = <DateTime, int>{};
    for (var date in last7Days) {
      counts[date] = 0;
    }

    for (var item in history) {
      final date = DateTime(item.readAt.year, item.readAt.month, item.readAt.day);
      if (counts.containsKey(date)) {
        counts[date] = (counts[date] ?? 0) + 1;
      }
    }

    // Days labels (Last char of weekday)
    final dayLabels = ["M", "T", "W", "T", "F", "S", "S"];
    // Rotate labels based on current day
    final rotatedLabels = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i)).weekday;
      return dayLabels[day - 1];
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("RESONANCE PATH"),
        const SizedBox(height: 16),
        PremiumUI.etherealCard(
          padding: const EdgeInsets.all(24),
          borderRadius: 24,
          glowColor: PremiumTokens.nebulaBlue,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Weekly Stillness",
                    style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  ),
                  const Text(
                     "Last 7 Days",
                    style: TextStyle(fontSize: 10, color: PremiumTokens.nebulaBlue, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: last7Days.map((date) {
                    final count = counts[date] ?? 0;
                    // Normalize: 0 to 5 shlokas maps to 0.1 to 1.0 height
                    final factor = (count / 5.0).clamp(0.1, 1.0);
                    return _buildBar(factor);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: rotatedLabels.map((d) => Text(
                  d, 
                  style: GoogleFonts.manrope(fontSize: 10, color: Colors.white24, fontWeight: FontWeight.bold)
                )).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBar(double heightFactor) {
    return Container(
      width: 14,
      height: 100 * heightFactor,
      decoration: BoxDecoration(
        color: PremiumTokens.nebulaBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  PremiumTokens.nebulaBlue.withValues(alpha: 0.1), 
                  PremiumTokens.nebulaBlue.withValues(alpha: 0.6)
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // Glow tip
          Positioned(
            top: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: PremiumTokens.nebulaBlue.withValues(alpha: 0.8),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SacredOrbitPainter extends CustomPainter {
  final double animationValue;
  final List<double> orbits;
  final List<ConstellationPoint> points;

  SacredOrbitPainter({
    required this.animationValue,
    required this.orbits,
    required this.points,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.05);

    // Draw Orbits
    for (var radius in orbits) {
      canvas.drawCircle(center, radius, orbitPaint);
    }

    // Draw Animated Points
    for (var point in points) {
      final radius = orbits[point.orbitIndex];
      final angle = point.initialAngle + (animationValue * 2 * 3.14159 * point.speed);
      
      // Fixed trigonometric calculation
      final x = center.dx + radius * (animationValue * 0 == 0 ? (math.cos(angle)) : 0);
      final y = center.dy + radius * (animationValue * 0 == 0 ? (math.sin(angle)) : 0);
      final pos = Offset(x, y);

      // Point Glow
      final glowPaint = Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(pos, 5, glowPaint);
      
      final corePaint = Paint()..color = Colors.white;
      canvas.drawCircle(pos, 2, corePaint);

      // Label
      final textPainter = TextPainter(
        text: TextSpan(
          text: point.label.toUpperCase(),
          style: GoogleFonts.spectral(
            fontSize: 7, 
            color: Colors.white38, 
            fontWeight: FontWeight.bold, 
            letterSpacing: 1
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      
      textPainter.paint(
        canvas, 
        Offset(pos.dx - textPainter.width / 2, pos.dy + 10)
      );
    }
  }


  @override
  bool shouldRepaint(covariant SacredOrbitPainter oldDelegate) => true;
}

class ConstellationPoint {
  final int orbitIndex;
  final double initialAngle;
  final String label;
  final double speed;

  ConstellationPoint({
    required this.orbitIndex,
    required this.initialAngle,
    required this.label,
    required this.speed,
  });
}
