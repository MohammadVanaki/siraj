import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/widgets/custom_app_bar.dart';
import 'package:mawsueat/app/core/common/widgets/empty_widget.dart';
import 'package:mawsueat/app/core/common/widgets/internal_page.dart';
import 'package:mawsueat/app/features/search/view/controller/search_controller.dart';
import 'package:mawsueat/app/features/search/view/widgets/search_item.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});
  @override
  Widget build(BuildContext context) {
    final mainSearchController = Get.put(MainSearchController());

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'البحث',
      ),
      body: InternalPage(
        child: Column(
          children: [
            // Input
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: mainSearchController.formKey,
                child: TextFormField(
                  controller: mainSearchController.searchController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'بحث...',
                    hintStyle: TextStyle(
                      color: Theme.of(context).hintColor.withAlpha(200),
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimary.withAlpha(250),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimary.withAlpha(70),
                      ),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        // Validate the form and perform search when search icon is pressed
                        if (mainSearchController.formKey.currentState
                                ?.validate() ??
                            false) {
                          searchInSelectedBooks(
                            mainSearchController.searchController.text.trim(),
                          );
                        }
                      },
                      icon: Icon(
                        Icons.search,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  cursorColor: Theme.of(context).colorScheme.primary,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 3) {
                      return 'يتطلب البحث إدخال 3 أحرف أو أكثر';
                    }
                    return null;
                  },
                  // onEditingComplete: () {
                  //   print('DONE    <');
                  //   FocusScope.of(context).unfocus();
                  //   if (mainSearchController.formKey.currentState?.validate() ??
                  //       false) {
                  //     searchInSelectedBooks(
                  //       mainSearchController.searchController.text.trim(),
                  //     );
                  //   }
                  // },
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).unfocus();
                    print('DONE    <');
                    if (mainSearchController.formKey.currentState?.validate() ??
                        false) {
                      searchInSelectedBooks(value.trim());
                    }
                  },
                ),
              ),
            ),

            const Gap(10),
            Obx(() {
              if (mainSearchController.resultCount.value != 0) {
                return Text(
                  'عدد النتائج: ${mainSearchController.resultCount.value}',
                  style: TextStyle(fontSize: 15),
                );
              } else {
                return SizedBox.shrink();
              }
            }),
            Obx(() {
              // بررسی اگر متغیر جستجو تغییر کرده باشد
              bool hasSearchText =
                  mainSearchController.searchController.text.isNotEmpty;
              bool hasResults = mainSearchController.searchResults.isNotEmpty;

              return Expanded(
                child: hasSearchText
                    ? hasResults
                          ? ListView.builder(
                              itemCount:
                                  mainSearchController.searchResults.length,
                              itemBuilder: (context, index) {
                                var book =
                                    mainSearchController.searchResults[index];
                                String bookName =
                                    book['bookName'] ??
                                    'نام کتاب در دسترس نیست';

                                return SearchItem(
                                  title:
                                      book['title'] ??
                                      book['_text'] ??
                                      'عنوان پیش‌فرض',
                                  page: book['page'] ?? '0',
                                  bookName: bookName,
                                  searchWords: mainSearchController
                                      .searchController
                                      .text
                                      .trim(),
                                  bookId: book['bookId'].toString(),
                                );
                              },
                            )
                          : Center(
                              child: SingleChildScrollView(
                                child: EmptyWidget(
                                  title: 'لم يتم العثور على نتيجة',
                                ),
                              ),
                            )
                    : SizedBox(),
              );
            }),
          ],
        ),
      ),
    );
  }

  void searchInSelectedBooks(String searchWords) {
    // Getting the controller instance
    final mainSearchController = Get.find<MainSearchController>();
    mainSearchController.searchResults.clear();
    print(
      'mainSearchController.selectedBook: ${mainSearchController.selectedBook}',
    ); // Debug print

    mainSearchController.searchBooksInDb(
      'db.sqlite',
      searchWords,
      mainSearchController.inTitle.value,
      mainSearchController.inText.value,
      'الحبوة في مناسك الحجّ والعمرة',
      885,
    );
  }
}
