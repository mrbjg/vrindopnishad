import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import '../core/design_system.dart';
import '../core/journal_provider.dart';
import '../core/color_theme_provider.dart';
import '../core/auth_provider.dart';
import '../core/providers.dart';
import '../models/journal_entry.dart';

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

class EternalReflectionScreen extends ConsumerStatefulWidget {
  final bool showBackButton;

  const EternalReflectionScreen({super.key, this.showBackButton = false});

  @override
  ConsumerState<EternalReflectionScreen> createState() => _EternalReflectionScreenState();
}

class _EternalReflectionScreenState extends ConsumerState<EternalReflectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

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

  String? _getYoutubeId(String url) {
    final regExp = RegExp(
      r'^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*',
      caseSensitive: false,
      multiLine: false,
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 2) {
      return match.group(2);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(journalProvider);
    ref.watch(themeProvider);
    ref.watch(colorPaletteProvider);

    return Scaffold(
      backgroundColor: PremiumTokens.scaffoldBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              PremiumTokens.surfaceMain,
              PremiumTokens.scaffoldBg,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Stardust Background
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
          final activeIndex = _tabController.index;
          if (activeIndex != 0) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: FloatingActionButton(
              onPressed: () {
                HapticFeedback.heavyImpact();
                _showPostDialog(context);
              },
              backgroundColor: PremiumTokens.fabBg,
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
                child: Icon(Iconsax.add, color: PremiumTokens.textPrimary, size: 26),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.showBackButton)
            IconButton(
              icon: Icon(Iconsax.arrow_left, color: PremiumTokens.textPrimary, size: 24),
              onPressed: () => Navigator.pop(context),
            )
          else
            Icon(Iconsax.volume_high, color: PremiumTokens.activeAccent, size: 24),
          Column(
            children: [
              Text(
                "SANT-VAANI",
                style: PremiumTokens.displayStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: PremiumTokens.textPrimary,
                ),
              ),
              Text(
                "SOUL RESONANCE",
                style: PremiumTokens.sansStyle(
                  fontSize: 10,
                  color: PremiumTokens.textMuted,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Iconsax.refresh, color: PremiumTokens.textPrimary, size: 20),
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(journalProvider.notifier).refresh();
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
        borderRadius: 24,
        child: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          splashBorderRadius: BorderRadius.circular(20),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          indicator: BoxDecoration(
            color: PremiumTokens.activeAccent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
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
      data: (entries) {
        final feedPosts = entries.where((e) {
          final type = e.moonPhase?.split('|').first ?? 'post';
          return type == 'post';
        }).toList();

        if (feedPosts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.message_text, size: 48, color: PremiumTokens.textMuted),
                const SizedBox(height: 16),
                Text(
                  "NO POSTS YET",
                  style: PremiumTokens.sansStyle(fontSize: 12, fontWeight: FontWeight.w800, color: PremiumTokens.textMuted),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 140),
          itemCount: feedPosts.length,
          itemBuilder: (context, index) {
            final post = feedPosts[index];
            final parts = post.moonPhase?.split('|') ?? [];
            final videoUrl = parts.length > 1 ? parts[1] : null;
            final avatarUrl = parts.length > 2 ? parts[2] : null;
            final ytId = videoUrl != null ? _getYoutubeId(videoUrl) : null;

            return _buildFeedPostCard(post, videoUrl, avatarUrl, ytId)
                .animate()
                .fadeIn(duration: 400.ms, delay: (index * 50).ms)
                .slideY(begin: 0.1, end: 0);
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: PremiumTokens.activeAccent)),
      error: (e, _) => Center(child: Text("Error: $e", style: TextStyle(color: PremiumTokens.textMuted))),
    );
  }

  Widget _buildFeedPostCard(JournalEntry post, String? videoUrl, String? avatarUrl, String? ytId) {
    final dateStr = "${post.createdAt.day}/${post.createdAt.month} ${post.createdAt.hour}:${post.createdAt.minute.toString().padLeft(2, '0')}";
    final isLiked = ref.watch(likedPostsProvider).contains(post.id);
    final isSaved = ref.watch(savedPostsProvider).contains(post.id);

    final int baseLikes = post.id.hashCode.abs() % 45 + 5;
    final int displayLikes = isLiked ? baseLikes + 1 : baseLikes;

    final entries = ref.watch(journalProvider).value ?? [];
    final commentsCount = entries.where((e) {
      final type = e.moonPhase?.split('|').first ?? '';
      final parts = e.moonPhase?.split('|') ?? [];
      return type == 'comment' && parts.length > 1 && parts[1] == post.id;
    }).length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: PremiumUI.relicStaticCard(
        padding: const EdgeInsets.all(18),
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
                    borderRadius: BorderRadius.circular(19),
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
                        post.title,
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
                if (videoUrl != null && videoUrl.isNotEmpty)
                  Icon(Iconsax.video_play5, color: PremiumTokens.activeAccent, size: 20),
              ],
            ),
            const SizedBox(height: 14),

            // Post Text Content
            Text(
              post.content,
              style: PremiumTokens.sansStyle(
                fontSize: 14,
                color: PremiumTokens.textSecondary,
              ).copyWith(height: 1.5),
            ),

            // Render playable video preview card if youtube video exists
            if (ytId != null) ...[
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Clipboard.setData(ClipboardData(text: videoUrl));
                  PremiumUI.showNotification(context, "Realization URL copied to clipboard");
                },
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
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
                                videoUrl!,
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
              // Standard web video link decoration
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
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

            // Action row (Instagram style)
            const SizedBox(height: 16),
            Divider(color: PremiumTokens.borderSubtle, height: 0.5),
            const SizedBox(height: 12),
            Row(
              children: [
                // Heart Like Button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    ref.read(likedPostsProvider.notifier).toggleLike(post.id);
                  },
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.favorite : Iconsax.heart,
                        color: isLiked ? Colors.redAccent : PremiumTokens.textMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "$displayLikes",
                        style: PremiumTokens.sansStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: PremiumTokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                
                // Comment Button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showCommentsSheet(post);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.message,
                        color: PremiumTokens.textMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "$commentsCount",
                        style: PremiumTokens.sansStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: PremiumTokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                
                // Share Button (Paper Airplane)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Share.share("${post.title}: ${post.content}");
                  },
                  child: Icon(
                    Iconsax.send_1,
                    color: PremiumTokens.textMuted,
                    size: 20,
                  ),
                ),
                const Spacer(),
                
                // Bookmark/Save Button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
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
          ],
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
        // Chat messages body
        Expanded(
          child: entriesAsync.when(
            data: (entries) {
              final chatMsgs = entries.where((e) {
                final type = e.moonPhase?.split('|').first ?? 'post';
                return type == 'chat';
              }).toList().reversed.toList(); // Oldest first for scrolling down

              if (chatMsgs.isEmpty) {
                return Center(
                  child: Text(
                    "Welcome to Sangat Chat. Say Radhe Radhe!",
                    style: PremiumTokens.sansStyle(color: PremiumTokens.textMuted, fontSize: 11),
                  ),
                );
              }

              // Auto scroll to bottom
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_chatScrollController.hasClients) {
                  _chatScrollController.animateTo(
                    _chatScrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });

              return ListView.builder(
                controller: _chatScrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, 10, 20, isKeyboardOpen ? 80 : 110),
                itemCount: chatMsgs.length,
                itemBuilder: (context, index) {
                  final msg = chatMsgs[index];
                  final isMe = msg.firebaseUid == user.uid;
                  final parts = msg.moonPhase?.split('|') ?? [];
                  final avatarUrl = parts.length > 1 ? parts[1] : null;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isMe) ...[
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black26),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: avatarUrl != null && avatarUrl.isNotEmpty
                                  ? PremiumUI.networkImage(url: avatarUrl, fit: BoxFit.cover)
                                  : Icon(Iconsax.user, size: 12, color: PremiumTokens.activeAccent),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              if (!isMe)
                                Padding(
                                  padding: const EdgeInsets.only(left: 6, bottom: 2),
                                  child: Text(
                                    msg.title,
                                    style: PremiumTokens.sansStyle(fontSize: 10, color: PremiumTokens.textMuted, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? PremiumTokens.activeAccent.withValues(alpha: 0.15)
                                      : PremiumTokens.surfaceMain.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                                    bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                                  ),
                                  border: Border.all(
                                    color: isMe
                                        ? PremiumTokens.activeAccent.withValues(alpha: 0.25)
                                        : PremiumTokens.borderSubtle,
                                  ),
                                ),
                                child: Text(
                                  msg.content,
                                  style: PremiumTokens.sansStyle(
                                    color: PremiumTokens.textPrimary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black26),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: avatarUrl != null && avatarUrl.isNotEmpty
                                  ? PremiumUI.networkImage(url: avatarUrl, fit: BoxFit.cover)
                                  : Icon(Iconsax.user, size: 12, color: PremiumTokens.activeAccent),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
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
            padding: const EdgeInsets.all(4),
            borderRadius: 28,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _chatController,
                      style: PremiumTokens.sansStyle(color: PremiumTokens.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "Send message to Sangat...",
                        hintStyle: PremiumTokens.sansStyle(color: PremiumTokens.textMuted, fontSize: 12),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendChatMessage(),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _sendChatMessage,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: PremiumTokens.activeAccent.withValues(alpha: 0.15),
                      border: Border.all(color: PremiumTokens.activeAccent.withValues(alpha: 0.3)),
                    ),
                    child: Icon(Iconsax.send_1, size: 16, color: PremiumTokens.activeAccent),
                  ),
                ),
                const SizedBox(width: 4),
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
    HapticFeedback.lightImpact();
    ref.read(journalProvider.notifier).addChatMessage(text);
    _chatController.clear();
  }

  void _showPostDialog(BuildContext context) {
    final postTextController = TextEditingController();
    final videoUrlController = TextEditingController();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      barrierColor: PremiumTokens.scaffoldBg.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: PremiumUI.glassCard(
                padding: const EdgeInsets.all(28),
                borderRadius: 28,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "SHARE SATSANG REALIZATION",
                      style: PremiumTokens.displayStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: PremiumTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: postTextController,
                      maxLines: 5,
                      style: PremiumTokens.sansStyle(color: PremiumTokens.textPrimary, fontSize: 13).copyWith(height: 1.5),
                      decoration: InputDecoration(
                        hintText: "Write your spiritual realizations or quotes here...",
                        hintStyle: PremiumTokens.sansStyle(color: PremiumTokens.textMuted, fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: PremiumTokens.borderSubtle),
                        ),
                        filled: true,
                        fillColor: Colors.black26,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: videoUrlController,
                      style: PremiumTokens.sansStyle(color: PremiumTokens.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "Devotional YouTube/Video Link (Optional)",
                        hintStyle: PremiumTokens.sansStyle(color: PremiumTokens.textMuted, fontSize: 12),
                        prefixIcon: Icon(Iconsax.video, color: PremiumTokens.textMuted, size: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: PremiumTokens.borderSubtle),
                        ),
                        filled: true,
                        fillColor: Colors.black26,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: PremiumTokens.borderSubtle),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text("CLOSE", style: TextStyle(color: PremiumTokens.textMuted, fontSize: 11, letterSpacing: 1)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final text = postTextController.text.trim();
                              final video = videoUrlController.text.trim();
                              if (text.isNotEmpty) {
                                ref.read(journalProvider.notifier).addPost(text, video.isEmpty ? null : video);
                                Navigator.pop(ctx);
                                HapticFeedback.mediumImpact();
                                PremiumUI.showNotification(context, "Realization posted to Live Satsang");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PremiumTokens.activeAccent.withValues(alpha: 0.15),
                              side: BorderSide(color: PremiumTokens.activeAccent.withValues(alpha: 0.3)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text("SHARE", style: TextStyle(color: PremiumTokens.textPrimary, fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.bold)),
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
      },
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
                              : ListView.builder(
                                  physics: const BouncingScrollPhysics(),
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

                                    final isCommentLiked = ref.watch(likedCommentsProvider).contains(item.id);
                                    final commentLikesCount = isCommentLiked ? 1 : 0;

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
                                                        HapticFeedback.lightImpact();
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
                                              HapticFeedback.lightImpact();
                                              ref.read(likedCommentsProvider.notifier).toggleLike(item.id);
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
                                    borderRadius: BorderRadius.circular(17),
                                    child: user?.photoURL != null && user!.photoURL!.isNotEmpty
                                        ? PremiumUI.networkImage(url: user.photoURL!, fit: BoxFit.cover)
                                        : Icon(Iconsax.user, size: 14, color: PremiumTokens.activeAccent),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.black38,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(color: PremiumTokens.borderSubtle),
                                    ),
                                    child: TextField(
                                      controller: commentsController,
                                      style: PremiumTokens.sansStyle(color: PremiumTokens.textPrimary, fontSize: 13),
                                      decoration: InputDecoration(
                                        hintText: "Add comment...",
                                        hintStyle: PremiumTokens.sansStyle(color: PremiumTokens.textMuted, fontSize: 12),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () {
                                    final reply = commentsController.text.trim();
                                    if (reply.isNotEmpty) {
                                      HapticFeedback.lightImpact();
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
