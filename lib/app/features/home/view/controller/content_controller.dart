// content_controller.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/config/functions.dart';
import 'package:mawsueat/app/config/status.dart';
import 'package:mawsueat/app/core/common/constants/constants.dart';
import 'package:mawsueat/app/features/home/repository/content_repository.dart';
import 'package:mawsueat/app/features/setting/view/controller/settings_controller.dart';

enum SearchScope {
  titles,
  content,
}

class ContentController extends GetxController {
  ContentController();
  var showWebView = true.obs;
  RxBool showAudio = false.obs;
  var bookInfo = Rxn<Map<String, dynamic>>();
  SettingsController get settingsController => Get.find<SettingsController>();
  final ContentRepository repository = ContentRepository();
  var searchQuery = ''.obs;
  final Rx<SearchScope> searchScope = SearchScope.titles.obs;

  var pages = <Map<String, dynamic>>[].obs;
  var groups = <Map<String, dynamic>>[].obs;
  var currentPage = 1.0.obs;
  var scrollPosetion = 1.0.obs;
  var htmlContent = ''.obs;
  var status = Status.init.obs;
  RxBool showContentSettings = false.obs;
  final isBookmarked = false.obs;

  // متغیر برای مانیتورینگ تغییرات
  var lastUpdateTime = DateTime.now().obs;

  late InAppWebViewController inAppWebViewController;

  // وضعیت لودینگ ورودی‌های هر کتاب
  final RxSet<int> loadingBookIds = <int>{}.obs;
  bool isBookLoading(int bookId) => loadingBookIds.contains(bookId);

  // کش متن کامل ورودی‌ها
  final Map<int, String> fullTextsCache = {};
  final RxSet<int> loadingEntryDetailIds = <int>{}.obs;
  bool isEntryDetailLoading(int entryId) => loadingEntryDetailIds.contains(entryId);

  // وضعیت باز/بسته بودن گروه‌ها
  final RxSet<int> expandedGroupIds = <int>{}.obs;
  // وضعیت باز/بسته بودن زیرمجموعه‌ها (متن‌ها)
  final RxSet<int> expandedSubItemIds = <int>{}.obs;

  void toggleGroupExpansion(int bookId) {
    if (expandedGroupIds.contains(bookId)) {
      expandedGroupIds.remove(bookId);
    } else {
      expandedGroupIds.add(bookId);
      if (_subItemsByBook[bookId] == null || _subItemsByBook[bookId]!.isEmpty) {
        loadBookEntries(bookId);
      }
    }
  }

  bool isGroupExpanded(int bookId) {
    return expandedGroupIds.contains(bookId);
  }

  final Map<int, List<Map<String, dynamic>>> _subItemsByBook = {};

  /// دریافت ورودی‌های یک کتاب از سرور
  Future<void> loadBookEntries(int bookId, {bool force = false}) async {
    if (!force && _subItemsByBook.containsKey(bookId) && _subItemsByBook[bookId]!.isNotEmpty) {
      return;
    }
    if (loadingBookIds.contains(bookId)) return;

    try {
      loadingBookIds.add(bookId);
      final entries = await repository.getAllBookEntries(bookId);

      final processed = <Map<String, dynamic>>[];
      for (int i = 0; i < entries.length; i++) {
        final map = Map<String, dynamic>.from(entries[i]);
        map['_pageIndex'] = i;
        map['bid'] = map['bookId'] ?? bookId;
        final rawText = (map['text'] ?? map['excerpt'] ?? '').toString();
        map['_text'] = rawText;
        map['text'] = rawText;
        map['_normTitle'] = normalizeArabic((map['title'] ?? '').toString());
        map['_normText'] = normalizeArabic(removeHtmlTags(rawText));
        processed.add(map);
      }

      _subItemsByBook[bookId] = processed;
      update();
    } catch (e) {
      print('❌ Error loading book entries for $bookId: $e');
    } finally {
      loadingBookIds.remove(bookId);
    }
  }

