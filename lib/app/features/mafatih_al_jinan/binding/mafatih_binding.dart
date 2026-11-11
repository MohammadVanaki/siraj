import 'package:get/get.dart';
import '../controller/mafatih_controller.dart';
import '../controller/mafatih_reader_controller.dart';

class MafatihBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MafatihController>(() => MafatihController());
    Get.lazyPut<MafatihReaderController>(() => MafatihReaderController());
  }
}
