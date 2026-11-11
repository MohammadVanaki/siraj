import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/constants/api_constants.dart';
import 'package:mawsueat/app/core/network/api_client.dart';
import '../models/sahifa_dua_model.dart';

class SahifaRemoteDataSource {
  ApiClient get _apiClient {
    if (Get.isRegistered<ApiClient>()) {
      return Get.find<ApiClient>();
    }
    return Get.put(ApiClient(), permanent: true);
  }

  /// دریافت لیست کامل ادعیه صحیفه سجادیه از API دجله
  /// GET https://alsiraj-api.dijlah.org/api/v1/sahifa-sajjadiya
  Future<List<SahifaDuaModel>> getDuasList() async {
    try {
      final response = await _apiClient.get(ApiConstants.sahifaSajjadiya);
      if (response['success'] == true && response['data'] is List) {
        final List list = response['data'];
        final items = list
            .map((e) => SahifaDuaModel.fromJson(Map<String, dynamic>.from(e)))
            .where((item) => item.published)
            .toList();

        // مرتب‌سازی بر اساس sortOrder در صورت تعیین، یا نگهداری ترتیب دریافتی
        items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return items;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching Sahifa Sajjadiya duas: $e');
      rethrow;
    }
  }

  /// دریافت جزئیات و متن کامل یک دعای خاص با شناسه
  /// GET https://alsiraj-api.dijlah.org/api/v1/sahifa-sajjadiya/{id}
  Future<SahifaDuaModel?> getDuaDetail(String id) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.sahifaSajjadiyaDetail(id),
      );
      if (response['success'] == true && response['data'] != null) {
        return SahifaDuaModel.fromJson(
          Map<String, dynamic>.from(response['data']),
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching Sahifa Sajjadiya dua detail ($id): $e');
      return null;
    }
  }
}
