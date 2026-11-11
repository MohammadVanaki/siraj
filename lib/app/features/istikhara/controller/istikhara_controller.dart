import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/istikhara/data/models/istikhara_model.dart';
import 'package:mawsueat/app/features/istikhara/data/repositories/istikhara_repository.dart';
import 'package:share_plus/share_plus.dart';

class IstikharaController extends GetxController {
  final IstikharaRepository _repository;
  IstikharaController(this._repository);

  // States
  final isLoading = false.obs;
  final isTakingIstikhara = false.obs;
  final result = Rxn<IstikharaResultModel>();
  final etiquettes = <String>[].obs;
  final duaaText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    try {
      final futures = await Future.wait([
        _repository.getIstikharaEtiquettes(),
        _repository.getIstikharaDuaa(),
      ]);
      etiquettes.assignAll(futures[0] as List<String>);
      duaaText.value = futures[1] as String;
    } catch (e) {
      debugPrint('Error loading Istikhara initial data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> takeIstikhara() async {
    if (isTakingIstikhara.value) return;

    isTakingIstikhara.value = true;
    try {
      final newResult = await _repository.performIstikhara();
      result.value = newResult;
      // Provide subtle haptic feedback
      HapticFeedback.mediumImpact();
    } catch (e) {
      Get.rawSnackbar(
        message: 'تعذر إجراء الاستخارة، يرجى المحاولة مرة أخرى.',
        backgroundColor: Colors.red.withAlpha(200),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isTakingIstikhara.value = false;
    }
  }

  void reset() {
    result.value = null;
  }

  void copyResult() {
    final current = result.value;
    if (current == null) return;

    final text = '''
الاستخارة بالقرآن الكريم - تطبيق السراج
النتيجة: ${current.displayAnswer}
السورة: ${current.surahName} (آية ${current.ayahNumber} - صفحة ${current.pageNumber})
الآية: «${current.ayahText}»

التفسير والتوجيه:
${current.generalAdvice}
${current.workAdvice != null && current.workAdvice!.isNotEmpty ? '\nالعمل والتجارة: ${current.workAdvice}' : ''}
${current.marriageAdvice != null && current.marriageAdvice!.isNotEmpty ? '\nالزواج والارتباط: ${current.marriageAdvice}' : ''}
''';

    Clipboard.setData(ClipboardData(text: text));
    Get.rawSnackbar(
      message: 'تم نسخ نتيجة الاستخارة إلى الحافظة',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  void shareResult() {
    final current = result.value;
    if (current == null) return;

    final text = '''
📖 الاستخارة بالقرآن الكريم (تطبيق السراج)
━━━━━━━━━━━━━━━━━━━━
📌 النتيجة: ${current.displayAnswer}
📖 ${current.surahName} - آية ${current.ayahNumber} (ص ${current.pageNumber})
﴿${current.ayahText}﴾

🔹 التفسير والتوجيه:
${current.generalAdvice}

${current.workAdvice != null && current.workAdvice!.isNotEmpty ? '💼 العمل: ${current.workAdvice}\n' : ''}${current.marriageAdvice != null && current.marriageAdvice!.isNotEmpty ? '💍 الزواج: ${current.marriageAdvice}' : ''}
''';

    Share.share(text, subject: 'نتيجة الاستخارة');
  }
}
