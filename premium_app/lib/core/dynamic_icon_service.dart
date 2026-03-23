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
    // Listen to Naam Jap state to trigger icon updates
    _ref.listen(naamJapStateProvider, (previous, next) {
      _checkAndUpdateIcon();
    });
    
    // Listen to User Stats (for streaks and levels)
    _ref.listen(userStatsProvider, (previous, next) {
      _checkAndUpdateIcon();
    });
    
    // Listen for toggle changes to reset if disabled
    _ref.listen(dynamicIconEnabledProvider, (previous, next) {
      if (!next) {
        // Explicitly return to starter icon (vaani_icon.png)
        FlutterDynamicIconPlus.setAlternateIconName(iconName: 'MainActivityStarter');
      } else {
        _checkAndUpdateIcon();
      }
    });

    // Check and apply correct icon on service initialization
    _checkAndUpdateIcon();
    
    // Check for midnight reset
    _checkMidnightReset();
  }

  /// Checks if the day has changed since the last update.
  /// If it's a new day, resets the icon to default (Starter).
  Future<void> _checkMidnightReset() async {
    final now = DateTime.now();
    if (now.day != _lastCheckedDate.day || 
        now.month != _lastCheckedDate.month || 
        now.year != _lastCheckedDate.year) {
      
      _lastCheckedDate = now;
      
      try {
        if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;
        
        final currentIcon = await FlutterDynamicIconPlus.alternateIconName;
        if (currentIcon != 'MainActivityStarter') {
          // Reset to default at midnight
          await FlutterDynamicIconPlus.setAlternateIconName(iconName: 'MainActivityStarter');
        }
      } catch (e) {
        print('Error resetting icon at midnight: $e');
      }
    }
  }

  Future<void> _checkAndUpdateIcon() async {
    // Respect user preference
    if (!_ref.read(dynamicIconEnabledProvider)) return;

    try {
      if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

      // Always check for midnight reset first
      await _checkMidnightReset();

      final japState = _ref.read(naamJapStateProvider);
      final statsState = _ref.read(userStatsProvider).value;
      
      String? targetIcon;
      
      // Daily Milestones (Duolingo Style)
      final todayMalas = japState.today ~/ 108;
      final streak = statsState?.streakCount ?? 0;
      final level = statsState?.level ?? 1;

      // Milestone Logic (Highest first)
      // Divine: 108+ Malas Today OR Legendary Status (Streak 30+ and 21 Today) OR High Level (50+)
      if (todayMalas >= 108 || (streak >= 30 && todayMalas >= 21) || level >= 50) {
        targetIcon = 'MainActivityDivine';
      } 
      // Golden: 54+ Malas Today OR Strong Streak (7+ and 11 Today) OR Experience Level (20+)
      else if (todayMalas >= 54 || (streak >= 7 && todayMalas >= 11) || level >= 20) {
        targetIcon = 'MainActivityGolden';
      } 
      // Radiant: 21+ Malas Today (The first daily spark)
      else if (todayMalas >= 21) {
        targetIcon = 'MainActivityRadiant';
      } 
      else {
        // Default to Starter (Level 1 / Morning Reset)
        targetIcon = 'MainActivityStarter';
      }

      final currentIcon = await FlutterDynamicIconPlus.alternateIconName;
      
      if (currentIcon != targetIcon) {
        await FlutterDynamicIconPlus.setAlternateIconName(
          iconName: targetIcon,
        );
      }
    } catch (e) {
      // Fail silently for icons to avoid breaking the chant experience
      print('Error updating dynamic icon: $e');
    }
  }

  // Debug method to force an icon change (useful for testing)
  Future<void> forceSetIcon(String? iconName) async {
    await FlutterDynamicIconPlus.setAlternateIconName(iconName: iconName);
  }
}
