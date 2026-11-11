import 'package:get/get.dart';
import 'package:mawsueat/app/features/rulings/controller/rulings_controller.dart';
import 'package:mawsueat/app/features/rulings/data/repositories/rulings_repository.dart';
import 'package:mawsueat/app/features/rulings/data/repositories/mock_rulings_repository.dart';
// import 'package:mawsueat/app/features/rulings/data/repositories/remote_rulings_repository.dart';

class RulingsBinding extends Bindings {
  @override
  void dependencies() {
    // 💡 عند جهوزية الـ API يتم استبدال MockRulingsRepository بـ RemoteRulingsRepository فقط!
    Get.lazyPut<RulingsRepository>(() => MockRulingsRepository());
    // Get.lazyPut<RulingsRepository>(() => RemoteRulingsRepository());

    Get.lazyPut<RulingsController>(
      () => RulingsController(Get.find<RulingsRepository>()),
    );
  }
}
