import 'package:get/get.dart';
import 'package:mawsueat/app/core/network/api_client.dart';
import 'package:mawsueat/app/features/istikhara/controller/istikhara_controller.dart';
import 'package:mawsueat/app/features/istikhara/data/repositories/istikhara_repository.dart';
import 'package:mawsueat/app/features/istikhara/data/repositories/remote_istikhara_repository.dart';

class IstikharaBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient());
    }

    Get.lazyPut<IstikharaRepository>(() => RemoteIstikharaRepository());

    Get.lazyPut<IstikharaController>(
      () => IstikharaController(Get.find<IstikharaRepository>()),
    );
  }
}

