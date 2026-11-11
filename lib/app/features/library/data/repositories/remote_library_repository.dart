import 'package:flutter/foundation.dart';
import 'package:mawsueat/app/core/common/constants/api_constants.dart';
import 'package:mawsueat/app/core/network/api_client.dart';
import 'package:mawsueat/app/features/library/data/models/book_category_model.dart';
import 'package:mawsueat/app/features/library/data/models/book_entry_model.dart';
import 'package:mawsueat/app/features/library/data/models/book_model.dart';
import 'package:mawsueat/app/features/library/data/repositories/library_repository.dart';
import 'package:mawsueat/app/features/library/data/services/book_storage_service.dart';

class RemoteLibraryRepository implements LibraryRepository {
  final ApiClient _apiClient;
  final BookStorageService _storageService;

  List<BookCategoryModel>? _cachedCategories;
  List<BookModel>? _cachedBooks;
  DateTime? _lastFetchTime;

  RemoteLibraryRepository(this._apiClient, this._storageService);

  Future<void> _fetchLibraryData({bool force = false}) async {
    final now = DateTime.now();
    if (!force &&
        _cachedBooks != null &&
        _cachedCategories != null &&
        _lastFetchTime != null &&
        now.difference(_lastFetchTime!).inMinutes < 5) {
      return;
    }

    try {
      final response = await _apiClient.get(
        ApiConstants.libraryBooks,
        headers: ApiConstants.libraryHeaders,
      );

      // 1. پردازش دسته‌بندی‌ها
      final parsedCategories = <BookCategoryModel>[
        const BookCategoryModel(id: 0, title: 'الكل', icon: 'all'),
      ];
      final rawCategories = response['categories'];
      if (rawCategories is List) {
        for (final item in rawCategories) {
          if (item is Map<String, dynamic>) {
            parsedCategories.add(BookCategoryModel.fromJson(item));
          }
        }
      }
      _cachedCategories = parsedCategories;

      // 2. پردازش کتاب‌ها
      final rawBooks = response['books'] ?? response['data'] ?? [];
      final parsedBooks = <BookModel>[];
      if (rawBooks is List) {
        for (final item in rawBooks) {
          if (item is Map<String, dynamic>) {
            parsedBooks.add(BookModel.fromJson(item));
          }
        }
      }
      _cachedBooks = parsedBooks;
      _lastFetchTime = now;
    } catch (e) {
      debugPrint('Error fetching library data from API: $e');
      rethrow;
    }
  }

  Future<BookModel> _enrichWithLocalData(BookModel book) async {
    final isDownloaded = await _storageService.isBookDownloaded(book.id);
    final localPath = isDownloaded
        ? await _storageService.getBookLocalPath(book.id)
        : null;
    final progressData = _storageService.getReadingProgress(book.id);
    final userRating = _storageService.getUserRating(book.id);

    int lastPage = 0;
    DateTime? lastTimestamp;
    if (progressData != null) {
      lastPage = progressData['last_page'] as int? ?? 0;
      final ts = progressData['timestamp'] as String?;
      if (ts != null) {
        lastTimestamp = DateTime.tryParse(ts);
      }
    }

    return book.copyWith(
      isDownloaded: isDownloaded,
      localPath: localPath,
      lastReadPage: lastPage,
      lastReadTimestamp: lastTimestamp,
      userRating: userRating,
    );
  }

  @override
  Future<List<BookCategoryModel>> getCategories() async {
    try {
      await _fetchLibraryData();
      return _cachedCategories ?? [
        const BookCategoryModel(id: 0, title: 'الكل', icon: 'all'),
      ];
    } catch (e) {
      debugPrint('Error getting categories from API: $e');
      return [
        const BookCategoryModel(id: 0, title: 'الكل', icon: 'all'),
      ];
    }
  }

  @override
  Future<List<BookModel>> getBooks({
    int? categoryId,
    String? searchQuery,
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    try {
      await _fetchLibraryData(force: forceRefresh);
      final allBooks = _cachedBooks ?? [];
      final filteredBooks = <BookModel>[];

      for (final book in allBooks) {
        // فیلتر دسته‌بندی
        if (categoryId != null && categoryId > 0 && book.categoryId != categoryId) {
          continue;
        }

        // فیلتر جستجو
        if (searchQuery != null && searchQuery.trim().isNotEmpty) {
          final query = searchQuery.trim().toLowerCase();
          final matchesTitle = book.title.toLowerCase().contains(query);
          final matchesAuthor = book.author.toLowerCase().contains(query);
          final matchesDesc = book.description.toLowerCase().contains(query);
          if (!matchesTitle && !matchesAuthor && !matchesDesc) {
            continue;
          }
        }

        filteredBooks.add(await _enrichWithLocalData(book));
      }

      return filteredBooks;
    } catch (e) {
      debugPrint('Error fetching library books from API: $e');
      rethrow;
    }
  }

  @override
  Future<List<BookEntryModel>> getBookEntries({
    required int bookId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.encyclopediaBookEntries(bookId),
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );
      final data = response['data'] ?? [];
      final entries = <BookEntryModel>[];
      if (data is List) {
        for (final item in data) {
          entries.add(BookEntryModel.fromJson(item as Map<String, dynamic>));
        }
      }
      return entries;
    } catch (e) {
      debugPrint('Error fetching book entries from API: $e');
      return [];
    }
  }

