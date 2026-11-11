import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/constants/api_constants.dart';
import 'package:mawsueat/app/core/common/constants/constants.dart';
import 'package:mawsueat/app/core/network/api_client.dart';

class ContentRepository {
  ApiClient get _apiClient {
    if (Get.isRegistered<ApiClient>()) {
      return Get.find<ApiClient>();
    }
    return Get.put(ApiClient(), permanent: true);
  }

  /// دریافت لیست کتاب‌ها / موسوعه‌ها از سرور
  /// GET /api/v1/encyclopedia/books
  Future<List<Map<String, dynamic>>> getBooks() async {
    try {
      final response = await _apiClient.get(ApiConstants.encyclopediaBooks);
      if (response['success'] == true && response['data'] is List) {
        return List<Map<String, dynamic>>.from(
          (response['data'] as List).map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [];
    } catch (e) {
      print('❌ Error fetching encyclopedia books: $e');
      rethrow;
    }
  }

  /// دریافت زیرمجموعه‌ها (ورودی‌های) یک کتاب
  /// GET /api/v1/encyclopedia/books/{bookId}/entries?page={page}&limit={limit}
  Future<List<Map<String, dynamic>>> getBookEntries(
    int bookId, {
    int page = 1,
    int limit = 100,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.encyclopediaBookEntries(bookId),
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );
      if (response['success'] == true && response['data'] is List) {
        return List<Map<String, dynamic>>.from(
          (response['data'] as List).map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [];
    } catch (e) {
      print('❌ Error fetching entries for book $bookId: $e');
      rethrow;
    }
  }

  /// دریافت تمامی زیرمجموعه‌های یک کتاب (صفحه‌بندی شده کامل)
  Future<List<Map<String, dynamic>>> getAllBookEntries(int bookId) async {
    final allEntries = <Map<String, dynamic>>[];
    int currentPage = 1;
    const limit = 100;

    while (true) {
      try {
        final response = await _apiClient.get(
          ApiConstants.encyclopediaBookEntries(bookId),
          queryParameters: {
            'page': currentPage.toString(),
            'limit': limit.toString(),
          },
        );

        if (response['success'] == true && response['data'] is List) {
          final list = List<Map<String, dynamic>>.from(
            (response['data'] as List).map((e) => Map<String, dynamic>.from(e)),
          );
          if (list.isEmpty) break;
          allEntries.addAll(list);

          // اگر تعداد دریافت شده کمتر از لیمیت بود یعنی به انتهای لیست رسیده‌ایم
          if (list.length < limit) break;
          currentPage++;
        } else {
          break;
        }
      } catch (e) {
        print('❌ Error loading all entries for book $bookId at page $currentPage: $e');
        break;
      }
    }

    return allEntries;
  }

  /// دریافت متن کامل یک ورودی
  /// GET /api/v1/encyclopedia/entries/{entryId}
  Future<Map<String, dynamic>?> getEntryDetail(int entryId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.encyclopediaEntryDetail(entryId),
      );
      if (response['success'] == true && response['data'] is Map) {
        return Map<String, dynamic>.from(response['data']);
      }
      return null;
    } catch (e) {
      print('❌ Error fetching entry detail for id $entryId: $e');
      return null;
    }
  }

  /// جستجو در موسوعه از طریق سرور
  /// GET /api/v1/encyclopedia/search?q={query}&page={page}
  Future<List<Map<String, dynamic>>> searchEncyclopedia(
    String query, {
    int page = 1,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.encyclopediaSearch,
        queryParameters: {
          'q': query,
          'page': page.toString(),
        },
      );
      if (response['success'] == true && response['data'] is List) {
        return List<Map<String, dynamic>>.from(
          (response['data'] as List).map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [];
    } catch (e) {
      print('❌ Error searching encyclopedia: $e');
      return [];
    }
  }
}

void toggleBookmark(dynamic bookId, String bookTitle) {
  final id = bookId.toString();

  final bookmarks = Map<String, String>.from(
    Constants.localStorage.read('bookmarks') ?? {},
  );

  if (bookmarks.containsKey(id)) {
    bookmarks.remove(id);
  } else {
    bookmarks[id] = bookTitle;
  }

  Constants.localStorage.write('bookmarks', bookmarks);
}
