import 'package:intl/intl.dart';
import 'prayer_type.dart';

class PrayerTimeItem {
  final PrayerType type;
  final DateTime dateTime;
  final DateTime? displayWallClock;
  final bool isAdhan;
  bool isAlarmEnabled;

  PrayerTimeItem({
    required this.type,
    required this.dateTime,
    this.displayWallClock,
    this.isAdhan = false,
    this.isAlarmEnabled = false,
  });

  DateTime get _formatTarget => displayWallClock ?? dateTime;

  String get formattedTime {
    return DateFormat('hh:mm a', 'ar').format(_formatTarget);
  }

  String get formattedTime24 {
    return DateFormat('HH:mm').format(_formatTarget);
  }

  String get arabicName => type.arabicName;
  String get englishName => type.englishName;
  String get iconAsset => type.iconAsset;

  bool get isPassed {
    return DateTime.now().isAfter(dateTime);
  }

  Duration get timeUntil {
    final now = DateTime.now();
    if (dateTime.isAfter(now)) {
      return dateTime.difference(now);
    }
    return Duration.zero;
  }

  PrayerTimeItem copyWith({
    PrayerType? type,
    DateTime? dateTime,
    DateTime? displayWallClock,
    bool? isAdhan,
    bool? isAlarmEnabled,
  }) {
    return PrayerTimeItem(
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      displayWallClock: displayWallClock ?? this.displayWallClock,
      isAdhan: isAdhan ?? this.isAdhan,
      isAlarmEnabled: isAlarmEnabled ?? this.isAlarmEnabled,
    );
  }
}
