import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../data/models/mafatih_item_model.dart';
import '../data/repositories/mafatih_repository.dart';
import 'mafatih_controller.dart';

class MafatihReaderController extends GetxController {
  final MafatihRepository _repository = MafatihRepository();

  final Rxn<MafatihItemModel> currentItem = Rxn<MafatihItemModel>();
  final RxBool isLoadingDetail = false.obs;
  final RxDouble fontSize = 21.0.obs;
  final RxBool isBookmarked = false.obs;

  static const double minFontSize = 16.0;
  static const double maxFontSize = 34.0;

  @override
  void onInit() {
    super.onInit();
    fontSize.value = _repository.getSavedFontSize(fallback: 21.0);

    // دریافت داده از Arguments
    final args = Get.arguments;
    if (args is MafatihItemModel) {
      currentItem.value = args;
      isBookmarked.value = _repository.isBookmarked(args.id);
      _loadFreshDetail(args.id);
    } else if (args is String) {
      _loadItemById(args);
    }
  }

  Future<void> _loadItemById(String id) async {
    isLoadingDetail.value = true;
    try {
      final item = await _repository.getItemById(id);
      if (item != null) {
        currentItem.value = item;
        isBookmarked.value = _repository.isBookmarked(item.id);
      }
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<void> _loadFreshDetail(String id) async {
    final fresh = await _repository.getItemById(id);
    if (fresh != null && fresh.bodyArabic.isNotEmpty) {
      currentItem.value = fresh;
    }
  }

  void updateFontSize(double newSize) {
    final clamped = newSize.clamp(minFontSize, maxFontSize);
    fontSize.value = clamped;
    _repository.saveFontSize(clamped);
  }

  void increaseFontSize() {
    updateFontSize(fontSize.value + 1.5);
  }

  void decreaseFontSize() {
    updateFontSize(fontSize.value - 1.5);
  }

  void resetFontSize() {
    updateFontSize(21.0);
  }

  Future<void> toggleBookmark(BuildContext context) async {
    final item = currentItem.value;
    if (item == null) return;

    HapticFeedback.lightImpact();
    final bool newStatus = await _repository.toggleBookmark(item.id);
    isBookmarked.value = newStatus;

    // هماهنگ‌سازی با کنترلر لیست
    if (Get.isRegistered<MafatihController>()) {
      Get.find<MafatihController>().syncBookmarkStatus(item.id, newStatus);
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              newStatus ? Icons.bookmark_added_rounded : Icons.bookmark_remove_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              newStatus ? 'تمت الإضافة إلى المحفوظات' : 'تمت الإزالة من المحفوظات',
              style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 13),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF1B4965),
      ),
    );
  }

  Future<void> copyParagraph(BuildContext context, String text, int index) async {
    HapticFeedback.lightImpact();
    await Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              'تم نسخ صفحة ${MafatihItemModel.toArabicDigits(index + 1)}',
              style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 13),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF1B4965),
      ),
    );
  }

  Future<void> copyFullText(BuildContext context) async {
    final item = currentItem.value;
    if (item == null) return;

    final full = '${item.titleArabic}\n\n${item.bodyArabic}';
    await Clipboard.setData(ClipboardData(text: full));

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'تم نسخ كامل النص بنجاح',
              style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 13),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF1B4965),
      ),
    );
  }

  Future<void> shareText(BuildContext context) async {
    final item = currentItem.value;
    if (item == null) return;

    final shareContent = '''
${item.titleArabic}
من كتاب مفاتيح الجنان

${item.bodyArabic}

(تطبيق السراج)
''';

    await Share.share(
      shareContent,
      subject: item.titleArabic,
    );
  }
}