  /// دریافت متن کامل یک ورودی از سرور
  Future<String?> loadEntryFullText(int entryId, {int? bookId}) async {
    if (fullTextsCache.containsKey(entryId)) {
      return fullTextsCache[entryId];
    }
    if (loadingEntryDetailIds.contains(entryId)) return null;

    try {
      loadingEntryDetailIds.add(entryId);
      final detail = await repository.getEntryDetail(entryId);
      if (detail != null && detail['text'] != null) {
        final fullText = detail['text'].toString();
        fullTextsCache[entryId] = fullText;

        // به‌روزرسانی در کش زیرمجموعه‌ها
        if (bookId != null && _subItemsByBook.containsKey(bookId)) {
          final list = _subItemsByBook[bookId]!;
          for (final item in list) {
            if (item['id'] == entryId || item['id']?.toString() == entryId.toString()) {
              item['_text'] = fullText;
              item['text'] = fullText;
              item['_normText'] = normalizeArabic(removeHtmlTags(fullText));
              break;
            }
          }
        } else {
          for (final list in _subItemsByBook.values) {
            for (final item in list) {
              if (item['id'] == entryId || item['id']?.toString() == entryId.toString()) {
                item['_text'] = fullText;
                item['text'] = fullText;
                item['_normText'] = normalizeArabic(removeHtmlTags(fullText));
                break;
              }
            }
          }
        }

        // به‌روزرسانی در pages
        for (final p in pages) {
          if (p['id'] == entryId || p['id']?.toString() == entryId.toString()) {
            p['_text'] = fullText;
            p['text'] = fullText;
            break;
          }
        }

        update();
        return fullText;
      }
    } catch (e) {
      print('❌ Error loading entry full text for $entryId: $e');
    } finally {
      loadingEntryDetailIds.remove(entryId);
    }
    return null;
  }

  /// آماده‌سازی صفحات یک کتاب برای نمایش در ContentPage
  Future<void> preparePagesForBook(int bookId, {int? targetEntryId}) async {
    if (!_subItemsByBook.containsKey(bookId) || _subItemsByBook[bookId]!.isEmpty) {
      await loadBookEntries(bookId);
    }

    final bookEntries = _subItemsByBook[bookId] ?? [];
    pages.assignAll(bookEntries);

    if (targetEntryId != null) {
      await loadEntryFullText(targetEntryId, bookId: bookId);
    }

    htmlContent.value = await buildHtmlContent();
  }

  // نتایج کش‌شده جستجو برای دسترسی فوق‌العاده سریع O(1) بدون افت فریم
  final RxList<Map<String, dynamic>> _filteredGroupsCache =
      <Map<String, dynamic>>[].obs;
  final Map<int, List<Map<String, dynamic>>> _filteredSubItemsCache = {};

