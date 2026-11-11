import 'package:get_storage/get_storage.dart';
import '../models/nahj_category_model.dart';
import '../models/nahj_entry_model.dart';

class NahjLocalDataSource {
  final GetStorage _storage = GetStorage();

  static const String _categoriesKey = 'nahj_cached_categories';
  static const String _bookmarksKey = 'nahj_bookmarked_ids';
  static const String _bookmarkedEntriesKey = 'nahj_bookmarked_entries';
  static const String _lastReadEntryIdKey = 'nahj_last_read_entry_id';
  static const String _fontSizeKey = 'nahj_reader_font_size';
  static const String _fontFamilyKey = 'nahj_reader_font_family';
  static const String _showTranslationKey = 'nahj_reader_show_translation';
  static const String _selectedCommentatorKey = 'nahj_reader_selected_commentator';

  String _categoryCacheKey(String category) => 'nahj_cached_entries_$category';
  String _entryDetailCacheKey(String id) => 'nahj_cached_entry_detail_$id';

  // --- Categories Caching ---
  List<NahjCategoryModel> getCachedCategories() {
    final raw = _storage.read<List<dynamic>>(_categoriesKey);
    if (raw == null) return [];
    return raw
        .map((e) => NahjCategoryModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> saveCategories(List<NahjCategoryModel> categories) async {
    await _storage.write(
      _categoriesKey,
      categories.map((e) => e.toJson()).toList(),
    );
  }

  // --- Entries Caching ---
  List<NahjEntryModel> getCachedEntries(String category) {
    final raw = _storage.read<List<dynamic>>(_categoryCacheKey(category));
    if (raw == null) return [];
    return raw
        .map((e) => NahjEntryModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> saveEntries(String category, List<NahjEntryModel> entries) async {
    await _storage.write(
      _categoryCacheKey(category),
      entries.take(50).map((e) => e.toJson()).toList(),
    );
  }

  NahjEntryModel? getCachedEntryDetail(String id) {
    final raw = _storage.read<Map<String, dynamic>>(_entryDetailCacheKey(id));
    if (raw == null) return null;
    return NahjEntryModel.fromJson(raw);
  }

  Future<void> saveEntryDetail(NahjEntryModel entry) async {
    await _storage.write(_entryDetailCacheKey(entry.id), entry.toJson());

    // If this entry is bookmarked, keep the bookmarked entries list updated
    if (isBookmarked(entry.id)) {
      final list = getBookmarkedEntries();
      final idx = list.indexWhere((e) => e.id == entry.id);
      if (idx >= 0) {
        list[idx] = entry;
      } else {
        list.insert(0, entry);
      }
      await _storage.write(
        _bookmarkedEntriesKey,
        list.map((e) => e.toJson()).toList(),
      );
    }
  }

  // --- Bookmarks ---
  List<String> getBookmarkedIds() {
    final raw = _storage.read<List<dynamic>>(_bookmarksKey);
    if (raw == null) return [];
    return raw.map((e) => e.toString()).toList();
  }

  List<NahjEntryModel> getBookmarkedEntries() {
    final raw = _storage.read<List<dynamic>>(_bookmarkedEntriesKey);
    final List<NahjEntryModel> list = [];
    if (raw != null) {
      list.addAll(
        raw.map((e) => NahjEntryModel.fromJson(Map<String, dynamic>.from(e))),
      );
    }

    // Auto-recover any IDs previously saved in _bookmarksKey
    final ids = getBookmarkedIds();
    final existingIds = list.map((e) => e.id).toSet();
    bool needResave = false;

    for (final id in ids) {
      if (!existingIds.contains(id)) {
        final detail = getCachedEntryDetail(id);
        if (detail != null) {
          list.add(detail);
          existingIds.add(id);
          needResave = true;
        } else {
          for (final cat in ['sermons', 'letters', 'wisdom', 'rare_words']) {
            final catEntries = getCachedEntries(cat);
            final found = catEntries.where((e) => e.id == id).firstOrNull;
            if (found != null) {
              list.add(found);
              existingIds.add(id);
              needResave = true;
              break;
            }
          }
        }
      }
    }

    if (needResave) {
      _storage.write(
        _bookmarkedEntriesKey,
        list.map((e) => e.toJson()).toList(),
      );
    }

    return list;
  }

  Future<void> toggleBookmark(dynamic entryOrId) async {
    final currentIds = getBookmarkedIds();
    final entries = getBookmarkedEntries();

    String id;
    NahjEntryModel? model;

    if (entryOrId is NahjEntryModel) {
      model = entryOrId;
      id = entryOrId.id;
    } else {
      id = entryOrId.toString();
      model = entries.where((e) => e.id == id).firstOrNull ?? getCachedEntryDetail(id);
    }

    if (currentIds.contains(id)) {
      currentIds.remove(id);
      entries.removeWhere((e) => e.id == id);
    } else {
      currentIds.add(id);
      if (model != null) {
        entries.removeWhere((e) => e.id == id);
        entries.insert(0, model);
      }
    }

    await _storage.write(_bookmarksKey, currentIds);
    await _storage.write(
      _bookmarkedEntriesKey,
      entries.map((e) => e.toJson()).toList(),
    );
  }

  bool isBookmarked(String entryId) {
    return getBookmarkedIds().contains(entryId);
  }

  // --- Last Read ---
  String? getLastReadEntryId() {
    return _storage.read<String>(_lastReadEntryIdKey);
  }

  Future<void> saveLastReadEntryId(String entryId) async {
    await _storage.write(_lastReadEntryIdKey, entryId);
  }

  // --- Reader Preferences ---
  double getFontSize() {
    return _storage.read<double>(_fontSizeKey) ?? 19.0;
  }

  Future<void> saveFontSize(double size) async {
    await _storage.write(_fontSizeKey, size);
  }

  String getFontFamily() {
    return _storage.read<String>(_fontFamilyKey) ?? 'dijlah';
  }

  Future<void> saveFontFamily(String family) async {
    await _storage.write(_fontFamilyKey, family);
  }

  bool getShowTranslation() {
    return _storage.read<bool>(_showTranslationKey) ?? true;
  }

  Future<void> saveShowTranslation(bool show) async {
    await _storage.write(_showTranslationKey, show);
  }

  String? getSelectedCommentatorId() {
    return _storage.read<String>(_selectedCommentatorKey);
  }

  Future<void> saveSelectedCommentatorId(String id) async {
    await _storage.write(_selectedCommentatorKey, id);
  }
}
