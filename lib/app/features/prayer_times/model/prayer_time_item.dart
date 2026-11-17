import 'package:intl/intl.dart';
import 'prayer_type.dart';

class PrayerTimeItem {
  final PrayerType type;
  final DateTime dateTime;
  final DateTime? displayWallClock;
  final bool isAdhan;
  bool isAlarmEnabled;
  final int notificationOffsetMinutes;

  PrayerTimeItem({
    required this.type,
    required this.dateTime,
    this.displayWallClock,
    this.isAdhan = false,
    this.isAlarmEnabled = false,
    this.notificationOffsetMinutes = 0,
  });

  DateTime get _formatTarget => displayWallClock ?? dateTime;

  String get formattedTime {
    return DateFormat('hh:mm a', 'ar').format(_formatTarget);
  }

  String get formattedTime24 {
    return DateFormat('HH:mm').format(_formatTarget);
  }

  DateTime get effectiveAlertTime =>
      dateTime.add(Duration(minutes: notificationOffsetMinutes));

  DateTime? get displayEffectiveAlertWallClock =>
      displayWallClock?.add(Duration(minutes: notificationOffsetMinutes));

  String get formattedAlertTime {
    final target = displayEffectiveAlertWallClock ?? effectiveAlertTime;
    return DateFormat('hh:mm a', 'ar').format(target);
  }

  String get offsetDescription {
    if (notificationOffsetMinutes == 0) return 'في الموعد';
    if (notificationOffsetMinutes < 0) {
      return 'قبل الأذان بـ ${notificationOffsetMinutes.abs()} د';
    }
    return 'بعد الأذان بـ $notificationOffsetMinutes د';
  }

  String get arabicName => type.arabicName;
  String get englishName => type.englishName;
  String get iconAsset => type.iconAsset;

  bool get isPassed {
    return DateTime.now().isAfter(dateTime);
  }

  bool get isAlertPassed {
    return DateTime.now().isAfter(effectiveAlertTime);
  }

  Duration get timeUntil {
    final now = DateTime.now();
    if (dateTime.isAfter(now)) {
      return dateTime.difference(now);
    }
    return Duration.zero;
  }

  Duration get timeUntilAlert {
    final now = DateTime.now();
    if (effectiveAlertTime.isAfter(now)) {
      return effectiveAlertTime.difference(now);
    }
    return Duration.zero;
  }

  PrayerTimeItem copyWith({
    PrayerType? type,
    DateTime? dateTime,
    DateTime? displayWallClock,
    bool? isAdhan,
    bool? isAlarmEnabled,
    int? notificationOffsetMinutes,
  }) {
    return PrayerTimeItem(
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      displayWallClock: displayWallClock ?? this.displayWallClock,
      isAdhan: isAdhan ?? this.isAdhan,
      isAlarmEnabled: isAlarmEnabled ?? this.isAlarmEnabled,
      notificationOffsetMinutes:
          notificationOffsetMinutes ?? this.notificationOffsetMinutes,
    );
  }
}
