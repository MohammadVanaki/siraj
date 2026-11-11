class GalleryImageModel {
  final String id;
  final String albumId;
  final String? mediaAssetId;
  final String imageUrl;
  final String? captionArabic;
  final int sortOrder;
  final DateTime? createdAt;

  GalleryImageModel({
    required this.id,
    required this.albumId,
    this.mediaAssetId,
    required this.imageUrl,
    this.captionArabic,
    this.sortOrder = 0,
    this.createdAt,
  });

  factory GalleryImageModel.fromJson(Map<String, dynamic> json) {
    return GalleryImageModel(
      id: json['id']?.toString() ?? '',
      albumId: json['albumId']?.toString() ?? '',
      mediaAssetId: json['mediaAssetId']?.toString(),
      imageUrl: json['imageUrl'] ??
          json['image_url'] ??
          json['url'] ??
          json['mediaUrl'] ??
          json['streamUrl'] ??
          json['coverUrl'] ??
          '',
      captionArabic: json['captionArabic'] ?? json['caption'] ?? json['title'],
      sortOrder: json['sortOrder'] is int
          ? json['sortOrder']
          : int.tryParse(json['sortOrder']?.toString() ?? '0') ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'albumId': albumId,
      'media_asset_id': mediaAssetId,
      'imageUrl': imageUrl,
      'captionArabic': captionArabic,
      'sortOrder': sortOrder,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

class GalleryItemModel {
  final String id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String? thumbnailUrl;
  final String? categoryId;
  final String? categoryTitle;
  final String? coverAssetId;
  final int imageCount;
  final int viewsCount;
  final int likesCount;
  final int sortOrder;
  final bool published;
  final bool isFavorite;
  final DateTime? createdAt;
  final List<GalleryImageModel> images;

  GalleryItemModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    this.thumbnailUrl,
    this.categoryId,
    this.categoryTitle,
    this.coverAssetId,
    this.imageCount = 1,
    this.viewsCount = 0,
    this.likesCount = 0,
    this.sortOrder = 0,
    this.published = true,
    this.isFavorite = false,
    this.createdAt,
    this.images = const [],
  });

  factory GalleryItemModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'] as List? ??
        json['photos'] as List? ??
        json['media'] as List? ??
        json['items'] as List?;

    final imagesList = (rawImages
            ?.map((e) => GalleryImageModel.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [])
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final mainImage = json['coverUrl'] ??
        json['image_url'] ??
        json['imageUrl'] ??
        json['url'] ??
        (imagesList.isNotEmpty ? imagesList.first.imageUrl : '');

    return GalleryItemModel(
      id: json['id']?.toString() ?? '',
      title: json['titleArabic'] ?? json['title'] ?? '',
      subtitle: json['descriptionArabic'] ?? json['subtitle'] ?? json['description'],
      imageUrl: mainImage,
      thumbnailUrl: json['coverUrl'] ?? json['thumbnail_url'] ?? json['thumbnailUrl'] ?? mainImage,
      categoryId: json['categoryId']?.toString() ?? json['category_id']?.toString(),
      categoryTitle: json['categoryNameArabic'] ??
          json['category_title'] ??
          json['categoryTitle'] ??
          json['category_name'],
      coverAssetId: json['coverAssetId']?.toString(),
      imageCount: json['imageCount'] is int
          ? json['imageCount']
          : int.tryParse(json['imageCount']?.toString() ?? '1') ??
              (imagesList.isNotEmpty ? imagesList.length : 1),
      viewsCount: json['views_count'] is int
          ? json['views_count']
          : int.tryParse(json['views_count']?.toString() ?? '0') ?? 0,
      likesCount: json['likes_count'] is int
          ? json['likes_count']
          : int.tryParse(json['likes_count']?.toString() ?? '0') ?? 0,
      sortOrder: json['sortOrder'] is int
          ? json['sortOrder']
          : int.tryParse(json['sortOrder']?.toString() ?? '0') ?? 0,
      published: json['published'] == null ? true : json['published'] == true,
      isFavorite: json['is_favorite'] == true || json['is_favorite'] == 1,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null),
      images: imagesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'image_url': imageUrl,
      'thumbnail_url': thumbnailUrl,
      'category_id': categoryId,
      'category_title': categoryTitle,
      'cover_asset_id': coverAssetId,
      'image_count': imageCount,
      'views_count': viewsCount,
      'likes_count': likesCount,
      'sort_order': sortOrder,
      'published': published,
      'is_favorite': isFavorite,
      'created_at': createdAt?.toIso8601String(),
      'images': images.map((e) => e.toJson()).toList(),
    };
  }

  GalleryItemModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? thumbnailUrl,
    String? categoryId,
    String? categoryTitle,
    String? coverAssetId,
    int? imageCount,
    int? viewsCount,
    int? likesCount,
    int? sortOrder,
    bool? published,
    bool? isFavorite,
    DateTime? createdAt,
    List<GalleryImageModel>? images,
  }) {
    return GalleryItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      categoryId: categoryId ?? this.categoryId,
      categoryTitle: categoryTitle ?? this.categoryTitle,
      coverAssetId: coverAssetId ?? this.coverAssetId,
      imageCount: imageCount ?? this.imageCount,
      viewsCount: viewsCount ?? this.viewsCount,
      likesCount: likesCount ?? this.likesCount,
      sortOrder: sortOrder ?? this.sortOrder,
      published: published ?? this.published,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      images: images ?? this.images,
    );
  }
}

