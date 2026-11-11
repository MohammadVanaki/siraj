import 'package:hijri/hijri_calendar.dart';
import '../data/occasions_dataset.dart';
import '../model/occasion_model.dart';

class CalendarDayInfo {
  final DateTime gregorianDate;
  final int hijriYear;
  final int hijriMonth;
  final int hijriDay;
  final String hijriMonthName;
  final String gregorianMonthName;
  final String weekDayName;
  final List<Occasion> occasions;
  final bool isToday;
  final bool isPast;
  final bool isSelectedMonth;

  CalendarDayInfo({
    required this.gregorianDate,
    required this.hijriYear,
    required this.hijriMonth,
    required this.hijriDay,
    required this.hijriMonthName,
    required this.gregorianMonthName,
    required this.weekDayName,
    required this.occasions,
    this.isToday = false,
    this.isPast = false,
    this.isSelectedMonth = true,
  });

  bool get hasOccasions => occasions.isNotEmpty;
  bool get hasMajorOccasion => occasions.any((o) => o.isMajor);
  bool get hasJoyOccasion => occasions.any((o) => o.type == OccasionType.joy);
  bool get hasMourningOccasion => occasions.any((o) => o.type == OccasionType.mourning);
  bool get isFriday => gregorianDate.weekday == DateTime.friday;
  bool get isHoliday =>
      isFriday ||
      occasions.any((o) => o.isHoliday) ||
      OccasionsDataset.isHijriHoliday(hijriMonth, hijriDay);
}

class HijriCalendarService {
  static void initialize() {
    HijriCalendar.setLocal('ar');
  }

  /// تحويل تاريخ ميلادي إلى هجري مع تطبيق تعديل رؤية الهلال
  static HijriCalendar fromGregorian(DateTime gregorianDate, {int adjustmentDays = 0}) {
    final adjusted = gregorianDate.add(Duration(days: adjustmentDays));
    final hDate = HijriCalendar.fromDate(adjusted);
    return hDate;
  }

  /// تحويل تاريخ هجري إلى تاريخ ميلادي مع مراعاة التعديل
  static DateTime toGregorian(int hYear, int hMonth, int hDay, {int adjustmentDays = 0}) {
    final hDate = HijriCalendar();
    hDate.hYear = hYear;
    hDate.hMonth = hMonth;
    hDate.hDay = hDay;
    final gDate = hDate.hijriToGregorian(hYear, hMonth, hDay);
    return gDate.subtract(Duration(days: adjustmentDays));
  }

  /// جلب اسم الشهر الهجري
  static String getHijriMonthName(int month) {
    if (month >= 1 && month <= 12) {
      return OccasionsDataset.hijriMonthNames[month - 1];
    }
    return '';
  }

  /// جلب اسم الشهر الميلادي بالعربية
  static String getGregorianMonthName(int month) {
    if (month >= 1 && month <= 12) {
      return OccasionsDataset.gregorianMonthNamesArabic[month - 1];
    }
    return '';
  }

  /// جلب اسم يوم الأسبوع بالعربية (السبت = 6 في DateTime.saturday)
  static String getWeekDayName(DateTime date) {
    // DateTime.weekday: Monday is 1 and Sunday is 7
    switch (date.weekday) {
      case DateTime.saturday:
        return 'السبت';
      case DateTime.sunday:
        return 'الأحد';
      case DateTime.monday:
        return 'الإثنين';
      case DateTime.tuesday:
        return 'الثلاثاء';
      case DateTime.wednesday:
        return 'الأربعاء';
      case DateTime.thursday:
        return 'الخميس';
      case DateTime.friday:
        return 'الجمعة';
      default:
        return '';
    }
  }

  /// جلب عدد أيام الشهر الهجري
  static int getDaysInMonth(int hYear, int hMonth) {
    return HijriCalendar().getDaysInMonth(hYear, hMonth);
  }

