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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
            // Scrollable text content area to dynamically manage overflows
            Flexible(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(), // Pure static rendering
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
                        style: GoogleFonts.notoSansDevanagari(
                          color: PremiumTokens.textPrimary,
                          fontSize: sanskritFontSize,
                          fontWeight: FontWeight.w500,
                          height: 1.6,
                        ),
                      ),

                    SizedBox(height: dividerSpacing),

                    // Divider
                    Container(
                      width: 80,
                      height: 1,
                      color: PremiumTokens.borderSubtle,
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
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Divider
            Container(
              width: double.infinity,
              height: 1,
              color: PremiumTokens.borderSubtle,
            ),
            const SizedBox(height: 16),

            // Watermark & Social Advertisement Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // App/Site Branding
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: PremiumTokens.activeGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'ॐ',
                          style: GoogleFonts.spectral(
                            color: Colors.white,
                            fontSize: 16,
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
                          ),
                        ),
                        Text(
                          'Vaidik Sanskriti',
                          style: GoogleFonts.manrope(
                            color: PremiumTokens.textMuted,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.video_play5,
                          size: 13,
                          color: PremiumTokens.activeAccent,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'vrindopnishad',
                          style: GoogleFonts.manrope(
                            color: PremiumTokens.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.instagram5,
                          size: 13,
                          color: PremiumTokens.activeAccent,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '@vrindopnishad',
                          style: GoogleFonts.manrope(
                            color: PremiumTokens.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
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
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEDA638)),
          ),
        ),
      );

      // Create the widget to capture
      final widget = ShareContentWidget(
        content: content,
        screenshotController: _screenshotController,
      );

      // Capture the widget
      final Uint8List imageBytes = await _screenshotController
          .captureFromWidget(
            widget,
            delay: const Duration(milliseconds: 100),
            pixelRatio: 3.0,
          );

      // Close loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // if (imageBytes == null) {
      //   throw Exception('Failed to capture image');
      // }

      // Share logic
      if (kIsWeb) {
        await Share.shareXFiles(
          [XFile.fromData(imageBytes, name: 'vrindopnishad.png', mimeType: 'image/png')],
          text: '${content.title}\n\nShared from Vrindopnishad 🙏',
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
          text: '${content.title}\n\nShared from Vrindopnishad 🙏',
          subject: content.title,
        );
      }
    } catch (e) {
      // Close loading indicator if still showing
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
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
    final text =
        '''
${content.title}

${content.sanskritText}

${content.translation}

${content.hindiMeaning}

— Shared from Vrindopnishad 🙏
''';

    await Share.share(text, subject: content.title);
  }
}
