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
import '../core/providers.dart';

enum _RitualCategoryStatus { active, expired, scheduled }

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
            bottom: false,
            child: Column(
              children: [
                _buildHeader(context, ref),
                ritualsAsync.when(
                  data: (rituals) => _RitualProgressHeader(rituals: rituals),
                  loading: () => const SizedBox(height: 120),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                Expanded(
                  child: ritualsAsync.when(
                    data: (rituals) => _buildRitualsList(context, ref, rituals),
                    loading: () => Center(child: CircularProgressIndicator(color: PremiumTokens.activeAccent)),
                    error: (e, _) => Center(child: Text("Error loading rituals: $e", style: TextStyle(color: PremiumTokens.activeAccent))),
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
                      color: PremiumTokens.glassBase.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(Icons.add, color: PremiumTokens.surfaceMain, size: 32),
              ),
            ).animate().scale(delay: 400.ms, duration: 600.ms, curve: Curves.elasticOut),
          ),

          // Premium Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  ref.read(navigationIndexProvider.notifier).state = 0;
                }
              },
              child: PremiumUI.glassCard(
                padding: const EdgeInsets.all(12),
                borderRadius: 16,
                child: Icon(
                  Iconsax.arrow_left_2, 
                  color: PremiumTokens.textPrimary, 
                  size: 20
                ),
              ),
            ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final isDark = PremiumTokens.isDark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              ref.read(themeProvider.notifier).toggleTheme(!isDark);
            },
            child: PremiumUI.glassCard(
              padding: const EdgeInsets.all(10),
              borderRadius: 100,
              child: Icon(
                isDark ? Iconsax.moon : Iconsax.sun_1,
                color: isDark ? PremiumTokens.activeAccent : Colors.orangeAccent,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "SACRED RITUALS",
            textAlign: TextAlign.center,
            style: GoogleFonts.spectral(
              fontSize: 24,
              fontWeight: FontWeight.w200,
              color: PremiumTokens.silver,
              letterSpacing: 4,
            ),
          ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2),
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
              context,
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
      padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 180),
      children: categories.map((category) {
        final categoryRituals = rituals.where((r) => r.category == category).toList();
        if (categoryRituals.isEmpty) return const SizedBox.shrink();

        final completedCount = categoryRituals.where((r) => r.isCompleted).length;
        final totalCount = categoryRituals.length;
        final isCategoryDone = completedCount == totalCount;

        IconData categoryIcon = Icons.wb_sunny_outlined;
        if (category == 'Afternoon') categoryIcon = Icons.wb_cloudy_outlined;
        if (category == 'Evening') categoryIcon = Icons.nightlight_outlined;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 16),
              child: Row(
                children: [
                  Icon(categoryIcon, size: 14, color: isCategoryDone ? PremiumTokens.saffronGlow : PremiumTokens.starlight.withValues(alpha: 0.6)),
                  const SizedBox(width: 8),
                  Text(
                    category.toUpperCase(),
                    style: PremiumTokens.hindiAwareStyle(
                      category,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: isCategoryDone ? PremiumTokens.saffronGlow : PremiumTokens.starlight.withValues(alpha: 0.6),
                    ).copyWith(letterSpacing: 4),
                  ),
                  const Spacer(),
                  Text(
                    "$completedCount/$totalCount",
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isCategoryDone ? PremiumTokens.saffronGlow : PremiumTokens.textHint,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),
            
            ...categoryRituals.map((ritual) => _buildRitualCard(context, ref, ritual)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildRitualCard(BuildContext context, WidgetRef ref, Ritual ritual) {
    final status = _getCategoryStatus(ritual.category);
    final isMissed = status == _RitualCategoryStatus.expired && !ritual.isCompleted;
    final isScheduled = status == _RitualCategoryStatus.scheduled;
    final isActive = status == _RitualCategoryStatus.active;
    final isLocked = isMissed || isScheduled;

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
            color: PremiumTokens.activeAccent,
          );
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: PremiumTokens.activeAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(Iconsax.trash, color: PremiumTokens.activeAccent),
        ),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            final willBeCompleted = !ritual.isCompleted;
            if (willBeCompleted) {
              ref.read(userStatsProvider.notifier).recordReading(
                context,
                "ritual_done_${ritual.id}",
                title: "Completed: ${ritual.title}",
                category: "Ritual",
              );
            }
            ref.read(ritualsProvider.notifier).toggleRitual(ritual.id);
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            _showAddRitualDialog(context, ref, ritual: ritual);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: ritual.isCompleted 
                  ? PremiumTokens.saffronGlow.withValues(alpha: 0.02) 
                  : (isMissed ? PremiumTokens.activeAccent.withValues(alpha: 0.02) : PremiumTokens.borderSubtle),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: ritual.isCompleted 
                  ? PremiumTokens.saffronGlow.withValues(alpha: 0.2) 
                  : (isMissed ? PremiumTokens.activeAccent.withValues(alpha: 0.15) : PremiumTokens.borderMedium), 
                width: 1
              ),
              boxShadow: ritual.isCompleted ? [
                BoxShadow(
                  color: PremiumTokens.saffronGlow.withValues(alpha: 0.05),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ] : [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Opacity(
                opacity: isLocked && !ritual.isCompleted ? 0.8 : 1.0,
                child: _buildGlassContent(ritual, isMissed, isScheduled, isActive),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05),
        ),
      ),
    );
  }

  _RitualCategoryStatus _getCategoryStatus(String category) {
    final now = DateTime.now();
    final hour = now.hour;

    if (category == 'Morning') {
      if (hour < 4) return _RitualCategoryStatus.scheduled;
      if (hour < 12) return _RitualCategoryStatus.active;
      return _RitualCategoryStatus.expired;
    } else if (category == 'Afternoon') {
      if (hour < 12) return _RitualCategoryStatus.scheduled;
      if (hour < 17) return _RitualCategoryStatus.active;
      return _RitualCategoryStatus.expired;
    } else { // Evening
      if (hour < 17 && hour >= 4) return _RitualCategoryStatus.scheduled;
      return _RitualCategoryStatus.active; // Active 17:00 to 04:00
    }
  }

  Widget _buildGlassContent(Ritual ritual, bool isMissed, bool isScheduled, bool isActive) {
    const double blurSigma = 8.0;
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ritual.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: PremiumTokens.hindiAwareStyle(
                          ritual.title,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ritual.isCompleted ? PremiumTokens.textHint : PremiumTokens.silver,
                          isSacred: true,
                        ).copyWith(
                          decoration: ritual.isCompleted ? TextDecoration.lineThrough : null,
                          decorationColor: PremiumTokens.textHint,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (isMissed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: PremiumTokens.activeAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: PremiumTokens.activeAccent.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          "MISSED",
                          style: PremiumTokens.sansStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: PremiumTokens.activeAccent.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    if (isScheduled)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: PremiumTokens.borderSubtle,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: PremiumTokens.borderMedium),
                        ),
                        child: Text(
                          "LOCKED",
                          style: PremiumTokens.sansStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: PremiumTokens.textHint,
                          ),
                        ),
                      ),
                  ],
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
          _buildCheckmark(ritual, isMissed || isScheduled),
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

  Widget _buildCheckmark(Ritual ritual, bool isLocked) {
    return Consumer(
      builder: (context, ref, child) => GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          final willBeCompleted = !ritual.isCompleted;
          if (willBeCompleted) {
            ref.read(userStatsProvider.notifier).recordReading(
              context,
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
                  : PremiumTokens.glassBase.withValues(alpha: 0.2),
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
                    color: PremiumTokens.borderSubtle,
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
                style: TextStyle(color: PremiumTokens.textPrimary),
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
                          style: TextStyle(color: PremiumTokens.textPrimary),
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
                          style: TextStyle(color: PremiumTokens.textPrimary),
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
                        color: isSelected ? PremiumTokens.activeAccent : PremiumTokens.borderSubtle,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: isSelected ? PremiumTokens.activeAccent : PremiumTokens.borderMedium),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? PremiumTokens.textPrimary : PremiumTokens.textMuted,
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
          color: PremiumTokens.textHint,
          letterSpacing: 2,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: PremiumTokens.borderSubtle),
      filled: true,
      fillColor: PremiumTokens.borderSubtle,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: PremiumTokens.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: PremiumTokens.activeAccent, width: 1),
      ),
    );
  }
}

