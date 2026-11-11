class BookCategoryModel {
  final int id;
  final String title;
  final String? icon;
  final int booksCount;

  const BookCategoryModel({
    required this.id,
    required this.title,
    this.icon,
    this.booksCount = 0,
  });

  factory BookCategoryModel.fromJson(Map<String, dynamic> json) {
    return BookCategoryModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      icon: json['icon'],
      booksCount: json['books_count'] is int
          ? json['books_count']
          : int.tryParse(json['books_count']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'icon': icon, 'books_count': booksCount};
  }
}
