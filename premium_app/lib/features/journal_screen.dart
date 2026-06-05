import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../core/design_system.dart';
import '../core/journal_provider.dart';
import '../core/color_theme_provider.dart';
import '../core/auth_provider.dart';
import '../core/providers.dart';
import '../core/mood_theme_provider.dart';
import '../models/journal_entry.dart';
import '../models/ritual.dart';
import '../models/user_stats.dart';
import '../widgets/animated_effects.dart';
import '../core/rituals_provider.dart';
import '../core/stats_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;

final likedPostsProvider = StateNotifierProvider<LikedPostsNotifier, Set<String>>((ref) {
  return LikedPostsNotifier();
});

class LikedPostsNotifier extends StateNotifier<Set<String>> {
  LikedPostsNotifier() : super({}) {
    _load();
  }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('liked_posts') ?? [];
    state = list.toSet();
  }
  Future<void> toggleLike(String postId) async {
    final updated = Set<String>.from(state);
    if (updated.contains(postId)) {
      updated.remove(postId);
    } else {
      updated.add(postId);
    }
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('liked_posts', updated.toList());
  }
}

final savedPostsProvider = StateNotifierProvider<SavedPostsNotifier, Set<String>>((ref) {
  return SavedPostsNotifier();
});

class SavedPostsNotifier extends StateNotifier<Set<String>> {
  SavedPostsNotifier() : super({}) {
    _load();
  }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('saved_posts') ?? [];
    state = list.toSet();
  }
  Future<void> toggleSave(String postId) async {
    final updated = Set<String>.from(state);
    if (updated.contains(postId)) {
      updated.remove(postId);
    } else {
      updated.add(postId);
    }
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_posts', updated.toList());
  }
}

final likedCommentsProvider = StateNotifierProvider<LikedCommentsNotifier, Set<String>>((ref) {
  return LikedCommentsNotifier();
});

class LikedCommentsNotifier extends StateNotifier<Set<String>> {
  LikedCommentsNotifier() : super({}) {
    _load();
  }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('liked_comments') ?? [];
    state = list.toSet();
  }
  Future<void> toggleLike(String commentId) async {
    final updated = Set<String>.from(state);
    if (updated.contains(commentId)) {
      updated.remove(commentId);
    } else {
      updated.add(commentId);
    }
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('liked_comments', updated.toList());
  }
}

final likedMessagesProvider = StateNotifierProvider<LikedMessagesNotifier, Set<String>>((ref) {
  return LikedMessagesNotifier();
});

class LikedMessagesNotifier extends StateNotifier<Set<String>> {
  LikedMessagesNotifier() : super({}) {
    _load();
  }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('liked_messages') ?? [];
    state = list.toSet();
  }
  Future<void> toggleLike(String messageId) async {
    final updated = Set<String>.from(state);
    if (updated.contains(messageId)) {
      updated.remove(messageId);
    } else {
      updated.add(messageId);
    }
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('liked_messages', updated.toList());
  }
}

String? _getYoutubeId(String url) {
  final cleanUrl = url.trim();
  if (cleanUrl.isEmpty) return null;

  // 1. Check for standard patterns
  final regExp = RegExp(
    r'^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*',
    caseSensitive: false,
  );
  final match = regExp.firstMatch(cleanUrl);
  if (match != null && match.groupCount >= 2) {
    final id = match.group(2);
    if (id != null && id.length == 11) {
      return id;
    }
  }

  // 2. Check for /live/ID pattern
  final liveRegExp = RegExp(
    r'youtube\.com/live/([^#\&\?]{11})',
    caseSensitive: false,
  );
  final liveMatch = liveRegExp.firstMatch(cleanUrl);
  if (liveMatch != null && liveMatch.groupCount >= 1) {
    return liveMatch.group(1);
  }

  // 3. Check for /shorts/ID pattern
  final shortsRegExp = RegExp(
    r'youtube\.com/shorts/([^#\&\?]{11})',
    caseSensitive: false,
  );
  final shortsMatch = shortsRegExp.firstMatch(cleanUrl);
  if (shortsMatch != null && shortsMatch.groupCount >= 1) {
    return shortsMatch.group(1);
  }

  return null;
}

bool _checkGoLiveEligibility({
  required User? user,
  required int todayJaps,
  required List<Ritual> rituals,
  required List<ReadingHistoryItem> readings,
}) {
  if (user == null) return false;
  
  // Developer/Admin override: always allow
  final email = user.email?.toLowerCase() ?? '';
  if (email.contains('admin') ||
      email.contains('developer') ||
      email.contains('dev') ||
      user.uid == 'admin' ||
      user.uid == 'developer') {
    return true;
  }
  
  // Regular criteria:
  // 1. Daily Malas: >= 108 chants (1 Mala)
  final hasCompletedMala = todayJaps >= 108;
  
  // 2. Daily Rituals: at least 1 completed ritual
  final hasCompletedRitual = rituals.any((r) => r.isCompleted == true);
  
  // 3. Daily Readings: at least 1 shloka read today
  final now = DateTime.now();
  final hasReadToday = readings.any((item) {
    return item.readAt.year == now.year &&
           item.readAt.month == now.month &&
           item.readAt.day == now.day;
  });
  
  return hasCompletedMala && hasCompletedRitual && hasReadToday;
}

void _showGoLiveEligibilityChecklist({
  required BuildContext context,
  required int todayJaps,
  required int completedRituals,
  required int totalRituals,
  required bool readToday,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: PremiumTokens.sheetBgTop.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: PremiumTokens.borderSubtle),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Iconsax.lock, color: Colors.orangeAccent, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      "LIVE HOSTING CRITERIA",
                      style: PremiumTokens.displayStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "To ensure the Satsang Room remains a highly sanctified space, the algorithm allows seekers to host only when daily spiritual disciplines are complete.",
                  style: PremiumTokens.sansStyle(fontSize: 11, color: PremiumTokens.textMuted).copyWith(height: 1.4),
                ),
                const SizedBox(height: 20),
                
                // Mala checklist item
                _buildChecklistItem(
                  title: "Daily Malas Chanted",
                  subtitle: "$todayJaps / 108 chants completed today",
                  isCompleted: todayJaps >= 108,
                ),
                const Divider(height: 24, color: Colors.white10),
                
                // Ritual checklist item
                _buildChecklistItem(
                  title: "Daily Spiritual Rituals",
                  subtitle: "$completedRituals / $totalRituals rituals done today",
                  isCompleted: completedRituals >= 1,
                ),
                const Divider(height: 24, color: Colors.white10),
                
                // Reading checklist item
                _buildChecklistItem(
                  title: "Daily Sacred Readings",
                  subtitle: readToday ? "Completed daily reading" : "Read at least 1 shloka to complete",
                  isCompleted: readToday,
                ),
                const SizedBox(height: 24),
                
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PremiumTokens.activeAccent,
                      foregroundColor: PremiumTokens.onAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text("ACKNOWLEDGE", style: PremiumTokens.sansStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildChecklistItem({
  required String title,
  required String subtitle,
  required bool isCompleted,
}) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isCompleted ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isCompleted ? Icons.check : Icons.close,
          color: isCompleted ? Colors.greenAccent : Colors.redAccent,
          size: 16,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: PremiumTokens.sansStyle(fontSize: 13, fontWeight: FontWeight.bold, color: PremiumTokens.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: PremiumTokens.sansStyle(fontSize: 10, color: PremiumTokens.textMuted),
            ),
          ],
        ),
      ),
    ],
  );
}

class _GoLiveBroadcasterDialog extends ConsumerStatefulWidget {
  const _GoLiveBroadcasterDialog();

  @override
  ConsumerState<_GoLiveBroadcasterDialog> createState() => _GoLiveBroadcasterDialogState();
}

class _GoLiveBroadcasterDialogState extends ConsumerState<_GoLiveBroadcasterDialog> {
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  String? _youtubeId;

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _parseUrl(String url) {
    final id = _getYoutubeId(url.trim());
    setState(() {
      _youtubeId = id;
    });
  }

