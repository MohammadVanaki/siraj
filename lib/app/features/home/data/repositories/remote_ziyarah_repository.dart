import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/constants/api_constants.dart';
import 'package:mawsueat/app/core/network/api_client.dart';
import 'package:mawsueat/app/features/home/data/models/virtual_ziyarat_model.dart';

class RemoteZiyarahRepository {
  ApiClient get _apiClient {
    if (Get.isRegistered<ApiClient>()) {
      return Get.find<ApiClient>();
    }
    return Get.put(ApiClient(), permanent: true);
  }

  /// دریافت لیست مکان‌های زیارت از دور
  /// GET /api/v1/remote-ziyarah/locations
  Future<List<VirtualZiyaratModel>> getLocations() async {
    try {
      final response = await _apiClient.get(ApiConstants.remoteZiyarahLocations);
      if (response['success'] == true && response['data'] is List) {
        final List list = response['data'];
        final items = list
            .map((e) => VirtualZiyaratModel.fromJson(Map<String, dynamic>.from(e)))
            .where((item) => item.enabled)
            .toList();

        items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return items;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching remote ziyarah locations: $e');
      rethrow;
    }
  }

  /// دریافت اطلاعات کامل یک مکان به همراه لیست زیارت‌ها (readings)
  /// GET /api/v1/remote-ziyarah/locations/{locationId}
  Future<VirtualZiyaratModel?> getLocationDetail(String locationId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.remoteZiyarahLocationDetail(locationId),
      );
      if (response['success'] == true && response['data'] != null) {
        return VirtualZiyaratModel.fromJson(
          Map<String, dynamic>.from(response['data']),
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching location detail for $locationId: $e');
      return null;
    }
  }

  /// دریافت متون و قرائت‌های مربوط به یک بارگاه
  /// GET /api/v1/remote-ziyarah/locations/{locationId}/readings
  Future<List<RemoteZiyarahReadingModel>> getLocationReadings(
    String locationId,
  ) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.remoteZiyarahReadings(locationId),
      );
      if (response['success'] == true && response['data'] is List) {
        final List list = response['data'];
        final items = list
            .map((e) =>
                RemoteZiyarahReadingModel.fromJson(Map<String, dynamic>.from(e)))
            .where((r) => r.published)
            .toList();

        items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return items;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching readings for $locationId: $e');
      return [];
    }
  }

  /// دریافت جزئیات یک متن زیارت خاص بر اساس شناسه
  /// GET /api/v1/remote-ziyarah/readings/{readingId}
  Future<RemoteZiyarahReadingModel?> getReadingDetail(String readingId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.remoteZiyarahReadingDetail(readingId),
      );
      if (response['success'] == true && response['data'] != null) {
        return RemoteZiyarahReadingModel.fromJson(
          Map<String, dynamic>.from(response['data']),
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching reading detail for $readingId: $e');
      return null;
    }
  }

  /// دریافت زاویه و جهت محاسبه‌شده از سرور (اختیاری)
  /// POST /api/v1/remote-ziyarah/locations/{locationId}/direction
  Future<Map<String, dynamic>?> getDirection({
    required String locationId,
    required double lat,
    required double lng,
    required double heading,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.remoteZiyarahDirection(locationId),
        body: {
          'lat': lat,
          'lng': lng,
          'heading': heading,
        },
      );
      if (response['success'] == true && response['data'] != null) {
        return Map<String, dynamic>.from(response['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching server direction for $locationId: $e');
      return null;
    }
  }
}
