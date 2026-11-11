import 'dart:math';
import 'package:mawsueat/app/features/istikhara/data/models/istikhara_model.dart';
import 'package:mawsueat/app/features/istikhara/data/repositories/istikhara_repository.dart';

class MockIstikharaRepository implements IstikharaRepository {
  final Random _random = Random();

  final List<IstikharaResultModel> _mockResults = [
    IstikharaResultModel(
      id: 1,
      surahName: 'سورة يوسف',
      surahNumber: 12,
      ayahNumber: 56,
      pageNumber: 242,
      ayahText: 'وَكَذَٰلِكَ مَكَّنَّا لِيُوسُفَ فِي الْأَرْضِ يَتَبَوَّأُ مِنْهَا حَيْثُ يَشَاءُ ۚ نُصِيبُ بِرَحْمَتِنَا مَن نَّشَاءُ ۖ وَلَا نُضِيعُ أَجْرَ الْمُحْسِنِينَ',
      status: IstikharaStatus.veryGood,
      generalAdvice: 'الأمر مبارك جداً وفيه فتح عظيم وتوفيق إلهي. ستنال فيه مكانة رفيعة وتيسيراً لما تسعى إليه، فتوكل على الله وباشر بالأمر دون تردد.',
      workAdvice: 'تجارة رابحة وعمل مثمر يفتح لك أبواب الرزق والتمكين بإذن الله.',
      marriageAdvice: 'زواج مبارك وميمون يحمل التوافق والسعادة والبركة للطرفين.',
    ),
    IstikharaResultModel(
      id: 2,
      surahName: 'سورة البقرة',
      surahNumber: 2,
      ayahNumber: 216,
      pageNumber: 34,
      ayahText: 'وَعَسَىٰ أَن تَكْرَهُوا شَيْئًا وَهُوَ خَيْرٌ لَّكُمْ ۖ وَعَسَىٰ أَن تُحِبُّوا شَيْئًا وَهُوَ شَرٌّ لَّكُمْ ۗ وَاللَّهُ يَعْلَمُ وَأَنتُمْ لَا تَعْلَمُونَ',
      status: IstikharaStatus.medium,
      generalAdvice: 'الأمر يحتاج إلى تأمل وصبر. قد تواجه بعض المشقات الظاهرية لكن عاقبته خير مع التوكل ودفع الصدقة والابتعاد عن العجلة.',
      workAdvice: 'يتطلب دراسة دقيقة ومشاورة أهل الخبرة، ولا تتسرع في توقيع العقود.',
      marriageAdvice: 'يحتاج إلى مزيد من الفحص والتحقق قبل اتخاذ القرار النهائي.',
    ),
    IstikharaResultModel(
      id: 3,
      surahName: 'سورة التوبة',
      surahNumber: 9,
      ayahNumber: 51,
      pageNumber: 195,
      ayahText: 'قُل لَّن يُصِيبَنَا إِلَّا مَا كَتَبَ اللَّهُ لَنَا هُوَ مَوْلَانَا ۚ وَعَلَى اللَّهِ فَلْيَتَوَكَّلِ الْمُؤْمِنُونَ',
      status: IstikharaStatus.good,
      generalAdvice: 'الأمر خير ومحمود العاقبة، اعتمد على الله وتوكل عليه وسيسهل لك أسباب النجاح.',
      workAdvice: 'موفق بإذن الله، استمر في عملك بنية صادقة وإخلاص.',
      marriageAdvice: 'أمر طيب وفيه خير وصلاح، مع الالتزام بالقيم الدينية والأخلاقية.',
    ),
    IstikharaResultModel(
      id: 4,
      surahName: 'سورة الإسراء',
      surahNumber: 17,
      ayahNumber: 11,
      pageNumber: 283,
      ayahText: 'وَيَدْعُ الْإِنسَانُ بِالشَّرِّ دُعَاءَهُ بِالْخَيْرِ ۖ وَكَانَ الْإِنسَانُ عَجُولًا',
      status: IstikharaStatus.bad,
      generalAdvice: 'نهي صريح، الأمر غير صالح وفيه عواقب غير محمودة وندامة لاحقة. يُنصح بالعدول عنه أو تأجيله تماماً.',
      workAdvice: 'خسارة محتملة أو مشاكل غير متوقعة، يُفضل صرف النظر عن هذا العمل.',
      marriageAdvice: 'غير ملائم وقد تترتب عليه خلافات وصعوبات لا تُحمد عقباها.',
    ),
    IstikharaResultModel(
      id: 5,
      surahName: 'سورة الفتح',
      surahNumber: 48,
      ayahNumber: 1,
      pageNumber: 511,
      ayahText: 'إِنَّا فَتَحْنَا لَكَ فَتْحًا مُّبِينًا',
      status: IstikharaStatus.veryGood,
      generalAdvice: 'بشرى بالخير والنجاح التام والظفر. أمر مبارك ومؤيد برعاية الله ولطفه.',
      workAdvice: 'نجاح باهر ومكاسب معنوية ومادية كبيرة بإذن الله.',
      marriageAdvice: 'وفاق وتوفيق عظيم وأسرة قائمة على المودة والرحمة.',
    ),
    IstikharaResultModel(
      id: 6,
      surahName: 'سورة آل عمران',
      surahNumber: 3,
      ayahNumber: 159,
      pageNumber: 71,
      ayahText: 'فَإِذَا عَزَمْتَ فَتَوَكَّلْ عَلَى اللَّهِ ۚ إِنَّ اللَّهَ يُحِبُّ الْمُتَوَكِّلِينَ',
      status: IstikharaStatus.good,
      generalAdvice: 'توجه إلى هذا الأمر بتصميم وثقة بالله تعالى، فالخير مقرون بالعزم والإخلاص.',
      workAdvice: 'مشروع واعد يحتاج إلى إدارة حكيمة ومتابعة مستمرة.',
      marriageAdvice: 'خطوة مباركة وموفقة مع وضوح النوايا والتفاهم المتبادل.',
    ),
    IstikharaResultModel(
      id: 7,
      surahName: 'سورة النجم',
      surahNumber: 53,
      ayahNumber: 28,
      pageNumber: 527,
      ayahText: 'وَإِنَّ الظَّنَّ لَا يُغْنِي مِنَ الْحَقِّ شَيْئًا',
      status: IstikharaStatus.bad,
      generalAdvice: 'الأمر مبني على أوهام وتوقعات غير واقعية، ونهايته غير مرضية. تجنبه تماماً.',
      workAdvice: 'مشروع غير مدروس ومحفوف بالمخاطر، لا تقدم عليه.',
      marriageAdvice: 'عدم توافق جوهري، يُنصح بالصرف والابتعاد.',
    ),
  ];

