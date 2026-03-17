import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design_system.dart';
import '../core/auth_provider.dart';
import '../core/providers.dart';
import 'profile/saved_items_screen.dart';
import 'profile/reading_history_screen.dart';
import 'profile/settings_screen.dart';
import 'profile/about_screen.dart';
import 'spiritual_leveling_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background handled by MainNavigationScreen
          
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Premium Header
              SliverToBoxAdapter(
                child: _PremiumProfileHeader(user: user),
              ),

              // Menu Sections
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildPremiumSectionTitle("Sacred Journey"),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SpiritualLevelingScreen()),
                      ),
                      child: PremiumUI.voidCard(
                        padding: const EdgeInsets.all(20),
                        borderRadius: 24,
                        accentColor: const Color(0xFF2E0BDA),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: PremiumTokens.evolvingAura(
                                color: const Color(0xFF2E0BDA),
                                intensity: 0.6,
                              ),
                              child: PremiumUI.animatedIcon(
                                folder: 'Star',
                                fileName: 'star.json',
                                size: 24,
                                color: const Color(0xFFC0C0C0),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Level 42 Seeker",
                                    style: PremiumTokens.sansStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "Evolving Silver-Indigo Aura",
                                    style: PremiumTokens.sansStyle(
                                      fontSize: 12,
                                      color: Colors.white38,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Iconsax.arrow_right_3, color: Colors.white24, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildPremiumSectionTitle("Your Sacred Collection"),
                    const SizedBox(height: 16),
                    _buildPremiumMenuItem(
                      icon: Iconsax.archive_book,
                      title: "Saved Items",
                      subtitle: "Your spiritual vault",
                      color: PremiumTokens.nebulaBlue,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SavedItemsScreen()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPremiumMenuItem(
                      icon: Iconsax.clock,
                      title: "Journey History",
                      subtitle: "Continue your reflections",
                      color: Colors.blueAccent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ReadingHistoryScreen()),
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildPremiumSectionTitle("Preferences & Self"),
                    const SizedBox(height: 16),
                    _buildPremiumMenuItem(
                      icon: Iconsax.setting_2,
                      title: "Settings",
                      subtitle: "Notifications & Account",
                      color: Colors.purpleAccent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SettingsScreen()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPremiumMenuItem(
                      icon: Iconsax.info_circle,
                      title: "About Divine Path",
                      subtitle: "Vision & Mission",
                      color: Colors.tealAccent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AboutScreen()),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Premium Logout
                    Center(
                      child: TextButton.icon(
                        onPressed: () => _handleLogout(context, ref),
                        icon: Icon(Iconsax.logout, color: Colors.white24, size: 20),
                        label: Text(
                          "Sign Out from Path",
                          style: GoogleFonts.outfit(color: Colors.white24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    const SizedBox(height: 120),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: PremiumTokens.nebulaBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white38,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumMenuItem({
    IconData? icon,
    String? customIconFile,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return PremiumUI.voidCard(
      padding: const EdgeInsets.all(12),
      child: ListTile(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: customIconFile != null
              ? PremiumUI.customIcon(fileName: customIconFile, color: color, size: 22)
              : Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.manrope(color: Colors.white38, fontSize: 13),
        ),
        trailing: const Icon(Iconsax.arrow_right_3, color: Colors.white12, size: 18),
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PremiumTokens.charcoal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Colors.white10)),
        title: Text("Spiritual Rest?", style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to pause your journey for now?", style: GoogleFonts.manrope(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Continue")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authServiceProvider).signOut();
            },
            child: const Text("Sign Out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _PremiumProfileHeader extends ConsumerWidget {
  final User? user;

  const _PremiumProfileHeader({required this.user});

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return "${(count / 1000).toStringAsFixed(1)}k";
    return "${(count / 1000000).toStringAsFixed(1)}m";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final japCount = ref.watch(naamJapStateProvider);
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 24,
        right: 24,
        bottom: 40,
      ),
      child: Column(
        children: [
          // Elegant Avatar with Evolving Aura
          Container(
            padding: const EdgeInsets.all(4),
            decoration: PremiumTokens.evolvingAura(
              color: PremiumTokens.nebulaBlue,
              intensity: 0.7,
            ),
            child: Container(
              width: 120,
              height: 120,
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(shape: BoxShape.circle,
                gradient: PremiumTokens.nebulaGradient,
              ),
              child: Container(
                decoration: const BoxDecoration(shape: BoxShape.circle, color: PremiumTokens.charcoal),
                child: user?.photoURL != null
                    ? PremiumUI.networkImage(
                        url: user!.photoURL!,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(60),
                      )
                    : const Icon(Iconsax.user, color: Colors.white24, size: 48),
              ),
            ),
          ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack),
          
          const SizedBox(height: 24),
          
          Text(
            user?.displayName ?? "Dedicated Seeker",
            style: GoogleFonts.manrope(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          
          PremiumUI.glassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            borderRadius: 100,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Iconsax.sms, color: PremiumTokens.nebulaBlue, size: 14),
                const SizedBox(width: 8),
                  Text(
                    user?.email ?? "Exploring the Path",
                    style: GoogleFonts.manrope(color: Colors.white70, fontSize: 13),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Journey Overview Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStat("Streaks", "21d", PremiumTokens.nebulaBlue),
              const SizedBox(width: 24),
              _buildStat("Japs", _formatCount(japCount), PremiumTokens.celestialGlow),
              const SizedBox(width: 24),
              _buildStat("Level", "Orbit 4", Colors.tealAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.manrope(
            color: color.withValues(alpha: 0.7),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
