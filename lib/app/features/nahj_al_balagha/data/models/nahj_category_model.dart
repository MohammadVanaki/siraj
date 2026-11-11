class NahjCategoryModel {
  final String slug;
  final String titleArabic;
  final int count;

  const NahjCategoryModel({
    required this.slug,
    required this.titleArabic,
    this.count = 0,
  });

  factory NahjCategoryModel.fromJson(Map<String, dynamic> json) {
    return NahjCategoryModel(
      slug: json['slug']?.toString() ?? '',
      titleArabic: json['titleArabic']?.toString() ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'titleArabic': titleArabic,
      'count': count,
    };
  }
}
