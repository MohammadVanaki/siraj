import 'package:adhan/adhan.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../model/prayer_settings_model.dart';
import '../model/prayer_time_item.dart';
import '../model/prayer_type.dart';

class PrayerCalculationService {
  static bool _tzInitialized = false;

  static void _ensureTimeZonesInitialized() {
    if (_tzInitialized) return;
    try {
      // Only initialize if not already loaded by PrayerNotificationService
      if (tz.timeZoneDatabase.locations.isEmpty) {
        tz_data.initializeTimeZones();
      }
      _tzInitialized = true;
    } catch (_) {
      try {
        tz_data.initializeTimeZones();
        _tzInitialized = true;
      } catch (_) {}
    }
  }

  static tz.Location? _resolveTargetLocation(String? timeZoneId) {
    if (timeZoneId == null || timeZoneId.isEmpty) return null;
    _ensureTimeZonesInitialized();
    try {
      return tz.getLocation(timeZoneId);
    } catch (_) {
      return null;
    }
  }

  static DateTime? _toTargetWallClock(
    DateTime instant, {
    tz.Location? targetLocation,
    int? utcOffsetSeconds,
  }) {
    if (targetLocation != null) {
      final tzTime = tz.TZDateTime.from(instant.toUtc(), targetLocation);
      return DateTime(
        tzTime.year,
        tzTime.month,
        tzTime.day,
        tzTime.hour,
        tzTime.minute,
        tzTime.second,
      );
    }
    if (utcOffsetSeconds != null) {
      final shifted = instant.toUtc().add(Duration(seconds: utcOffsetSeconds));
      return DateTime(
        shifted.year,
        shifted.month,
        shifted.day,
        shifted.hour,
        shifted.minute,
        shifted.second,
      );
    }
    return null;
  }

  static DateComponents _dateComponentsForTarget(
    DateTime date, {
    tz.Location? targetLocation,
    int? utcOffsetSeconds,
  }) {
    final wall = _toTargetWallClock(
      date,
      targetLocation: targetLocation,
      utcOffsetSeconds: utcOffsetSeconds,
    );
    if (wall != null) {
      return DateComponents(wall.year, wall.month, wall.day);
    }
    return DateComponents.from(date);
  }

