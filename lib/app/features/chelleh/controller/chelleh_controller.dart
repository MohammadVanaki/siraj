import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../model/arbaeen_dhikr_model.dart';
import '../model/chelleh_model.dart';
import '../service/arbaeen_api_service.dart';
import '../service/chelleh_reminder_service.dart';

class ChellehController extends GetxController {
  static ChellehController get to => Get.find<ChellehController>();

  final GetStorage _storage = GetStorage();
  final ArbaeenApiService _apiService = ArbaeenApiService();

  static const String _legacyStorageKey = 'chelleh_salawat_data';
  static const String _lastActiveDhikrKey = 'last_active_arbaeen_dhikr_id';

  /// لیست اذکار اربعینیات دریافت شده از API
  final RxList<ArbaeenDhikrModel> adhkarList = <ArbaeenDhikrModel>[].obs;
  final RxBool isLoadingAdhkar = false.obs;

  /// ذکر اربعینی فعال کنونی
  final Rx<ArbaeenDhikrModel?> activeDhikr = Rx<ArbaeenDhikrModel?>(null);

  /// مدل ردیابی ۴۰ روزه برای ذکر فعال
  late final Rx<ChellehModel> chelleh;
  final RxBool isLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initController();
  }

  Future<void> _initController() async {
    // 1. بارگذاری اذکار از کش
    final cached = _apiService.getCachedAdhkar();
    adhkarList.assignAll(cached);

    // 2. تعیین ذکر پیش‌فرض
    final lastId = _storage.read<String>(_lastActiveDhikrKey);
    ArbaeenDhikrModel? initialDhikr;
    if (lastId != null && adhkarList.isNotEmpty) {
      initialDhikr = adhkarList.firstWhereOrNull((d) => d.id == lastId);
    }
    initialDhikr ??= (adhkarList.isNotEmpty ? adhkarList.first : ArbaeenApiService.defaultFallbackAdhkar.first);

    activeDhikr.value = initialDhikr;
    _initChellehForDhikr(initialDhikr);

    // 3. فراخوانی API در پس‌زمینه جهت دریافت جدیدترین اذکار
    refreshAdhkarFromApi();
  }

  /// دریافت آنلاین اذکار از API
  Future<void> refreshAdhkarFromApi() async {
    try {
      isLoadingAdhkar.value = true;
      final fresh = await _apiService.fetchAdhkar();
      if (fresh.isNotEmpty) {
        adhkarList.assignAll(fresh);
        if (activeDhikr.value != null) {
          final updated = fresh.firstWhereOrNull((d) => d.id == activeDhikr.value!.id);
          if (updated != null) {
            activeDhikr.value = updated;
          }
        }
      }
    } catch (e) {
      debugPrint('Error in refreshAdhkarFromApi: $e');
    } finally {
      isLoadingAdhkar.value = false;
    }
  }

  String _dhikrStorageKey(String dhikrId) => 'chelleh_dhikr_$dhikrId';

  /// مقداردهی یا بارگذاری وضعیت چله برای یک ذکر مشخص
  void _initChellehForDhikr(ArbaeenDhikrModel dhikr) {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final key = _dhikrStorageKey(dhikr.id);
    var storedJson = _storage.read<Map<String, dynamic>>(key);

    // پشتیبانی و انتقال اطلاعات از نسخه قدیمی صلوات در صورت نیاز
    if (storedJson == null && dhikr.titleArabic.contains('صلوات')) {
      storedJson = _storage.read<Map<String, dynamic>>(_legacyStorageKey);
    }

    if (storedJson != null) {
      var model = ChellehModel.fromJson(storedJson);
      // بازنشانی شمارنده روزانه در صورت ورود به روز تقویمی جدید
      if (model.lastActiveDateString != null &&
          model.lastActiveDateString != todayStr) {
        model = model.copyWith(
          currentDayCount: 0,
          lastActiveDateString: todayStr,
        );
      }
      // اطمینان از به‌روز بودن عنوان و متن
      model = model.copyWith(
        title: dhikr.isDuaOrSurah ? dhikr.titleArabic : 'أربعينية ${dhikr.titleArabic}',
        bodyArabic: dhikr.bodyArabic,
        dhikrId: dhikr.id,
        isDhikr: dhikr.isDhikr,
      );
      if (isLoaded.value) {
        chelleh.value = model;
      } else {
        chelleh = model.obs;
      }
    } else {
      final initialModel = ChellehModel(
        id: 'chelleh_${dhikr.id}',
        dhikrId: dhikr.id,
        title: dhikr.isDuaOrSurah ? dhikr.titleArabic : 'أربعينية ${dhikr.titleArabic}',
        bodyArabic: dhikr.bodyArabic,
        totalDays: 40,
        isDhikr: dhikr.isDhikr,
        targetCountPerDay: dhikr.isDuaOrSurah
            ? 1
            : (dhikr.repetitionCount > 0 ? dhikr.repetitionCount : 100),
        startDate: now,
        lastActiveDateString: todayStr,
      );
      if (isLoaded.value) {
        chelleh.value = initialModel;
      } else {
        chelleh = initialModel.obs;
      }
      _saveCurrentChelleh();
    }

    isLoaded.value = true;
    _syncReminder();
  }

  /// انتخاب یک ذکر برای مشاهده و پیگیری چله ۴۰ روزه
  void selectDhikr(ArbaeenDhikrModel dhikr) {
    activeDhikr.value = dhikr;
    _storage.write(_lastActiveDhikrKey, dhikr.id);
    _initChellehForDhikr(dhikr);
  }

  /// دریافت وضعیت چله یک ذکر خاص (برای نمایش پیشرفت روی کارت‌های صفحه لیست)
  ChellehModel getProgressForDhikr(ArbaeenDhikrModel dhikr) {
    if (activeDhikr.value?.id == dhikr.id && isLoaded.value) {
      return chelleh.value;
    }

    final key = _dhikrStorageKey(dhikr.id);
    var storedJson = _storage.read<Map<String, dynamic>>(key);

    if (storedJson == null && dhikr.titleArabic.contains('صلوات')) {
      storedJson = _storage.read<Map<String, dynamic>>(_legacyStorageKey);
    }

    if (storedJson != null) {
      return ChellehModel.fromJson(storedJson);
    }

    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return ChellehModel(
      id: 'chelleh_${dhikr.id}',
      dhikrId: dhikr.id,
      title: 'أربعينية ${dhikr.titleArabic}',
      bodyArabic: dhikr.bodyArabic,
      targetCountPerDay: dhikr.repetitionCount > 0 ? dhikr.repetitionCount : 100,
      startDate: now,
      lastActiveDateString: todayStr,
    );
  }

  Future<void> _saveCurrentChelleh() async {
    final current = chelleh.value;
    final dhikrId = current.dhikrId ?? activeDhikr.value?.id;
    if (dhikrId != null) {
      await _storage.write(_dhikrStorageKey(dhikrId), current.toJson());
      // ذخیره در کلید قدیمی برای هماهنگی کامل
      if (current.title.contains('صلوات')) {
        await _storage.write(_legacyStorageKey, current.toJson());
      }
    }
  }

  /// افزایش شمارنده ورد روزانه با فیدبک لمسی
  void incrementSalawat() {
    HapticFeedback.selectionClick();
    final model = chelleh.value;
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final activeDay = model.activeDayNumber;
    final isAlreadyCompletedToday = model.isTodayCompleted;

    if (isAlreadyCompletedToday) {
      chelleh.value = model.copyWith(
        currentDayCount: model.currentDayCount + 1,
      );
      _saveCurrentChelleh();
      return;
    }

    final newCount = model.currentDayCount + 1;
    final updatedCompleted = List<int>.from(model.completedDays);

    final bool justCompleted =
        newCount >= model.targetCountPerDay && !updatedCompleted.contains(activeDay);

    if (justCompleted) {
      updatedCompleted.add(activeDay);
      HapticFeedback.heavyImpact();
    }

    chelleh.value = model.copyWith(
      currentDayCount: newCount,
      completedDays: updatedCompleted,
      lastActiveDateString: todayStr,
    );
    _saveCurrentChelleh();

    if (justCompleted) {
      _showCompletionDialog(activeDay);
    }
  }

  /// بازنشانی شمارنده روز جاری
  void resetTodayCount() {
    HapticFeedback.mediumImpact();
    chelleh.value = chelleh.value.copyWith(currentDayCount: 0);
    _saveCurrentChelleh();
  }

  /// علامت‌گذاری دستی تکمیل یک روز مشخص
  void toggleDayCompletion(int dayNumber) {
    final model = chelleh.value;

    if (model.isDayLocked(dayNumber)) {
      HapticFeedback.mediumImpact();
      final targetDate = model.dateForDay(dayNumber);
      final formattedDate =
          '${targetDate.year}/${targetDate.month.toString().padLeft(2, '0')}/${targetDate.day.toString().padLeft(2, '0')}';
      _showLockedDaySnackbar(dayNumber, formattedDate);
      return;
    }

    if (model.completedDays.contains(dayNumber)) {
      HapticFeedback.selectionClick();
      _showAlreadyCompletedSnackbar(dayNumber);
      return;
    }

    HapticFeedback.lightImpact();
    final updated = List<int>.from(model.completedDays);
    updated.add(dayNumber);
    if (updated.length == model.totalDays) {
      HapticFeedback.heavyImpact();
      _showOverallCelebrationDialog();
    }
    chelleh.value = model.copyWith(completedDays: updated);
    _saveCurrentChelleh();
  }

  void _showAlreadyCompletedSnackbar(int dayNumber) {
    final context = Get.context;
    if (context != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'اليوم $dayNumber منجز بالفعل، تقبل الله طاعتكم 🌸',
            style: const TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.white),
          ),
          backgroundColor: Colors.teal.shade800,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showLockedDaySnackbar(int dayNumber, String dateStr) {
    final context = Get.context;
    if (context != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'اليوم $dayNumber مقفل حالياً. سيتوفر هذا اليوم بتاريخ $dateStr.',
            style: const TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.white),
          ),
          backgroundColor: Colors.blueGrey.shade800,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  /// به‌روزرسانی نیت
  void updateNiyyah(String newNiyyah) {
    chelleh.value = chelleh.value.copyWith(niyyah: newNiyyah);
    _saveCurrentChelleh();
  }

  /// به‌روزرسانی هدف روزانه
  void updateTargetCount(int target) {
    chelleh.value = chelleh.value.copyWith(targetCountPerDay: target);
    _saveCurrentChelleh();
  }

  /// به‌روزرسانی یادآور
  void updateReminderSettings({
    required bool isEnabled,
    required int hour,
    required int minute,
  }) {
    chelleh.value = chelleh.value.copyWith(
      isReminderEnabled: isEnabled,
      reminderHour: hour,
      reminderMinute: minute,
    );
    _saveCurrentChelleh();
    _syncReminder();
  }

  void _syncReminder() {
    if (chelleh.value.isReminderEnabled) {
      ChellehReminderService.scheduleDailyReminder(
        hour: chelleh.value.reminderHour,
        minute: chelleh.value.reminderMinute,
        activeDay: chelleh.value.activeDayNumber,
      );
    } else {
      ChellehReminderService.cancelReminder();
    }
  }

  /// شروع مجدد چله ۴۰ روزه از روز اول
  /// آیا نیاز به نمایش دیالوگ روزهای رد شده وجود دارد؟
  bool get shouldShowMissedDaysDialog {
    if (!isLoaded.value) return false;
    final model = chelleh.value;
    if (!model.hasMissedDays) return false;
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return model.lastMissedPromptDismissedDate != todayStr;
  }

  /// بررسی و نمایش خودکار دیالوگ در صورت فوت شدن روزی از چله
  void checkAndPromptMissedDays(BuildContext context) {
    if (shouldShowMissedDaysDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && shouldShowMissedDaysDialog) {
          _showMissedDaysDialog(context);
        }
      });
    }
  }

  /// دیالوگ انقطاع و رد شدن روز چله
  void _showMissedDaysDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final model = chelleh.value;
    final missedDaysStr = model.missedDays.map((d) => 'اليوم $d').join('، ');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          backgroundColor: theme.colorScheme.surface,
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(isDark ? 40 : 30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.history_toggle_off_rounded,
                  color: Colors.amber,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'انقطاع في مسار العهد',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ورد الأيام السابقة ($missedDaysStr) لم يتم تثبيته.',
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'من سنّة الأربعينيات والعهود استدامة الذكر يومياً دون انقطاع. هل ترغب في إعادة بدء العهد من اليوم الأول، أم متابعة العهد الحالي؟',
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 13.5,
                  height: 1.6,
                  color: theme.colorScheme.onSurface.withAlpha(210),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          actions: [
            // گزینه ۱: شروع چله از اول
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                restartChellehFromDayOne();
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text(
                'البدء مجددًا',
                style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.amber.shade800,
                side: BorderSide(color: Colors.amber.shade700, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
            // گزینه ۲: ادامه همون ذکر
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                continueCurrentChelleh();
              },
              icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
              label: const Text(
                'متابعة العهد',
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        );
      },
    );
  }

  /// شروع مجدد چله از روز اول
  void restartChellehFromDayOne() {
    HapticFeedback.mediumImpact();
    final current = chelleh.value;
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    chelleh.value = current.copyWith(
      startDate: now,
      completedDays: [],
      currentDayCount: 0,
      lastActiveDateString: todayStr,
      lastMissedPromptDismissedDate: todayStr,
    );
    _saveCurrentChelleh();
    _syncReminder();

    final context = Get.context;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'تمت إعادة بدء العهد المبارك من اليوم الأول، أسأل الله لكم التوفيق والقبول 🌿',
            style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.white),
          ),
          backgroundColor: Colors.teal.shade800,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  /// ادامه دادن چله بدون بازنشانی
  void continueCurrentChelleh() {
    HapticFeedback.lightImpact();
    final current = chelleh.value;
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    chelleh.value = current.copyWith(
      lastMissedPromptDismissedDate: todayStr,
    );
    _saveCurrentChelleh();

    final context = Get.context;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'تستمر في عهدك الحالي، تقبل الله صالح أعمالكم 🌸',
            style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.white),
          ),
          backgroundColor: Colors.blueGrey.shade800,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  /// ایجاد یک چله جدید با ذکر، تعداد روز، نیت و هدف دلخواه
  void createNewChelleh({
    required ArbaeenDhikrModel dhikr,
    required int totalDays,
    required int targetCountPerDay,
    required String niyyah,
    required bool isReminderEnabled,
    required int reminderHour,
    required int reminderMinute,
  }) {
    HapticFeedback.mediumImpact();
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    activeDhikr.value = dhikr;
    _storage.write(_lastActiveDhikrKey, dhikr.id);

    final newModel = ChellehModel(
      id: 'chelleh_${dhikr.id}_${now.millisecondsSinceEpoch}',
      dhikrId: dhikr.id,
      title: dhikr.isDuaOrSurah ? dhikr.titleArabic : 'أربعينية ${dhikr.titleArabic}',
      bodyArabic: dhikr.bodyArabic,
      niyyah: niyyah.trim().isNotEmpty
          ? niyyah.trim()
          : 'تعجيل في فرج مولانا صاحب الزمان (عج)',
      totalDays: totalDays > 0 ? totalDays : 40,
      isDhikr: dhikr.isDhikr,
      targetCountPerDay: dhikr.isDuaOrSurah
          ? 1
          : (targetCountPerDay > 0 ? targetCountPerDay : 100),
      currentDayCount: 0,
      startDate: now,
      completedDays: [],
      isReminderEnabled: isReminderEnabled,
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
      lastActiveDateString: todayStr,
      lastMissedPromptDismissedDate: todayStr,
    );

    chelleh.value = newModel;
    _saveCurrentChelleh();
    _syncReminder();
  }

  /// تأیید یا انصراف از قرائت روزانه برای سوره یا دعا
  void toggleTodayReadingCompletion() {
    final model = chelleh.value;
    final activeDay = model.activeDayNumber;
    final updated = List<int>.from(model.completedDays);
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    if (updated.contains(activeDay)) {
      updated.remove(activeDay);
      HapticFeedback.selectionClick();
      chelleh.value = model.copyWith(
        completedDays: updated,
        currentDayCount: 0,
        lastActiveDateString: todayStr,
      );
      _saveCurrentChelleh();
    } else {
      updated.add(activeDay);
      HapticFeedback.heavyImpact();
      chelleh.value = model.copyWith(
        completedDays: updated,
        currentDayCount: 1,
        lastActiveDateString: todayStr,
      );
      _saveCurrentChelleh();
      _showCompletionDialog(activeDay);
    }
  }

  /// شروع مجدد چله از روز اول (عمومی)
  void restartChelleh({String? newNiyyah, int? newTarget}) {
    final current = chelleh.value;
    final dhikr = activeDhikr.value;
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    chelleh.value = ChellehModel(
      id: 'chelleh_${dhikr?.id ?? now.millisecondsSinceEpoch}',
      dhikrId: dhikr?.id,
      title: dhikr != null
          ? (dhikr.isDuaOrSurah ? dhikr.titleArabic : 'أربعينية ${dhikr.titleArabic}')
          : current.title,
      bodyArabic: dhikr?.bodyArabic ?? current.bodyArabic,
      niyyah: newNiyyah ?? current.niyyah,
      totalDays: current.totalDays,
      isDhikr: dhikr?.isDhikr ?? current.isDhikr,
      targetCountPerDay: newTarget ?? current.targetCountPerDay,
      currentDayCount: 0,
      startDate: now,
      completedDays: [],
      isReminderEnabled: current.isReminderEnabled,
      reminderHour: current.reminderHour,
      reminderMinute: current.reminderMinute,
      lastActiveDateString: todayStr,
      lastMissedPromptDismissedDate: todayStr,
    );
    _saveCurrentChelleh();
    _syncReminder();
  }

  void _showCompletionDialog(int dayNumber) {
    final context = Get.context;
    if (context == null) return;
    final title = activeDhikr.value?.titleArabic ?? 'الورد المبارك';
    final bodyText = activeDhikr.value?.bodyArabic;
    final totalDays = chelleh.value.totalDays;

    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: theme.colorScheme.surface,
          title: const Text(
            'تقبل الله طاعتكم 🌸',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (bodyText != null && bodyText.isNotEmpty)
                Text(
                  bodyText.length > 80 ? '${bodyText.substring(0, 75)}...' : bodyText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 15,
                    color: Colors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                'أتممت بنجاح ورد اليوم ($dayNumber من $totalDays) من عهد $title المبارك.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withAlpha(200),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              child: const Text(
                'الحمد لله',
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showOverallCelebrationDialog() {
    final context = Get.context;
    if (context == null) return;
    final title = activeDhikr.value?.titleArabic ?? 'العهد المبارك';
    final totalDays = chelleh.value.totalDays;

    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: theme.colorScheme.surface,
          title: const Text(
            'مبارك إتمام العهد المبارك! 🎉',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          content: Text(
            'بحمد الله وتوفيقه، أتممت عهد $title المبارك بنجاح واستمرار طيلة $totalDays يوماً. نسأل الله أن يتقبل عملكم ويقضي حوائجكم.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 14,
              color: theme.colorScheme.onSurface.withAlpha(200),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'تقبل الله',
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

