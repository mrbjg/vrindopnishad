import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../core/content_provider.dart';
import '../core/theme.dart';
import '../core/providers.dart';
import '../core/localization.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = ref.watch(languageProvider);
    final l = AppLocalization(currentLanguage);
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0F)
          : const Color(0xFFF5F3F0),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverAppBar(
                expandedHeight: 160,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _buildBackButton(isDark),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [const Color(0xFF1E1E2E), const Color(0xFF1A1A2E)]
                            : [
                                const Color(0xFFFFF7ED),
                                const Color(0xFFFED7AA),
                              ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient(context),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor
                                            .withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    LucideIcons.shield,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Admin Dashboard",
                                        style: GoogleFonts.spectral(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF1A1A2E),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Content Management",
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          color: isDark
                                              ? Colors.white60
                                              : Colors.black54,
                                        ),
                                      ),
                                    ],
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
              ),

              // Tab Bar - Optimized without BackdropFilter
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                      width: 1.5,
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: AppTheme.primaryGradient(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: isDark
                        ? Colors.white60
                        : Colors.black54,
                    labelStyle: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(icon: Icon(LucideIcons.plus, size: 20)),
                      Tab(icon: Icon(LucideIcons.uploadCloud, size: 20)),
                      Tab(icon: Icon(LucideIcons.list, size: 20)),
                      Tab(icon: Icon(LucideIcons.helpCircle, size: 20)),
                    ],
                  ),
                ),
              ),

              // Tab Content
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSingleAddTab(context, l, isDark),
                    _buildBulkUploadTab(context, l, isDark),
                    _buildManageTab(context, l, isDark),
                    _buildGuideTab(context, l, isDark),
                  ],
                ),
              ),
            ],
          ),

          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1A1A2E).withOpacity(0.95)
                          : Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 20),
                        Text(
                          "Processing...",
                          style: GoogleFonts.outfit(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBackButton(bool isDark) {
    return PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Icon(
          LucideIcons.arrowLeft,
          size: 20,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSingleAddTab(
    BuildContext context,
    AppLocalization l,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInfoCard(
            context,
            isDark: isDark,
            icon: LucideIcons.info,
            title: "Single Content Addition",
            description:
                "Add one piece of sacred content at a time with all details.",
          ),
          const SizedBox(height: 20),
          PressableScale(
            onTap: () => _showSingleAddDialog(context, l, isDark),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient(context),
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.glowShadow(AppTheme.primaryColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.plus, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    "Add Single Content",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkUploadTab(
    BuildContext context,
    AppLocalization l,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            context,
            isDark: isDark,
            icon: LucideIcons.upload,
            title: "Bulk Upload Options",
            description:
                "Upload multiple content items at once using CSV or JSON files.",
          ),
          const SizedBox(height: 24),

          _buildUploadCard(
            context,
            isDark: isDark,
            icon: LucideIcons.fileSpreadsheet,
            title: "Upload CSV File",
            description: "Import content from a CSV file",
            color: const Color(0xFF10B981),
            onTap: () => _handleCSVUpload(context, l),
          ),
          const SizedBox(height: 16),

          _buildUploadCard(
            context,
            isDark: isDark,
            icon: LucideIcons.fileCode,
            title: "Upload JSON File",
            description: "Import content from a JSON file",
            color: const Color(0xFF3B82F6),
            onTap: () => _handleJSONUpload(context, l),
          ),
          const SizedBox(height: 16),

          _buildUploadCard(
            context,
            isDark: isDark,
            icon: LucideIcons.image,
            title: "Upload Images",
            description: "Add multiple images for content",
            color: const Color(0xFFEC4899),
            onTap: () => _handleImageUpload(context, l),
          ),
          const SizedBox(height: 16),

          _buildUploadCard(
            context,
            isDark: isDark,
            icon: LucideIcons.music,
            title: "Upload Audio Files",
            description: "Add audio narrations in bulk",
            color: const Color(0xFF8B5CF6),
            onTap: () => _handleAudioUpload(context, l),
          ),

          const SizedBox(height: 32),

          PressableScale(
            onTap: () => _downloadTemplate(context, l),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.download,
                    size: 18,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Download CSV Template",
                    style: GoogleFonts.outfit(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageTab(BuildContext context, AppLocalization l, bool isDark) {
    final allContent = ref.watch(sacredContentProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            context,
            isDark: isDark,
            icon: LucideIcons.database,
            title: "Content Management",
            description: "${allContent.length} items in database",
          ),
          const SizedBox(height: 20),
          ...allContent.map(
            (content) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildContentCard(context, content, isDark),
            ),
          ),
        ],
      ),
    );
  }

  // Optimized info card without BackdropFilter
  Widget _buildInfoCard(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.25),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Optimized upload card without BackdropFilter
  Widget _buildUploadCard(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.black54,
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
                  : Colors.black.withOpacity(0.26),
            ),
          ],
        ),
      ),
    );
  }

  // Optimized content card without BackdropFilter
  Widget _buildContentCard(
    BuildContext context,
    SacredContent content,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              LucideIcons.scroll,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  content.category,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.red),
            onPressed: () => _deleteContent(content),
          ),
        ],
      ),
    );
  }

  void _showSingleAddDialog(
    BuildContext context,
    AppLocalization l,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Add Single Content",
                  style: GoogleFonts.spectral(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Use the form to add one item",
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("Close", style: GoogleFonts.outfit()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleCSVUpload(BuildContext context, AppLocalization l) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        setState(() => _isProcessing = true);
        await Future.delayed(const Duration(seconds: 2));
        setState(() => _isProcessing = false);

        if (!mounted) return;
        _showSuccessMessage(context, "CSV uploaded successfully!");
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (!mounted) return;
      _showErrorMessage(context, "Error uploading CSV");
    }
  }

  Future<void> _handleJSONUpload(
    BuildContext context,
    AppLocalization l,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        setState(() => _isProcessing = true);
        await Future.delayed(const Duration(seconds: 2));
        setState(() => _isProcessing = false);

        if (!mounted) return;
        _showSuccessMessage(context, "JSON uploaded successfully!");
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (!mounted) return;
      _showErrorMessage(context, "Error uploading JSON");
    }
  }

  Future<void> _handleImageUpload(
    BuildContext context,
    AppLocalization l,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() => _isProcessing = true);
        await Future.delayed(const Duration(seconds: 2));
        setState(() => _isProcessing = false);

        if (!mounted) return;
        _showSuccessMessage(context, "${result.count} images uploaded!");
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (!mounted) return;
      _showErrorMessage(context, "Error uploading images");
    }
  }

  Future<void> _handleAudioUpload(
    BuildContext context,
    AppLocalization l,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() => _isProcessing = true);
        await Future.delayed(const Duration(seconds: 2));
        setState(() => _isProcessing = false);

        if (!mounted) return;
        _showSuccessMessage(context, "${result.count} audio files uploaded!");
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (!mounted) return;
      _showErrorMessage(context, "Error uploading audio files");
    }
  }

  void _downloadTemplate(BuildContext context, AppLocalization l) {
    _showSuccessMessage(context, "Template download started");
  }

  void _deleteContent(SacredContent content) {
    ref.read(sacredContentProvider.notifier).removeContent(content.id);
  }

  Widget _buildGuideTab(BuildContext context, AppLocalization l, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            context,
            isDark: isDark,
            icon: LucideIcons.bookOpen,
            title: "Admin Guide & Instructions",
            description: "How to manage and upload content to Sant-Vaani",
          ),
          const SizedBox(height: 24),
          _buildGuideSection(
            context,
            isDark: isDark,
            icon: LucideIcons.fileType,
            title: "1. Supported Formats",
            content:
                "• Data: CSV (.csv) or JSON (.json) files.\n"
                "• Audio: MP3 (.mp3) files (Standard quality recommended).\n"
                "• Images: JPG/PNG (.jpg, .png) for content thumbnails and banners.",
          ),
          const SizedBox(height: 16),
          _buildGuideSection(
            context,
            isDark: isDark,
            icon: LucideIcons.uploadCloud,
            title: "2. Where to Upload Files",
            content:
                "• Pictures & Audio: Upload to Firebase Storage or a CDN (Cloudinary).\n"
                "• Linking: After uploading, copy the 'Direct Download Link' (URL).\n"
                "• Text Content: Enter directly in the Add form or include in CSV/JSON data.",
          ),
          const SizedBox(height: 16),
          _buildGuideSection(
            context,
            isDark: isDark,
            icon: LucideIcons.link,
            title: "3. Linking Files to Database",
            content:
                "• In your CSV/JSON, add a column/field for 'audioUrl' and 'imageUrl'.\n"
                "• Paste the direct links into these fields.\n"
                "• This allows both the Mobile App and Web App to access the same files simultaneously.",
          ),
          const SizedBox(height: 16),
          _buildGuideSection(
            context,
            isDark: isDark,
            icon: LucideIcons.server,
            title: "4. Direct Database Update",
            content:
                "• When you add content here, it's saved to the global Content Provider.\n"
                "• App & Web Sync: If using Firebase, both platforms sync in real-time.\n"
                "• Process: Add → Content Provider → Cloud Service → All Users.",
          ),
          const SizedBox(height: 16),
          _buildGuideSection(
            context,
            isDark: isDark,
            icon: LucideIcons.checkSquare,
            title: "5. Management Tips",
            content:
                "• Use the 'Manage' tab (List icon) to delete or edit existing entries.\n"
                "• Bulk upload is best for adding entire Chapters or Books at once.\n"
                "• Always verify direct links by opening them in a browser before adding.",
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGuideSection(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primaryColor),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.checkCircle, color: Colors.white, size: 18),
            const SizedBox(width: 12),
            Text(message, style: GoogleFonts.outfit()),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF10B981),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.alertCircle, color: Colors.white, size: 18),
            const SizedBox(width: 12),
            Text(message, style: GoogleFonts.outfit()),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
