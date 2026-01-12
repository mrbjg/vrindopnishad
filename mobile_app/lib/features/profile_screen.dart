import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import '../core/auth_provider.dart';
import 'profile/saved_items_screen.dart';
import 'profile/reading_history_screen.dart';
import 'profile/settings_screen.dart';
import 'profile/about_screen.dart';
// import 'admin_dashboard.dart'; // Removed admin from profile
import 'package:flutter_animate/flutter_animate.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final isDark = AppTheme.isDark(context);
    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0F)
          : const Color(0xFFF5F3F0),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Optimized Header
          SliverToBoxAdapter(
            child: RepaintBoundary(
              child: _ProfileHeader(user: user, isDark: isDark),
            ),
          ),

          // Glass Menu Items
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionTitle(context, "Your Collection", isDark),
                const SizedBox(height: 14),
                _buildGlassMenuItem(
                  context,
                  icon: LucideIcons.bookmark,
                  title: "Saved Items",
                  subtitle: "Your personal collection",
                  gradientColors: [AppTheme.primaryColor, AppTheme.primaryDark],
                  isDark: isDark,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SavedItemsScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                _buildGlassMenuItem(
                  context,
                  icon: LucideIcons.clock,
                  title: "Reading History",
                  subtitle: "Continue where you left off",
                  gradientColors: [AppTheme.glowBlue, const Color(0xFF60A5FA)],
                  isDark: isDark,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReadingHistoryScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                _buildSectionTitle(context, "Preferences", isDark),
                const SizedBox(height: 14),
                _buildGlassMenuItem(
                  context,
                  icon: LucideIcons.settings,
                  title: "Settings",
                  subtitle: "Notifications, Theme, Account",
                  gradientColors: [
                    AppTheme.glowPurple,
                    const Color(0xFFA78BFA),
                  ],
                  isDark: isDark,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                _buildGlassMenuItem(
                  context,
                  icon: LucideIcons.info,
                  title: "About Sant-Vaani",
                  subtitle: "Our mission and vision",
                  gradientColors: [AppTheme.glowTeal, const Color(0xFF2DD4BF)],
                  isDark: isDark,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  ),
                ),
                const SizedBox(height: 28),

                // Admin section removed

                // Glass Logout Button
                _buildGlassLogoutButton(context, ref, isDark),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, bool isDark) {
    return Row(
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
          title.toUpperCase(),
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white60 : Colors.black54,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return RepaintBoundary(
      child: PressableScale(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.white.withOpacity(0.35),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(isDark ? 0.12 : 0.5),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
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
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 20,
                color: isDark
                    ? Colors.white.withOpacity(0.4)
                    : Colors.black.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassLogoutButton(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
  ) {
    return RepaintBoundary(
      child: PressableScale(
        onTap: () => _showGlassLogoutDialog(context, ref, isDark),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(isDark ? 0.1 : 0.08),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.red.withOpacity(0.3), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.red, Color(0xFFDC2626)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
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
              Icon(
                LucideIcons.chevronRight,
                size: 20,
                color: Colors.red.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGlassLogoutDialog(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
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
                  color: Colors.white.withOpacity(isDark ? 0.15 : 0.5),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
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
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Are you sure you want to logout?",
                    style: GoogleFonts.outfit(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: PressableScale(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                "Cancel",
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: PressableScale(
                          onTap: () async {
                            Navigator.pop(ctx);
                            await ref.read(authServiceProvider).signOut();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(
                                        LucideIcons.check,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        "Logged out successfully",
                                        style: GoogleFonts.outfit(),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.red, Color(0xFFDC2626)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                "Logout",
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontSize: 15,
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

// Separate widget for profile header to optimize rebuilds
class _ProfileHeader extends StatelessWidget {
  final dynamic user;
  final bool isDark;

  const _ProfileHeader({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 24,
        right: 24,
        bottom: 40,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [const Color(0xFFFEF3C7), const Color(0xFFFBD38D)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          // Profile Picture with Animated Glow Ring
          Stack(
            alignment: Alignment.center,
            children: [
              // Animated glow ring
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.glowPurple,
                      AppTheme.glowTeal,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.05, 1.05),
                duration: 2.seconds,
                curve: Curves.easeInOut,
              ),
              // Profile picture container
              Container(
                width: 110,
                height: 110,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF5F3F0),
                ),
                child: ClipOval(
                  child: _getPhotoUrl(user) != null
                      ? CachedNetworkImage(
                          imageUrl: _getPhotoUrl(user)!,
                          fit: BoxFit.cover,
                          memCacheWidth: 220,
                          memCacheHeight: 220,
                          maxWidthDiskCache: 220,
                          maxHeightDiskCache: 220,
                          placeholder: (context, url) => Container(
                            color: isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.05),
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              _buildFallbackAvatar(),
                        )
                      : _buildFallbackAvatar(),
                ),
              ),
            ],
          )
          .animate()
          .fadeIn(duration: 600.ms)
          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 18),
          // Name
          Text(
            _getDisplayName(user) ?? user?.email?.split('@')[0] ?? "Devotee",
            style: GoogleFonts.spectral(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          // Email Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.mail,
                  size: 14,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
                const SizedBox(width: 8),
                Text(
                  user?.email ?? "Exploring Wisdom",
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _getPhotoUrl(dynamic user) {
    if (user == null) return null;
    try {
      // Try Supabase metadata
      final metadata = user.userMetadata;
      if (metadata != null && metadata is Map) {
        return metadata['avatar_url'] ??
            metadata['picture'] ??
            metadata['photo_url'];
      }
      // Fallback for direct property (if any)
      return user.photoURL;
    } catch (_) {
      return null;
    }
  }

  String? _getDisplayName(dynamic user) {
    if (user == null) return null;
    try {
      // Try Supabase metadata
      final metadata = user.userMetadata;
      if (metadata != null && metadata is Map) {
        return metadata['full_name'] ??
            metadata['name'] ??
            metadata['display_name'];
      }
      // Fallback
      return user.displayName;
    } catch (_) {
      return null;
    }
  }

  Widget _buildFallbackAvatar() {
    return Container(
      color: isDark
          ? Colors.white.withOpacity(0.1)
          : Colors.white.withOpacity(0.6),
      child: Icon(
        LucideIcons.user,
        size: 40,
        color: isDark ? Colors.white70 : AppTheme.primaryColor,
      ),
    );
  }
}
