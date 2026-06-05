import 'package:premium_app/core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design_system.dart';
import '../core/color_theme_provider.dart';

/// The original Spiritual Rest dialog — with bounce entry animation
/// and theme-connected accent color for the icon circle and primary button.
class SacredLogoutDialog extends ConsumerWidget {
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
      barrierColor: PremiumTokens.scaffoldBg.withValues(alpha: 0.82),
      transitionDuration: const Duration(milliseconds: 380),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SacredLogoutDialog(onLogout: onLogout);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(colorPaletteProvider);

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
                // Themed celestial icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        palette.accent.withValues(alpha: 0.25),
                        palette.accent.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                    border: Border.all(
                      color: palette.accent.withValues(alpha: 0.30),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.nights_stay_outlined,
                      color: palette.accent,
                      size: 32,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

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
                    color: PremiumTokens.silver.withValues(alpha: 0.7),
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 40),

                // CONTINUE — theme gradient
                _buildContinueButton(context, palette),

                const SizedBox(height: 16),

                // SIGN OUT — subtle ghost
                _buildSignOutButton(context),
              ],
            ),
          )
            // Bounce-in entry animation (fast + springy)
            .animate()
            .fadeIn(duration: 220.ms)
            .scaleXY(
              begin: 0.82,
              end: 1.0,
              duration: 380.ms,
              curve: Curves.elasticOut,
            ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context, AppColorPalette palette) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: LinearGradient(
            colors: [palette.accent, palette.accentDark],
          ),
          boxShadow: [
            BoxShadow(
              color: palette.glow.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            AppHapticFeedback.mediumImpact();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          ),
          child: Text(
            "CONTINUE JOURNEY",
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: () {
          AppHapticFeedback.heavyImpact();
          Navigator.pop(context);
          onLogout();
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: PremiumTokens.silver.withValues(alpha: 0.12)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        ),
        child: Text(
          "SIGN OUT",
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: PremiumTokens.silver.withValues(alpha: 0.45),
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