  void updateSearchQuery(String query) async {
    final cleanQuery = query.trim();
    searchQuery.value = cleanQuery;
    expandedGroupIds.clear();
    expandedSubItemIds.clear();
    _filteredGroupsCache.clear();
    _filteredSubItemsCache.clear();

    if (cleanQuery.isEmpty) return;

    final inContent = searchScope.value == SearchScope.content;

    if (inContent) {
      // جستجو در محتوا با API سرور
      try {
        final searchResults = await repository.searchEncyclopedia(cleanQuery);
        if (searchQuery.value != cleanQuery) return;

        final Map<int, List<Map<String, dynamic>>> groupedResults = {};
        for (int i = 0; i < searchResults.length; i++) {
          final item = Map<String, dynamic>.from(searchResults[i]);
          final bId = item['bookId'] is int
              ? item['bookId']
              : (int.tryParse(item['bookId']?.toString() ?? '-1') ?? -1);
          item['_pageIndex'] = i;
          final rawText = (item['text'] ?? item['excerpt'] ?? '').toString();
          item['_text'] = rawText;
          item['text'] = rawText;
          item['_normTitle'] = normalizeArabic((item['title'] ?? '').toString());
          item['_normText'] = normalizeArabic(removeHtmlTags(rawText));

          groupedResults.putIfAbsent(bId, () => []).add(item);
          final int textId = item['id'] is int
              ? item['id']
              : (int.tryParse(item['id']?.toString() ?? '0') ?? 0);
          expandedSubItemIds.add(textId);
        }

        final matchingGroups = <Map<String, dynamic>>[];
        for (final book in groups) {
          final bookId = book['id'] is int
              ? book['id']
              : (int.tryParse(book['id']?.toString() ?? '-1') ?? -1);
          if (groupedResults.containsKey(bookId)) {
            _filteredSubItemsCache[bookId] = groupedResults[bookId]!;
            matchingGroups.add(book);
            expandedGroupIds.add(bookId);
          }
        }
        _filteredGroupsCache.assignAll(matchingGroups);
      } catch (e) {
        print('❌ Error in encyclopedia remote search: $e');
      }
    } else {
      // جستجو در عناوین
      final queryTokens = cleanQuery
          .split(RegExp(r'\s+'))
          .map((s) => normalizeArabic(s))
          .where((s) => s.isNotEmpty)
          .toList();

      final matchingGroups = <Map<String, dynamic>>[];

      for (final book in groups) {
        final bookId = book['id'] is int
            ? book['id']
            : int.tryParse(book['id']?.toString() ?? '-1') ?? -1;
        final subItems = _subItemsByBook[bookId] ?? [];
        final matchingSubItems = <Map<String, dynamic>>[];

        final normTitle = (book['_normTitle'] ??
            normalizeArabic((book['title'] ?? '').toString())) as String;
        bool bookMatches = queryTokens.isNotEmpty &&
            queryTokens.every((token) => normTitle.contains(token));

        for (final p in subItems) {
          final subNormTitle = (p['_normTitle'] ??
              normalizeArabic((p['title'] ?? '').toString())) as String;
          if (queryTokens.isNotEmpty &&
              queryTokens.every((token) => subNormTitle.contains(token))) {
            matchingSubItems.add(p);
          }
        }

        if (bookMatches || matchingSubItems.isNotEmpty) {
          _filteredSubItemsCache[bookId] =
              matchingSubItems.isNotEmpty ? matchingSubItems : subItems;
          matchingGroups.add(book);
          if (matchingSubItems.isNotEmpty) {
            expandedGroupIds.add(bookId);
          }
        }
      }
      _filteredGroupsCache.assignAll(matchingGroups);
    }
  }

  void toggleSubItemExpansion(int textId, {int? bookId}) {
    if (expandedSubItemIds.contains(textId)) {
      expandedSubItemIds.remove(textId);
    } else {
      expandedSubItemIds.add(textId);
      loadEntryFullText(textId, bookId: bookId);
    }
  }

  bool isSubItemExpanded(int textId) {
    return expandedSubItemIds.contains(textId);
  }

  void expandTopic({required int bookId, required int textId}) {
    expandedGroupIds.add(bookId);
    expandedSubItemIds.add(textId);
  }

  /// دریافت زیرمجموعه‌های متنی یک کتاب با کش سریع O(1)
  List<Map<String, dynamic>> getSubItemsForBook(int bookId) {
    if (searchQuery.isEmpty) return _subItemsByBook[bookId] ?? [];
    return _filteredSubItemsCache[bookId] ?? [];
  }

  List<Map<String, dynamic>> get filteredGroups {
    if (searchQuery.isEmpty) return groups;
    return _filteredGroupsCache;
  }

  String normalizeArabic(String text) {
    // الف‌های مختلف (أ, إ, آ, ٱ, ٵ, ٲ) → ا
    text = text.replaceAll(RegExp(r'[أإآٱٵٲ]'), 'ا');
    // ی‌های مختلف (ى, ی, ئ, ؽ, ؾ, ؿ, ػ, ؼ, ۍ, ې, ي) → ي
    text = text.replaceAll(RegExp(r'[ىیئؽؾؿػؼۍېي]'), 'ي');
    // ک فارسی → ك عربی
    text = text.replaceAll('ک', 'ك');
    // و‌های مختلف (ؤ, ۇ, ۆ, ۉ, ۊ, ۋ) → و
    text = text.replaceAll(RegExp(r'[ؤۇۆۉۊۋ]'), 'و');
    // ه و ة (ة, ۃ, ه, ۂ, ە) → ه
    text = text.replaceAll(RegExp(r'[ةۃۂە]'), 'ه');
    // حذف اعراب / تشکيل / تنوین / تشدید / سکون / کشیده (تطویل ـ) / علائم قرآنی / کاراکترهای نامرئی
    text = text.replaceAll(
      RegExp(r'[\u064B-\u065F\u0670\u0640\u06D6-\u06ED\u200C\u200D\u200E\u200F\uFEFF]'),
      '',
    );
    // فاصله‌های چندتایی و کاراکترهای خاص
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text.toLowerCase();
  }

