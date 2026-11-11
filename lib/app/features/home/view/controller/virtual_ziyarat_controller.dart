import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/services/app_location_compass_service.dart';
import 'package:mawsueat/app/features/home/data/models/virtual_ziyarat_model.dart';
import 'package:mawsueat/app/features/home/data/repositories/remote_ziyarah_repository.dart';
import 'package:mawsueat/app/features/qibla/services/qibla_math_service.dart';
import 'package:url_launcher/url_launcher.dart';

enum ShrineTurnDirection { facing, turnRight, turnLeft, turnAround, unknown }

class VirtualZiyaratController extends GetxController {
  // سرویس مرکزی موقعیت و سنسور قبله و حرم
  final AppLocationCompassService locationService =
      AppLocationCompassService.to;
  final RemoteZiyarahRepository _repository = RemoteZiyarahRepository();

  // زیارتگاه‌های پیش‌فرض با مختصات دقیق برای حالت آفلاین
  static const List<VirtualZiyaratModel> defaultShrines = [
    VirtualZiyaratModel(
      id: 'rzi_loc_madinah',
      slug: 'madenyh',
      nameArabic: 'المدينة المنورة',
      shrineNameArabic: 'المسجد النبوي الشريف',
      descriptionArabic: 'المسجد النبوي المبارك والروضة الشريفة',
      latitude: 24.4672,
      longitude: 39.6111,
      liveUrl: 'https://haramain.prh.gov.sa/ar/live',
      readings: [
        RemoteZiyarahReadingModel(
          id: 'read_madinah_1',
          locationId: 'rzi_loc_madinah',
          titleArabic: 'زيارة النبي الأكرم (ص)',
          bodyArabic:
              '''السَّلامُ عَلَيْكَ يا نَبِيَّ اللهِ، السَّلامُ عَلَيْكَ يا مُحَمَّدَ بْنَ عَبْدِ اللهِ، السَّلامُ عَلَيْكَ يا خاتَمَ النَّبِيِّينَ.

أَشْهَدُ أَنَّكَ قَدْ بَلَّغْتَ الرِّسالَةَ، وَأَقَمْتَ الصَّلاةَ، وَآتَيْتَ الزَّكاةَ، وَأَمَرْتَ بِالْمَعْرُوفِ، وَنَهَيْتَ عَنِ الْمُنْكَرِ، وَعَبَدْتَ اللهَ مُخْلِصاً حَتّى أَتاكَ الْيَقِينُ، فَصَلَواتُ اللهِ عَلَيْكَ وَرَحْمَتُهُ وَعَلى أَهْلِ بَيْتِكَ الطَّاهِرِينَ.''',
        ),
      ],
    ),
    VirtualZiyaratModel(
      id: 'imam_reza',
      slug: 'mashhad',
      nameArabic: 'مشهد المقدسة',
      shrineNameArabic: 'الروضة الرضوية المقدسة',
      descriptionArabic: 'حرم الإمام علي بن موسى الرضا (ع)',
      liveUrl: 'https://heyatonline.ir/embed/razavi',
      latitude: 36.2878,
      longitude: 59.6158,
      readings: [
        RemoteZiyarahReadingModel(
          id: 'read_reza_1',
          locationId: 'imam_reza',
          titleArabic: 'زيارة الإمام علي بن موسى الرضا (ع)',
          bodyArabic:
              '''اللَّهُمَّ صَلِّ عَلَى عَلِيِّ بْنِ مُوسَى الرِّضَا الْمُرْتَضَى، الإِمَامِ التَّقِيِّ النَّقِيِّ، وَحُجَّتِكَ عَلَى مَنْ فَوْقَ الأَرْضِ وَمَنْ تَحْتَ الثَّرَى، الصِّدِّيقِ الشَّهِيدِ، صَلاَةً كَثِيرَةً تَامَّةً زَاكِيَةً مُتَوَاصِلَةً مُتَوَاتِرَةً مُتَرَادِفَةً، كَأَفْضَلِ مَا صَلَّيْتَ عَلَى أَحَدٍ مِنْ أَوْلِيَائِكَ.

السَّلاَمُ عَلَيْكَ يَا وَلِيَّ اللَّهِ وَابْنَ وَلِيِّهِ، السَّلاَمُ عَلَيْكَ يَا حُجَّةَ اللَّهِ وَابْنَ حُجَّتِهِ، السَّلاَمُ عَلَيْكَ يَا إِمَامَ الْهُدَى وَالْعُرْوَةَ الْوُثْقَى، السَّلاَمُ عَلَيْكَ يَا غَرِيبَ الْغُرَبَاءِ، وَيَا مُعِينَ الضُّعَفَاءِ وَالْفُقَرَاءِ، السَّلاَمُ عَلَيْكَ أَيُّهَا الرَّءُوفُ بِالْعِبَادِ، وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ.''',
        ),
      ],
    ),
    VirtualZiyaratModel(
      id: 'karbala',
      slug: 'karbala',
      nameArabic: 'كربلاء المقدسة',
      shrineNameArabic: 'العتبة الحسينية المقدسة',
      descriptionArabic: 'حرم الإمام الحسين وأبي الفضل العباس (عليهما السلام)',
      liveUrl: 'https://heyatonline.ir/embed/karbala',
      latitude: 32.6164,
      longitude: 44.0324,
      readings: [
        RemoteZiyarahReadingModel(
          id: 'read_karbala_1',
          locationId: 'karbala',
          titleArabic: 'زيارة وارث للإمام الحسين (ع)',
          bodyArabic:
              '''السَّلاَمُ عَلَيْكَ يَا وَارِثَ آدَمَ صَفْوَةِ اللَّهِ، السَّلاَمُ عَلَيْكَ يَا وَارِثَ نُوحٍ نَبِيِّ اللَّهِ، السَّلاَمُ عَلَيْكَ يَا وَارِثَ إِبْرَاهِيمَ خَلِيلِ اللَّهِ، السَّلاَمُ عَلَيْكَ يَا وَارِثَ مُوسَى كَلِيمِ اللَّهِ، السَّلاَمُ عَلَيْكَ يَا وَارِثَ عِيسَى رُوحِ اللَّهِ، السَّلاَمُ عَلَيْكَ يَا وَارِثَ مُحَمَّدٍ حَبِيبِ اللَّهِ.

السَّلاَمُ عَلَيْكَ يَا أَبَا عَبْدِ اللَّهِ، السَّلاَمُ عَلَيْكَ يَا ابْنَ رَسُولِ اللَّهِ، السَّلاَمُ عَلَيْكَ وَعَلَى الأَرْوَاحِ الَّتِي حَلَّتْ بِفِنَائِكَ، عَلَيْكُمْ مِنِّي سَلاَمُ اللَّهِ أَبَداً مَا بَقِيتُ وَبَقِيَ اللَّيْلُ وَالنَّهَارُ، وَلاَ جَعَلَهُ اللَّهُ آخِرَ الْعَهْدِ مِنِّي لِزِيَارَتِكُمْ.''',
        ),
      ],
    ),
    VirtualZiyaratModel(
      id: 'najaf',
      slug: 'najaf',
      nameArabic: 'النجف الأشرف',
      shrineNameArabic: 'العتبة العلوية المقدسة',
      descriptionArabic: 'حرم أمير المؤمنين علي بن أبي طالب (عليه السلام)',
      liveUrl: 'https://heyatonline.ir/embed/imamali',
      latitude: 31.9961,
      longitude: 44.3142,
      readings: [
        RemoteZiyarahReadingModel(
          id: 'read_najaf_1',
          locationId: 'najaf',
          titleArabic: 'زيارة أمين الله لأمير المؤمنين (ع)',
          bodyArabic:
              '''السَّلامُ عَلَيْكَ يَا أَمِينَ اللهِ فِي أَرْضِهِ، وَحُجَّتَهُ عَلَى عِبَادِهِ، السَّلامُ عَلَيْكَ يَا أَمِيرَ الْمُؤْمِنِينَ، أَشْهَدُ أَنَّكَ جَاهَدْتَ فِي اللهِ حَقَّ جِهَادِهِ، وَعَمِلْتَ بِكِتَابِهِ، وَاتَّبَعْتَ سُنَنَ نَبِيِّهِ صَلَّى اللهُ عَلَيْهِ وَآلِهِ، حَتَّى دَعَاكَ اللهُ إِلَى جِوَارِهِ.

اللَّهُمَّ فَاجْعَلْ نَفْسِي مُطْمَئِنَّةً بِقَدَرِكَ، رَاضِيَةً بِقَضَائِكَ، مُولَعَةً بِذِكْرِكَ وَدُعَائِكَ، مُحِبَّةً لِصَفْوَةِ أَوْلِيَائِكَ، مَحْبُوبَةً فِي أَرْضِكَ وَسَمَائِكَ، صَابِرَةً عَلَى نُزُولِ بَلائِكَ، شَاكِرَةً لِفَوَاضِلِ نَعْمَائِكَ.''',
        ),
      ],
    ),
  ];

