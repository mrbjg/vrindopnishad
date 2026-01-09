import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../core/content_provider.dart';

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
    return Screenshot(
      controller: screenshotController,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F0F1A)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEDA638).withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top decoration
            Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFEDA638),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEDA638).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                content.category.toUpperCase(),
                style: GoogleFonts.inter(
                  color: const Color(0xFFEDA638),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Sanskrit Text
            if (content.sanskritText.isNotEmpty)
              Text(
                content.sanskritText,
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansDevanagari(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
              ),

            const SizedBox(height: 20),

            // Divider
            Container(
              width: 80,
              height: 1,
              color: Colors.white.withOpacity(0.2),
            ),

            const SizedBox(height: 20),

            // Translation
            if (content.translation.isNotEmpty)
              Text(
                content.translation,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
              ),

            const SizedBox(height: 24),

            // Title
            Text(
              '— ${content.title}',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFFEDA638),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 32),

            // Watermark
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDA638),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'व',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Vrindopnishad',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
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

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'vrindopnishad_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      // Share the image
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${content.title}\n\nShared from Vrindopnishad 🙏',
        subject: content.title,
      );
    } catch (e) {
      // Close loading indicator if still showing
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: $e'),
            backgroundColor: Colors.red,
          ),
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
