import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/favorite%20&%20comment/view/controller/favorite_controller.dart';

class ModalComment {
  static void show(
    BuildContext context, {
    required int idBook,
    required String bookname,
    required int idPage,
    required bool updateMode,
    required int id,
    String? oldTitle,
    String? oldComment,
  }) {
    final TextEditingController titleController = TextEditingController(
      text: oldTitle ?? '',
    );
    final TextEditingController contentController = TextEditingController(
      text: oldComment ?? '',
    );

    final FavoriteController favoriteController =
        Get.isRegistered<FavoriteController>()
            ? Get.find<FavoriteController>()
            : Get.put(FavoriteController());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 20,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
            ),
            child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit_note_rounded,
                      size: 24,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        updateMode ? 'تعديل التعليق' : 'إضافة تعليق جديد',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                Text(
                  "$bookname (ص $idPage)",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const Gap(16),

                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'عنوان التعليق (اختياري)',
                    labelStyle: const TextStyle(color: Colors.black45, fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimary,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const Gap(12),

                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'نص التعليق *',
                    labelStyle: const TextStyle(color: Colors.black45, fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimary,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),

                const Gap(20),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    const Gap(12),
                    ElevatedButton(
                      onPressed: () {
                        final String commentText = contentController.text.trim();
                        if (commentText.isEmpty) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'يرجى كتابة نص التعليق أولاً',
                                style: TextStyle(fontFamily: 'IBMPlexSansArabic'),
                                textDirection: TextDirection.rtl,
                              ),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                          return;
                        }

                        final String titleText = titleController.text.trim();

                        // حفظ في FavoriteController والتخزين المحلي
                        favoriteController.saveComment(
                          bookId: idBook,
                          bookName: bookname,
                          pageNumber: idPage - 1,
                          title: titleText.isNotEmpty ? titleText : bookname,
                          comment: commentText,
                        );

                        Navigator.pop(sheetContext);

                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              updateMode
                                  ? 'تم تحديث التعليق بنجاح'
                                  : 'تمت إضافة التعليق بنجاح',
                              style: const TextStyle(fontFamily: 'IBMPlexSansArabic'),
                              textDirection: TextDirection.rtl,
                            ),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.onPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        updateMode ? 'تحديث' : 'حفظ التعليق',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Gap(8),
              ],
            ),
          ),
        ),
      );
    },
    );
  }
}