  // متغیرهای انتخابی و وضعیت
  final shrines = <VirtualZiyaratModel>[].obs;
  late final Rx<VirtualZiyaratModel> currentShrine;
  final selectedReadingIndex = 0.obs;
  final isLoadingLocations = false.obs;
  final isLoadingReadings = false.obs;

  RemoteZiyarahReadingModel? get currentReading {
    final list = currentShrine.value.readings;
    if (list.isEmpty) return null;
    if (selectedReadingIndex.value < list.length) {
      return list[selectedReadingIndex.value];
    }
    return list.first;
  }

  void selectReading(int index) {
    selectedReadingIndex.value = index;
  }

  final isStreamActive = false.obs;
  final isStreamLoading = false.obs;
  final streamHasError = false.obs;
  final isTextExpanded = false.obs;
  InAppWebViewController? webViewController;

  // محاسبات ژئودتیک حرم
  final distanceKm = 0.0.obs;
  final shrineBearing = 0.0.obs;
  final angleDiffDegrees = 0.0.obs;
  final displayedDegrees = 0.obs;
  final isFacingShrine = false.obs;
  final turnDirection = ShrineTurnDirection.unknown.obs;

  // حاشیه امن تراز (Safe Margin / Alignment Tolerance with Hysteresis)
  static const double alignmentEnterThreshold = 14.0;
  static const double alignmentExitThreshold = 18.0;

