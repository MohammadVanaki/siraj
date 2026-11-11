import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../data/models/nahj_commentary_model.dart';
import '../data/models/nahj_commentator_model.dart';
import '../data/models/nahj_entry_model.dart';
import '../data/repositories/nahj_repository.dart';
import 'nahj_controller.dart';

class NahjReaderController extends GetxController {
  final NahjRepository repository;

  NahjReaderController({required this.repository});

  final Rx<NahjEntryModel?> entry = Rx<NahjEntryModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isBookmarked = false.obs;

  // Reader Preferences
  final RxDouble fontSize = 19.0.obs;
  final RxString fontFamily = 'dijlah'.obs;
  final RxBool showTranslation = true.obs;

  // Commentaries
  final RxList<NahjCommentatorModel> commentators = <NahjCommentatorModel>[].obs;
  final Rx<NahjCommentatorModel?> selectedCommentator =
      Rx<NahjCommentatorModel?>(null);
  final Rx<NahjCommentaryModel?> activeCommentary =
      Rx<NahjCommentaryModel?>(null);
  final RxBool isLoadingCommentary = false.obs;
  final RxBool showCommentarySection = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
    _loadCommentators();

    // دریافت داده‌های پاس داده شده از صفحه لیست
    final args = Get.arguments;
    if (args is NahjEntryModel) {
      entry.value = args;
      _checkBookmark(args.id);
      repository.saveLastReadEntryId(args.id);
      // دریافت جزئیات و متن کامل از API
      fetchEntryDetail(args.id);
    } else if (args is String) {
      _checkBookmark(args);
      fetchEntryDetail(args);
    }
  }

  void _loadPreferences() {
    fontSize.value = repository.getFontSize();
    fontFamily.value = repository.getFontFamily();
    showTranslation.value = repository.getShowTranslation();
  }

  Future<void> _loadCommentators() async {
    try {
      final list = await repository.getCommentators();
      commentators.assignAll(list);
      final savedId = repository.getSelectedCommentatorId();
      if (savedId != null && list.any((c) => c.id == savedId)) {
        selectedCommentator.value = list.firstWhere((c) => c.id == savedId);
      } else if (list.isNotEmpty) {
        selectedCommentator.value = list.first;
      }
    } catch (e) {
      debugPrint('Error loading commentators: $e');
    }
  }

  void _checkBookmark(String id) {
    isBookmarked.value = repository.isBookmarked(id);
  }

  Future<void> fetchEntryDetail(String id) async {
    try {
      isLoading.value = true;
      final detailed = await repository.getEntryDetail(id);
      if (detailed != null) {
        entry.value = detailed;
        _checkBookmark(detailed.id);
        repository.saveLastReadEntryId(detailed.id);
        _syncActiveCommentary();
      }
    } catch (e) {
      debugPrint('Error fetching Nahj entry detail: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectCommentator(NahjCommentatorModel commentator) {
    selectedCommentator.value = commentator;
    repository.saveSelectedCommentatorId(commentator.id);
    _syncActiveCommentary();
  }

  Future<void> _syncActiveCommentary() async {
    final currentEntry = entry.value;
    final commentator = selectedCommentator.value;
    if (currentEntry == null || commentator == null) {
      activeCommentary.value = null;
      return;
    }

    // پیدا کردن شرح مربوط به این شارح در ورودی فعلی
    final commentarySummary = currentEntry.commentaries.firstWhereOrNull(
      (c) => c.commentatorId == commentator.id,
    );

    if (commentarySummary == null) {
      activeCommentary.value = null;
      return;
    }

    // اگر متن کامل شرح موجود است از همان استفاده کن
    if (commentarySummary.bodyArabic != null &&
        commentarySummary.bodyArabic!.isNotEmpty) {
      activeCommentary.value = commentarySummary;
      return;
    }

    // در غیر این صورت از API متن کامل را بخوان
    try {
      isLoadingCommentary.value = true;
      final fullCommentary =
          await repository.getCommentaryDetail(commentarySummary.id);
      if (fullCommentary != null) {
        activeCommentary.value = fullCommentary;
      } else {
        activeCommentary.value = commentarySummary;
      }
    } catch (e) {
      debugPrint('Error fetching full commentary: $e');
      activeCommentary.value = commentarySummary;
    } finally {
      isLoadingCommentary.value = false;
    }
  }

  void toggleBookmark(BuildContext context) {
    final current = entry.value;
    if (current == null) return;
    repository.toggleBookmark(current);
    isBookmarked.value = !isBookmarked.value;

    if (Get.isRegistered<NahjController>()) {
      Get.find<NahjController>().reloadBookmarks();
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isBookmarked.value
              ? 'تمت إضافة هذا المقطع إلى المفضلة 🌿'
              : 'تمت إزالة هذا المقطع من المفضلة',
          style: const TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.white),
        ),
        backgroundColor: Colors.teal.shade800,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void updateFontSize(double size) {
    fontSize.value = size.clamp(14.0, 36.0);
    repository.saveFontSize(fontSize.value);
  }

  void updateFontFamily(String family) {
    fontFamily.value = family;
    repository.saveFontFamily(family);
  }

  void toggleTranslation() {
    showTranslation.value = !showTranslation.value;
    repository.saveShowTranslation(showTranslation.value);
  }

  void toggleCommentarySection() {
    showCommentarySection.value = !showCommentarySection.value;
    if (showCommentarySection.value && activeCommentary.value == null) {
      _syncActiveCommentary();
    }
  }

  void copyText(BuildContext context) {
    final current = entry.value;
    if (current == null) return;

    final buffer = StringBuffer();
    buffer.writeln(current.titleArabic);
    if (current.titlePersian != null && current.titlePersian!.isNotEmpty) {
      buffer.writeln(current.titlePersian);
    }
    buffer.writeln('\n--- النص العربي ---');
    buffer.writeln(current.bodyArabic ?? current.excerptArabic ?? '');

    if (showTranslation.value &&
        current.bodyPersian != null &&
        current.bodyPersian!.isNotEmpty) {
      buffer.writeln('\n--- ترجمه فارسی ---');
      buffer.writeln(current.bodyPersian);
    }

    buffer.writeln('\n(من تطبيق السراج - نهج البلاغة)');

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'تم نسخ النص بنجاح 📋',
          style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.white),
        ),
        backgroundColor: Colors.teal.shade800,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void shareText() {
    final current = entry.value;
    if (current == null) return;

    final buffer = StringBuffer();
    buffer.writeln('«نهج البلاغة - ${current.titleArabic}»');
    if (current.titlePersian != null && current.titlePersian!.isNotEmpty) {
      buffer.writeln(current.titlePersian);
    }
    buffer.writeln('');
    buffer.writeln(current.bodyArabic ?? current.excerptArabic ?? '');

    if (showTranslation.value &&
        current.bodyPersian != null &&
        current.bodyPersian!.isNotEmpty) {
      buffer.writeln('\nترجمه:');
      buffer.writeln(current.bodyPersian);
    }

    buffer.writeln('\nمقتبس من تطبيق السراج المبارك');

    Share.share(buffer.toString(), subject: current.titleArabic);
  }
}
