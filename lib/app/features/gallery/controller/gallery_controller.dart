import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/gallery/data/models/gallery_category_model.dart';
import 'package:mawsueat/app/features/gallery/data/models/gallery_item_model.dart';
import 'package:mawsueat/app/features/gallery/data/repositories/gallery_repository.dart';
import 'package:share_plus/share_plus.dart';

class GalleryController extends GetxController {
  final GalleryRepository _repository;
  GalleryController(this._repository);

  // Observables
  final categories = <GalleryCategoryModel>[].obs;
  final selectedCategoryId = ''.obs; // '' means all
  final images = <GalleryItemModel>[].obs;
  final isLoadingCategories = false.obs;
  final isLoadingImages = false.obs;
  final searchQuery = ''.obs;
  final isSearching = false.obs;

  final TextEditingController searchTextController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadCategoriesAndImages();
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

  Future<void> loadCategoriesAndImages() async {
    isLoadingCategories.value = true;
    isLoadingImages.value = true;
    try {
      final fetchedCategories = await _repository.getCategories();
      final allCategory = GalleryCategoryModel(
        id: '',
        title: 'الكل',
        count: null,
      );

      final fullCategories = [
        allCategory,
        ...fetchedCategories.where((c) => c.id.isNotEmpty),
      ];

      categories.assignAll(fullCategories);
      await fetchImages();
    } catch (e) {
      debugPrint('Error loading gallery initial data: $e');
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> fetchImages() async {
    isLoadingImages.value = true;
    try {
      final result = await _repository.getImages(
        categoryId: selectedCategoryId.value,
        searchQuery: searchQuery.value,
      );
      images.assignAll(result);
    } catch (e) {
      debugPrint('Error fetching gallery images: $e');
    } finally {
      isLoadingImages.value = false;
    }
  }

  void selectCategory(String categoryId) {
    if (selectedCategoryId.value == categoryId) return;
    selectedCategoryId.value = categoryId;
    fetchImages();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    fetchImages();
  }

  void toggleSearchMode() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchTextController.clear();
      searchQuery.value = '';
      fetchImages();
    }
  }

  Future<GalleryItemModel?> loadAlbumDetail(String albumId) async {
    try {
      final detailedItem = await _repository.getAlbumDetail(albumId);
      if (detailedItem != null) {
        final index = images.indexWhere((element) => element.id == albumId);
        if (index != -1) {
          images[index] = detailedItem;
        }
        return detailedItem;
      }
    } catch (e) {
      debugPrint('Error loading album details ($albumId): $e');
    }
    return null;
  }

  Future<void> toggleFavorite(GalleryItemModel item) async {
    final index = images.indexWhere((element) => element.id == item.id);
    if (index == -1) return;

    final currentFav = item.isFavorite;
    // Optimistic UI update
    images[index] = item.copyWith(
      isFavorite: !currentFav,
      likesCount: currentFav ? (item.likesCount > 0 ? item.likesCount - 1 : 0) : item.likesCount + 1,
    );
    HapticFeedback.lightImpact();

    try {
      final serverFav = await _repository.toggleFavorite(item.id);
      if (images[index].isFavorite != serverFav) {
        images[index] = images[index].copyWith(isFavorite: serverFav);
      }
    } catch (e) {
      // Revert if failed
      images[index] = item;
      Get.rawSnackbar(
        message: 'تعذر تحديث المفضلة',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void shareImage(GalleryItemModel item) {
    final text = '''
🖼️ ${item.title}
${item.subtitle != null ? '📌 ${item.subtitle}\n' : ''}
🔗 ${item.imageUrl}

تطبيق السراج - نورٌ وقربٌ وسكينة
''';
    Share.share(text, subject: item.title);
  }

  void copyImageUrl(GalleryItemModel item) {
    Clipboard.setData(ClipboardData(text: item.imageUrl));
    Get.rawSnackbar(
      message: 'تم نسخ رابط الصورة إلى الحافظة',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }
}
