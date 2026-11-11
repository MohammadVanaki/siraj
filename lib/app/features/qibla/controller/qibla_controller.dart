import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart' hide ServiceStatus;
import 'package:mawsueat/app/core/services/app_location_compass_service.dart';
import '../services/qibla_math_service.dart';

enum QiblaStatus {
  loading,
  permissionDenied,
  permissionPermanentlyDenied,
  gpsDisabled,
  sensorUnavailable,
  ready,
  error,
}

class QiblaController extends GetxController with WidgetsBindingObserver {
  // الحالة العامة
  final Rx<QiblaStatus> status = QiblaStatus.loading.obs;
  final RxString statusMessage = ''.obs;

  // نمط العرض (AR بالكاميرا أو بوصلة 2D)
  final RxBool isArMode = true.obs;

  // إحداثيات وموقع المستخدم
  final Rxn<Position> currentPosition = Rxn<Position>();
  final RxDouble qiblaBearing =
      0.0.obs; // زاوية القبلة بالنسبة للشمال (0 - 360)
  final RxDouble distanceToKaabaKm = 0.0.obs; // المسافة إلى الكعبة بالكيلومتر

  // حساس البوصلة
  final RxDouble currentHeading = 0.0.obs; // زاوية اتجاه الهاتف الحالية
  final RxDouble smoothedHeading = 0.0.obs; // الزاوية بعد التنعيم
  final RxDouble angleDiff = 0.0.obs; // الفرق: موجب (يمين)، سالب (يسار)
  final RxBool isAligned = false.obs; // هل الهاتف موجه تماماً نحو القبلة؟
  final RxDouble accuracy = 0.0.obs; // دقة السنسور

  // الكاميرا
  CameraController? cameraController;
  final RxBool isCameraInitialized = false.obs;
  List<CameraDescription> _availableCameras = [];

  // الاشتراكات والمؤقتات
  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamSubscription<ServiceStatus>? _locationServiceSubscription;
  bool _hasVibratedForAlignment = false;

