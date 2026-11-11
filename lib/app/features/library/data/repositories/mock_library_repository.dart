import 'dart:async';
import 'package:mawsueat/app/features/library/data/models/book_category_model.dart';
import 'package:mawsueat/app/features/library/data/models/book_entry_model.dart';
import 'package:mawsueat/app/features/library/data/models/book_model.dart';

import 'package:mawsueat/app/features/library/data/repositories/library_repository.dart';
import 'package:mawsueat/app/features/library/data/services/book_storage_service.dart';

class MockLibraryRepository implements LibraryRepository {
  final BookStorageService _storageService;

  MockLibraryRepository(this._storageService);

  final List<BookCategoryModel> _mockCategories = const [
    BookCategoryModel(id: 0, title: 'الكل', icon: 'all', booksCount: 8),
    BookCategoryModel(id: 1, title: 'القرآن وعلومه', icon: 'quran', booksCount: 2),
    BookCategoryModel(id: 2, title: 'العقائد والكلام', icon: 'aqeedah', booksCount: 2),
    BookCategoryModel(id: 3, title: 'الحديث والرواية', icon: 'hadith', booksCount: 2),
    BookCategoryModel(id: 4, title: 'الفقه والأحكام', icon: 'fiqh', booksCount: 1),
    BookCategoryModel(id: 5, title: 'الأدعية والزيارات', icon: 'dua', booksCount: 1),
  ];

