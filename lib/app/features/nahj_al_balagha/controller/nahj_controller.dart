import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/nahj_category_model.dart';
import '../data/models/nahj_entry_model.dart';
import '../data/repositories/nahj_repository.dart';

class NahjController extends GetxController {
  final NahjRepository repository;

  NahjController({required this.repository});

  final RxList<NahjCategoryModel> categories = <NahjCategoryModel>[].obs;
  final RxString selectedCategory = 'sermons'.obs;

  final RxList<NahjEntryModel> entries = <NahjEntryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final RxInt currentPage = 1.obs;
  final RxBool hasMore = false.obs;
  final RxInt totalCount = 0.obs;

  final RxString searchQuery = ''.obs;
  final RxBool showOnlyBookmarks = false.obs;
  final RxList<String> bookmarkedIds = <String>[].obs;
  final RxList<NahjEntryModel> bookmarkedEntries = <NahjEntryModel>[].obs;

  final ScrollController scrollController = ScrollController();
  Timer? _debounceTimer;

  static const List<NahjCategoryModel> defaultFallbackCategories = [
    NahjCategoryModel(slug: 'sermons', titleArabic: 'الخطب', count: 240),
    NahjCategoryModel(slug: 'letters', titleArabic: 'الرسائل', count: 79),
    NahjCategoryModel(slug: 'wisdom', titleArabic: 'الحكم', count: 470),
    NahjCategoryModel(slug: 'rare_words', titleArabic: 'غريب الكلام', count: 9),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadBookmarks();
    _setupScrollListener();
    loadCategoriesAndInitialEntries();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 250 &&
          !isLoading.value &&
          !isLoadingMore.value &&
          hasMore.value &&
          !showOnlyBookmarks.value) {
        loadMoreEntries();
      }
    });
  }

  void reloadBookmarks() {
    _loadBookmarks();
  }

  void _loadBookmarks() {
    bookmarkedIds.assignAll(repository.getBookmarkedIds());
    bookmarkedEntries.assignAll(repository.getBookmarkedEntries());

    final existingIds = bookmarkedEntries.map((e) => e.id).toSet();
    for (final id in bookmarkedIds) {
      if (!existingIds.contains(id)) {
        repository.getEntryDetail(id).then((entry) {
          if (entry != null && !bookmarkedEntries.any((e) => e.id == entry.id)) {
            bookmarkedEntries.add(entry);
          }
        }).catchError((_) {});
      }
    }
  }

  Future<void> loadCategoriesAndInitialEntries() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final cats = await repository.getCategories();
      if (cats.isNotEmpty) {
        categories.assignAll(cats);
      } else {
        categories.assignAll(defaultFallbackCategories);
      }

      if (!categories.any((c) => c.slug == selectedCategory.value)) {
        selectedCategory.value = categories.first.slug;
      }

      await fetchEntries(reset: true);
    } catch (e) {
      debugPrint('Error in loadCategoriesAndInitialEntries: $e');
      if (categories.isEmpty) {
        categories.assignAll(defaultFallbackCategories);
      }
      hasError.value = true;
      errorMessage.value = 'تعذر الاتصال بالخادم، يرجى المحاولة لاحقاً';
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(String slug) {
    if (showOnlyBookmarks.value) {
      showOnlyBookmarks.value = false;
    }
    if (selectedCategory.value == slug) return;
    selectedCategory.value = slug;
    fetchEntries(reset: true);
  }

  Future<void> fetchEntries({
    bool reset = true,
    bool forceRefresh = false,
  }) async {
    if (reset) {
      currentPage.value = 1;
      hasMore.value = false;
      entries.clear();
      isLoading.value = true;
    }

    try {
      hasError.value = false;
      final result = await repository.getEntries(
        category: selectedCategory.value,
        page: currentPage.value,
        limit: 20,
        q: searchQuery.value.trim().isNotEmpty
            ? searchQuery.value.trim()
            : null,
      );

      final List<NahjEntryModel> list =
          (result['entries'] as List<NahjEntryModel>?) ?? [];
      final bool more = result['hasMore'] == true;
      final int total = (result['total'] as int?) ?? list.length;

      if (reset) {
        entries.assignAll(list);
      } else {
        entries.addAll(list);
      }

      hasMore.value = more;
      totalCount.value = total;
    } catch (e) {
      debugPrint('Error fetching Nahj entries: $e');
      if (reset && entries.isEmpty) {
        hasError.value = true;
        errorMessage.value = 'حدث خطأ أثناء تحميل البيانات';
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreEntries() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    currentPage.value++;
    await fetchEntries(reset: false);
  }

  void onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      searchQuery.value = query;
      fetchEntries(reset: true);
    });
  }

  void clearSearch() {
    searchQuery.value = '';
    fetchEntries(reset: true);
  }

  void toggleBookmarksFilter() {
    showOnlyBookmarks.value = !showOnlyBookmarks.value;
  }

  bool isBookmarked(String entryId) => bookmarkedIds.contains(entryId);

  Future<void> toggleBookmark(dynamic entryOrId) async {
    await repository.toggleBookmark(entryOrId);
    _loadBookmarks();
  }

  List<NahjEntryModel> get displayedEntries {
    if (showOnlyBookmarks.value) {
      if (searchQuery.value.trim().isEmpty) {
        return bookmarkedEntries;
      }
      final query = searchQuery.value.trim().toLowerCase();
      return bookmarkedEntries.where((e) {
        return e.titleArabic.toLowerCase().contains(query) ||
            (e.excerptArabic?.toLowerCase().contains(query) ?? false) ||
            (e.bodyArabic?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    return entries;
  }
}