  // عتبة التطابق (درجات)
  static const double alignmentThreshold = 3.5;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    initQibla();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    _compassSubscription?.cancel();
    _locationServiceSubscription?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      cameraController?.dispose();
      isCameraInitialized.value = false;
    } else if (state == AppLifecycleState.resumed && isArMode.value) {
      _initCamera();
    }
  }

  /// بدء فحص الصلاحيات وتهيئة كل الخدمات
  Future<void> initQibla() async {
    status.value = QiblaStatus.loading;
    statusMessage.value = 'جاري التحقق من الصلاحيات والاتصال بالموقع...';

    // 1. فحص سنسور البوصلة
    final compassStream = FlutterCompass.events;
    if (compassStream == null) {
      status.value = QiblaStatus.sensorUnavailable;
      statusMessage.value =
          'جهازك لا يحتوي على حساس البوصلة المغناطيسية (Magnetometer).';
      return;
    }

    // 2. فحص صلاحيات الموقع
    final locationPermission = await Permission.locationWhenInUse.status;
    if (locationPermission.isPermanentlyDenied) {
      status.value = QiblaStatus.permissionPermanentlyDenied;
      statusMessage.value =
          'يرجى تفعيل إذن الموقع الجغرافي من إعدادات الهاتف لتحديد القبلة.';
      return;
    }

    if (!locationPermission.isGranted) {
      final reqResult = await Permission.locationWhenInUse.request();
      if (reqResult.isPermanentlyDenied) {
        status.value = QiblaStatus.permissionPermanentlyDenied;
        statusMessage.value =
            'يرجى تفعيل إذن الموقع الجغرافي من إعدادات الهاتف لتحديد القبلة.';
        return;
      }
      if (!reqResult.isGranted) {
        status.value = QiblaStatus.permissionDenied;
        statusMessage.value =
            'يتطلب تحديد القبلة إذن الوصول إلى الموقع الجغرافي.';
        return;
      }
    }

    // 3. فحص تفعيل خدمة الـ GPS
    final isGpsEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isGpsEnabled) {
      status.value = QiblaStatus.gpsDisabled;
      statusMessage.value = 'يرجى تشغيل خدمة تحديد الموقع (GPS) في هاتفك.';
      _listenToLocationServiceStatus();
      return;
    }

    // 4. الحصول على الموقع الجغرافي
    try {
      Position? pos;
      // بررسی لوکیشن موجود در سرویس مرکزی اپلیکیشن
      if (Get.isRegistered<AppLocationCompassService>()) {
        pos = AppLocationCompassService.to.currentPosition.value;
      }

      if (pos == null) {
        try {
          pos = await Geolocator.getLastKnownPosition();
        } catch (_) {}
      }

      pos ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      currentPosition.value = pos;
      if (Get.isRegistered<AppLocationCompassService>()) {
        AppLocationCompassService.to.currentPosition.value = pos;
      }
      qiblaBearing.value = QiblaMathService.calculateQiblaBearing(
        pos.latitude,
        pos.longitude,
      );
      distanceToKaabaKm.value = QiblaMathService.calculateDistanceToKaaba(
        pos.latitude,
        pos.longitude,
      );
    } catch (e) {
      // إذا فشل الحصول على الموقع الحالي نستخدم آخر موقع معروف أو إحداثيات افتراضية
      if (currentPosition.value == null) {
        status.value = QiblaStatus.error;
        statusMessage.value =
            'تعذر الحصول على موقعك الحالي، يرجى المحاولة في مكان مفتوح.';
        return;
      }
    }

    // 5. فحص وتشغيل الكاميرا لوضع الواقع المعزز
    await _checkCameraAndInit();

    // 6. الاستماع لحساس البوصلة
    _startListeningToCompass();

    status.value = QiblaStatus.ready;
  }

  /// الاستماع لتغيرات حالة خدمة الموقع GPS
  void _listenToLocationServiceStatus() {
    _locationServiceSubscription?.cancel();
    _locationServiceSubscription = Geolocator.getServiceStatusStream().listen((
      serviceStatus,
    ) {
      if (serviceStatus == ServiceStatus.enabled) {
        initQibla();
      }
    });
  }

  /// طلب وتجهيز الكاميرا
  Future<void> _checkCameraAndInit() async {
    try {
      final cameraPermission = await Permission.camera.status;
      if (!cameraPermission.isGranted) {
        final res = await Permission.camera.request();
        if (!res.isGranted) {
          // إذا رفض المستخدم الكاميرا، نتحول تلقائياً لوضع البوصلة 2D دون إيقاف التطبيق
          isArMode.value = false;
          return;
        }
      }

      await _initCamera();
    } catch (_) {
      isArMode.value = false;
    }
  }

  /// تهيئة الكاميرا الخلفية
  Future<void> _initCamera() async {
    try {
      _availableCameras = await availableCameras();
      if (_availableCameras.isEmpty) {
        isArMode.value = false;
        return;
      }

      final backCamera = _availableCameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => _availableCameras.first,
      );

      cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await cameraController!.initialize();
      isCameraInitialized.value = true;
    } catch (e) {
      isArMode.value = false;
      isCameraInitialized.value = false;
    }
  }

  /// التبديل بين وضع الكاميرا ووضع البوصلة
  Future<void> toggleMode() async {
    isArMode.value = !isArMode.value;
    if (isArMode.value) {
      if (!isCameraInitialized.value) {
        await _checkCameraAndInit();
      }
    }
  }

  /// الاستماع لحساس البوصلة ومعالجة الحركة
  void _startListeningToCompass() {
    _compassSubscription?.cancel();
    _compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
      if (event.heading == null) return;

      final double heading = event.heading!;
      accuracy.value = event.accuracy ?? 0.0;
      currentHeading.value = heading;

      // تنعيم زاوية الدوران للتخلص من التموجات
      smoothedHeading.value = QiblaMathService.smoothAngle(
        smoothedHeading.value == 0 ? heading : smoothedHeading.value,
        heading,
        factor: 0.25,
      );

      // حساب الفرق الزاوي بالنسبة للقبلة
      final double diff = QiblaMathService.getAngleDifference(
        qiblaBearing.value,
        smoothedHeading.value,
      );
      angleDiff.value = diff;

      // التحقق من الانطباق
      final bool nowAligned = diff.abs() <= alignmentThreshold;
      if (nowAligned && !isAligned.value) {
        isAligned.value = true;
        _triggerHapticFeedback();
      } else if (!nowAligned && isAligned.value) {
        isAligned.value = false;
        _hasVibratedForAlignment = false;
      }
    });
  }

  /// إطلاق اهتزاز هپتيك عند الوصول للقبلة
  void _triggerHapticFeedback() {
    if (!_hasVibratedForAlignment) {
      _hasVibratedForAlignment = true;
      HapticFeedback.heavyImpact();
    }
  }

  /// إيقاف الكاميرا
  void _disposeCamera() {
    cameraController?.dispose();
    cameraController = null;
    isCameraInitialized.value = false;
  }

  /// إعادة المحاولة
  Future<void> retry() async {
    await initQibla();
  }

  /// فتح إعدادات التطبيق
  Future<void> openAppSettingsPage() async {
    await openAppSettings();
  }
}
