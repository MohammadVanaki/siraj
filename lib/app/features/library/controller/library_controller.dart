import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/constants/constants.dart';
import 'package:mawsueat/app/features/library/data/models/book_category_model.dart';
import 'package:mawsueat/app/features/library/data/models/book_entry_model.dart';
import 'package:mawsueat/app/features/library/data/models/book_model.dart';
import 'package:mawsueat/app/features/library/data/models/bookmarked_page_model.dart';
import 'package:mawsueat/app/features/library/data/repositories/library_repository.dart';
import 'package:mawsueat/app/features/library/data/services/book_db_service.dart';
import 'package:mawsueat/app/features/library/data/services/book_storage_service.dart';
import 'package:mawsueat/app/features/library/view/screens/book_content_reader_page.dart';
import 'package:mawsueat/app/features/library/view/screens/book_detail_page.dart';

class LibraryController extends GetxController {
  final LibraryRepository _repository;
  final BookStorageService _storageService;
  final BookDbService _dbService = BookDbService();

  LibraryController(this._repository, this._storageService);

  static const String _keyFavoriteBooks = 'library_favorite_book_ids';
  static const String _keyBookmarkedPages = 'library_bookmarked_pages';

  // Observables
  final categories = <BookCategoryModel>[].obs;
  final selectedCategoryId = 0.obs;
  final books = <BookModel>[].obs;
  final continueReadingBooks = <BookModel>[].obs;

  // 0: All Books (المكتبة العامة), 1: Downloaded Books (الكتب المحملة), 2: Favorites (المفضلة)
  final selectedTab = 0.obs;

  // Sub-tab for Favorites: 0: الكتب المفضلة, 1: الصفحات المحفوظة
  final selectedFavSubTab = 0.obs;

  final favoriteBookIds = <int>{}.obs;
  final bookmarkedPages = <BookmarkedPageModel>[].obs;

  final isLoading = false.obs;
  final isBooksLoading = false.obs;
  final isLoadingContinueReading = false.obs;
  final searchQuery = ''.obs;
  final isSearching = false.obs;

  final downloadProgressMap = <int, double>{}.obs;
  StreamSubscription? _downloadSub;

  final TextEditingController searchController = TextEditingController();

  /// لیست کتاب‌های دانلود شده
  List<BookModel> get downloadedBooks =>
      books.where((b) => b.isDownloaded).toList();

  /// لیست کتاب‌های دانلود نشده
  List<BookModel> get nonDownloadedBooks =>
      books.where((b) => !b.isDownloaded).toList();

  /// لیست کتاب‌های محبوب (مفضلة)
  List<BookModel> get favoriteBooks =>
      books.where((b) => favoriteBookIds.contains(b.id)).toList();

  @override
  void onInit() {
    super.onInit();
    _loadFavoritesAndBookmarks();
    _downloadSub = _storageService.downloadProgressStream.listen((map) {
      downloadProgressMap.assignAll(map);
    });
    loadInitialData();
  }

  @override
  void onClose() {
    _downloadSub?.cancel();
    searchController.dispose();
    super.onClose();
  }

