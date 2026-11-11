import 'package:mawsueat/app/features/library/data/models/book_category_model.dart';
import 'package:mawsueat/app/features/library/data/models/book_entry_model.dart';
import 'package:mawsueat/app/features/library/data/models/book_model.dart';

abstract class LibraryRepository {
  /// دریافت لیست دسته‌بندی‌های کتابخانه
  Future<List<BookCategoryModel>> getCategories();

  /// دریافت لیست کتاب‌ها با فیلتر دسته‌بندی یا جستجو
  Future<List<BookModel>> getBooks({
    int? categoryId,
    String? searchQuery,
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  });

  /// دریافت لیست مدخل‌ها و ابواب یک موسوعه
  Future<List<BookEntryModel>> getBookEntries({
    required int bookId,
    int page = 1,
    int limit = 20,
  });

  /// دریافت محتوای کامل یک مدخل / باب از موسوعه
  Future<BookEntryModel> getEntryDetail(int entryId);

  /// جستجو در تمام مدخل‌ها و ابواب دانشنامه
  Future<List<BookEntryModel>> searchEncyclopedia({
    required String query,
    int page = 1,
    int limit = 20,
  });

  /// دریافت اطلاعات کامل یک کتاب
  Future<BookModel> getBookDetails(int bookId);

  /// دریافت لیست کتاب‌های در حال مطالعه (واصل القراءة)
  Future<List<BookModel>> getContinueReadingBooks();

  /// ثبت امتیاز ۵ ستاره‌ای کاربر برای کتاب
  Future<bool> submitRating({
    required int bookId,
    required double rating,
  });

  /// دانلود دیتابیس متنی کتاب (SQLite)
  Future<String> downloadBookDb({
    required int bookId,
    String? downloadUrl,
    void Function(double progress)? onProgress,
  });

  /// بررسی اینکه آیا دیتابیس متنی کتاب دانلود شده است؟
  Future<bool> isBookDbDownloaded(int bookId);

  /// دریافت مسیر محلی فایل دیتابیس متنی کتاب
  Future<String> getBookDbPath(int bookId);

  /// دانلود نسخه PDF کتاب
  Future<String> downloadBookPdf({
    required int bookId,
    required String pdfUrl,
    void Function(double progress)? onProgress,
  });

  /// بررسی اینکه آیا فایل PDF دانلود شده است؟
  Future<bool> isBookPdfDownloaded(int bookId);

  /// دریافت مسیر محلی فایل PDF کتاب
  Future<String> getBookPdfPath(int bookId);

  /// دانلود فایل کتاب (متد عمومی پیش‌فرض)
  Future<String> downloadBook({
    required int bookId,
    required String pdfUrl,
    void Function(double progress)? onProgress,
  });

  /// حذف فایل دانلود شده کتاب
  Future<bool> deleteDownloadedBook(int bookId);

  /// ذخیره آخرین صفحه خوانده شده
  Future<void> saveReadingProgress({
    required int bookId,
    required int pageNumber,
    required int totalPages,
  });

  /// بررسی وضعیت دانلود بودن کتاب
  Future<bool> isBookDownloaded(int bookId);

  /// دریافت مسیر محلی فایل
  Future<String> getBookLocalPath(int bookId);
}
