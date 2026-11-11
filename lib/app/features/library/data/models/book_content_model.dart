class BookPageModel {
  final int id;
  final int pageNumber;
  final String text;
  final bool isFavorite;

  const BookPageModel({
    required this.id,
    required this.pageNumber,
    required this.text,
    this.isFavorite = false,
  });

  factory BookPageModel.fromMap(Map<String, dynamic> map) {
    final pageRaw = map['page'];
    int pageNum = 1;
    if (pageRaw is int) {
      pageNum = pageRaw;
    } else if (pageRaw is String) {
      pageNum = int.tryParse(pageRaw.trim()) ?? 1;
    }

    return BookPageModel(
      id: map['id'] as int? ?? 0,
      pageNumber: pageNum,
      text: (map['_text'] ?? map['text'] ?? '').toString(),
      isFavorite: (map['fav'] as int? ?? 0) == 1,
    );
  }

  BookPageModel copyWith({
    int? id,
    int? pageNumber,
    String? text,
    bool? isFavorite,
  }) {
    return BookPageModel(
      id: id ?? this.id,
      pageNumber: pageNumber ?? this.pageNumber,
      text: text ?? this.text,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class BookChapterModel {
  final int id;
  final int bid;
  final int pageNumber;
  final String title;

  const BookChapterModel({
    required this.id,
    required this.bid,
    required this.pageNumber,
    required this.title,
  });

  factory BookChapterModel.fromMap(Map<String, dynamic> map) {
    final pageRaw = map['page'];
    int pageNum = 1;
    if (pageRaw is int) {
      pageNum = pageRaw;
    } else if (pageRaw is String) {
      pageNum = int.tryParse(pageRaw.trim()) ?? 1;
    }

    return BookChapterModel(
      id: map['id'] as int? ?? 0,
      bid: map['bid'] as int? ?? 0,
      pageNumber: pageNum,
      title: (map['title'] ?? '').toString().trim(),
    );
  }
}

class BookSearchResultModel {
  final int pageNumber;
  final String chapterTitle;
  final String snippet;
  final int matchCount;

  const BookSearchResultModel({
    required this.pageNumber,
    required this.chapterTitle,
    required this.snippet,
    this.matchCount = 1,
  });
}