  @override
  Future<IstikharaResultModel> performIstikhara() async {
    // شبیه‌سازی تأخیر شبکه / پردازش برای نمایش انیمیشن روان
    await Future.delayed(const Duration(milliseconds: 1400));
    final index = _random.nextInt(_mockResults.length);
    return _mockResults[index];
  }

  @override
  Future<IstikharaResultModel?> getIstikharaById(int id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _mockResults.firstWhere((element) => element.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<String>> getIstikharaEtiquettes() async {
    return [
      'أن يكون على طهارة ووضوء تام.',
      'التوجه إلى القبلة الشريفة بخشوع وحضور قلب.',
      'الصلاة على محمد وآل محمد ثلاث مرات قبل وبعد الاستخارة.',
      'قراءة سورة الإخلاص (التوحيد) ثلاث مرات.',
      'عقد النية الخالصة في الأمر المراد الاستخارة فيه دون انحياز مسبق.',
      'قراءة الدعاء المأثور عن أهل البيت (عليهم السلام).',
    ];
  }

  @override
  Future<String> getIstikharaDuaa() async {
    return '«اللَّهُمَّ إِنِّي تَفَأَّلْتُ بِكِتَابِكَ، وَتَوَكَّلْتُ عَلَيْكَ، فَأَرِنِي مِنْ كِتَابِكَ مَا هُوَ مَكْتُومٌ مِنْ سِرِّكَ الْمَكْنُونِ فِي غَيْبِكَ، بِرَحْمَتِكَ يَا أَرْحَمَ الرَّاحِمِينَ، اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَآلِ مُحَمَّدٍ»';
  }
}
