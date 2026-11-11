import '../data_sources/quran_api_provider.dart';
import '../models/ayah_model.dart';
import '../models/reciter_model.dart';
import '../models/surah_model.dart';
import '../models/tafsir_source.dart';

class QuranRepository {
  final QuranApiProvider _apiProvider;

  QuranRepository({QuranApiProvider? apiProvider})
      : _apiProvider = apiProvider ?? QuranApiProvider();

  Future<List<SurahModel>> getSurahs() {
    return _apiProvider.getSurahs();
  }

  Future<List<AyahModel>> getSurahVerses(int surahNumber, TafsirSource tafsir) {
    return _apiProvider.getSurahVerses(
      surahNumber,
      tafsirIdentifier: tafsir.apiIdentifier,
      tafsirDisplayName: tafsir.name,
    );
  }

  Future<AyahModel?> getAyah(int surahNumber, int ayahNumber) {
    return _apiProvider.getAyah(surahNumber, ayahNumber);
  }

  Future<List<AyahModel>> getPageVerses(int pageNumber) {
    return _apiProvider.getPageVerses(pageNumber);
  }

  Future<List<AyahModel>> getJuzVerses(int juzNumber) {
    return _apiProvider.getJuzVerses(juzNumber);
  }

  Future<List<ReciterModel>> getReciters() {
    return _apiProvider.getReciters();
  }

  Future<String?> getAyahAudioUrl({
    required int surahNumber,
    required int ayahNumber,
    required String reciterId,
  }) {
    return _apiProvider.getAyahAudioUrl(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      reciterId: reciterId,
    );
  }

  final Map<String, String> _tafsirCache = {};

  Future<List<TafsirSource>> getTafsirs() {
    return _apiProvider.getTafsirs();
  }

  Future<String?> getAyahTafsir({
    required int surahNumber,
    required int ayahNumber,
    required String tafsirId,
  }) async {
    final cacheKey = '${surahNumber}_${ayahNumber}_$tafsirId';
    if (_tafsirCache.containsKey(cacheKey)) {
      return _tafsirCache[cacheKey];
    }
    final text = await _apiProvider.getAyahTafsir(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      tafsirId: tafsirId,
    );
    if (text != null && text.isNotEmpty) {
      _tafsirCache[cacheKey] = text;
    }
    return text;
  }
}