  final List<BookModel> _rawBooks = [
    const BookModel(
      id: 1,
      title: 'نهج البلاغة',
      author: 'الشريف الرضي (جامع خطب أمير المؤمنين ع)',
      categoryId: 3,
      categoryName: 'الحديث والرواية',
      coverUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600&auto=format&fit=crop&q=80',
      pdfUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      description: 'مجموع ما اختاره الشريف الرضي من كلام مولانا أمير المؤمنين علي بن أبي طالب عليه السلام، يشتمل على الخطب والكتب والرسائل والحكم والمواعظ البالغة قمة الفصاحة والبلاغة والحكمة الإلهية.',
      totalPages: 480,
      fileSizeBytes: 15420000,
      publishedYear: '400 هـ',
      rating: 4.9,
      reviewsCount: 320,
    ),
    const BookModel(
      id: 2,
      title: 'الصحيفة السجادية',
      author: 'الإمام علي بن الحسين زين العابدين (ع)',
      categoryId: 5,
      categoryName: 'الأدعية والزيارات',
      coverUrl: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=600&auto=format&fit=crop&q=80',
      pdfUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      description: 'زبور آل محمد وإنجيل أهل البيت، تتضمن أسمى الأدعية والمناجاة في معرفة الله والتوبة وطلب المغفرة ومكارم الأخلاق وسائر الشؤون الإنسانية والروحية.',
      totalPages: 310,
      fileSizeBytes: 8900000,
      publishedYear: '95 هـ',
      rating: 4.95,
      reviewsCount: 285,
    ),
    const BookModel(
      id: 3,
      title: 'أصول الكافي',
      author: 'الشيخ محمد بن يعقوب الكليني (ره)',
      categoryId: 3,
      categoryName: 'الحديث والرواية',
      coverUrl: 'https://images.unsplash.com/photo-1532012164546-f432f2e3edd7?w=600&auto=format&fit=crop&q=80',
      pdfUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      description: 'أهم الكتب الأربعة المعتمدة عند الشيعة الإمامية، جمع فيه المصنف رحمه الله الأحاديث المروية عن النبي وأهل بيته الطاهرين في أصول العقائد والتوحيد والإمامة والحجة والعقل والجهل.',
      totalPages: 620,
      fileSizeBytes: 24300000,
      publishedYear: '329 هـ',
      rating: 4.85,
      reviewsCount: 190,
    ),
    const BookModel(
      id: 4,
      title: 'تفسير الميزان في تفسير القرآن',
      author: 'العلامة السيد محمد حسين الطباطبائي (قدس)',
      categoryId: 1,
      categoryName: 'القرآن وعلومه',
      coverUrl: 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=600&auto=format&fit=crop&q=80',
      pdfUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      description: 'من أعظم التفاسير المعاصرة التي اعتمدت منهج تفسير القرآن بالقرآن، مستعرضاً الأبعاد الفلسفية والاجتماعية والأخلاقية والروائية للآيات المباركة.',
      totalPages: 540,
      fileSizeBytes: 18500000,
      publishedYear: '1402 هـ',
      rating: 4.9,
      reviewsCount: 215,
    ),
    const BookModel(
      id: 5,
      title: 'عقائد الإمامية',
      author: 'الشيخ محمد رضا المظفر (رحمه الله)',
      categoryId: 2,
      categoryName: 'العقائد والكلام',
      coverUrl: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?w=600&auto=format&fit=crop&q=80',
      pdfUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      description: 'كتاب مختصر وشامل يوضح أصول ومتبنيات مذهب أهل البيت عليهم السلام بأسلوب عصري ومنهجي واضح بعيداً عن التعقيد.',
      totalPages: 160,
      fileSizeBytes: 5200000,
      publishedYear: '1380 هـ',
      rating: 4.75,
      reviewsCount: 140,
    ),
    const BookModel(
      id: 6,
      title: 'منهاج الصالحين',
      author: 'سماحة المرجع الديني الأعلى',
      categoryId: 4,
      categoryName: 'الفقه والأحكام',
      coverUrl: 'https://images.unsplash.com/photo-1476275466078-4007374efbbe?w=600&auto=format&fit=crop&q=80',
      pdfUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      description: 'الرسالة العملية الفقهية الشاملة للأبواب العبادية والمعاملاتية وفق أحدث الفتاوى الفقهية.',
      totalPages: 420,
      fileSizeBytes: 12800000,
      publishedYear: '1442 هـ',
      rating: 4.8,
      reviewsCount: 310,
    ),
    const BookModel(
      id: 7,
      title: 'المعجم في فقه لغة القرآن',
      author: 'مجموعة من الباحثين والمحققين',
      categoryId: 1,
      categoryName: 'القرآن وعلومه',
      coverUrl: 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=600&auto=format&fit=crop&q=80',
      pdfUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      description: 'موسوعة لغوية قرآنية تبحث في دلالات ومفردات ألفاظ التنزيل الحكيم بأسلوب علمي مقارن ودقيق.',
      totalPages: 780,
      fileSizeBytes: 32000000,
      publishedYear: '1435 هـ',
      rating: 4.7,
      reviewsCount: 98,
    ),
    const BookModel(
      id: 8,
      title: 'أصل الشيعة وأصولها',
      author: 'الشيخ محمد الحسين كاشف الغطاء (قدس)',
      categoryId: 2,
      categoryName: 'العقائد والكلام',
      coverUrl: 'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=600&auto=format&fit=crop&q=80',
      pdfUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      description: 'كتاب قيّم ألفه الشيخ كاشف الغطاء للتعريف بحقيقة مذهب أهل البيت عليهم السلام ودفع الشبهات والمغالطات وتوحيد صفوف المسلمين.',
      totalPages: 240,
      fileSizeBytes: 7100000,
      publishedYear: '1351 هـ',
      rating: 4.88,
      reviewsCount: 165,
    ),
  ];

  /// ترکیب اطلاعات با وضعیت محلی ذخیره شده در دستگاه
  Future<BookModel> _enrichWithLocalData(BookModel book) async {
    final isDownloaded = await _storageService.isBookDownloaded(book.id);
    final localPath = isDownloaded ? await _storageService.getBookLocalPath(book.id) : null;
    final progressData = _storageService.getReadingProgress(book.id);
    final userRating = _storageService.getUserRating(book.id);

    int lastPage = 0;
    DateTime? lastTimestamp;
    if (progressData != null) {
      lastPage = progressData['last_page'] as int? ?? 0;
      final ts = progressData['timestamp'] as String?;
      if (ts != null) {
        lastTimestamp = DateTime.tryParse(ts);
      }
    }

    return book.copyWith(
      isDownloaded: isDownloaded,
      localPath: localPath,
      lastReadPage: lastPage,
      lastReadTimestamp: lastTimestamp,
      userRating: userRating,
    );
  }

