class BookEntryModel {
  final int id;
  final int bookId;
  final String? bookTitle;
  final int groupId;
  final String title;
  final String excerpt;
  final String text;
  final int? previousEntryId;
  final int? nextEntryId;

  const BookEntryModel({
    required this.id,
    required this.bookId,
    this.bookTitle,
    this.groupId = 0,
    required this.title,
    this.excerpt = '',
    this.text = '',
    this.previousEntryId,
    this.nextEntryId,
  });

  factory BookEntryModel.fromJson(Map<String, dynamic> json) {
    return BookEntryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      bookId: json['bookId'] is int
          ? json['bookId']
          : int.tryParse(json['bookId']?.toString() ?? json['book_id']?.toString() ?? '0') ?? 0,
      bookTitle: json['bookTitle']?.toString() ?? json['book_title']?.toString(),
      groupId: json['groupId'] is int
          ? json['groupId']
          : int.tryParse(json['groupId']?.toString() ?? json['group_id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? '',
      excerpt: json['excerpt'] ?? '',
      text: json['text'] ?? '',
      previousEntryId: json['previousEntryId'] is int
          ? json['previousEntryId']
          : int.tryParse(json['previousEntryId']?.toString() ?? ''),
      nextEntryId: json['nextEntryId'] is int
          ? json['nextEntryId']
          : int.tryParse(json['nextEntryId']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'groupId': groupId,
      'title': title,
      'excerpt': excerpt,
      'text': text,
      'previousEntryId': previousEntryId,
      'nextEntryId': nextEntryId,
    };
  }
}

