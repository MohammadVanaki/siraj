import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/constants/constants.dart';
import 'package:mawsueat/app/features/library/controller/library_controller.dart';
import 'package:mawsueat/app/features/library/data/models/book_content_model.dart';
import 'package:mawsueat/app/features/library/data/models/book_model.dart';
import 'package:mawsueat/app/features/library/data/models/bookmarked_page_model.dart';
import 'package:mawsueat/app/features/library/data/repositories/library_repository.dart';
import 'package:mawsueat/app/features/library/data/services/book_db_service.dart';

enum ReaderThemeMode {
  light(
    title: 'فاتح',
    backgroundColor: Color(0xFFFAF9F6),
    textColor: Color(0xFF1E2022),
    cardColor: Color(0xFFFFFFFF),
    accentColor: Color(0xFF4A6B82),
    borderColor: Color(0xFFE5E5E0),
  ),
  sepia(
    title: 'ورقي',
    backgroundColor: Color(0xFFF5EEDB),
    textColor: Color(0xFF382E1E),
    cardColor: Color(0xFFEBE2CD),
    accentColor: Color(0xFF8C6239),
    borderColor: Color(0xFFDDD2BA),
  ),
  dark(
    title: 'داكن',
    backgroundColor: Color(0xFF1E2124),
    textColor: Color(0xFFE1E3E6),
    cardColor: Color(0xFF282B30),
    accentColor: Color(0xFF6C9AB8),
    borderColor: Color(0xFF33373D),
  ),
  black(
    title: 'ليلي',
    backgroundColor: Color(0xFF0D0E10),
    textColor: Color(0xFFCCCCCC),
    cardColor: Color(0xFF17181C),
    accentColor: Color(0xFF8AB4F8),
    borderColor: Color(0xFF25262B),
  );

  final String title;
  final Color backgroundColor;
  final Color textColor;
  final Color cardColor;
  final Color accentColor;
  final Color borderColor;

  const ReaderThemeMode({
    required this.title,
    required this.backgroundColor,
    required this.textColor,
    required this.cardColor,
    required this.accentColor,
    required this.borderColor,
  });
}

class BookContentReaderController extends GetxController {
  final LibraryRepository repository;
  final BookModel book;
  final String dbPath;
  final BookDbService _dbService = BookDbService();

  late PageController pageController;

  final totalPages = 1.obs;
  final currentPage = 1.obs;
  final showControls = true.obs;
  final isDraggingSlider = false.obs;
  final dragPage = 1.obs;

  static const String _keyIsVertical = 'reader_is_vertical_scroll';
  static const String _keyFontSize = 'reader_font_size';
  static const String _keyReaderTheme = 'reader_theme_mode';

  // تنظیمات مطالعه
  final fontSize = 18.0.obs;
  final lineHeight = 1.85.obs;
  final readerTheme = ReaderThemeMode.light.obs;
  final isVertical = true.obs;

  // اطلاعات فصول و صفحات
  final chapters = <BookChapterModel>[].obs;
  final bookmarks = <BookPageModel>[].obs;
  final isCurrentPageBookmarked = false.obs;
  final currentChapterTitle = ''.obs;

  // کش صفحات لود شده
  final pagesCache = <int, BookPageModel>{}.obs;
  final isLoadingInitial = true.obs;
  final isSearching = false.obs;
  final searchResults = <BookSearchResultModel>[].obs;
  final currentSearchQuery = ''.obs;

  final int? initialPage;

  BookContentReaderController({
    required this.repository,
    required this.book,
    required this.dbPath,
    this.initialPage,
  });

  @override
  void onInit() {
    super.onInit();
    final startPage = initialPage ?? (book.lastReadPage > 0 ? book.lastReadPage : 1);
    currentPage.value = startPage;
    dragPage.value = startPage;

    // بارگذاری تنظیمات ذخیره شده
    final savedIsVertical = Constants.localStorage.read<bool>(_keyIsVertical) ?? true;
    isVertical.value = savedIsVertical;

    final savedFontSize = Constants.localStorage.read<double>(_keyFontSize);
    if (savedFontSize != null && savedFontSize >= 12 && savedFontSize <= 36) {
      fontSize.value = savedFontSize;
    }

    final savedThemeIndex = Constants.localStorage.read<int>(_keyReaderTheme);
    if (savedThemeIndex != null && savedThemeIndex >= 0 && savedThemeIndex < ReaderThemeMode.values.length) {
      readerTheme.value = ReaderThemeMode.values[savedThemeIndex];
    }

    pageController = PageController(initialPage: startPage - 1);

    _initReader();
  }

