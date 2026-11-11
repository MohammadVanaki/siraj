import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/rulings/data/models/marja_model.dart';
import 'package:mawsueat/app/features/rulings/data/models/ruling_category_model.dart';
import 'package:mawsueat/app/features/rulings/data/models/ruling_model.dart';
import 'package:mawsueat/app/features/rulings/data/repositories/rulings_repository.dart';
import 'package:share_plus/share_plus.dart';

class RulingsController extends GetxController {
  final RulingsRepository _repository;
  RulingsController(this._repository);

  // States
  final maraji = <MarjaModel>[].obs;
  final selectedMarjaId = 0.obs;

  final categories = <RulingCategoryModel>[].obs;
  final selectedCategoryId = 0.obs;

  final rulings = <RulingModel>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  final isSearching = false.obs;
  final searchQuery = ''.obs;
  final searchTextController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    try {
      final futures = await Future.wait([
        _repository.getMaraji(),
        _repository.getCategories(),
      ]);
      maraji.assignAll(futures[0] as List<MarjaModel>);
      categories.assignAll(futures[1] as List<RulingCategoryModel>);

      await fetchRulings();
    } catch (e) {
      debugPrint('Error loading rulings data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRulings() async {
    isLoading.value = true;
    try {
      final result = await _repository.getRulings(
        marjaId: selectedMarjaId.value,
        categoryId: selectedCategoryId.value,
        searchQuery: searchQuery.value,
      );
      rulings.assignAll(result);
    } catch (e) {
      debugPrint('Error fetching rulings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectMarja(int id) {
    if (selectedMarjaId.value == id) return;
    selectedMarjaId.value = id;
    fetchRulings();
  }

  void selectCategory(int id) {
    if (selectedCategoryId.value == id) return;
    selectedCategoryId.value = id;
    fetchRulings();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    fetchRulings();
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchTextController.clear();
      searchQuery.value = '';
      fetchRulings();
    }
  }

  Future<void> toggleBookmark(RulingModel item) async {
    final index = rulings.indexWhere((element) => element.id == item.id);
    if (index == -1) return;

    final currentFav = item.isFavorite;
    rulings[index] = item.copyWith(isFavorite: !currentFav);
    HapticFeedback.lightImpact();

    try {
      final serverFav = await _repository.toggleBookmark(item.id);
      if (rulings[index].isFavorite != serverFav) {
        rulings[index] = rulings[index].copyWith(isFavorite: serverFav);
      }
    } catch (e) {
      rulings[index] = item;
    }
  }

  Future<bool> sendQuestion({
    required int marjaId,
    required int categoryId,
    required String question,
    String? contact,
  }) async {
    isSubmitting.value = true;
    try {
      final success = await _repository.submitQuestion(
        marjaId: marjaId,
        categoryId: categoryId,
        question: question,
        contactInfo: contact,
      );
      return success;
    } catch (e) {
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void copyRuling(RulingModel ruling) {
    final text = '''
📌 ${ruling.title}
🏛️ المرجع: ${ruling.marjaName}
📂 الباب: ${ruling.categoryTitle}

❓ السؤال:
${ruling.question}

💬 الجواب:
${ruling.answer}

تطبيق السراج - الاستفتاءات الشرعية
''';
    Clipboard.setData(ClipboardData(text: text));
    Get.rawSnackbar(
      message: 'تم نسخ نص المسألة والجواب إلى الحافظة',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  void shareRuling(RulingModel ruling) {
    final text = '''
📖 استفتاء شرعي (تطبيق السراج)
━━━━━━━━━━━━━━━━━━━━
📌 ${ruling.title}
🏛️ المرجع: ${ruling.marjaName} (${ruling.categoryTitle})

❓ السؤال:
${ruling.question}

💬 الفتوى والجواب:
${ruling.answer}
''';
    Share.share(text, subject: ruling.title);
  }
}
