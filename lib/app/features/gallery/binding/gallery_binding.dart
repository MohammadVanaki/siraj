import 'package:get/get.dart';
import 'package:mawsueat/app/features/gallery/controller/gallery_controller.dart';
import 'package:mawsueat/app/features/gallery/data/repositories/gallery_repository.dart';
import 'package:mawsueat/app/features/gallery/data/repositories/remote_gallery_repository.dart';

class GalleryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GalleryRepository>(() => RemoteGalleryRepository());

    Get.lazyPut<GalleryController>(
      () => GalleryController(Get.find<GalleryRepository>()),
    );
  }
}
