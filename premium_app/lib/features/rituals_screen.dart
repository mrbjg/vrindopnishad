import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/design_system.dart';
import '../core/rituals_provider.dart';
import '../models/ritual.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../widgets/sacred_ritual_alert.dart';

import '../core/stats_provider.dart';

class RitualsScreen extends ConsumerWidget {
  const RitualsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ritualsAsync = ref.watch(ritualsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background - Premium Constellation Design
          const _ConstellationBackground(),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, ref),
                Expanded(
                  child: ritualsAsync.when(
                    data: (rituals) => _buildRitualsList(context, ref, rituals),
                    loading: () => const Center(child: CircularProgressIndicator(color: PremiumTokens.nebulaBlue)),
                    error: (e, _) => Center(child: Text("Error loading rituals: $e", style: const TextStyle(color: Colors.redAccent))),
                  ),
                ),
              ],
            ),
          ),

          // Floating Add Button
          Positioned(
            bottom: 32,
            right: 24,
            child: GestureDetector(
              onTap: () => _showAddRitualDialog(context, ref),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: PremiumTokens.silverGradient,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: PremiumTokens.voidBlack, size: 32),
              ),
            ).animate().scale(delay: 400.ms, duration: 600.ms, curve: Curves.elasticOut),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          const Icon(Icons.brightness_4_outlined, color: Colors.white60, size: 40),
          const SizedBox(height: 16),
          Text(
            "MY SACRED RITUALS",
            textAlign: TextAlign.center,
            style: GoogleFonts.spectral(
              fontSize: 28,
              fontWeight: FontWeight.w200,
              color: PremiumTokens.silver,
              letterSpacing: 6,
            ),
          ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2),
          const SizedBox(height: 24),
          Container(
            height: 1,
            width: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, PremiumTokens.silver.withValues(alpha: 0.3), Colors.transparent],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildTestTrigger(context, ref),
        ],
      ),
    );
  }

  Widget _buildTestTrigger(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        SacredRitualAlert.show(
          context,
          title: "Celestial Call",
          description: "Begin your morning sequence to greet the sun.",
          ritualTitle: "Surya Namaskar",
          onBegin: () {
            ref.read(userStatsProvider.notifier).recordReading(
              "ritual_surya_namaskar",
              title: "Surya Namaskar",
              category: "Ritual",
            );
            Navigator.pop(context);
          },
          onRemind: () => Navigator.pop(context),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: PremiumTokens.starlightBlue.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, color: PremiumTokens.starlightBlue, size: 14),
            const SizedBox(width: 8),
            Text(
              "TEST CELESTIAL ALERT",
              style: GoogleFonts.manrope(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: PremiumTokens.starlightBlue.withValues(alpha: 0.6),
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRitualsList(BuildContext context, WidgetRef ref, List<Ritual> rituals) {
    final categories = ['Morning', 'Afternoon', 'Evening'];
    
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      children: categories.map((category) {
        final categoryRituals = rituals.where((r) => r.category == category).toList();
        if (categoryRituals.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 32, bottom: 24),
              child: Row(
                children: [
                  Text(
                    category.toUpperCase(),
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: PremiumTokens.starlight.withValues(alpha: 0.6),
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.05), thickness: 1)),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),
            
            ...categoryRituals.map((ritual) => _buildRitualCard(context, ref, ritual)).toList(),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildRitualCard(BuildContext context, WidgetRef ref, Ritual ritual) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(ritual.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) {
          ref.read(ritualsProvider.notifier).removeRitual(ritual.id);
          PremiumUI.showNotification(
            context, 
            "Ritual removed",
            icon: Iconsax.trash,
            color: Colors.redAccent,
          );
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Iconsax.trash, color: Colors.redAccent),
        ),
        child: GestureDetector(
          onLongPress: () {
            HapticFeedback.mediumImpact();
            _showAddRitualDialog(context, ref, ritual: ritual);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: _buildGlassContent(ritual),
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05),
        ),
      ),
    );
  }

  Widget _buildGlassContent(Ritual ritual) {
    const double blurSigma = 8.0;
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ritual.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: ritual.isCompleted ? Colors.white24 : PremiumTokens.silver,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${ritual.time} ${ritual.subtitle != null ? '• ${ritual.subtitle}' : ''}",
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.blueGrey[400]!.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Checkmark indicator logic stays same...
          _buildCheckmark(ritual),
        ],
      ),
    );

    if (AppTheme.lowPerformanceMode) {
      return content;
    }

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
      child: content,
    );
  }

  Widget _buildCheckmark(Ritual ritual) {
    return Consumer(
      builder: (context, ref, child) => GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          final willBeCompleted = !ritual.isCompleted;
          if (willBeCompleted) {
            ref.read(userStatsProvider.notifier).recordReading(
              "ritual_done_${ritual.id}",
              title: "Completed: ${ritual.title}",
              category: "Ritual",
            );
          }
          ref.read(ritualsProvider.notifier).toggleRitual(ritual.id);
        },
        child: AnimatedContainer(
          duration: 300.ms,
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ritual.isCompleted 
                ? PremiumTokens.starlight.withValues(alpha: 0.1) 
                : Colors.transparent,
            border: Border.all(
              color: ritual.isCompleted 
                  ? PremiumTokens.starlight.withValues(alpha: 0.6) 
                  : Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: ritual.isCompleted ? [
              BoxShadow(
                color: PremiumTokens.starlight.withValues(alpha: 0.4),
                blurRadius: AppTheme.lowPerformanceMode ? 5 : 15,
                spreadRadius: 0,
              )
            ] : [],
          ),
          child: ritual.isCompleted 
              ? const Icon(Icons.check, color: PremiumTokens.starlight, size: 18) 
              : null,
        ),
      ),
    );
  }
  void _showAddRitualDialog(BuildContext context, WidgetRef ref, {Ritual? ritual}) {
    final titleController = TextEditingController(text: ritual?.title);
    final timeController = TextEditingController(text: ritual?.time);
    final subtitleController = TextEditingController(text: ritual?.subtitle);
    String category = ritual?.category ?? 'Morning';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => PremiumUI.glassCard(
          optimized: false,
          blur: 24,
          opacity: 0.05,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 40,
            top: 40,
            left: 28,
            right: 28,
          ),
          borderRadius: 40,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                ritual == null ? "ADD NEW RITUAL" : "EDIT RITUAL",
                style: GoogleFonts.spectral(
                  fontSize: 22, 
                  fontWeight: FontWeight.w300, 
                  color: PremiumTokens.silver,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 24),
              _buildInputLabel("TITLE"),
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("e.g., Morning Meditation"),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel("TIME"),
                        TextField(
                          controller: timeController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("06:00 AM"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel("SUBTITLE"),
                        TextField(
                          controller: subtitleController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("15 Mins"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInputLabel("CATEGORY"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['Morning', 'Afternoon', 'Evening'].map((cat) {
                  final isSelected = category == cat;
                  return GestureDetector(
                    onTap: () => setModalState(() => category = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? PremiumTokens.nebulaBlue : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: isSelected ? PremiumTokens.nebulaBlue : Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white54,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: PremiumUI.primaryButton(
                  text: ritual == null ? "ESTABLISH RITUAL" : "UPDATE RITUAL",
                  onTap: () {
                    if (titleController.text.isNotEmpty && timeController.text.isNotEmpty) {
                      if (ritual == null) {
                        ref.read(ritualsProvider.notifier).addRitual(Ritual(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleController.text,
                          time: timeController.text,
                          subtitle: subtitleController.text.isEmpty ? null : subtitleController.text,
                          category: category,
                          updatedAt: DateTime.now(),
                        ));
                      } else {
                        ref.read(ritualsProvider.notifier).updateRitual(ritual.copyWith(
                          title: titleController.text,
                          time: timeController.text,
                          subtitle: subtitleController.text.isEmpty ? null : subtitleController.text,
                          category: category,
                          updatedAt: DateTime.now(),
                        ));
                      }
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Colors.white24,
          letterSpacing: 2,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white10),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.03),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: PremiumTokens.nebulaBlue, width: 1),
      ),
    );
  }
}

class _ConstellationBackground extends StatelessWidget {
  const _ConstellationBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            Color(0xFF0A0F1D), // void-deep
            Color(0xFF020408), // void-black
          ],
        ),
      ),
      child: Stack(
        children: [
          _buildStar(top: 100, left: 40, size: 2, opacity: 0.3),
          _buildStar(top: 250, right: 60, size: 3, opacity: 0.2),
          _buildStar(bottom: 300, left: 80, size: 2, opacity: 0.4),
          _buildStar(top: 500, right: 30, size: 3, opacity: 0.25),
          _buildStar(top: 40, right: 120, size: 2, opacity: 0.3),
          _buildStar(bottom: 100, right: 100, size: 2, opacity: 0.2),
        ],
      ),
    );
  }

  Widget _buildStar({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required double opacity,
  }) {
    final star = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: opacity),
            blurRadius: size * (AppTheme.lowPerformanceMode ? 1 : 2),
            spreadRadius: 1,
          ),
        ],
      ),
    );

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: AppTheme.lowPerformanceMode 
        ? star
        : star.animate(onPlay: (c) => c.repeat(reverse: true))
             .fadeIn(duration: (1000 + (size * 500)).ms)
             .blur(begin: const Offset(0.5, 0.5), end: const Offset(1.5, 1.5)),
    );
  }
}
