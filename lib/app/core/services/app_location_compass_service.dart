import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mawsueat/app/features/qibla/services/qibla_math_service.dart';
import 'package:permission_handler/permission_handler.dart' hide ServiceStatus;

/// سرویس جامع و پایدار مدیریت موقعیت مکانی (GPS) و قطب‌نما در سراسر اپلیکیشن
/// این سرویس دقیقاً از منطق اعتبارسنجی قبله‌نما استفاده کرده و اطلاعات را بین
/// قبله‌نما، زیارت از راه دور، و اوقات شرعی به اشتراک می‌گذارد.
class AppLocationCompassService extends GetxService {
  static AppLocationCompassService get to {
    if (!Get.isRegistered<AppLocationCompassService>()) {
      return Get.put(AppLocationCompassService(), permanent: true);
    }
    return Get.find<AppLocationCompassService>();
  }

  final GetStorage _storage = GetStorage();

  // کلیدهای ذخیره‌سازی محلی برای دسترسی فوری بدون معطلی ماهواره
  static const String _kLatKey = 'user_cached_latitude';
  static const String _kLngKey = 'user_cached_longitude';
  static const String _kCityKey = 'user_cached_city_name';

  // موقعیت مکانی کاربر
  final Rxn<Position> currentPosition = Rxn<Position>();
  final RxBool hasLocationPermission = false.obs;
  final RxBool isGpsServiceEnabled = false.obs;
  final RxBool isLocationLoading = false.obs;
  final RxString locationCityName = ''.obs;

  // سنسور قطب‌نما
  final RxBool isCompassAvailable = false.obs;
  final RxDouble currentHeading = 0.0.obs; // زاویه فعلی (0 تا 360)
  final RxDouble smoothedHeading = 0.0.obs; // زاویه بعد از فیلتر بدون لرزش
  final RxDouble accuracy = 0.0.obs;

  StreamSubscription<CompassEvent>? _compassSub;
  StreamSubscription<ServiceStatus>? _gpsServiceStatusSub;
  StreamSubscription<Position>? _positionStreamSub;

  @override
  void onInit() {
    super.onInit();
    _loadCachedLocation();
    _initCompass();
    _initLocation();
  }

  @override
  void onClose() {
    _compassSub?.cancel();
    _gpsServiceStatusSub?.cancel();
    _positionStreamSub?.cancel();
    super.onClose();
  }

  /// ۱. بارگذاری فوری موقعیت ذخیره‌شده از کش جهت جلوگیری از خطای فاصله و زاویه در فریم اول
  void _loadCachedLocation() {
    try {
      // بررسی موقعیت ذخیره‌شده در prayer_settings یا کلیدهای اختصاصی
      double? lat = _storage.read<double>(_kLatKey);
      double? lng = _storage.read<double>(_kLngKey);
      String? city = _storage.read<String>(_kCityKey);

      if (lat == null || lng == null) {
        final prayerSettings = _storage.read<Map<String, dynamic>>(
          'prayer_settings',
        );
        if (prayerSettings != null) {
          lat = (prayerSettings['latitude'] as num?)?.toDouble();
          lng = (prayerSettings['longitude'] as num?)?.toDouble();
          city ??= prayerSettings['cityName'] as String?;
        }
      }

      if (lat != null && lng != null) {
        currentPosition.value = Position(
          latitude: lat,
          longitude: lng,
          timestamp: DateTime.now(),
          accuracy: 50.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
        if (city != null) locationCityName.value = city;
        hasLocationPermission.value = true;
      }
    } catch (e) {
      debugPrint('Error reading cached location: $e');
    }
  }

  /// ۲. راه‌اندازی و شنود پیوسته سنسور قطب‌نما با نرم‌سازی زاویه
  void _initCompass() {
    try {
      if (FlutterCompass.events != null) {
        isCompassAvailable.value = true;
        _compassSub?.cancel();
        _compassSub = FlutterCompass.events!.listen((CompassEvent event) {
          if (event.heading == null) return;

          // نرمال‌سازی دقیق به بازه [0, 360)
          final double rawHeading = event.heading!;
          final double normalized = (rawHeading % 360.0 + 360.0) % 360.0;

          accuracy.value = event.accuracy ?? 0.0;
          currentHeading.value = normalized;

          final double lastSmoothed = smoothedHeading.value;

          // فیلتر آستانه تغییرات ریز (تغییرات کمتر از ۰.۸ درجه نادیده گرفته می‌شوند تا لرزش دست باعث حواس‌پرتی نشود)
          if (lastSmoothed != 0) {
            double delta = (normalized - lastSmoothed).abs();
            if (delta > 180) delta = 360 - delta;
            if (delta < 0.8) return;
          }

          // فیلتر مدور نرم‌سازی برای حذف تکان‌های دست (Low-pass Circular Smoothing)
          smoothedHeading.value = QiblaMathService.smoothAngle(
            lastSmoothed == 0 ? normalized : lastSmoothed,
            normalized,
            factor: 0.20,
          );
        });
      } else {
        isCompassAvailable.value = false;
      }
    } catch (e) {
      debugPrint('Error initializing compass: $e');
      isCompassAvailable.value = false;
    }
  }

  /// ۳. راه‌اندازی بررسی وضعیت GPS و دریافت لوکیشن با منطق استاندارد Qibla
  Future<void> _initLocation() async {
    isLocationLoading.value = true;

    try {
      // بررسی وضعیت سخت‌افزار GPS
      final gpsEnabled = await Geolocator.isLocationServiceEnabled();
      isGpsServiceEnabled.value = gpsEnabled;
      _listenToGpsServiceStatus();

      // بررسی دسترسی
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        // در شروع اپ بدون اجبار فقط وضعیت را نگه می‌داریم تا در صورت نیاز کاربر درخواست شود
        hasLocationPermission.value = false;
      } else if (perm == LocationPermission.deniedForever) {
        hasLocationPermission.value = false;
      } else {
        hasLocationPermission.value = true;
        await refreshLocation();
      }
    } catch (e) {
      debugPrint('Error in _initLocation: $e');
    } finally {
      isLocationLoading.value = false;
    }
  }