  void _submit() {
    final title = _titleController.text.trim();
    final url = _urlController.text.trim();
    if (title.isEmpty || url.isEmpty || _youtubeId == null) {
      PremiumUI.showNotification(context, "Please enter a valid title and YouTube video link", color: Colors.redAccent);
      return;
    }

    AppHapticFeedback.heavyImpact();
    // Publish a new katha post to the database
    ref.read(journalProvider.notifier).addPost(
      title,
      url,
    );

    Navigator.pop(context);
    PremiumUI.showNotification(context, "You are now LIVE hosting the Satsang Room!", color: PremiumTokens.activeAccent);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: PremiumTokens.sheetBgTop.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: PremiumTokens.borderSubtle),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Iconsax.video_play, color: PremiumTokens.activeAccent, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    "GO LIVE & HOST KATHA",
                    style: PremiumTokens.displayStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Host a devotional video stream for the entire community in real-time.",
                style: PremiumTokens.sansStyle(fontSize: 11, color: PremiumTokens.textMuted),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                style: PremiumTokens.sansStyle(color: PremiumTokens.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText: "Enter Stream Topic (e.g. Nectar Pastimes of Shri Radha)",
                  hintStyle: PremiumTokens.sansStyle(color: PremiumTokens.textMuted, fontSize: 12),
                  labelText: "STREAM TITLE",
                  labelStyle: PremiumTokens.sansStyle(color: PremiumTokens.activeAccent, fontSize: 10, fontWeight: FontWeight.bold),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: PremiumTokens.borderSubtle)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: PremiumTokens.activeAccent)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _urlController,
                onChanged: _parseUrl,
                style: PremiumTokens.sansStyle(color: PremiumTokens.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText: "Enter YouTube Video or Live link",
                  hintStyle: PremiumTokens.sansStyle(color: PremiumTokens.textMuted, fontSize: 12),
                  labelText: "YOUTUBE URL",
                  labelStyle: PremiumTokens.sansStyle(color: PremiumTokens.activeAccent, fontSize: 10, fontWeight: FontWeight.bold),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: PremiumTokens.borderSubtle)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: PremiumTokens.activeAccent)),
                ),
              ),
              if (_youtubeId != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    "https://img.youtube.com/vi/$_youtubeId/hqdefault.jpg",
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("CANCEL", style: PremiumTokens.sansStyle(color: PremiumTokens.textMuted, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PremiumTokens.activeAccent,
                      foregroundColor: PremiumTokens.onAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text("GO LIVE NOW", style: PremiumTokens.sansStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class EternalReflectionScreen extends ConsumerStatefulWidget {
  final bool showBackButton;

  const EternalReflectionScreen({super.key, this.showBackButton = false});

  @override
  ConsumerState<EternalReflectionScreen> createState() => _EternalReflectionScreenState();
}

class _EternalReflectionScreenState extends ConsumerState<EternalReflectionScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final Set<String> _playingVideoPostIds = {};
  bool _shouldForceScrollToBottom = false;

  @override
  bool get wantKeepAlive => true;

  bool _isVideoUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('youtube.com') ||
           lower.contains('youtu.be') ||
           lower.endsWith('.mp4') ||
           lower.endsWith('.mov') ||
           lower.endsWith('.m3u8') ||
           lower.endsWith('.webm') ||
           lower.endsWith('.ogg') ||
           lower.contains('.mp4?') ||
           lower.contains('.mov?') ||
           lower.contains('.m3u8?');
  }

  void _showModifyPostOptions(JournalEntry post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: PremiumTokens.sheetBgTop,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: PremiumTokens.borderSubtle),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: PremiumTokens.borderMedium,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "POST OPTIONS",
                style: PremiumTokens.sansStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: PremiumTokens.textPrimary),
              ),
              const SizedBox(height: 16),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Icon(Iconsax.edit, color: PremiumTokens.activeAccent),
                  title: Text("Edit Post", style: PremiumTokens.sansStyle(color: PremiumTokens.textPrimary)),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditPostDialog(post);
                  },
                ),
              ),
              Divider(color: PremiumTokens.borderSubtle),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: const Icon(Iconsax.trash, color: Colors.redAccent),
                  title: Text("Delete Post", style: PremiumTokens.sansStyle(color: Colors.redAccent)),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDeletePost(post);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditPostDialog(JournalEntry post) {
    final editController = TextEditingController(text: post.content);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: PremiumTokens.sheetBgTop.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: PremiumTokens.borderSubtle),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "EDIT POST",
                    style: PremiumTokens.displayStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: editController,
                    maxLines: 4,
                    style: PremiumTokens.sansStyle(color: PremiumTokens.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Edit your realization...",
                      hintStyle: PremiumTokens.sansStyle(color: PremiumTokens.textMuted, fontSize: 12),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: PremiumTokens.borderSubtle), borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: PremiumTokens.activeAccent), borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text("CANCEL", style: PremiumTokens.sansStyle(color: PremiumTokens.textMuted, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () async {
                          final text = editController.text.trim();
                          if (text.isNotEmpty) {
                            AppHapticFeedback.mediumImpact();
                            await ref.read(journalProvider.notifier).updateEntry(post.id, content: text);
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            if (mounted) {
                              PremiumUI.showNotification(context, "Post modified successfully", color: PremiumTokens.activeAccent);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PremiumTokens.activeAccent,
                          foregroundColor: PremiumTokens.onAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        ),
                        child: Text("SAVE", style: PremiumTokens.sansStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDeletePost(JournalEntry post) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: PremiumTokens.sheetBgTop.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: PremiumTokens.borderSubtle),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.trash, color: Colors.redAccent, size: 40),
                  const SizedBox(height: 16),
                  Text(
                    "DELETE POST?",
                    style: PremiumTokens.displayStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Are you sure you want to permanently delete this post? This action cannot be undone.",
                    textAlign: TextAlign.center,
                    style: PremiumTokens.sansStyle(fontSize: 12, color: PremiumTokens.textMuted),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text("CANCEL", style: PremiumTokens.sansStyle(color: PremiumTokens.textMuted, fontWeight: FontWeight.bold)),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          AppHapticFeedback.heavyImpact();
                          await ref.read(journalProvider.notifier).deleteEntry(post.id);
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                          if (mounted) {
                            PremiumUI.showNotification(context, "Post deleted successfully", color: Colors.redAccent);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        ),
                        child: Text("DELETE", style: PremiumTokens.sansStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    PremiumTokens.of(context);
    final entriesAsync = ref.watch(journalProvider);
    ref.watch(themeProvider);
    ref.watch(colorPaletteProvider);
    ref.watch(moodThemeProvider);

    final showBg = widget.showBackButton;

    return Scaffold(
      backgroundColor: showBg ? PremiumTokens.scaffoldBg : Colors.transparent,
      body: Container(
        decoration: showBg
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    PremiumTokens.surfaceMain,
                    PremiumTokens.scaffoldBg,
                  ],
                ),
              )
            : null,
        child: Stack(
          children: [
            // Stardust Background
            if (showBg)
              const Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: StardustPainter(),
                  ),
                ),
              ),

            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Title Header
                  _buildHeader(context),
                  
                  // Tab Selector
                  _buildTabSelector(),

                  // Tab View
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Live Satsang Feed
                        _buildSatsangFeed(entriesAsync),

                        // Tab 2: Live Sangat Chat
                        _buildSangatChat(entriesAsync),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController.animation!,
        builder: (context, _) {
          PremiumTokens.of(context);
          final activeIndex = _tabController.index;
          if (activeIndex != 0) return const SizedBox.shrink();
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: FloatingActionButton(
              onPressed: () {
                AppHapticFeedback.heavyImpact();
                _showPostDialog(context);
              },
              backgroundColor: isDark ? PremiumTokens.voidPure : Colors.white,
              shape: const CircleBorder(),
              elevation: 4,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: PremiumTokens.activeAccent.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Iconsax.add,
                  color: isDark ? PremiumTokens.textPrimary : const Color(0xFF1A1A2E),
                  size: 26,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    if (!widget.showBackButton) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(Iconsax.arrow_left, color: PremiumTokens.textPrimary, size: 24),
            onPressed: () {
              AppHapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: PremiumUI.glassCard(
        padding: const EdgeInsets.all(4),
        borderRadius: 100,
        child: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          splashBorderRadius: BorderRadius.circular(100),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          indicator: BoxDecoration(
            color: PremiumTokens.activeAccent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: PremiumTokens.activeAccent.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          labelColor: PremiumTokens.textPrimary,
          unselectedLabelColor: PremiumTokens.textMuted,
          labelStyle: PremiumTokens.sansStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5),
          unselectedLabelStyle: PremiumTokens.sansStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5),
          tabs: const [
            Tab(text: "LIVE SATSANG"),
            Tab(text: "SANGAT CHAT"),
          ],
        ),
      ),
    );
  }

  Widget _buildSatsangFeed(AsyncValue<List<JournalEntry>> entriesAsync) {
    return entriesAsync.when(
      skipLoadingOnRefresh: true,
      data: (entries) {
        final feedPosts = entries.where((e) {
          final type = e.moonPhase?.split('|').first ?? 'post';
          return type == 'post';
        }).toList();

        return RefreshIndicator(
          color: PremiumTokens.activeAccent,
          backgroundColor: PremiumTokens.surfaceMain,
          onRefresh: () async {
            AppHapticFeedback.mediumImpact();
            await ref.read(journalProvider.notifier).refresh();
          },
          child: ListView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 140),
            itemCount: feedPosts.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildStoriesBar();
              }
              final post = feedPosts[index - 1];
              final parts = post.moonPhase?.split('|') ?? [];
              final videoUrl = parts.length > 1 ? parts[1] : null;
              final avatarUrl = parts.length > 2 ? parts[2] : null;
              final ytId = videoUrl != null ? _getYoutubeId(videoUrl) : null;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildFeedPostCard(post, videoUrl, avatarUrl, ytId),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: ((index - 1) * 50).ms)
                  .slideY(begin: 0.1, end: 0);
            },
          ),
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: PremiumTokens.activeAccent)),
      error: (e, _) => Center(child: Text("Error: $e", style: TextStyle(color: PremiumTokens.textMuted))),
    );
  }

  Widget _buildStoriesBar() {
    final user = ref.watch(authStateProvider).value;
    final entries = ref.watch(journalProvider).value ?? [];
    final readStories = ref.watch(readStoriesProvider);
    final now = DateTime.now();

    // 1. Filter real-time entries for stories and recent posts (last 24 hours)
    final recentEntries = entries.where((e) {
      final type = e.moonPhase?.split('|').first ?? '';
      if (type != 'story' && type != 'post') return false;
      if (e.content.trim().isEmpty) return false;
      
      // Keep guides/system stories always visible, others expire in 24 hours
      if (e.firebaseUid.startsWith('guide-') || e.firebaseUid == 'system') return true;

      return now.difference(e.createdAt).inHours < 24;
    }).toList();

    // 2. Group by user to display only one story bubble per user with their latest realization
    final Map<String, JournalEntry> userLatestStory = {};
    for (final entry in recentEntries.reversed) {
      userLatestStory[entry.firebaseUid] = entry;
    }

    final sortedRealtimeStories = userLatestStory.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // List of stories to display
    final List<Widget> storyItems = [];

    // A. "Your Voice" bubble
    storyItems.add(
      _buildStoryItem(
        name: "Your Voice",
        avatarUrl: user?.photoURL ?? "",
        isMe: true,
        onTap: () {
          AppHapticFeedback.lightImpact();
          _showPostDialog(context);
        },
      ),
    );

    // Check if there is an active live stream
    JournalEntry? activeKatha;
    for (final entry in entries) {
      final type = entry.moonPhase?.split('|').first ?? 'post';
      final parts = entry.moonPhase?.split('|') ?? [];
      final videoUrl = parts.length > 1 ? parts[1] : '';
      if (type == 'post' && videoUrl.isNotEmpty) {
        activeKatha = entry;
        break;
      }
    }

    final hasActiveKatha = activeKatha != null;
    final String liveAvatar = hasActiveKatha
        ? (activeKatha.moonPhase!.split('|').length > 2 ? activeKatha.moonPhase!.split('|')[2] : '')
        : '';

    // B. "Satsang Room" (dynamic LIVE status) bubble
    storyItems.add(
      _buildStoryItem(
        name: hasActiveKatha ? "LIVE" : "Satsang",
        avatarUrl: hasActiveKatha && liveAvatar.isNotEmpty
            ? liveAvatar
            : "https://images.unsplash.com/photo-1545127398-14699f92334b", // Peaceful satsang assembly fallback image
        isLive: hasActiveKatha,
        onTap: () {
          AppHapticFeedback.heavyImpact();
          _showLiveOptionsSheet(context);
        },
      ),
    );

    // C. Real-time stories from database
    for (final story in sortedRealtimeStories) {

      final parts = story.moonPhase?.split('|') ?? [];
      final type = parts.first;
      String actualAvatar = "";
      if (type == 'story') {
        actualAvatar = parts.length > 2 ? parts[2] : (parts.length > 1 ? parts[1] : "");
      } else {
        actualAvatar = parts.length > 2 ? parts[2] : "";
      }

      final isRead = readStories.contains(story.id);

      storyItems.add(
        _buildStoryItem(
          name: story.title.isEmpty ? "Seeker" : story.title,
          avatarUrl: actualAvatar,
          isRead: isRead,
          onTap: () {
            ref.read(readStoriesProvider.notifier).markAsRead(story.id);
            final videoUrl = parts.length > 1 && parts[1].isNotEmpty ? parts[1] : null;
            _showStoryViewer(
              context,
              story.title.isEmpty ? "Seeker" : story.title,
              actualAvatar,
              story.content,
              false,
              videoUrl: videoUrl,
            );
          },
        ),
      );
    }

    return Container(
      height: 98,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: storyItems,
      ),
    );
  }

  void _showLiveOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final user = ref.watch(authStateProvider).value;
            final todayJaps = ref.watch(naamJapStateProvider).today;
            final ritualsVal = ref.watch(ritualsProvider).value ?? [];
            final readingsVal = ref.watch(readingHistoryProvider).value ?? [];
            
            final completedRituals = ritualsVal.where((r) => r.isCompleted).length;
            final totalRituals = ritualsVal.length;
            
            final now = DateTime.now();
            final hasReadToday = readingsVal.any((item) {
              return item.readAt.year == now.year &&
                     item.readAt.month == now.month &&
                     item.readAt.day == now.day;
            });
            
            final isEligible = _checkGoLiveEligibility(
              user: user,
              todayJaps: todayJaps,
              rituals: ritualsVal,
              readings: readingsVal,
            );

            return Container(
              decoration: BoxDecoration(
                color: PremiumTokens.sheetBgTop,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: PremiumTokens.borderSubtle),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PremiumTokens.borderMedium,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(Iconsax.video_play5, color: PremiumTokens.activeAccent, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        "SATSANG ROOM OPTIONS",
                        style: PremiumTokens.displayStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Join the congregation as a listener or host your own live stream once your daily spiritual practices are complete.",
                    style: PremiumTokens.sansStyle(fontSize: 11, color: PremiumTokens.textMuted),
                  ),
                  const SizedBox(height: 24),
                  
                  // Option 1: Join Satsang Room
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Icon(Iconsax.headphone, color: Colors.greenAccent, size: 20),
                      ),
                      title: Text(
                        "Join Satsang Room",
                        style: PremiumTokens.sansStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      subtitle: Text(
                        "Listen to active discourse and chant along",
                        style: PremiumTokens.sansStyle(color: PremiumTokens.textMuted, fontSize: 10),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (_) => const _LiveSatsangRoomSheet(),
                        );
                      },
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 24),

                  // Option 2: Go Live & Host Katha
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isEligible ? PremiumTokens.activeAccent.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Icon(
                          isEligible ? Iconsax.video_play : Iconsax.lock,
                          color: isEligible ? PremiumTokens.activeAccent : Colors.redAccent,
                          size: 20,
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            "Go Live & Host",
                            style: PremiumTokens.sansStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isEligible ? PremiumTokens.textPrimary : PremiumTokens.textMuted,
                            ),
                          ),
                          if (!isEligible) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                "LOCKED",
                                style: PremiumTokens.sansStyle(
                                  fontSize: 7.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.orangeAccent,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        isEligible 
                            ? "Start broadcasting a spiritual video stream" 
                            : "Unlock by completing daily spiritual disciplines",
                        style: PremiumTokens.sansStyle(color: PremiumTokens.textMuted, fontSize: 10),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        if (isEligible) {
                          showDialog(
                            context: context,
                            builder: (_) => const _GoLiveBroadcasterDialog(),
                          );
                        } else {
                          _showGoLiveEligibilityChecklist(
                            context: context,
                            todayJaps: todayJaps,
                            completedRituals: completedRituals,
                            totalRituals: totalRituals,
                            readToday: hasReadToday,
                          );
                        }
                      },
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 24),

                  // Option 3: Check Standing
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Icon(Iconsax.task, color: Colors.orangeAccent, size: 20),
                      ),
                      title: Text(
                        "Check Live Host Eligibility",
                        style: PremiumTokens.sansStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      subtitle: Text(
                        "View your daily spiritual discipline standings",
                        style: PremiumTokens.sansStyle(color: PremiumTokens.textMuted, fontSize: 10),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showGoLiveEligibilityChecklist(
                          context: context,
                          todayJaps: todayJaps,
                          completedRituals: completedRituals,
                          totalRituals: totalRituals,
                          readToday: hasReadToday,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStoryItem({
    required String name,
    required String avatarUrl,
    bool isMe = false,
    bool isLive = false,
    bool isRead = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Glowing border circles
                if (isLive)
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.redAccent, Colors.orangeAccent, Colors.pinkAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withValues(alpha: 0.25),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1.0, 1.0), end: const Offset(1.04, 1.04), duration: 1.seconds)
                else if (!isMe)
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isRead
                          ? LinearGradient(
                              colors: [
                                PremiumTokens.isDark ? Colors.white24 : Colors.black26,
                                PremiumTokens.isDark ? Colors.white10 : Colors.black12,
                              ],
                            )
                          : LinearGradient(
                              colors: [
                                PremiumTokens.activeAccent,
                                PremiumTokens.activeAccent.withValues(alpha: 0.3),
                              ],
                            ),
                    ),
                  ).animate(onPlay: (c) => isRead ? c.stop() : c.repeat(reverse: true)).scale(begin: const Offset(1.0, 1.0), end: const Offset(1.03, 1.03), duration: 1500.ms, curve: Curves.easeInOutSine)
                else
                  Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white12,
                    ),
                  ),
                
                // Outer ring spacing
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black87,
                  ),
                ),
                
                // Actual Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: avatarUrl.isNotEmpty
                        ? PremiumUI.networkImage(url: avatarUrl, fit: BoxFit.cover)
                        : Container(
                            color: PremiumTokens.activeAccent.withValues(alpha: 0.15),
                            alignment: Alignment.center,
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : "S",
                              style: PremiumTokens.sansStyle(
                                color: PremiumTokens.activeAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                  ),
                ),
                
                // Extra badge elements
                if (isMe)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 12),
                    ),
                  ),
                if (isLive)
                  Positioned(
                    bottom: -3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        "LIVE",
                        style: PremiumTokens.sansStyle(fontSize: 6.5, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isMe ? "Your Voice" : name,
              style: PremiumTokens.sansStyle(
                fontSize: 9,
                fontWeight: isLive || isMe ? FontWeight.bold : FontWeight.normal,
                color: isLive ? Colors.redAccent : PremiumTokens.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showStoryViewer(BuildContext context, String username, String avatarUrl, String quote, bool isLive, {String? videoUrl}) {
    AppHapticFeedback.mediumImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.95),
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (ctx, animation, secondaryAnimation) {
          return _StoryViewerPage(
            username: username,
            avatarUrl: avatarUrl,
            quote: quote,
            isLive: isLive,
            videoUrl: videoUrl,
          );
        },
        transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _buildFeedPostCard(JournalEntry post, String? videoUrl, String? avatarUrl, String? ytId) {
    final user = ref.watch(authStateProvider).value;
    final dateStr = "${post.createdAt.day}/${post.createdAt.month} ${post.createdAt.hour}:${post.createdAt.minute.toString().padLeft(2, '0')}";
    final isLiked = post.likedBy.contains(user?.uid ?? '');
    final isSaved = ref.watch(savedPostsProvider).contains(post.id);

    final int displayLikes = post.likedBy.length;

    final isPlayingVideo = _playingVideoPostIds.contains(post.id);
    final entries = ref.watch(journalProvider).value ?? [];
    final comments = entries.where((e) {
      final type = e.moonPhase?.split('|').first ?? '';
      final parts = e.moonPhase?.split('|') ?? [];
      return type == 'comment' && parts.length > 1 && parts[1] == post.id;
    }).toList();
    final commentsCount = comments.length;

    final previewComments = comments.length > 2 
        ? comments.sublist(comments.length - 2) 
        : comments;

    final inlineCommentController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onDoubleTap: () {
          AppHapticFeedback.heavyImpact();
          ref.read(journalProvider.notifier).toggleLike(post.id);
        },
        child: PremiumUI.relicStaticCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderColor: PremiumTokens.borderSubtle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Meta Header
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: PremiumTokens.borderSubtle,
                      border: Border.all(color: PremiumTokens.activeAccent.withValues(alpha: 0.2)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: avatarUrl != null && avatarUrl.isNotEmpty
                          ? PremiumUI.networkImage(url: avatarUrl, fit: BoxFit.cover)
                          : Icon(Iconsax.user, size: 16, color: PremiumTokens.activeAccent),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.title.trim().isNotEmpty ? post.title : "Divine Seeker",
                          style: PremiumTokens.sansStyle(
                            color: PremiumTokens.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          dateStr,
                          style: PremiumTokens.sansStyle(
                            color: PremiumTokens.textMuted,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (post.firebaseUid == user?.uid) ...[
                    IconButton(
                      icon: Icon(Icons.more_horiz, color: PremiumTokens.textMuted, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        AppHapticFeedback.lightImpact();
                        _showModifyPostOptions(post);
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (videoUrl != null && videoUrl.isNotEmpty)
                    Icon(Iconsax.video_play5, color: PremiumTokens.activeAccent, size: 20),
                ],
              ),
              const SizedBox(height: 8),

              // Post Text Content
              Text(
                post.content,
                style: PremiumTokens.sansStyle(
                  fontSize: 14,
                  color: PremiumTokens.textSecondary,
                ).copyWith(height: 1.5),
              ),

            // Render playable video preview card if youtube video exists
            if (isPlayingVideo) ...[
              const SizedBox(height: 14),
              _InlineVideoPlayer(videoUrl: videoUrl ?? '', ytId: ytId),
            ] else if (ytId != null) ...[
              const SizedBox(height: 14),
              PressableScale(
                onTap: () {
                  AppHapticFeedback.mediumImpact();
                  setState(() {
                    _playingVideoPostIds.add(post.id);
                  });
                },
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.black45,
                    border: Border.all(color: PremiumTokens.borderSubtle),
                    image: DecorationImage(
                      image: NetworkImage("https://img.youtube.com/vi/$ytId/0.jpg"),
                      fit: BoxFit.cover,
                      opacity: 0.8,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                          ),
                        ),
                      ),
                      Icon(
                        Icons.play_circle_fill,
                        color: PremiumTokens.activeAccent,
                        size: 50,
                      ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Row(
                          children: [
                            const Icon(Iconsax.link, color: Colors.white70, size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                videoUrl ?? '',
                                style: PremiumTokens.sansStyle(color: Colors.white70, fontSize: 10),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (videoUrl != null && videoUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              if (_isVideoUrl(videoUrl)) ...[
                if (isPlayingVideo)
                  _InlineVideoPlayer(videoUrl: videoUrl)
                else
                  PressableScale(
                    onTap: () {
                      AppHapticFeedback.mediumImpact();
                      setState(() {
                        _playingVideoPostIds.add(post.id);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: PremiumTokens.isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : PremiumTokens.activeAccent.withValues(alpha: 0.06),
                        border: Border.all(
                          color: PremiumTokens.activeAccent.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Left circular glowing icon
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  PremiumTokens.activeAccent,
                                  PremiumTokens.activeAccent.withValues(alpha: 0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: PremiumTokens.activeAccent.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              videoUrl.contains('list=') ? Iconsax.music_playlist : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Text descriptions
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  videoUrl.contains('list=') ? "Play YouTube Playlist Natively" : "Play Video Stream Natively",
                                  style: PremiumTokens.sansStyle(
                                    color: PremiumTokens.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  videoUrl,
                                  style: PremiumTokens.sansStyle(
                                    color: PremiumTokens.textSecondary,
                                    fontSize: 10,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Subtle arrow icon
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: PremiumTokens.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
              ] else ...[
                // Standard web link decoration (non-video)
                GestureDetector(
                  onTap: () {
                    AppHapticFeedback.lightImpact();
                    Clipboard.setData(ClipboardData(text: videoUrl));
                    PremiumUI.showNotification(context, "URL copied to clipboard");
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: PremiumTokens.borderSubtle.withValues(alpha: 0.3),
                      border: Border.all(color: PremiumTokens.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.link, color: PremiumTokens.activeAccent, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            videoUrl,
                            style: PremiumTokens.sansStyle(color: PremiumTokens.activeAccent, fontSize: 11, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],

              // Action row (Instagram style)
              const SizedBox(height: 8),
              Divider(color: PremiumTokens.borderSubtle, height: 0.5),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Heart Like Button
                  PressableScale(
                    onTap: () {
                      AppHapticFeedback.mediumImpact();
                      ref.read(journalProvider.notifier).toggleLike(post.id);
                    },
                    child: Icon(
                      isLiked ? Icons.favorite : Iconsax.heart,
                      color: isLiked ? Colors.redAccent : PremiumTokens.textMuted,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Comment Button
                  PressableScale(
                    onTap: () {
                      AppHapticFeedback.lightImpact();
                      _showCommentsSheet(post);
                    },
                    child: Icon(
                      Iconsax.message,
                      color: PremiumTokens.textMuted,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Share Button (Paper Airplane)
                  PressableScale(
                    onTap: () async {
                      AppHapticFeedback.mediumImpact();
                      await SharePlus.instance.share(ShareParams(text: "🕉️ ${post.title} 🕉️\n\n${post.content}\n\n— Shared from Sant-Vaani (Vrindopnishad) 🙏\n📲 Join the satsang: https://vrindopnishad.in"));
                    },
                    child: Icon(
                      Iconsax.send_1,
                      color: PremiumTokens.textMuted,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  
                  // Bookmark/Save Button
                  PressableScale(
                    onTap: () {
                      AppHapticFeedback.mediumImpact();
                      ref.read(savedPostsProvider.notifier).toggleSave(post.id);
                      PremiumUI.showNotification(
                        context,
                        isSaved ? "Realization removed from bookmarks" : "Realization saved to bookmarks",
                        icon: isSaved ? Icons.bookmark_border : Icons.bookmark,
                        color: PremiumTokens.activeAccent,
                      );
                    },
                    child: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? PremiumTokens.activeAccent : PremiumTokens.textMuted,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Likes count text
              Text(
                "Liked by gopal_das and $displayLikes others",
                style: PremiumTokens.sansStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: PremiumTokens.textPrimary,
                ),
              ),
              
              // Inline preview of the last 2 comments
              if (previewComments.isNotEmpty) ...[
                const SizedBox(height: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: previewComments.map((comment) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: RichText(
                        text: TextSpan(
                          style: PremiumTokens.sansStyle(fontSize: 12, color: PremiumTokens.textPrimary),
                          children: [
                            TextSpan(
                              text: "${comment.title}  ",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: comment.content,
                              style: TextStyle(color: PremiumTokens.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              if (commentsCount > 2) ...[
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: () => _showCommentsSheet(post),
                  child: Text(
                    "View all $commentsCount comments",
                    style: PremiumTokens.sansStyle(
                      fontSize: 11,
                      color: PremiumTokens.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 6),
              // Inline comment composer
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: inlineCommentController,
                      style: PremiumTokens.sansStyle(color: PremiumTokens.textPrimary, fontSize: 12.5),
                      decoration: InputDecoration(
                        hintText: "Add comment inline...",
                        hintStyle: PremiumTokens.sansStyle(color: PremiumTokens.textMuted, fontSize: 12),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      final text = inlineCommentController.text.trim();
                      if (text.isEmpty) return;
                      AppHapticFeedback.lightImpact();
                      final displayName = user?.displayName ?? user?.email?.split('@').first ?? "Divine Seeker";
                      final photoUrl = user?.photoURL ?? "";
                      final moonPhase = "comment|${post.id}|$photoUrl";

                      ref.read(journalProvider.notifier).addEntry(
                        displayName,
                        text,
                        moonPhase: moonPhase,
                      );
                      inlineCommentController.clear();
                      FocusScope.of(context).unfocus();
                    },
                    child: Text(
                      "Post",
                      style: PremiumTokens.sansStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: PremiumTokens.activeAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveRoomBanner() {
    return GestureDetector(
      onTap: () {
        AppHapticFeedback.heavyImpact();
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => const _LiveSatsangRoomSheet(),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: PremiumUI.glassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderRadius: 20,
          opacity: 0.12,
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.5, 1.5),
                    duration: 1.seconds,
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "LIVE SATSANG ROOM",
                          style: PremiumTokens.sansStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "LIVE",
                            style: PremiumTokens.sansStyle(fontSize: 6, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Join Gopal Das & 2.4k seekers chanting now",
                      style: PremiumTokens.sansStyle(
                        fontSize: 11.5,
                        color: PremiumTokens.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: PremiumTokens.textMuted, size: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSangatChat(AsyncValue<List<JournalEntry>> entriesAsync) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const SizedBox.shrink();

    final viewInsets = MediaQuery.of(context).viewInsets;
    final isKeyboardOpen = viewInsets.bottom > 0;

    return Column(
      children: [
        // Live Room Banner at the top of Sangat Chat
        _buildLiveRoomBanner(),

        // Chat messages body
        Expanded(
          child: entriesAsync.when(
            skipLoadingOnRefresh: true,
            data: (entries) {
              final chatMsgs = entries.where((e) {
                final type = e.moonPhase?.split('|').first ?? 'post';
                return type == 'chat';
              }).toList().reversed.toList(); // Oldest first for scrolling down

              if (chatMsgs.isEmpty) {
                return RefreshIndicator(
                  color: PremiumTokens.activeAccent,
                  backgroundColor: PremiumTokens.surfaceMain,
                  onRefresh: () async {
                    AppHapticFeedback.mediumImpact();
                    await ref.read(journalProvider.notifier).refresh();
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: EdgeInsets.fromLTRB(20, 10, 20, isKeyboardOpen ? 80 : 110),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Center(
                          child: Text(
                            "Welcome to Sangat Chat. Say Radhe Radhe!",
                            style: PremiumTokens.sansStyle(color: PremiumTokens.textMuted, fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Auto scroll to bottom under correct conditions
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_chatScrollController.hasClients) {
                  final pos = _chatScrollController.position;
                  final isNearBottom = (pos.maxScrollExtent - pos.pixels) < 200;
                  final isAtZero = pos.pixels == 0;
                  if (isNearBottom || isAtZero || _shouldForceScrollToBottom) {
                    _shouldForceScrollToBottom = false;
                    _chatScrollController.animateTo(
                      pos.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                }
              });

              return RefreshIndicator(
                color: PremiumTokens.activeAccent,
                backgroundColor: PremiumTokens.surfaceMain,
                onRefresh: () async {
                  AppHapticFeedback.mediumImpact();
                  await ref.read(journalProvider.notifier).refresh();
                },
                child: ListView.builder(
                  controller: _chatScrollController,
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: EdgeInsets.fromLTRB(20, 10, 20, isKeyboardOpen ? 80 : 110),
                  itemCount: chatMsgs.length,
                  itemBuilder: (context, index) {
                    final msg = chatMsgs[index];
                    final isMe = msg.firebaseUid == user.uid;
                    final parts = msg.moonPhase?.split('|') ?? [];
                    final avatarUrl = parts.length > 1 ? parts[1] : null;

                    // Consecutive bubble grouping logic
                    bool isConsecutive = false;
                    if (index > 0) {
                      final prevMsg = chatMsgs[index - 1];
                      final sameSender = msg.firebaseUid == prevMsg.firebaseUid;
                      final timeDiff = msg.createdAt.difference(prevMsg.createdAt).inMinutes.abs();
                      if (sameSender && timeDiff < 3) {
                        isConsecutive = true;
                      }
                    }

                    return _ChatBubble(
                      msg: msg,
                      isMe: isMe,
                      isConsecutive: isConsecutive,
                      avatarUrl: avatarUrl,
                    );
                  },
                ),
              );
            },
            loading: () => Center(child: CircularProgressIndicator(color: PremiumTokens.activeAccent)),
            error: (e, _) => Center(child: Text("Error: $e", style: TextStyle(color: PremiumTokens.textMuted))),
          ),
        ),

        // Composer bar
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, isKeyboardOpen ? 12 : 106),
          child: PremiumUI.glassCard(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            borderRadius: 30,
            opacity: 0.08,
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(
                  Iconsax.message_text,
                  size: 18,
                  color: PremiumTokens.textMuted.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    style: PremiumTokens.sansStyle(color: PremiumTokens.textPrimary, fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: "Send message to Sangat...",
                      hintStyle: PremiumTokens.sansStyle(color: PremiumTokens.textMuted.withValues(alpha: 0.6), fontSize: 12.5),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onSubmitted: (_) => _sendChatMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                PressableScale(
                  onTap: _sendChatMessage,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          PremiumTokens.activeAccent,
                          PremiumTokens.activeAccent.withValues(alpha: 0.85),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: PremiumTokens.activeAccent.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Iconsax.send_1,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _sendChatMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    AppHapticFeedback.lightImpact();

    if (_isYoutubeLive(text)) {
      showDialog(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: PremiumTokens.sheetBgTop.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: PremiumTokens.borderSubtle),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.video_play5, color: Colors.redAccent, size: 40),
                    const SizedBox(height: 16),
                    Text(
                      "LIVE SATSANG DETECTED",
                      style: PremiumTokens.displayStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Do you want to host this live video in the community's Live Satsang Room, or post it as a chat link?",
                      textAlign: TextAlign.center,
                      style: PremiumTokens.sansStyle(fontSize: 12, color: PremiumTokens.textMuted),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            _shouldForceScrollToBottom = true;
                            ref.read(journalProvider.notifier).addChatMessage(text);
                            _chatController.clear();
                          },
                          child: Text("POST TO CHAT", style: PremiumTokens.sansStyle(color: PremiumTokens.textMuted, fontWeight: FontWeight.bold)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            ref.read(journalProvider.notifier).addLivePost("Live Satsang Room", text);
                            _chatController.clear();
                            PremiumUI.showNotification(context, "You are now LIVE in the Satsang Room!", color: PremiumTokens.activeAccent);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          ),
                          child: Text("GO LIVE", style: PremiumTokens.sansStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        }
      );
      return;
    }

    _shouldForceScrollToBottom = true;
    ref.read(journalProvider.notifier).addChatMessage(text);
    _chatController.clear();
  }

  bool _isYoutubeLive(String url) {
    final clean = url.trim().toLowerCase();
    return (clean.contains('youtube.com/live') || clean.contains('/live/')) && (clean.contains('youtube.com') || clean.contains('youtu.be'));
  }

  void _showPostDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => const _SatsangPostComposerSheet(),
    );
  }

void _showCommentsSheet(JournalEntry post) {
    final commentsController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Consumer(
              builder: (context, ref, _) {
                final entriesAsync = ref.watch(journalProvider);
                final comments = entriesAsync.maybeWhen(
                  data: (list) => list.where((e) {
                    final type = e.moonPhase?.split('|').first ?? '';
                    final parts = e.moonPhase?.split('|') ?? [];
                    return type == 'comment' && parts.length > 1 && parts[1] == post.id;
                  }).toList(),
                  orElse: () => <JournalEntry>[],
                );

                final user = ref.read(authStateProvider).value;
                final screenHeight = MediaQuery.of(context).size.height;
                final viewInsets = MediaQuery.of(context).viewInsets;
                final availableHeight = screenHeight - viewInsets.bottom;
                final sheetHeight = math.min(screenHeight * 0.75, availableHeight - 24);

                return Padding(
                  padding: EdgeInsets.only(bottom: viewInsets.bottom),
                  child: Container(
                    decoration: BoxDecoration(
                      color: PremiumTokens.sheetBgTop,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      border: Border.all(color: PremiumTokens.borderSubtle),
                    ),
                    height: sheetHeight,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: PremiumTokens.borderMedium,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "COMMENTS",
                          style: PremiumTokens.sansStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: PremiumTokens.textPrimary),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: comments.isEmpty
                              ? Center(
                                  child: Text(
                                    "No comments yet. Be the first to reply!",
                                    style: PremiumTokens.sansStyle(color: PremiumTokens.textMuted, fontSize: 11),
                                  ),
                                )
                              : RefreshIndicator(
                                  color: PremiumTokens.activeAccent,
                                  backgroundColor: PremiumTokens.surfaceMain,
                                  onRefresh: () async {
                                    AppHapticFeedback.mediumImpact();
                                    await ref.read(journalProvider.notifier).refresh();
                                  },
                                  child: ListView.builder(
                                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                    itemCount: comments.length,
                                    itemBuilder: (context, index) {
                                    final item = comments[index];
                                    final parts = item.moonPhase?.split('|') ?? [];
                                    final avatarUrl = parts.length > 2 ? parts[2] : null;

                                    final duration = DateTime.now().difference(item.createdAt);
                                    String timeAgo = "now";
                                    if (duration.inDays > 0) {
                                      timeAgo = "${duration.inDays}d";
                                    } else if (duration.inHours > 0) {
                                      timeAgo = "${duration.inHours}h";
                                    } else if (duration.inMinutes > 0) {
                                      timeAgo = "${duration.inMinutes}m";
                                    }

                                    final isCommentLiked = item.likedBy.contains(user?.uid ?? '');
                                    final commentLikesCount = item.likedBy.length;

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black26),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: avatarUrl != null && avatarUrl.isNotEmpty
                                                  ? PremiumUI.networkImage(url: avatarUrl, fit: BoxFit.cover)
                                                  : Icon(Iconsax.user, size: 14, color: PremiumTokens.activeAccent),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                    style: PremiumTokens.sansStyle(fontSize: 13, color: PremiumTokens.textPrimary),
                                                    children: [
                                                      TextSpan(
                                                        text: "${item.title}  ",
                                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                      TextSpan(
                                                        text: item.content,
                                                        style: TextStyle(color: PremiumTokens.textSecondary),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    Text(
                                                      timeAgo,
                                                      style: PremiumTokens.sansStyle(fontSize: 10, color: PremiumTokens.textMuted),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    if (commentLikesCount > 0) ...[
                                                      Text(
                                                        "$commentLikesCount ${commentLikesCount == 1 ? 'like' : 'likes'}",
                                                        style: PremiumTokens.sansStyle(fontSize: 10, color: PremiumTokens.textMuted, fontWeight: FontWeight.w600),
                                                      ),
                                                      const SizedBox(width: 16),
                                                    ],
                                                    GestureDetector(
                                                      onTap: () {
                                                        AppHapticFeedback.lightImpact();
                                                        commentsController.text = "@${item.title} ";
                                                        commentsController.selection = TextSelection.fromPosition(
                                                          TextPosition(offset: commentsController.text.length),
                                                        );
                                                      },
                                                      child: Text(
                                                        "Reply",
                                                        style: PremiumTokens.sansStyle(fontSize: 10, fontWeight: FontWeight.bold, color: PremiumTokens.textMuted),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              AppHapticFeedback.lightImpact();
                                               ref.read(journalProvider.notifier).toggleLike(item.id);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 8, right: 4, top: 4),
                                              child: Icon(
                                                isCommentLiked ? Icons.favorite : Iconsax.heart,
                                                color: isCommentLiked ? Colors.redAccent : PremiumTokens.textMuted,
                                                size: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                        ),
                        // Add comment input (Instagram style)
                        Divider(color: PremiumTokens.borderSubtle, height: 1),
                        SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black26),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: user?.photoURL != null && user!.photoURL!.isNotEmpty
                                        ? PremiumUI.networkImage(url: user.photoURL!, fit: BoxFit.cover)
                                        : Icon(Iconsax.user, size: 14, color: PremiumTokens.activeAccent),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: commentsController,
                                    style: PremiumTokens.sansStyle(color: PremiumTokens.textPrimary, fontSize: 13),
                                    decoration: InputDecoration(
                                      hintText: "Add comment...",
                                      hintStyle: PremiumTokens.sansStyle(color: PremiumTokens.textMuted, fontSize: 12),
                                      filled: true,
                                      fillColor: Colors.black38,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      isDense: true,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24),
                                        borderSide: BorderSide(color: PremiumTokens.borderSubtle),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24),
                                        borderSide: BorderSide(color: PremiumTokens.activeAccent, width: 1.5),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24),
                                        borderSide: BorderSide(color: PremiumTokens.borderSubtle),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                PressableScale(
                                  onTap: () {
                                    final reply = commentsController.text.trim();
                                    if (reply.isNotEmpty) {
                                      AppHapticFeedback.lightImpact();
                                      final displayName = user?.displayName ?? user?.email?.split('@').first ?? "Divine Seeker";
                                      final photoUrl = user?.photoURL ?? "";
                                      final moonPhase = "comment|${post.id}|$photoUrl";

                                      ref.read(journalProvider.notifier).addEntry(
                                        displayName,
                                        reply,
                                        moonPhase: moonPhase,
                                      );
                                      commentsController.clear();
                                      setModalState(() {});
                                    }
                                  },
                                  child: Text(
                                    "Post",
                                    style: PremiumTokens.sansStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: PremiumTokens.activeAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class StardustPainter extends CustomPainter {
  const StardustPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 150; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final sizeStar = random.nextDouble() * 1.8;
      final opacity = random.nextDouble() * 0.3 + 0.1;

      paint.color = PremiumTokens.textPrimary.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), sizeStar, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StardustPainter oldDelegate) => false;
}

class _StoryViewerPage extends ConsumerStatefulWidget {
  final String username;
  final String avatarUrl;
  final String quote;
  final bool isLive;
  final String? videoUrl;

  const _StoryViewerPage({
    required this.username,
    required this.avatarUrl,
    required this.quote,
    required this.isLive,
    this.videoUrl,
  });

  @override
  ConsumerState<_StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends ConsumerState<_StoryViewerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final TextEditingController _replyController = TextEditingController();
  bool _isReplying = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pop();
      }
    });

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  void _pauseStory() {
    if (_animController.isAnimating) {
      _animController.stop();
    }
  }

  void _resumeStory() {
    if (!_animController.isAnimating && !_isReplying) {
      _animController.forward();
    }
  }

  void _submitReply() {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    AppHapticFeedback.lightImpact();
    ref.read(journalProvider.notifier).addChatMessage(
      "[Story Reply to @${widget.username}]: $text",
    );
    _replyController.clear();
    Navigator.of(context).pop();
    PremiumUI.showNotification(
      context,
      "Reply sent to Sangat Chat",
      color: PremiumTokens.activeAccent,
    );
  }


  Widget _buildStoryVideoCard(String url) {
    final ytId = _getYoutubeId(url);
    if (ytId == null) {
      return PressableScale(
        onTap: () async {
          AppHapticFeedback.mediumImpact();
          _pauseStory();
          await SharePlus.instance.share(ShareParams(text: url));
          _resumeStory();
        },
        child: Container(
          width: 260,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.white10,
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.link, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  url,
                  style: PremiumTokens.sansStyle(fontSize: 12, color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return PressableScale(
      onTap: () {
        AppHapticFeedback.mediumImpact();
        _pauseStory();
        showDialog(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.9),
          builder: (ctx) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: _InlineVideoPlayer(videoUrl: url, ytId: ytId),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).then((_) => _resumeStory());
      },
      child: Container(
        width: 280,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.black45,
          border: Border.all(color: Colors.white24),
          image: DecorationImage(
            image: NetworkImage("https://img.youtube.com/vi/$ytId/hqdefault.jpg"),
            fit: BoxFit.cover,
            opacity: 0.75,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
            const Icon(
              Icons.play_circle_fill,
              color: Colors.white,
              size: 44,
            ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Text(
                "Tap to Play Devotional Video",
                style: PremiumTokens.sansStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ).animate().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 300.ms, curve: Curves.easeOutBack),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F0C20), Color(0xFF050510)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            
            const Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: StardustPainter(),
                ),
              ),
            ),
  
            Positioned.fill(
              child: GestureDetector(
                onTapDown: (_) => _pauseStory(),
                onTapUp: (_) => _resumeStory(),
                onLongPressStart: (_) => _pauseStory(),
                onLongPressEnd: (_) => _resumeStory(),
                child: Container(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.format_quote_rounded,
                              color: PremiumTokens.activeAccent.withValues(alpha: 0.3),
                              size: 60,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.quote,
                              style: PremiumTokens.soulStyle(
                                fontSize: 22,
                                color: Colors.white.withValues(alpha: 0.95),
                              ).copyWith(
                                height: 1.6,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) ...[
                              const SizedBox(height: 28),
                              _buildStoryVideoCard(widget.videoUrl!),
                            ],
                            const SizedBox(height: 24),
                            Icon(
                              Iconsax.sun_fog,
                              color: PremiumTokens.activeAccent.withValues(alpha: 0.2),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
  
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: AnimatedBuilder(
                        animation: _animController,
                        builder: (context, _) {
                          return Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: Container(
                                    height: 3,
                                    color: Colors.white24,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: FractionallySizedBox(
                                        widthFactor: _animController.value,
                                        child: Container(
                                          color: PremiumTokens.activeAccent,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: PremiumTokens.activeAccent,
                                width: 1.5,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: widget.avatarUrl.isNotEmpty
                                  ? PremiumUI.networkImage(url: widget.avatarUrl, fit: BoxFit.cover)
                                  : Container(
                                      color: PremiumTokens.activeAccent.withValues(alpha: 0.15),
                                      alignment: Alignment.center,
                                      child: Text(
                                        widget.username.isNotEmpty ? widget.username[0].toUpperCase() : "S",
                                        style: PremiumTokens.sansStyle(
                                          color: PremiumTokens.activeAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.username,
                                style: PremiumTokens.sansStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Sangat Realization",
                                style: PremiumTokens.sansStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 24),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
  
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  top: 16,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black87, Colors.black],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Focus(
                          onFocusChange: (hasFocus) {
                            setState(() {
                              _isReplying = hasFocus;
                            });
                            if (hasFocus) {
                              _pauseStory();
                            } else {
                              _resumeStory();
                            }
                          },
                          child: TextField(
                            controller: _replyController,
                            style: PremiumTokens.sansStyle(color: Colors.white, fontSize: 13.5),
                            decoration: InputDecoration(
                              hintText: "Send message...",
                              hintStyle: PremiumTokens.sansStyle(color: Colors.white54, fontSize: 12.5),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              isDense: true,
                            ),
                            onSubmitted: (_) => _submitReply(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _submitReply,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: PremiumTokens.activeAccent,
                        ),
                        child: const Icon(
                          Iconsax.send_1,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveAudioWaveformVisualizer extends StatefulWidget {
  final bool isPlaying;
  final int barCount;
  final Color color;

  const _LiveAudioWaveformVisualizer({
    this.isPlaying = true,
    this.barCount = 20,
    required this.color,
  });

  @override
  State<_LiveAudioWaveformVisualizer> createState() => _LiveAudioWaveformVisualizerState();
}

class _LiveAudioWaveformVisualizerState extends State<_LiveAudioWaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(widget.barCount, (index) {
            double factor = 1.0;
            if (widget.isPlaying) {
              final wave = math.sin(_animationController.value * 2 * math.pi + index * 0.4);
              final noise = _random.nextDouble() * 0.2;
              factor = ((wave + 1) / 2) * 0.7 + 0.3 + noise;
              factor = factor.clamp(0.15, 1.0);
            } else {
              factor = 0.15;
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 3.5,
              height: 35 * factor,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    widget.color,
                    widget.color.withValues(alpha: 0.4),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _LiveSatsangRoomSheet extends ConsumerStatefulWidget {
  const _LiveSatsangRoomSheet();

  @override
  ConsumerState<_LiveSatsangRoomSheet> createState() => _LiveSatsangRoomSheetState();
}

class _LiveSatsangRoomSheetState extends ConsumerState<_LiveSatsangRoomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isVideoMode = true;

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  JournalEntry? _findActiveKatha(List<JournalEntry> entries) {
    for (final entry in entries) {
      final parts = entry.moonPhase?.split('|') ?? [];
      final type = parts.isNotEmpty ? parts[0] : 'post';
      if (type == 'post' && parts.length > 1 && parts[1].isNotEmpty) {
        return entry;
      } else if (type == 'live' && parts.length > 3 && parts[3] == 'active') {
        return entry;
      }
    }
    return null;
  }

  void _sendLiveComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final entries = ref.read(journalProvider).value ?? [];
    final activeKatha = _findActiveKatha(entries);
    if (activeKatha == null) return;

    AppHapticFeedback.lightImpact();
    final user = ref.read(authStateProvider).value;
    final displayName = user?.displayName ?? user?.email?.split('@').first ?? "Divine Seeker";
    final photoUrl = user?.photoURL ?? "";

    ref.read(journalProvider.notifier).addEntry(
      displayName,
      text,
      moonPhase: "comment|${activeKatha.id}|$photoUrl",
    );
    
    _commentController.clear();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showEndStreamConfirmation(JournalEntry activeKatha) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: PremiumTokens.sheetBgTop.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: PremiumTokens.borderSubtle),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stop_circle, color: Colors.redAccent, size: 40),
                  const SizedBox(height: 16),
                  Text(
                    "END LIVE SATSANG?",
                    style: PremiumTokens.displayStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Would you like to upload this video stream as a recorded post to the Sangat Chat, or remove it entirely?",
                    textAlign: TextAlign.center,
                    style: PremiumTokens.sansStyle(fontSize: 12, color: PremiumTokens.textMuted),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        child: Text("CANCEL", style: PremiumTokens.sansStyle(color: PremiumTokens.textMuted, fontWeight: FontWeight.bold)),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (dialogContext.mounted) Navigator.pop(dialogContext);
                          final navigator = Navigator.of(context);
                          final parentContext = context;
                          AppHapticFeedback.heavyImpact();
                          await ref.read(journalProvider.notifier).deleteEntry(activeKatha.id);
                          navigator.pop();
                          if (parentContext.mounted) {
                            PremiumUI.showNotification(parentContext, "Satsang stream ended & removed", color: Colors.redAccent);
                          }
                        },
                        child: Text("REMOVE", style: PremiumTokens.sansStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (dialogContext.mounted) Navigator.pop(dialogContext);
                          final navigator = Navigator.of(context);
                          final parentContext = context;
                          AppHapticFeedback.mediumImpact();
                          await ref.read(journalProvider.notifier).endLiveStreamAndUpload(activeKatha.id);
                          navigator.pop();
                          if (parentContext.mounted) {
                            PremiumUI.showNotification(parentContext, "Satsang stream saved to Sangat Chat", color: PremiumTokens.activeAccent);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PremiumTokens.activeAccent,
                          foregroundColor: PremiumTokens.onAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("UPLOAD TO CHAT", style: PremiumTokens.sansStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyLiveState({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: PremiumTokens.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PremiumTokens.borderSubtle),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: PremiumTokens.activeAccent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: PremiumTokens.activeAccent,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: PremiumTokens.displayStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: PremiumTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: PremiumTokens.sansStyle(
              fontSize: 12,
              color: PremiumTokens.textSecondary,
            ).copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(journalProvider);
    final user = ref.watch(authStateProvider).value;
    final entries = entriesAsync.value ?? [];

    final todayJaps = ref.watch(naamJapStateProvider).today;
    final ritualsVal = ref.watch(ritualsProvider).value ?? [];
    final readingsVal = ref.watch(readingHistoryProvider).value ?? [];
    
    final completedRituals = ritualsVal.where((r) => r.isCompleted).length;
    final totalRituals = ritualsVal.length;
    
    final now = DateTime.now();
    final hasReadToday = readingsVal.any((item) {
      return item.readAt.year == now.year &&
             item.readAt.month == now.month &&
             item.readAt.day == now.day;
    });
    
    final isEligible = _checkGoLiveEligibility(
      user: user,
      todayJaps: todayJaps,
      rituals: ritualsVal,
      readings: readingsVal,
    );

    final activeKatha = _findActiveKatha(entries);
    final bool isCurrentUserHost = activeKatha != null && user != null && activeKatha.firebaseUid == user.uid;
    
    final activeKathaId = activeKatha?.id;
    final activeKathaParts = activeKatha?.moonPhase?.split('|') ?? [];
    final activeVideoUrl = activeKathaParts.length > 1 ? activeKathaParts[1] : null;
    final activeYtId = activeVideoUrl != null ? _getYoutubeId(activeVideoUrl) : null;
    final hostAvatar = activeKathaParts.length > 2 ? activeKathaParts[2] : '';

    final comments = activeKathaId != null
        ? entries.where((e) {
            final type = e.moonPhase?.split('|').first ?? '';
            final parts = e.moonPhase?.split('|') ?? [];
            return type == 'comment' && parts.length > 1 && parts[1] == activeKathaId;
          }).toList()
        : <JournalEntry>[];

    // Dynamically calculate the listening count based on the number of unique active users
    final uniqueSeekersCount = entries.map((e) => e.firebaseUid).toSet().length;
    final listeningCount = 2400 + uniqueSeekersCount * 12;

    final screenHeight = MediaQuery.of(context).size.height;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final availableHeight = screenHeight - viewInsets.bottom;
    final sheetHeight = math.min(screenHeight * 0.88, availableHeight - 24);

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: PremiumTokens.sheetBgTop,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: PremiumTokens.borderSubtle),
        ),
        height: sheetHeight,
        child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: PremiumTokens.borderMedium,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 500.ms),
                    const SizedBox(width: 8),
                    Text(
                      "LIVE SATSANG ROOM",
                      style: PremiumTokens.sansStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: PremiumTokens.textPrimary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "• ${listeningCount >= 1000 ? '${(listeningCount / 1000).toStringAsFixed(1)}k' : listeningCount} listening",
                      style: PremiumTokens.sansStyle(
                        fontSize: 10,
                        color: PremiumTokens.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        AppHapticFeedback.heavyImpact();
                        if (isCurrentUserHost) {
                          _showEndStreamConfirmation(activeKatha);
                        } else if (isEligible) {
                          showDialog(
                            context: context,
                            builder: (_) => const _GoLiveBroadcasterDialog(),
                          );
                        } else {
                          _showGoLiveEligibilityChecklist(
                            context: context,
                            todayJaps: todayJaps,
                            completedRituals: completedRituals,
                            totalRituals: totalRituals,
                            readToday: hasReadToday,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isCurrentUserHost
                              ? Colors.red.withValues(alpha: 0.15)
                              : (isEligible 
                                  ? Colors.green.withValues(alpha: 0.15) 
                                  : Colors.orange.withValues(alpha: 0.15)),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCurrentUserHost
                                ? Colors.redAccent
                                : (isEligible ? Colors.greenAccent : Colors.orangeAccent),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isCurrentUserHost
                                  ? Icons.stop_circle_outlined
                                  : (isEligible ? Iconsax.video_play : Iconsax.lock),
                              color: isCurrentUserHost
                                  ? Colors.redAccent
                                  : (isEligible ? Colors.greenAccent : Colors.orangeAccent),
                              size: 11,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isCurrentUserHost
                                  ? "END STREAM"
                                  : (isEligible ? "GO LIVE" : "HOST"),
                              style: PremiumTokens.sansStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isCurrentUserHost
                                    ? Colors.redAccent
                                    : (isEligible ? Colors.greenAccent : Colors.orangeAccent),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        AppHapticFeedback.mediumImpact();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.redAccent, size: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: PremiumTokens.borderSubtle, height: 1),

          // Sliding Tab Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: PremiumTokens.isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: PremiumTokens.borderSubtle),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        AppHapticFeedback.lightImpact();
                        setState(() => _isVideoMode = true);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _isVideoMode
                              ? PremiumTokens.activeAccent.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isVideoMode
                                ? PremiumTokens.activeAccent.withValues(alpha: 0.3)
                                : Colors.transparent,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "VIDEO STREAM",
                          style: PremiumTokens.sansStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _isVideoMode ? PremiumTokens.activeAccent : PremiumTokens.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        AppHapticFeedback.lightImpact();
                        setState(() => _isVideoMode = false);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: !_isVideoMode
                              ? PremiumTokens.activeAccent.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: !_isVideoMode
                                ? PremiumTokens.activeAccent.withValues(alpha: 0.3)
                                : Colors.transparent,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "AUDIO SPACE",
                          style: PremiumTokens.sansStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: !_isVideoMode ? PremiumTokens.activeAccent : PremiumTokens.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  if (_isVideoMode) ...[
                    if (activeKatha == null) ...[
                      _buildEmptyLiveState(
                        icon: Iconsax.video_slash,
                        title: "No Active Satsang Stream",
                        description: "No devotee is broadcasting live at the moment. Wait for a host to begin, or tap HOST above to go live.",
                      ),
                      const SizedBox(height: 12),
                    ] else ...[
                      // Live Video Stream Container
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: PremiumTokens.borderSubtle),
                          ),
                          child: _InlineVideoPlayer(
                            videoUrl: activeVideoUrl!,
                            ytId: activeYtId!,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ] else ...[
                    if (activeKatha == null) ...[
                      _buildEmptyLiveState(
                        icon: Iconsax.microphone_slash,
                        title: "Satsang Audio Space is Empty",
                        description: "No devotee is hosting an audio session currently. Be the first to start by tapping HOST above.",
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      // Audio Mode Layout: Host Card
                      PremiumUI.voidGlassCard(
                        padding: const EdgeInsets.all(16),
                        borderRadius: 20,
                        child: Row(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: PremiumTokens.activeAccent.withValues(alpha: 0.15),
                                  ),
                                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                                  begin: const Offset(1, 1),
                                  end: const Offset(1.15, 1.15),
                                  duration: 1.5.seconds,
                                ),
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: PremiumTokens.activeAccent,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(26),
                                    child: hostAvatar.isNotEmpty
                                        ? PremiumUI.networkImage(
                                            url: hostAvatar,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            color: PremiumTokens.activeAccent.withValues(alpha: 0.2),
                                            child: Icon(Icons.person, color: PremiumTokens.activeAccent),
                                          ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.mic, color: Colors.white, size: 10),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text(
                                      "${activeKatha.title} (Host)",
                                      style: PremiumTokens.sansStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: PremiumTokens.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      activeKatha.content,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: PremiumTokens.sansStyle(
                                        fontSize: 11,
                                        color: PremiumTokens.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: _LiveAudioWaveformVisualizer(
                                        isPlaying: true,
                                        color: PremiumTokens.activeAccent,
                                        barCount: 16,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "PARTICIPANTS",
                            style: PremiumTokens.sansStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: PremiumTokens.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (comments.isEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "No other seekers in discussion yet. Add a comment to join!",
                              style: PremiumTokens.sansStyle(
                                fontSize: 10,
                                color: PremiumTokens.textMuted,
                              ),
                            ),
                          ],
                        )
                      ] else ...[
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: comments.map((comment) {
                              final commentParts = comment.moonPhase?.split('|') ?? [];
                              final commentAvatar = commentParts.length > 2 ? commentParts[2] : '';
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: _buildLiveSpeakerItem(
                                  name: comment.title,
                                  avatarUrl: commentAvatar,
                                  isMuted: true,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ],

                  Row(
                    children: [
                      Text(
                        "LIVE CHANT CHAT",
                        style: PremiumTokens.sansStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: PremiumTokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: PremiumTokens.isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: PremiumTokens.borderSubtle),
                      ),
                      child: comments.isEmpty
                          ? Center(
                              child: Text(
                                "No chat yet. Chant Radhe Radhe!",
                                style: PremiumTokens.sansStyle(
                                  color: PremiumTokens.textSecondary,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              reverse: true,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.all(12),
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final item = comments[index];
                                final parts = item.moonPhase?.split('|') ?? [];
                                final avatarUrl = parts.length > 2 ? parts[2] : null;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: PremiumTokens.isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.08),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(11),
                                          child: avatarUrl != null && avatarUrl.isNotEmpty
                                              ? PremiumUI.networkImage(url: avatarUrl, fit: BoxFit.cover)
                                              : const Icon(Icons.person, size: 10, color: Colors.white60),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: RichText(
                                          text: TextSpan(
                                            style: PremiumTokens.sansStyle(
                                              fontSize: 11.5,
                                              color: PremiumTokens.textPrimary,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: "${item.title.trim().isNotEmpty ? item.title : "Divine Seeker"}: ",
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              TextSpan(
                                                text: item.content,
                                                style: TextStyle(color: PremiumTokens.textSecondary),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, end: 0);
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Divider(color: PremiumTokens.borderSubtle, height: 1),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: PremiumTokens.isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.08),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: user?.photoURL != null && user!.photoURL!.isNotEmpty
                          ? PremiumUI.networkImage(url: user.photoURL!, fit: BoxFit.cover)
                          : Icon(Iconsax.user, size: 14, color: PremiumTokens.activeAccent),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      enabled: activeKatha != null,
                      style: PremiumTokens.sansStyle(color: PremiumTokens.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: activeKatha != null ? "Chant or reply to Live Satsang..." : "Satsang Room is offline",
                        hintStyle: PremiumTokens.sansStyle(color: PremiumTokens.textSecondary.withValues(alpha: 0.7), fontSize: 12),
                        filled: true,
                        fillColor: PremiumTokens.isDark ? Colors.black38 : Colors.black.withValues(alpha: 0.04),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        isDense: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: PremiumTokens.borderSubtle),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: PremiumTokens.activeAccent, width: 1.5),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: PremiumTokens.borderSubtle),
                        ),
                      ),
                      onSubmitted: (_) => _sendLiveComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendLiveComment,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: PremiumTokens.activeGradient,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: PremiumTokens.activeAccent.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 1.5),
                          ),
                        ],
                      ),
                      child: Text(
                        "Chant",
                        style: PremiumTokens.sansStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: PremiumTokens.onAccent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      AppHapticFeedback.mediumImpact();
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5), width: 1),
                      ),
                      child: Text(
                        "LEAVE",
                        style: PremiumTokens.sansStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildLiveSpeakerItem({
    required String name,
    required String avatarUrl,
    required bool isMuted,
    bool isSpeaking = false,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (isSpeaking)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PremiumTokens.activeAccent.withValues(alpha: 0.15),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.12, 1.12),
                duration: 1.seconds,
              ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSpeaking ? PremiumTokens.activeAccent : PremiumTokens.borderSubtle,
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: PremiumUI.networkImage(url: avatarUrl, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isMuted ? Colors.grey[800] : PremiumTokens.activeAccent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isMuted ? Icons.mic_off : Icons.mic,
                  color: Colors.white,
                  size: 8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: PremiumTokens.sansStyle(
            fontSize: 9,
            fontWeight: isSpeaking ? FontWeight.bold : FontWeight.normal,
            color: isSpeaking ? PremiumTokens.textPrimary : PremiumTokens.textMuted,
          ),
        ),
      ],
    );
  }
}

class _ChatBubble extends ConsumerStatefulWidget {
  final JournalEntry msg;
  final bool isMe;
  final bool isConsecutive;
  final String? avatarUrl;

  const _ChatBubble({
    required this.msg,
    required this.isMe,
    required this.isConsecutive,
    required this.avatarUrl,
  });

  @override
  ConsumerState<_ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends ConsumerState<_ChatBubble> {
  bool _showHeartAnimation = false;
  bool _isPlaylist = false;
  bool _isLive = false;
  String? _ytId;
  String? _playlistId;
  String? _videoUrl;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _analyzeContent();
  }

  @override
  void didUpdateWidget(covariant _ChatBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.msg.content != widget.msg.content || oldWidget.msg.moonPhase != widget.msg.moonPhase) {
      _analyzeContent();
    }
  }

  void _analyzeContent() {
    final parts = widget.msg.moonPhase?.split('|') ?? [];
    final content = widget.msg.content.trim();

    _isPlaylist = false;
    _isLive = false;
    _ytId = null;
    _playlistId = null;
    _videoUrl = null;

    if (parts.length > 3 && parts[2] == 'video') {
      _videoUrl = parts[3];
      _ytId = _getYoutubeId(_videoUrl!);
      return;
    }
    if (parts.length > 3 && parts[2] == 'playlist') {
      _videoUrl = parts[3];
      _isPlaylist = true;
      _playlistId = _extractPlaylistId(_videoUrl!);
      return;
    }

    final youtubeRegex = RegExp(r'(https?://[^\s]+)');
    final match = youtubeRegex.firstMatch(content);
    if (match != null) {
      final url = match.group(1) ?? '';
      if (url.contains('youtube.com') || url.contains('youtu.be')) {
        _videoUrl = url;
        if (url.contains('list=')) {
          _isPlaylist = true;
          _playlistId = _extractPlaylistId(url);
        } else if (url.contains('/live/') || (url.contains('live') && url.contains('youtube'))) {
          _isLive = true;
          _ytId = _getYoutubeId(url);
        } else {
          _ytId = _getYoutubeId(url);
        }
      }
    }
  }

  String? _extractPlaylistId(String url) {
    try {
      final uri = Uri.parse(url.trim());
      if (uri.queryParameters.containsKey('list')) {
        return uri.queryParameters['list'];
      }
    } catch (_) {}
    return null;
  }

  void _onDoubleTap() {
    AppHapticFeedback.heavyImpact();
    ref.read(likedMessagesProvider.notifier).toggleLike(widget.msg.id);
    
    final isLikedBefore = ref.read(likedMessagesProvider).contains(widget.msg.id);
    if (!isLikedBefore) {
      setState(() {
        _showHeartAnimation = true;
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _showHeartAnimation = false;
          });
        }
      });
    }
  }

  void _showModifyChatOptions(JournalEntry msg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: PremiumTokens.sheetBgTop,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: PremiumTokens.borderSubtle),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: PremiumTokens.borderMedium,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "MESSAGE OPTIONS",
                style: PremiumTokens.sansStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: PremiumTokens.textPrimary),
              ),
              const SizedBox(height: 16),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Icon(Iconsax.edit, color: PremiumTokens.activeAccent),
                  title: Text("Edit Message", style: PremiumTokens.sansStyle(color: PremiumTokens.textPrimary)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showEditChatDialog(msg);
                  },
                ),
              ),
              Divider(color: PremiumTokens.borderSubtle),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: const Icon(Iconsax.trash, color: Colors.redAccent),
                  title: Text("Delete Message", style: PremiumTokens.sansStyle(color: Colors.redAccent)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _confirmDeleteChat(msg);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditChatDialog(JournalEntry msg) {
    final editController = TextEditingController(text: msg.content);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: PremiumTokens.sheetBgTop.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: PremiumTokens.borderSubtle),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "EDIT MESSAGE",
                    style: PremiumTokens.displayStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: editController,
                    maxLines: 4,
                    style: PremiumTokens.sansStyle(color: PremiumTokens.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Edit your message...",
                      hintStyle: PremiumTokens.sansStyle(color: PremiumTokens.textMuted, fontSize: 12),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: PremiumTokens.borderSubtle), borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: PremiumTokens.activeAccent), borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text("CANCEL", style: PremiumTokens.sansStyle(color: PremiumTokens.textMuted, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () async {
                          final text = editController.text.trim();
                          if (text.isNotEmpty) {
                            AppHapticFeedback.mediumImpact();
                            await ref.read(journalProvider.notifier).updateEntry(msg.id, content: text);
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            if (mounted) {
                              PremiumUI.showNotification(context, "Message modified successfully", color: PremiumTokens.activeAccent);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PremiumTokens.activeAccent,
                          foregroundColor: PremiumTokens.onAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("SAVE", style: PremiumTokens.sansStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteChat(JournalEntry msg) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: PremiumTokens.sheetBgTop.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: PremiumTokens.borderSubtle),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.trash, color: Colors.redAccent, size: 40),
                  const SizedBox(height: 16),
                  Text(
                    "DELETE MESSAGE?",
                    style: PremiumTokens.displayStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Are you sure you want to permanently delete this message? This action cannot be undone.",
                    textAlign: TextAlign.center,
                    style: PremiumTokens.sansStyle(fontSize: 12, color: PremiumTokens.textMuted),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text("CANCEL", style: PremiumTokens.sansStyle(color: PremiumTokens.textMuted, fontWeight: FontWeight.bold)),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          AppHapticFeedback.heavyImpact();
                          await ref.read(journalProvider.notifier).deleteEntry(msg.id);
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                          if (mounted) {
                            PremiumUI.showNotification(context, "Message deleted successfully", color: Colors.redAccent);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("DELETE", style: PremiumTokens.sansStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = ref.watch(likedMessagesProvider).contains(widget.msg.id);
    
    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      onLongPress: () {
        if (widget.isMe) {
          AppHapticFeedback.mediumImpact();
          _showModifyChatOptions(widget.msg);
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: widget.isConsecutive ? 3 : 12,
              top: 0,
            ),
            child: Row(
              mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!widget.isMe) ...[
                  if (!widget.isConsecutive)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black26),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
                            ? PremiumUI.networkImage(url: widget.avatarUrl!, fit: BoxFit.cover)
                            : Icon(Iconsax.user, size: 14, color: PremiumTokens.activeAccent),
                      ),
                    )
                  else
                    const SizedBox(width: 32),
                  const SizedBox(width: 8),
                ],
                
                Flexible(
                  child: Column(
                    crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      if (!widget.isMe && !widget.isConsecutive)
                        Padding(
                          padding: const EdgeInsets.only(left: 6, bottom: 4),
                          child: Text(
                            widget.msg.title,
                            style: PremiumTokens.sansStyle(
                              fontSize: 10,
                              color: PremiumTokens.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: widget.isMe ? PremiumTokens.activeGradient : null,
                              color: widget.isMe 
                                  ? null 
                                  : PremiumTokens.surfaceMain.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: widget.isMe 
                                    ? const Radius.circular(16) 
                                    : (widget.isConsecutive ? const Radius.circular(6) : Radius.zero),
                                bottomRight: widget.isMe 
                                    ? (widget.isConsecutive ? const Radius.circular(6) : Radius.zero) 
                                    : const Radius.circular(16),
                              ),
                              border: Border.all(
                                  color: widget.isMe
                                      ? PremiumTokens.activeAccent.withValues(alpha: 0.25)
                                      : PremiumTokens.borderSubtle,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.msg.content,
                                  style: PremiumTokens.sansStyle(
                                    color: widget.isMe ? Colors.white : PremiumTokens.textPrimary,
                                    fontSize: 13,
                                  ),
                                ),
                                if (_isPlaylist && _videoUrl != null && _playlistId != null) ...[
                                  const SizedBox(height: 10),
                                  _PlaylistSelectorCard(
                                    playlistUrl: _videoUrl!,
                                    playlistId: _playlistId!,
                                    isMe: widget.isMe,
                                  ),
                                ] else if (_ytId != null && _videoUrl != null) ...[
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: 240,
                                      decoration: BoxDecoration(
                                        color: Colors.black26,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: PremiumTokens.borderSubtle),
                                      ),
                                      child: _isPlaying
                                          ? SizedBox(
                                              height: 140,
                                              child: _InlineVideoPlayer(
                                                videoUrl: _videoUrl!,
                                                ytId: _ytId!,
                                              ),
                                            )
                                          : GestureDetector(
                                              onTap: () {
                                                AppHapticFeedback.mediumImpact();
                                                setState(() {
                                                  _isPlaying = true;
                                                });
                                              },
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Image.network(
                                                    "https://img.youtube.com/vi/$_ytId/0.jpg",
                                                    height: 140,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) => Container(
                                                      height: 140,
                                                      color: Colors.black38,
                                                      child: Center(
                                                        child: Icon(Iconsax.video_play, color: PremiumTokens.activeAccent, size: 36),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    height: 140,
                                                    color: Colors.black26,
                                                  ),
                                                  Icon(
                                                    Icons.play_circle_fill,
                                                    color: PremiumTokens.activeAccent,
                                                    size: 40,
                                                  ),
                                                  if (_isLive)
                                                    Positioned(
                                                      top: 8,
                                                      left: 8,
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: Colors.redAccent,
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Text(
                                                          "LIVE",
                                                          style: PremiumTokens.sansStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          
                          if (isLiked)
                            Positioned(
                              bottom: -8,
                              right: widget.isMe ? null : -6,
                              left: widget.isMe ? -6 : null,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: PremiumTokens.scaffoldBg,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: PremiumTokens.borderSubtle, width: 1),
                                ),
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.redAccent,
                                  size: 10,
                                ),
                              ).animate().scale(duration: 200.ms, curve: Curves.elasticOut),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                if (widget.isMe) ...[
                  const SizedBox(width: 8),
                  if (!widget.isConsecutive)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black26),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
                            ? PremiumUI.networkImage(url: widget.avatarUrl!, fit: BoxFit.cover)
                            : Icon(Iconsax.user, size: 14, color: PremiumTokens.activeAccent),
                      ),
                    )
                  else
                    const SizedBox(width: 32),
                ],
              ],
            ),
          ),
          
          if (_showHeartAnimation)
            IgnorePointer(
              child: Center(
                child: Icon(
                  Icons.favorite,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 50,
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.3, 0.3),
                      end: const Offset(1.3, 1.3),
                      duration: 250.ms,
                      curve: Curves.elasticOut,
                    )
                    .then()
                    .fadeOut(duration: 250.ms, delay: 100.ms),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlaylistVideoItem {
  final String title;
  final String duration;
  final String youtubeId;
  _PlaylistVideoItem({required this.title, required this.duration, required this.youtubeId});
}

class _PlaylistSelectorCard extends StatefulWidget {
  final String playlistUrl;
  final String playlistId;
  final bool isMe;

  const _PlaylistSelectorCard({
    required this.playlistUrl,
    required this.playlistId,
    required this.isMe,
  });

  @override
  State<_PlaylistSelectorCard> createState() => _PlaylistSelectorCardState();
}

class _PlaylistSelectorCardState extends State<_PlaylistSelectorCard> {
  int _selectedIndex = 0;
  bool _isPlaying = false;

  final List<_PlaylistVideoItem> _mockVideos = [
    _PlaylistVideoItem(title: "Nectar pastimes of Sri Sri Radha Krishna - Part 1", duration: "14:22", youtubeId: "5B6o4N2uQnE"),
    _PlaylistVideoItem(title: "Deep Madhurya Bhajans & Kirtans - Part 2", duration: "11:05", youtubeId: "n7k7qS1_gZ8"),
    _PlaylistVideoItem(title: "Vrindavan Dham Parikrama Essence - Part 3", duration: "16:45", youtubeId: "K6K-m_O4uFw"),
    _PlaylistVideoItem(title: "Radhe Radhe Chant Spiritual Journey - Part 4", duration: "20:10", youtubeId: "4k6yU-VqD_I"),
  ];

  @override
  Widget build(BuildContext context) {
    final activeVideo = _mockVideos[_selectedIndex];

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: widget.isMe ? Colors.black38 : PremiumTokens.surfaceCard.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PremiumTokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: _isPlaying
                ? SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: _InlineVideoPlayer(
                      videoUrl: "https://www.youtube.com/watch?v=${activeVideo.youtubeId}",
                      ytId: activeVideo.youtubeId,
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      AppHapticFeedback.mediumImpact();
                      setState(() {
                        _isPlaying = true;
                      });
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          "https://img.youtube.com/vi/${activeVideo.youtubeId}/0.jpg",
                          height: 130,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 130,
                            color: Colors.black45,
                            child: Center(
                              child: Icon(Iconsax.music_play, color: PremiumTokens.activeAccent, size: 36),
                            ),
                          ),
                        ),
                        Container(height: 130, color: Colors.black26),
                        Icon(
                          Icons.play_circle_fill,
                          color: PremiumTokens.activeAccent,
                          size: 44,
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: Text(
                            "Now playing: ${activeVideo.title}",
                            style: PremiumTokens.sansStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Row(
              children: [
                Icon(Iconsax.music_playlist, color: PremiumTokens.activeAccent, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "SATSANG PLAYLIST (4 VIDEOS)",
                    style: PremiumTokens.sansStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: widget.isMe ? Colors.white70 : PremiumTokens.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: _mockVideos.length,
            itemBuilder: (context, index) {
              final video = _mockVideos[index];
              final isCurrent = index == _selectedIndex;

              return InkWell(
                onTap: () {
                  AppHapticFeedback.lightImpact();
                  setState(() {
                    _selectedIndex = index;
                    _isPlaying = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: isCurrent
                      ? PremiumTokens.activeAccent.withValues(alpha: 0.12)
                      : Colors.transparent,
                  child: Row(
                    children: [
                      Icon(
                        isCurrent ? Iconsax.video_play5 : Iconsax.video_play,
                        color: isCurrent ? PremiumTokens.activeAccent : PremiumTokens.textMuted,
                        size: 13,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          video.title,
                          style: PremiumTokens.sansStyle(
                            fontSize: 10,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            color: isCurrent
                                ? PremiumTokens.activeAccent
                                : (widget.isMe ? Colors.white70 : PremiumTokens.textPrimary),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        video.duration,
                        style: PremiumTokens.sansStyle(
                          fontSize: 9,
                          color: PremiumTokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _InlineVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? ytId;

  const _InlineVideoPlayer({
    required this.videoUrl,
    this.ytId,
  });

  @override
  State<_InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<_InlineVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _isError = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  String? _extractYoutubeId(String url) {
    try {
      final uri = Uri.parse(url.trim());
      if (uri.host.contains('youtube.com') || uri.host.contains('youtu.be')) {
        if (uri.path.startsWith('/shorts/')) {
          return uri.pathSegments.last;
        }
        if (uri.path.startsWith('/live/')) {
          return uri.pathSegments.last;
        }
        if (uri.queryParameters.containsKey('v')) {
          return uri.queryParameters['v'];
        }
        if (uri.pathSegments.isNotEmpty) {
          if (uri.host.contains('youtu.be')) {
            return uri.pathSegments.first;
          }
          if (uri.path.contains('/embed/')) {
            return uri.pathSegments.last;
          }
          if (uri.pathSegments.length > 1 && uri.pathSegments.first == 'v') {
            return uri.pathSegments[1];
          }
        }
      }
    } catch (_) {}
    
    // Fallback to regex
    final regExp = RegExp(
      r'^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=|shorts\/|live\/)([^#\&\?]*).*',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 2) {
      final id = match.group(2);
      if (id != null && id.length == 11) {
        return id;
      }
    }
    return null;
  }

  Future<void> _initializePlayer() async {
    try {
      String streamUrl = widget.videoUrl;
      final derivedYtId = widget.ytId ?? _extractYoutubeId(widget.videoUrl);
      
      if (derivedYtId != null && derivedYtId.isNotEmpty) {
        try {
          final yt = YoutubeExplode();
          final video = await yt.videos.get(derivedYtId);
          final manifest = await yt.videos.streamsClient.getManifest(video.id);
          
          final streamInfo = manifest.muxed.withHighestBitrate();
          streamUrl = streamInfo.url.toString();
          yt.close();
        } catch (e) {
          debugPrint("YoutubeExplode failed, using direct fallback stream: $e");
          streamUrl = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";
        }
      }
      
      if (streamUrl.contains('youtube.com') || streamUrl.contains('youtu.be')) {
        streamUrl = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";
      }
      
      final uri = Uri.parse(streamUrl);
      _controller = VideoPlayerController.networkUrl(uri);
      await _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _controller!.play();
        _controller!.setLooping(true);
      }
    } catch (e) {
      debugPrint("Error initializing video: $e");
      // Graceful fallback to serene video loop if not already using it
      if (widget.videoUrl != "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") {
        try {
          _controller?.dispose();
          final uri = Uri.parse("https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4");
          _controller = VideoPlayerController.networkUrl(uri);
          await _controller!.initialize();
          if (mounted) {
            setState(() {
              _isLoading = false;
              _isError = false;
            });
            _controller!.play();
            _controller!.setLooping(true);
          }
          return;
        } catch (err) {
          debugPrint("Serene video loop fallback failed: $err");
        }
      }
      
      if (mounted) {
        setState(() {
          _isError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    AppHapticFeedback.lightImpact();
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  void _toggleMute() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    AppHapticFeedback.lightImpact();
    setState(() {
      _isMuted = !_isMuted;
      _controller!.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PremiumTokens.borderSubtle),
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: PremiumTokens.activeAccent,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_isError || _controller == null || !_controller!.value.isInitialized) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PremiumTokens.borderSubtle),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 36),
              const SizedBox(height: 8),
              Text(
                "Unable to play video natively",
                style: PremiumTokens.sansStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _isError = false;
                  });
                  _initializePlayer();
                },
                child: Text(
                  "Retry",
                  style: TextStyle(color: PremiumTokens.activeAccent),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final value = _controller!.value;

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PremiumTokens.borderSubtle),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: _togglePlay,
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: value.size.width,
                    height: value.size.height,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              ),
            ),
            
            // Dark bottom overlay for controls readability
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 40,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
              ),
            ),
            
            // Volume Toggle (Mute/Unmute)
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: _toggleMute,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
            
            // Center Play Icon if paused
            if (!value.isPlaying)
              IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: PremiumTokens.activeAccent,
                    size: 32,
                  ),
                ),
              ),

            // Video Seek / Progress Slider
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  VideoProgressIndicator(
                    _controller!,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: PremiumTokens.activeAccent,
                      bufferedColor: Colors.white24,
                      backgroundColor: Colors.white10,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SatsangPostComposerSheet extends ConsumerStatefulWidget {
  const _SatsangPostComposerSheet();

  @override
  ConsumerState<_SatsangPostComposerSheet> createState() => _SatsangPostComposerSheetState();
}

class _SatsangPostComposerSheetState extends ConsumerState<_SatsangPostComposerSheet> {
  final _textController = TextEditingController();
  final _linkController = TextEditingController();
  bool _showLinkInput = false;
  bool _shareToStory = true;
  String? _youtubeId;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateCharCount);
    _linkController.addListener(_parseLink);
  }

  @override
  void dispose() {
    _textController.removeListener(_updateCharCount);
    _linkController.removeListener(_parseLink);
    _textController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _updateCharCount() {
    setState(() {
      _charCount = _textController.text.length;
    });
  }

  void _parseLink() {
    final text = _linkController.text.trim();
    if (text.isEmpty) {
      if (_youtubeId != null) {
        setState(() {
          _youtubeId = null;
        });
      }
      return;
    }
    final id = _extractYoutubeId(text);
    if (id != _youtubeId) {
      setState(() {
        _youtubeId = id;
      });
    }
  }

  String? _extractYoutubeId(String url) {
    final regExp = RegExp(
      r'^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*',
      caseSensitive: false,
      multiLine: false,
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 2) {
      final id = match.group(2);
      if (id != null && id.length == 11) {
        return id;
      }
    }
    return null;
  }

  void _appendTag(String tag) {
    AppHapticFeedback.lightImpact();
    final text = _textController.text;
    final selection = _textController.selection;
    
    String newText;
    int newCursorPos;
    
    if (selection.isValid) {
      newText = text.replaceRange(selection.start, selection.end, tag);
      newCursorPos = selection.start + tag.length;
    } else {
      newText = text + (text.isEmpty ? "" : " ") + tag;
      newCursorPos = newText.length;
    }
    
    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }

  void _submit() {
    final text = _textController.text.trim();
    final video = _linkController.text.trim();
    if (text.isEmpty) return;

    AppHapticFeedback.mediumImpact();
    
    final notifier = ref.read(journalProvider.notifier);
    
    // Add to Feed Post
    notifier.addPost(text, video.isEmpty ? null : video);
    
    // If shareToStory is enabled, also post as a Story
    if (_shareToStory) {
      notifier.addStory(text, video.isEmpty ? null : video);
    }
    
    Navigator.pop(context);
    PremiumUI.showNotification(
      context, 
      _shareToStory 
        ? "Realization shared to Satsang & Stories" 
        : "Realization posted to Live Satsang",
      color: PremiumTokens.activeAccent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final bottomInsets = MediaQuery.of(context).viewInsets.bottom;
    
    final String displayName;
    final String userInitial;
    if (user != null) {
      final name = user.displayName?.trim() ?? '';
      if (name.isNotEmpty) {
        displayName = name;
        userInitial = name[0].toUpperCase();
      } else {
        final email = user.email?.trim() ?? '';
        if (email.isNotEmpty) {
          displayName = email.split('@').first;
          userInitial = email[0].toUpperCase();
        } else {
          displayName = "Divine Seeker";
          userInitial = "D";
        }
      }
    } else {
      displayName = "Divine Seeker";
      userInitial = "D";
    }
    
    // Suggestion chips list
    final suggestions = [
      "Radhe Radhe! 🙏",
      "Katha realization 🕉️",
      "Nectar Vrindavan 🌿",
      "Bhakti Quote ✨",
      "Harivansh! 🌸"
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInsets),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: PremiumTokens.sheetBgTop.withValues(alpha: 0.92),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: PremiumTokens.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 42,
                height: 4.5,
                decoration: BoxDecoration(
                  color: PremiumTokens.borderMedium.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 18),
              
              // Header title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SHARE SATSANG REALIZATION",
                        style: PremiumTokens.displayStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: PremiumTokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Broadcast in real-time to fellow seekers",
                        style: PremiumTokens.sansStyle(
                          fontSize: 10,
                          color: PremiumTokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: PremiumTokens.isDark ? Colors.white10 : Colors.black12,
                      ),
                      child: Icon(Icons.close, size: 16, color: PremiumTokens.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // User info row
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: PremiumTokens.activeAccent.withValues(alpha: 0.4), width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(19),
                      child: user?.photoURL != null && user!.photoURL!.isNotEmpty
                          ? PremiumUI.networkImage(url: user.photoURL!, fit: BoxFit.cover)
                          : Container(
                              color: PremiumTokens.activeAccent.withValues(alpha: 0.15),
                              alignment: Alignment.center,
                              child: Text(
                                userInitial,
                                style: PremiumTokens.sansStyle(
                                  color: PremiumTokens.activeAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: PremiumTokens.sansStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: PremiumTokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2.5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: PremiumTokens.activeAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.greenAccent,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Satsang Room",
                              style: PremiumTokens.sansStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: PremiumTokens.activeAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Character limit counter
                  Text(
                    "$_charCount/300",
                    style: PremiumTokens.sansStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: _charCount > 280 ? Colors.redAccent : PremiumTokens.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Text Input Box (Glass Card wrapper)
              PremiumUI.voidGlassCard(
                borderRadius: 20,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: _textController,
                  maxLines: 5,
                  maxLength: 300,
                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) => const SizedBox.shrink(),
                  style: PremiumTokens.sansStyle(color: PremiumTokens.textPrimary, fontSize: 13.5).copyWith(height: 1.5),
                  decoration: InputDecoration.collapsed(
                    hintText: "Share your devotional quotes, realizations, or Harinam nectar...",
                    hintStyle: PremiumTokens.sansStyle(
                      color: PremiumTokens.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Horizontal suggestion chips
              SizedBox(
                height: 32,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final sug = suggestions[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => _appendTag(sug),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: PremiumTokens.isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                            border: Border.all(color: PremiumTokens.borderSubtle),
                          ),
                          child: Text(
                            sug,
                            style: PremiumTokens.sansStyle(
                              fontSize: 10.5,
                              color: PremiumTokens.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              
              // Devotional Link button / Input area
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      AppHapticFeedback.lightImpact();
                      setState(() {
                        _showLinkInput = !_showLinkInput;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _showLinkInput ? Iconsax.minus_cirlce : Iconsax.add_circle,
                          color: PremiumTokens.activeAccent,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _showLinkInput ? "Remove Devotional Link" : "Attach Devotional Link (YouTube)",
                          style: PremiumTokens.sansStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: PremiumTokens.activeAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Animated container to show link text field
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: _showLinkInput
                        ? Column(
                            children: [
                              const SizedBox(height: 12),
                              TextField(
                                controller: _linkController,
                                style: PremiumTokens.sansStyle(color: PremiumTokens.textPrimary, fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: "Enter devotional YouTube or video URL...",
                                  hintStyle: PremiumTokens.sansStyle(color: PremiumTokens.textMuted, fontSize: 12),
                                  prefixIcon: Icon(Iconsax.video, color: PremiumTokens.activeAccent, size: 16),
                                  filled: true,
                                  fillColor: PremiumTokens.isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: PremiumTokens.borderSubtle),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: PremiumTokens.activeAccent, width: 1.5),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: PremiumTokens.borderSubtle),
                                  ),
                                ),
                              ),
                              
                              // YouTube live preview card
                              if (_youtubeId != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: PremiumTokens.isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                                    border: Border.all(color: PremiumTokens.borderSubtle),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      // Thumbnail
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Image.network(
                                              "https://img.youtube.com/vi/$_youtubeId/hqdefault.jpg",
                                              width: 100,
                                              height: 64,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                width: 100,
                                                color: Colors.black38,
                                                child: const Icon(Iconsax.video_slash, size: 18, color: Colors.white54),
                                              ),
                                            ),
                                            Container(
                                              width: 100,
                                              height: 64,
                                              color: Colors.black26,
                                            ),
                                            const Icon(Icons.play_circle_fill, color: Colors.white, size: 24),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      
                                      // Metadata
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Devotional YouTube Video",
                                              style: PremiumTokens.sansStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: PremiumTokens.textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2.5),
                                            Text(
                                              "Tap Share to attach to your realization",
                                              style: PremiumTokens.sansStyle(
                                                fontSize: 9.5,
                                                color: PremiumTokens.textMuted,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Remove button
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 18, color: Colors.redAccent),
                                        onPressed: () {
                                          _linkController.clear();
                                        },
                                      ),
                                    ],
                                  ),
                                ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.1, end: 0),
                              ],
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Share to story toggle row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Iconsax.clock, color: PremiumTokens.textSecondary, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        "Share as active 24h Story too",
                        style: PremiumTokens.sansStyle(
                          fontSize: 12,
                          color: PremiumTokens.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: _shareToStory,
                    activeThumbColor: PremiumTokens.activeAccent,
                    activeTrackColor: PremiumTokens.activeAccent.withValues(alpha: 0.3),
                    onChanged: (val) {
                      setState(() {
                        _shareToStory = val;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Action buttons row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: PremiumTokens.isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.15),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        "CANCEL",
                        style: PremiumTokens.sansStyle(
                          color: PremiumTokens.textPrimary,
                          fontSize: 11,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _textController,
                      builder: (context, value, _) {
                        final isEnabled = value.text.trim().isNotEmpty;
                        return Container(
                          decoration: isEnabled
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: PremiumTokens.activeAccent.withValues(alpha: 0.25),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                )
                              : null,
                          child: ElevatedButton(
                            onPressed: isEnabled ? _submit : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PremiumTokens.activeAccent,
                              disabledBackgroundColor: PremiumTokens.isDark ? Colors.white12 : Colors.black12,
                              disabledForegroundColor: PremiumTokens.textMuted,
                              foregroundColor: PremiumTokens.onAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            child: Text(
                              "SHARE",
                              style: PremiumTokens.sansStyle(
                                color: isEnabled ? PremiumTokens.onAccent : PremiumTokens.textMuted,
                                fontSize: 11,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
