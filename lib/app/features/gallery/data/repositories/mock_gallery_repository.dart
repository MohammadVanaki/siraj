import 'package:mawsueat/app/features/gallery/data/models/gallery_category_model.dart';
import 'package:mawsueat/app/features/gallery/data/models/gallery_item_model.dart';
import 'package:mawsueat/app/features/gallery/data/repositories/gallery_repository.dart';

class MockGalleryRepository implements GalleryRepository {
  final List<GalleryCategoryModel> _categories = [
    GalleryCategoryModel(id: '', title: 'الكل', count: 4),
    GalleryCategoryModel(id: '1', title: 'العتبات المقدسة', slug: 'shrines', count: 2),
    GalleryCategoryModel(id: '2', title: 'خلفيات ولائية', slug: 'wallpapers', count: 2),
  ];

  final List<GalleryItemModel> _allImages = [
    GalleryItemModel(
      id: '101',
      title: 'حرم الإمام الحسين (عليه السلام)',
      subtitle: 'كربلاء المقدسة - القبة الشريفة والمنارتان',
      imageUrl: 'https://images.unsplash.com/photo-1564769625905-50e93615e769?q=80&w=1200&auto=format&fit=crop',
      thumbnailUrl: 'https://images.unsplash.com/photo-1564769625905-50e93615e769?q=80&w=400&auto=format&fit=crop',
      categoryId: '1',
      categoryTitle: 'العتبات المقدسة',
      viewsCount: 1420,
      likesCount: 385,
      isFavorite: false,
    ),
    GalleryItemModel(
      id: '102',
      title: 'حرم أمير المؤمنين (عليه السلام)',
      subtitle: 'النجف الأشرف - الإيوان الذهبي والروضة الحيدرية',
      imageUrl: 'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?q=80&w=1200&auto=format&fit=crop',
      thumbnailUrl: 'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?q=80&w=400&auto=format&fit=crop',
      categoryId: '1',
      categoryTitle: 'العتبات المقدسة',
      viewsCount: 2150,
      likesCount: 520,
      isFavorite: true,
    ),
    GalleryItemModel(
      id: '103',
      title: 'خلفية إسلامية مذهبة',
      subtitle: 'زخارف هندسية إسلامية ذات طابع روحي',
      imageUrl: 'https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?q=80&w=1200&auto=format&fit=crop',
      thumbnailUrl: 'https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?q=80&w=400&auto=format&fit=crop',
      categoryId: '2',
      categoryTitle: 'خلفيات ولائية',
      viewsCount: 980,
      likesCount: 210,
      isFavorite: false,
    ),
    GalleryItemModel(
      id: '104',
      title: 'حرم الإمام الرضا (عليه السلام)',
      subtitle: 'مشهد المقدسة - صحن الثورة الإسلامية',
      imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=1200&auto=format&fit=crop',
      thumbnailUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=400&auto=format&fit=crop',
      categoryId: '2',
      categoryTitle: 'خلفيات ولائية',
      viewsCount: 3100,
      likesCount: 780,
      isFavorite: false,
    ),
  ];

  @override
  bool isFavorite(String imageId) {
    final item = _allImages.firstWhere(
      (element) => element.id == imageId,
      orElse: () => _allImages.first,
    );
    return item.isFavorite;
  }

  @override
  Future<List<GalleryCategoryModel>> getCategories() async {
    return _categories;
  }

  @override
  Future<List<GalleryItemModel>> getImages({
    String? categoryId,
    int page = 1,
    int limit = 20,
    String? searchQuery,
  }) async {
    var filtered = List<GalleryItemModel>.from(_allImages);

    if (categoryId != null && categoryId.isNotEmpty && categoryId != '0') {
      filtered = filtered.where((item) => item.categoryId == categoryId).toList();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      filtered = filtered.where((item) {
        final title = item.title.toLowerCase();
        final subtitle = item.subtitle?.toLowerCase() ?? '';
        return title.contains(query) || subtitle.contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Future<GalleryItemModel?> getAlbumDetail(String albumId) async {
    try {
      return _allImages.firstWhere((item) => item.id == albumId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> toggleFavorite(String imageId) async {
    final index = _allImages.indexWhere((item) => item.id == imageId);
    if (index != -1) {
      final item = _allImages[index];
      _allImages[index] = item.copyWith(
        isFavorite: !item.isFavorite,
        likesCount: item.isFavorite ? item.likesCount - 1 : item.likesCount + 1,
      );
      return _allImages[index].isFavorite;
    }
    return false;
  }
}
