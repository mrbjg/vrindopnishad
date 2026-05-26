import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design_system.dart';
import '../core/auth_provider.dart';
import 'profile/saved_items_screen.dart';
import 'profile/reading_history_screen.dart';
import 'profile/settings_screen.dart';
import 'profile/about_screen.dart';
import 'journal_screen.dart';
import 'admin_dashboard.dart';
import '../widgets/sacred_logout_dialog.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import '../core/stats_provider.dart';
import '../core/color_theme_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final bool isPushed;
  const ProfileScreen({super.key, this.isPushed = false});

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
    // Watch colorPaletteProvider to trigger a rebuild when custom theme changes
    ref.watch(colorPaletteProvider);

    // Sync system status and navigation bar overlay style
    PremiumUI.setSacredStatus();

    final showBg = widget.isPushed;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          if (showBg)
            Positioned.fill(
              child: PremiumUI.masterBackground(index: 4, context: context),
            ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Premium Header
              SliverToBoxAdapter(
                child: _PremiumProfileHeader(user: user, isPushed: widget.isPushed),
              ),

              // Menu Sections
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 16),

                    _buildPremiumSectionTitle("Your Sacred Collection"),
                    const SizedBox(height: 16),
                    _buildPremiumMenuItem(
                      icon: Iconsax.edit_2,
                      title: "Journal Reflections",
                      subtitle: "Your spiritual diary",
                      color: PremiumTokens.activeAccent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EternalReflectionScreen(showBackButton: true)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPremiumMenuItem(
                      icon: Iconsax.heart,
                      title: "Saved Items",
                      subtitle: "Your spiritual vault",
                      color: PremiumTokens.activeAccent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SavedItemsScreen()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPremiumMenuItem(
                      icon: Iconsax.clock,
                      title: "Reading History",
                      subtitle: "Continue your reflections",
                      color: PremiumTokens.activeAccent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReadingHistoryScreen()),
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildPremiumSectionTitle("Preferences & Self"),
                    const SizedBox(height: 16),
                    _buildPremiumMenuItem(
                      icon: Iconsax.setting_2,
                      title: "Settings",
                      subtitle: "Notifications & Account",
                      color: PremiumTokens.activeAccent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPremiumMenuItem(
                      icon: Iconsax.info_circle,
                      title: "About Divine Path",
                      subtitle: "Vision & Mission",
                      color: PremiumTokens.activeAccent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPremiumMenuItem(
                      icon: Iconsax.shield_tick,
                      title: "Admin Dashboard",
                      subtitle: "Content & User Management",
                      color: PremiumTokens.activeAccent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminDashboard()),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Premium Logout
                    Center(
                      child: TextButton.icon(
                        onPressed: () => _handleLogout(context, ref),
                        icon: Icon(Iconsax.logout, color: PremiumTokens.textMuted, size: 20),
                        label: Text(
                          "Sign Out from Path",
                          style: GoogleFonts.outfit(color: PremiumTokens.textMuted, fontWeight: FontWeight.bold),
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
            color: PremiumTokens.textMuted,
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: PremiumTokens.textMuted,
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
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            style: GoogleFonts.manrope(color: PremiumTokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.manrope(color: PremiumTokens.textMuted, fontSize: 13),
          ),
          trailing: Icon(Iconsax.arrow_right_3, color: PremiumTokens.textMuted, size: 18),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    SacredLogoutDialog.show(
      context,
      onLogout: () => ref.read(authServiceProvider).signOut(),
    );
  }
}

class _PremiumProfileHeader extends ConsumerWidget {
  final User? user;
  final bool isPushed;

  const _PremiumProfileHeader({required this.user, required this.isPushed});

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return "${(count / 1000).toStringAsFixed(1)}k";
    return "${(count / 1000000).toStringAsFixed(1)}m";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(colorPaletteProvider);
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 24,
        right: 24,
        bottom: 40,
      ),
      child: Column(
        children: [
          // Back Button (if pushed)
          if (isPushed && Navigator.canPop(context))
            Align(
              alignment: Alignment.topLeft,
              child: PremiumUI.glassCard(
                padding: const EdgeInsets.all(4),
                borderRadius: 100,
                child: IconButton(
                  icon: Icon(
                    Iconsax.arrow_left,
                    color: PremiumTokens.textPrimary,
                    size: 20,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          
          const SizedBox(height: 8),

          // Elegant Avatar with Evolving Aura
          Container(
            padding: const EdgeInsets.all(4),
            decoration: PremiumTokens.evolvingAura(
              color: PremiumTokens.textPrimary,
              intensity: 0.5,
            ),
            child: Container(
              width: 120,
              height: 120,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: PremiumTokens.activeGradient,
              ),
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: PremiumTokens.surfaceMain),
                child: user?.photoURL != null
                    ? PremiumUI.networkImage(
                        url: user!.photoURL!,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(60),
                      )
                    : Icon(Iconsax.user, color: PremiumTokens.textMuted, size: 48),
              ),
            ),
          ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack),
          
          const SizedBox(height: 24),
          
          Text(
            user?.displayName ?? "Dedicated Seeker",
            style: GoogleFonts.manrope(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: PremiumTokens.textPrimary,
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
                Icon(Iconsax.sms, color: PremiumTokens.activeAccent, size: 14),
                const SizedBox(width: 8),
                  Text(
                    user?.email ?? "Exploring the Path",
                    style: GoogleFonts.manrope(color: PremiumTokens.textSecondary, fontSize: 13),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Journey Overview Stats
          Consumer(
            builder: (context, ref, child) {
              final statsAsync = ref.watch(userStatsProvider);
              return statsAsync.when(
                data: (stats) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStat("Japs", _formatCount(stats?.totalJapCount ?? 0), PremiumTokens.textSecondary),
                  ],
                ),
                loading: () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStat("Japs", "--", PremiumTokens.celestialGlow),
                  ],
                ),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
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
            color: PremiumTokens.textPrimary,
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
