import 'package:get/get.dart';
import '../controller/sahifa_controller.dart';
import '../controller/sahifa_reader_controller.dart';

class SahifaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SahifaController>(() => SahifaController());
    Get.lazyPut<SahifaReaderController>(() => SahifaReaderController());
  }
}
