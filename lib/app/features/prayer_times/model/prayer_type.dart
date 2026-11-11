enum PrayerType { fajr, sunrise, dhuhr, asr, sunset, maghrib, isha, midnight }

extension PrayerTypeExtension on PrayerType {
  String get arabicName {
    switch (this) {
      case PrayerType.fajr:
        return 'الفجر';
      case PrayerType.sunrise:
        return 'الشروق';
      case PrayerType.dhuhr:
        return 'الظهر';
      case PrayerType.asr:
        return 'العصر';
      case PrayerType.sunset:
        return 'الغروب';
      case PrayerType.maghrib:
        return 'المغرب';
      case PrayerType.isha:
        return 'العشاء';
      case PrayerType.midnight:
        return 'منتصف الليل';
    }
  }

  String get englishName {
    switch (this) {
      case PrayerType.fajr:
        return 'Fajr';
      case PrayerType.sunrise:
        return 'Sunrise';
      case PrayerType.dhuhr:
        return 'Dhuhr';
      case PrayerType.asr:
        return 'Asr';
      case PrayerType.sunset:
        return 'Sunset';
      case PrayerType.maghrib:
        return 'Maghrib';
      case PrayerType.isha:
        return 'Isha';
      case PrayerType.midnight:
        return 'Midnight';
    }
  }

  String get iconAsset {
    switch (this) {
      case PrayerType.fajr:
        return 'assets/svgs/moon.svg';
      case PrayerType.sunrise:
        return 'assets/svgs/brightness.svg';
      case PrayerType.dhuhr:
        return 'assets/svgs/brightness.svg';
      case PrayerType.asr:
        return 'assets/svgs/brightness.svg';
      case PrayerType.sunset:
        return 'assets/svgs/moon.svg';
      case PrayerType.maghrib:
        return 'assets/svgs/moon.svg';
      case PrayerType.isha:
        return 'assets/svgs/moon.svg';
      case PrayerType.midnight:
        return 'assets/svgs/moon.svg';
    }
  }

  /// Whether this prayer has an Adhan call (Fajr, Dhuhr, Asr, Maghrib, Isha)
  bool get isAdhanPrayer {
    return this == PrayerType.fajr ||
        this == PrayerType.dhuhr ||
        this == PrayerType.asr ||
        this == PrayerType.maghrib ||
        this == PrayerType.isha;
  }
}
