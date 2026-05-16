import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../core/design_system.dart';
import '../core/spirituality_provider.dart';
import '../models/daily_gyaan.dart';

class DailyGyaanScreen extends ConsumerWidget {
  const DailyGyaanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gyaanAsync = ref.watch(allGyaanProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(child: PremiumUI.masterBackground(index: 2, context: context)), // Deeper cosmic vibe
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
                          child: Icon(Iconsax.arrow_left_2,
                              color: PremiumTokens.textPrimary, size: 20),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'ECHOES OF ETERNITY',
                        style: PremiumTokens.sansStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4,
                          color: PremiumTokens.textPrimary,
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
                        color: PremiumTokens.textMuted,
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
                          style: TextStyle(color: PremiumTokens.textMuted)),
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
                Icon(Iconsax.book, color: PremiumTokens.textPrimary, size: 40),
                const SizedBox(height: 16),
                Text(
                  'The silence holds no wisdom for today.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spectral(
                    fontSize: 16,
                    color: PremiumTokens.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: PremiumTokens.nebulaBlue.withValues(alpha: 0.1),
                blurRadius: 40,
                spreadRadius: -10,
              )
            ],
          ),
          child: PremiumUI.relicCard(
            padding: const EdgeInsets.all(32),
            borderRadius: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "WISDOM OF THE DAY",
                      style: PremiumTokens.sansStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        color: PremiumTokens.textSecondary,
                      ),
                    ),
                    _difficultyBadge(gyaan.difficulty),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  gyaan.title,
                  style: GoogleFonts.spectral(
                    fontSize: 26,
                    color: PremiumTokens.textPrimary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  gyaan.content,
                  style: GoogleFonts.spectral(
                    fontSize: 18,
                    color: PremiumTokens.textPrimary.withValues(alpha: 0.75),
                    height: 1.7,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: PremiumUI.etherealButton(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                    },
                    child: Text(
                      'REFLECT ON WISDOM',
                      style: PremiumTokens.sansStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
                        color: PremiumTokens.surfaceMain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.05, curve: Curves.easeOutCubic);
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
            Icon(Iconsax.book, color: PremiumTokens.borderSubtle, size: 64),
            const SizedBox(height: 16),
            Text(
              'THE VOID IS SILENT',
              style: PremiumTokens.sansStyle(
                  color: PremiumTokens.textMuted, 
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              borderRadius: 16,
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: PremiumTokens.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: PremiumTokens.borderSubtle),
                    ),
                    child: Center(
                        child: Icon(Iconsax.book_1, color: PremiumTokens.textPrimary, size: 20)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gyaan.title,
                          style: PremiumTokens.sansStyle(
                            color: PremiumTokens.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          gyaan.content,
                          style: PremiumTokens.sansStyle(
                            color: PremiumTokens.textPrimary.withValues(alpha: 0.4),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _difficultyBadge(gyaan.difficulty),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (index * 50).ms, duration: 400.ms).slideX(begin: 0.05),
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
        color: (colors[difficulty] ?? PremiumTokens.textPrimary).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        labels[difficulty] ?? '',
        style: PremiumTokens.sansStyle(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
          color: colors[difficulty] == Colors.greenAccent ? PremiumTokens.accentSilver : (colors[difficulty] ?? PremiumTokens.textPrimary),
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
            PremiumTokens.sheetBgTop,
            PremiumTokens.sheetBgBottom,
            ],
          ),
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border.all(color: PremiumTokens.borderSubtle),
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
                    color: PremiumTokens.textHint,
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
                  color: PremiumTokens.textPrimary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                gyaan.content,
                style: GoogleFonts.spectral(
                  fontSize: 17,
                  color: PremiumTokens.textSecondary,
                  height: 1.7,
                ),
              ),
              if (gyaan.category != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: PremiumTokens.borderSubtle,
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
