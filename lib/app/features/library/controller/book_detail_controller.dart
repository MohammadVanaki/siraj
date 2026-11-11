import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/library/controller/library_controller.dart';
import 'package:mawsueat/app/features/library/data/models/book_entry_model.dart';
import 'package:mawsueat/app/features/library/data/models/book_model.dart';
import 'package:mawsueat/app/features/library/data/repositories/library_repository.dart';

class BookDetailController extends GetxController {
  final LibraryRepository _repository;
  final BookModel initialBook;

  BookDetailController(this._repository, this.initialBook);

  late final Rx<BookModel> book;

  // وضعیت دانلود دیتابیس (متنی)
  final isDbDownloaded = false.obs;
  final isDownloadingDb = false.obs;
  final downloadDbProgress = 0.0.obs;

  // متغیرهای سازگاری عمومی
  final isDownloading = false.obs;
  final downloadProgress = 0.0.obs;

  final isSubmittingRating = false.obs;
  final entries = <BookEntryModel>[].obs;
  final isLoadingEntries = false.obs;

  @override
  void onInit() {
    super.onInit();
    book = Rx<BookModel>(initialBook);
    if (Get.isRegistered<LibraryController>()) {
      final isFav = Get.find<LibraryController>().isBookFavorite(initialBook.id);
      book.value = book.value.copyWith(isFavorite: isFav);
    }
    refreshBookDetails();
    fetchEntries();
  }

  bool get isFavorite {
    if (Get.isRegistered<LibraryController>()) {
      return Get.find<LibraryController>().isBookFavorite(book.value.id);
    }
    return book.value.isFavorite;
  }

  void toggleFavorite() {
    if (Get.isRegistered<LibraryController>()) {
      final libCtrl = Get.find<LibraryController>();
      libCtrl.toggleBookFavorite(book.value.id);
      book.value = book.value.copyWith(
        isFavorite: libCtrl.isBookFavorite(book.value.id),
      );
    }
  }

  Future<void> fetchEntries() async {
    isLoadingEntries.value = true;
    try {
      final result = await _repository.getBookEntries(
        bookId: book.value.id,
        limit: 100,
      );
      entries.assignAll(result);
    } catch (e) {
      debugPrint('Error fetching entries in controller: $e');
    } finally {
      isLoadingEntries.value = false;
    }
  }

  void _showMessage(
    String title,
    String message, {
    bool isError = false,
    bool isSuccess = false,
    bool isWarning = false,
  }) {
    Color bg = const Color(0xFF333333);
    if (isError) bg = const Color(0xFFD32F2F);
    if (isSuccess) bg = const Color(0xFF388E3C);
    if (isWarning) bg = const Color(0xFFF57C00);

    Get.rawSnackbar(
      title: title,
      message: message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: bg,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> refreshBookDetails() async {
    try {
      final updated = await _repository.getBookDetails(book.value.id);
      book.value = updated;

      isDbDownloaded.value = await _repository.isBookDbDownloaded(
        book.value.id,
      );
    } catch (e) {
      debugPrint('Error refreshing book details: $e');
    }
  }

  /// دریافت مسیر دیتابیس محلی
  Future<String> getBookDbPath() async {
    return await _repository.getBookDbPath(book.value.id);
  }

  /// دریافت مسیر PDF محلی
  Future<String> getBookPdfPath() async {
    return await _repository.getBookPdfPath(book.value.id);
  }

  /// شروع دانلود دیتابیس کتاب (مطالعه متنی)
  Future<String?> startDbDownload() async {
    if (isDownloadingDb.value) return null;

    isDownloadingDb.value = true;
    isDownloading.value = true;
    downloadDbProgress.value = 0.0;
    downloadProgress.value = 0.0;

    try {
      final localPath = await _repository.downloadBookDb(
        bookId: book.value.id,
        onProgress: (progress) {
          downloadDbProgress.value = progress;
          downloadProgress.value = progress;
        },
      );

      isDbDownloaded.value = true;
      book.value = book.value.copyWith(
        isDownloaded: true,
        localPath: localPath,
      );

      if (Get.isRegistered<LibraryController>()) {
        Get.find<LibraryController>().updateBookState(book.value.id);
      }

      _showMessage(
        'تم تحميل الكتاب بنجاح',
        'تم حفظ كتاب "${book.value.title}" ويمكنك قراءته الآن بدون إنترنت',
        isSuccess: true,
      );

      return localPath;
    } catch (e) {
      debugPrint('Error downloading book db: $e');
      _showMessage(
        'خطأ في التحميل',
        'تعذر تحميل دیتابیس کتاب، يرجى المحاولة مرة أخرى',
        isError: true,
      );
      return null;
    } finally {
      isDownloadingDb.value = false;
      isDownloading.value = false;
      downloadDbProgress.value = 0.0;
      downloadProgress.value = 0.0;
    }
  }

  /// دانلود پیش‌فرض (همان دانلود دیتابیس متنی)
  Future<void> startDownload() async {
    await startDbDownload();
  }

  /// حذف فایل‌های دیتابیس کتاب از حافظه دستگاه
  Future<void> deleteDownload() async {
    try {
      await _repository.deleteDownloadedBook(book.value.id);
      isDbDownloaded.value = false;

      book.value = book.value.copyWith(isDownloaded: false, localPath: null);

      if (Get.isRegistered<LibraryController>()) {
        Get.find<LibraryController>().updateBookState(book.value.id);
      }

      _showMessage('تم الحذف', 'تم حذف الملفات المحملة للكتاب من الذاكرة');
    } catch (e) {
      debugPrint('Error deleting downloaded book: $e');
    }
  }

  /// ثبت امتیاز ۵ ستاره‌ای کاربر
  Future<void> submitRating(double rating) async {
    if (!book.value.isDownloaded && !isDbDownloaded.value) {
      _showMessage(
        'تنبيه',
        'يجب تحميل الكتاب أولاً لتتمكن من تقييمه',
        isWarning: true,
      );
      return;
    }

    isSubmittingRating.value = true;
    try {
      final success = await _repository.submitRating(
        bookId: book.value.id,
        rating: rating,
      );

      if (success) {
        book.value = book.value.copyWith(userRating: rating);
        if (Get.isRegistered<LibraryController>()) {
          Get.find<LibraryController>().updateBookState(book.value.id);
        }

        _showMessage(
          'شكراً لتقييمك',
          'تم تسجيل تقييمك ($rating من 5 نجوم) بنجاح',
          isSuccess: true,
        );
      }
    } catch (e) {
      debugPrint('Error submitting rating: $e');
      _showMessage(
        'خطأ',
        'تعذر حفظ التقييم، يرجى المحاولة لاحقاً',
        isError: true,
      );
    } finally {
      isSubmittingRating.value = false;
    }
  }
}