class _ConstellationBackground extends StatelessWidget {
  const _ConstellationBackground();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: isDark
            ? [const Color(0xFF0A0F1D), const Color(0xFF020408)]
            : [PremiumTokens.scaffoldBg, const Color(0xFFF5EFE0)],
        ),
      ),
      child: isDark ? Stack(
        children: [
          _buildStar(top: 100, left: 40, size: 2, opacity: 0.3),
          _buildStar(top: 250, right: 60, size: 3, opacity: 0.2),
          _buildStar(bottom: 300, left: 80, size: 2, opacity: 0.4),
          _buildStar(top: 500, right: 30, size: 3, opacity: 0.25),
          _buildStar(top: 40, right: 120, size: 2, opacity: 0.3),
          _buildStar(bottom: 100, right: 100, size: 2, opacity: 0.2),
        ],
      ) : null,
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
        color: PremiumTokens.textPrimary.withValues(alpha: opacity),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: PremiumTokens.textPrimary.withValues(alpha: opacity),
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

class _RitualProgressHeader extends StatelessWidget {
  final List<Ritual> rituals;

  const _RitualProgressHeader({required this.rituals});

  @override
  Widget build(BuildContext context) {
    if (rituals.isEmpty) return const SizedBox.shrink();

    final completedCount = rituals.where((r) => r.isCompleted).length;
    final totalCount = rituals.length;
    final progress = totalCount > 0 ? (completedCount / totalCount) : 0.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: PremiumUI.etherealCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 32,
        glowColor: PremiumTokens.activeAccent.withValues(alpha: 0.1),
        child: Row(
          children: [
            // Progress Indicator
            SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 5,
                    color: PremiumTokens.saffronGlow,
                    backgroundColor: PremiumTokens.borderSubtle,
                  ),
                  Center(
                    child: Text(
                      "${(progress * 100).toInt()}%",
                      style: PremiumTokens.sansStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: PremiumTokens.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Status Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "DAILY PROGRESS",
                    style: PremiumTokens.sansStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: PremiumTokens.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "$completedCount/$totalCount",
                        style: GoogleFonts.spectral(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: PremiumTokens.silver,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "DONE",
                        style: PremiumTokens.sansStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: PremiumTokens.saffronGlow.withValues(alpha: 0.6),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Streak Item (Simplified)
            Column(
              children: [
                const Icon(Icons.local_fire_department_rounded, color: PremiumTokens.saffronGlow, size: 24),
                const SizedBox(height: 4),
                Text(
                  "7 DAYS",
                  style: PremiumTokens.sansStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: PremiumTokens.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }
}
