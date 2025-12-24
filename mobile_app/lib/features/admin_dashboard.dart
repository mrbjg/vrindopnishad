import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _sanskritController = TextEditingController();
  final _translationController = TextEditingController();
  final _hindiController = TextEditingController();
  final _commentaryController = TextEditingController();

  String _selectedCategoryKey = 'shloka';

  static const Map<String, String> _categoryKeys = {
    'shloka': 'shlokas',
    'strotra': 'strotras',
    'poem': 'poems',
    'veda': 'vedas',
    'mantra': 'mantras',
    'story': 'stories',
  };

  File? _selectedImage;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _titleController.dispose();
    _sanskritController.dispose();
    _translationController.dispose();
    _hindiController.dispose();
    _commentaryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    HapticFeedback.lightImpact();
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  void _submitData(AppLocalization l) {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();

      final categoryName =
          _selectedCategoryKey[0].toUpperCase() +
          _selectedCategoryKey.substring(1);

      final newContent = SacredContent(
        id: const Uuid().v4(),
        title: _titleController.text,
        category: categoryName,
        sanskritText: _sanskritController.text,
        translation: _translationController.text,
        hindiMeaning: _hindiController.text,
        commentary: _commentaryController.text,
        imageUrl: _selectedImage?.path,
      );

      ref.read(sacredContentProvider.notifier).addContent(newContent);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(LucideIcons.sparkles, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                l.translate('publish_success'),
                style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppTheme.primaryColor,
          margin: const EdgeInsets.all(20),
        ),
      );

      _titleController.clear();
      _sanskritController.clear();
      _translationController.clear();
      _hindiController.clear();
      _commentaryController.clear();
      setState(() {
        _selectedImage = null;
        _selectedCategoryKey = 'shloka';
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = ref.watch(languageProvider);
    final l = AppLocalization(currentLanguage);
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Premium App Bar
            _buildAppBar(context, l, isDark),

            // Body content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image picker with glassmorphism
                      _buildImagePicker(
                        context,
                        l,
                        isDark,
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05),
                      const SizedBox(height: 32),

                      // Form fields with staggered animations
                      _buildGlassTextField(
                        context,
                        l.translate('title_label'),
                        _titleController,
                        LucideIcons.heading,
                        l.translate('enter_title'),
                        l,
                        gradientColors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryDark,
                        ],
                      ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05),
                      const SizedBox(height: 20),

                      _buildCategoryDropdown(
                        context,
                        l,
                        isDark,
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),
                      const SizedBox(height: 20),

                      _buildGlassTextField(
                        context,
                        l.translate('sanskrit_label'),
                        _sanskritController,
                        LucideIcons.languages,
                        l.translate('enter_sanskrit'),
                        l,
                        maxLines: 4,
                        gradientColors: [
                          AppTheme.glowPurple,
                          const Color(0xFFA78BFA),
                        ],
                      ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.05),
                      const SizedBox(height: 20),

                      _buildGlassTextField(
                        context,
                        l.translate('english_label'),
                        _translationController,
                        LucideIcons.scroll,
                        l.translate('enter_english'),
                        l,
                        maxLines: 3,
                        gradientColors: [
                          AppTheme.glowBlue,
                          const Color(0xFF60A5FA),
                        ],
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05),
                      const SizedBox(height: 20),

                      _buildGlassTextField(
                        context,
                        l.translate('hindi_label'),
                        _hindiController,
                        LucideIcons.book,
                        l.translate('enter_hindi'),
                        l,
                        maxLines: 3,
                        gradientColors: [
                          AppTheme.glowPink,
                          const Color(0xFFF472B6),
                        ],
                      ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.05),
                      const SizedBox(height: 20),

                      _buildGlassTextField(
                        context,
                        l.translate('commentary_label'),
                        _commentaryController,
                        LucideIcons.messageCircle,
                        l.translate('enter_commentary'),
                        l,
                        maxLines: 4,
                        gradientColors: [
                          AppTheme.glowTeal,
                          const Color(0xFF2DD4BF),
                        ],
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.05),
                      const SizedBox(height: 40),

                      // Premium submit button
                      _buildSubmitButton(
                        context,
                        l,
                      ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppLocalization l, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back button with glass effect
          PressableScale(
            onTap: () => Navigator.pop(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                    ),
                  ),
                  child: Icon(
                    LucideIcons.arrowLeft,
                    color: AppTheme.textPrimary(context),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.translate('add_wisdom'),
                  style: GoogleFonts.spectral(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary(context),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Create sacred content",
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: AppTheme.textMuted(context),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 50.ms).slideX(begin: -0.1),
          // Animated sparkle icon
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor.withOpacity(
                        0.1 + _pulseController.value * 0.1,
                      ),
                      AppTheme.glowPurple.withOpacity(
                        0.1 + _pulseController.value * 0.1,
                      ),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(
                        0.2 * _pulseController.value,
                      ),
                      blurRadius: 20,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.wand2,
                  color: AppTheme.primaryColor,
                  size: 22,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(
    BuildContext context,
    AppLocalization l,
    bool isDark,
  ) {
    return PressableScale(
      onTap: _pickImage,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                width: 2,
              ),
              boxShadow: AppTheme.softShadow(context),
              image: _selectedImage != null
                  ? DecorationImage(
                      image: FileImage(_selectedImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _selectedImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.15),
                              AppTheme.glowPurple.withOpacity(0.15),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.imagePlus,
                          size: 36,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l.translate('add_cover'),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: AppTheme.textPrimary(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.translate('optional_limit'),
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppTheme.textMuted(context),
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      // Dark overlay for better text visibility
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            LucideIcons.pencil,
                            size: 18,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassTextField(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon,
    String hint,
    AppLocalization l, {
    int maxLines = 1,
    List<Color>? gradientColors,
  }) {
    final isDark = AppTheme.isDark(context);
    final colors =
        gradientColors ?? [AppTheme.primaryColor, AppTheme.primaryDark];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 14, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary(context),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.04),
                  width: 1.5,
                ),
                boxShadow: AppTheme.softShadow(context),
              ),
              child: TextFormField(
                controller: controller,
                maxLines: maxLines,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: AppTheme.textPrimary(context),
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: GoogleFonts.outfit(
                    color: AppTheme.textMuted(context),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.all(18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: colors[0], width: 2),
                  ),
                ),
                validator: (value) => value!.isEmpty
                    ? "${l.translate('please_enter')} $label"
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(
    BuildContext context,
    AppLocalization l,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.glowOrange, const Color(0xFFFB923C)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                LucideIcons.grid,
                size: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l.translate('category_label'),
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary(context),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.04),
                  width: 1.5,
                ),
                boxShadow: AppTheme.softShadow(context),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedCategoryKey,
                dropdownColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: AppTheme.textPrimary(context),
                ),
                icon: Icon(
                  LucideIcons.chevronDown,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _categoryKeys.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getCategoryIcon(entry.key),
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(l.translate(entry.value)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedCategoryKey = val!);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String key) {
    switch (key) {
      case 'shloka':
        return LucideIcons.scroll;
      case 'strotra':
        return LucideIcons.music;
      case 'poem':
        return LucideIcons.feather;
      case 'veda':
        return LucideIcons.bookOpen;
      case 'mantra':
        return LucideIcons.sparkles;
      case 'story':
        return LucideIcons.book;
      default:
        return LucideIcons.file;
    }
  }

  Widget _buildSubmitButton(BuildContext context, AppLocalization l) {
    return PressableScale(
      onTap: () => _submitData(l),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryDark,
              const Color(0xFFBF8F20),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 12),
              spreadRadius: -8,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.sparkles, size: 22, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              l.translate('publish_wisdom'),
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