  Worker? _posWorker;
  Worker? _headingWorker;
  bool _hasVibratedForAlignment = false;

  @override
  void onInit() {
    super.onInit();
    // مقداردهی اولیه با بارگاه‌های پیش‌فرض
    shrines.assignAll(defaultShrines);
    final initialShrine = _determineAutomaticShrine();
    currentShrine = initialShrine.obs;

    _recalculateBearingAndDistance();

    // همگام‌سازی لحظه‌ای با تغییرات موقعیت و زاویه چرخش در AppLocationCompassService
    _posWorker = ever(locationService.currentPosition, (_) {
      _recalculateBearingAndDistance();
    });

    _headingWorker = ever(locationService.smoothedHeading, (_) {
      _updateAngleDifference();
    });

    // بارگذاری بارگاه‌ها از سرور دجله
    fetchRemoteLocations();
  }

  /// دریافت لیست مکان‌های زیارت از سرور
  Future<void> fetchRemoteLocations() async {
    isLoadingLocations.value = true;
    try {
      final remoteLocations = await _repository.getLocations();
      if (remoteLocations.isNotEmpty) {
        // تلفیق یا جایگزینی با داده‌های سرور
        shrines.assignAll(remoteLocations);

        // به‌روزرسانی بارگاه انتخابی فعلی در صورت وجود در لیست سرور
        final matching = remoteLocations.firstWhereOrNull(
          (loc) =>
              loc.id == currentShrine.value.id ||
              loc.slug == currentShrine.value.slug,
        );

        if (matching != null) {
          currentShrine.value = matching;
        } else {
          currentShrine.value = remoteLocations.first;
        }

        _recalculateBearingAndDistance();

        // دریافت متون قرائت‌ها برای بارگاه انتخاب شده
        if (currentShrine.value.readings.isEmpty) {
          loadShrineDetails(currentShrine.value.id);
        }
      }
    } catch (e) {
      debugPrint('Error loading remote ziyarah locations: $e');
    } finally {
      isLoadingLocations.value = false;
    }
  }