  Future<void> _initReader() async {
    isLoadingInitial.value = true;
    try {
      // دریافت تعداد صفحات و سرفصل‌ها
      final count = await _dbService.getTotalPages(dbPath);
      totalPages.value = count > 0 ? count : (book.totalPages > 0 ? book.totalPages : 1);

      final chaps = await _dbService.getChapters(dbPath);
      chapters.assignAll(chaps);

      // بارگذاری بوکمارک‌ها
      final favs = await _dbService.getBookmarkedPages(dbPath);
      bookmarks.assignAll(favs);

      // بارگذاری صفحه جاری
      await loadPage(currentPage.value);
      _updateCurrentChapterTitle();
      _checkBookmarkStatus();
    } catch (e) {
      debugPrint('Error initializing BookContentReader: $e');
    } finally {
      isLoadingInitial.value = false;
    }
  }

  /// بارگذاری محتوای یک صفحه خاص
  Future<BookPageModel?> loadPage(int pageNum) async {
    if (pagesCache.containsKey(pageNum)) {
      return pagesCache[pageNum];
    }

    try {
      final pageModel = await _dbService.getPage(dbPath, pageNum);
      if (pageModel != null) {
        pagesCache[pageNum] = pageModel;
        return pageModel;
      }
    } catch (e) {
      debugPrint('Error loading page $pageNum: $e');
    }
    return null;
  }

  /// پیش‌بارگذاری صفحات مجاور برای روان بودن اسکرول
  void preloadNeighborPages(int pageNum) {
    if (pageNum > 1 && !pagesCache.containsKey(pageNum - 1)) {
      loadPage(pageNum - 1);
    }
    if (pageNum < totalPages.value && !pagesCache.containsKey(pageNum + 1)) {
      loadPage(pageNum + 1);
    }
  }

  /// تغییر صفحه در PageView
  void onPageViewChanged(int index) {
    final pageNum = index + 1;
    currentPage.value = pageNum;
    dragPage.value = pageNum;
    _updateCurrentChapterTitle();
    _checkBookmarkStatus();
    preloadNeighborPages(pageNum);
    _saveProgress(pageNum);
  }

  /// پرش به صفحه مشخص
  void jumpToPage(int pageNum) {
    final target = pageNum.clamp(1, totalPages.value);
    currentPage.value = target;
    dragPage.value = target;
    if (pageController.hasClients) {
      pageController.jumpToPage(target - 1);
    }
    loadPage(target);
    _updateCurrentChapterTitle();
    _checkBookmarkStatus();
    _saveProgress(target);
  }

