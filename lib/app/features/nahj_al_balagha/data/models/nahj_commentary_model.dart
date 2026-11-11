class NahjCommentaryModel {
  final String id;
  final String entryId;
  final String commentatorId;
  final String? commentatorNameArabic;
  final String? commentatorNamePersian;
  final String language;
  final String? category;
  final int? itemNumber;
  final String? titleArabic;
  final String? titlePersian;
  final bool published;
  final int? sourceArticleId;
  final String? excerptArabic;
  final String? excerptPersian;
  final String? bodyArabic;
  final String? bodyPersian;

  const NahjCommentaryModel({
    required this.id,
    required this.entryId,
    required this.commentatorId,
    this.commentatorNameArabic,
    this.commentatorNamePersian,
    this.language = 'ar',
    this.category,
    this.itemNumber,
    this.titleArabic,
    this.titlePersian,
    this.published = true,
    this.sourceArticleId,
    this.excerptArabic,
    this.excerptPersian,
    this.bodyArabic,
    this.bodyPersian,
  });

  factory NahjCommentaryModel.fromJson(Map<String, dynamic> json) {
    return NahjCommentaryModel(
      id: json['id']?.toString() ?? '',
      entryId: json['entryId']?.toString() ?? '',
      commentatorId: json['commentatorId']?.toString() ?? '',
      commentatorNameArabic: json['commentatorNameArabic']?.toString(),
      commentatorNamePersian: json['commentatorNamePersian']?.toString(),
      language: json['language']?.toString() ?? 'ar',
      category: json['category']?.toString(),
      itemNumber: (json['itemNumber'] as num?)?.toInt(),
      titleArabic: json['titleArabic']?.toString(),
      titlePersian: json['titlePersian']?.toString(),
      published: json['published'] == true,
      sourceArticleId: (json['sourceArticleId'] as num?)?.toInt(),
      excerptArabic: json['excerptArabic']?.toString(),
      excerptPersian: json['excerptPersian']?.toString(),
      bodyArabic: json['bodyArabic']?.toString(),
      bodyPersian: json['bodyPersian']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entryId': entryId,
      'commentatorId': commentatorId,
      'commentatorNameArabic': commentatorNameArabic,
      'commentatorNamePersian': commentatorNamePersian,
      'language': language,
      'category': category,
      'itemNumber': itemNumber,
      'titleArabic': titleArabic,
      'titlePersian': titlePersian,
      'published': published,
      'sourceArticleId': sourceArticleId,
      'excerptArabic': excerptArabic,
      'excerptPersian': excerptPersian,
      'bodyArabic': bodyArabic,
      'bodyPersian': bodyPersian,
    };
  }
}
