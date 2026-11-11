import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mawsueat/app/config/error_widget.dart';
import 'package:mawsueat/app/config/get_version.dart';
import 'package:mawsueat/app/core/database/db_helper.dart';
import 'package:mawsueat/app/features/favorite%20&%20comment/view/controller/favorite_controller.dart';
import 'package:mawsueat/app/features/home/view/controller/navigation_controller.dart';
import 'package:mawsueat/app/features/prayer_times/service/prayer_audio_service.dart';
import 'package:mawsueat/app/features/prayer_times/service/prayer_notification_service.dart';
import 'package:mawsueat/app/core/network/api_client.dart';
import 'package:mawsueat/app/core/services/app_location_compass_service.dart';
import 'package:mawsueat/app/core/services/firebase_auth_service.dart';
import 'package:mawsueat/app/core/services/firestore_service.dart';
import 'package:mawsueat/app/core/services/media_notification_service.dart';
import 'package:mawsueat/app/features/setting/view/controller/settings_controller.dart';

Future<void> init() async {
  // Initialize storage first
  await GetStorage.init();

  // Initialize network client
  Get.put(ApiClient(), permanent: true);

  // Initialize Firebase services
  Get.put(FirebaseAuthService(), permanent: true);
  Get.put(FirestoreService(), permanent: true);

  // Initialize controllers and services
  Get.put(AppVersionController());
  Get.put(SettingsController());
  Get.put(FavoriteController(), permanent: true);
  Get.put(BottmNavigationController(), permanent: true);
  Get.put(PrayerAudioService(), permanent: true);
  Get.put(PrayerNotificationService(), permanent: true);
  Get.put(AppLocationCompassService(), permanent: true);
  final mediaService = await MediaNotificationService.initService();
  Get.put(mediaService, permanent: true);


  // Custom error widget
  CustomErrorWidget.initialize();

  // Initialize database factory
  DBHelper.initializeDatabaseFactory();

  debugPrint('✅ App initialization complete');
}
