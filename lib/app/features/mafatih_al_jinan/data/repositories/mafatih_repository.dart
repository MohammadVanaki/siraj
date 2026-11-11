import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import '../data_sources/mafatih_remote_data_source.dart';
import '../models/mafatih_item_model.dart';

class MafatihRepository {
  final MafatihRemoteDataSource _remoteDataSource = MafatihRemoteDataSource();
  final GetStorage _storage = GetStorage();

  static const String _kCachedItemsKey = 'mafatih_cached_items_v1';
  static const String _kBookmarksKey = 'mafatih_bookmarks_ids_v1';
  static const String _kFontSizeKey = 'mafatih_reader_font_size';

  /// دریافت ادعیه و زیارات با استراتژی کش-اول برای سرعت بارگذاری آنی
  Future<List<MafatihItemModel>> getItems({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = getCachedItems();
      if (cached.isNotEmpty) {
        _fetchAndCacheSilently();
        return cached;
      }
    }

    try {
      final remoteList = await _remoteDataSource.getItemsList();
      if (remoteList.isNotEmpty) {
        await _saveToCache(remoteList);
        return remoteList;
      }
    } catch (e) {
      debugPrint('MafatihRepository: failed to fetch remote items, checking cache: $e');
      final fallback = getCachedItems();
      if (fallback.isNotEmpty) return fallback;
      rethrow;
    }

    return getCachedItems();
  }

  /// دریافت یک مورد بر اساس ID
  Future<MafatihItemModel?> getItemById(String id) async {
    final cached = getCachedItems();
    final localMatch = cached.where((d) => d.id == id);
    if (localMatch.isNotEmpty) {
      return localMatch.first;
    }
    return await _remoteDataSource.getItemDetail(id);
  }

  /// خواندن موارد کش‌شده از حافظه آفلاین
  List<MafatihItemModel> getCachedItems() {
    try {
      final raw = _storage.read<List>(_kCachedItemsKey);
      if (raw != null) {
        return raw
            .map((e) => MafatihItemModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      debugPrint('Error reading cached Mafatih items: $e');
    }
    return [];
  }

  Future<void> _saveToCache(List<MafatihItemModel> items) async {
    try {
      final raw = items.map((e) => e.toJson()).toList();
      await _storage.write(_kCachedItemsKey, raw);
    } catch (e) {
      debugPrint('Error caching Mafatih items: $e');
    }
  }

  void _fetchAndCacheSilently() {
    _remoteDataSource.getItemsList().then((fresh) {
      if (fresh.isNotEmpty) {
        _saveToCache(fresh);
      }
    }).catchError((_) {});
  }

  /// بوک‌مارک‌ها / نشان‌شده‌ها
  Set<String> getBookmarkedIds() {
    try {
      final list = _storage.read<List>(_kBookmarksKey);
      if (list != null) {
        return list.map((e) => e.toString()).toSet();
      }
    } catch (e) {
      debugPrint('Error reading Mafatih bookmarks: $e');
    }
    return <String>{};
  }

  Future<bool> toggleBookmark(String id) async {
    final bookmarks = getBookmarkedIds();
    final bool willBeBookmarked = !bookmarks.contains(id);

    if (willBeBookmarked) {
      bookmarks.add(id);
    } else {
      bookmarks.remove(id);
    }

    await _storage.write(_kBookmarksKey, bookmarks.toList());
    return willBeBookmarked;
  }

  bool isBookmarked(String id) {
    return getBookmarkedIds().contains(id);
  }

  /// سایز قلم مطالعه ذخیره‌شده
  double getSavedFontSize({double fallback = 20.0}) {
    final val = _storage.read<num>(_kFontSizeKey);
    return val?.toDouble() ?? fallback;
  }

  Future<void> saveFontSize(double size) async {
    await _storage.write(_kFontSizeKey, size);
  }
}