  @override
  Future<BookEntryModel> getEntryDetail(int entryId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.encyclopediaEntryDetail(entryId),
      );
      final data = response['data'] ?? response;
      return BookEntryModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error fetching entry detail from API: $e');
      rethrow;
    }
  }

  @override
  Future<List<BookEntryModel>> searchEncyclopedia({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.encyclopediaSearch,
        queryParameters: {
          'q': query,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );
      final data = response['data'] ?? [];
      final entries = <BookEntryModel>[];
      if (data is List) {
        for (final item in data) {
          entries.add(BookEntryModel.fromJson(item as Map<String, dynamic>));
        }
      }
      return entries;
    } catch (e) {
      debugPrint('Error searching encyclopedia from API: $e');
      return [];
    }
  }

  @override
  Future<BookModel> getBookDetails(int bookId) async {
    try {
      final books = await getBooks();
      return books.firstWhere(
        (b) => b.id == bookId,
        orElse: () => BookModel(id: bookId, title: 'موسوعة'),
      );
    } catch (e) {
      debugPrint('Error fetching book details: $e');
      return BookModel(id: bookId, title: 'موسوعة');
    }
  }

  @override
  Future<List<BookModel>> getContinueReadingBooks() async {
    final bookIds = _storageService.getContinueReadingBookIds();
    final continueBooks = <BookModel>[];

    for (final id in bookIds) {
      try {
        final book = await getBookDetails(id);
        if (book.hasStartedReading) {
          continueBooks.add(book);
        }
      } catch (e) {
        debugPrint('Could not fetch book #$id for continue reading: $e');
      }
    }

    return continueBooks;
  }

  @override
  Future<bool> submitRating({
    required int bookId,
    required double rating,
  }) async {
    await _storageService.saveUserRating(bookId: bookId, rating: rating);
    return true;
  }

  @override
  Future<String> downloadBookDb({
    required int bookId,
    String? downloadUrl,
    void Function(double progress)? onProgress,
  }) async {
    final targetUrl = (downloadUrl != null && downloadUrl.trim().isNotEmpty)
        ? downloadUrl.trim()
        : '${ApiConstants.libraryDownloadBook}$bookId';

    return await _storageService.downloadBookDb(
      bookId: bookId,
      downloadUrl: targetUrl,
      headers: ApiConstants.libraryHeaders,
      onProgress: onProgress,
    );
  }

  @override
  Future<bool> isBookDbDownloaded(int bookId) async {
    return await _storageService.isBookDbDownloaded(bookId);
  }

  @override
  Future<String> getBookDbPath(int bookId) async {
    return await _storageService.getBookDbPath(bookId);
  }

  @override
  Future<String> downloadBookPdf({
    required int bookId,
    required String pdfUrl,
    void Function(double progress)? onProgress,
  }) async {
    return await _storageService.downloadBookPdf(
      bookId: bookId,
      pdfUrl: pdfUrl,
      onProgress: onProgress,
    );
  }

  @override
  Future<bool> isBookPdfDownloaded(int bookId) async {
    return await _storageService.isBookPdfDownloaded(bookId);
  }

  @override
  Future<String> getBookPdfPath(int bookId) async {
    return await _storageService.getBookPdfPath(bookId);
  }

  @override
  Future<String> downloadBook({
    required int bookId,
    required String pdfUrl,
    void Function(double progress)? onProgress,
  }) async {
    // پیش‌فرض دانلود کتاب، دیتابیس متنی است
    return await downloadBookDb(
      bookId: bookId,
      downloadUrl: '${ApiConstants.libraryDownloadBook}$bookId',
      onProgress: onProgress,
    );
  }

  @override
  Future<bool> deleteDownloadedBook(int bookId) async {
    return await _storageService.deleteDownloadedBook(bookId);
  }

  @override
  Future<void> saveReadingProgress({
    required int bookId,
    required int pageNumber,
    required int totalPages,
  }) async {
    await _storageService.saveReadingProgress(
      bookId: bookId,
      pageNumber: pageNumber,
      totalPages: totalPages,
    );
  }

  @override
  Future<bool> isBookDownloaded(int bookId) async {
    return await _storageService.isBookDownloaded(bookId);
  }

  @override
  Future<String> getBookLocalPath(int bookId) async {
    return await _storageService.getBookLocalPath(bookId);
  }
}
