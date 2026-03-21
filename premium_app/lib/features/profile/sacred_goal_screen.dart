import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/design_system.dart';
import '../../core/stats_provider.dart';
import '../../core/auth_provider.dart';
import '../../services/notification_service.dart';

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: PremiumUI.masterBackground(index: 3)),
          
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
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Set your daily minimum Mala goal to maintain the flow of peace.",
                    textAlign: TextAlign.center,
                    style: PremiumTokens.sansStyle(
                      fontSize: 16,
                      color: Colors.white54,
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
                      child: Text("CANCEL", style: PremiumTokens.sansStyle(color: Colors.white24, letterSpacing: 2)),
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
          style: PremiumTokens.sansStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PremiumTokens.nebulaBlue, letterSpacing: 2),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => setState(() => _malaGoal = (_malaGoal > 1) ? _malaGoal - 1 : 1),
              icon: const Icon(Iconsax.minus, color: Colors.white38),
            ),
            const SizedBox(width: 24),
            Text(
              "$_malaGoal",
              style: GoogleFonts.spectral(fontSize: 84, fontWeight: FontWeight.w300, color: Colors.white),
            ),
            const SizedBox(width: 24),
            IconButton(
              onPressed: () => setState(() => _malaGoal++),
              icon: const Icon(Iconsax.add, color: Colors.white38),
            ),
          ],
        ),
        Text(
          "${_malaGoal * 108} CHANTS",
          style: PremiumTokens.sansStyle(fontSize: 14, color: Colors.white24),
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
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(primary: PremiumTokens.nebulaBlue, onPrimary: Colors.white, surface: PremiumTokens.voidIndigo),
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
            const Icon(Iconsax.notification, color: PremiumTokens.nebulaBlue, size: 24),
            const SizedBox(width: 16),
            Text(
              "REMINDER: ${_reminderTime.format(context)}",
              style: PremiumTokens.sansStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
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
          gradient: PremiumTokens.nebulaGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: PremiumTokens.nebulaBlue.withOpacity(0.3), blurRadius: 20, spreadRadius: 2),
          ],
        ),
        child: Center(
          child: Text(
            "SET INTENTION",
            style: PremiumTokens.sansStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2),
          ),
        ),
      ),
    );
  }
}
