import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/library/controller/library_controller.dart';
import 'package:mawsueat/app/features/library/data/models/book_model.dart';
import 'package:mawsueat/app/features/library/data/repositories/library_repository.dart';

class BookReaderController extends GetxController {
  final LibraryRepository _repository;
  final BookModel book;

  BookReaderController(this._repository, this.book);

  late final RxInt currentPage;
  late final RxInt totalPages;
  final showControls = true.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    currentPage = (book.lastReadPage > 0 ? book.lastReadPage : 1).obs;
    totalPages = (book.totalPages > 0 ? book.totalPages : 1).obs;
  }

  void toggleControls() {
    showControls.value = !showControls.value;
  }

  void setPage(int page) {
    if (page < 1) page = 1;
    if (page > totalPages.value) page = totalPages.value;

    currentPage.value = page;
    _autoSaveProgress(page);
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      setPage(currentPage.value + 1);
    }
  }

  void prevPage() {
    if (currentPage.value > 1) {
      setPage(currentPage.value - 1);
    }
  }

  Future<void> _autoSaveProgress(int page) async {
    try {
      await _repository.saveReadingProgress(
        bookId: book.id,
        pageNumber: page,
        totalPages: totalPages.value,
      );

      if (Get.isRegistered<LibraryController>()) {
        Get.find<LibraryController>().updateBookState(book.id);
      }
    } catch (e) {
      debugPrint('Error saving reading progress: $e');
    }
  }
}
