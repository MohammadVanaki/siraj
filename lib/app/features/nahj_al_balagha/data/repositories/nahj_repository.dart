import '../data_sources/nahj_local_data_source.dart';
import '../data_sources/nahj_remote_data_source.dart';
import '../models/nahj_category_model.dart';
import '../models/nahj_commentator_model.dart';
import '../models/nahj_commentary_model.dart';
import '../models/nahj_entry_model.dart';

class NahjRepository {
  final NahjRemoteDataSource remoteDataSource;
  final NahjLocalDataSource localDataSource;

  NahjRepository({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  /// دریافت دسته‌بندی‌ها با اولویت کش محلی و به‌روزرسانی شبکه
  Future<List<NahjCategoryModel>> getCategories({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = localDataSource.getCachedCategories();
      if (cached.isNotEmpty) {
        // بازخوانی پس‌زمینه
        remoteDataSource.getCategories().then((fresh) {
          if (fresh.isNotEmpty) {
            localDataSource.saveCategories(fresh);
          }
        }).catchError((_) {});
        return cached;
      }
    }

    final fresh = await remoteDataSource.getCategories();
    if (fresh.isNotEmpty) {
      await localDataSource.saveCategories(fresh);
    }
    return fresh;
  }

  /// دریافت شارحان
  Future<List<NahjCommentatorModel>> getCommentators() async {
    return remoteDataSource.getCommentators();
  }

  /// دریافت ورودی‌ها
  Future<Map<String, dynamic>> getEntries({
    String? category,
    int page = 1,
    int limit = 20,
    String? q,
  }) async {
    // برای صفحه اول بدون جستجو کش محلی بررسی می‌شود
    if (page == 1 && (q == null || q.isEmpty) && category != null) {
      final cached = localDataSource.getCachedEntries(category);
      if (cached.isNotEmpty) {
        // بازخوانی در پس‌زمینه
        remoteDataSource
            .getEntries(category: category, page: page, limit: limit, q: q)
            .then((freshResult) {
          final list = freshResult['entries'] as List<NahjEntryModel>?;
          if (list != null && list.isNotEmpty) {
            localDataSource.saveEntries(category, list);
          }
        }).catchError((_) {});

        return {
          'entries': cached,
          'hasMore': true,
          'total': cached.length,
        };
      }
    }

    final result = await remoteDataSource.getEntries(
      category: category,
      page: page,
      limit: limit,
      q: q,
    );

    final entries = result['entries'] as List<NahjEntryModel>?;
    if (page == 1 && (q == null || q.isEmpty) && category != null && entries != null) {
      localDataSource.saveEntries(category, entries);
    }

    return result;
  }

  /// دریافت متن کامل ورودی
  Future<NahjEntryModel?> getEntryDetail(String id) async {
    final cached = localDataSource.getCachedEntryDetail(id);
    if (cached != null && cached.bodyArabic != null && cached.bodyArabic!.isNotEmpty) {
      // به‌روزرسانی در پس‌زمینه
      remoteDataSource.getEntryDetail(id).then((fresh) {
        if (fresh != null) {
          localDataSource.saveEntryDetail(fresh);
        }
      }).catchError((_) {});
      return cached;
    }

    final fresh = await remoteDataSource.getEntryDetail(id);
    if (fresh != null) {
      await localDataSource.saveEntryDetail(fresh);
    }
    return fresh;
  }

  /// دریافت متن شرح
  Future<NahjCommentaryModel?> getCommentaryDetail(String id) async {
    return remoteDataSource.getCommentaryDetail(id);
  }

  // نشانه‌گذاری‌ها
  List<String> getBookmarkedIds() => localDataSource.getBookmarkedIds();
  List<NahjEntryModel> getBookmarkedEntries() =>
      localDataSource.getBookmarkedEntries();
  Future<void> toggleBookmark(dynamic entryOrId) =>
      localDataSource.toggleBookmark(entryOrId);
  bool isBookmarked(String id) => localDataSource.isBookmarked(id);

  // آخرین مطالعه
  String? getLastReadEntryId() => localDataSource.getLastReadEntryId();
  Future<void> saveLastReadEntryId(String id) =>
      localDataSource.saveLastReadEntryId(id);

  // تنظیمات ریدر
  double getFontSize() => localDataSource.getFontSize();
  Future<void> saveFontSize(double size) => localDataSource.saveFontSize(size);

  String getFontFamily() => localDataSource.getFontFamily();
  Future<void> saveFontFamily(String family) =>
      localDataSource.saveFontFamily(family);

  bool getShowTranslation() => localDataSource.getShowTranslation();
  Future<void> saveShowTranslation(bool show) =>
      localDataSource.saveShowTranslation(show);

  String? getSelectedCommentatorId() =>
      localDataSource.getSelectedCommentatorId();
  Future<void> saveSelectedCommentatorId(String id) =>
      localDataSource.saveSelectedCommentatorId(id);
}
