import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mawsueat/app/features/home/data/models/daily_hadith_model.dart';
import 'package:share_plus/share_plus.dart';

class DailyHadithController extends GetxController {
  // Observable state for the current daily hadith
  final Rx<DailyHadithModel> currentHadith = const DailyHadithModel(
    speaker: 'قال رسول الله (صلى الله عليه وآله):',
    text: 'إِنِّي تَارِكٌ فِيكُمُ الثَّقَلَيْنِ: كِتَابَ اللَّهِ وَعِتْرَتِي أَهْلَ بَيْتِي، مَا إِنْ تَمَسَّكْتُمْ بِهِمَا لَنْ تَضِلُّوا أَبَداً',
    source: 'صحيح مسلم / بحار الأنوار',
  ).obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Curated list of Hadiths from Ahl al-Bayt (AS) for daily rotation
  static const List<DailyHadithModel> _defaultHadiths = [
    DailyHadithModel(
      speaker: 'قال رسول الله (صلى الله عليه وآله):',
      text: 'إِنِّي تَارِكٌ فِيكُمُ الثَّقَلَيْنِ: كِتَابَ اللَّهِ وَعِتْرَتِي أَهْلَ بَيْتِي، مَا إِنْ تَمَسَّكْتُمْ بِهِمَا لَنْ تَضِلُّوا أَبَداً',
      source: 'صحيح مسلم / بحار الأنوار',
    ),
    DailyHadithModel(
      speaker: 'قال أمير المؤمنين الإمام علي (عليه السلام):',
      text: 'قِيمَةُ كُلِّ امْرِئٍ مَا يُحْسِنُهُ، وَالعِلْمُ أَصْلُ كُلِّ خَيْرٍ',
      source: 'نهج البلاغة، الحكمة ٨١',
    ),
    DailyHadithModel(
      speaker: 'قالت سيدة نساء العالمين فاطمة الزهراء (عليها السلام):',
      text: 'خِيَارُكُمْ أَلْيَنُكُمْ مَنَاكِبَةً، وَأَكْرَمُهُمْ لِنِسَائِهِمْ',
      source: 'عوالم العلوم، ج ١١، ص ٩١٥',
    ),
    DailyHadithModel(
      speaker: 'قال الإمام الحسن المجتبى (عليه السلام):',
      text: 'أَحْسَنُ الحَسَنِ الخُلُقُ الحَسَنُ',
      source: 'الخصال، ص ٢٩',
    ),
    DailyHadithModel(
      speaker: 'قال سيد الشهداء الإمام الحسين (عليه السلام):',
      text: 'إِنَّ حَوَائِجَ النَّاسِ إِلَيْكُمْ مِنْ نِعَمِ اللَّهِ عَلَيْكُمْ فَلا تَمَلُّوا النِّعَمَ',
      source: 'بحار الأنوار، ج ٧١، ص ٣١٨',
    ),
    DailyHadithModel(
      speaker: 'قال الإمام علي بن الحسين زين العابدين (عليه السلام):',
      text: 'خَفِ اللَّهَ تَعَالَى لِقُدْرَتِهِ عَلَيْكَ، وَاسْتَحْيِ مِنْهُ لِقُرْبِهِ مِنْكَ',
      source: 'بحار الأنوار، ج ٧٨، ص ١٦٠',
    ),
    DailyHadithModel(
      speaker: 'قال الإمام محمد بن علي الباقر (عليه السلام):',
      text: 'إِنَّمَا يُدَاقُّ اللَّهُ العِبَادَ فِي الحِسَابِ يَوْمَ القِيَامَةِ عَلَى قَدْرِ مَا آتَاهُمْ مِنَ العُقُولِ فِي الدُّنْيَا',
      source: 'الكافي، ج ١، ص ١١',
    ),
    DailyHadithModel(
      speaker: 'قال الإمام جعفر بن محمد الصادق (عليه السلام):',
      text: 'أَحَبُّ إِخْوَانِي إِلَيَّ مَنْ أَهْدَى إِلَيَّ عُيُوبِي',
      source: 'الكافي، ج ٢، ص ٦٣٩',
    ),
    DailyHadithModel(
      speaker: 'قال الإمام موسى بن جعفر الكاظم (عليه السلام):',
      text: 'لَيْسَ مِنَّا مَنْ لَمْ يُحَاسِبْ نَفْسَهُ فِي كُلِّ يَوْمٍ',
      source: 'الكافي، ج ٢، ص ٤٥٣',
    ),
    DailyHadithModel(
      speaker: 'قال الإمام علي بن موسى الرضا (عليه السلام):',
      text: 'صَدِيقُ كُلِّ امْرِئٍ عَقْلُهُ، وَعَدُوُّهُ جَهْلُهُ',
      source: 'الكافي، ج ١، ص ١١',
    ),
    DailyHadithModel(
      speaker: 'قال الإمام محمد بن علي الجواد (عليه السلام):',
      text: 'المُؤْمِنُ يَحْتَاجُ إِلَى تَوْفِيقٍ مِنَ اللَّهِ، وَوَاعِظٍ مِنْ نَفْسِهِ، وَقَبُولٍ مِمَّنْ يَنْصَحُهُ',
      source: 'تحف العقول، ص ٤٥٧',
    ),
    DailyHadithModel(
      speaker: 'قال الإمام علي بن محمد الهادي (عليه السلام):',
      text: 'العِلْمُ وَرَاثَةٌ كَرِيمَةٌ، وَالآدَابُ حُلَلٌ مُجَدَّدَةٌ، وَالفِكْرُ مِرْآةٌ صَافِيَةٌ',
      source: 'بحار الأنوار، ج ٧٥، ص ٣٦٨',
    ),
    DailyHadithModel(
      speaker: 'قال الإمام الحسن بن علي العسكري (عليه السلام):',
      text: 'خَصْلَتَانِ لَيْسَ فَوْقَهُمَا شَيْءٌ: الإِيمَانُ بِاللَّهِ، وَنَفْعُ الإِخْوَانِ',
      source: 'تحف العقول، ص ٤٨٩',
    ),
    DailyHadithModel(
      speaker: 'قال الإمام المهدي المنتظر (عجل الله تعالى فرجه الشريف):',
      text: 'أَكْثِرُوا الدُّعَاءَ بِتَعْجِيلِ الفَرَجِ، فَإِنَّ ذَلِكَ فَرَجُكُمْ',
      source: 'كمال الدين، ج ٢، ص ٤٨٥',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    loadTodayHadith();
  }

  /// Selects a Hadith based on the day of the year (or can be refreshed)
  void loadTodayHadith() {
    final now = DateTime.now();
    final dayOfYear = int.parse("${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}");
    final index = dayOfYear % _defaultHadiths.length;
    currentHadith.value = _defaultHadiths[index];
  }

  /// Hook to fetch the daily Hadith from remote API once provided
  Future<void> fetchHadithFromApi(String apiUrl) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await http.get(Uri.parse(apiUrl)).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is Map<String, dynamic>) {
          currentHadith.value = DailyHadithModel.fromJson(data);
        } else if (data is List && data.isNotEmpty) {
          currentHadith.value = DailyHadithModel.fromJson(data.first);
        }
      } else {
        errorMessage.value = 'Failed to load hadith from API: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error fetching hadith: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Share current hadith
  void shareHadith() {
    Share.share(currentHadith.value.fullShareText);
  }

  /// Copy hadith text to clipboard
  Future<void> copyHadithToClipboard(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: currentHadith.value.fullShareText),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'تم نسخ الحديث الشريف بنجاح',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'IBMPlexSansArabic'),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