  /// توليد شبكة أيام الشهر الهجري
  static List<CalendarDayInfo> getHijriMonthGrid({
    required int hYear,
    required int hMonth,
    int adjustmentDays = 0,
    DateTime? today,
  }) {
    today ??= DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    // حساب عدد أيام الشهر الهجري الحالي
    final daysInMonth = getDaysInMonth(hYear, hMonth);

    // أول يوم في الشهر الهجري وتاريخه الميلادي
    final firstDayGregorian = toGregorian(hYear, hMonth, 1, adjustmentDays: adjustmentDays);
    
    // في التقويم الإسلامي والعربي، يبدأ الأسبوع بيوم السبت (السبت = 0 offset)
    // DateTime.weekday: Saturday=6, Sunday=7, Monday=1, ..., Friday=5
    int startWeekdayOffset = (firstDayGregorian.weekday % 7 + 1) % 7; 
    // Saturday(6): (6 % 7 + 1) % 7 = (6 + 1) % 7 = 0. Perfect!
    // Sunday(7): (7 % 7 + 1) % 7 = (0 + 1) % 7 = 1.
    // Monday(1): (1 % 7 + 1) % 7 = 2.
    // Friday(5): (5 % 7 + 1) % 7 = 6.

    final List<CalendarDayInfo> grid = [];

    // 1. الأيام المتممة من الشهر الهجري السابق قبل بداية الشهر
    if (startWeekdayOffset > 0) {
      final prevMonth = hMonth == 1 ? 12 : hMonth - 1;
      final prevYear = hMonth == 1 ? hYear - 1 : hYear;
      final prevMonthDays = getDaysInMonth(prevYear, prevMonth);

      for (int i = startWeekdayOffset - 1; i >= 0; i--) {
        final day = prevMonthDays - i;
        final gDate = toGregorian(prevYear, prevMonth, day, adjustmentDays: adjustmentDays);
        final gNormalized = DateTime(gDate.year, gDate.month, gDate.day);
        final occs = OccasionsDataset.getOccasionsForHijriDay(prevMonth, day);

        grid.add(CalendarDayInfo(
          gregorianDate: gNormalized,
          hijriYear: prevYear,
          hijriMonth: prevMonth,
          hijriDay: day,
          hijriMonthName: getHijriMonthName(prevMonth),
          gregorianMonthName: getGregorianMonthName(gNormalized.month),
          weekDayName: getWeekDayName(gNormalized),
          occasions: occs,
          isToday: gNormalized.isAtSameMomentAs(todayNormalized),
          isPast: gNormalized.isBefore(todayNormalized),
          isSelectedMonth: false,
        ));
      }
    }

    // 2. أيام الشهر الهجري الحالي
    for (int day = 1; day <= daysInMonth; day++) {
      final gDate = toGregorian(hYear, hMonth, day, adjustmentDays: adjustmentDays);
      final gNormalized = DateTime(gDate.year, gDate.month, gDate.day);
      final occs = OccasionsDataset.getOccasionsForHijriDay(hMonth, day);

      grid.add(CalendarDayInfo(
        gregorianDate: gNormalized,
        hijriYear: hYear,
        hijriMonth: hMonth,
        hijriDay: day,
        hijriMonthName: getHijriMonthName(hMonth),
        gregorianMonthName: getGregorianMonthName(gNormalized.month),
        weekDayName: getWeekDayName(gNormalized),
        occasions: occs,
        isToday: gNormalized.isAtSameMomentAs(todayNormalized),
        isPast: gNormalized.isBefore(todayNormalized),
        isSelectedMonth: true,
      ));
    }

    // 3. الأيام المتممة للشهر التالي حتى اكتمال صفوف الجدول (مضاعف 7)
    final remaining = (7 - (grid.length % 7)) % 7;
    if (remaining > 0) {
      final nextMonth = hMonth == 12 ? 1 : hMonth + 1;
      final nextYear = hMonth == 12 ? hYear + 1 : hYear;

      for (int day = 1; day <= remaining; day++) {
        final gDate = toGregorian(nextYear, nextMonth, day, adjustmentDays: adjustmentDays);
        final gNormalized = DateTime(gDate.year, gDate.month, gDate.day);
        final occs = OccasionsDataset.getOccasionsForHijriDay(nextMonth, day);

        grid.add(CalendarDayInfo(
          gregorianDate: gNormalized,
          hijriYear: nextYear,
          hijriMonth: nextMonth,
          hijriDay: day,
          hijriMonthName: getHijriMonthName(nextMonth),
          gregorianMonthName: getGregorianMonthName(gNormalized.month),
          weekDayName: getWeekDayName(gNormalized),
          occasions: occs,
          isToday: gNormalized.isAtSameMomentAs(todayNormalized),
          isPast: gNormalized.isBefore(todayNormalized),
          isSelectedMonth: false,
        ));
      }
    }

    return grid;
  }
}