  void _loadFavoritesAndBookmarks() {
    // 1. بارگذاری شناسه‌های کتاب‌های موردعلاقه
    final favIds = Constants.localStorage.read<List>(_keyFavoriteBooks);
    if (favIds != null) {
      favoriteBookIds.assignAll(
        favIds
            .map((e) => int.tryParse(e.toString()) ?? 0)
            .where((id) => id > 0),
      );
    }

    // 2. بارگذاری صفحات بوک‌مارک شده
    final pagesList = Constants.localStorage.read<List>(_keyBookmarkedPages);
    if (pagesList != null) {
      try {
        final parsed = pagesList
            .map((e) =>
                BookmarkedPageModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
        bookmarkedPages.assignAll(parsed);
      } catch (e) {
        debugPrint('Error parsing bookmarked pages: $e');
      }
    }
  }

  /// ذخیره صفحات بوکمارک شده
  void _saveBookmarkedPages() {
    Constants.localStorage.write(
      _keyBookmarkedPages,
      bookmarkedPages.map((b) => b.toMap()).toList(),
    );
  }

  /// همگام‌سازی بوکمارک‌های ثبت شده در دیتابیس‌های محلی sqlite با لیست بوکمارک‌ها
  Future<void> syncBookmarksFromDownloadedDbs() async {
    try {
      final downloaded = downloadedBooks;
      bool hasChanges = false;

      for (final book in downloaded) {
        if (book.localPath == null) continue;
        final pages = await _dbService.getBookmarkedPages(book.localPath!);
        for (final p in pages) {
          final alreadyExists = bookmarkedPages.any(
            (b) => b.bookId == book.id && b.pageNumber == p.pageNumber,
          );
          if (!alreadyExists) {
            final plainSnippet = p.text
                .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ')
                .replaceAll(RegExp(r'\s+'), ' ')
                .trim();
            final snippet = plainSnippet.length > 120
                ? '${plainSnippet.substring(0, 120)}...'
                : plainSnippet;

            bookmarkedPages.add(
              BookmarkedPageModel(
                bookId: book.id,
                bookTitle: book.title,
                bookAuthor: book.author,
                bookCoverUrl: book.coverUrl,
                pageNumber: p.pageNumber,
                snippet: snippet,
                localDbPath: book.localPath,
                createdAt: DateTime.now(),
              ),
            );
            hasChanges = true;
          }
        }
      }

      if (hasChanges) {
        _saveBookmarkedPages();
      }
    } catch (e) {
      debugPrint('Error syncing bookmarks from downloaded DBs: $e');
    }
  }

  /// بررسی اینکه آیا کتاب مورد نظر در لیست مفضله است
  bool isBookFavorite(int bookId) => favoriteBookIds.contains(bookId);

  /// افزودن یا حذف کتاب از مفضله
  void toggleBookFavorite(int bookId) {
    if (favoriteBookIds.contains(bookId)) {
      favoriteBookIds.remove(bookId);
    } else {
      favoriteBookIds.add(bookId);
    }
    Constants.localStorage.write(_keyFavoriteBooks, favoriteBookIds.toList());

    final index = books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      books[index] =
          books[index].copyWith(isFavorite: favoriteBookIds.contains(bookId));
    }
    books.refresh();
  }

  /// افزودن یک صفحه بوکمارک شده
  void addBookmark(BookmarkedPageModel bookmark) {
    final index = bookmarkedPages.indexWhere(
      (b) => b.bookId == bookmark.bookId && b.pageNumber == bookmark.pageNumber,
    );
    if (index != -1) {
      bookmarkedPages[index] = bookmark;
    } else {
      bookmarkedPages.insert(0, bookmark);
    }
    _saveBookmarkedPages();
  }

  /// حذف یک صفحه بوکمارک شده
  Future<void> removeBookmark(int bookId, int pageNumber) async {
    bookmarkedPages.removeWhere(
      (b) => b.bookId == bookId && b.pageNumber == pageNumber,
    );
    _saveBookmarkedPages();

    final isDownloaded = await _storageService.isBookDbDownloaded(bookId);
    if (isDownloaded) {
      final dbPath = await _storageService.getBookDbPath(bookId);
      await _dbService.setBookmark(dbPath, pageNumber, false);
    }
  }

  /// بررسی وضعیت بوکمارک بودن یک صفحه
  bool isPageBookmarked(int bookId, int pageNumber) => bookmarkedPages.any(
        (b) => b.bookId == bookId && b.pageNumber == pageNumber,
      );

  /// باز کردن مستقیم صفحه بوکمارک شده در ریدر
  Future<void> openBookmarkedPage(BookmarkedPageModel bookmark) async {
    final isDownloaded =
        await _storageService.isBookDbDownloaded(bookmark.bookId);
    final dbPath = await _storageService.getBookDbPath(bookmark.bookId);

    BookModel? book = books.firstWhereOrNull((b) => b.id == bookmark.bookId);
    if (book == null) {
      try {
        book = await _repository.getBookDetails(bookmark.bookId);
      } catch (_) {
        book = BookModel(
          id: bookmark.bookId,
          title: bookmark.bookTitle,
          author: bookmark.bookAuthor,
          coverUrl: bookmark.bookCoverUrl,
          isDownloaded: isDownloaded,
          localPath: isDownloaded ? dbPath : null,
        );
      }
    }

    if (isDownloaded && await File(dbPath).exists()) {
      Get.to(
        () => BookContentReaderPage(
          book: book!,
          dbPath: dbPath,
          initialPage: bookmark.pageNumber,
        ),
      );
    } else {
      Get.to(() => BookDetailPage(book: book!));
    }
  }

