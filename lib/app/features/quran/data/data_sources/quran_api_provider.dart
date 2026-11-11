import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/constants/api_constants.dart';
import 'package:mawsueat/app/core/network/api_client.dart';
import '../models/ayah_model.dart';
import '../models/reciter_model.dart';
import '../models/surah_model.dart';
import '../models/tafsir_source.dart';
import 'surah_constants.dart';

class QuranApiProvider {
  ApiClient get _apiClient {
    if (Get.isRegistered<ApiClient>()) {
      return Get.find<ApiClient>();
    }
    return Get.put(ApiClient(), permanent: true);
  }

  /// جلب قائمة جميع سور القرآن الكريم من سيرفر دجلة
  /// GET https://alsiraj-api.dijlah.org/api/v1/quran/surahs
  Future<List<SurahModel>> getSurahs() async {
    try {
      final response = await _apiClient.get(ApiConstants.quranSurahs);

      if (response['success'] == true && response['data'] is List) {
        final list = (response['data'] as List)
            .map((item) => SurahModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        return list;
      }
      return SurahConstants.allSurahs;
    } catch (e) {
      debugPrint('Error loading surahs from server: $e');
      // در صورت خطای شبکه، لیست استاندارد محلی ۱۱۴ سوره را برمی‌گرداند
      return SurahConstants.allSurahs;
    }
  }

  /// جلب آیات و جزئیات سوره از سيرفر دجله
  /// GET https://alsiraj-api.dijlah.org/api/v1/quran/surahs/{number}
  Future<List<AyahModel>> getSurahVerses(
    int surahNumber, {
    String? tafsirIdentifier,
    String? tafsirDisplayName,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.quranSurahDetail(surahNumber),
      );

      if (response['success'] == true && response['data'] != null) {
        final data = Map<String, dynamic>.from(response['data'] as Map);
        final versesJson = data['verses'] as List? ?? [];

        return versesJson.map((item) {
          final itemMap = Map<String, dynamic>.from(item as Map);
          if (!itemMap.containsKey('surah')) {
            itemMap['surah'] = surahNumber;
          }
          return AyahModel.fromJson(
            itemMap,
            tafsirName: tafsirDisplayName,
          );
        }).toList();
      }
      throw Exception('فشل في تحميل الآيات: استجابة غير صحيحة من الخادم');
    } catch (e) {
      debugPrint('Error loading surah verses from server: $e');
      rethrow;
    }
  }