  /// دریافت جزئیات و متن‌های قرائت زیارت برای یک مکان خاص
  Future<void> loadShrineDetails(String locationId) async {
    isLoadingReadings.value = true;
    try {
      final detailed = await _repository.getLocationDetail(locationId);
      if (detailed != null) {
        final index = shrines.indexWhere((element) => element.id == locationId);
        if (index != -1) {
          shrines[index] = detailed;
        }
        if (currentShrine.value.id == locationId) {
          currentShrine.value = detailed;
        }
      } else {
        // Fallback: try getting readings directly
        final readings = await _repository.getLocationReadings(locationId);
        if (readings.isNotEmpty) {
          final index = shrines.indexWhere(
            (element) => element.id == locationId,
          );
          if (index != -1) {
            final updated = shrines[index].copyWith(readings: readings);
            shrines[index] = updated;
            if (currentShrine.value.id == locationId) {
              currentShrine.value = updated;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading shrine details for $locationId: $e');
    } finally {
      isLoadingReadings.value = false;
    }
  }

  @override
  void onClose() {
    _posWorker?.dispose();
    _headingWorker?.dispose();
    super.onClose();
  }

  /// تعیین اتوماتیک زیارتگاه بر اساس روز جاری
  VirtualZiyaratModel _determineAutomaticShrine() {
    final list = shrines.isNotEmpty ? shrines : defaultShrines;
    final weekday = DateTime.now().weekday;

    // ترجیحاً بر اساس slug یا id روز را تطبیق می‌دهیم
    if (weekday == DateTime.saturday) {
      final madinah = list.firstWhereOrNull(
        (s) => s.slug == 'madenyh' || s.id.contains('madinah'),
      );
      if (madinah != null) return madinah;
    } else if (weekday == DateTime.wednesday) {
      final reza = list.firstWhereOrNull(
        (s) => s.slug == 'mashhad' || s.id.contains('reza'),
      );
      if (reza != null) return reza;
    } else if (weekday == DateTime.thursday || weekday == DateTime.friday) {
      final karbala = list.firstWhereOrNull(
        (s) => s.slug == 'karbala' || s.id.contains('karbala'),
      );
      if (karbala != null) return karbala;
    } else {
      final najaf = list.firstWhereOrNull(
        (s) => s.slug == 'najaf' || s.id.contains('najaf'),
      );
      if (najaf != null) return najaf;
    }
    return list.first;
  }

  /// تغییر دستی زیارتگاه در صورت تمایل کاربر
  void selectShrine(VirtualZiyaratModel shrine) {
    if (currentShrine.value.id == shrine.id) return;
    currentShrine.value = shrine;
    streamHasError.value = false;
    _hasVibratedForAlignment = false;
    _recalculateBearingAndDistance();

    if (isStreamActive.value && webViewController != null) {
      isStreamLoading.value = true;
      webViewController?.loadUrl(
        urlRequest: URLRequest(
          url: WebUri(shrine.streamUrl),
          headers: {'Referer': 'https://www.youtube.com/'},
        ),
      );
    }

    selectedReadingIndex.value = 0;
    if (shrine.readings.isEmpty) {
      loadShrineDetails(shrine.id);
    }
  }

  void toggleStream() {
    isStreamActive.value = !isStreamActive.value;
    if (isStreamActive.value) {
      isStreamLoading.value = true;
      streamHasError.value = false;
    }
  }

  void toggleTextExpansion() {
    isTextExpanded.value = !isTextExpanded.value;
  }

  void reloadStream() {
    streamHasError.value = false;
    isStreamLoading.value = true;
    if (webViewController != null) {
      webViewController?.reload();
    } else {
      isStreamActive.value = false;
      Future.delayed(const Duration(milliseconds: 100), () {
        isStreamActive.value = true;
      });
    }
  }

  Future<void> openExternalStream() async {
    final urlStr = currentShrine.value.externalUrl;
    final uri = Uri.parse(urlStr);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching external live stream: $e');
    }
  }

  /// درخواست مجدد موقعیت مکانی
  Future<void> requestLocation() async {
    await locationService.requestLocationPermission();
    _recalculateBearingAndDistance();
  }

  /// باز کردن تنظیمات GPS
  Future<void> openGpsSettings() async {
    await locationService.openLocationSettings();
  }

  /// محاسبه زاویه مستقیم به سمت حرم و فاصله بر اساس فرمول‌های ریاضی معتبر QiblaMathService
  void _recalculateBearingAndDistance() {
    final pos = locationService.currentPosition.value;
    final targetLat = currentShrine.value.latitude;
    final targetLng = currentShrine.value.longitude;

    if (pos == null) {
      // اگر هنوز لوکیشن ثبت نشده، یک زاویه تقریبی قرار داده می‌شود
      distanceKm.value = 850.0;
      shrineBearing.value = 82.0;
      _updateAngleDifference();
      return;
    }

    // ۱. محاسبه فاصله مستقیم به کیلومتر (فرمول هاورسین دقیقا مشابه قبله‌نما)
    distanceKm.value = QiblaMathService.calculateTargetDistance(
      pos.latitude,
      pos.longitude,
      targetLat,
      targetLng,
    );

    // ۲. محاسبه زاویه مستقیم ژئودتیک به سمت حرم (True Bearing)
    shrineBearing.value = QiblaMathService.calculateTargetBearing(
      pos.latitude,
      pos.longitude,
      targetLat,
      targetLng,
    );

    _updateAngleDifference();
  }

  /// به‌روزرسانی اختلاف زاویه بین سنسور گوشی و جهت حرم با حاشیه امن و فیلتر پرش
  void _updateAngleDifference() {
    final double heading = locationService.smoothedHeading.value;

    // فرمول دقیق قبله‌نما: اختلاف زاویه هدف با زاویه فعلی بین -180 تا +180
    final double diff = QiblaMathService.getAngleDifference(
      shrineBearing.value,
      heading,
    );
    angleDiffDegrees.value = diff;

    final double diffAbs = diff.abs();

    // بررسی تراز بودن با حاشیه امن هیسترزیس (Hysteresis):
    // ورود به محدوده تراز در ۱۴ درجه، و خروج تنها پس از گذشتن از ۱۸ درجه
    // این فاصله ۴ درجه‌ای مانع از پرش یا قطع و وصل شدن مداوم با تکان‌های جزئی دست می‌شود.
    if (diffAbs <= alignmentEnterThreshold && !isFacingShrine.value) {
      isFacingShrine.value = true;
      if (!_hasVibratedForAlignment) {
        _hasVibratedForAlignment = true;
        HapticFeedback.mediumImpact();
      }
    } else if (diffAbs > alignmentExitThreshold && isFacingShrine.value) {
      isFacingShrine.value = false;
      _hasVibratedForAlignment = false;
    }

    // فیلتر نوسان عدد درجه: پله‌های ۲ درجه‌ای برای جلوگیری از تغییر مدام عدد
    final int roundedDeg = (diffAbs / 2.0).round() * 2;
    if ((roundedDeg - displayedDegrees.value).abs() >= 2 ||
        displayedDegrees.value == 0) {
      displayedDegrees.value = roundedDeg;
    }

    // به‌روزرسانی جهت چرخش فقط هنگام تغییر فاز برای جلوگیری از ری‌بیلد بیهوده ویجت‌ها
    final ShrineTurnDirection newDirection;
    if (!locationService.isCompassAvailable.value) {
      newDirection = ShrineTurnDirection.unknown;
    } else if (isFacingShrine.value) {
      newDirection = ShrineTurnDirection.facing;
    } else if (diffAbs >= 135.0) {
      newDirection = ShrineTurnDirection.turnAround;
    } else if (diff > 0) {
      newDirection = ShrineTurnDirection.turnRight;
    } else {
      newDirection = ShrineTurnDirection.turnLeft;
    }

    if (turnDirection.value != newDirection) {
      turnDirection.value = newDirection;
    }
  }

  /// میزان درجه چرخش مورد نیاز (فیلتر شده و بدون پرش ۱ درجه‌ای)
  int get turnDegrees => displayedDegrees.value;

  /// زاویه چرخش عقربه نشانگر (رادیان ساعت‌گرد جهت نقاشی عقربه)
  /// در حاشیه امن تراز، عقربه رو به جلو قفل و آرام می‌ماند تا لرزش دست باعث حواس‌پرتی نشود
  double get needleRotationRadians {
    if (isFacingShrine.value) {
      return 0.0;
    }
    final diff = (shrineBearing.value - locationService.smoothedHeading.value);
    return diff * (math.pi / 180.0);
  }

  /// زاویه چرخش صفحه مدرج قطب‌نما (علامت شمال N با منفی چرخیدن نشان داده می‌شود)
  double get dialRotationRadians {
    return -locationService.smoothedHeading.value * (math.pi / 180.0);
  }
}
