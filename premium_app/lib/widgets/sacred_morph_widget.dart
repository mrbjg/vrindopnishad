import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(Iconsax.magic_star, size: size * 0.5, color: color),
    );
  }
}
