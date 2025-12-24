import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About Sant-Vaani")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.sparkles,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Sant-Vaani",
              style: GoogleFonts.spectral(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
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
                _buildSocialIcon(LucideIcons.instagram),
                const SizedBox(width: 24),
                _buildSocialIcon(LucideIcons.twitter),
                const SizedBox(width: 24),
                _buildSocialIcon(LucideIcons.facebook),
                const SizedBox(width: 24),
                _buildSocialIcon(LucideIcons.youtube),
              ],
            ),
            const SizedBox(height: 60),
            const Text(
              "© 2025 Vrindopnishad. All rights reserved.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const Text(
              "Made with ❤️ for Sant-Sanatan",
              style: TextStyle(
                color: AppTheme.accentColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String description,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.1)),
      ),
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
                color: AppTheme.primaryColor,
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
        color: AppTheme.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppTheme.primaryColor, size: 24),
    );
  }
}
