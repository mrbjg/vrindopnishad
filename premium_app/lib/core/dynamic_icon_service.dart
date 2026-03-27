import 'package:flutter_dynamic_icon_plus/flutter_dynamic_icon_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'providers.dart';
import 'stats_provider.dart';

final dynamicIconServiceProvider = Provider((ref) => DynamicIconService(ref));

class DynamicIconService {
  final Ref _ref;
  DateTime _lastCheckedDate = DateTime.now();
  
  DynamicIconService(this._ref) {
    Future.microtask(() {
      // Listen to Naam Jap state - Throttle checks to significant milestones only
      _ref.listen(naamJapStateProvider, (previous, next) {
        // Only check every 21 Japs (the first milestone) to avoid main-thread lag
        if (next.today % 21 == 0 || next.today == 1) {
          _checkAndUpdateIcon();
        }
      });
      
      // Listen to User Stats (for streaks and levels)
      _ref.listen(userStatsProvider, (previous, next) {
        // Stats change less frequently than Jap count
        _checkAndUpdateIcon();
      });
      
      // Listen for toggle changes
      _ref.listen(dynamicIconEnabledProvider, (previous, next) {
        if (!next) {
          FlutterDynamicIconPlus.setAlternateIconName(iconName: 'MainActivityStarter');
        } else {
          _checkAndUpdateIcon();
        }
      });

      // Check on initial load
      _checkAndUpdateIcon();
    });
  }

  /// Checks if the day has changed since the last update.
  Future<void> _checkMidnightReset() async {
    if (kIsWeb) return;
    
    final now = DateTime.now();
    if (now.day != _lastCheckedDate.day || 
        now.month != _lastCheckedDate.month || 
        now.year != _lastCheckedDate.year) {
      
      _lastCheckedDate = now;
      
      try {
        final currentIcon = await FlutterDynamicIconPlus.alternateIconName;
        if (currentIcon != 'MainActivityStarter') {
          await FlutterDynamicIconPlus.setAlternateIconName(iconName: 'MainActivityStarter');
        }
      } catch (e) {
        // Silent fail
      }
    }
  }

  Future<void> _checkAndUpdateIcon() async {
    // Respect user preference and platform constraints
    if (kIsWeb || !_ref.read(dynamicIconEnabledProvider)) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;

    try {
      // Midnight reset check
      await _checkMidnightReset();

      final japState = _ref.read(naamJapStateProvider);
      final statsState = _ref.read(userStatsProvider).value;
      
      String targetIcon = 'MainActivityStarter';
      
      final todayMalas = japState.today / 108.0; 
      final streak = statsState?.streakCount ?? 0;
      final level = statsState?.level ?? 1;

      // Milestone Logic (Highest first)
      if (todayMalas >= 108 || (streak >= 30 && todayMalas >= 21) || level >= 50) {
        targetIcon = 'MainActivityDivine';
      } 
      else if (todayMalas >= 54 || (streak >= 7 && todayMalas >= 11) || level >= 20) {
        targetIcon = 'MainActivityGolden';
      } 
      else if (todayMalas >= 0.19) { // ~21 Japs
        targetIcon = 'MainActivityRadiant';
      } 

      final currentIcon = await FlutterDynamicIconPlus.alternateIconName;
      
      if (currentIcon != targetIcon) {
        await FlutterDynamicIconPlus.setAlternateIconName(
          iconName: targetIcon,
        );
      }
    } catch (e) {
      // Fail silently to avoid breaking the chant experience
    }

  }


  // Debug method to force an icon change (useful for testing)
  Future<void> forceSetIcon(String? iconName) async {
    await FlutterDynamicIconPlus.setAlternateIconName(iconName: iconName);
  }
}
