import 'package:get/get.dart';
import '../controller/duas_controller.dart';
import '../data/repositories/duas_repository.dart';
import '../data/repositories/remote_duas_repository.dart';
import '../data/services/duas_audio_cache_service.dart';

class DuasBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<DuasAudioCacheService>()) {
      Get.lazyPut<DuasAudioCacheService>(() => DuasAudioCacheService());
    }
    if (!Get.isRegistered<DuasRepository>()) {
      Get.lazyPut<DuasRepository>(() => RemoteDuasRepository());
    }
    Get.lazyPut<DuasController>(() => DuasController());
  }
}
