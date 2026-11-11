class SahifaDuaModel {
  final String id;
  final String collection;
  final String titleArabic;
  final String bodyArabic;
  final int sortOrder;
  final bool published;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SahifaDuaModel({
    required this.id,
    required this.collection,
    required this.titleArabic,
    required this.bodyArabic,
    this.sortOrder = 0,
    this.published = true,
    this.createdAt,
    this.updatedAt,
  });

  factory SahifaDuaModel.fromJson(Map<String, dynamic> json) {
    return SahifaDuaModel(
      id: json['id'] as String? ?? '',
      collection: json['collection'] as String? ?? 'sahifa-sajjadiya',
      titleArabic: json['titleArabic'] as String? ?? '',
      bodyArabic: json['bodyArabic'] as String? ?? '',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      published: json['published'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collection': collection,
      'titleArabic': titleArabic,
      'bodyArabic': bodyArabic,
      'sortOrder': sortOrder,
      'published': published,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  SahifaDuaModel copyWith({
    String? id,
    String? collection,
    String? titleArabic,
    String? bodyArabic,
    int? sortOrder,
    bool? published,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SahifaDuaModel(
      id: id ?? this.id,
      collection: collection ?? this.collection,
      titleArabic: titleArabic ?? this.titleArabic,
      bodyArabic: bodyArabic ?? this.bodyArabic,
      sortOrder: sortOrder ?? this.sortOrder,
      published: published ?? this.published,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// لیست پاراگراف‌ها یا فرازهای دعا جدا شده با خط جدید
  List<String> get paragraphs {
    if (bodyArabic.isEmpty) return const [];
    return bodyArabic
        .split('\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
  }

  /// پیش‌نمایش خلاصه از ابتدای متن دعا
  String get previewSnippet {
    final clean = bodyArabic.replaceAll('\n', ' ').trim();
    if (clean.length <= 110) return clean;
    return '${clean.substring(0, 110)}...';
  }

  /// تبدیل عدد انگلیسی به ارقام عربی/فارسی (مثلاً 1 -> ۱)
  static String toArabicDigits(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((ch) {
          final digit = int.tryParse(ch);
          return digit != null ? arabicDigits[digit] : ch;
        })
        .join();
  }
}
