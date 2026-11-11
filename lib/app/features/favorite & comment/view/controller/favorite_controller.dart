import 'dart:convert';

import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/constants/constants.dart';

class FavoriteController extends GetxController {
  RxInt selectedTabIndex = 1.obs;
  RxList<Map<String, dynamic>> commentsList = <Map<String, dynamic>>[].obs;

  RxList<Map<String, dynamic>> bookmarksList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadBookmarks();
    loadComments();
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  void loadBookmarks() {
    String? savedBookmarksJson = Constants.localStorage.read('bookmark');
    if (savedBookmarksJson != null) {
      try {
        var decoded = jsonDecode(savedBookmarksJson);
        if (decoded is List) {
          bookmarksList.value = List<Map<String, dynamic>>.from(decoded);
        } else if (decoded is Map) {
          bookmarksList.value = [Map<String, dynamic>.from(decoded)];
        }
      } catch (e) {
        print('❌ Failed to decode bookmarks: $e');
      }
    } else {
      bookmarksList.clear();
    }
  }

  void saveBookmarks() {
    String encodedBookmarks = jsonEncode(bookmarksList.toList());
    Constants.localStorage.write('bookmark', encodedBookmarks);
  }

  bool isBookmarked(int bookId, int pageNumber) {
    return bookmarksList.any(
      (bookmark) =>
          bookmark['bookId'].toString() == bookId.toString() &&
          bookmark['pageNumber'].toString() == pageNumber.toString(),
    );
  }

  bool toggleBookmark({
    required int bookId,
    required int pageNumber,
    required String bookName,
  }) {
    var index = bookmarksList.indexWhere(
      (bookmark) =>
          bookmark['bookId'].toString() == bookId.toString() &&
          bookmark['pageNumber'].toString() == pageNumber.toString(),
    );

    bool added;
    if (index != -1) {
      bookmarksList.removeAt(index);
      added = false;
    } else {
      bookmarksList.add({
        'bookId': bookId,
        'pageNumber': pageNumber,
        'bookName': bookName,
      });
      added = true;
    }
    saveBookmarks();
    return added;
  }

  void removeBookmarkAt(int bookId, int pageNumber) {
    var index = bookmarksList.indexWhere(
      (bookmark) =>
          bookmark['bookId'].toString() == bookId.toString() &&
          bookmark['pageNumber'].toString() == pageNumber.toString(),
    );
    if (index != -1) {
      bookmarksList.removeAt(index);
      saveBookmarks();
    } else {
      print(
          '❌ Bookmark not found for bookId: $bookId and pageNumber: $pageNumber');
    }
  }

  void clearAllBookmarks() {
    bookmarksList.clear();
    Constants.localStorage.remove('bookmark');
  }

  void loadComments() {
    final data = Constants.localStorage.read('allBookComments');
    if (data != null && data is List) {
      commentsList.value = List<Map<String, dynamic>>.from(data);
    } else {
      commentsList.clear();
    }
  }

  bool hasComment(int bookId, int pageNumber) {
    return commentsList.any(
      (c) =>
          c['idBook'].toString() == bookId.toString() &&
          c['idPage'].toString() == (pageNumber + 1).toString(),
    );
  }

  Map<String, dynamic>? getComment(int bookId, int pageNumber) {
    final index = commentsList.indexWhere(
      (c) =>
          c['idBook'].toString() == bookId.toString() &&
          c['idPage'].toString() == (pageNumber + 1).toString(),
    );
    if (index != -1) return commentsList[index];
    return null;
  }

  void saveComment({
    required int bookId,
    required String bookName,
    required int pageNumber,
    required String title,
    required String comment,
  }) {
    final existingIndex = commentsList.indexWhere(
      (c) =>
          c['idBook'].toString() == bookId.toString() &&
          c['idPage'].toString() == (pageNumber + 1).toString(),
    );

    final now = DateTime.now().toIso8601String();
    if (existingIndex != -1) {
      commentsList[existingIndex] = {
        ...commentsList[existingIndex],
        'title': title,
        'comment': comment,
        'updatedAt': now,
      };
    } else {
      commentsList.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'idBook': bookId,
        'bookName': bookName,
        'idPage': pageNumber + 1,
        'title': title,
        'comment': comment,
        'createdAt': now,
      });
    }
    commentsList.refresh();
    Constants.localStorage.write('allBookComments', commentsList.toList());
  }

  void deleteComment(dynamic commentId) {
    commentsList.removeWhere((comment) => comment['id'].toString() == commentId.toString());
    commentsList.refresh();
    Constants.localStorage.write('allBookComments', commentsList.toList());
  }
}
