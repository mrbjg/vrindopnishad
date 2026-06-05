import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/design_system.dart';
import '../../core/stats_provider.dart';
import '../../core/auth_provider.dart';
import '../../services/notification_service.dart';
import '../../core/color_theme_provider.dart';
import '../../widgets/divine_ruler_picker.dart';

class SacredGoalScreen extends ConsumerStatefulWidget {
  final bool isOnboarding;
  const SacredGoalScreen({this.isOnboarding = false, super.key});

  @override
  ConsumerState<SacredGoalScreen> createState() => _SacredGoalScreenState();
}

class _SacredGoalScreenState extends ConsumerState<SacredGoalScreen> {
  int _malaGoal = 11;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 6, minute: 0);

  @override
  Widget build(BuildContext context) {
    PremiumTokens.of(context);
    ref.watch(colorPaletteProvider);
    return Scaffold(
      backgroundColor: PremiumTokens.scaffoldBg,
      body: Stack(
        children: [
          Positioned.fill(child: PremiumUI.masterBackground(index: 3, context: context)),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    "SACRED INTENTION",
                    style: PremiumTokens.sansStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      color: PremiumTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Set your daily minimum Mala goal to maintain the flow of peace.",
                    textAlign: TextAlign.center,
                    style: PremiumTokens.sansStyle(
                      fontSize: 16,
                      color: PremiumTokens.textMuted,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Mala Goal Selector
                  _buildGoalSelector(),
                  
                  const SizedBox(height: 48),
                  
                  // Reminder Picker
                  _buildReminderPicker(),
                  
                  const Spacer(),
                  
                  _buildSubmitButton(),
                  
                  if (!widget.isOnboarding)
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("CANCEL", style: PremiumTokens.sansStyle(color: PremiumTokens.textHint, letterSpacing: 2)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalSelector() {
    return Column(
      children: [
        Text(
          "DAILY MALAS",
          style: PremiumTokens.sansStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PremiumTokens.activeAccent, letterSpacing: 2),
        ),
        const SizedBox(height: 16),
        Text(
          "$_malaGoal",
          style: GoogleFonts.spectral(fontSize: 84, fontWeight: FontWeight.w300, color: PremiumTokens.textPrimary),
        ),
        const SizedBox(height: 16),
        DivineRulerPicker(
          value: _malaGoal.toDouble(),
          min: 1.0,
          max: 108.0,
          step: 1.0,
          onChanged: (val) {
            setState(() => _malaGoal = val.toInt());
          },
          activeColor: PremiumTokens.activeAccent,
          textColor: PremiumTokens.textPrimary,
        ),
        const SizedBox(height: 24),
        Text(
          "${_malaGoal * 108} CHANTS",
          style: PremiumTokens.sansStyle(fontSize: 14, color: PremiumTokens.textHint),
        ),
      ],
    );
  }

  Widget _buildReminderPicker() {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _reminderTime,
          builder: (context, child) => Theme(
            data: (PremiumTokens.isDark ? ThemeData.dark() : ThemeData.light()).copyWith(
              colorScheme: PremiumTokens.isDark 
                  ? ColorScheme.dark(primary: PremiumTokens.activeAccent, onPrimary: PremiumTokens.textPrimary, surface: PremiumTokens.surfaceMain)
                  : ColorScheme.light(primary: PremiumTokens.activeAccent, onPrimary: Colors.white, surface: PremiumTokens.surfaceMain),
            ),
            child: child!,
          ),
        );
        if (time != null) setState(() => _reminderTime = time);
      },
      child: PremiumUI.glassCard(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
        borderRadius: 24,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.notification, color: PremiumTokens.activeAccent, size: 24),
            const SizedBox(width: 16),
            Text(
              "REMINDER: ${_reminderTime.format(context)}",
              style: PremiumTokens.sansStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PremiumTokens.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final colorPalette = ref.watch(colorPaletteProvider);
    return GestureDetector(
      onTap: () async {
        final user = ref.read(authStateProvider).value;
        if (user != null) {
          final timeStr = "${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}";
          await ref.read(statsServiceProvider).updateGoal(user.uid, _malaGoal, timeStr);
          await NotificationService().scheduleDailyReminder(_reminderTime.hour, _reminderTime.minute);
          
          if (mounted) {
            if (widget.isOnboarding) {
              // Finalize onboarding if needed
            }
            Navigator.pop(context);
          }
        }
      },
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colorPalette.gradient,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: colorPalette.accent.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 2),
          ],
        ),
        child: Center(
          child: Text(
            "SET INTENTION",
            style: PremiumTokens.sansStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: colorPalette.accent.computeLuminance() > 0.4
                  ? const Color(0xFF1A1A2E)
                  : Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
