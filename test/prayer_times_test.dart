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
}

