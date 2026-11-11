import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mawsueat/app/core/database/db_helper.dart';
import 'package:mawsueat/app/features/library/data/models/book_content_model.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

class BookDbService {
  final Map<String, sqflite.Database> _openDatabases = {};

  Future<sqflite.Database> _getOrOpenDb(String dbPath) async {
    final existing = _openDatabases[dbPath];
    if (existing != null && existing.isOpen) {
      return existing;
    }

    final file = File(dbPath);
    if (!await file.exists()) {
      throw Exception('ملف قاعدة البيانات غير موجود في المسار: $dbPath');
    }

    final db = await DBHelper.dbFactory.openDatabase(dbPath);
    _openDatabases[dbPath] = db;
    return db;
  }

  /// پیدا کردن خودکار نام جدول‌ها (مانند b15_pages یا b364_chapters)
  Future<String?> _findTableName(sqflite.Database db, String pattern) async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name LIKE ? ORDER BY name ASC",
      ['%$pattern'],
    );
    if (tables.isNotEmpty) {
      return tables.first['name'] as String?;
    }
    return null;
  }

  Future<String> _getPagesTableName(sqflite.Database db) async {
    final name = await _findTableName(db, '_pages');
    return name ?? 'pages';
  }

  Future<String> _getChaptersTableName(sqflite.Database db) async {
    final name = await _findTableName(db, '_chapters');
    return name ?? 'chapters';
  }

  /// دریافت تعداد کل صفحات کتاب
  Future<int> getTotalPages(String dbPath) async {
    try {
      final db = await _getOrOpenDb(dbPath);
      final pagesTable = await _getPagesTableName(db);
      final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM $pagesTable');
      if (countResult.isNotEmpty) {
        return (countResult.first['count'] as int?) ?? 1;
      }
      return 1;
    } catch (e) {
      debugPrint('Error getting total pages: $e');
      return 1;
    }
  }

  /// دریافت سرفصل‌ها و فصول کتاب (TABLE b_chapters)
  Future<List<BookChapterModel>> getChapters(String dbPath) async {
    try {
      final db = await _getOrOpenDb(dbPath);
      final chaptersTable = await _getChaptersTableName(db);
      final exists = await _findTableName(db, chaptersTable);
      if (exists == null) return [];

      final rows = await db.query(chaptersTable, orderBy: 'id ASC');
      return rows.map((r) => BookChapterModel.fromMap(r)).toList();
    } catch (e) {
      debugPrint('Error getting book chapters: $e');
      return [];
    }
  }

  /// دریافت محتوای یک صفحه خاص بر اساس شماره صفحه
  Future<BookPageModel?> getPage(String dbPath, int pageNumber) async {
    try {
      final db = await _getOrOpenDb(dbPath);
      final pagesTable = await _getPagesTableName(db);

      // جستجو با رشته یا عدد
      var rows = await db.query(
        pagesTable,
        where: 'page = ?',
        whereArgs: [pageNumber.toString()],
        limit: 1,
      );

      // اگر با شماره رشته‌ای پیدا نشد، با id / offset بررسی می‌کنیم
      if (rows.isEmpty) {
        rows = await db.query(
          pagesTable,
          offset: pageNumber > 0 ? pageNumber - 1 : 0,
          limit: 1,
        );
      }

      if (rows.isNotEmpty) {
        return BookPageModel.fromMap(rows.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting page $pageNumber: $e');
      return null;
    }
  }

  /// دریافت دسته‌ای از صفحات
  Future<List<BookPageModel>> getPages(
    String dbPath, {
    int offset = 0,
    int limit = 50,
  }) async {
    try {
      final db = await _getOrOpenDb(dbPath);
      final pagesTable = await _getPagesTableName(db);
      final rows = await db.query(
        pagesTable,
        orderBy: 'id ASC',
        offset: offset,
        limit: limit,
      );
      return rows.map((r) => BookPageModel.fromMap(r)).toList();
    } catch (e) {
      debugPrint('Error getting batch pages: $e');
      return [];
    }
  }

  /// جستجو در تمام صفحات کتاب
  Future<List<BookSearchResultModel>> searchInBook(
    String dbPath,
    String query,
  ) async {
    if (query.trim().isEmpty) return [];

    try {
      final db = await _getOrOpenDb(dbPath);
      final pagesTable = await _getPagesTableName(db);
      final chapters = await getChapters(dbPath);

      final cleanQuery = query.trim();
      final rows = await db.query(
        pagesTable,
        where: '_text LIKE ? OR page = ?',
        whereArgs: ['%$cleanQuery%', cleanQuery],
        limit: 100,
      );

      final results = <BookSearchResultModel>[];
      for (final row in rows) {
        final pageModel = BookPageModel.fromMap(row);
        final text = pageModel.text;

        // یافتن نام فصل مناسب برای این صفحه
        String chapterTitle = '';
        for (final ch in chapters.reversed) {
          if (ch.pageNumber <= pageModel.pageNumber) {
            chapterTitle = ch.title;
            break;
          }
        }

        // استخراج برش متن تمیز بدون تگ‌های HTML اطراف کلمه جستجو شده
        final cleanText = text.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
        String snippet = '';
        final matchIdx = cleanText.toLowerCase().indexOf(cleanQuery.toLowerCase());
        if (matchIdx != -1) {
          final start = (matchIdx - 40).clamp(0, cleanText.length);
          final end = (matchIdx + cleanQuery.length + 60).clamp(0, cleanText.length);
          snippet = '...${cleanText.substring(start, end).trim()}...';
        } else {
          snippet = cleanText.length > 80 ? '${cleanText.substring(0, 80)}...' : cleanText;
        }

        results.add(BookSearchResultModel(
          pageNumber: pageModel.pageNumber,
          chapterTitle: chapterTitle,
          snippet: snippet,
        ));
      }

      return results;
    } catch (e) {
      debugPrint('Error searching in book: $e');
      return [];
    }
  }

  /// نشانه‌گذاری صفحه (Favorite / Bookmark)
  Future<bool> setBookmark(String dbPath, int pageNumber, bool fav) async {
    try {
      final db = await _getOrOpenDb(dbPath);
      final pagesTable = await _getPagesTableName(db);
      final count = await db.update(
        pagesTable,
        {'fav': fav ? 1 : 0},
        where: 'page = ?',
        whereArgs: [pageNumber.toString()],
      );
      return count > 0;
    } catch (e) {
      debugPrint('Error updating bookmark: $e');
      return false;
    }
  }

  /// دریافت صفحات نشانه‌گذاری شده
  Future<List<BookPageModel>> getBookmarkedPages(String dbPath) async {
    try {
      final db = await _getOrOpenDb(dbPath);
      final pagesTable = await _getPagesTableName(db);
      final rows = await db.query(
        pagesTable,
        where: 'fav = ?',
        whereArgs: [1],
        orderBy: 'id ASC',
      );
      return rows.map((r) => BookPageModel.fromMap(r)).toList();
    } catch (e) {
      debugPrint('Error getting bookmarked pages: $e');
      return [];
    }
  }

  /// بستن دیتابیس
  Future<void> closeDb(String dbPath) async {
    final db = _openDatabases.remove(dbPath);
    if (db != null && db.isOpen) {
      await db.close();
    }
  }

  /// بستن همه دیتابیس‌های باز
  Future<void> closeAll() async {
    for (final db in _openDatabases.values) {
      if (db.isOpen) {
        await db.close();
      }
    }
    _openDatabases.clear();
  }
}
