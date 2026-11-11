import 'package:mawsueat/app/features/gallery/data/models/gallery_category_model.dart';
import 'package:mawsueat/app/features/gallery/data/models/gallery_item_model.dart';

abstract class GalleryRepository {
  /// دریافت لیست دسته‌بندی‌های گالری
  Future<List<GalleryCategoryModel>> getCategories();

  /// دریافت لیست آلبوم‌های تصاویر (با امکان فیلتر بر اساس دسته‌بندی و صفحه)
  Future<List<GalleryItemModel>> getImages({
    String? categoryId,
    int page = 1,
    int limit = 20,
    String? searchQuery,
  });

  /// دریافت جزئیات یک آلبوم و لیست عکس‌های داخل آن
  Future<GalleryItemModel?> getAlbumDetail(String albumId);

  /// تغییر وضعیت لایک / علاقه‌مندی
  Future<bool> toggleFavorite(String imageId);

  /// بررسی وضعیت علاقه‌مندی
  bool isFavorite(String imageId);
}

