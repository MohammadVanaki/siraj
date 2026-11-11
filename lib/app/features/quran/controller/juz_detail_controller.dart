import 'package:get/get.dart';
import '../data/models/ayah_model.dart';
import '../data/models/juz_model.dart';
import '../data/models/reciter_model.dart';
import '../data/models/tafsir_source.dart';
import '../data/repositories/quran_repository.dart';

class JuzDetailController extends GetxController {
  final JuzModel juz;
  final QuranRepository _repository;

  JuzDetailController({
    required this.juz,
    QuranRepository? repository,
  }) : _repository = repository ??
            (Get.isRegistered<QuranRepository>()
                ? Get.find<QuranRepository>()
                : QuranRepository());

  final RxList<AyahModel> ayahs = <AyahModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final RxDouble quranFontSize = 22.0.obs;
  final Rx<TafsirSource> selectedTafsir = TafsirSource.defaultTafsirs.first.obs;
  final Rx<ReciterModel> selectedReciter = ReciterModel.defaultReciters.first.obs;

  @override
  void onInit() {
    super.onInit();
    loadJuzVerses();
  }

  Future<void> loadJuzVerses() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final verses = await _repository.getJuzVerses(juz.number);
      ayahs.assignAll(verses);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void increaseFontSize() {
    if (quranFontSize.value < 34.0) {
      quranFontSize.value += 1.5;
    }
  }

  void decreaseFontSize() {
    if (quranFontSize.value > 16.0) {
      quranFontSize.value -= 1.5;
    }
  }
}