  @override
  void onInit() async {
    super.onInit();

    // گوش دادن به تغییرات font size
    ever(settingsController.fontSize, (value) async {
      print('📝 Font size changed to: $value');
      await refreshContent();
    });

    // گوش دادن به تغییرات line height
    ever(settingsController.lineHeight, (value) async {
      print('📝 Line height changed to: $value');
      await refreshContent();
    });

    // گوش دادن به تغییرات font family
    ever(settingsController.fontFamily, (value) async {
      print('📝 Font family changed to: $value');
      await refreshContent();
    });

    // گوش دادن به تغییرات background color
    ever(settingsController.backgroundColor, (value) async {
      print('🎨 Background color changed');
      await refreshContent();
    });

    // گوش دادن به تغییرات vertical scroll
    ever(settingsController.verticalScroll, (value) async {
      print('🔄 Scroll direction changed');
      await refreshContent();
    });

    final bookmarks = Constants.localStorage.read('bookmarks') ?? {};
    final allComments = Constants.localStorage.read('allBookComments') ?? {};
    status.value = Status.loading;
    await _loadData();
    htmlContent.value = await buildHtmlContent();

    _listenForUpdates();
  }

  // گوش دادن به تغییرات دیتابیس
  void _listenForUpdates() {
    ever(lastUpdateTime, (DateTime time) async {
      print('📢 Database update detected, refreshing content...');
      await refreshContent();
    });
  }

  // Future<void> resetForNewPage() async {
  //   try {
  //     print('🔄 Resetting controller for new page...');

  //     showWebView.value = true;
  //     htmlContent.value = '';
  //     status.value = Status.init;

  //     // پاک کردن WebViewController قبلی
  //     if (inAppWebViewController != null) {
  //       try {
  //         await inAppWebViewController.stopLoading();
  //       } catch (e) {
  //         print('⚠️ Error stopping WebView: $e');
  //       }
  //     }

  //     await Future.delayed(const Duration(milliseconds: 100));

  //     print('✅ Controller reset for new page');
  //   } catch (e) {
  //     print('❌ Error resetting controller: $e');
  //   }
  // }

  // متد برای refresh کردن محتوا
  Future<void> refreshContent({bool forceRebuild = false}) async {
    try {
      print('🔄 Refreshing content data...');
      status.value = Status.loading;
      update(); // notify listeners

      if (forceRebuild) {
        await _loadData();
      }

      // HTML جدید بساز
      htmlContent.value = await buildHtmlContent();

      status.value = Status.success;
      print('✅ Content refreshed successfully');
    } catch (e) {
      print('❌ Error refreshing content: $e');
      status.value = Status.error;
    }
  }

  // متد عمومی برای force refresh از خارج
  Future<void> forceRefreshFromDatabase() async {
    try {
      print('🔁 Force refreshing from database...');
      await refreshContent();
    } catch (e) {
      print('❌ Force refresh error: $e');
    }
  }

  Future<void> _loadData() async {
    try {
      print('📥 Loading encyclopedia books from Dijlah API...');
      final loadedGroups = await repository.getBooks();
      print('📚 Loaded ${loadedGroups.length} books from API');

      final loadedGroupsWithNorm = <Map<String, dynamic>>[];
      for (final g in loadedGroups) {
        final gMap = Map<String, dynamic>.from(g);
        gMap['_normTitle'] = normalizeArabic((gMap['title'] ?? '').toString());
        loadedGroupsWithNorm.add(gMap);
      }

      groups.assignAll(loadedGroupsWithNorm);
      status.value = Status.success;
    } catch (e) {
      print("❌ Encyclopedia API load error: $e");
      status.value = Status.error;
    }
  }

  /// Returns map of book info like sound_url, title, writer, img