  @override
  Future<List<BookCategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockCategories;
  }

  @override
  Future<List<BookModel>> getBooks({
    int? categoryId,
    String? searchQuery,
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    var filtered = _rawBooks.where((book) {
      if (categoryId != null && categoryId > 0 && book.categoryId != categoryId) {
        return false;
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        final matchTitle = book.title.toLowerCase().contains(query);
        final matchAuthor = book.author.toLowerCase().contains(query);
        final matchDesc = book.description.toLowerCase().contains(query);
        return matchTitle || matchAuthor || matchDesc;
      }
      return true;
    }).toList();

    // همگام‌سازی با فایل‌های لوکال و دیتابیس دستگاه
    final enrichedList = await Future.wait(filtered.map(_enrichWithLocalData));
    return enrichedList;
  }

  @override
  Future<BookModel> getBookDetails(int bookId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final book = _rawBooks.firstWhere(
      (b) => b.id == bookId,
      orElse: () => _rawBooks.first,
    );
    return await _enrichWithLocalData(book);
  }

  @override
  Future<List<BookModel>> getContinueReadingBooks() async {
    final bookIds = _storageService.getContinueReadingBookIds();
    final continueBooks = <BookModel>[];

    for (final id in bookIds) {
      final raw = _rawBooks.firstWhere((b) => b.id == id, orElse: () => _rawBooks.first);
      final enriched = await _enrichWithLocalData(raw);
      if (enriched.hasStartedReading) {
        continueBooks.add(enriched);
      }
    }

    return continueBooks;
  }

  @override
  Future<bool> submitRating({
    required int bookId,
    required double rating,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    await _storageService.saveUserRating(bookId: bookId, rating: rating);
    return true;
  }

  @override
  Future<String> downloadBookDb({
    required int bookId,
    String? downloadUrl,
    void Function(double progress)? onProgress,
  }) async {
    return await _storageService.downloadBookDb(
      bookId: bookId,
      downloadUrl: downloadUrl,
      onProgress: onProgress,
    );
  }

  @override
  Future<bool> isBookDbDownloaded(int bookId) async {
    return await _storageService.isBookDbDownloaded(bookId);
  }

  @override
  Future<String> getBookDbPath(int bookId) async {
    return await _storageService.getBookDbPath(bookId);
  }

  @override
  Future<String> downloadBookPdf({
    required int bookId,
    required String pdfUrl,
    void Function(double progress)? onProgress,
  }) async {
    return await _storageService.downloadBookPdf(
      bookId: bookId,
      pdfUrl: pdfUrl,
      onProgress: onProgress,
    );
  }

  @override
  Future<bool> isBookPdfDownloaded(int bookId) async {
    return await _storageService.isBookPdfDownloaded(bookId);
  }

  @override
  Future<String> getBookPdfPath(int bookId) async {
    return await _storageService.getBookPdfPath(bookId);
  }

  @override
  Future<String> downloadBook({
    required int bookId,
    required String pdfUrl,
    void Function(double progress)? onProgress,
  }) async {
    return await _storageService.downloadBookDb(
      bookId: bookId,
      downloadUrl: pdfUrl,
      onProgress: onProgress,
    );
  }

  @override
  Future<bool> deleteDownloadedBook(int bookId) async {
    return await _storageService.deleteDownloadedBook(bookId);
  }

  @override
  Future<void> saveReadingProgress({
    required int bookId,
    required int pageNumber,
    required int totalPages,
  }) async {
    await _storageService.saveReadingProgress(
      bookId: bookId,
      pageNumber: pageNumber,
      totalPages: totalPages,
    );
  }

  @override
  Future<bool> isBookDownloaded(int bookId) async {
    return await _storageService.isBookDownloaded(bookId);
  }

  @override
  Future<List<BookEntryModel>> getBookEntries({
    required int bookId,
    int page = 1,
    int limit = 20,
  }) async {
    return [];
  }

  @override
  Future<BookEntryModel> getEntryDetail(int entryId) async {
    return BookEntryModel(id: entryId, bookId: 1, title: 'عنوان');
  }

  @override
  Future<List<BookEntryModel>> searchEncyclopedia({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    return [];
  }

  @override
  Future<String> getBookLocalPath(int bookId) async {
    return await _storageService.getBookLocalPath(bookId);
  }
}
