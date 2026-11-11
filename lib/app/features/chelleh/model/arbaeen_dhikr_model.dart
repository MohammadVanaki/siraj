class ArbaeenDhikrModel {
  final String id;
  final String titleArabic;
  final String bodyArabic;
  final int repetitionCount;
  final int sortOrder;
  final bool published;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ArbaeenDhikrModel({
    required this.id,
    required this.titleArabic,
    required this.bodyArabic,
    required this.repetitionCount,
    this.sortOrder = 0,
    this.published = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ArbaeenDhikrModel.fromJson(Map<String, dynamic> json) {
    return ArbaeenDhikrModel(
      id: json['id']?.toString() ?? '',
      titleArabic: json['titleArabic']?.toString() ?? '',
      bodyArabic: json['bodyArabic']?.toString() ?? '',
      repetitionCount: (json['repetitionCount'] as num?)?.toInt() ?? 1,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      published: json['published'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleArabic': titleArabic,
      'bodyArabic': bodyArabic,
      'repetitionCount': repetitionCount,
      'sortOrder': sortOrder,
      'published': published,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Whether this item is a long reading recitation (Surah, Dua, Ziyarah)
  bool get isDuaOrSurah {
    final t = titleArabic.trim().toLowerCase();
    if (t.startsWith('سورة') ||
        t.startsWith('سوره') ||
        t.startsWith('دعاء') ||
        t.startsWith('دعا') ||
        t.startsWith('زيارة') ||
        t.startsWith('زیارت')) {
      return true;
    }
    if (bodyArabic.trim().length > 100) {
      return true;
    }
    return false;
  }

  /// Whether this item is a repetitive Dhikr (like Salawat, Istighfar)
  bool get isDhikr => !isDuaOrSurah;
}
