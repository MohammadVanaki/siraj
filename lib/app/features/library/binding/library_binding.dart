import 'package:get/get.dart';
import 'package:mawsueat/app/core/network/api_client.dart';
import 'package:mawsueat/app/features/library/controller/library_controller.dart';
import 'package:mawsueat/app/features/library/data/repositories/library_repository.dart';
import 'package:mawsueat/app/features/library/data/repositories/remote_library_repository.dart';
import 'package:mawsueat/app/features/library/data/services/book_storage_service.dart';

class LibraryBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient());
    }

    // 1. ثبت سرویس ذخیره‌سازی محلی و دانلود
    if (!Get.isRegistered<BookStorageService>()) {
      Get.put<BookStorageService>(BookStorageService(), permanent: true);
    }

    final storageService = Get.find<BookStorageService>();

    // 2. ثبت مخزن ریموت
    Get.lazyPut<LibraryRepository>(
      () => RemoteLibraryRepository(Get.find<ApiClient>(), storageService),
    );

    // 3. ثبت کنترلر اصلی کتابخانه
    Get.lazyPut<LibraryController>(
      () => LibraryController(
        Get.find<LibraryRepository>(),
        storageService,
      ),
    );
  }
}
