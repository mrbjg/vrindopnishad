import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design_system.dart';

class SacredLogoutDialog extends StatelessWidget {
  final VoidCallback onLogout;

  const SacredLogoutDialog({
    super.key,
    required this.onLogout,
  });

  static void show(BuildContext context, {required VoidCallback onLogout}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SacredLogoutDialog(onLogout: onLogout);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: PremiumTokens.indigoGlass(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Floating celestial icon
                PremiumUI.pulsingCelestialIcon(
                  icon: Icons.nights_stay_outlined,
                  size: 40,
                ),
                
                const SizedBox(height: 32),
                
                PremiumUI.silverText(
                  "Spiritual Rest?",
                  style: GoogleFonts.spectral(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  "Are you sure you want to pause your journey for now? Your progress is saved in the celestial vault.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: PremiumTokens.silver.withOpacity(0.7),
                    height: 1.6,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Action Buttons
                _buildActionButton(
                  context: context,
                  label: "CONTINUE JOURNEY",
                  isPrimary: true,
                  onTap: () => Navigator.pop(context),
                ),
                
                const SizedBox(height: 16),
                
                _buildActionButton(
                  context: context,
                  label: "SIGN OUT",
                  isPrimary: false,
                  onTap: () {
                    Navigator.pop(context);
                    onLogout();
                  },
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms).scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1, 1),
                curve: Curves.easeOutCubic,
              ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: isPrimary
          ? ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: PremiumTokens.silverGradient,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: PremiumTokens.voidBlack,
                      letterSpacing: 2.5,
                    ),
                  ),
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: PremiumTokens.silver.withOpacity(0.1)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
              child: Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: PremiumTokens.silver.withOpacity(0.4),
                  letterSpacing: 2,
                ),
              ),
            ),
    );
  }
}
