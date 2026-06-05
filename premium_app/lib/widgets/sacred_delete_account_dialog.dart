import 'package:premium_app/core/providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../core/design_system.dart';
import '../core/auth_provider.dart';
import '../core/stats_provider.dart';

class SacredDeleteAccountDialog extends ConsumerStatefulWidget {
  const SacredDeleteAccountDialog({super.key});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      barrierColor: PremiumTokens.scaffoldBg.withValues(alpha: 0.82),
      transitionDuration: const Duration(milliseconds: 380),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SacredDeleteAccountDialog();
      },
    );
  }

  @override
  ConsumerState<SacredDeleteAccountDialog> createState() => _SacredDeleteAccountDialogState();
}

class _SacredDeleteAccountDialogState extends ConsumerState<SacredDeleteAccountDialog> {
  bool _isLoading = false;

  Future<void> _handleDeleteAccount() async {
    AppHapticFeedback.heavyImpact();
    setState(() => _isLoading = true);

    try {
      final user = ref.read(authServiceProvider).currentUser;
      if (user != null) {
        // Clean up Supabase stats & history data first
        await ref.read(statsServiceProvider).deleteUserData(user.uid);
      }

      await ref.read(authServiceProvider).deleteAccount();
      if (mounted) {
        Navigator.pop(context); // Close dialog
        // Sign out to trigger auth state updates and redirect
        await ref.read(authServiceProvider).signOut();
        if (mounted) {
          PremiumUI.showNotification(
            context,
            "Your presence has been dissolved.",
            icon: Iconsax.trash,
            color: Colors.red,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        if (e.code == 'requires-recent-login') {
          _showReauthenticatePrompt(context);
        } else {
          PremiumUI.showNotification(
            context,
            e.message ?? "An error occurred during account dissolution.",
            icon: Iconsax.warning_2,
            color: Colors.red,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        PremiumUI.showNotification(
          context,
          "An error occurred: $e",
          icon: Iconsax.warning_2,
          color: Colors.red,
        );
      }
    }
  }

  void _showReauthenticatePrompt(BuildContext context) {
    if (!context.mounted) return;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      barrierColor: PremiumTokens.scaffoldBg.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Material(
          color: Colors.transparent,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: PremiumTokens.indigoGlass(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: PremiumTokens.activeAccent.withValues(alpha: 0.1),
                        border: Border.all(
                          color: PremiumTokens.activeAccent.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Iconsax.security_safe,
                        color: PremiumTokens.activeAccent,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 24),
                    PremiumUI.silverText(
                      "Re-authentication Required",
                      style: GoogleFonts.spectral(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "For security reasons, dissolving your account requires a recent login. Please sign out, sign back in, and try again.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: PremiumTokens.silver.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!context.mounted) return;
                          Navigator.pop(context); // Close this prompt
                          Navigator.pop(context); // Close delete dialog
                          // Sign out the user
                          await ref.read(authServiceProvider).signOut();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PremiumTokens.activeAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Text(
                          "SIGN OUT TO RE-AUTHENTICATE",
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: PremiumTokens.silver.withValues(alpha: 0.12),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Text(
                          "CANCEL",
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: PremiumTokens.silver.withValues(alpha: 0.6),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
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
                // Destructive styled icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.red.withValues(alpha: 0.25),
                        Colors.red.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.30),
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Iconsax.trash,
                      color: Colors.red,
                      size: 32,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                PremiumUI.silverText(
                  "Dissolve Presence?",
                  style: GoogleFonts.spectral(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                Text(
                  "This action is permanent and irreversible. You will instantly lose your daily streaks, completed Jap malas, saved items, and progress in your spiritual journey.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: PremiumTokens.silver.withValues(alpha: 0.7),
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 40),

                // Confirm Deletion Button
                _buildConfirmButton(),

                const SizedBox(height: 16),

                // Keep Account Button
                _buildCancelButton(),
              ],
            ),
          )
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

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFC53030)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _handleDeleteAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text(
                  "DISSOLVE PERMANENTLY",
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

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: _isLoading
            ? null
            : () {
                AppHapticFeedback.lightImpact();
                Navigator.pop(context);
              },
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: PremiumTokens.silver.withValues(alpha: 0.12),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Text(
          "KEEP MY ACCOUNT",
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
