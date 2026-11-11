import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/database/db_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

class MainSearchController extends GetxController {
  TextEditingController searchController = TextEditingController();

  var searchResults = <Map<String, dynamic>>[].obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  var resultCount = 0.obs;
  RxInt selectedBook = (-1).obs;
  RxBool inText = true.obs;
  RxBool inTitle = true.obs;

  Future<void> searchBooksInDb(
    String dbName,
    String searchWords,
    bool isTitleChecked,
    bool isDescriptionChecked,
    String bookName,
    int bookId,
  ) async {
    var results = await searchBooks(
      dbName,
      searchWords,
      isTitleChecked,
      isDescriptionChecked,
      bookName,
    );

    List<Map<String, dynamic>> bookResults = [];

    for (var result in results) {
      var updatedResult = Map<String, dynamic>.from(result);
      updatedResult['bookName'] = bookName;
      updatedResult['bookId'] = bookId;
      bookResults.add(updatedResult);
    }

    searchResults.addAll(bookResults);
    resultCount.value = searchResults.length;
  }

  void clearSearchResults() {
    searchResults.value = [];
    resultCount.value = 0;
  }
}

class Book {
  final int id;
  final String title;
  final String author;
  final int idShow;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.idShow,
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title:
          (map['title']?.toString() ?? '') +
          ((map['joz'] != null && map['joz'].toString() != '0')
              ? map['joz'].toString()
              : ''),
      author: map['writer'],
      idShow: map['id_show'] ?? 0,
    );
  }
}

Future<List<Map<String, dynamic>>> searchBooks(
  String bookId,
  String searchWords,
  bool isTitleChecked,
  bool isDescriptionChecked,
  String bookName,
) async {
  late String dbPath;
  late Database db;

  // 📦 مسیر دیتابیس داخل assets
  const assetDbPath = 'assets/db/db.sqlite';

  // 📁 پوشه‌ای برای کپی فایل دیتابیس
  final documentsDir = await getApplicationDocumentsDirectory();
  dbPath = p.join(documentsDir.path, 'db.sqlite');

  // ✅ اگه هنوز کپی نشده، از assets بیارش
  if (!await File(dbPath).exists()) {
    final data = await rootBundle.load(assetDbPath);
    final bytes = data.buffer.asUint8List();
    await File(dbPath).writeAsBytes(bytes, flush: true);
    print('📥 Copied database from assets to: $dbPath');
  } else {
    print('✅ Database already exists at: $dbPath');
  }

  // 📂 باز کردن دیتابیس
  db = await openDatabase(dbPath);

  List<Map<String, dynamic>> results = [];

  // 🔍 جستجو در عنوان
  if (isTitleChecked) {
    final titleResults = await db.rawQuery(
      'SELECT * FROM book_text WHERE title LIKE ?',
      ['%$searchWords%'],
    );
    results.addAll(titleResults);
  }

  // 🔍 جستجو در متن
  if (isDescriptionChecked) {
    final descriptionResults = await db.rawQuery(
      'SELECT * FROM book_text WHERE _text LIKE ?',
      ['%$searchWords%'],
    );
    results.addAll(descriptionResults);
  }

  await db.close();
  return results;
}

Future<String> getDownloadsDirectoryPath() async {
  if (Platform.isWindows) {
    final userProfile = Platform.environment['USERPROFILE'];
    if (userProfile != null) {
      return p.join(userProfile, 'Downloads');
    }
  } else if (Platform.isMacOS) {
    final home = Platform.environment['HOME'];
    if (home != null) {
      return p.join(home, 'Downloads');
    }
  }

  throw UnsupportedError(
    'Downloads directory is not supported on this platform',
  );
}

Future<Directory> getWindowsSaveDirectory() async {
  final appSupportDir = await getApplicationSupportDirectory();

  final alraheeqDir = Directory(p.join(appSupportDir.path, 'alraheeq'));

  if (!await alraheeqDir.exists()) {
    await alraheeqDir.create(recursive: true);
  }

  return alraheeqDir;
}
