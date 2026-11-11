class BookModel {
  final int id;
  final String title;
  final String author;
  final int categoryId;
  final String categoryName;
  final String coverUrl;
  final String pdfUrl;
  final String description;
  final int totalPages;
  final int entriesCount;
  final int fileSizeBytes;
  final String? publishedYear;
  final double rating;
  final int reviewsCount;

  // Client/Local state properties
  final double? userRating;
  final bool isDownloaded;
  final bool isFavorite;
  final String? localPath;
  final int lastReadPage;
  final DateTime? lastReadTimestamp;

  const BookModel({
    required this.id,
    required this.title,
    this.author = '',
    this.categoryId = 1,
    this.categoryName = 'موسوعة أهل البيت',
    this.coverUrl = '',
    this.pdfUrl = '',
    this.description = '',
    this.totalPages = 1,
    this.entriesCount = 0,
    this.fileSizeBytes = 0,
    this.publishedYear,
    this.rating = 5.0,
    this.reviewsCount = 0,
    this.userRating,
    this.isDownloaded = false,
    this.isFavorite = false,
    this.localPath,
    this.lastReadPage = 0,
    this.lastReadTimestamp,
  });

  /// نمایش تعداد مدخل‌ها / صفحات
  int get displayEntriesCount => entriesCount > 0 ? entriesCount : totalPages;

  /// درصد مطالعه کتاب بین 0.0 تا 1.0
  double get readProgress {
    if (totalPages <= 0) return 0.0;
    if (lastReadPage <= 0) return 0.0;
    final progress = lastReadPage / totalPages;
    return progress > 1.0 ? 1.0 : progress;
  }

  /// درصد مطالعه به صورت عدد صحیح بین 0 تا 100
  int get readProgressPercent => (readProgress * 100).toInt();

  /// آیا کاربر خواندن این کتاب را شروع کرده است؟
  bool get hasStartedReading => lastReadPage > 0;

  /// حجم فایل با فرمت خوانا (MB یا KB)
  String get formattedFileSize {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      final kb = (fileSizeBytes / 1024).toStringAsFixed(1);
      return '$kb KB';
    } else {
      final mb = (fileSizeBytes / (1024 * 1024)).toStringAsFixed(1);
      return '$mb MB';
    }
  }

  BookModel copyWith({
    int? id,
    String? title,
    String? author,
    int? categoryId,
    String? categoryName,
    String? coverUrl,
    String? pdfUrl,
    String? description,
    int? totalPages,
    int? entriesCount,
    int? fileSizeBytes,
    String? publishedYear,
    double? rating,
    int? reviewsCount,
    double? userRating,
    bool? isDownloaded,
    bool? isFavorite,
    String? localPath,
    int? lastReadPage,
    DateTime? lastReadTimestamp,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      coverUrl: coverUrl ?? this.coverUrl,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      description: description ?? this.description,
      totalPages: totalPages ?? this.totalPages,
      entriesCount: entriesCount ?? this.entriesCount,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      publishedYear: publishedYear ?? this.publishedYear,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      userRating: userRating ?? this.userRating,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isFavorite: isFavorite ?? this.isFavorite,
      localPath: localPath ?? this.localPath,
      lastReadPage: lastReadPage ?? this.lastReadPage,
      lastReadTimestamp: lastReadTimestamp ?? this.lastReadTimestamp,
    );
  }

  factory BookModel.fromJson(Map<String, dynamic> json) {
    // 1. تعداد صفحات یا مدخل‌ها
    final rawEntries = json['number_pages'] ??
        json['entriesCount'] ??
        json['entries_count'] ??
        json['total_pages'] ??
        json['totalPages'] ??
        0;
    final int parsedEntries = rawEntries is int
        ? rawEntries
        : int.tryParse(rawEntries.toString()) ?? 0;

    // 2. نام نویسنده / مؤلف
    final rawAuthor = json['writer_name'] ??
        json['author'] ??
        json['scholar_name'];
    final String author = (rawAuthor != null && rawAuthor.toString().trim().isNotEmpty)
        ? rawAuthor.toString().trim()
        : '';

    // 3. دسته‌بندی
    int categoryId = 1;
    String categoryName = 'عام';

    if (json['category'] is Map<String, dynamic>) {
      final cat = json['category'] as Map<String, dynamic>;
      categoryId = cat['id'] is int
          ? cat['id']
          : int.tryParse(cat['id']?.toString() ?? '1') ?? 1;
      categoryName = cat['title']?.toString() ?? 'عام';
    } else {
      if (json['category_id'] != null) {
        categoryId = json['category_id'] is int
            ? json['category_id']
            : int.tryParse(json['category_id'].toString()) ?? 1;
      }
      if (json['category_name'] != null || json['categoryName'] != null) {
        categoryName = (json['category_name'] ?? json['categoryName']).toString();
      }
    }

    // 4. تصویر کاور
    final cover = json['photo_url'] ??
        json['cover_url'] ??
        json['coverUrl'] ??
        '';

    // 5. فایل دانلود / پی‌دی‌اف
    final pdf = json['pdf_link'] ??
        json['pdf_url'] ??
        json['pdfUrl'] ??
        '';

    final totalPages = parsedEntries > 0
        ? parsedEntries
        : (json['number_pages'] is int
            ? json['number_pages']
            : int.tryParse(json['number_pages']?.toString() ?? '1') ?? 1);

    return BookModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      author: author,
      categoryId: categoryId,
      categoryName: categoryName,
      coverUrl: cover.toString(),
      pdfUrl: pdf.toString(),
      description: json['description']?.toString() ?? '',
      totalPages: totalPages > 0 ? totalPages : 1,
      entriesCount: parsedEntries,
      fileSizeBytes: json['file_size_bytes'] is int
          ? json['file_size_bytes']
          : int.tryParse(json['file_size_bytes']?.toString() ?? '0') ?? 0,
      publishedYear: json['published_year']?.toString(),
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 5.0,
      reviewsCount: json['reviews_count'] is int
          ? json['reviews_count']
          : int.tryParse(json['reviews_count']?.toString() ?? '0') ?? 0,
      userRating: (json['user_rating'] is num)
          ? (json['user_rating'] as num).toDouble()
          : null,
      isDownloaded: json['is_downloaded'] == true,
      isFavorite: json['is_favorite'] == true ||
          json['fav'] == 1 ||
          json['fav'] == true,
      localPath: json['local_path'],
      lastReadPage: json['last_read_page'] is int
          ? json['last_read_page']
          : int.tryParse(json['last_read_page']?.toString() ?? '0') ?? 0,
      lastReadTimestamp: json['last_read_timestamp'] != null
          ? DateTime.tryParse(json['last_read_timestamp'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'category_id': categoryId,
      'category_name': categoryName,
      'cover_url': coverUrl,
      'pdf_url': pdfUrl,
      'description': description,
      'total_pages': totalPages,
      'entriesCount': entriesCount,
      'file_size_bytes': fileSizeBytes,
      'published_year': publishedYear,
      'rating': rating,
      'reviews_count': reviewsCount,
      'user_rating': userRating,
      'is_downloaded': isDownloaded,
      'is_favorite': isFavorite,
      'local_path': localPath,
      'last_read_page': lastReadPage,
      'last_read_timestamp': lastReadTimestamp?.toIso8601String(),
    };
  }
}