  /// Builds the full HTML content to be displayed in the WebView
  Future<String> buildHtmlContent() async {
    final StringBuffer buffer = StringBuffer();

    final bool vertical = settingsController.verticalScroll.value;
    print('vertical ====>$vertical');
    final String bookText = vertical
        ? 'book_text_vertical'
        : 'book_text_horizontal';
    final String bookContainer = vertical
        ? 'book-container-vertical'
        : 'book-container-horizontal';
    final String bookPage = vertical
        ? 'BookPage-vertical book-page-vertical'
        : 'BookPage-horizontal book-page-horizontal';

    List<dynamic> bookmarks = [];
    final String? savedBookmarks = Constants.localStorage.read('bookmark');
    if (savedBookmarks != null) {
      try {
        final decoded = jsonDecode(savedBookmarks);
        bookmarks = decoded is List ? decoded : [decoded];
      } catch (e) {
        print('❌ Error parsing bookmarks: $e');
      }
    }

    for (int i = 0; i < pages.length; i++) {
      bool isBookmarked = bookmarks.any((b) => b['pageNumber'] == i);

      final String bgColor = settingsController.backgroundColor.value
          .toCssHex();

      buffer.write("""
        <div class='$bookPage book_page' data-page='$i' style='color: black !important; background-color: $bgColor !important;' id='page_$i'>
          ${isBookmarked ? "<div class='book-mark add_fav' id='book-mark_$i'></div>" : "<div class='book-mark' id='book-mark_$i'></div>"}
          <div class='comment-button'></div>
          <span class='page-number'>${i + 1}</span>
          <br>
          <div class='$bookText text_style' id='page___$i' style="font-size:${settingsController.fontSize}px !important; line-height:${settingsController.lineHeight} !important;">
            <div style='text-align:center;'><img class='pageLoading' src='asset://images/loader.gif'></div>
          </div>
        </div>
      """);
    }

    final fontCss = await loadFont();

    return '''
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>$fontCss</style>
        <link rel="stylesheet" href="asset://web/css/bootstrap.rtl.min.css">
        <link rel="stylesheet" href="asset://web/css/mhebooks.css">
        <link rel="stylesheet" href="asset://web/all.min.css">
      </head>
      <body onload="replaceContent()" dir="rtl">
        <div class="$bookContainer">
          ${buffer.toString()}
        </div>
        <script src="asset://web/js/jquery-3.5.1.min.js"></script>
        <script src="asset://web/js/bootstrap.bundle.min.js"></script>
        <script src="asset://web/js/main.js"></script>
      </body>
      </html>
    ''';
  }

  /// Loads font files from assets and returns CSS rules to embed them in HTML
  Future<String> loadFont() async {
    String fontPath = 'assets/fonts/dijlah-reg.ttf';
    String fontMime = 'font/truetype';
    String fontFormat = 'truetype';

    switch (settingsController.effectiveFontFamily) {
      case 'aljazeera':
        fontPath = 'assets/fonts/aljazeera.ttf';
        fontMime = 'font/truetype';
        fontFormat = 'truetype';
        break;
      case 'SegoeUI':
        fontPath = 'assets/fonts/SegoeUI.woff2';
        fontMime = 'font/woff2';
        fontFormat = 'woff2';
        break;
      case 'abo':
        fontPath = 'assets/fonts/abo.ttf';
        fontMime = 'font/truetype';
        fontFormat = 'truetype';
        break;
      case 'dijlah':
      default:
        fontPath = 'assets/fonts/dijlah-reg.ttf';
        fontMime = 'font/truetype';
        fontFormat = 'truetype';
    }

    final ByteData mainFont = await rootBundle.load(fontPath);
    final ByteData aboFont = await rootBundle.load('assets/fonts/abo.ttf');

    final String mainFontBase64 = _getFontUriAsBase64(mainFont, fontMime);
    final String aboFontBase64 = _getFontUriAsBase64(aboFont, 'font/truetype');

    return '''
      @font-face {
        font-family: "${settingsController.effectiveFontFamily}";
        src: url("$mainFontBase64") format('$fontFormat');
      }
      @font-face {
        font-family: "AboThar";
        src: url("$aboFontBase64") format('truetype');
      }
      .AboThar {
        font-family: "AboThar" !important;
          color: #4caf50 !important;
        font-size: 20px;
      }
      body, p, div, span {
        font-family: "${settingsController.fontFamily.value}" !important;
        direction: rtl;
      }
    ''';
  }

