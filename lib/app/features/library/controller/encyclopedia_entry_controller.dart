import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/library/data/models/book_entry_model.dart';
import 'package:mawsueat/app/features/library/data/repositories/library_repository.dart';
import 'package:share_plus/share_plus.dart';

class EncyclopediaEntryController extends GetxController {
  final LibraryRepository _repository;
  final int initialEntryId;
  final String? initialTitle;

  EncyclopediaEntryController(
    this._repository, {
    required this.initialEntryId,
    this.initialTitle,
  });

  final currentEntryId = 0.obs;
  final entry = Rxn<BookEntryModel>();
  final isLoading = false.obs;
  final fontSize = 16.0.obs;

  @override
  void onInit() {
    super.onInit();
    currentEntryId.value = initialEntryId;
    loadEntry(initialEntryId);
  }

  Future<void> loadEntry(int entryId) async {
    currentEntryId.value = entryId;
    isLoading.value = true;
    try {
      final result = await _repository.getEntryDetail(entryId);
      entry.value = result;
    } catch (e) {
      debugPrint('Error loading entry #$entryId: $e');
      Get.rawSnackbar(
        message: 'فشل في تحميل محتوى المدخل',
        backgroundColor: Colors.red.withAlpha(200),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void loadNext() {
    final nextId = entry.value?.nextEntryId;
    if (nextId != null) {
      loadEntry(nextId);
    }
  }

  void loadPrevious() {
    final prevId = entry.value?.previousEntryId;
    if (prevId != null) {
      loadEntry(prevId);
    }
  }

  void increaseFontSize() {
    if (fontSize.value < 28.0) {
      fontSize.value += 2.0;
    }
  }

  void decreaseFontSize() {
    if (fontSize.value > 12.0) {
      fontSize.value -= 2.0;
    }
  }

  void copyText() {
    final current = entry.value;
    if (current == null) return;

    final content = '${current.title}\n\n${current.text}';
    Clipboard.setData(ClipboardData(text: content));
    Get.rawSnackbar(
      message: 'تم نسخ النص إلى الحافظة',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  void shareText() {
    final current = entry.value;
    if (current == null) return;

    final content = '📖 ${current.title}\n${current.bookTitle != null ? 'من (${current.bookTitle})\n' : ''}\n${current.text}';
    Share.share(content, subject: current.title);
  }
}
