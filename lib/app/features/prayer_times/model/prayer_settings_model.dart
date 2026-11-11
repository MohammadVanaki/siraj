import 'package:adhan/adhan.dart';

enum PrayerCalculationMethodType {
  tehran, // موسسة لواء قم / ژئوفیزیک تهران (شیعه اثنی عشری)
  ummAlQura, // ام القرى (مكة المكرمة)
  muslimWorldLeague, // رابطة العالم الإسلامي
  karachi, // جامعة العلوم الإسلامية بكراتشي
  egyptian, // الهيئة المصرية العامة للمساحة
  dubai, // دبي
  kuwait, // الكويت
  qatar, // قطر
  northAmerica, // أمريكا الشمالية (ISNA)
}

extension PrayerCalculationMethodTypeExtension on PrayerCalculationMethodType {
  String get title {
    switch (this) {
      case PrayerCalculationMethodType.tehran:
        return 'طريقة طهران / لواء قم (الشيعة الإمامية)';
      case PrayerCalculationMethodType.ummAlQura:
        return 'أم القرى (مكة المكرمة)';
      case PrayerCalculationMethodType.muslimWorldLeague:
        return 'رابطة العالم الإسلامي';
      case PrayerCalculationMethodType.karachi:
        return 'جامعة العلوم الإسلامية بكراتشي';
      case PrayerCalculationMethodType.egyptian:
        return 'الهيئة العامة المصرية للمساحة';
      case PrayerCalculationMethodType.dubai:
        return 'دائرة الشؤون الإسلامية بدبي';
      case PrayerCalculationMethodType.kuwait:
        return 'وزارة الأوقاف والشؤون الإسلامية بالكويت';
      case PrayerCalculationMethodType.qatar:
        return 'وزارة الأوقاف والشؤون الإسلامية بقطر';
      case PrayerCalculationMethodType.northAmerica:
        return 'الجمعية الإسلامية لأمريكا الشمالية (ISNA)';
    }
  }

  CalculationMethod get adhanMethod {
    switch (this) {
      case PrayerCalculationMethodType.tehran:
        return CalculationMethod.tehran;
      case PrayerCalculationMethodType.ummAlQura:
        return CalculationMethod.umm_al_qura;
      case PrayerCalculationMethodType.muslimWorldLeague:
        return CalculationMethod.muslim_world_league;
      case PrayerCalculationMethodType.karachi:
        return CalculationMethod.karachi;
      case PrayerCalculationMethodType.egyptian:
        return CalculationMethod.egyptian;
      case PrayerCalculationMethodType.dubai:
        return CalculationMethod.dubai;
      case PrayerCalculationMethodType.kuwait:
        return CalculationMethod.kuwait;
      case PrayerCalculationMethodType.qatar:
        return CalculationMethod.qatar;
      case PrayerCalculationMethodType.northAmerica:
        return CalculationMethod.north_america;
    }
  }
}

class PrayerSettingsModel {
  PrayerCalculationMethodType methodType;
  double latitude;
  double longitude;
  String cityName;
  bool isManualLocation;
  bool hasResolvedLocation;
  String? timeZoneId;
  int? utcOffsetSeconds;
  Map<String, bool> enabledPrayers; // e.g. {'fajr': true, 'dhuhr': true, 'maghrib': true}
  bool playFullAdhan;
  double volume;
  String adhanVoiceId;

  PrayerSettingsModel({
    this.methodType = PrayerCalculationMethodType.tehran,
    this.latitude = 33.3152,
    this.longitude = 44.3661,
    this.cityName = 'جاري تحديد الموقع...',
    this.isManualLocation = false,
    this.hasResolvedLocation = false,
    this.timeZoneId,
    this.utcOffsetSeconds,
    Map<String, bool>? enabledPrayers,
    this.playFullAdhan = true,
    this.volume = 1.0,
    this.adhanVoiceId = 'moazenzadeh',
  }) : enabledPrayers = enabledPrayers ??
            {
              'fajr': true,
              'dhuhr': true,
              'asr': false,
              'maghrib': true,
              'isha': false,
            };

  Map<String, dynamic> toJson() {
    return {
      'methodType': methodType.index,
      'latitude': latitude,
      'longitude': longitude,
      'cityName': cityName,
      'isManualLocation': isManualLocation,
      'hasResolvedLocation': hasResolvedLocation,
      'timeZoneId': timeZoneId,
      'utcOffsetSeconds': utcOffsetSeconds,
      'enabledPrayers': enabledPrayers,
      'playFullAdhan': playFullAdhan,
      'volume': volume,
      'adhanVoiceId': adhanVoiceId,
    };
  }

  factory PrayerSettingsModel.fromJson(Map<String, dynamic> json) {
    final storedMethodIndex = json['methodType'] as int?;
    final safeMethod = (storedMethodIndex != null &&
            storedMethodIndex >= 0 &&
            storedMethodIndex < PrayerCalculationMethodType.values.length)
        ? PrayerCalculationMethodType.values[storedMethodIndex]
        : PrayerCalculationMethodType.tehran;

    final rawLat = (json['latitude'] as num?)?.toDouble();
    final rawLng = (json['longitude'] as num?)?.toDouble();
    final rawCity = json['cityName'] as String?;
    final isManual = json['isManualLocation'] as bool? ?? false;
    final storedResolved = json['hasResolvedLocation'] as bool?;

    // Migrate legacy installs stuck on the hardcoded Central Iran (32.0, 53.0) default
    final isLegacyIranPlaceholder =
        rawLat == null ||
        rawLng == null ||
        ((rawLat - 32.0).abs() < 0.001 &&
            (rawLng - 53.0).abs() < 0.001 &&
            (rawCity == null || rawCity == 'الموقع التلقائي'));

    final resolved = storedResolved ?? (!isLegacyIranPlaceholder || isManual);

    return PrayerSettingsModel(
      methodType: safeMethod,
      latitude: isLegacyIranPlaceholder ? 33.3152 : rawLat,
      longitude: isLegacyIranPlaceholder ? 44.3661 : rawLng,
      cityName: (isLegacyIranPlaceholder && !isManual)
          ? 'جاري تحديد الموقع...'
          : (rawCity ?? 'جاري تحديد الموقع...'),
      isManualLocation: isManual,
      hasResolvedLocation: resolved,
      timeZoneId: json['timeZoneId'] as String?,
      utcOffsetSeconds: (json['utcOffsetSeconds'] as num?)?.toInt(),
      enabledPrayers: json['enabledPrayers'] != null
          ? Map<String, bool>.from(json['enabledPrayers'] as Map)
          : null,
      playFullAdhan: json['playFullAdhan'] as bool? ?? true,
      volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
      adhanVoiceId: json['adhanVoiceId'] as String? ?? 'moazenzadeh',
    );
  }
}