  /// باز کردن مستقیم کتاب برای ادامه مطالعه در متن کتاب (BookContentReaderPage)
  Future<void> openBookForReading(BookModel book) async {
    final isDownloaded = await _storageService.isBookDbDownloaded(book.id);
    final dbPath = await _storageService.getBookDbPath(book.id);

    if (isDownloaded && await File(dbPath).exists()) {
      Get.to(
        () => BookContentReaderPage(
          book: book,
          dbPath: dbPath,
          initialPage: book.lastReadPage > 0 ? book.lastReadPage : 1,
        ),
      );
    } else {
      Get.to(() => BookDetailPage(book: book));
    }
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    try {
      final fetchedCategories = await _repository.getCategories();
      categories.assignAll(fetchedCategories);

      await Future.wait([
        fetchBooks(showLoader: false),
        fetchContinueReadingBooks(),
      ]);
      syncBookmarksFromDownloadedDbs();
    } catch (e) {
      debugPrint('Error loading library initial data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchBooks(
      {bool showLoader = true, bool forceRefresh = false}) async {
    if (showLoader) {
      isBooksLoading.value = true;
    }
    try {
      final result = await _repository.getBooks(
        categoryId: selectedCategoryId.value,
        searchQuery: searchQuery.value,
        forceRefresh: forceRefresh,
      );
      final mapped = result.map((b) {
        return b.copyWith(isFavorite: favoriteBookIds.contains(b.id));
      }).toList();
      books.assignAll(mapped);
    } catch (e) {
      debugPrint('Error fetching books: $e');
    } finally {
      if (showLoader) {
        isBooksLoading.value = false;
      }
    }
  }

  Future<void> fetchContinueReadingBooks() async {
    isLoadingContinueReading.value = true;
    try {
      final result = await _repository.getContinueReadingBooks();
      continueReadingBooks.assignAll(result);
    } catch (e) {
      debugPrint('Error fetching continue reading books: $e');
    } finally {
      isLoadingContinueReading.value = false;
    }
  }

  final searchedEntries = <BookEntryModel>[].obs;
  final isSearchingEntries = false.obs;

  void selectCategory(int categoryId) {
    if (selectedCategoryId.value == categoryId) return;
    selectedCategoryId.value = categoryId;
    fetchBooks(showLoader: true);
  }

  void switchTab(int tabIndex) {
    if (selectedTab.value == tabIndex) return;
    selectedTab.value = tabIndex;
    if (tabIndex == 2) {
      syncBookmarksFromDownloadedDbs();
    }
  }

  void switchFavSubTab(int index) {
    if (selectedFavSubTab.value == index) return;
    selectedFavSubTab.value = index;
  }

  void onSearch(String query) {
    searchQuery.value = query;
    fetchBooks(showLoader: true);
    if (query.trim().isNotEmpty) {
      searchInEntries(query.trim());
    } else {
      searchedEntries.clear();
    }
  }

  Future<void> searchInEntries(String query) async {
    isSearchingEntries.value = true;
    try {
      final results = await _repository.searchEncyclopedia(query: query);
      searchedEntries.assignAll(results);
    } catch (e) {
      debugPrint('Error searching entries: $e');
    } finally {
      isSearchingEntries.value = false;
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    searchedEntries.clear();
    isSearching.value = false;
    fetchBooks(showLoader: true);
  }

  Future<void> refreshLibrary() async {
    try {
      final fetchedCategories = await _repository.getCategories();
      categories.assignAll(fetchedCategories);
    } catch (e) {
      debugPrint('Error refreshing categories: $e');
    }
    await Future.wait([
      fetchBooks(showLoader: false, forceRefresh: true),
      fetchContinueReadingBooks(),
    ]);
    syncBookmarksFromDownloadedDbs();
  }

  /// به‌روزرسانی مجدد اطلاعات یک کتاب خاص در لیست
  Future<void> updateBookState(int bookId) async {
    try {
      final updated = await _repository.getBookDetails(bookId);
      final index = books.indexWhere((b) => b.id == bookId);
      if (index != -1) {
        books[index] = updated.copyWith(
          isFavorite: favoriteBookIds.contains(bookId),
        );
      }
      await fetchContinueReadingBooks();
    } catch (e) {
      debugPrint('Error updating single book state: $e');
    }
  }
}
