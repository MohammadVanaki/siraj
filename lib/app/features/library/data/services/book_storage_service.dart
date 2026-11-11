import 'dart:async';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mawsueat/app/core/common/constants/api_constants.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class BookStorageService {
  static const String _storageContainer = 'library_storage';
  static const String _progressKey = 'reading_progress';
  static const String _ratingsKey = 'user_ratings';
  static const String _downloadedDbsKey = 'downloaded_books_db_map';
  static const String _downloadedPdfsKey = 'downloaded_books_pdf_map';

  late final GetStorage _box;
  late final Dio _dio;

  final Map<int, double> _downloadProgressMap = {};
  final _downloadProgressStreamController = StreamController<Map<int, double>>.broadcast();

  Stream<Map<int, double>> get downloadProgressStream => _downloadProgressStreamController.stream;

  BookStorageService() {
    _box = GetStorage(_storageContainer);
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 5),
        responseType: ResponseType.bytes,
        followRedirects: true,
      ),
    );
  }

  static Future<void> init() async {
    await GetStorage.init(_storageContainer);
  }

  /// دریافت پوشه اختصاصی ذخیره فایل‌های محلی کتابخانه
  Future<Directory> _getBooksDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final booksDir = Directory(p.join(docsDir.path, 'library_books'));
    if (!await booksDir.exists()) {
      await booksDir.create(recursive: true);
    }
    return booksDir;
  }

  // ===================== بخش دیتابیس کتاب (SQLite DB) =====================

  /// مسیر فایل دیتابیس کتاب
  Future<String> getBookDbPath(int bookId) async {
    final dir = await _getBooksDirectory();
    return p.join(dir.path, 'book_$bookId.db');
  }

  /// بررسی اینکه آیا دیتابیس کتاب دانلود شده است؟
  Future<bool> isBookDbDownloaded(int bookId) async {
    final path = await getBookDbPath(bookId);
    final file = File(path);
    return await file.exists() && (await file.length() > 0);
  }

  /// دانلود دیتابیس کتاب (zip حاوی دیتابیس sqlite)، اکسترکت و ذخیره
  Future<String> downloadBookDb({
    required int bookId,
    String? downloadUrl,
    Map<String, String>? headers,
    void Function(double progress)? onProgress,
  }) async {
    final targetPath = await getBookDbPath(bookId);
    final targetFile = File(targetPath);

    // اگر قبلاً دانلود شده باشد
    if (await targetFile.exists() && await targetFile.length() > 0) {
      return targetPath;
    }

    final url = (downloadUrl != null && downloadUrl.trim().isNotEmpty)
        ? downloadUrl.trim()
        : '${ApiConstants.libraryDownloadBook}$bookId';

    final tempZipPath = '$targetPath.zip.tmp';
    final tempZipFile = File(tempZipPath);
    if (await tempZipFile.exists()) {
      await tempZipFile.delete();
    }

    try {
      _downloadProgressMap[bookId] = 0.0;
      _downloadProgressStreamController.add(Map.from(_downloadProgressMap));

      final requestHeaders = {
        'x-api-key': ApiConstants.libraryApiKey,
        'Accept': '*/*',
        ...?headers,
      };

      final response = await _dio.get<List<int>>(
        url,
        options: Options(
          headers: requestHeaders,
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = (received / total).clamp(0.0, 1.0);
            _downloadProgressMap[bookId] = progress;
            _downloadProgressStreamController.add(Map.from(_downloadProgressMap));
            onProgress?.call(progress);
          }
        },
      );

      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        throw Exception('محتوای فایل دانلودی خالی است');
      }

      // بررسی آیا بایت‌ها زیپ هستند (امضای PK یا 0x50, 0x4B)
      final isZip = bytes.length > 4 && bytes[0] == 0x50 && bytes[1] == 0x4B;

      if (isZip) {
        // اکسترکت فایل زیپ با پکیج archive
        final archive = ZipDecoder().decodeBytes(bytes);
        ArchiveFile? candidateDb;

        for (final file in archive) {
          if (file.isFile) {
            final name = file.name.toLowerCase();
            if (name.endsWith('.db') || name.endsWith('.sqlite') || name.endsWith('.sqlite3')) {
              candidateDb = file;
              break;
            }
          }
        }

        // اگر فایلی با پسوند دیتابیس نیافتیم، اولین فایل داخل زیپ را برمی‌داریم
        candidateDb ??= archive.firstWhere(
          (f) => f.isFile,
          orElse: () => throw Exception('هیچ فایلی درون آرشیو زیپ یافت نشد'),
        );

        final dbBytes = candidateDb.content as List<int>;
        await targetFile.writeAsBytes(dbBytes, flush: true);
      } else {
        // فایل مستقیماً به صورت دیتابیس برگردانده شده است
        await targetFile.writeAsBytes(bytes, flush: true);
      }

      // ثبت در نگاشت ذخیره‌سازی محلی
      final map = _getMap(_downloadedDbsKey);
      map[bookId.toString()] = targetPath;
      await _box.write(_downloadedDbsKey, map);

      return targetPath;
    } catch (e) {
      if (await targetFile.exists()) {
        try {
          await targetFile.delete();
        } catch (_) {}
      }
      rethrow;
    } finally {
      if (await tempZipFile.exists()) {
        try {
          await tempZipFile.delete();
        } catch (_) {}
      }
      _downloadProgressMap.remove(bookId);
      _downloadProgressStreamController.add(Map.from(_downloadProgressMap));
    }
  }

  /// حذف دیتابیس کتاب
  Future<bool> deleteBookDb(int bookId) async {
    final path = await getBookDbPath(bookId);
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    final map = _getMap(_downloadedDbsKey);
    map.remove(bookId.toString());
    await _box.write(_downloadedDbsKey, map);
    return true;
  }

  // ===================== بخش فایل PDF کتاب =====================

  /// مسیر محلی فایل PDF کتاب
  Future<String> getBookPdfPath(int bookId) async {
    final dir = await _getBooksDirectory();
    return p.join(dir.path, 'book_$bookId.pdf');
  }

  /// بررسی موجود بودن فایل PDF محلی
  Future<bool> isBookPdfDownloaded(int bookId) async {
    final path = await getBookPdfPath(bookId);
    final file = File(path);
    return await file.exists() && (await file.length() > 0);
  }

  /// دانلود فایل PDF کتاب
  Future<String> downloadBookPdf({
    required int bookId,
    required String pdfUrl,
    void Function(double progress)? onProgress,
  }) async {
    final targetPath = await getBookPdfPath(bookId);
    final targetFile = File(targetPath);

    if (await targetFile.exists() && await targetFile.length() > 0) {
      return targetPath;
    }

    final tempPath = '$targetPath.tmp';
    final tempFile = File(tempPath);
    if (await tempFile.exists()) {
      await tempFile.delete();
    }

    try {
      _downloadProgressMap[bookId] = 0.0;
      _downloadProgressStreamController.add(Map.from(_downloadProgressMap));

      final response = await _dio.get<List<int>>(
        pdfUrl,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = (received / total).clamp(0.0, 1.0);
            _downloadProgressMap[bookId] = progress;
            _downloadProgressStreamController.add(Map.from(_downloadProgressMap));
            onProgress?.call(progress);
          }
        },
      );

      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        throw Exception('فایل PDF دانلودی خالی است');
      }

      await tempFile.writeAsBytes(bytes, flush: true);
      await tempFile.rename(targetPath);

      final map = _getMap(_downloadedPdfsKey);
      map[bookId.toString()] = targetPath;
      await _box.write(_downloadedPdfsKey, map);

      return targetPath;
    } catch (e) {
      if (await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
      rethrow;
    } finally {
      _downloadProgressMap.remove(bookId);
      _downloadProgressStreamController.add(Map.from(_downloadProgressMap));
    }
  }

  /// حذف فایل PDF کتاب
  Future<bool> deleteBookPdf(int bookId) async {
    final path = await getBookPdfPath(bookId);
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    final map = _getMap(_downloadedPdfsKey);
    map.remove(bookId.toString());
    await _box.write(_downloadedPdfsKey, map);
    return true;
  }

  // ===================== متدهای مشترک و سازگاری =====================

  /// دریافت مسیر محلی فایل کتاب (اولویت با دیتابیس و سپس PDF)
  Future<String> getBookLocalPath(int bookId) async {
    if (await isBookDbDownloaded(bookId)) {
      return await getBookDbPath(bookId);
    }
    return await getBookPdfPath(bookId);
  }

  /// بررسی اینکه آیا هر نوع فایلی از کتاب (دیتابیس یا PDF) دانلود شده است
  Future<bool> isBookDownloaded(int bookId) async {
    return (await isBookDbDownloaded(bookId)) || (await isBookPdfDownloaded(bookId));
  }

  /// دریافت درصد دانلود جاری کتاب (اگر در حال دانلود باشد)
  double? getDownloadProgress(int bookId) {
    return _downloadProgressMap[bookId];
  }

  /// حذف تمام فایل‌های کتاب
  Future<bool> deleteDownloadedBook(int bookId) async {
    await deleteBookDb(bookId);
    await deleteBookPdf(bookId);
    return true;
  }

  /// ذخیره پیشرفت مطالعه (شماره صفحه خوانده شده)
  Future<void> saveReadingProgress({
    required int bookId,
    required int pageNumber,
    required int totalPages,
  }) async {
    final progressMap = _getMap(_progressKey);
    progressMap[bookId.toString()] = {
      'last_page': pageNumber,
      'total_pages': totalPages,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _box.write(_progressKey, progressMap);
  }

  /// دریافت پیشرفت مطالعه کتاب
  Map<String, dynamic>? getReadingProgress(int bookId) {
    final progressMap = _getMap(_progressKey);
    final data = progressMap[bookId.toString()];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  /// دریافت لیست شناسه کتاب‌هایی که کاربر مطالعه آن‌ها را آغاز کرده
  List<int> getContinueReadingBookIds() {
    final progressMap = _getMap(_progressKey);
    final list = <MapEntry<int, DateTime>>[];

    progressMap.forEach((key, value) {
      final id = int.tryParse(key);
      if (id != null && value is Map) {
        final lastPage = value['last_page'] as int? ?? 0;
        final timestampStr = value['timestamp'] as String?;
        final timestamp = timestampStr != null
            ? DateTime.tryParse(timestampStr) ?? DateTime(2000)
            : DateTime(2000);

        if (lastPage > 0) {
          list.add(MapEntry(id, timestamp));
        }
      }
    });

    list.sort((a, b) => b.value.compareTo(a.value));
    return list.map((e) => e.key).toList();
  }

  /// ذخیره امتیاز کاربر برای کتاب
  Future<void> saveUserRating({
    required int bookId,
    required double rating,
  }) async {
    final ratingsMap = _getMap(_ratingsKey);
    ratingsMap[bookId.toString()] = rating;
    await _box.write(_ratingsKey, ratingsMap);
  }

  /// دریافت امتیاز کاربر برای کتاب
  double? getUserRating(int bookId) {
    final ratingsMap = _getMap(_ratingsKey);
    final val = ratingsMap[bookId.toString()];
    if (val is num) {
      return val.toDouble();
    }
    return null;
  }

  Map<String, dynamic> _getMap(String key) {
    final data = _box.read(key);
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }

  void dispose() {
    _downloadProgressStreamController.close();
  }
}
