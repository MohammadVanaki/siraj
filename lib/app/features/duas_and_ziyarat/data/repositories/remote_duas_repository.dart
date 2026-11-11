import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../core/common/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/dua_media_item.dart';
import 'duas_repository.dart';

class RemoteDuasRepository implements DuasRepository {
  ApiClient get _apiClient {
    if (Get.isRegistered<ApiClient>()) {
      return Get.find<ApiClient>();
    }
    return Get.put(ApiClient(), permanent: true);
  }

  @override
  Future<List<DuaCategoryModel>> getVoiceCategories() async {
    try {
      final response = await _apiClient.get(ApiConstants.voicesCategories);
      if (response['success'] == true && response['data'] is List) {
        final List list = response['data'];
        final items = list
            .map((e) => DuaCategoryModel.fromJson(Map<String, dynamic>.from(e)))
            .where((c) => c.enabled)
            .toList();

        // مرتب‌سازی بر اساس sortOrder
        items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return items;
      }
      return [];
    } catch (e) {
      debugPrint('Error loading voices categories: $e');
      return [];
    }
  }

  @override
  Future<List<DuaAudioItem>> getVoices({String? categoryId}) async {
    try {
      final Map<String, String>? queryParams =
          categoryId != null ? {'categoryId': categoryId} : null;

      final response = await _apiClient.get(
        ApiConstants.voices,
        queryParameters: queryParams,
      );

      if (response['success'] == true && response['data'] is List) {
        final List list = response['data'];
        var items = list
            .map((e) => DuaAudioItem.fromJson(Map<String, dynamic>.from(e)))
            .where((v) => v.published)
            .toList();

        // اگر در صورت ارسال categoryId، سرور فیلتر نکرده بود، در سمت کلاینت فیلتر شود
        if (categoryId != null && categoryId.isNotEmpty) {
          items = items.where((v) => v.categoryId == categoryId).toList();
        }

        items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return items;
      }
      return [];
    } catch (e) {
      debugPrint('Error loading voices: $e');
      return [];
    }
  }

  @override
  Future<DuaAudioItem?> getVoiceById(String id) async {
    try {
      final response = await _apiClient.get(ApiConstants.voiceDetail(id));
      if (response['success'] == true && response['data'] != null) {
        return DuaAudioItem.fromJson(
          Map<String, dynamic>.from(response['data']),
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error loading voice by id ($id): $e');
      return null;
    }
  }

  @override
  Future<List<DuaCategoryModel>> getVideoCategories() async {
    try {
      final response = await _apiClient.get(ApiConstants.videosCategories);
      if (response['success'] == true && response['data'] is List) {
        final List list = response['data'];
        final items = list
            .map((e) => DuaCategoryModel.fromJson(Map<String, dynamic>.from(e)))
            .where((c) => c.enabled)
            .toList();

        items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return items;
      }
      return [];
    } catch (e) {
      debugPrint('Error loading videos categories: $e');
      return [];
    }
  }

  @override
  Future<List<DuaVideoItem>> getVideos({String? categoryId}) async {
    try {
      final Map<String, String>? queryParams =
          categoryId != null ? {'categoryId': categoryId} : null;

      final response = await _apiClient.get(
        ApiConstants.videos,
        queryParameters: queryParams,
      );

      if (response['success'] == true && response['data'] is List) {
        final List list = response['data'];
        var items = list
            .map((e) => DuaVideoItem.fromJson(Map<String, dynamic>.from(e)))
            .where((v) => v.published)
            .toList();

        if (categoryId != null && categoryId.isNotEmpty) {
          items = items.where((v) => v.categoryId == categoryId).toList();
        }

        items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return items;
      }
      return [];
    } catch (e) {
      debugPrint('Error loading videos: $e');
      return [];
    }
  }

  @override
  Future<DuaVideoItem?> getVideoById(String id) async {
    try {
      final response = await _apiClient.get(ApiConstants.videoDetail(id));
      if (response['success'] == true && response['data'] != null) {
        return DuaVideoItem.fromJson(
          Map<String, dynamic>.from(response['data']),
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error loading video by id ($id): $e');
      return null;
    }
  }
}

