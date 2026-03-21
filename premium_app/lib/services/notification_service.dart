import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
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
      if (Platform.isAndroid) {
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

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
