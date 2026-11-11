import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

class DBHelper {
  static sqflite.Database? _db;
  // DatabaseFactory shared for all DB operations
  static late final sqflite.DatabaseFactory _dbFactory;

  static sqflite.DatabaseFactory get dbFactory => _dbFactory;

  static void initializeDatabaseFactory() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      _dbFactory = databaseFactoryFfi;
    } else {
      _dbFactory = sqflite.databaseFactory;
    }
  }

  /// Initialize and open the database, copy from assets if not exist
  static Future<sqflite.Database> initDb() async {
    if (_db != null) return _db!;

    // Get proper database directory path based on platform
    String dbPath;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      dbPath = await _dbFactory.getDatabasesPath();
    } else {
      dbPath = await sqflite.getDatabasesPath();
    }

    final dbDir = Directory(dbPath);
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }

    final path = join(dbPath, 'db.sqlite');

    // Copy database file from assets if it does not exist
    final exists = await File(path).exists();
    if (!exists) {
      final data = await rootBundle.load('assets/db/db.sqlite');
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(path).writeAsBytes(bytes, flush: true);
    }

    // Open database
    _db = await _dbFactory.openDatabase(path);
    return _db!;
  }

  static Future<void> closeDb() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
      print('Database closed successfully.');
    } else {
      print('Database was already closed.');
    }
  }

  /// Execute a simple query on the given table
  static Future<List<Map<String, dynamic>>> query(String table) async {
    final db = await initDb();
    return db.query(table);
  }

  /// Get all main book groups (TABLE books)
  static Future<List<Map<String, dynamic>>> getBooks() async {
    final db = await initDb();
    return await db.query('books', orderBy: 'id ASC');
  }

  /// Alias for backward compatibility
  static Future<List<Map<String, dynamic>>> getBookGroups() async {
    return await getBooks();
  }

  /// Get book info by bookId from TABLE books
  static Future<Map<String, dynamic>?> getBookById(int id) async {
    final db = await initDb();
    final result = await db.query('books', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  /// Get all sub-items (chapters/texts) for a specific book (TABLE book_text WHERE bid = books.id)
  static Future<List<Map<String, dynamic>>> getBookTextsByBookId(int bookId) async {
    final db = await initDb();
    return await db.query(
      'book_text',
      where: 'bid = ?',
      whereArgs: [bookId],
      orderBy: 'id ASC',
    );
  }

  /// Get a specific text page by its primary key id from TABLE book_text
  static Future<Map<String, dynamic>?> getBookTextById(int id) async {
    final db = await initDb();
    final result = await db.query('book_text', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  /// Toggle or update favorite status for a book_text item
  static Future<int> setFavorite(int id, bool isFav) async {
    final db = await initDb();
    return await db.update(
      'book_text',
      {'fav': isFav ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Run raw SQL query
  static Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    final db = await initDb();
    return db.rawQuery(sql, arguments);
  }
}