  /// جلب آية معينة من سورة محددة
  /// GET https://alsiraj-api.dijlah.org/api/v1/quran/surahs/{surah}/ayahs/{ayah}
  Future<AyahModel?> getAyah(int surahNumber, int ayahNumber) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.quranAyahDetail(surahNumber, ayahNumber),
      );

      if (response['success'] == true && response['data'] != null) {
        final data = Map<String, dynamic>.from(response['data'] as Map);
        if (!data.containsKey('surah')) {
          data['surah'] = surahNumber;
        }
        return AyahModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error loading ayah from server: $e');
      rethrow;
    }
  }

  /// جلب جميع آيات صفحة معينة من المصحف الشريف
  /// GET https://alsiraj-api.dijlah.org/api/v1/quran/pages/{page}
  Future<List<AyahModel>> getPageVerses(int pageNumber) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.quranPage(pageNumber),
      );

      if (response['success'] == true && response['data'] != null) {
        final data = Map<String, dynamic>.from(response['data'] as Map);
        final versesJson = data['verses'] as List? ?? [];

        return versesJson.map((item) {
          final itemMap = Map<String, dynamic>.from(item as Map);
          return AyahModel.fromJson(itemMap);
        }).toList();
      }
      throw Exception('فشل في تحميل آيات الصفحة: استجابة غير صحيحة من الخادم');
    } catch (e) {
      debugPrint('Error loading page verses from server: $e');
      rethrow;
    }
  }

  /// جلب جميع آيات جزء معين من القرآن الكريم
  /// GET https://alsiraj-api.dijlah.org/api/v1/quran/juzs/{juz}
  Future<List<AyahModel>> getJuzVerses(int juzNumber) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.quranJuz(juzNumber),
      );

      if (response['success'] == true && response['data'] != null) {
        final data = Map<String, dynamic>.from(response['data'] as Map);
        final versesJson = data['verses'] as List? ?? [];

        return versesJson.map((item) {
          final itemMap = Map<String, dynamic>.from(item as Map);
          return AyahModel.fromJson(itemMap);
        }).toList();
      }
      throw Exception('فشل في تحميل آيات الجزء: استجابة غير صحيحة من الخادم');
    } catch (e) {
      debugPrint('Error loading juz verses from server: $e');
      rethrow;
    }
  }

  /// جلب قائمة القراء المعتمدين من خادم دجلة
  /// GET https://alsiraj-api.dijlah.org/api/v1/quran/reciters
  Future<List<ReciterModel>> getReciters() async {
    try {
      final response = await _apiClient.get(ApiConstants.quranReciters);

      if (response['success'] == true && response['data'] is List) {
        final list = (response['data'] as List)
            .map((item) => ReciterModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        if (list.isNotEmpty) {
          return list;
        }
      }
      return ReciterModel.defaultReciters;
    } catch (e) {
      debugPrint('Error loading reciters from server: $e');
      return ReciterModel.defaultReciters;
    }
  }

  /// جلب رابط تلاوة الآية من الخادم لقارئ محدد
  /// GET https://alsiraj-api.dijlah.org/api/v1/quran/surahs/{surah}/ayahs/{ayah}/audio/{reciterId}
  Future<String?> getAyahAudioUrl({
    required int surahNumber,
    required int ayahNumber,
    required String reciterId,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.quranAyahAudio(surahNumber, ayahNumber, reciterId),
      );

      if (response['success'] == true && response['data'] != null) {
        final data = Map<String, dynamic>.from(response['data'] as Map);
        final audioUrl = data['audioUrl'] as String?;
        if (audioUrl != null && audioUrl.trim().isNotEmpty) {
          return audioUrl.trim();
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error loading ayah audio URL from server: $e');
      return null;
    }
  }

  /// جلب قائمة التفاسير المعتمدة من سيرفر دجلة
  /// GET https://alsiraj-api.dijlah.org/api/v1/quran/tafsirs
  Future<List<TafsirSource>> getTafsirs() async {
    try {
      final response = await _apiClient.get(ApiConstants.quranTafsirs);

      if (response['success'] == true && response['data'] is List) {
        final serverList = (response['data'] as List)
            .map((item) => TafsirSource.fromJson(Map<String, dynamic>.from(item as Map)))
            .where((t) => t.isAvailable)
            .toList();

        if (serverList.isNotEmpty) {
          return serverList;
        }
      }
      return TafsirSource.defaultTafsirs.where((t) => t.isAvailable).toList();
    } catch (e) {
      debugPrint('Error loading tafsirs from server: $e');
      return TafsirSource.defaultTafsirs.where((t) => t.isAvailable).toList();
    }
  }

  /// جلب نص تفسير آية معينة من سيرفر دجلة
  /// GET https://alsiraj-api.dijlah.org/api/v1/quran/surahs/{surah}/ayahs/{ayah}/tafsir/{tafsirId}
  Future<String?> getAyahTafsir({
    required int surahNumber,
    required int ayahNumber,
    required String tafsirId,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.quranAyahTafsir(surahNumber, ayahNumber, tafsirId),
      );

      if (response['success'] == true && response['data'] != null) {
        final data = Map<String, dynamic>.from(response['data'] as Map);
        final textArabic = data['textArabic'] as String?;
        if (textArabic != null && textArabic.trim().isNotEmpty) {
          return textArabic.trim();
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error loading ayah tafsir from server: $e');
      return null;
    }
  }
}
