import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/sahifa_dua_model.dart';
import '../data/repositories/sahifa_repository.dart';

class SahifaController extends GetxController {
  final SahifaRepository _repository = SahifaRepository();

  // وضعیت بارگذاری و لیست ادعیه
  final duas = <SahifaDuaModel>[].obs;
  final filteredDuas = <SahifaDuaModel>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // جستجو و فیلترها
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final showOnlyBookmarks = false.obs;
  final bookmarkedIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadBookmarks();
    fetchDuas();

    searchController.addListener(() {
      final text = searchController.text.trim();
      if (searchQuery.value != text) {
        searchQuery.value = text;
        _applyFilters();
      }
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void _loadBookmarks() {
    bookmarkedIds.assignAll(_repository.getBookmarks());
  }

  /// دریافت ادعیه صحیفه سجادیه از ریپازیتوری
  Future<void> fetchDuas({bool forceRefresh = false}) async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final items = await _repository.getDuas(forceRefresh: forceRefresh);
      duas.assignAll(items);
      _applyFilters();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'تعذر تحميل أدعية الصحيفة السجادية. يرجى التحقق من الاتصال بالإنترنت.';
    } finally {
      isLoading.value = false;
    }
  }

  /// اعمال فیلتر جستجو و علاقه‌مندی‌ها
  void _applyFilters() {
    final query = searchQuery.value.toLowerCase();
    final onlyFavs = showOnlyBookmarks.value;

    filteredDuas.assignAll(
      duas.where((dua) {
        if (onlyFavs && !bookmarkedIds.contains(dua.id)) {
          return false;
        }

        if (query.isEmpty) {
          return true;
        }

        final titleMatch = dua.titleArabic.toLowerCase().contains(query);
        final bodyMatch = dua.bodyArabic.toLowerCase().contains(query);
        return titleMatch || bodyMatch;
      }),
    );
  }

  /// تغییر وضعیت فیلتر نشانه‌گذاری‌ها
  void toggleFilterBookmarks() {
    showOnlyBookmarks.value = !showOnlyBookmarks.value;
    _applyFilters();
  }

  /// بررسی نشانه‌گذاری بودن یک دعا
  bool isDuaBookmarked(String id) {
    return bookmarkedIds.contains(id);
  }

  /// افزودن/حذف از نشانه‌گذاری‌ها
  Future<void> toggleBookmark(String id) async {
    final isNowBookmarked = await _repository.toggleBookmark(id);
    if (isNowBookmarked) {
      bookmarkedIds.add(id);
    } else {
      bookmarkedIds.remove(id);
    }
    _applyFilters();
  }

  /// همگام‌سازی وضعیت نشانه‌گذاری از صفحه خوانش بدون تغییر مضاعف مخزن
  void syncBookmarkStatus(String id, bool isBookmarked) {
    if (isBookmarked) {
      bookmarkedIds.add(id);
    } else {
      bookmarkedIds.remove(id);
    }
    _applyFilters();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _applyFilters();
  }
}
