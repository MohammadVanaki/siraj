import 'nahj_commentary_model.dart';

class NahjEntryModel {
  final String id;
  final String category;
  final int itemNumber;
  final String titleArabic;
  final String? titlePersian;
  final int sortOrder;
  final bool published;
  final int? sourceArticleId;
  final String? excerptArabic;
  final String? excerptPersian;
  final String? bodyArabic;
  final String? bodyPersian;
  final List<NahjCommentaryModel> commentaries;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NahjEntryModel({
    required this.id,
    required this.category,
    required this.itemNumber,
    required this.titleArabic,
    this.titlePersian,
    this.sortOrder = 0,
    this.published = true,
    this.sourceArticleId,
    this.excerptArabic,
    this.excerptPersian,
    this.bodyArabic,
    this.bodyPersian,
    this.commentaries = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory NahjEntryModel.fromJson(Map<String, dynamic> json) {
    var rawCommentaries = json['commentaries'];
    List<NahjCommentaryModel> commentaryList = [];
    if (rawCommentaries is List) {
      commentaryList = rawCommentaries
          .map((e) => NahjCommentaryModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return NahjEntryModel(
      id: json['id']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      itemNumber: (json['itemNumber'] as num?)?.toInt() ?? 0,
      titleArabic: json['titleArabic']?.toString() ?? '',
      titlePersian: json['titlePersian']?.toString(),
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      published: json['published'] == true,
      sourceArticleId: (json['sourceArticleId'] as num?)?.toInt(),
      excerptArabic: json['excerptArabic']?.toString(),
      excerptPersian: json['excerptPersian']?.toString(),
      bodyArabic: json['bodyArabic']?.toString(),
      bodyPersian: json['bodyPersian']?.toString(),
      commentaries: commentaryList,
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
      'category': category,
      'itemNumber': itemNumber,
      'titleArabic': titleArabic,
      'titlePersian': titlePersian,
      'sortOrder': sortOrder,
      'published': published,
      'sourceArticleId': sourceArticleId,
      'excerptArabic': excerptArabic,
      'excerptPersian': excerptPersian,
      'bodyArabic': bodyArabic,
      'bodyPersian': bodyPersian,
      'commentaries': commentaries.map((e) => e.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  NahjEntryModel copyWith({
    String? id,
    String? category,
    int? itemNumber,
    String? titleArabic,
    String? titlePersian,
    int? sortOrder,
    bool? published,
    int? sourceArticleId,
    String? excerptArabic,
    String? excerptPersian,
    String? bodyArabic,
    String? bodyPersian,
    List<NahjCommentaryModel>? commentaries,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NahjEntryModel(
      id: id ?? this.id,
      category: category ?? this.category,
      itemNumber: itemNumber ?? this.itemNumber,
      titleArabic: titleArabic ?? this.titleArabic,
      titlePersian: titlePersian ?? this.titlePersian,
      sortOrder: sortOrder ?? this.sortOrder,
      published: published ?? this.published,
      sourceArticleId: sourceArticleId ?? this.sourceArticleId,
      excerptArabic: excerptArabic ?? this.excerptArabic,
      excerptPersian: excerptPersian ?? this.excerptPersian,
      bodyArabic: bodyArabic ?? this.bodyArabic,
      bodyPersian: bodyPersian ?? this.bodyPersian,
      commentaries: commentaries ?? this.commentaries,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
