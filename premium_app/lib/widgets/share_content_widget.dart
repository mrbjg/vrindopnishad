import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../core/content_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../core/design_system.dart';
import '../core/mood_theme_provider.dart';
import 'package:iconsax/iconsax.dart';

/// Widget and utilities for sharing content as beautiful quote images
class ShareContentWidget extends StatelessWidget {
  final SacredContent content;
  final ScreenshotController screenshotController;

  const ShareContentWidget({
    super.key,
    required this.content,
    required this.screenshotController,
  });

  @override
  Widget build(BuildContext context) {
    // Sync the active theme with current BuildContext to make colors adaptive
    PremiumTokens.of(context);

    // Dynamic size scaling based on content length to prevent image clipping/overflows
    final int totalLength = content.sanskritText.length + content.translation.length;
    double sanskritFontSize = 22;
    double translationFontSize = 14;
    double verticalSpacing = 24;
    double dividerSpacing = 20;

    if (totalLength > 450) {
      sanskritFontSize = 14;
      translationFontSize = 10;
      verticalSpacing = 8;
      dividerSpacing = 10;
    } else if (totalLength > 280) {
      sanskritFontSize = 16;
      translationFontSize = 11;
      verticalSpacing = 12;
      dividerSpacing = 12;
    } else if (totalLength > 160) {
      sanskritFontSize = 18;
      translationFontSize = 12;
      verticalSpacing = 16;
      dividerSpacing = 16;
    }

    return Screenshot(
      controller: screenshotController,
      child: Container(
        width: 400,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: PremiumTokens.isMoodActive
                ? AppMoodThemes.getPalette(PremiumTokens.currentMood).backgroundGradient
                : [
                    PremiumTokens.surfaceMain,
                    PremiumTokens.scaffoldBg,
                  ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: PremiumTokens.borderSubtle,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: PremiumTokens.activeAccent.withValues(alpha: 0.15),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top decoration
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: PremiumTokens.activeAccent,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            SizedBox(height: verticalSpacing),

            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: PremiumTokens.activeAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: PremiumTokens.activeAccent.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Text(
                content.category.toUpperCase(),
                style: GoogleFonts.outfit(
                  color: PremiumTokens.activeAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            SizedBox(height: verticalSpacing),

            // Sanskrit Text
            if (content.sanskritText.isNotEmpty)
              Text(
                content.sanskritText,
                textAlign: TextAlign.center,
                style: GoogleFonts.laila(
                  color: PremiumTokens.textPrimary,
                  fontSize: sanskritFontSize,
                  fontWeight: FontWeight.w600,
                  height: 1.6,
                ),
              ),

            SizedBox(height: dividerSpacing),

            // Ornament Divider
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        PremiumTokens.activeAccent.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'ॐ',
                    style: GoogleFonts.spectral(
                      color: PremiumTokens.activeAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: 50,
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        PremiumTokens.activeAccent.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: dividerSpacing),

            // Translation
            if (content.translation.isNotEmpty)
              Text(
                content.translation,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: PremiumTokens.textSecondary,
                  fontSize: translationFontSize,
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
              ),

            SizedBox(height: verticalSpacing),

            // Title
            Text(
              '— ${content.title}',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: PremiumTokens.activeAccent,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 24),

            // Divider
            Container(
              width: double.infinity,
              height: 1,
              color: PremiumTokens.borderSubtle,
            ),
            const SizedBox(height: 16),

            // Watermark & Social Advertisement Section (Encapsulated modern card footer)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: PremiumTokens.isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.black.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: PremiumTokens.borderSubtle,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App/Site Branding
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: PremiumTokens.activeGradient,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: PremiumTokens.activeAccent.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'ॐ',
                            style: GoogleFonts.spectral(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vrindopnishad',
                            style: GoogleFonts.outfit(
                              color: PremiumTokens.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'vrindopnishad.in',
                            style: GoogleFonts.manrope(
                              color: PremiumTokens.activeAccent,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Modern Advertising Handles
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // YouTube Handle Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: PremiumTokens.isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: PremiumTokens.borderSubtle,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Iconsax.video_play5,
                              size: 11,
                              color: Color(0xFFFF0000), // Brand color for YouTube
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'vrindopnishad',
                              style: GoogleFonts.manrope(
                                color: PremiumTokens.textSecondary,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Instagram Handle Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: PremiumTokens.isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: PremiumTokens.borderSubtle,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Iconsax.instagram5,
                              size: 11,
                              color: Color(0xFFE1306C), // Brand color for Instagram
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '@vrindopnishad',
                              style: GoogleFonts.manrope(
                                color: PremiumTokens.textSecondary,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
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
          ],
        ),
      ),
    );
  }
}

/// Utility class for sharing content
class ShareContentHelper {
  static final ScreenshotController _screenshotController =
      ScreenshotController();

  /// Capture and share content as an image
  static Future<void> shareAsImage(
    BuildContext context,
    SacredContent content,
  ) async {
    BuildContext? dialogContext;
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (innerContext) {
          dialogContext = innerContext;
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEDA638)),
            ),
          );
        },
      );

      // Create the widget to capture
      final widget = ShareContentWidget(
        content: content,
        screenshotController: _screenshotController,
      );

      // Capture the widget, passing the parent context to inherit the active theme and View tree root
      final Uint8List imageBytes = await _screenshotController
          .captureFromWidget(
            widget,
            context: context,
            delay: const Duration(milliseconds: 100),
            pixelRatio: 3.0,
          );

      // Close loading indicator
      if (dialogContext != null && dialogContext!.mounted) {
        Navigator.of(dialogContext!).pop();
        dialogContext = null;
      }

      // Share logic
      if (kIsWeb) {
        await Share.shareXFiles(
          [XFile.fromData(imageBytes, name: 'vrindopnishad.png', mimeType: 'image/png')],
          text: '🕉️ ${content.title} 🕉️\n\nRead more on Sant-Vaani: https://vrindopnishad.in 🙏',
          subject: content.title,
        );
      } else {
        // Save to temp file for mobile/desktop
        final tempDir = await getTemporaryDirectory();
        final fileName = 'vrindopnishad_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(imageBytes);

        // Share the image
        await Share.shareXFiles(
          [XFile(file.path)],
          text: '🕉️ ${content.title} 🕉️\n\nRead more on Sant-Vaani: https://vrindopnishad.in 🙏',
          subject: content.title,
        );
      }
    } catch (e) {
      // Close loading indicator if still showing
      if (dialogContext != null && dialogContext!.mounted) {
        Navigator.of(dialogContext!).pop();
        dialogContext = null;
      }
      if (context.mounted) {
        PremiumUI.showNotification(
          context, 
          'Error sharing: $e',
          icon: Iconsax.info_circle,
          color: Colors.redAccent,
        );
      }
    }
  }

  /// Share content as text
  static Future<void> shareAsText(SacredContent content) async {
    final List<String> parts = [
      "🕉️ ${content.title} 🕉️",
      if (content.sanskritText.isNotEmpty) content.sanskritText,
      if (content.translation.isNotEmpty) "Translation:\n${content.translation}",
      if (content.hindiMeaning.isNotEmpty) "Meaning:\n${content.hindiMeaning}",
      "— Shared from Sant-Vaani (Vrindopnishad) 🙏\n📲 Experience the Divine Path & Preserves our Sanskriti: https://vrindopnishad.in"
    ];
    final text = parts.join("\n\n");

    await Share.share(text, subject: content.title);
  }
}
