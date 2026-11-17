import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mawsueat/app/features/prayer_times/model/prayer_city_model.dart';
import 'package:mawsueat/app/features/prayer_times/model/prayer_settings_model.dart';
import 'package:mawsueat/app/features/prayer_times/model/prayer_type.dart';
import 'package:mawsueat/app/features/prayer_times/service/prayer_calculation_service.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ar');
  });

  test('Legacy Central Iran placeholder (32.0, 53.0) migrates as unresolved', () {
    final legacy = PrayerSettingsModel.fromJson({
      'methodType': 0,
      'latitude': 32.0,
      'longitude': 53.0,
      'cityName': 'الموقع التلقائي',
    });

    expect(legacy.hasResolvedLocation, isFalse);
    expect(legacy.isManualLocation, isFalse);
  });

  test('Saved resolved city preserves hasResolvedLocation = true', () {
    final saved = PrayerSettingsModel.fromJson({
      'methodType': 0,
      'latitude': 32.0000,
      'longitude': 44.3333,
      'cityName': 'النجف الأشرف',
    });

    expect(saved.hasResolvedLocation, isTrue);
    expect(saved.cityName, 'النجف الأشرف');
    expect(saved.latitude, closeTo(32.0, 0.001));
    expect(saved.longitude, closeTo(44.3333, 0.001));
  });

  test('Najaf and Tehran wall-clock display times match each city horizon', () {
    final najaf = PrayerCityModel.presetCities.firstWhere(
      (c) => c.name == 'النجف الأشرف',
    );
    final tehran = PrayerCityModel.presetCities.firstWhere(
      (c) => c.name == 'طهران',
    );
    final date = DateTime(2026, 5, 15, 10, 0);

    final najafPrayers = PrayerCalculationService.calculatePrayerTimes(
      latitude: najaf.latitude,
      longitude: najaf.longitude,
      date: date,
      timeZoneId: najaf.timeZoneId,
      utcOffsetSeconds: najaf.utcOffsetSeconds,
    );

    final tehranPrayers = PrayerCalculationService.calculatePrayerTimes(
      latitude: tehran.latitude,
      longitude: tehran.longitude,
      date: date,
      timeZoneId: tehran.timeZoneId,
      utcOffsetSeconds: tehran.utcOffsetSeconds,
    );

    final najafDhuhr = najafPrayers.firstWhere((e) => e.type == PrayerType.dhuhr);
    final tehranDhuhr = tehranPrayers.firstWhere((e) => e.type == PrayerType.dhuhr);

    // Dhuhr in both cities should be around local solar noon (~11:55 - 12:15)
    expect(najafDhuhr.displayWallClock!.hour, inInclusiveRange(11, 12));
    expect(tehranDhuhr.displayWallClock!.hour, inInclusiveRange(11, 12));

    // In real UTC instants, Najaf (44.33E) solar noon occurs later than Tehran (51.39E)
    expect(najafDhuhr.dateTime.isAfter(tehranDhuhr.dateTime), isTrue);
  });

  test('Prayer offsets calculate effectiveAlertTime and offset descriptions correctly', () {
    final najaf = PrayerCityModel.presetCities.firstWhere(
      (c) => c.name == 'النجف الأشرف',
    );
    final date = DateTime(2026, 5, 15, 10, 0);
    final offsets = {
      'fajr': -5,
      'maghrib': 4,
      'isha': 0,
    };

    final prayers = PrayerCalculationService.calculatePrayerTimes(
      latitude: najaf.latitude,
      longitude: najaf.longitude,
      date: date,
      timeZoneId: najaf.timeZoneId,
      utcOffsetSeconds: najaf.utcOffsetSeconds,
      prayerOffsets: offsets,
    );

    final fajr = prayers.firstWhere((e) => e.type == PrayerType.fajr);
    final maghrib = prayers.firstWhere((e) => e.type == PrayerType.maghrib);
    final isha = prayers.firstWhere((e) => e.type == PrayerType.isha);

    // Fajr: 5 min before
    expect(fajr.notificationOffsetMinutes, equals(-5));
    expect(fajr.effectiveAlertTime, equals(fajr.dateTime.subtract(const Duration(minutes: 5))));
    expect(fajr.offsetDescription, equals('قبل الأذان بـ 5 د'));

    // Maghrib: 4 min after
    expect(maghrib.notificationOffsetMinutes, equals(4));
    expect(maghrib.effectiveAlertTime, equals(maghrib.dateTime.add(const Duration(minutes: 4))));
    expect(maghrib.offsetDescription, equals('بعد الأذان بـ 4 د'));

    // Isha: on time
    expect(isha.notificationOffsetMinutes, equals(0));
    expect(isha.effectiveAlertTime, equals(isha.dateTime));
    expect(isha.offsetDescription, equals('في الموعد'));
  });

  test('PrayerSettingsModel serializes and deserializes prayerOffsets accurately', () {
    final model = PrayerSettingsModel(
      cityName: 'كربلاء المقدسة',
      latitude: 32.6160,
      longitude: 44.0249,
      prayerOffsets: {
        'fajr': -10,
        'dhuhr': -5,
        'maghrib': 7,
      },
    );

    final json = model.toJson();
    final restored = PrayerSettingsModel.fromJson(json);

    expect(restored.getOffsetFor('fajr'), equals(-10));
    expect(restored.getOffsetFor('dhuhr'), equals(-5));
    expect(restored.getOffsetFor('maghrib'), equals(7));
    expect(restored.getOffsetFor('asr'), equals(0)); // default
  });
}