  /// گوش دادن به روشن/خاموش شدن GPS در کنترل‌سنتر گوشی
  void _listenToGpsServiceStatus() {
    _gpsServiceStatusSub?.cancel();
    _gpsServiceStatusSub = Geolocator.getServiceStatusStream().listen((status) {
      final isEnabled = status == ServiceStatus.enabled;
      isGpsServiceEnabled.value = isEnabled;
      if (isEnabled) {
        refreshLocation();
      }
    });
  }

  /// درخواست فعال‌سازی دسترسی لوکیشن توسط کاربر
  Future<bool> requestLocationPermission() async {
    try {
      // ابتدا بررسی وضعیت GPS
      final gpsEnabled = await Geolocator.isLocationServiceEnabled();
      isGpsServiceEnabled.value = gpsEnabled;

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      if (perm == LocationPermission.deniedForever) {
        hasLocationPermission.value = false;
        await openAppSettings();
        return false;
      }

      if (perm == LocationPermission.whileInUse ||
          perm == LocationPermission.always) {
        hasLocationPermission.value = true;
        if (!gpsEnabled) {
          // اگر دسترسی هست اما GPS خاموش است، تنظیمات GPS را باز می‌کنیم
          await Geolocator.openLocationSettings();
        }
        await refreshLocation();
        return true;
      }

      hasLocationPermission.value = false;
      return false;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return false;
    }
  }

  /// به‌روزرسانی لوکیشن از حافظه موقت و سپس از ماهواره‌های GPS
  Future<void> refreshLocation() async {
    isLocationLoading.value = true;

    try {
      final gpsEnabled = await Geolocator.isLocationServiceEnabled();
      isGpsServiceEnabled.value = gpsEnabled;

      // دریافت آخرین موقعیت ثبت‌شده در حافظه دستگاه (فوری و بدون مصرف باتری)
      Position? pos;
      try {
        pos = await Geolocator.getLastKnownPosition();
        if (pos != null) {
          _updateAndCachePosition(pos);
        }
      } catch (_) {}

      // دریافت موقعیت زنده جدید با زمان‌بندی معقول (۱۰ ثانیه)
      if (gpsEnabled) {
        try {
          pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 10),
            ),
          );
          _updateAndCachePosition(pos);
        } catch (e) {
          debugPrint('getCurrentPosition error/timeout: $e');
        }
      }

      // شنود تغییرات موقعیت کاربر در صورت جابجایی
      _startPositionStream();
    } catch (e) {
      debugPrint('Error in refreshLocation: $e');
    } finally {
      isLocationLoading.value = false;
    }
  }

  void _updateAndCachePosition(Position pos) {
    currentPosition.value = pos;
    hasLocationPermission.value = true;

    // ذخیره در کش دائمی
    try {
      _storage.write(_kLatKey, pos.latitude);
      _storage.write(_kLngKey, pos.longitude);
    } catch (_) {}
  }

  void _startPositionStream() {
    _positionStreamSub?.cancel();
    _positionStreamSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            distanceFilter:
                50, // فقط هر ۵۰ متر به‌روز شود تا مصرف باتری بهینه باشد
          ),
        ).listen((pos) {
          _updateAndCachePosition(pos);
        });
  }

  /// باز کردن تنظیمات GPS دستگاه
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}
