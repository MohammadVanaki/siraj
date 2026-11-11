import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import '../data_sources/sahifa_remote_data_source.dart';
import '../models/sahifa_dua_model.dart';

class SahifaRepository {
  final SahifaRemoteDataSource _remoteDataSource = SahifaRemoteDataSource();
  final GetStorage _storage = GetStorage();

  static const String _kCachedDuasKey = 'sahifa_cached_duas_v1';
  static const String _kBookmarksKey = 'sahifa_bookmarks_ids_v1';
  static const String _kFontSizeKey = 'sahifa_reader_font_size';

  /// دریافت ادعیه با استراتژی کش-اول برای سرعت بارگذاری آنی
  Future<List<SahifaDuaModel>> getDuas({bool forceRefresh = false}) async {
    // ۱. اگر اجبار به رفرش نیست، ابتدا از کش محلی سریع می‌خوانیم
    if (!forceRefresh) {
      final cached = getCachedDuas();
      if (cached.isNotEmpty) {
        // در پس‌زمینه تلاش برای به‌روزرسانی می‌کنیم بدون بلاک کردن UI
        _fetchAndCacheSilently();
        return cached;
      }
    }

    // ۲. دریافت زنده از API
    try {
      final remoteList = await _remoteDataSource.getDuasList();
      if (remoteList.isNotEmpty) {
        await _saveToCache(remoteList);
        return remoteList;
      }
    } catch (e) {
      debugPrint('Repository: failed to fetch remote duas, checking cache: $e');
      final fallback = getCachedDuas();
      if (fallback.isNotEmpty) return fallback;
      rethrow;
    }

    return getCachedDuas();
  }

  /// دریافت یک دعا بر اساس ID
  Future<SahifaDuaModel?> getDuaById(String id) async {
    // ابتدا در کش محلی بررسی می‌کنیم
    final cached = getCachedDuas();
    final localMatch = cached.where((d) => d.id == id);
    if (localMatch.isNotEmpty) {
      return localMatch.first;
    }

    // در غیر این صورت از سرور دریافت می‌کنیم
    return await _remoteDataSource.getDuaDetail(id);
  }

  /// خواندن ادعیه کش‌شده از حافظه آفلاین
  List<SahifaDuaModel> getCachedDuas() {
    try {
      final raw = _storage.read<List>(_kCachedDuasKey);
      if (raw != null) {
        return raw
            .map((e) => SahifaDuaModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      debugPrint('Error reading cached duas: $e');
    }
    return [];
  }

  /// ذخیره در کش محلی
  Future<void> _saveToCache(List<SahifaDuaModel> list) async {
    try {
      final mapped = list.map((e) => e.toJson()).toList();
      await _storage.write(_kCachedDuasKey, mapped);
    } catch (e) {
      debugPrint('Error saving duas to cache: $e');
    }
  }

  /// به‌روزرسانی بی‌صدا در پس‌زمینه
  void _fetchAndCacheSilently() {
    _remoteDataSource.getDuasList().then((fresh) {
      if (fresh.isNotEmpty) {
        _saveToCache(fresh);
      }
    }).catchError((_) {});
  }

  // ===================== مدیریت نشانه‌گذاری‌ها (Bookmarks) =====================

  Set<String> getBookmarks() {
    try {
      final list = _storage.read<List>(_kBookmarksKey);
      if (list != null) {
        return Set<String>.from(list.map((e) => e.toString()));
      }
    } catch (e) {
      debugPrint('Error reading bookmarks: $e');
    }
    return {};
  }

  bool isBookmarked(String id) {
    return getBookmarks().contains(id);
  }

  Future<bool> toggleBookmark(String id) async {
    final current = getBookmarks();
    final isCurrentlyFav = current.contains(id);

    if (isCurrentlyFav) {
      current.remove(id);
    } else {
      current.add(id);
    }

    await _storage.write(_kBookmarksKey, current.toList());
    return !isCurrentlyFav;
  }

  // ===================== تنظیمات اندازه قلم خوانش =====================

  double getSavedFontSize() {
    return _storage.read<double>(_kFontSizeKey) ?? 19.0;
  }

  Future<void> saveFontSize(double size) async {
    await _storage.write(_kFontSizeKey, size);
  }
}
