import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design_system.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          PremiumUI.voidBackground(context),
          
          // Celestial Nebula Overlays
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PremiumTokens.nebulaBlue.withValues(alpha: 0.15),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scale(duration: 5.seconds, begin: const Offset(1, 1), end: const Offset(1.2, 1.2))
             .blur(begin: const Offset(80, 80), end: const Offset(100, 100)),
          ),

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
                  onPressed: () {},
                ),
                title: Text(
                  "SACRED VISION",
                  style: GoogleFonts.spectral(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    fontSize: 16,
                    color: PremiumTokens.textPrimary,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      
                      // Hero Icon with Divine Aura
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: PremiumTokens.evolvingAura(
                          color: PremiumTokens.nebulaBlue,
                          intensity: 0.5,
                        ),
                        child: PremiumUI.pulsingCelestialIcon(
                          icon: Iconsax.magic_star,
                          size: 80,
                        ),
                      ).animate().fadeIn(duration: 800.ms).scale(delay: 200.ms),
                      
                      const SizedBox(height: 48),
                      
                      // Branding Section
                      Text(
                         "SANT-VAANI",
                         style: GoogleFonts.spectral(
                           fontSize: 42,
                           fontWeight: FontWeight.w900,
                           color: PremiumTokens.textPrimary,
                           letterSpacing: 8,
                         ),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                      
                      const SizedBox(height: 8),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: PremiumTokens.nebulaBlue.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          "VERSION 1.0.0 • PRO",
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: PremiumTokens.nebulaBlue,
                          ),
                        ),
                      ).animate().fadeIn(delay: 600.ms),
                      
                      const SizedBox(height: 64),
                      
                      // Info Sections
                      _buildCelestialSection(
                        "OUR DIVINE MISSION",
                        "Sant-Vaani (Vrindopnishad) is dedicated to preserving and promoting the rich cultural and spiritual heritage of Hindu Vaidik Sanskriti in the digital age.",
                        Iconsax.sun_1,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      _buildCelestialSection(
                        "WHAT WE OFFER",
                        "An immersive celestial platform to explore Shlokas, Strotras, and sacred poems with high-fidelity audio and deep commentaries.",
                        Iconsax.moon,
                      ),
                      
                      const SizedBox(height: 64),
                      
                      // Social Connections
                      Text(
                        "CONNECT IN THE CIRCLE",
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 3,
                          color: PremiumTokens.textHint,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildPremiumSocialIcon(context, Iconsax.instagram, "Instagram", PremiumTokens.nebulaBlue),
                          const SizedBox(width: 24),
                          _buildPremiumSocialIcon(context, Iconsax.message_2, "WhatsApp", Colors.greenAccent),
                          const SizedBox(width: 24),
                          _buildPremiumSocialIcon(context, Iconsax.direct_right, "Telegram", Colors.lightBlueAccent),
                          const SizedBox(width: 24),
                          _buildPremiumSocialIcon(context, Iconsax.video_circle, "YouTube", Colors.redAccent),
                        ],
                      ),
                      
                      const SizedBox(height: 80),
                      
                      // Footer
                      Text(
                        "© 2026 VRINDOPNISHAD",
                        style: GoogleFonts.manrope(
                          color: PremiumTokens.textHint,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("MADE WITH ", style: TextStyle(color: PremiumTokens.glassBase.withValues(alpha: 0.2), fontSize: 10)),
                          const Icon(Icons.favorite, color: Colors.redAccent, size: 10),
                          Text(" FOR ", style: TextStyle(color: PremiumTokens.glassBase.withValues(alpha: 0.2), fontSize: 10)),
                          Text(
                            "SANT-SANATAN",
                            style: GoogleFonts.manrope(
                              color: PremiumTokens.nebulaBlue.withValues(alpha: 0.6),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 60),
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

  Widget _buildCelestialSection(String title, String description, IconData icon) {
    return PremiumUI.voidCard(
      padding: const EdgeInsets.all(28),
      accentColor: PremiumTokens.nebulaBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PremiumTokens.nebulaBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: PremiumTokens.nebulaBlue, size: 16),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.spectral(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  color: PremiumTokens.textPrimary.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Text(
              description,
              style: GoogleFonts.manrope(
                height: 1.8,
                fontSize: 14,
                color: PremiumTokens.textPrimary.withValues(alpha: 0.5),
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSocialIcon(BuildContext context, IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        PremiumUI.showNotification(
          context, 
          "Connecting to $label...",
          icon: icon,
          color: color,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    ).animate()
     .fadeIn(delay: 800.ms)
     .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack);
  }
}
