import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../core/stats_provider.dart';
import '../core/spirituality_provider.dart';
import '../models/user_stats.dart';
import '../models/sacred_event.dart';
import '../models/daily_gyaan.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final notificationManagerProvider = Provider<NotificationManager>((ref) {
  return NotificationManager(ref);
});

class NotificationManager {
  final Ref ref;

  NotificationManager(this.ref);

  /// Synchronize all spiritual reminders based on current state
  Future<void> syncAllReminders() async {
    final stats = ref.read(userStatsProvider).value;
    if (stats != null) {
      await _syncStreakReminder(stats);
    }

    final events = ref.read(upcomingEventsProvider).value ?? [];
    await _syncEventReminders(events);

    final gyaan = ref.read(dailyGyaanProvider).value;
    if (gyaan != null) {
      await _syncGyaanReminder(gyaan);
    }
  }

  Future<void> _syncStreakReminder(UserStats stats) async {
    if (stats.streakCount > 0) {
      // If they haven't checked in today, schedule a warning for 8 PM
      final now = DateTime.now();
      final lastDate = stats.lastActiveDate?.toIso8601String().split('T')[0];
      final todayDate = now.toIso8601String().split('T')[0];

      if (lastDate != todayDate) {
        try {
          await ref.read(notificationServiceProvider).scheduleStreakWarning(stats.streakCount);
        } catch (e) {
          // Android 13+ may deny exact alarms — gracefully ignore
        }
      }
    }
  }

  Future<void> _syncEventReminders(List<SacredEvent> events) async {
    final now = DateTime.now();
    for (final event in events) {
      // Only schedule for future events within next 7 days to avoid flooding
      if (event.date.isAfter(now) && event.date.difference(now).inDays <= 7) {
        try {
          await ref.read(notificationServiceProvider).scheduleSacredEventReminder(
            event.id,
            event.title,
            event.date,
          );
        } catch (e) {
          // Gracefully handle exact alarm permission denial
        }
      }
    }
  }

  Future<void> _syncGyaanReminder(DailyGyaan gyaan) async {
    try {
      await ref.read(notificationServiceProvider).scheduleDailyGyaanNotification(gyaan.title);
    } catch (e) {
      // Gracefully handle exact alarm permission denial
    }
  }
}
