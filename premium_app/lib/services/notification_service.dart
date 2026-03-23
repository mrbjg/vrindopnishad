import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;
    
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      // Request exact alarms permission if on Android
      if (!kIsWeb && Platform.isAndroid) {
        final allowed = await androidPlugin.requestExactAlarmsPermission();
        if (allowed == false) {
          debugPrint('Exact alarms not permitted.');
          return false;
        }
      }
    }
    // For iOS, permissions are requested during initialization, but we can add a check here if needed.
    // For now, assume true if not Android or if Android permission was granted.
    return true;
  }

  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _notifications.initialize(initSettings);
  }

  Future<void> scheduleDailyReminder(int hour, int minute) async {
    // Cancel existing reminders
    await _notifications.cancel(1001);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      if (!kIsWeb && Platform.isAndroid) {
         final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
         if (androidPlugin != null) {
           final allowed = await androidPlugin.requestExactAlarmsPermission();
           if (allowed == false) {
             // Fallback to inexact if needed, or just handle
             debugPrint('Exact alarms not permitted. Falling back.');
           }
         }
      }

      await _notifications.zonedSchedule(
        1001,
        'Sacred Reminder',
        'It is time for your daily Mala. Return to stillness.',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'sacred_reminders',
            'Sacred Reminders',
            channelDescription: 'Daily spiritual practice reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      // If exact fails, try inexact as fallback
      try {
        await _notifications.zonedSchedule(
          1001,
          'Sacred Reminder',
          'It is time for your daily Mala. Return to stillness.',
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'sacred_reminders',
              'Sacred Reminders',
              channelDescription: 'Daily spiritual practice reminders',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } catch (e2) {
        debugPrint('Fallback failed: $e2');
      }
    }
  }

  /// Schedule a reminder for a Vrat or Utsav the day before
  Future<void> scheduleSacredEventReminder(String id, String title, DateTime date) async {
    final scheduledDate = tz.TZDateTime.from(date, tz.local).subtract(const Duration(days: 1));
    // Set to 8:00 PM the night before
    final finalDate = tz.TZDateTime(tz.local, scheduledDate.year, scheduledDate.month, scheduledDate.day, 20, 0);

    if (finalDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _notifications.zonedSchedule(
      id.hashCode,
      'Sacred Preparation',
      'Tomorrow is $title. Prepare your heart for the divine tithi.',
      finalDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'sacred_calendar',
          'Sacred Calendar',
          channelDescription: 'Vrat and Utsav reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Schedule a warning when a streak is at risk of being lost
  Future<void> scheduleStreakWarning(int currentStreak) async {
    await _notifications.cancel(2001); // 2001 is for streak warnings

    final now = tz.TZDateTime.now(tz.local);
    // Schedule for 8 PM tonight if they haven't checked in
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20, 0);

    if (scheduledDate.isBefore(now)) return;

    await _notifications.zonedSchedule(
      2001,
      '🔥 Streak at Risk!',
      'Your $currentStreak-day streak is ending soon. Complete your Sadhana now!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_warnings',
          'Streak Warnings',
          channelDescription: 'Alerts when your streak is about to be lost',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Schedule daily wisdom (Daily Gyaan)
  Future<void> scheduleDailyGyaanNotification(String title) async {
    await _notifications.cancel(3001);

    final now = tz.TZDateTime.now(tz.local);
    // 9:00 AM every morning
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 9, 0);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      3001,
      'Daily Gyaan',
      'Today\'s Wisdom: $title',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_gyaan',
          'Daily Gyaan',
          channelDescription: 'Daily spiritual wisdom notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
