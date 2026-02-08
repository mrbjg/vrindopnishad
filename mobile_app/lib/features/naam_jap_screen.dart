import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/providers.dart';
import '../widgets/animated_effects.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// NAAM JAP SCREEN - Sacred Mantra Chanting Counter
/// Features: Large tappable button, mala tracking, cooldown, and calm UI
/// ═══════════════════════════════════════════════════════════════════════════

class NaamJapScreen extends ConsumerStatefulWidget {
  const NaamJapScreen({super.key});

  @override
  ConsumerState<NaamJapScreen> createState() => _NaamJapScreenState();
}

class _NaamJapScreenState extends ConsumerState<NaamJapScreen>
    with SingleTickerProviderStateMixin {
  bool _canTap = true;
  late AnimationController _pulseController;

  // Cooldown duration in milliseconds - prevents too fast counting
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

    // Animate the tap
    _pulseController.forward().then((_) => _pulseController.reverse());

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Increment counter
    ref.read(naamJapCounterProvider.notifier).state++;

    // Apply cooldown
    setState(() => _canTap = false);
    Future.delayed(Duration(milliseconds: _cooldownMs), () {
      if (mounted) setState(() => _canTap = true);
    });
  }

  void _resetCounter() {
    HapticFeedback.mediumImpact();
    ref.read(naamJapCounterProvider.notifier).state = 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final count = ref.watch(naamJapCounterProvider);
    final malaCount = count ~/ 108;
    final currentInMala = count % 108;
    final progress = currentInMala / 108;

    return Scaffold(
      body: GestureDetector(
        onTap: _onTap,
        behavior: HitTestBehavior.translucent,
        child: AnimatedSacredBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.space20),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.deepSaffron,
                              AppTheme.primaryColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.deepSaffron.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.heart,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'नाम जप',
                              style: GoogleFonts.notoSansDevanagari(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary(context),
                              ),
                            ),
                            Text(
                              'Tap anywhere to count',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: AppTheme.textMuted(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Reset button - wrapped in GestureDetector to stop propagation
                      if (count > 0)
                        GestureDetector(
                          onTap: () {
                            _resetCounter();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor(context),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusFull,
                              ),
                              border: Border.all(
                                color: AppTheme.borderColor(context),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.rotateCcw,
                                  size: 14,
                                  color: AppTheme.textMuted(context),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Reset',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: AppTheme.textMuted(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  const Spacer(),

                  // Mala counter display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatCard(
                        context,
                        '$malaCount',
                        'Mala\nComplete',
                        AppTheme.primaryColor,
                        isDark,
                      ),
                      const SizedBox(width: AppTheme.space24),
                      _buildStatCard(
                        context,
                        '$currentInMala',
                        'Current\n/ 108',
                        AppTheme.deepSaffron,
                        isDark,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.space32),

                  // Main ॐ display with animation
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = 1.0 - (_pulseController.value * 0.05);
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Progress ring
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 10,
                            backgroundColor: AppTheme.surfaceColor(context),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.deepSaffron,
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        // ॐ button
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: _canTap
                                  ? [
                                      AppTheme.deepSaffron,
                                      AppTheme.primaryColor,
                                    ]
                                  : [
                                      AppTheme.deepSaffron.withOpacity(0.6),
                                      AppTheme.primaryColor.withOpacity(0.6),
                                    ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.deepSaffron.withOpacity(0.5),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'ॐ',
                              style: TextStyle(
                                fontSize: 72,
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.space24),

                  // Total counter
                  GlassCard(
                    blur: 10,
                    opacity: isDark ? 0.12 : 0.7,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.space24,
                      vertical: AppTheme.space16,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Total Jap',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppTheme.textMuted(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$count',
                          style: GoogleFonts.outfit(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Instruction text
                  Text(
                    'Tap anywhere • Calm pace for mindful jap',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: AppTheme.textMuted(context),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    Color color,
    bool isDark,
  ) {
    return GlassCard(
      blur: 10,
      opacity: isDark ? 0.12 : 0.7,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space24,
        vertical: AppTheme.space16,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: AppTheme.textMuted(context),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