  /// Converts binary font data into Base64 URI
  String _getFontUriAsBase64(ByteData data, String mime) {
    final buffer = data.buffer;
    return "data:$mime;charset=utf-8;base64,${base64Encode(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes))}";
  }

  Future<void> handleBack() async {
    showWebView.value = false;
    await Future.delayed(const Duration(milliseconds: 50));
    Get.back();
  }

  // متد برای به‌روزرسانی زمان (از UpdatedPagesController صدا زده می‌شود)
  void notifyDatabaseUpdated() {
    lastUpdateTime.value = DateTime.now();
    print('📢 ContentController notified of database update');
  }
}

String applyTextReplacements(String text) {
  text = text.replaceAll(
    "<p style='color: blue;font-size: 67%'",
    "<hr><p style='color: blue;font-size: 14px !important'",
  );
  text = text.replaceAll("(عليهم السلام)", "<span class =AboThar></span>");
  text = text.replaceAll("(عليهم السّلام)", "<span class =AboThar></span>");
  text = text.replaceAll("(عليها السلام)", "<span class =AboThar></span>");
  text = text.replaceAll("(عليهالسلام)", "<span class =AboThar></span>");
  text = text.replaceAll(
    "(عَلَيْهَا السَّلَامُ)",
    "<span class =AboThar></span>",
  );
  text = text.replaceAll("(عليه السلام)", "<span class =AboThar></span>");
  text = text.replaceAll("(علیه السلام)", "<span class =AboThar></span>");
  text = text.replaceAll("(ع)", "<span class =AboThar></span>");

  text = text.replaceAll(
    "(صلّى الله عليه وآله)",
    "<span class =AboThar></span>",
  );
  text = text.replaceAll("صلى اله عليه وسلم", "<span class =AboThar></span>");
  text = text.replaceAll(
    "(صلى لله عليه وآله)",
    "<span class =AboThar></span>",
  );
  text = text.replaceAll(
    "(صَلَّى اللَّهُ عَلَيْهِ وَ آلِهِ)",
    "<span class =AboThar></span>",
  );
  text = text.replaceAll(
    "(صلي الله عليه وآله)",
    "<span class =AboThar></span>",
  );
  text = text.replaceAll(
    "(صلى الله عليه و اله)",
    "<span class =AboThar></span>",
  );
  text = text.replaceAll(
    "(صلي الله عليه و آله)",
    "<span class =AboThar></span>",
  );
  text = text.replaceAll(
    "(صلى الله عليه و آله)",
    "<span class =AboThar></span>",
  );
  text = text.replaceAll(
    "(صلى الله عليه وآله)",
    "<span class =AboThar></span>",
  );
  text = text.replaceAll(
    "(صلي الله عليه وسلم)",
    "<span class =AboThar></span>",
  );
  text = text.replaceAll(
    "(صلی الله علیه و آله و سلم)",
    "<span class =AboThar></span>",
  );
  text = text.replaceAll(
    "(صلى الله عليه وآله وسلم)",
    "<span class =AboThar></span>",
  );
  text = text.replaceAll("(ص)", "<span class =AboThar></span>");

  text = text.replaceAll("(رحمه الله)", "<span class =AboThar></span>");
  text = text.replaceAll(
    "(عجل الله تعالي و فرجه)",
    "<span class =AboThar></span>",
  );
  text = text.replaceAll(
    "(عجل الله فرجه الشريف)",
    "<span class =AboThar></span>",
  );
  text = text.replaceAll(
    "(عجل الله تعالى و فرجه)",
    "<span class =AboThar></span>",
  );
  text = text.replaceAll(
    "(عجل الله تعالى فرجه)",
    "<span class =AboThar></span>",
  );
  text = text.replaceAll(
    "(عجل الله تعالى فرجه الشريف)",
    "<span class =AboThar></span>",
  );
  text = text.replaceAll("(عج)", "<span class =AboThar></span>");
  text = text.replaceAll(
    "(عجل الله تعالي فرجه)",
    "<span class =AboThar></span>",
  );
  text = text.replaceAll("(عجل الله فرجه)", "<span class =AboThar></span>");

  text = text.replaceAll("(رضي الله عنه)", "<span class =AboThar></span>");
  text = text.replaceAll("(قدس سره)", "<span class =AboThar></span>");
  text = text.replaceAll("﴿", "<span class=AboThar></span>");
  text = text.replaceAll("﴾", "<span class=AboThar></span>");
  text = text.replaceAll("{", "<span class=AboThar></span>");
  text = text.replaceAll("}", "<span class=AboThar></span>");

  text = text.replaceAll("@@", "<span style=\"font-size: 110%;\"> 📚 </span>");
  text = text.replaceAll("##", "<span style=\"font-size: 110%;\"> 🌟 </span>");
  text = text.replaceAll(
    "\$\$",
    "<span style=\"font-size: 110%;\"> 8️⃣ </span>",
  );
  text = text.replaceAll("%%", "<span style=\"font-size: 110%;\"> 9️⃣ </span>");
  text = text.replaceAll(
    "&amp;&amp;",
    "<span style=\"font-size: 110%;\"> 🔄 </span>",
  );
  text = text.replaceAll("^^", "<span style=\"font-size: 110%;\"> 💡 </span>");

  text = text.replaceAll(
    "<span style=\"font-size: 110%;\"> 📚 </span>&nbsp;<h1 id=load-bjohar class=tit1>",
    "&nbsp;<h1 id=load-bjohar class=tit1><span style=\"font-size: 110%;\"> 📚 </span>",
  );
  text = text.replaceAll(
    "</h1>&nbsp; <span style=\"font-size: 110%;\"> 📚 </span>",
    "<span style=\"font-size: 110%;\"> 📚 </span></h1>&nbsp; ",
  );
  text = text.replaceAll(
    "<span style=\"font-size: 110%;\"> 📚 </span>&nbsp;<h1 id=load-bjohar class=tit1>",
    "&nbsp;<h1 id=load-bjohar class=tit1><span style=\"font-size: 110%;\"> 📚 </span>",
  );
  text = text.replaceAll(
    "<span style=\"font-size: 110%;\"> 8️⃣ </span> <h1 id=load-bjohar class=tit1>",
    "<h1 id=load-bjohar class=tit1> <span style=\"font-size: 110%;\"> 8️⃣ </span>",
  );
  text = text.replaceAll(
    "</h1>&nbsp;<span style=\"font-size: 110%;\"> 📚 </span>",
    "<span style=\"font-size: 110%;\"> 📚 </span></h1>&nbsp;",
  );
  text = text.replaceAll(
    "<span style=\"font-size: 110%;\"> 9️⃣ </span> <h1 id=load-bjohar class=tit1>",
    "<h1 id=load-bjohar class=tit1><span style=\"font-size: 110%;\"> 9️⃣ </span>",
  );
  text = text.replaceAll(
    "<span style=\"font-size: 110%;\"> 🌟 </span> <h1 id=load-bjohar class=tit1>",
    "<h1 id=load-bjohar class=tit1><span style=\"font-size: 110%;\"> 🌟 </span>",
  );
  text = text.replaceAll(
    "<span style=\"font-size: 110%;\"> ⃣ </span>&nbsp;<h1 id=load-bjohar class=tit1>",
    "&nbsp;<h1 id=load-bjohar class=tit1><span style=\"font-size: 110%;\"> ⃣ </span>",
  );
  text = text.replaceAll(
    "<span style=\"font-size: 110%;\"> 📚 </span><h1 id=load-bjohar class=tit1>",
    "<h1 id=load-bjohar class=tit1><span style=\"font-size: 110%;\"> 📚 </span>",
  );
  text = text.replaceAll(
    "<span style=\"font-size: 110%;\"> 📚 </span> <h1 id=load-bjohar class=tit1>",
    "<h1 id=load-bjohar class=tit1><span style=\"font-size: 110%;\"> 📚 </span>",
  );
  text = text.replaceAll(
    "</h1> <span style=\"font-size: 110%;\"> 📚 </span>",
    "<span style=\"font-size: 110%;\"> 📚 </span></h1>",
  );

  return text;
}