  /// پرش انیمیشنی به صفحه مشخص
  void animateToPage(int pageNum) {
    final target = pageNum.clamp(1, totalPages.value);
    currentPage.value = target;
    dragPage.value = target;
    if (pageController.hasClients) {
      pageController.animateToPage(
        target - 1,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
    loadPage(target);
    _updateCurrentChapterTitle();
    _checkBookmarkStatus();
    _saveProgress(target);
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      animateToPage(currentPage.value + 1);
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      animateToPage(currentPage.value - 1);
    }
  }

  void toggleControls() {
    showControls.value = !showControls.value;
  }

  void _updateCurrentChapterTitle() {
    final cur = currentPage.value;
    String title = '';
    for (final ch in chapters.reversed) {
      if (ch.pageNumber <= cur) {
        title = ch.title;
        break;
      }
    }
    currentChapterTitle.value = title.isNotEmpty ? title : book.title;
  }

  void _checkBookmarkStatus() {
    final cur = currentPage.value;
    final cached = pagesCache[cur];
    if (cached != null) {
      isCurrentPageBookmarked.value = cached.isFavorite;
    } else {
      isCurrentPageBookmarked.value = bookmarks.any((b) => b.pageNumber == cur);
    }
  }

  /// نشانه‌گذاری / حذف نشانه‌گذاری صفحه جاری
  Future<void> toggleCurrentPageBookmark() async {
    final cur = currentPage.value;
    final nextState = !isCurrentPageBookmarked.value;
    isCurrentPageBookmarked.value = nextState;

    final success = await _dbService.setBookmark(dbPath, cur, nextState);
    if (success) {
      // به‌روزرسانی کش صفحه
      final cached = pagesCache[cur];
      if (cached != null) {
        pagesCache[cur] = cached.copyWith(isFavorite: nextState);
      }

      // به‌روزرسانی لیست بوکمارک‌ها
      final favs = await _dbService.getBookmarkedPages(dbPath);
      bookmarks.assignAll(favs);

      // همگام‌سازی با LibraryController
      if (Get.isRegistered<LibraryController>()) {
        final libCtrl = Get.find<LibraryController>();
        if (nextState) {
          final chTitle = chapters
                  .lastWhereOrNull((c) => c.pageNumber <= cur)
                  ?.title ??
              '';
          final rawText = cached?.text ?? '';
          final plainSnippet = rawText
              .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim();
          final snippet = plainSnippet.length > 120
              ? '${plainSnippet.substring(0, 120)}...'
              : plainSnippet;

          libCtrl.addBookmark(
            BookmarkedPageModel(
              bookId: book.id,
              bookTitle: book.title,
              bookAuthor: book.author,
              bookCoverUrl: book.coverUrl,
              pageNumber: cur,
              chapterTitle: chTitle,
              snippet: snippet,
              localDbPath: dbPath,
              createdAt: DateTime.now(),
            ),
          );
        } else {
          libCtrl.removeBookmark(book.id, cur);
        }
      }
    }
  }

  /// ذخیره موقعیت مطالعه
  Future<void> _saveProgress(int pageNum) async {
    try {
      await repository.saveReadingProgress(
        bookId: book.id,
        pageNumber: pageNum,
        totalPages: totalPages.value,
      );

      if (Get.isRegistered<LibraryController>()) {
        Get.find<LibraryController>().updateBookState(book.id);
      }
    } catch (e) {
      debugPrint('Error saving reading progress: $e');
    }
  }

  /// جستجو در متن کتاب
  Future<void> search(String query) async {
    final cleanQuery = query.trim();
    currentSearchQuery.value = cleanQuery;
    if (cleanQuery.isEmpty) {
      searchResults.clear();
      return;
    }

    isSearching.value = true;
    try {
      final results = await _dbService.searchInBook(dbPath, cleanQuery);
      searchResults.assignAll(results);
    } catch (e) {
      debugPrint('Error searching: $e');
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  /// پاک‌کردن کلمه جستجو و هایلایت‌ها
  void clearSearch() {
    currentSearchQuery.value = '';
    searchResults.clear();
  }

  // تغییر اندازه فونت
  void increaseFontSize() {
    if (fontSize.value < 34) {
      fontSize.value += 1.5;
      Constants.localStorage.write(_keyFontSize, fontSize.value);
    }
  }

  void decreaseFontSize() {
    if (fontSize.value > 13) {
      fontSize.value -= 1.5;
      Constants.localStorage.write(_keyFontSize, fontSize.value);
    }
  }

  void setFontSize(double size) {
    fontSize.value = size;
    Constants.localStorage.write(_keyFontSize, size);
  }

  void setTheme(ReaderThemeMode mode) {
    readerTheme.value = mode;
    Constants.localStorage.write(_keyReaderTheme, mode.index);
  }

  /// تغییر جهت اسکرول و ورق‌زدن (افقی یا عمودی)
  void setScrollDirection(bool vertical) {
    if (isVertical.value == vertical) return;
    final current = currentPage.value;
    final oldController = pageController;
    pageController = PageController(initialPage: current - 1);
    isVertical.value = vertical;
    Constants.localStorage.write(_keyIsVertical, vertical);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      oldController.dispose();
    });
  }

  @override
  void onClose() {
    pageController.dispose();
    _dbService.closeDb(dbPath);
    super.onClose();
  }
}
