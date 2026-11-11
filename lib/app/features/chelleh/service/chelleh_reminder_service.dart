import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class ChellehReminderService {
  static const int reminderNotificationId = 901;
  static const String channelId = 'chelleh_reminder_channel';
  static const String channelName = 'تنبيهات أربعينية الصلوات';
  static const String channelDesc = 'تذكير يومي بقراءة صلوات الأربعينية المباركة';

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Schedule daily notification at [hour] and [minute]
  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required int activeDay,
  }) async {
    try {
      await cancelReminder();

      // Create channel
      final androidChannel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDesc,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(androidChannel);
      }

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notificationsPlugin.zonedSchedule(
        reminderNotificationId,
        'وقت أربعينية الصلوات 📿 (اليوم $activeDay من 40)',
        'اللهم صل علی محمد و آل محمد - لا تنسَ نصيبك من صلوات اليوم',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // Daily recurring
      );

      debugPrint('Chelleh daily reminder scheduled for $hour:$minute');
    } catch (e) {
      debugPrint('Error scheduling chelleh reminder: $e');
    }
  }

  static Future<void> cancelReminder() async {
    try {
      await _notificationsPlugin.cancel(reminderNotificationId);
    } catch (e) {
      debugPrint('Error cancelling chelleh reminder: $e');
    }
  }
}
