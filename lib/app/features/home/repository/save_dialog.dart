import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/constants/constants.dart';

void showSaveBookDialog(BuildContext context, String bookName, int currentPage,
    int bookId, int total) {
  print(bookName);
  Get.dialog(
    barrierDismissible: false,
    Dialog(
      backgroundColor: Get.theme.colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400), 
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'احفظ الكتاب',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Get.theme.colorScheme.onPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'هل ترغب في حفظ الكتاب لقرائته لاحقًا؟',
                style: TextStyle(
                  fontSize: 16,
                  color: Get.theme.colorScheme.onPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Get.back();
                      Get.back();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      backgroundColor: Colors.red.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('لا'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      saveOrUpdateBook(
                          currentPage: currentPage,
                          id: bookId.toString(),
                          name: bookName,
                          totalPages: total);
                      Get.back();
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      backgroundColor: Colors.green.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('نعم'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> saveOrUpdateBook({
  required String id,
  required String name,
  required int currentPage,
  required int totalPages,
}) async {
  List<Book> books = await getBooksList();

  int index = books.indexWhere((book) => book.id == id);
  if (index != -1) {
    books[index].currentPage = currentPage;
    books[index].totalPages = totalPages;
  } else {
    books.add(Book(
      id: id,
      name: name,
      currentPage: currentPage,
      totalPages: totalPages,
    ));
  }

  if (books.length > 10) {
    books.removeAt(
        0); // Remove the first (oldest) book to keep the list at 10 items
  }

  await Constants.localStorage.write(
    'books',
    books.map((book) => book.toMap()).toList(),
  );
}

Future<List<Book>> getBooksList() async {
  List? storedBooks = Constants.localStorage.read('books');
  if (storedBooks == null) {
    return [];
  } else {
    return storedBooks
        .map((bookMap) => Book.fromMap(bookMap))
        .toList()
        .cast<Book>();
  }
}

class Book {
  String id;
  String name;
  int currentPage;
  int totalPages;

  Book({
    required this.id,
    required this.name,
    required this.currentPage,
    required this.totalPages,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'currentPage': currentPage,
      'totalPages': totalPages,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      name: map['name'],
      currentPage: map['currentPage'],
      totalPages: map['totalPages'],
    );
  }
}
