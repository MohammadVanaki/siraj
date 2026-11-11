class ChellehModel {
  final String id;
  final String? dhikrId;
  final String title;
  final String? bodyArabic;
  final String niyyah;
  final int totalDays; // Custom day duration (default 40 for Arbaeen)
  final bool isDhikr; // true for counter-based dhikr, false for recitation-based Surah/Dua
  final int targetCountPerDay;
  final int currentDayCount;
  final DateTime startDate;
  final List<int> completedDays; // Day numbers 1 to totalDays
  final bool isReminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final String? lastActiveDateString; // YYYY-MM-DD for tracking 24h reset
  final String? lastMissedPromptDismissedDate; // YYYY-MM-DD prevents prompting repeatedly today

  const ChellehModel({
    required this.id,
    this.dhikrId,
    this.title = 'أربعينية الصلوات',
    this.bodyArabic,
    this.niyyah = 'تعجيل في فرج مولانا صاحب الزمان (عج)',
    this.totalDays = 40,
    this.isDhikr = true,
    this.targetCountPerDay = 100,
    this.currentDayCount = 0,
    required this.startDate,
    this.completedDays = const [],
    this.isReminderEnabled = true,
    this.reminderHour = 8,
    this.reminderMinute = 0,
    this.lastActiveDateString,
    this.lastMissedPromptDismissedDate,
  });

  /// The active day index (1-based, 1 to totalDays) based on start date and today
  int get activeDayNumber {
    final now = DateTime.now();
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final today = DateTime(now.year, now.month, now.day);
    final diffDays = today.difference(start).inDays;
    final maxDays = totalDays > 0 ? totalDays : 40;
    return (diffDays + 1).clamp(1, maxDays);
  }

  /// Exact calendar date for a specific day number (1 to totalDays)
  DateTime dateForDay(int dayNumber) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    return start.add(Duration(days: dayNumber - 1));
  }

  /// Whether a specific day is locked (in the future)
  bool isDayLocked(int dayNumber) => dayNumber > activeDayNumber;

  /// Whether today's day number is in completedDays
  bool get isTodayCompleted => completedDays.contains(activeDayNumber);

  /// Overall completion percentage (0.0 to 1.0)
  double get overallProgress {
    final maxDays = totalDays > 0 ? totalDays : 40;
    return (completedDays.length / maxDays).clamp(0.0, 1.0);
  }

  /// Today's counter progress (0.0 to 1.0)
  double get todayProgress {
    if (targetCountPerDay <= 0) return 0.0;
    return (currentDayCount / targetCountPerDay).clamp(0.0, 1.0);
  }

  /// List of past days (strictly before activeDayNumber) that were not marked as completed
  List<int> get missedDays {
    final list = <int>[];
    for (int day = 1; day < activeDayNumber; day++) {
      if (!completedDays.contains(day)) {
        list.add(day);
      }
    }
    return list;
  }

  /// Whether there are any missed past days
  bool get hasMissedDays => missedDays.isNotEmpty;

  ChellehModel copyWith({
    String? id,
    String? dhikrId,
    String? title,
    String? bodyArabic,
    String? niyyah,
    int? totalDays,
    bool? isDhikr,
    int? targetCountPerDay,
    int? currentDayCount,
    DateTime? startDate,
    List<int>? completedDays,
    bool? isReminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    String? lastActiveDateString,
    String? lastMissedPromptDismissedDate,
  }) {
    return ChellehModel(
      id: id ?? this.id,
      dhikrId: dhikrId ?? this.dhikrId,
      title: title ?? this.title,
      bodyArabic: bodyArabic ?? this.bodyArabic,
      niyyah: niyyah ?? this.niyyah,
      totalDays: totalDays ?? this.totalDays,
      isDhikr: isDhikr ?? this.isDhikr,
      targetCountPerDay: targetCountPerDay ?? this.targetCountPerDay,
      currentDayCount: currentDayCount ?? this.currentDayCount,
      startDate: startDate ?? this.startDate,
      completedDays: completedDays ?? this.completedDays,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      lastActiveDateString: lastActiveDateString ?? this.lastActiveDateString,
      lastMissedPromptDismissedDate:
          lastMissedPromptDismissedDate ?? this.lastMissedPromptDismissedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dhikrId': dhikrId,
      'title': title,
      'bodyArabic': bodyArabic,
      'niyyah': niyyah,
      'totalDays': totalDays,
      'isDhikr': isDhikr,
      'targetCountPerDay': targetCountPerDay,
      'currentDayCount': currentDayCount,
      'startDate': startDate.toIso8601String(),
      'completedDays': completedDays,
      'isReminderEnabled': isReminderEnabled,
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
      'lastActiveDateString': lastActiveDateString,
      'lastMissedPromptDismissedDate': lastMissedPromptDismissedDate,
    };
  }

  factory ChellehModel.fromJson(Map<String, dynamic> json) {
    return ChellehModel(
      id: json['id'] as String? ?? 'default_salawat_chelleh',
      dhikrId: json['dhikrId'] as String?,
      title: json['title'] as String? ?? 'أربعينية الصلوات',
      bodyArabic: json['bodyArabic'] as String?,
      niyyah:
          json['niyyah'] as String? ?? 'تعجيل في فرج مولانا صاحب الزمان (عج)',
      totalDays: json['totalDays'] as int? ?? 40,
      isDhikr: json['isDhikr'] as bool? ?? true,
      targetCountPerDay: json['targetCountPerDay'] as int? ?? 100,
      currentDayCount: json['currentDayCount'] as int? ?? 0,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : DateTime.now(),
      completedDays:
          (json['completedDays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      isReminderEnabled: json['isReminderEnabled'] as bool? ?? true,
      reminderHour: json['reminderHour'] as int? ?? 8,
      reminderMinute: json['reminderMinute'] as int? ?? 0,
      lastActiveDateString: json['lastActiveDateString'] as String?,
      lastMissedPromptDismissedDate:
          json['lastMissedPromptDismissedDate'] as String?,
    );
  }
}


