import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/data_sources/juz_constants.dart';
import '../data/data_sources/surah_constants.dart';
import '../data/models/juz_model.dart';
import '../data/models/surah_model.dart';
import '../data/models/tafsir_source.dart';
import '../data/repositories/quran_repository.dart';

enum RevelationFilter { all, meccan, medinan }

enum QuranTab { surahs, juzs }

class QuranController extends GetxController {
  final QuranRepository _repository;

  QuranController({QuranRepository? repository})
      : _repository = repository ??
            (Get.isRegistered<QuranRepository>()
                ? Get.find<QuranRepository>()
                : QuranRepository());

  // تب فعال: سوره‌ها یا جزء‌ها
  final Rx<QuranTab> selectedTab = QuranTab.surahs.obs;

  final RxList<SurahModel> allSurahs = <SurahModel>[].obs;
  final RxList<SurahModel> filteredSurahs = <SurahModel>[].obs;

  final RxList<JuzModel> allJuzs = <JuzModel>[].obs;
  final RxList<JuzModel> filteredJuzs = <JuzModel>[].obs;

  final Rx<RevelationFilter> activeFilter = RevelationFilter.all.obs;
  final TextEditingController searchController = TextEditingController();

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // لیست تفاسیر
  final RxList<TafsirSource> availableTafsirs = <TafsirSource>[].obs;

  // تفسیر انتخاب‌شده
  late final Rx<TafsirSource> selectedTafsir;

  @override
  void onInit() {
    super.onInit();
    availableTafsirs.assignAll(
        TafsirSource.defaultTafsirs.where((t) => t.isAvailable));
    selectedTafsir = availableTafsirs.first.obs;
    allJuzs.assignAll(JuzConstants.allJuzs);
    filteredJuzs.assignAll(JuzConstants.allJuzs);
    loadSurahs();
    _loadTafsirs();
    searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadTafsirs() async {
    try {
      final list = await _repository.getTafsirs();
      final available = list.where((t) => t.isAvailable).toList();
      if (available.isNotEmpty) {
        availableTafsirs.assignAll(available);
        final match = availableTafsirs.firstWhereOrNull(
          (t) => t.id == selectedTafsir.value.id,
        );
        if (match != null) {
          selectedTafsir.value = match;
        } else {
          selectedTafsir.value = availableTafsirs.first;
        }
      }
    } catch (e) {
      debugPrint('Error loading tafsirs: $e');
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void setTab(QuranTab tab) {
    selectedTab.value = tab;
    _applyFilter();
  }

  Future<void> loadSurahs() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final surahs = await _repository.getSurahs();
      allSurahs.assignAll(surahs);
      _applyFilter();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(RevelationFilter filter) {
    activeFilter.value = filter;
    _applyFilter();
  }

  void _onSearchChanged() {
    _applyFilter();
  }

  void _applyFilter() {
    final query = searchController.text.trim().toLowerCase();

    // فیلتر سوره‌ها
    filteredSurahs.assignAll(allSurahs.where((surah) {
      final matchesFilter = switch (activeFilter.value) {
        RevelationFilter.all => true,
        RevelationFilter.meccan => surah.isMeccan,
        RevelationFilter.medinan => !surah.isMeccan,
      };

      if (!matchesFilter) return false;
      if (query.isEmpty) return true;

      final normalizedQuery = _normalizeArabic(query);
      final normalizedSurahName = _normalizeArabic(surah.name);
      final normalizedEnglish = surah.englishName.toLowerCase();
      final surahNumberStr = surah.number.toString();

      return normalizedSurahName.contains(normalizedQuery) ||
          normalizedEnglish.contains(query) ||
          surahNumberStr == query;
    }).toList());

    // فیلتر جزء‌ها
    if (query.isEmpty) {
      filteredJuzs.assignAll(allJuzs);
    } else {
      final normalizedQuery = _normalizeArabic(query);
      filteredJuzs.assignAll(allJuzs.where((juz) {
        final juzNumberStr = juz.number.toString();
        final normalizedName = _normalizeArabic(juz.name);
        final normalizedVerseText = _normalizeArabic(juz.startVerseText);

        // آیا شماره یا نام جزء یا آیه شروع تطابق دارد؟
        if (juzNumberStr == query ||
            normalizedName.contains(normalizedQuery) ||
            normalizedVerseText.contains(normalizedQuery)) {
          return true;
        }

        // آیا سوره های داخل این جزء تطابق دارند؟
        for (var ref in juz.surahs) {
          final surah = getSurahByNumber(ref.surahNumber);
          if (surah != null) {
            final normalizedSurahName = _normalizeArabic(surah.name);
            if (normalizedSurahName.contains(normalizedQuery) ||
                surah.englishName.toLowerCase().contains(query)) {
              return true;
            }
          }
        }

        return false;
      }).toList());
    }
  }

  String _normalizeArabic(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ي', 'ی')
        .replaceAll('ئ', 'ی')
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '') // حذف اعراب و تشدید
        .toLowerCase();
  }

  void selectTafsir(TafsirSource tafsir) {
    selectedTafsir.value = tafsir;
  }

  SurahModel? getSurahByNumber(int number) {
    if (allSurahs.isNotEmpty) {
      final found = allSurahs.firstWhereOrNull((s) => s.number == number);
      if (found != null) return found;
    }
    return SurahConstants.allSurahs.firstWhereOrNull((s) => s.number == number);
  }
}
