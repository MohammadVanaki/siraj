import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/constants/api_constants.dart';
import 'package:mawsueat/app/core/network/api_client.dart';
import '../models/mafatih_item_model.dart';

class MafatihRemoteDataSource {
  ApiClient get _apiClient {
    if (Get.isRegistered<ApiClient>()) {
      return Get.find<ApiClient>();
    }
    return Get.put(ApiClient(), permanent: true);
  }

  /// دریافت لیست کامل مفاتیح الجنان از API دجله
  /// GET https://alsiraj-api.dijlah.org/api/v1/mafatih-al-jinan
  Future<List<MafatihItemModel>> getItemsList() async {
    try {
      final response = await _apiClient.get(ApiConstants.mafatihAlJinan);
      if (response['success'] == true && response['data'] is List) {
        final List list = response['data'];
        final items = list
            .map((e) => MafatihItemModel.fromJson(Map<String, dynamic>.from(e)))
            .where((item) => item.published)
            .toList();

        // مرتب‌سازی بر اساس sortOrder
        items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return items;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching Mafatih al-Jinan list: $e');
      rethrow;
    }
  }

  /// دریافت جزئیات و متن کامل یک مورد خاص از مفاتیح با شناسه
  /// GET https://alsiraj-api.dijlah.org/api/v1/mafatih-al-jinan/{id}
  Future<MafatihItemModel?> getItemDetail(String id) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.mafatihAlJinanDetail(id),
      );
      if (response['success'] == true && response['data'] != null) {
        return MafatihItemModel.fromJson(
          Map<String, dynamic>.from(response['data']),
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching Mafatih al-Jinan detail ($id): $e');
      return null;
    }
  }
}
