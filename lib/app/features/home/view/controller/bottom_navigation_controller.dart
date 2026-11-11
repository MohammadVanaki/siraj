import 'package:get/get.dart';
import 'package:mawsueat/app/features/favorite%20&%20comment/view/controller/favorite_controller.dart';

class BottomNavigationController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  void onItemTapped(int index) {
    selectedIndex.value = index;
    if (index == 1) {
      FavoriteController favController;
      if (Get.isRegistered<FavoriteController>()) {
        favController = Get.find<FavoriteController>();
      } else {
        favController = Get.put(FavoriteController());
      }
      favController.loadBookmarks();
      favController.loadComments();
    }
  }
}
