import 'package:get/get.dart';
import '../controller/nahj_controller.dart';
import '../controller/nahj_reader_controller.dart';
import '../data/data_sources/nahj_local_data_source.dart';
import '../data/data_sources/nahj_remote_data_source.dart';
import '../data/repositories/nahj_repository.dart';

class NahjBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NahjRemoteDataSource>(() => NahjRemoteDataSource(), fenix: true);
    Get.lazyPut<NahjLocalDataSource>(() => NahjLocalDataSource(), fenix: true);

    Get.lazyPut<NahjRepository>(
      () => NahjRepository(
        remoteDataSource: Get.find<NahjRemoteDataSource>(),
        localDataSource: Get.find<NahjLocalDataSource>(),
      ),
      fenix: true,
    );

    Get.lazyPut<NahjController>(
      () => NahjController(repository: Get.find<NahjRepository>()),
      fenix: true,
    );

    Get.lazyPut<NahjReaderController>(
      () => NahjReaderController(repository: Get.find<NahjRepository>()),
      fenix: true,
    );
  }
}
