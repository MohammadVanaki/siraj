import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:mawsueat/app/core/services/app_location_compass_service.dart';

import '../model/prayer_city_model.dart';
import '../model/prayer_settings_model.dart';
import '../model/prayer_time_item.dart';
import '../model/prayer_type.dart';
import '../service/prayer_audio_service.dart';
import '../service/prayer_calculation_service.dart';
import '../service/prayer_notification_service.dart';

class PrayerTimesController extends GetxController {
  static PrayerTimesController get to => Get.find<PrayerTimesController>();

  final GetStorage _storage = GetStorage();

  // State Observables
  final RxBool isLoading = true.obs;
  final RxList<PrayerTimeItem> todayPrayers = <PrayerTimeItem>[].obs;
  final Rxn<PrayerTimeItem> nextPrayer = Rxn<PrayerTimeItem>();
  final RxString countdownString = '00:00:00'.obs;
  final RxDouble dayProgress = 0.0.obs;

  // Settings
  final Rx<PrayerSettingsModel> settings = PrayerSettingsModel().obs;
  final RxString locationCityName = 'جاري تحديد الموقع...'.obs;
  final RxString hijriDateString = ''.obs;
  final RxString gregorianDateString = ''.obs;

  Timer? _countdownTimer;
  Worker? _sharedPositionWorker;
  bool _isUpdatingFromSharedPosition = false;
  final Set<String> _playedPrayersToday = {};

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _initDateStrings();
    _bindSharedLocationService();
    initPrayerTimes();
    _startCountdownTimer();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    _sharedPositionWorker?.dispose();
    super.onClose();
  }

  void _initDateStrings() {
    final now = DateTime.now();
    final hijri = HijriCalendar.now();
    hijriDateString.value =
        '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} هـ';
    gregorianDateString.value = DateFormat('EEEE، d MMMM yyyy', 'ar').format(now);
  }

  void _loadSettings() {
    final storedJson = _storage.read<Map<String, dynamic>>('prayer_settings');
    if (storedJson != null) {
      settings.value = PrayerSettingsModel.fromJson(storedJson);
    } else {
      settings.value = _buildTimezoneHintPlaceholder();
    }

    // Seed from shared AppLocationCompassService cache if not manually pinned
    // and current settings don't yet have a resolved location.
    if (!settings.value.isManualLocation && !settings.value.hasResolvedLocation) {
      final cachedLat = _storage.read<num>('user_cached_latitude')?.toDouble();
      final cachedLng = _storage.read<num>('user_cached_longitude')?.toDouble();
      final cachedCity = _storage.read<String>('user_cached_city_name');
      if (cachedLat != null && cachedLng != null) {
        settings.value.latitude = cachedLat;
        settings.value.longitude = cachedLng;
        settings.value.cityName =
            (cachedCity != null && cachedCity.isNotEmpty)
                ? cachedCity
                : _nearestPresetCityName(cachedLat, cachedLng) ??
                    'الموقع التلقائي';
        settings.value.hasResolvedLocation = true;
      } else {
        settings.value = _buildTimezoneHintPlaceholder(base: settings.value);
      }
    }

    locationCityName.value = settings.value.cityName;
  }

  /// Build an approximate timezone-matched placeholder only while GPS/IP is pending.
  /// Never marked as [hasResolvedLocation] so real location always overrides it.
  PrayerSettingsModel _buildTimezoneHintPlaceholder({PrayerSettingsModel? base}) {
    final offsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
    PrayerCityModel hintCity;
    if (offsetMinutes == 210) {
      // UTC+3:30 (Iran)
      hintCity = PrayerCityModel.presetCities.firstWhere(
        (c) => c.name == 'قم المقدسة',
      );
    } else if (offsetMinutes == 240) {
      // UTC+4:00 (UAE / Oman)
      hintCity = PrayerCityModel.presetCities.firstWhere(
        (c) => c.name == 'دبي',
      );
    } else if (offsetMinutes == 120) {
      // UTC+2:00 (Lebanon / Egypt)
      hintCity = PrayerCityModel.presetCities.firstWhere(
        (c) => c.name == 'بيروت',
      );
    } else if (offsetMinutes >= -60 && offsetMinutes <= 60) {
      // UTC+0 / Europe West
      hintCity = PrayerCityModel.presetCities.firstWhere(
        (c) => c.name == 'لندن',
      );
    } else {
      // UTC+3:00 and default: Baghdad / Iraq
      hintCity = PrayerCityModel.presetCities.firstWhere(
        (c) => c.name == 'بغداد',
      );
    }

    final model = base ?? PrayerSettingsModel();
    model.latitude = hintCity.latitude;
    model.longitude = hintCity.longitude;
    model.cityName = '${hintCity.name} (تقديري)';
    model.hasResolvedLocation = false;
    model.timeZoneId = null;
    model.utcOffsetSeconds = null;
    return model;
  }

  void _bindSharedLocationService() {
    if (!Get.isRegistered<AppLocationCompassService>()) return;
    final shared = AppLocationCompassService.to;
    _sharedPositionWorker = ever<Position?>(shared.currentPosition, (pos) async {
      if (pos == null) return;
      if (settings.value.isManualLocation) return;
      if (_isUpdatingFromSharedPosition) return;

      final movedKm = _distanceKm(
        settings.value.latitude,
        settings.value.longitude,
        pos.latitude,
        pos.longitude,
      );

      // Update immediately if location wasn't resolved yet or device moved > 3 km
      if (!settings.value.hasResolvedLocation || movedKm > 3.0) {
        _isUpdatingFromSharedPosition = true;
        try {
          await _applyDetectedCoordinates(
            pos.latitude,
            pos.longitude,
            clearManualTimezone: true,
          );
          calculateTodayPrayers();
        } finally {
          _isUpdatingFromSharedPosition = false;
        }
      }
    });
  }

  Future<void> _saveSettings() async {
    await _storage.write('prayer_settings', settings.value.toJson());
    settings.refresh();
  }

  /// Initialize prayer calculations and location
  Future<void> initPrayerTimes() async {
    isLoading.value = true;
    try {
      // Compute immediately from cached/placeholder coords so UI isn't blank
      // while GPS / network resolves in the background.
      calculateTodayPrayers(scheduleNotifications: settings.value.hasResolvedLocation);

      if (!settings.value.isManualLocation) {
        final updated = await _fetchLocationIfPossible(allowPermissionPrompt: true);
        if (updated || !settings.value.hasResolvedLocation) {
          calculateTodayPrayers();
        }
      }
    } catch (e) {
      debugPrint('Error init prayer times: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Attempt to fetch location via shared GPS cache, device GPS, or IP geolocation.
  /// Returns true if location coordinates were updated.
  Future<bool> _fetchLocationIfPossible({
    bool allowPermissionPrompt = true,
  }) async {
    if (settings.value.isManualLocation) return false;

    try {
      // 1. Check GPS permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && allowPermissionPrompt) {
        permission = await Geolocator.requestPermission();
      }

      final hasGpsPermission =
          permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      Position? gpsPosition;

      if (hasGpsPermission) {
        // 2a. Try instant last-known GPS position (works even indoors/cached)
        try {
          gpsPosition = await Geolocator.getLastKnownPosition();
        } catch (_) {}

        // 2b. Try live GPS if hardware location service is enabled
        final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
        if (isLocationEnabled) {
          try {
            gpsPosition = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.medium,
                timeLimit: Duration(seconds: 10),
              ),
            );
          } catch (_) {
            // Retry with coarse/network accuracy when indoor GPS times out
            try {
              gpsPosition = await Geolocator.getCurrentPosition(
                locationSettings: const LocationSettings(
                  accuracy: LocationAccuracy.low,
                  timeLimit: Duration(seconds: 5),
                ),
              );
            } catch (e) {
              debugPrint('Low-accuracy GPS fallback timeout/error: $e');
            }
          }
        }
      }

      if (gpsPosition != null) {
        await _applyDetectedCoordinates(
          gpsPosition.latitude,
          gpsPosition.longitude,
          clearManualTimezone: true,
        );
        return true;
      }

      // 3. Check AppLocationCompassService cached position if GPS couldn't acquire fresh fix
      if (Get.isRegistered<AppLocationCompassService>()) {
        final sharedPos = AppLocationCompassService.to.currentPosition.value;
        if (sharedPos != null) {
          await _applyDetectedCoordinates(
            sharedPos.latitude,
            sharedPos.longitude,
            clearManualTimezone: true,
          );
          return true;
        }
      }

      // 4. Fallback to IP geolocation when GPS is off / denied / unavailable
      final ipResolved = await _fetchLocationFromIp();
      if (ipResolved) {
        return true;
      }
    } catch (e) {
      debugPrint('Location fetch error, keeping current coords: $e');
    }
    return false;
  }

  /// Apply detected coordinates from GPS or IP and cache city name
  Future<void> _applyDetectedCoordinates(
    double lat,
    double lng, {
    String? knownCityName,
    bool clearManualTimezone = true,
  }) async {
    settings.value.latitude = lat;
    settings.value.longitude = lng;
    settings.value.hasResolvedLocation = true;
    settings.value.isManualLocation = false;
    if (clearManualTimezone) {
      settings.value.timeZoneId = null;
      settings.value.utcOffsetSeconds = null;
    }

    String city = (knownCityName != null && knownCityName.isNotEmpty)
        ? knownCityName
        : await _getCityNameFromCoordinates(lat, lng);

    settings.value.cityName = city;
    locationCityName.value = city;

    await _storage.write('user_cached_latitude', lat);
    await _storage.write('user_cached_longitude', lng);
    await _storage.write('user_cached_city_name', city);

    await _saveSettings();
  }

  /// IP-based geolocation fallback with VPN timezone guard
  Future<bool> _fetchLocationFromIp() async {
    final deviceOffsetSeconds = DateTime.now().timeZoneOffset.inSeconds;

    // Provider 1: ipwho.is (HTTPS, supports Arabic city names)
    try {
      final response = await http
          .get(
            Uri.parse('https://ipwho.is/?lang=ar'),
            headers: {'User-Agent': 'AlSirajApp/1.0'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['success'] == true) {
          final lat = (data['latitude'] as num?)?.toDouble();
          final lng = (data['longitude'] as num?)?.toDouble();
          final city = (data['city'] as String?)?.trim();
          final country = (data['country'] as String?)?.trim();
          final tzMap = data['timezone'] as Map<String, dynamic>?;
          final ipOffset = (tzMap?['offset'] as num?)?.toInt();

          if (lat != null && lng != null) {
            // Skip IP geolocation if user is clearly behind a distant VPN
            if (ipOffset != null &&
                (ipOffset - deviceOffsetSeconds).abs() > 5400) {
              debugPrint(
                'Skipping IP location due to timezone mismatch (possible VPN): '
                'ipOffset=$ipOffset, deviceOffset=$deviceOffsetSeconds',
              );
              return false;
            }

            final resolvedCity =
                (city != null && city.isNotEmpty)
                    ? city
                    : (country != null && country.isNotEmpty
                        ? country
                        : null);
            await _applyDetectedCoordinates(
              lat,
              lng,
              knownCityName: resolvedCity,
              clearManualTimezone: true,
            );
            return true;
          }
        }
      }
    } catch (e) {
      debugPrint('ipwho.is fallback error: $e');
    }

    // Provider 2: ipapi.co (HTTPS fallback)
    try {
      final response = await http
          .get(
            Uri.parse('https://ipapi.co/json/'),
            headers: {'User-Agent': 'AlSirajApp/1.0'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final lat = (data['latitude'] as num?)?.toDouble();
        final lng = (data['longitude'] as num?)?.toDouble();
        final city = (data['city'] as String?)?.trim();
        final utcOffsetStr = data['utc_offset'] as String?;
        final ipOffset = _parseUtcOffsetString(utcOffsetStr);

        if (lat != null && lng != null) {
          if (ipOffset != null &&
              (ipOffset - deviceOffsetSeconds).abs() > 5400) {
            debugPrint(
              'Skipping ipapi location due to timezone mismatch (possible VPN): '
              'ipOffset=$ipOffset, deviceOffset=$deviceOffsetSeconds',
            );
            return false;
          }

          await _applyDetectedCoordinates(
            lat,
            lng,
            knownCityName: (city != null && city.isNotEmpty)
                ? (_nearestPresetCityName(lat, lng) ?? city)
                : null,
            clearManualTimezone: true,
          );
          return true;
        }
      }
    } catch (e) {
      debugPrint('ipapi.co fallback error: $e');
    }

    return false;
  }

  int? _parseUtcOffsetString(String? raw) {
    if (raw == null || raw.length < 5) return null;
    final sign = raw.startsWith('-') ? -1 : 1;
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 4) return null;
    final hours = int.tryParse(digits.substring(0, 2)) ?? 0;
    final mins = int.tryParse(digits.substring(2, 4)) ?? 0;
    return sign * (hours * 3600 + mins * 60);
  }

  /// Reverse geocode coordinates to Arabic city name
  Future<String> _getCityNameFromCoordinates(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&accept-language=ar&zoom=10',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'MawsueatAhlAlbaytApp/1.0',
      }).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final city = address['city'] ??
              address['town'] ??
              address['village'] ??
              address['suburb'] ??
              address['municipality'] ??
              address['state_district'] ??
              address['state'] ??
              address['county'] ??
              address['country'];
          if (city != null && city.toString().trim().isNotEmpty) {
            return city.toString().trim();
          }
        }
      }
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
    }
    return _nearestPresetCityName(lat, lon) ?? 'الموقع الحالي';
  }

  String? _nearestPresetCityName(double lat, double lon) {
    String? closestName;
    double bestKm = 45.0; // Only match if reasonably close (< 45 km)
    for (final city in PrayerCityModel.presetCities) {
      final d = _distanceKm(lat, lon, city.latitude, city.longitude);
      if (d < bestKm) {
        bestKm = d;
        closestName = city.name;
      }
    }
    return closestName;
  }

  double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    final dLat = (lat2 - lat1) * math.pi / 180.0;
    final dLon = (lon2 - lon1) * math.pi / 180.0;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180.0) *
            math.cos(lat2 * math.pi / 180.0) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Calculate all prayer times for today
  void calculateTodayPrayers({bool scheduleNotifications = true}) {
    final now = DateTime.now();
    final items = PrayerCalculationService.calculatePrayerTimes(
      latitude: settings.value.latitude,
      longitude: settings.value.longitude,
      date: now,
      methodType: settings.value.methodType,
      enabledMap: settings.value.enabledPrayers,
      timeZoneId: settings.value.timeZoneId,
      utcOffsetSeconds: settings.value.utcOffsetSeconds,
    );

    todayPrayers.assignAll(items);
    _updateNextPrayer();

    // Schedule notifications in background for 7 days
    if (scheduleNotifications && Get.isRegistered<PrayerNotificationService>()) {
      PrayerNotificationService.to.schedulePrayerNotificationsForDays(
        latitude: settings.value.latitude,
        longitude: settings.value.longitude,
        methodType: settings.value.methodType,
        enabledPrayers: settings.value.enabledPrayers,
        adhanVoiceId: settings.value.adhanVoiceId,
        timeZoneId: settings.value.timeZoneId,
        utcOffsetSeconds: settings.value.utcOffsetSeconds,
        daysCount: 7,
      );
    }
  }

  /// Update the next upcoming prayer
  void _updateNextPrayer() {
    final next = PrayerCalculationService.getNextPrayer(
      todayPrayers,
      latitude: settings.value.latitude,
      longitude: settings.value.longitude,
      methodType: settings.value.methodType,
      enabledMap: settings.value.enabledPrayers,
      timeZoneId: settings.value.timeZoneId,
      utcOffsetSeconds: settings.value.utcOffsetSeconds,
    );
    nextPrayer.value = next;
  }

  /// Periodic countdown loop to update UI every second
  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final next = nextPrayer.value;

      if (next == null) {
        _updateNextPrayer();
        return;
      }

      final diff = next.dateTime.difference(now);

      if (diff.isNegative) {
        // Time reached! Check if we should trigger adhan
        final prayerKey =
            '${next.type.name}_${DateFormat('yyyyMMdd').format(now)}';
        if (!_playedPrayersToday.contains(prayerKey)) {
          _playedPrayersToday.add(prayerKey);
          if (next.isAlarmEnabled && next.isAdhan) {
            _triggerAdhan(next);
          }
        }
        // Refresh prayers
        calculateTodayPrayers();
        return;
      }

      final hours = diff.inHours.toString().padLeft(2, '0');
      final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');

      countdownString.value = '$hours:$minutes:$seconds';

      // Calculate progress between Fajr and Isha
      if (todayPrayers.isNotEmpty) {
        final firstPrayer = todayPrayers.first.dateTime;
        final lastPrayer = todayPrayers.last.dateTime;
        final totalDuration = lastPrayer.difference(firstPrayer).inSeconds;
        final passedDuration = now.difference(firstPrayer).inSeconds;
        if (totalDuration > 0) {
          dayProgress.value = (passedDuration / totalDuration).clamp(0.0, 1.0);
        }
      }
    });
  }

  void _triggerAdhan(PrayerTimeItem prayer) {
    if (Get.isRegistered<PrayerAudioService>() &&
        settings.value.playFullAdhan) {
      PrayerAudioService.to.playAdhan(prayerName: prayer.arabicName);
    }
    if (Get.isRegistered<PrayerNotificationService>()) {
      PrayerNotificationService.to.showImmediatePrayerNotification(prayer);
    }
  }

  /// Toggle alarm/adhan notification for a specific prayer
  Future<void> togglePrayerAlarm(PrayerType type) async {
    final key = type.name;
    final currentVal = settings.value.enabledPrayers[key] ?? false;
    settings.value.enabledPrayers[key] = !currentVal;

    // Update in today's prayer list
    for (int i = 0; i < todayPrayers.length; i++) {
      if (todayPrayers[i].type == type) {
        todayPrayers[i] = todayPrayers[i].copyWith(
          isAlarmEnabled: !currentVal,
        );
        break;
      }
    }

    await _saveSettings();
    todayPrayers.refresh();

    // Reschedule notifications for 7 days
    if (Get.isRegistered<PrayerNotificationService>()) {
      PrayerNotificationService.to.schedulePrayerNotificationsForDays(
        latitude: settings.value.latitude,
        longitude: settings.value.longitude,
        methodType: settings.value.methodType,
        enabledPrayers: settings.value.enabledPrayers,
        adhanVoiceId: settings.value.adhanVoiceId,
        timeZoneId: settings.value.timeZoneId,
        utcOffsetSeconds: settings.value.utcOffsetSeconds,
        daysCount: 7,
      );
    }
  }

  /// Change calculation method
  Future<void> setCalculationMethod(PrayerCalculationMethodType method) async {
    settings.value.methodType = method;
    await _saveSettings();
    calculateTodayPrayers();
  }

  /// Change selected Adhan voice
  Future<void> setAdhanVoice(String voiceId) async {
    settings.value.adhanVoiceId = voiceId;
    await _saveSettings();
    settings.refresh();

    // Reschedule notifications with the selected voice channel
    if (Get.isRegistered<PrayerNotificationService>()) {
      PrayerNotificationService.to.autoScheduleFromStorage();
    }
  }

  /// Select a city manually (overrides automatic GPS/IP until switched back)
  Future<void> setManualCity(PrayerCityModel city) async {
    settings.value.latitude = city.latitude;
    settings.value.longitude = city.longitude;
    settings.value.cityName = city.name;
    settings.value.isManualLocation = true;
    settings.value.hasResolvedLocation = true;
    settings.value.timeZoneId = city.timeZoneId;
    settings.value.utcOffsetSeconds = city.utcOffsetSeconds;
    locationCityName.value = city.name;

    await _saveSettings();
    calculateTodayPrayers();

    _showSnackbar(
      title: 'تم تغيير المدينة',
      message: 'تم اعتماد أفق ${city.name}',
      isSuccess: true,
    );
  }

  /// Switch back to automatic GPS/IP location mode
  Future<void> useAutoLocation() async {
    settings.value.isManualLocation = false;
    settings.value.timeZoneId = null;
    settings.value.utcOffsetSeconds = null;
    await refreshLocation();
  }

  /// Refresh location manually by user
  Future<void> refreshLocation() async {
    isLoading.value = true;
    try {
      settings.value.isManualLocation = false;
      settings.value.timeZoneId = null;
      settings.value.utcOffsetSeconds = null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position? pos;
      final hasPermission =
          permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      if (hasPermission) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          try {
            pos = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
                timeLimit: Duration(seconds: 10),
              ),
            );
          } catch (_) {
            try {
              pos = await Geolocator.getLastKnownPosition();
            } catch (_) {}
          }
        } else {
          // Even if GPS toggle just turned off, try last known or IP fallback
          try {
            pos = await Geolocator.getLastKnownPosition();
          } catch (_) {}
        }
      }

      if (pos != null) {
        await _applyDetectedCoordinates(
          pos.latitude,
          pos.longitude,
          clearManualTimezone: true,
        );
        calculateTodayPrayers();
        _showSnackbar(
          title: 'تم تحديث الموقع',
          message: 'تم تحديث أفق المواقيت: ${locationCityName.value}',
          isSuccess: true,
        );
        return;
      }

      // Try IP geolocation fallback if GPS wasn't available
      final ipResolved = await _fetchLocationFromIp();
      if (ipResolved) {
        calculateTodayPrayers();
        _showSnackbar(
          title: 'تم تحديث الموقع',
          message: 'تم تحديد الأفق عبر الشبكة: ${locationCityName.value}',
          isSuccess: true,
        );
        return;
      }

      calculateTodayPrayers();
      _showSnackbar(
        title: 'تعذر تحديد الموقع',
        message: 'يرجى تفعيل الـ GPS أو اختيار المدينة يدوياً من الإعدادات',
        isSuccess: false,
      );
    } catch (e) {
      _showSnackbar(
        title: 'تعذر تحديد الموقع',
        message: 'يرجى التأكد من تشغيل الـ GPS أو اختيار المدينة يدوياً',
        isSuccess: false,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showSnackbar({
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    final context = Get.context;
    if (context != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$title - $message',
            style: const TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.white),
          ),
          backgroundColor: isSuccess
              ? Colors.teal.withAlpha(220)
              : Colors.red.withAlpha(220),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
