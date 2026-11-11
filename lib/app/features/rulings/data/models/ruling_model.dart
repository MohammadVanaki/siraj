class RulingModel {
  final int id;
  final String title;
  final String question;
  final String answer;
  final int marjaId;
  final String marjaName;
  final int categoryId;
  final String categoryTitle;
  final String? rulingNumber;
  final bool isFavorite;
  final DateTime? createdAt;

  RulingModel({
    required this.id,
    required this.title,
    required this.question,
    required this.answer,
    required this.marjaId,
    required this.marjaName,
    required this.categoryId,
    required this.categoryTitle,
    this.rulingNumber,
    this.isFavorite = false,
    this.createdAt,
  });

  factory RulingModel.fromJson(Map<String, dynamic> json) {
    return RulingModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? '',
      question: json['question'] ?? json['q'] ?? '',
      answer: json['answer'] ?? json['a'] ?? '',
      marjaId: json['marja_id'] is int ? json['marja_id'] : int.tryParse(json['marja_id']?.toString() ?? '1') ?? 1,
      marjaName: json['marja_name'] ?? '',
      categoryId: json['category_id'] is int ? json['category_id'] : int.tryParse(json['category_id']?.toString() ?? '1') ?? 1,
      categoryTitle: json['category_title'] ?? '',
      rulingNumber: json['ruling_number'] ?? json['code'],
      isFavorite: json['is_favorite'] == true || json['is_favorite'] == 1,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'question': question,
      'answer': answer,
      'marja_id': marjaId,
      'marja_name': marjaName,
      'category_id': categoryId,
      'category_title': categoryTitle,
      'ruling_number': rulingNumber,
      'is_favorite': isFavorite,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  RulingModel copyWith({
    int? id,
    String? title,
    String? question,
    String? answer,
    int? marjaId,
    String? marjaName,
    int? categoryId,
    String? categoryTitle,
    String? rulingNumber,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return RulingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      marjaId: marjaId ?? this.marjaId,
      marjaName: marjaName ?? this.marjaName,
      categoryId: categoryId ?? this.categoryId,
      categoryTitle: categoryTitle ?? this.categoryTitle,
      rulingNumber: rulingNumber ?? this.rulingNumber,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
