import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../model/adhan_voice_model.dart';
import '../model/prayer_settings_model.dart';
import '../model/prayer_time_item.dart';
import 'prayer_audio_service.dart';
import 'prayer_calculation_service.dart';

class PrayerNotificationService extends GetxService {
  static PrayerNotificationService get to =>
      Get.find<PrayerNotificationService>();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'prayer_times_channel';
  static const String channelName = 'أوقات الصلاة والأذان';
  static const String channelDesc = 'تنبيهات مواقيت الصلاة والأذان الشريف';

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initNotifications();
    // Auto-schedule for upcoming days upon startup
    await autoScheduleFromStorage();
  }

  Future<void> _setupLocalTimezone() async {
    try {
      String? platformTimeZone;
      try {
        const channel = MethodChannel('com.dijlah.alseraj/timezone');
        platformTimeZone = await channel.invokeMethod<String>('getTimeZone');
      } catch (e) {
        debugPrint('Platform timezone channel error: $e');
      }

      if (platformTimeZone != null && platformTimeZone.isNotEmpty) {
        try {
          final loc = tz.getLocation(platformTimeZone);
          tz.setLocalLocation(loc);
          debugPrint('Local timezone set to $platformTimeZone');
          return;
        } catch (e) {
          debugPrint('TimeZone $platformTimeZone not found in tz db: $e');
        }
      }

      // Fallback: match a valid IANA location from tz database with same offset
      final currentOffsetMillis = DateTime.now().timeZoneOffset.inMilliseconds;
      tz.Location? matchedLocation;
      for (final loc in tz.timeZoneDatabase.locations.values) {
        if (loc.currentTimeZone.offset == currentOffsetMillis) {
          matchedLocation = loc;
          break;
        }
      }

      if (matchedLocation != null) {
        tz.setLocalLocation(matchedLocation);
        debugPrint('Fallback timezone matched to ${matchedLocation.name}');
      } else {
        tz.setLocalLocation(tz.getLocation('UTC'));
        debugPrint('Defaulting timezone to UTC');
      }
    } catch (e) {
      debugPrint('Error setting local timezone: $e');
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
    }
  }

  Future<void> _initNotifications() async {
    try {
      tz.initializeTimeZones();
      await _setupLocalTimezone();

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings darwinSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        // Create base notification channel
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDesc,
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          ),
        );

        // Register custom sound channels for each available adhan voice
        for (final voice in AdhanVoiceModel.availableVoices) {
          final voiceChannel = AndroidNotificationChannel(
            'prayer_times_channel_${voice.rawResource}',
            'أوقات الصلاة - ${voice.name}',
            description: channelDesc,
            importance: Importance.max,
            playSound: true,
            sound: RawResourceAndroidNotificationSound(voice.rawResource),
            enableVibration: true,
          );
          await androidPlugin.createNotificationChannel(voiceChannel);
        }

        // Request runtime notification permission (Android 13+)
        await androidPlugin.requestNotificationsPermission();
        // Request exact alarms permission if supported
        await androidPlugin.requestExactAlarmsPermission();
      }

      final iosPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iosPlugin != null) {
        await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      debugPrint('Error initializing prayer notifications: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.actionId == 'stop_adhan') {
      if (Get.isRegistered<PrayerAudioService>()) {
        PrayerAudioService.to.stopAdhan();
      }
    }
  }

  /// Automatically schedule notifications based on saved prayer settings
  Future<void> autoScheduleFromStorage() async {
    try {
      final storage = GetStorage();
      final storedJson = storage.read<Map<String, dynamic>>('prayer_settings');
      PrayerSettingsModel settings;
      if (storedJson != null) {
        settings = PrayerSettingsModel.fromJson(storedJson);
      } else {
        settings = PrayerSettingsModel();
      }

      double? lat = settings.hasResolvedLocation ? settings.latitude : null;
      double? lng = settings.hasResolvedLocation ? settings.longitude : null;

      if (lat == null || lng == null) {
        final cachedLat = storage.read<num>('user_cached_latitude')?.toDouble();
        final cachedLng = storage.read<num>('user_cached_longitude')?.toDouble();
        if (cachedLat != null && cachedLng != null) {
          lat = cachedLat;
          lng = cachedLng;
        }
      }

      if (lat == null || lng == null) {
        // Location has not been resolved yet; PrayerTimesController will schedule
        // notifications immediately after obtaining GPS / IP / manual location.
        return;
      }

      await schedulePrayerNotificationsForDays(
        latitude: lat,
        longitude: lng,
        methodType: settings.methodType,
        enabledPrayers: settings.enabledPrayers,
        adhanVoiceId: settings.adhanVoiceId,
        timeZoneId: settings.timeZoneId,
        utcOffsetSeconds: settings.utcOffsetSeconds,
        daysCount: 7,
      );
    } catch (e) {
      debugPrint('Error in autoScheduleFromStorage: $e');
    }
  }

  /// Schedule notifications for all enabled prayers for upcoming days (default: 7 days)
  Future<void> schedulePrayerNotificationsForDays({
    required double latitude,
    required double longitude,
    required PrayerCalculationMethodType methodType,
    required Map<String, bool> enabledPrayers,
    String? adhanVoiceId,
    String? timeZoneId,
    int? utcOffsetSeconds,
    int daysCount = 7,
  }) async {
    try {
      await cancelAllNotifications();

      final voice = AdhanVoiceModel.getById(adhanVoiceId);
      final rawSound = voice.rawResource;
      final targetChannelId = 'prayer_times_channel_$rawSound';

      final now = DateTime.now();
      int notificationId = 100;

      for (int dayOffset = 0; dayOffset < daysCount; dayOffset++) {
        final targetDate = now.add(Duration(days: dayOffset));
        final items = PrayerCalculationService.calculatePrayerTimes(
          latitude: latitude,
          longitude: longitude,
          date: targetDate,
          methodType: methodType,
          enabledMap: enabledPrayers,
          timeZoneId: timeZoneId,
          utcOffsetSeconds: utcOffsetSeconds,
        );

        for (final prayer in items) {
          if (!prayer.isAlarmEnabled || !prayer.isAdhan) continue;
          if (prayer.dateTime.isBefore(now)) continue;

          final scheduledTz = tz.TZDateTime.from(prayer.dateTime, tz.local);

          await _notificationsPlugin.zonedSchedule(
            notificationId++,
            'حان الآن موعد أذان ${prayer.arabicName}',
            'حي على الصلاة، حي على الفلاح (${voice.name})',
            scheduledTz,
            NotificationDetails(
              android: AndroidNotificationDetails(
                targetChannelId,
                'أوقات الصلاة - ${voice.name}',
                channelDescription: channelDesc,
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
                sound: RawResourceAndroidNotificationSound(rawSound),
                enableVibration: true,
                actions: const [
                  AndroidNotificationAction(
                    'stop_adhan',
                    'إيقاف الأذان',
                    cancelNotification: true,
                  ),
                ],
              ),
              iOS: DarwinNotificationDetails(
                sound: '$rawSound.mp3',
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        }
      }
      debugPrint(
        'Successfully scheduled prayer notifications for $daysCount days using voice: ${voice.name}',
      );
    } catch (e) {
      debugPrint('Error scheduling prayer notifications: $e');
    }
  }

  /// Fallback single-list schedule method for compatibility
  Future<void> schedulePrayerNotifications(
    List<PrayerTimeItem> prayerItems,
  ) async {
    await autoScheduleFromStorage();
  }

  /// Show immediate notification for current prayer
  Future<void> showImmediatePrayerNotification(PrayerTimeItem prayer) async {
    try {
      final storage = GetStorage();
      final storedJson = storage.read<Map<String, dynamic>>('prayer_settings');
      String? voiceId;
      if (storedJson != null) {
        voiceId = storedJson['adhanVoiceId'] as String?;
      }
      final voice = AdhanVoiceModel.getById(voiceId);
      final rawSound = voice.rawResource;
      final targetChannelId = 'prayer_times_channel_$rawSound';

      await _notificationsPlugin.show(
        prayer.type.index,
        'حان الآن موعد أذان ${prayer.arabicName}',
        'حي على الصلاة، حي على الفلاح (${voice.name})',
        NotificationDetails(
          android: AndroidNotificationDetails(
            targetChannelId,
            'أوقات الصلاة - ${voice.name}',
            channelDescription: channelDesc,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            sound: RawResourceAndroidNotificationSound(rawSound),
            actions: const [
              AndroidNotificationAction(
                'stop_adhan',
                'إيقاف الأذان',
                cancelNotification: true,
              ),
            ],
          ),
          iOS: DarwinNotificationDetails(
            sound: '$rawSound.mp3',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error showing immediate prayer notification: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Error cancelling notifications: $e');
    }
  }
}
