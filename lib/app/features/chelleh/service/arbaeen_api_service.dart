import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mawsueat/app/core/common/constants/api_constants.dart';
import 'package:mawsueat/app/core/network/api_client.dart';
import '../model/arbaeen_dhikr_model.dart';

class ArbaeenApiService {
  static const String _cacheKey = 'cached_arbaeen_adhkar_list';
  final GetStorage _storage = GetStorage();

  ApiClient get _apiClient {
    if (Get.isRegistered<ApiClient>()) {
      return Get.find<ApiClient>();
    }
    return Get.put(ApiClient(), permanent: true);
  }

  /// دریافت لیست اذکار از کش محلی
  List<ArbaeenDhikrModel> getCachedAdhkar() {
    try {
      final cached = _storage.read<List<dynamic>>(_cacheKey);
      if (cached != null && cached.isNotEmpty) {
        return cached
            .map((e) => ArbaeenDhikrModel.fromJson(Map<String, dynamic>.from(e)))
            .where((item) => item.published)
            .toList();
      }
    } catch (e) {
      debugPrint('Error reading cached arbaeen adhkar: $e');
    }
    return defaultFallbackAdhkar;
  }

  /// دریافت لیست اذکار از API و ذخیره در کش
  Future<List<ArbaeenDhikrModel>> fetchAdhkar() async {
    try {
      final response = await _apiClient.get(ApiConstants.arbaeenAdhkar);
      if (response['success'] == true && response['data'] is List) {
        final List list = response['data'];
        final items = list
            .map((e) => ArbaeenDhikrModel.fromJson(Map<String, dynamic>.from(e)))
            .where((item) => item.published)
            .toList();

        items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

        // ذخیره در کش محلی
        await _storage.write(_cacheKey, items.map((e) => e.toJson()).toList());
        return items;
      }
      return getCachedAdhkar();
    } catch (e) {
      debugPrint('Error fetching arbaeen adhkar from API: $e');
      return getCachedAdhkar();
    }
  }

  /// لیست پشتیبان برای مواقع آفلاین بدون کش
  static final List<ArbaeenDhikrModel> defaultFallbackAdhkar = [
    const ArbaeenDhikrModel(
      id: "arb_dhikr_d9d964ca-b8ab-4306-bba1-779a5c46e3a1",
      titleArabic: "صلوات",
      bodyArabic: "اللهم صل على محمد وآل محمد",
      repetitionCount: 100,
      sortOrder: 0,
      published: true,
    ),
    const ArbaeenDhikrModel(
      id: "arb_dhikr_c3762f36-f4ee-4628-8a65-d627e2e1987e",
      titleArabic: "سورة يس",
      bodyArabic: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nيس ۝ وَالْقُرْآنِ الْحَكِيمِ ۝ إِنَّكَ لَمِنَ الْمُرْسَلِينَ ۝ عَلَىٰ صِرَاطٍ مُسْتَقِيمٍ ۝ تَنزِيلَ الْعَزِيزِ الرَّحِيمِ...",
      repetitionCount: 1,
      sortOrder: 1,
      published: true,
    ),
  ];
}
