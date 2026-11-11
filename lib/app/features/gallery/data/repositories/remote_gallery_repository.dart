import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/constants/constants.dart';
import 'package:mawsueat/app/core/common/constants/api_constants.dart';
import 'package:mawsueat/app/core/network/api_client.dart';
import 'package:mawsueat/app/features/gallery/data/models/gallery_category_model.dart';
import 'package:mawsueat/app/features/gallery/data/models/gallery_item_model.dart';
import 'package:mawsueat/app/features/gallery/data/repositories/gallery_repository.dart';

class RemoteGalleryRepository implements GalleryRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();
  static const String _keyFavorites = 'favorite_gallery_albums';

  List<String> _getFavoriteIds() {
    try {
      final list = Constants.localStorage.read<List>(_keyFavorites);
      if (list != null) {
        return list.map((e) => e.toString()).toList();
      }
    } catch (e) {
      debugPrint('Error reading favorite gallery items: $e');
    }
    return [];
  }

  @override
  bool isFavorite(String imageId) {
    return _getFavoriteIds().contains(imageId);
  }

  @override
  Future<List<GalleryCategoryModel>> getCategories() async {
    try {
      final response = await _apiClient.get(ApiConstants.photoAlbumsCategories);
      if (response['success'] == true && response['data'] is List) {
        final List list = response['data'];
        final items = list
            .map((e) => GalleryCategoryModel.fromJson(Map<String, dynamic>.from(e)))
            .where((c) => c.enabled)
            .toList();

        items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return items;
      }
      return [];
    } catch (e) {
      debugPrint('Error loading gallery categories: $e');
      throw Exception('فشل في جلب أقسام المعرض: $e');
    }
  }

  @override
  Future<List<GalleryItemModel>> getImages({
    String? categoryId,
    int page = 1,
    int limit = 20,
    String? searchQuery,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (categoryId != null &&
          categoryId.isNotEmpty &&
          categoryId != '0' &&
          categoryId.toLowerCase() != 'all') {
        queryParams['categoryId'] = categoryId;
      }

      final response = await _apiClient.get(
        ApiConstants.photoAlbums,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response['success'] == true && response['data'] is List) {
        final List list = response['data'];
        final favIds = _getFavoriteIds();

        var items = list
            .map((e) {
              final model = GalleryItemModel.fromJson(Map<String, dynamic>.from(e));
              return model.copyWith(isFavorite: favIds.contains(model.id));
            })
            .where((item) => item.published)
            .toList();

        items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

        // Local search filter if provided
        if (searchQuery != null && searchQuery.trim().isNotEmpty) {
          final query = searchQuery.trim().toLowerCase();
          items = items.where((item) {
            final matchTitle = item.title.toLowerCase().contains(query);
            final matchSub = item.subtitle?.toLowerCase().contains(query) ?? false;
            final matchCat = item.categoryTitle?.toLowerCase().contains(query) ?? false;
            return matchTitle || matchSub || matchCat;
          }).toList();
        }

        return items;
      }
      return [];
    } catch (e) {
      debugPrint('Error loading gallery albums: $e');
      throw Exception('فشل في جلب صور المعرض: $e');
    }
  }

  @override
  Future<GalleryItemModel?> getAlbumDetail(String albumId) async {
    try {
      final response = await _apiClient.get(ApiConstants.photoAlbumDetail(albumId));
      if (response['success'] == true && response['data'] != null) {
        final model = GalleryItemModel.fromJson(
          Map<String, dynamic>.from(response['data']),
        );
        return model.copyWith(isFavorite: isFavorite(albumId));
      }
      return null;
    } catch (e) {
      debugPrint('Error loading album detail ($albumId): $e');
      return null;
    }
  }

  @override
  Future<bool> toggleFavorite(String imageId) async {
    try {
      final list = _getFavoriteIds();
      final isFav = list.contains(imageId);
      if (isFav) {
        list.remove(imageId);
      } else {
        list.add(imageId);
      }
      await Constants.localStorage.write(_keyFavorites, list);
      return !isFav;
    } catch (e) {
      debugPrint('Error updating favorite for $imageId: $e');
      throw Exception('فشل في تحديث المفضلة: $e');
    }
  }
}
