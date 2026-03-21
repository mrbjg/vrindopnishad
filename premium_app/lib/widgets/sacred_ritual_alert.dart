import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design_system.dart';

class SacredRitualAlert extends StatelessWidget {
  final String title;
  final String description;
  final String ritualTitle;
  final VoidCallback onBegin;
  final VoidCallback onRemind;

  const SacredRitualAlert({
    super.key,
    required this.title,
    required this.description,
    required this.ritualTitle,
    required this.onBegin,
    required this.onRemind,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String description,
    required String ritualTitle,
    required VoidCallback onBegin,
    required VoidCallback onRemind,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SacredRitualAlert(
          title: title,
          description: description,
          ritualTitle: ritualTitle,
          onBegin: onBegin,
          onRemind: onRemind,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background content blur simulated
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),

          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Top Mini Card (Sant-Vaani Brand)
                  _buildTopMiniCard(),
                  
                  const Spacer(),
                  
                  // Central Modal
                  _buildCentralModal(),
                  
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          
          // Home Indicator Mock
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 120,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopMiniCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: PremiumTokens.glassDecoration(
        blur: 24,
        opacity: 0.05,
        borderRadius: 40,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.wb_sunny_outlined, color: PremiumTokens.silver, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "SANT-VAANI",
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: PremiumTokens.silver.withOpacity(0.6),
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      "now",
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        color: PremiumTokens.silver.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
                PremiumUI.silverText(
                  ritualTitle,
                  style: GoogleFonts.spectral(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: PremiumTokens.silver.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, curve: Curves.easeOutCubic);
  }

  Widget _buildCentralModal() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: PremiumTokens.indigoGlass(),
      child: Column(
        children: [
          // Starlight pulse decoration
          PremiumUI.pulsingCelestialIcon(icon: Icons.nights_stay_outlined),
          
          const SizedBox(height: 32),
          
          PremiumUI.silverText(
            title,
            style: GoogleFonts.spectral(
              fontSize: 32,
              fontWeight: FontWeight.w200,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          Text(
            "The celestial alignment is ideal for your $ritualTitle ritual. Step into the void of peace.",
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: PremiumTokens.silver.withOpacity(0.7),
              height: 1.6,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Buttons
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onBegin,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: PremiumTokens.silverGradient,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    "BEGIN RITUAL",
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: PremiumTokens.voidBlack,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: onRemind,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: PremiumTokens.silver.withOpacity(0.2)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
              child: Text(
                "REMIND IN 10M",
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: PremiumTokens.silver.withOpacity(0.6),
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1, curve: Curves.easeOutCubic);
  }
}
