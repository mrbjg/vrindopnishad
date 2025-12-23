import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
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

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _sanskritController = TextEditingController();
  final _translationController = TextEditingController();
  final _hindiController = TextEditingController();
  final _commentaryController = TextEditingController();

  // Use internal keys for categories (not localized)
  String _selectedCategoryKey = 'shloka';

  // Category mapping: internal key -> localization key
  static const Map<String, String> _categoryKeys = {
    'shloka': 'shlokas',
    'strotra': 'strotras',
    'poem': 'poems',
    'veda': 'vedas',
    'mantra': 'mantras',
    'story': 'stories',
  };

  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  void _submitData(AppLocalization l) {
    if (_formKey.currentState!.validate()) {
      // Store the English category name (capitalized internal key)
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
          content: Text(l.translate('publish_success')),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AppTheme.primaryColor,
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

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        LucideIcons.arrowLeft,
                        color: AppTheme.textPrimary(context),
                        size: 20,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      l.translate('add_wisdom'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spectral(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),
            // Body content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image picker
                      _buildImagePicker(context, l),
                      const SizedBox(height: 28),

                      // Form fields
                      _buildTextField(
                        context,
                        l.translate('title_label'),
                        _titleController,
                        LucideIcons.type,
                        l.translate('enter_title'),
                        l,
                      ),
                      const SizedBox(height: 20),

                      _buildCategoryDropdown(context, l),
                      const SizedBox(height: 20),

                      _buildTextField(
                        context,
                        l.translate('sanskrit_label'),
                        _sanskritController,
                        LucideIcons.languages,
                        l.translate('enter_sanskrit'),
                        l,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        context,
                        l.translate('english_label'),
                        _translationController,
                        LucideIcons.fileText,
                        l.translate('enter_english'),
                        l,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        context,
                        l.translate('hindi_label'),
                        _hindiController,
                        LucideIcons.book,
                        l.translate('enter_hindi'),
                        l,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        context,
                        l.translate('commentary_label'),
                        _commentaryController,
                        LucideIcons.messageSquare,
                        l.translate('enter_commentary'),
                        l,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 40),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _submitData(l),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.sparkles, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                l.translate('publish_wisdom'),
                                style: GoogleFonts.outfit(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ), // Close Expanded
          ], // Close Column children
        ), // Close Column
      ), // Close SafeArea
    );
  }

  Widget _buildImagePicker(BuildContext context, AppLocalization l) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(24),
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
                      color: AppTheme.surfaceColor(context),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.imagePlus,
                      size: 32,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.translate('add_cover'),
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      color: AppTheme.textMuted(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.translate('optional_limit'),
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppTheme.textMuted(context),
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor(context),
                        borderRadius: BorderRadius.circular(10),
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
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon,
    String hint,
    AppLocalization l, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary(context),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor(context),
            borderRadius: BorderRadius.circular(18),
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
              hintStyle: GoogleFonts.outfit(color: AppTheme.textMuted(context)),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(icon, color: AppTheme.primaryColor, size: 20),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              filled: true,
              fillColor: AppTheme.cardColor(context),
              contentPadding: const EdgeInsets.all(18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
            validator: (value) =>
                value!.isEmpty ? "${l.translate('please_enter')} $label" : null,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(BuildContext context, AppLocalization l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.translate('category_label'),
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary(context),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor(context),
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppTheme.softShadow(context),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCategoryKey,
            dropdownColor: AppTheme.cardColor(context),
            style: GoogleFonts.outfit(
              fontSize: 15,
              color: AppTheme.textPrimary(context),
            ),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  LucideIcons.grid,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              filled: true,
              fillColor: AppTheme.cardColor(context),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
            items: _categoryKeys.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(l.translate(entry.value)),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedCategoryKey = val!),
          ),
        ),
      ],
    );
  }
}
