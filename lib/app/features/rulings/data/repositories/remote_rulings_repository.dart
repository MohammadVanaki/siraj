import 'package:get/get.dart';
import 'package:mawsueat/app/core/network/api_client.dart';
import 'package:mawsueat/app/features/rulings/data/models/marja_model.dart';
import 'package:mawsueat/app/features/rulings/data/models/ruling_category_model.dart';
import 'package:mawsueat/app/features/rulings/data/models/ruling_model.dart';
import 'package:mawsueat/app/features/rulings/data/repositories/rulings_repository.dart';

class RemoteRulingsRepository implements RulingsRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  @override
  Future<List<MarjaModel>> getMaraji() async {
    try {
      final response = await _apiClient.get('/api/rulings/maraji');
      final List list = response['data'] ?? response['maraji'] ?? [];
      return list.map((e) => MarjaModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('فشل في جلب قائمة المراجع: $e');
    }
  }

  @override
  Future<List<RulingCategoryModel>> getCategories() async {
    try {
      final response = await _apiClient.get('/api/rulings/categories');
      final List list = response['data'] ?? response['categories'] ?? [];
      return list.map((e) => RulingCategoryModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('فشل في جلب أبواب الاستفتاءات: $e');
    }
  }

  @override
  Future<List<RulingModel>> getRulings({
    int? marjaId,
    int? categoryId,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (marjaId != null && marjaId != 0) {
        params['marja_id'] = marjaId.toString();
      }
      if (categoryId != null && categoryId != 0) {
        params['category_id'] = categoryId.toString();
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        params['q'] = searchQuery;
      }

      final response = await _apiClient.get(
        '/api/rulings',
        queryParameters: params,
      );
      final List list = response['data'] ?? response['rulings'] ?? [];
      return list.map((e) => RulingModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('فشل في جلب الفتاوى والاستفتاءات: $e');
    }
  }

  @override
  Future<bool> submitQuestion({
    required int marjaId,
    required int categoryId,
    required String question,
    String? contactInfo,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/rulings/ask',
        data: {
          'marja_id': marjaId,
          'category_id': categoryId,
          'question': question,
          'contact_info': contactInfo,
        },
        body: {},
      );
      return response['success'] == true;
    } catch (e) {
      throw Exception('فشل في إرسال الاستفتاء: $e');
    }
  }

  @override
  Future<bool> toggleBookmark(int rulingId) async {
    try {
      final response = await _apiClient.post(
        '/api/rulings/bookmark',
        data: {'ruling_id': rulingId},
        body: {},
      );
      return response['is_favorite'] ?? true;
    } catch (e) {
      throw Exception('فشل في تحديث الحفظ: $e');
    }
  }
}
