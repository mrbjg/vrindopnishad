import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final gamificationServiceProvider = Provider<GamificationService>((ref) {
  return GamificationService(ref);
});

class GamificationService {
  final Ref ref;

  GamificationService(this.ref);

  /// Award XP and handle progression (DISABLED)
  Future<void> awardXP(
    BuildContext context, 
    int amount, 
    String reason, {
    bool triggerCheck = true,
  }) async {
    // Gamification system removed for now.
    return;
  }
}
