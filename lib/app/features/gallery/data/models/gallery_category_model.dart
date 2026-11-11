class GalleryCategoryModel {
  final String id;
  final String title;
  final String? description;
  final String? slug;
  final int? count;
  final int sortOrder;
  final bool enabled;

  GalleryCategoryModel({
    required this.id,
    required this.title,
    this.description,
    this.slug,
    this.count,
    this.sortOrder = 0,
    this.enabled = true,
  });

  factory GalleryCategoryModel.fromJson(Map<String, dynamic> json) {
    return GalleryCategoryModel(
      id: json['id']?.toString() ?? '',
      title: json['nameArabic'] ?? json['title'] ?? json['name'] ?? '',
      description: json['descriptionArabic'] ?? json['description'],
      slug: json['slug'],
      count: json['itemCount'] != null
          ? int.tryParse(json['itemCount'].toString())
          : (json['count'] != null ? int.tryParse(json['count'].toString()) : null),
      sortOrder: json['sortOrder'] is int
          ? json['sortOrder']
          : int.tryParse(json['sortOrder']?.toString() ?? '0') ?? 0,
      enabled: json['enabled'] == null ? true : json['enabled'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'count': count,
      'sortOrder': sortOrder,
      'enabled': enabled,
    };
  }
}

