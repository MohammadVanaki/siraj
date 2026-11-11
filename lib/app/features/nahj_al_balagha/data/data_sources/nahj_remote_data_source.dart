import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/constants/api_constants.dart';
import 'package:mawsueat/app/core/network/api_client.dart';
import '../models/nahj_category_model.dart';
import '../models/nahj_commentator_model.dart';
import '../models/nahj_commentary_model.dart';
import '../models/nahj_entry_model.dart';

class NahjRemoteDataSource {
  ApiClient get _apiClient {
    if (Get.isRegistered<ApiClient>()) {
      return Get.find<ApiClient>();
    }
    return Get.put(ApiClient(), permanent: true);
  }

  /// دریافت دسته‌بندی‌های نهج‌البلاغه (الخطب، الرسائل، الحكم، غريب الكلام)
  /// GET https://alsiraj-api.dijlah.org/api/v1/nahj/categories
  Future<List<NahjCategoryModel>> getCategories() async {
    try {
      final response = await _apiClient.get(ApiConstants.nahjCategories);
      if (response['success'] == true && response['data'] is List) {
        final List list = response['data'];
        return list
            .map((e) => NahjCategoryModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching Nahj categories: $e');
      rethrow;
    }
  }

  /// دریافت لیست شارحان نهج‌البلاغه (ابن أبي الحديد، ابن ميثم، محمد تقي جعفري)
  /// GET https://alsiraj-api.dijlah.org/api/v1/nahj/commentators
  Future<List<NahjCommentatorModel>> getCommentators() async {
    try {
      final response = await _apiClient.get(ApiConstants.nahjCommentators);
      if (response['success'] == true && response['data'] is List) {
        final List list = response['data'];
        final items = list
            .map((e) => NahjCommentatorModel.fromJson(Map<String, dynamic>.from(e)))
            .where((item) => item.enabled)
            .toList();
        items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return items;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching Nahj commentators: $e');
      return [];
    }
  }

  /// دریافت لیست ورودی‌های نهج‌البلاغه با فیلتر دسته‌بندی، جستجو و صفحه‌بندی
  /// GET https://alsiraj-api.dijlah.org/api/v1/nahj/entries?category=...&page=...&limit=...&q=...
  Future<Map<String, dynamic>> getEntries({
    String? category,
    int page = 1,
    int limit = 20,
    String? q,
  }) async {
    try {
      final url = ApiConstants.nahjEntries(
        category: category,
        page: page,
        limit: limit,
        q: q,
      );
      final response = await _apiClient.get(url);

      if (response['success'] == true && response['data'] is List) {
        final List list = response['data'];
        final items = list
            .map((e) => NahjEntryModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        bool hasMore = false;
        int total = items.length;

        final meta = response['meta'];
        if (meta is Map && meta['pagination'] is Map) {
          final p = meta['pagination'];
          hasMore = p['hasMore'] == true;
          total = (p['total'] as num?)?.toInt() ?? total;
        }

        return {
          'entries': items,
          'hasMore': hasMore,
          'total': total,
        };
      }

      return {
        'entries': <NahjEntryModel>[],
        'hasMore': false,
        'total': 0,
      };
    } catch (e) {
      debugPrint('Error fetching Nahj entries: $e');
      rethrow;
    }
  }

  /// دریافت جزئیات و متن کامل یک ورودی نهج‌البلاغه به همراه شروح
  /// GET https://alsiraj-api.dijlah.org/api/v1/nahj/entries/{id}
  Future<NahjEntryModel?> getEntryDetail(String id) async {
    try {
      final url = ApiConstants.nahjEntryDetail(id);
      final response = await _apiClient.get(url);

      if (response['success'] == true && response['data'] != null) {
        return NahjEntryModel.fromJson(
          Map<String, dynamic>.from(response['data']),
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching Nahj entry detail ($id): $e');
      return null;
    }
  }

  /// دریافت متن کامل یک شرح مشخص
  /// GET https://alsiraj-api.dijlah.org/api/v1/nahj/commentaries/{id}
  Future<NahjCommentaryModel?> getCommentaryDetail(String id) async {
    try {
      final url = ApiConstants.nahjCommentaryDetail(id);
      final response = await _apiClient.get(url);

      if (response['success'] == true && response['data'] != null) {
        return NahjCommentaryModel.fromJson(
          Map<String, dynamic>.from(response['data']),
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching Nahj commentary detail ($id): $e');
      return null;
    }
  }
}
