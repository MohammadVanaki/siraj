import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../data/models/mafatih_item_model.dart';
import '../data/repositories/mafatih_repository.dart';

class MafatihController extends GetxController {
  final MafatihRepository _repository = MafatihRepository();

  final RxList<MafatihItemModel> allItems = <MafatihItemModel>[].obs;
  final RxList<MafatihItemModel> filteredItems = <MafatihItemModel>[].obs;
  final RxSet<String> bookmarkedIds = <String>{}.obs;

  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxnString errorMessage = RxnString();

  final RxString searchQuery = ''.obs;
  final RxBool showOnlyBookmarks = false.obs;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadBookmarks();
    fetchItems();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void _loadBookmarks() {
    bookmarkedIds.assignAll(_repository.getBookmarkedIds());
  }

  Future<void> fetchItems({bool forceRefresh = false}) async {
    if (forceRefresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }
    errorMessage.value = null;

    try {
      final items = await _repository.getItems(forceRefresh: forceRefresh);
      allItems.assignAll(items);
      _applyFilter();
    } catch (e) {
      errorMessage.value =
          'تعذر تحميل محتويات مفاتيح الجنان، يرجى المحاولة لاحقاً';
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query.trim();
    _applyFilter();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _applyFilter();
  }

  void toggleBookmarksFilter() {
    HapticFeedback.selectionClick();
    showOnlyBookmarks.value = !showOnlyBookmarks.value;
    _applyFilter();
  }

  void _applyFilter() {
    final query = searchQuery.value.toLowerCase();
    final onlyBookmarks = showOnlyBookmarks.value;

    List<MafatihItemModel> results = allItems;

    if (onlyBookmarks) {
      results = results
          .where((item) => bookmarkedIds.contains(item.id))
          .toList();
    }

    if (query.isNotEmpty) {
      results = results.where((item) {
        final title = item.titleArabic.toLowerCase();
        final body = item.bodyArabic.toLowerCase();
        return title.contains(query) || body.contains(query);
      }).toList();
    }

    filteredItems.assignAll(results);
  }

  Future<void> toggleBookmark(String id) async {
    HapticFeedback.lightImpact();
    final isAdded = await _repository.toggleBookmark(id);
    if (isAdded) {
      bookmarkedIds.add(id);
    } else {
      bookmarkedIds.remove(id);
    }
    _applyFilter();
  }

  /// هماهنگ‌سازی وضعیت بوک‌مارک در صورت تغییر از ریدر
  void syncBookmarkStatus(String id, bool isBookmarked) {
    if (isBookmarked) {
      bookmarkedIds.add(id);
    } else {
      bookmarkedIds.remove(id);
    }
    if (showOnlyBookmarks.value) {
      _applyFilter();
    }
  }

  bool isBookmarked(String id) => bookmarkedIds.contains(id);
}
