import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../data/models/sahifa_dua_model.dart';
import '../data/repositories/sahifa_repository.dart';
import 'sahifa_controller.dart';

class SahifaReaderController extends GetxController {
  final SahifaRepository _repository = SahifaRepository();

  final dua = Rxn<SahifaDuaModel>();
  final isLoading = false.obs;
  final fontSize = 19.0.obs;
  final isBookmarked = false.obs;

  static const double minFontSize = 14.0;
  static const double maxFontSize = 32.0;

  @override
  void onInit() {
    super.onInit();
    fontSize.value = _repository.getSavedFontSize();

    final args = Get.arguments;
    if (args is SahifaDuaModel) {
      dua.value = args;
      _checkBookmark();
    } else if (args is String && args.isNotEmpty) {
      _loadDuaById(args);
    }
  }

  void _checkBookmark() {
    if (dua.value != null) {
      isBookmarked.value = _repository.isBookmarked(dua.value!.id);
    }
  }

  Future<void> _loadDuaById(String id) async {
    isLoading.value = true;
    try {
      final fetched = await _repository.getDuaById(id);
      dua.value = fetched;
      _checkBookmark();
    } finally {
      isLoading.value = false;
    }
  }

  void increaseFontSize() {
    if (fontSize.value < maxFontSize) {
      fontSize.value += 1.5;
      _repository.saveFontSize(fontSize.value);
    }
  }

  void decreaseFontSize() {
    if (fontSize.value > minFontSize) {
      fontSize.value -= 1.5;
      _repository.saveFontSize(fontSize.value);
    }
  }

  void resetFontSize() {
    fontSize.value = 19.0;
    _repository.saveFontSize(fontSize.value);
  }

  Future<void> toggleBookmark([BuildContext? context]) async {
    if (dua.value == null) return;
    final id = dua.value!.id;
    final newStatus = await _repository.toggleBookmark(id);
    isBookmarked.value = newStatus;

    // همگام‌سازی وضعیت با کنترلر صفحه لیست بدون تغییر مضاعف مخزن
    if (Get.isRegistered<SahifaController>()) {
      Get.find<SahifaController>().syncBookmarkStatus(id, newStatus);
    }

    HapticFeedback.lightImpact();

    if (context != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                newStatus ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                newStatus ? 'تمت إضافة الدعاء إلى المفضلة' : 'تمت إزالة الدعاء من المفضلة',
                style: const TextStyle(fontFamily: 'IBMPlexSansArabic'),
              ),
            ],
          ),
          duration: const Duration(milliseconds: 1400),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  /// کپی کل متن دعا به حافظه
  void copyFullDua(BuildContext context) {
    if (dua.value == null) return;
    final text = '${dua.value!.titleArabic}\n\n${dua.value!.bodyArabic}\n\n— منقول من الصحيفة السجادية (تطبيق السراج)';
    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'تم نسخ نص الدعاء بالكامل',
              style: TextStyle(fontFamily: 'IBMPlexSansArabic'),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// کپی یک فراز خاص
  void copyParagraph(BuildContext context, String paragraph) {
    Clipboard.setData(ClipboardData(text: paragraph));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.copy_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'تم نسخ هذه الصفحة',
              style: TextStyle(fontFamily: 'IBMPlexSansArabic'),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// اشتراک‌گذاری دعا
  void shareDua() {
    if (dua.value == null) return;
    final text = '${dua.value!.titleArabic}\n\n${dua.value!.bodyArabic}\n\n— الصحيفة السجادية المباركة | تطبيق السراج';
    Share.share(text, subject: dua.value!.titleArabic);
  }
}
