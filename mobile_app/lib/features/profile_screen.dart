import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import 'profile/saved_items_screen.dart';
import 'profile/reading_history_screen.dart';
import 'profile/settings_screen.dart';
import 'profile/about_screen.dart';
import 'admin_dashboard.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Premium Curved gradient header with glassmorphism
          SliverToBoxAdapter(
            child: Container(
              height: 360,
              decoration: BoxDecoration(
                gradient: isDark
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1A1A2E),
                          const Color(0xFF16213E),
                          AppTheme.glowPurple.withOpacity(0.3),
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFFEF3C7),
                          const Color(0xFFFBD38D),
                          AppTheme.primaryColor.withOpacity(0.6),
                        ],
                      ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(48),
                  bottomRight: Radius.circular(48),
                ),
              ),
              child: Stack(
                children: [
                  // Decorative animated elements
                  Positioned(
                    top: -40,
                    right: -40,
                    child:
                        Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.15),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            )
                            .animate(onPlay: (c) => c.repeat())
                            .shimmer(duration: 3000.ms, color: Colors.white24),
                  ),
                  Positioned(
                    bottom: 80,
                    left: -30,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.glowPink.withOpacity(0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Profile content
                  SafeArea(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Premium avatar with glow
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: -5,
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                              ),
                              child: CircleAvatar(
                                radius: 52,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                child: const Icon(
                                  LucideIcons.user,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ).animate().fadeIn().scale(
                            begin: const Offset(0.8, 0.8),
                            curve: Curves.easeOutBack,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Devotee",
                            style: GoogleFonts.spectral(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ).animate().fadeIn(delay: 100.ms),
                          const SizedBox(height: 8),
                          // Status badge with glassmorphism
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      LucideIcons.sparkles,
                                      size: 16,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Exploring Vaidik Wisdom",
                                      style: GoogleFonts.outfit(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu items with staggered animations
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Your Collection Section
                _buildMenuSection(context, "Your Collection", [
                  _buildGlassListTile(
                    context,
                    LucideIcons.bookmark,
                    "Saved Items",
                    "Your personal collection",
                    [AppTheme.primaryColor, AppTheme.primaryDark],
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SavedItemsScreen(),
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.05),
                  const SizedBox(height: 12),
                  _buildGlassListTile(
                    context,
                    LucideIcons.clock,
                    "Reading History",
                    "Continue where you left off",
                    [AppTheme.glowBlue, const Color(0xFF60A5FA)],
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReadingHistoryScreen(),
                      ),
                    ),
                  ).animate().fadeIn(delay: 350.ms).slideX(begin: 0.05),
                ]),
                const SizedBox(height: 28),

                // Preferences Section
                _buildMenuSection(context, "Preferences", [
                  _buildGlassListTile(
                    context,
                    LucideIcons.sliders,
                    "Settings",
                    "Notifications, Theme, Account",
                    [AppTheme.glowPurple, const Color(0xFFA78BFA)],
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.05),
                  const SizedBox(height: 12),
                  _buildGlassListTile(
                    context,
                    LucideIcons.info,
                    "About Sant-Vaani",
                    "Our mission and vision",
                    [AppTheme.glowTeal, const Color(0xFF2DD4BF)],
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutScreen(),
                      ),
                    ),
                  ).animate().fadeIn(delay: 450.ms).slideX(begin: 0.05),
                ]),
                const SizedBox(height: 28),

                // Admin Section
                _buildMenuSection(context, "Admin", [
                  _buildGlassListTile(
                    context,
                    LucideIcons.command,
                    "Admin Dashboard",
                    "Add or manage sacred content",
                    [AppTheme.glowPink, const Color(0xFFF472B6)],
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminDashboard(),
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.05),
                ]),
                const SizedBox(height: 28),

                // Logout button with special styling
                _buildLogoutButton(
                  context,
                ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.05),

                const SizedBox(height: 100), // Bottom nav padding
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 14),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppTheme.primaryColor, AppTheme.glowPurple],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted(context),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildGlassListTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    List<Color> gradientColors,
    VoidCallback onTap,
  ) {
    final isDark = AppTheme.isDark(context);

    return PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.04),
                width: 1.5,
              ),
              boxShadow: AppTheme.softShadow(context),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Gradient icon container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors[0].withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppTheme.textPrimary(context),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.outfit(
                            color: AppTheme.textMuted(context),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      LucideIcons.chevronRight,
                      size: 18,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return PressableScale(
      onTap: () => _showLogoutDialog(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.red.withOpacity(0.1)
                  : Colors.red.withOpacity(0.05),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.red.withOpacity(0.15),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.red, Colors.red.shade400],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      LucideIcons.logOut,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "Logout",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      LucideIcons.chevronRight,
                      size: 18,
                      color: Colors.red.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1A1A2E).withOpacity(0.95)
                    : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.logOut,
                      color: Colors.red,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Logout",
                    style: GoogleFonts.spectral(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Are you sure you want to logout?",
                    style: GoogleFonts.outfit(
                      color: AppTheme.textMuted(context),
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: PressableScale(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor(context),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                "Cancel",
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary(context),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PressableScale(
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      LucideIcons.check,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "Logged out successfully",
                                      style: GoogleFonts.outfit(),
                                    ),
                                  ],
                                ),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.red, Colors.red.shade400],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "Logout",
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
