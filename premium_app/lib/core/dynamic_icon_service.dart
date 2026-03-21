import 'package:flutter_dynamic_icon/flutter_dynamic_icon.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'providers.dart';

final dynamicIconServiceProvider = Provider((ref) => DynamicIconService(ref));

class DynamicIconService {
  final Ref _ref;
  
  DynamicIconService(this._ref) {
    // Listen to Naam Jap state to trigger icon updates
    _ref.listen(naamJapStateProvider, (previous, next) {
      _checkAndUpdateIcon(next);
    });
  }

  Future<void> _checkAndUpdateIcon(NaamJapState state) async {
    try {
      if (!Platform.isAndroid && !Platform.isIOS) return;

      String? targetIcon;
      
      // 1 Mala = 108 chants
      final totalMalas = state.total ~/ 108;
      final todayMalas = state.today ~/ 108;

      // Milestone Logic (Highest first)
      if (totalMalas >= 1008) {
        targetIcon = 'MainActivityDivine';
      } else if (totalMalas >= 108) {
        targetIcon = 'MainActivityGolden';
      } else if (todayMalas >= 21) {
        targetIcon = 'MainActivityRadiant';
      } else {
        // Default to Starter (Level 1)
        // Only set if we were on something else, or if it's the first time
        targetIcon = 'MainActivityStarter';
      }

      final currentIcon = await FlutterDynamicIcon.getAlternateIconName();
      
      if (currentIcon != targetIcon) {
        // To avoid annoying the user with multiple batch icon changes, 
        // we only set it if it definitely changed level.
        await FlutterDynamicIcon.setAlternateIconName(targetIcon == 'MainActivityStarter' ? null : targetIcon);
      }
    } catch (e) {
      // Fail silently for icons to avoid breaking the chant experience
      print('Error updating dynamic icon: $e');
    }
  }

  // Debug method to force an icon change (useful for testing)
  Future<void> forceSetIcon(String? iconName) async {
    await FlutterDynamicIcon.setAlternateIconName(iconName);
  }
}
