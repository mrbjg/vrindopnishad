import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design_system.dart';
import 'package:flutter/services.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          PremiumUI.voidBackground(),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                centerTitle: true,
                leading: IconButton(
                  icon: PremiumUI.animatedIcon(
                    folder: 'Chevron-left',
                    fileName: 'chevron-left.json',
                    size: 20,
                    color: PremiumTokens.nebulaBlue,
                    onTap: () => Navigator.pop(context),
                  ),
                  onPressed: () {}, // Handled by animatedIcon onTap
                ),
                title: Text(
                  "ABOUT DIVINE PATH",
                  style: GoogleFonts.spectral(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: PremiumTokens.nebulaGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: PremiumTokens.nebulaBlue.withValues(alpha: 0.4),
                                blurRadius: 25,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Iconsax.magic_star,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Sant-Vaani",
                        style: PremiumTokens.displayStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text("Version 1.0.0", style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 40),
                      _buildInfoCard(
                        context,
                        "Our Mission",
                        "Sant-Vaani (Vrindopnishad) is dedicated to preserving and promoting the rich cultural and spiritual heritage of Hindu Vaidik Sanskriti in the digital age.",
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        context,
                        "What we offer",
                        "We provide an immersive platform to explore Shlokas, Strotras, and sacred poems with beautiful imagery, audio narrations, and deep commentaries.",
                      ),
                      const SizedBox(height: 40),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 24),
                      Text(
                        "Follow us for daily wisdom".toUpperCase(),
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: 2,
                          color: Colors.white38,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialIcon(context, Iconsax.instagram, "Instagram"),
                          const SizedBox(width: 24),
                          _buildSocialIcon(context, Iconsax.message_2, "WhatsApp"),
                          const SizedBox(width: 24),
                          _buildSocialIcon(context, Iconsax.direct_right, "Telegram"),
                          const SizedBox(width: 24),
                          _buildSocialIcon(context, Iconsax.video_circle, "YouTube"),
                        ],
                      ),
                      const SizedBox(height: 60),
                      const Text(
                        "© 2026 Vrindopnishad. All rights reserved.",
                        style: TextStyle(color: Colors.white24, fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Made with ❤️ for Sant-Sanatan",
                        style: TextStyle(
                          color: PremiumTokens.nebulaBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String description,
  ) {
    return PremiumUI.voidGlassCard(
      padding: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: PremiumTokens.nebulaBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(description, style: const TextStyle(height: 1.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(BuildContext context, IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        PremiumUI.showNotification(
          context, 
          "Connecting to our $label...",
          icon: icon,
          color: PremiumTokens.nebulaBlue,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: PremiumTokens.nebulaBlue.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: PremiumTokens.nebulaBlue.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: PremiumTokens.nebulaBlue, size: 24),
      ),
    );
  }
}
