import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../core/design_system.dart';
import '../core/spirituality_provider.dart';
import '../models/daily_gyaan.dart';
import '../services/gamification_service.dart';

class DailyGyaanScreen extends ConsumerWidget {
  const DailyGyaanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gyaanAsync = ref.watch(allGyaanProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(child: PremiumUI.masterBackground(index: 1)),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: PremiumUI.glassCard(
                          padding: const EdgeInsets.all(10),
                          borderRadius: 14,
                          child: const Icon(Iconsax.arrow_left_2,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'ECHOES OF ETERNITY',
                        style: PremiumTokens.sansStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4,
                          color: PremiumTokens.celestialSilver,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),

                // Today's featured gyaan
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildTodayGyaan(context, ref),
                ),

                const SizedBox(height: 20),

                // Browse all gyaan list
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'ALL WISDOM',
                      style: PremiumTokens.sansStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: gyaanAsync.when(
                    data: (gyaanList) => _buildGyaanList(context, gyaanList),
                    loading: () => const Center(
                        child: CircularProgressIndicator(
                            color: PremiumTokens.nebulaBlue)),
                    error: (e, _) => Center(
                      child: Text('Error: $e',
                          style: const TextStyle(color: Colors.white54)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayGyaan(BuildContext context, WidgetRef ref) {
    final todayGyaan = ref.watch(dailyGyaanProvider);

    return todayGyaan.when(
      data: (gyaan) {
        if (gyaan == null) {
          return PremiumUI.relicCard(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            borderRadius: 24, // Matches the Echoes cards more closely
            child: Column(
              children: [
                const Icon(Iconsax.book, color: PremiumTokens.celestialSilver, size: 40),
                const SizedBox(height: 16),
                Text(
                  'The silence holds no wisdom for today.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spectral(
                    fontSize: 16,
                    color: PremiumTokens.celestialSilver.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return PremiumUI.glassCard(
          padding: const EdgeInsets.all(28),
          borderRadius: 0, // Sharp edges as per design system
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "ECHOES OF ETERNITY",
                    style: PremiumTokens.sansStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4,
                      color: PremiumTokens.celestialSilver,
                    ),
                  ),
                  const Spacer(),
                  _difficultyBadge(gyaan.difficulty),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                gyaan.title,
                style: GoogleFonts.spectral(
                  fontSize: 24,
                  color: PremiumTokens.celestialSilver,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                gyaan.content,
                style: GoogleFonts.spectral(
                  fontSize: 17,
                  color: PremiumTokens.celestialSilver.withValues(alpha: 0.8),
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 20),
              // Complete button for XP
              SizedBox(
                width: double.infinity,
                child: PremiumUI.etherealButton(
                  onTap: () async {
                    HapticFeedback.heavyImpact();
                    await ref.read(gamificationServiceProvider).awardXP(
                      context,
                      50,
                      'Gyaan of the Day: ${gyaan.title}',
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'REFLECT ON WISDOM (+50 XP)',
                        style: PremiumTokens.sansStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: PremiumTokens.voidIndigo,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1);
      },
      loading: () => const SizedBox(
          height: 200,
          child: Center(
              child: CircularProgressIndicator(color: PremiumTokens.nebulaBlue))),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildGyaanList(BuildContext context, List<DailyGyaan> gyaanList) {
    if (gyaanList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.book, color: Colors.white10, size: 64),
            const SizedBox(height: 16),
            Text(
              'THE VOID IS SILENT',
              style: PremiumTokens.sansStyle(
                  color: PremiumTokens.celestialSilver.withValues(alpha: 0.2), 
                  fontSize: 12,
                  letterSpacing: 3,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: gyaanList.length,
      itemBuilder: (context, index) {
        final gyaan = gyaanList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showGyaanDetail(context, gyaan);
            },
            child: PremiumUI.relicCard(
              padding: const EdgeInsets.all(20),
              borderRadius: 4,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: PremiumTokens.voidIndigo.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: PremiumTokens.celestialSilver.withValues(alpha: 0.1)),
                    ),
                    child: Center(
                        child: Icon(Iconsax.book, color: PremiumTokens.celestialSilver.withValues(alpha: 0.5), size: 18)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gyaan.title,
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          gyaan.content,
                          style: GoogleFonts.manrope(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _difficultyBadge(gyaan.difficulty),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (index * 100).ms, duration: 400.ms),
        );
      },
    );
  }

  Widget _difficultyBadge(int difficulty) {
    final colors = {
      1: Colors.greenAccent,
      2: Colors.amberAccent,
      3: Colors.redAccent,
    };
    final labels = {1: 'BASIC', 2: 'MIDS', 3: 'DEEP'};

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (colors[difficulty] ?? Colors.white).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        labels[difficulty] ?? '',
        style: PremiumTokens.sansStyle(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
          color: colors[difficulty] == Colors.greenAccent ? PremiumTokens.celestialSilver : (colors[difficulty] ?? Colors.white),
        ),
      ),
    );
  }

  void _showGyaanDetail(BuildContext context, DailyGyaan gyaan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              PremiumTokens.voidIndigo.withValues(alpha: 0.98),
              PremiumTokens.voidBlack,
            ],
          ),
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _difficultyBadge(gyaan.difficulty),
              const SizedBox(height: 16),
              Text(
                gyaan.title,
                style: GoogleFonts.spectral(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                gyaan.content,
                style: GoogleFonts.spectral(
                  fontSize: 17,
                  color: Colors.white70,
                  height: 1.7,
                ),
              ),
              if (gyaan.category != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    gyaan.category!.toUpperCase(),
                    style: PremiumTokens.sansStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: PremiumTokens.nebulaBlue,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
