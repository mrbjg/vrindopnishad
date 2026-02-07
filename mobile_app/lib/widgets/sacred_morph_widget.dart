import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// A simple animated sacred symbol widget
class SacredMorphWidget extends StatelessWidget {
  final double size;
  final Color color;

  const SacredMorphWidget({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(LucideIcons.sparkles, size: size * 0.5, color: color),
    );
  }
}
