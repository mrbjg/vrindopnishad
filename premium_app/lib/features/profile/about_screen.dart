import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design_system.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          PremiumUI.voidBackground(),
          SingleChildScrollView(
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
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              "Follow us for daily wisdom",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon(Iconsax.instagram),
                const SizedBox(width: 24),
                _buildSocialIcon(Iconsax.message_2),
                const SizedBox(width: 24),
                _buildSocialIcon(Iconsax.direct_right),
                const SizedBox(width: 24),
                _buildSocialIcon(Iconsax.video_circle),
              ],
            ),
            const SizedBox(height: 60),
            const Text(
              "© 2026 Vrindopnishad. All rights reserved.",
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const Text(
              "Made with ❤️ for Sant-Sanatan",
              style: TextStyle(
                color: PremiumTokens.nebulaBlue,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PremiumTokens.nebulaBlue.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: PremiumTokens.nebulaBlue.withValues(alpha: 0.2)),
      ),
      child: Icon(icon, color: PremiumTokens.nebulaBlue, size: 24),
    );
  }
}
