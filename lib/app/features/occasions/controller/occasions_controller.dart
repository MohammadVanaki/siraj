import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../data/occasions_dataset.dart';
import '../service/hijri_calendar_service.dart';

class OccasionsController extends GetxController {
  final GetStorage _storage = GetStorage();
  static const String _adjustmentKey = 'hijri_lunar_adjustment_days';

  // ضبط اختلاف الأفق (رؤية الهلال) من -2 إلى +2
  final RxInt adjustmentDays = 0.obs;

  // التاريخ الهجري المعروض حالياً في التقويم
  final RxInt displayHijriYear = 1447.obs;
  final RxInt displayHijriMonth = 1.obs;

  // شبكة أيام الشهر الحالي
  final RxList<CalendarDayInfo> calendarDays = <CalendarDayInfo>[].obs;

  // اليوم المحدد في التقويم
  final Rxn<CalendarDayInfo> selectedDay = Rxn<CalendarDayInfo>();

  // معلومات اليوم الحالي
  final Rxn<CalendarDayInfo> todayInfo = Rxn<CalendarDayInfo>();

  @override
  void onInit() {
    super.onInit();
    HijriCalendarService.initialize();
    _loadAdjustment();
    _initCurrentDates();
    refreshCalendar();
  }

  void _loadAdjustment() {
    final saved = _storage.read<int>(_adjustmentKey);
    if (saved != null && saved >= -2 && saved <= 2) {
      adjustmentDays.value = saved;
    }
  }

  void setAdjustment(int days) {
    adjustmentDays.value = days.clamp(-2, 2);
    _storage.write(_adjustmentKey, adjustmentDays.value);
    _initCurrentDates();
    refreshCalendar();
  }

  void _initCurrentDates() {
    final now = DateTime.now();
    final todayH = HijriCalendarService.fromGregorian(now, adjustmentDays: adjustmentDays.value);

    displayHijriYear.value = todayH.hYear;
    displayHijriMonth.value = todayH.hMonth;

    final occs = OccasionsDataset.getOccasionsForHijriDay(todayH.hMonth, todayH.hDay);

    todayInfo.value = CalendarDayInfo(
      gregorianDate: DateTime(now.year, now.month, now.day),
      hijriYear: todayH.hYear,
      hijriMonth: todayH.hMonth,
      hijriDay: todayH.hDay,
      hijriMonthName: HijriCalendarService.getHijriMonthName(todayH.hMonth),
      gregorianMonthName: HijriCalendarService.getGregorianMonthName(now.month),
      weekDayName: HijriCalendarService.getWeekDayName(now),
      occasions: occs,
      isToday: true,
      isSelectedMonth: true,
    );

    selectedDay.value = todayInfo.value;
  }

  /// بناء أيام الشهر في التقويم
  void refreshCalendar() {
    calendarDays.value = HijriCalendarService.getHijriMonthGrid(
      hYear: displayHijriYear.value,
      hMonth: displayHijriMonth.value,
      adjustmentDays: adjustmentDays.value,
    );

    // إذا كان اليوم الحالي موجوداً في الشهر المعروض، يتم تحديده تلقائياً (اليوم فقط)
    // أما عند الانتقال لأشهر أخرى فلا يتم تحديد أي يوم تلقائياً إلا إذا ضغط المستخدم عليه
    final todayInGrid = calendarDays.firstWhereOrNull((d) => d.isToday);
    selectedDay.value = todayInGrid;
  }

  /// الانتقال للشهر التالي
  void nextMonth() {
    if (displayHijriMonth.value == 12) {
      displayHijriMonth.value = 1;
      displayHijriYear.value += 1;
    } else {
      displayHijriMonth.value += 1;
    }
    refreshCalendar();
  }

  /// الانتقال للشهر السابق
  void prevMonth() {
    if (displayHijriMonth.value == 1) {
      displayHijriMonth.value = 12;
      displayHijriYear.value -= 1;
    } else {
      displayHijriMonth.value -= 1;
    }
    refreshCalendar();
  }

  /// العودة إلى اليوم الحالي
  void jumpToToday() {
    _initCurrentDates();
    refreshCalendar();
  }

  /// تحديد يوم في شبكة التقويم
  void selectDay(CalendarDayInfo day) {
    selectedDay.value = day;
  }

  /// نص عنوان الشهر المعروض حالياً (التقويم الهجري)
  String get currentMonthTitle {
    final name = HijriCalendarService.getHijriMonthName(displayHijriMonth.value);
    return '$name ${displayHijriYear.value} هـ';
  }

  /// العنوان الفرعي للشهر (الفترة الميلادية المقابلة)
  String get currentMonthSubtitle {
    final firstG = HijriCalendarService.toGregorian(
      displayHijriYear.value,
      displayHijriMonth.value,
      1,
      adjustmentDays: adjustmentDays.value,
    );
    final daysInMonth = HijriCalendarService.getDaysInMonth(
      displayHijriYear.value,
      displayHijriMonth.value,
    );
    final lastG = HijriCalendarService.toGregorian(
      displayHijriYear.value,
      displayHijriMonth.value,
      daysInMonth,
      adjustmentDays: adjustmentDays.value,
    );
    final m1 = HijriCalendarService.getGregorianMonthName(firstG.month);
    final m2 = HijriCalendarService.getGregorianMonthName(lastG.month);
    if (m1 == m2 && firstG.year == lastG.year) {
      return '$m1 ${firstG.year} م';
    } else if (firstG.year == lastG.year) {
      return '$m1 - $m2 ${firstG.year} م';
    }
    return '$m1 ${firstG.year} - $m2 ${lastG.year} م';
  }
}
