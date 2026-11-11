import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/constants/constants.dart';
import '../data/data_sources/surah_constants.dart';
import '../data/models/ayah_model.dart';
import '../data/models/reciter_model.dart';
import '../data/models/surah_model.dart';
import '../data/models/tafsir_source.dart';
import '../data/repositories/quran_repository.dart';

class MushafPageReaderController extends GetxController {
  final QuranRepository _repository;
  final int initialPage;

  MushafPageReaderController({
    this.initialPage = 1,
    QuranRepository? repository,
  })  : _repository = repository ??
            (Get.isRegistered<QuranRepository>()
                ? Get.find<QuranRepository>()
                : QuranRepository()),
        currentPage = initialPage.obs;

  static const int totalPages = 604;

  late final PageController pageController;

  // الصفحة الحالية (1 - 604)
  final RxInt currentPage;

  // کش صفحات برای پیمایش سریع و آفلاین بدون لودینگ مجدد
  final RxMap<int, List<AyahModel>> pageCache = <int, List<AyahModel>>{}.obs;
  final RxSet<int> loadingPages = <int>{}.obs;
  final RxMap<int, String> pageErrors = <int, String>{}.obs;

  // تنظیمات قلم
  final RxDouble quranFontSize = 21.0.obs;
  final RxString quranFontFamily = 'uthman_taha'.obs;

  // تفسیر انتخابی
  final Rx<TafsirSource> selectedTafsir = TafsirSource.defaultTafsirs.first.obs;

  // قاری انتخابی
  final Rx<ReciterModel> selectedReciter = ReciterModel.defaultReciters.first.obs;

  @override
  void onInit() {
    super.onInit();
    final savedFont = Constants.localStorage.read('quranFontFamily');
    if (savedFont != null &&
        savedFont is String &&
        savedFont.isNotEmpty &&
        savedFont != 'abo' &&
        savedFont != 'dijlah') {
      quranFontFamily.value = savedFont;
    } else {
      quranFontFamily.value = 'uthman_taha';
      Constants.localStorage.write('quranFontFamily', 'uthman_taha');
    }
    pageController = PageController(initialPage: initialPage - 1);
    loadPage(initialPage);
    _prefetchNearbyPages(initialPage);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    final pageNumber = index + 1;
    currentPage.value = pageNumber;
    loadPage(pageNumber);
    _prefetchNearbyPages(pageNumber);
  }

  Future<void> loadPage(int pageNumber) async {
    if (pageNumber < 1 || pageNumber > totalPages) return;
    if (pageCache.containsKey(pageNumber)) return;
    if (loadingPages.contains(pageNumber)) return;

    try {
      loadingPages.add(pageNumber);
      pageErrors.remove(pageNumber);

      final verses = await _repository.getPageVerses(pageNumber);
      pageCache[pageNumber] = verses;
    } catch (e) {
      pageErrors[pageNumber] = e.toString();
    } finally {
      loadingPages.remove(pageNumber);
    }
  }

  void _prefetchNearbyPages(int pageNumber) {
    if (pageNumber + 1 <= totalPages && !pageCache.containsKey(pageNumber + 1)) {
      loadPage(pageNumber + 1);
    }
    if (pageNumber - 1 >= 1 && !pageCache.containsKey(pageNumber - 1)) {
      loadPage(pageNumber - 1);
    }
  }

  void jumpToPage(int pageNumber) {
    if (pageNumber < 1 || pageNumber > totalPages) return;
    currentPage.value = pageNumber;
    pageController.jumpToPage(pageNumber - 1);
    loadPage(pageNumber);
  }

  void jumpToSurah(SurahModel surah) async {
    try {
      // دریافت اولین آیه برای دانستن شماره صفحه شروع سوره
      final verses = await _repository.getSurahVerses(surah.number, selectedTafsir.value);
      if (verses.isNotEmpty && verses.first.page != null) {
        jumpToPage(verses.first.page!);
      }
    } catch (e) {
      debugPrint('Error jumping to surah page: $e');
    }
  }

  String getCurrentSurahName(int pageNumber) {
    final verses = pageCache[pageNumber];
    if (verses != null && verses.isNotEmpty) {
      // سوره اولین آیه موجود در این صفحه
      final surahNumber = verses.first.surahNumber;
      final surah = SurahConstants.getByNumber(surahNumber);
      return surah?.name ?? 'القرآن الكريم';
    }
    return 'القرآن الكريم';
  }

  int getCurrentJuzNumber(int pageNumber) {
    final verses = pageCache[pageNumber];
    if (verses != null && verses.isNotEmpty && verses.first.juz != null) {
      return verses.first.juz!;
    }
    return 1;
  }

  void increaseFontSize() {
    if (quranFontSize.value < 32.0) {
      quranFontSize.value += 1.5;
    }
  }

  void decreaseFontSize() {
    if (quranFontSize.value > 16.0) {
      quranFontSize.value -= 1.5;
    }
  }
}