  /// Calculate all prayer times for a specific date and coordinates
  static List<PrayerTimeItem> calculatePrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
    PrayerCalculationMethodType methodType = PrayerCalculationMethodType.tehran,
    Map<String, bool>? enabledMap,
    String? timeZoneId,
    int? utcOffsetSeconds,
  }) {
    final targetLocation = _resolveTargetLocation(timeZoneId);
    final coordinates = Coordinates(latitude, longitude);
    final dateComponents = _dateComponentsForTarget(
      date,
      targetLocation: targetLocation,
      utcOffsetSeconds: utcOffsetSeconds,
    );
    final params = methodType.adhanMethod.getParameters();
    params.madhab = Madhab.shafi; // Default standard juristic method

    final prayerTimes = PrayerTimes(coordinates, dateComponents, params);

    // Calculate Midnight (منتصف الليل): Midpoint between Sunset/Maghrib and next day's Fajr
    final nextDayDate = date.add(const Duration(days: 1));
    final nextDayComponents = _dateComponentsForTarget(
      nextDayDate,
      targetLocation: targetLocation,
      utcOffsetSeconds: utcOffsetSeconds,
    );
    final nextDayPrayerTimes =
        PrayerTimes(coordinates, nextDayComponents, params);

    final maghribTime = prayerTimes.maghrib;
    final nextFajrTime = nextDayPrayerTimes.fajr;
    final midnightTime = maghribTime.add(
      Duration(
        milliseconds: nextFajrTime.difference(maghribTime).inMilliseconds ~/ 2,
      ),
    );

    // Sunset is roughly calculated by adhan or derived from maghrib/sun position
    // In Shia Ithna-Ashari / Tehran calculation, Sunset (غروب خورشید) is before Maghrib (اذان مغرب - زوال حمره)
    // adhan package's maghrib calculation in Tehran method gives the actual Maghrib (4.5 deg),
    // and sunset can be calculated with astronomical sunset.
    DateTime sunsetTime;
    if (methodType == PrayerCalculationMethodType.tehran) {
      // In Tehran method, Maghrib is ~15-20 min after solar sunset
      sunsetTime = prayerTimes.maghrib.subtract(const Duration(minutes: 16));
    } else {
      sunsetTime = prayerTimes.maghrib;
    }

    final isAlarmFajr = enabledMap?['fajr'] ?? true;
    final isAlarmDhuhr = enabledMap?['dhuhr'] ?? true;
    final isAlarmAsr = enabledMap?['asr'] ?? false;
    final isAlarmMaghrib = enabledMap?['maghrib'] ?? true;
    final isAlarmIsha = enabledMap?['isha'] ?? false;

    PrayerTimeItem buildItem({
      required PrayerType type,
      required DateTime instant,
      required bool isAdhan,
      required bool isAlarmEnabled,
    }) {
      final localInstant = instant.toLocal();
      return PrayerTimeItem(
        type: type,
        dateTime: localInstant,
        displayWallClock: _toTargetWallClock(
          localInstant,
          targetLocation: targetLocation,
          utcOffsetSeconds: utcOffsetSeconds,
        ),
        isAdhan: isAdhan,
        isAlarmEnabled: isAlarmEnabled,
      );
    }

    return [
      buildItem(
        type: PrayerType.fajr,
        instant: prayerTimes.fajr,
        isAdhan: true,
        isAlarmEnabled: isAlarmFajr,
      ),
      buildItem(
        type: PrayerType.sunrise,
        instant: prayerTimes.sunrise,
        isAdhan: false,
        isAlarmEnabled: false,
      ),
      buildItem(
        type: PrayerType.dhuhr,
        instant: prayerTimes.dhuhr,
        isAdhan: true,
        isAlarmEnabled: isAlarmDhuhr,
      ),
      buildItem(
        type: PrayerType.asr,
        instant: prayerTimes.asr,
        isAdhan: true,
        isAlarmEnabled: isAlarmAsr,
      ),
      buildItem(
        type: PrayerType.sunset,
        instant: sunsetTime,
        isAdhan: false,
        isAlarmEnabled: false,
      ),
      buildItem(
        type: PrayerType.maghrib,
        instant: prayerTimes.maghrib,
        isAdhan: true,
        isAlarmEnabled: isAlarmMaghrib,
      ),
      buildItem(
        type: PrayerType.isha,
        instant: prayerTimes.isha,
        isAdhan: true,
        isAlarmEnabled: isAlarmIsha,
      ),
      buildItem(
        type: PrayerType.midnight,
        instant: midnightTime,
        isAdhan: false,
        isAlarmEnabled: false,
      ),
    ];
  }

  /// Find the next upcoming prayer time from the list or tomorrow's first prayer
  static PrayerTimeItem? getNextPrayer(
    List<PrayerTimeItem> todayPrayers, {
    required double latitude,
    required double longitude,
    PrayerCalculationMethodType methodType = PrayerCalculationMethodType.tehran,
    Map<String, bool>? enabledMap,
    String? timeZoneId,
    int? utcOffsetSeconds,
  }) {
    final now = DateTime.now();

    for (final item in todayPrayers) {
      if (item.dateTime.isAfter(now)) {
        return item;
      }
    }

    // If all prayers today have passed, get tomorrow's Fajr
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowPrayers = calculatePrayerTimes(
      latitude: latitude,
      longitude: longitude,
      date: tomorrow,
      methodType: methodType,
      enabledMap: enabledMap,
      timeZoneId: timeZoneId,
      utcOffsetSeconds: utcOffsetSeconds,
    );

    return tomorrowPrayers.isNotEmpty ? tomorrowPrayers.first : null;
  }
}
