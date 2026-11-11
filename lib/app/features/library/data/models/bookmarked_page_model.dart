class BookmarkedPageModel {
  final int bookId;
  final String bookTitle;
  final String bookAuthor;
  final String bookCoverUrl;
  final int pageNumber;
  final String chapterTitle;
  final String snippet;
  final String? localDbPath;
  final DateTime createdAt;

  const BookmarkedPageModel({
    required this.bookId,
    required this.bookTitle,
    this.bookAuthor = '',
    this.bookCoverUrl = '',
    required this.pageNumber,
    this.chapterTitle = '',
    this.snippet = '',
    this.localDbPath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookAuthor': bookAuthor,
      'bookCoverUrl': bookCoverUrl,
      'pageNumber': pageNumber,
      'chapterTitle': chapterTitle,
      'snippet': snippet,
      'localDbPath': localDbPath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BookmarkedPageModel.fromMap(Map<String, dynamic> map) {
    return BookmarkedPageModel(
      bookId: map['bookId'] as int? ?? 0,
      bookTitle: map['bookTitle']?.toString() ?? '',
      bookAuthor: map['bookAuthor']?.toString() ?? '',
      bookCoverUrl: map['bookCoverUrl']?.toString() ?? '',
      pageNumber: map['pageNumber'] as int? ?? 1,
      chapterTitle: map['chapterTitle']?.toString() ?? '',
      snippet: map['snippet']?.toString() ?? '',
      localDbPath: map['localDbPath']?.toString(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  BookmarkedPageModel copyWith({
    int? bookId,
    String? bookTitle,
    String? bookAuthor,
    String? bookCoverUrl,
    int? pageNumber,
    String? chapterTitle,
    String? snippet,
    String? localDbPath,
    DateTime? createdAt,
  }) {
    return BookmarkedPageModel(
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      bookAuthor: bookAuthor ?? this.bookAuthor,
      bookCoverUrl: bookCoverUrl ?? this.bookCoverUrl,
      pageNumber: pageNumber ?? this.pageNumber,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      snippet: snippet ?? this.snippet,
      localDbPath: localDbPath ?? this.localDbPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
