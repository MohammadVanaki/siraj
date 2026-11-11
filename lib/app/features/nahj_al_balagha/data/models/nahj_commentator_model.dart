class NahjCommentatorModel {
  final String id;
  final String nameArabic;
  final String namePersian;
  final String language;
  final int sortOrder;
  final bool enabled;

  const NahjCommentatorModel({
    required this.id,
    required this.nameArabic,
    required this.namePersian,
    this.language = 'ar',
    this.sortOrder = 0,
    this.enabled = true,
  });

  factory NahjCommentatorModel.fromJson(Map<String, dynamic> json) {
    return NahjCommentatorModel(
      id: json['id']?.toString() ?? '',
      nameArabic: json['nameArabic']?.toString() ?? '',
      namePersian: json['namePersian']?.toString() ?? '',
      language: json['language']?.toString() ?? 'ar',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      enabled: json['enabled'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameArabic': nameArabic,
      'namePersian': namePersian,
      'language': language,
      'sortOrder': sortOrder,
      'enabled': enabled,
    };
  }
}
