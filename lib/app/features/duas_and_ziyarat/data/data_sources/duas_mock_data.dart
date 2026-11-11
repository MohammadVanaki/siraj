import 'package:flutter/material.dart';
import '../models/dua_media_item.dart';

class DuasMockData {
  // دسته‌بندی‌های صوتیات
  static const List<DuaCategoryModel> audioCategories = [
    DuaCategoryModel(
      id: 'cat_audio_duas',
      title: 'الأدعية المشهورة',
      subtitle: 'دعاء كميل، دعاء التوسل، دعاء الصباح، دعاء العهد وغيرها',
      icon: Icons.menu_book_rounded,
      itemCount: 4,
    ),
    DuaCategoryModel(
      id: 'cat_audio_ziyarat',
      title: 'الزيارات المأثورة',
      subtitle: 'زيارة عاشوراء، زيارة وارث، زيارة آل ياسين وغيرها',
      icon: Icons.mosque_rounded,
      itemCount: 2,
    ),
    DuaCategoryModel(
      id: 'cat_audio_munajat',
      title: 'المناجاة الإلهية',
      subtitle: 'المناجاة الخمس عشرة ومناجاة الإمام علي (ع)',
      icon: Icons.volunteer_activism_rounded,
      itemCount: 2,
    ),
    DuaCategoryModel(
      id: 'cat_audio_daily',
      title: 'أدعية الأيام والأسبوع',
      subtitle: 'أدعية وتعقيبات أيام الأسبوع من السبت إلى الجمعة',
      icon: Icons.calendar_month_rounded,
      itemCount: 2,
    ),
  ];

  // دسته‌بندی‌های مرئیات
  static const List<DuaCategoryModel> videoCategories = [
    DuaCategoryModel(
      id: 'cat_video_harams',
      title: 'مجالس العتبات المقدسة',
      subtitle: 'تسجيلات مرئية مباركة من حرم الإمام الحسين والنجف الأشرف',
      icon: Icons.videocam_rounded,
      itemCount: 2,
    ),
    DuaCategoryModel(
      id: 'cat_video_friday',
      title: 'أدعية ليلة الجمعة',
      subtitle: 'أجواء روحانية وتلاوات مرئية لليالي الجمعة المباركة',
      icon: Icons.ondemand_video_rounded,
      itemCount: 2,
    ),
    DuaCategoryModel(
      id: 'cat_video_ziyarat',
      title: 'الزيارات المصورة',
      subtitle: 'مشاهد وزيارات مرئية لسادات الوجود (عليهم السلام)',
      icon: Icons.movie_creation_rounded,
      itemCount: 2,
    ),
  ];

  // آیتم‌های صوتی نمونه
  static const List<DuaAudioItem> testAudios = [
    DuaAudioItem(
      id: 'audio_kumayl',
      categoryId: 'cat_audio_duas',
      title: 'دعاء كميل بن زياد',
      reciter: 'الحاج أباذر الحلواجي',
      durationText: '34:20',
      audioUrl: 'https://server8.mp3quran.net/afs/001.mp3',
      text: '''اللَّهُمَّ إِنِّي أَسْأَلُكَ بِرَحْمَتِكَ الَّتِي وَسِعَتْ كُلَّ شَيْءٍ، وَبِقُوَّتِكَ الَّتِي قَهَرْتَ بِهَا كُلَّ شَيْءٍ، وَخَضَعَ لَهَا كُلُّ شَيْءٍ، وَذَلَّ لَهَا كُلُّ شَيْءٍ، وَبِجَبَرُوتِكَ الَّتِي غَلَبْتَ بِهَا كُلَّ شَيْءٍ، وَبِعِزَّتِكَ الَّتِي لا يَقُومُ لَهَا شَيْءٌ، وَبِعَظَمَتِكَ الَّتِي مَلأَتْ كُلَّ شَيْءٍ، وَبِسُلْطَانِكَ الَّذِي عَلا كُلَّ شَيْءٍ، وَبِوَجْهِكَ الْبَاقِي بَعْدَ فَنَاءِ كُلِّ شَيْءٍ، وَبِأَسْمَائِكَ الَّتِي مَلأَتْ أَرْكَانَ كُلِّ شَيْءٍ، وَبِعِلْمِكَ الَّذِي أَحَاطَ بِكُلِّ شَيْءٍ، وَبِنُورِ وَجْهِكَ الَّذِي أَضَاءَ لَهُ كُلُّ شَيْءٍ، يَا نُورُ يَا قُدُّوسُ، يَا أَوَّلَ الأَوَّلِينَ، وَيَا آخِرَ الآخِرِينَ.

اللَّهُمَّ اغْفِرْ لِيَ الذُّنُوبَ الَّتِي تَهْتِكُ الْعِصَمَ، اللَّهُمَّ اغْفِرْ لِيَ الذُّنُوبَ الَّتِي تُنْزِلُ النِّقَمَ، اللَّهُمَّ اغْفِرْ لِيَ الذُّنُوبَ الَّتِي تُغَيِّرُ النِّعَمَ، اللَّهُمَّ اغْفِرْ لِيَ الذُّنُوبَ الَّتِي تَحْبِسُ الدُّعَاءَ، اللَّهُمَّ اغْفِرْ لِيَ الذُّنُوبَ الَّتِي تُنْزِلُ الْبَلاءَ.

اللَّهُمَّ اغْفِرْ لِي كُلَّ ذَنْبٍ أَذْنَبْتُهُ، وَكُلَّ خَطِيئَةٍ أَخْطَأْتُهَا، اللَّهُمَّ إِنِّي أَتَقَرَّبُ إِلَيْكَ بِذِكْرِكَ، وَأَسْتَشْفِعُ بِكَ إِلَى نَفْسِكَ، وَأَسْأَلُكَ بِجُودِكَ أَنْ تُدْنِيَنِي مِنْ قُرْبِكَ، وَأَنْ تُوزِعَنِي شُكْرَكَ، وَأَنْ تُلْهِمَنِي ذِكْرَكَ.''',
    ),
    DuaAudioItem(
      id: 'audio_tawassul',
      categoryId: 'cat_audio_duas',
      title: 'دعاء التوسل',
      reciter: 'الشيخ حسين الأكرف',
      durationText: '16:40',
      audioUrl: 'https://server8.mp3quran.net/afs/004.mp3',
      text: '''اللَّهُمَّ إِنِّي أَسْأَلُكَ وَأَتَوَجَّهُ إِلَيْكَ بِنَبِيِّكَ نَبِيِّ الرَّحْمَةِ مُحَمَّدٍ صَلَّى اللهُ عَلَيْهِ وَآلِهِ، يَا أَبَا الْقَاسِمِ، يَا رَسُولَ اللهِ، يَا إِمَامَ الرَّحْمَةِ، يَا سَيِّدَنَا وَمَوْلانَا، إِنَّا تَوَجَّهْنَا وَاسْتَشْفَعْنَا وَتَوَسَّلْنَا بِكَ إِلَى اللهِ، وَقَدَّمْنَاكَ بَيْنَ يَدَيْ حَاجَاتِنَا، يَا وَجِيهاً عِنْدَ اللهِ، اشْفَعْ لَنَا عِنْدَ اللهِ.

يَا أَبَا الْحَسَنِ، يَا أَمِيرَ الْمُؤْمِنِينَ، يَا عَلِيَّ بْنَ أَبِي طَالِبٍ، يَا حُجَّةَ اللهِ عَلَى خَلْقِهِ، يَا سَيِّدَنَا وَمَوْلانَا، إِنَّا تَوَجَّهْنَا وَاسْتَشْفَعْنَا وَتَوَسَّلْنَا بِكَ إِلَى اللهِ، وَقَدَّمْنَاكَ بَيْنَ يَدَيْ حَاجَاتِنَا، يَا وَجِيهاً عِنْدَ اللهِ، اشْفَعْ لَنَا عِنْدَ اللهِ.''',
    ),
    DuaAudioItem(
      id: 'audio_ahad',
      categoryId: 'cat_audio_duas',
      title: 'دعاء العهد',
      reciter: 'الحاج ميثم التمار',
      durationText: '09:15',
      audioUrl: 'https://server8.mp3quran.net/afs/003.mp3',
      text: '''اللَّهُمَّ رَبَّ النُّورِ الْعَظِيمِ، وَرَبَّ الْكُرْسِيِّ الرَّفِيعِ، وَرَبَّ الْبَحْرِ الْمَسْجُورِ، وَمُنْزِلَ التَّوْرَاةِ وَالإِنْجِيلِ وَالزَّبُورِ، وَرَبَّ الظِّلِّ وَالْحَرُورِ، وَمُنْزِلَ الْقُرْآنِ الْعَظِيمِ، وَرَبَّ الْمَلائِكَةِ الْمُقَرَّبِينَ وَالأَنْبِيَاءِ وَالْمُرْسَلِينَ.

اللَّهُمَّ إِنِّي أَسْأَلُكَ بِوَجْهِكَ الْكَرِيمِ، وَبِنُورِ وَجْهِكَ الْمُنِيرِ، وَمُلْكِكَ الْقَدِيمِ، يَا حَيُّ يَا قَيُّومُ، أَسْأَلُكَ بِاسْمِكَ الَّذِي أَشْرَقَتْ بِهِ السَّمَاوَاتُ وَالأَرَضُونَ، وَبِاسْمِكَ الَّذِي يَصْلُحُ بِهِ الأَوَّلُونَ وَالآخِرُونَ.''',
    ),
    DuaAudioItem(
      id: 'audio_sabah',
      categoryId: 'cat_audio_duas',
      title: 'دعاء الصباح (أمير المؤمنين ع)',
      reciter: 'الحاج مهدي صدقي',
      durationText: '14:10',
      audioUrl: 'https://server8.mp3quran.net/afs/005.mp3',
      text: '''اللَّهُمَّ يَا مَنْ دَلَعَ لِسَانَ الصَّبَاحِ بِنُطْقِ تَبَلُّجِهِ، وَسَرَّحَ قِطَعَ اللَّيْلِ الْمُظْلِمِ بِغَيَاهِبِ تَلَجْلُجِهِ، وَأَتْقَنَ صُنْعَ الْفَلَكِ الدَّوَّارِ فِي مَقَادِيرِ تَبَرُّجِهِ، وَشَعْشَعَ ضِيَاءَ الشَّمْسِ بِنُورِ تَأَجُّجِهِ، يَا مَنْ دَلَّ عَلَى ذَاتِهِ بِذَاتِهِ، وَتَنَزَّهَ عَنْ مُجَانَسَةِ مَخْلُوقَاتِهِ.''',
    ),
    DuaAudioItem(
      id: 'audio_ashura',
      categoryId: 'cat_audio_ziyarat',
      title: 'زيارة عاشوراء المشهورة',
      reciter: 'الحاج باسم الكربلائي',
      durationText: '18:50',
      audioUrl: 'https://server8.mp3quran.net/afs/002.mp3',
      text: '''السَّلامُ عَلَيْكَ يَا أَبَا عَبْدِ اللهِ، السَّلامُ عَلَيْكَ يَا ابْنَ رَسُولِ اللهِ، السَّلامُ عَلَيْكَ يَا ابْنَ أَمِيرِ الْمُؤْمِنِينَ وَابْنَ سَيِّدِ الْوَصِيِّينَ، السَّلامُ عَلَيْكَ يَا ابْنَ فَاطِمَةَ سَيِّدَةِ نِسَاءِ الْعَالَمِينَ، السَّلامُ عَلَيْكَ يَا ثَارَ اللهِ وَابْنَ ثَارِهِ وَالْوِتْرَ الْمَوْتُورَ.

السَّلامُ عَلَيْكَ وَعَلَى الأَرْوَاحِ الَّتِي حَلَّتْ بِفِنَائِكَ، عَلَيْكُمْ مِنِّي جَمِيعاً سَلامُ اللهِ أَبَداً مَا بَقِيتُ وَبَقِيَ اللَّيْلُ وَالنَّهَارُ، يَا أَبَا عَبْدِ اللهِ لَقَدْ عَظُمَتِ الرَّزِيَّةُ وَجَلَّتْ وَعَظُمَتِ الْمُصِيبَةُ بِكَ عَلَيْنَا وَعَلَى جَمِيعِ أَهْلِ الإِسْلامِ.''',
    ),
    DuaAudioItem(
      id: 'audio_warith',
      categoryId: 'cat_audio_ziyarat',
      title: 'زيارة وارث الشريفة',
      reciter: 'أباذر الحلواجي',
      durationText: '11:20',
      audioUrl: 'https://server8.mp3quran.net/afs/001.mp3',
      text: '''السَّلامُ عَلَيْكَ يَا وَارِثَ آدَمَ صَفْوَةِ اللهِ، السَّلامُ عَلَيْكَ يَا وَارِثَ نُوحٍ نَبِيِّ اللهِ، السَّلامُ عَلَيْكَ يَا وَارِثَ إِبْرَاهِيمَ خَلِيلِ اللهِ، السَّلامُ عَلَيْكَ يَا وَارِثَ مُوسَى كَلِيمِ اللهِ، السَّلامُ عَلَيْكَ يَا وَارِثَ عِيسَى رُوحِ اللهِ، السَّلامُ عَلَيْكَ يَا وَارِثَ مُحَمَّدٍ حَبِيبِ اللهِ.''',
    ),
    DuaAudioItem(
      id: 'audio_munajat_taibeen',
      categoryId: 'cat_audio_munajat',
      title: 'مناجاة التائبين (السجاد ع)',
      reciter: 'حسين الأكرف',
      durationText: '08:30',
      audioUrl: 'https://server8.mp3quran.net/afs/003.mp3',
      text: '''إِلَهِي أَلْبَسَتْنِي الْخَطَايَا ثَوْبَ مَذَلَّتِي، وَجَلَّلَنِي التَّبَاعُدُ مِنْكَ لِبَاسَ مَسْكَنَتِي، وَأَمَاتَ قَلْبِي عَظِيمُ جِنَايَتِي، فَأَحْيِهِ بِتَوْبَةٍ مِنْكَ يَا أَمَلِي وَبُغْيَتِي، وَيَا سُؤْلِي وَمُنْيَتِي، فَوَعِزَّتِكَ مَا أَجِدُ لِذُنُوبِي سِوَاكَ غَافِراً، وَلا أَرَى لِكَسْرِي غَيْرَكَ جَابِراً.''',
    ),
    DuaAudioItem(
      id: 'audio_munajat_shakin',
      categoryId: 'cat_audio_munajat',
      title: 'مناجاة الشاكين',
      reciter: 'ميثم التمار',
      durationText: '07:45',
      audioUrl: 'https://server8.mp3quran.net/afs/004.mp3',
      text: '''إِلَهِي إِلَيْكَ أَشْكُو نَفْساً بِالسُّوءِ أَمَّارَةً، وَإِلَى الْخَطِيئَةِ مُبَادِرَةً، وَبِمَعَاصِيكَ مُولَعَةً، وَلِسَخَطِكَ مُتَعَرِّضَةً، تَسْلُكُ بِي مَسَالِكَ الْمَهَالِكِ، وَتَجْعَلُنِي عِنْدَكَ أَهْوَنَ هَالِكٍ، كَثِيرَةَ الْعِلَلِ طَوِيلَةَ الأَمَلِ، إِنْ مَسَّهَا الشَّرُّ تَجْزَعُ، وَإِنْ مَسَّهَا الْخَيْرُ تَمْنَعُ.''',
    ),
    DuaAudioItem(
      id: 'audio_dua_friday',
      categoryId: 'cat_audio_daily',
      title: 'دعاء يوم الجمعة المباركة',
      reciter: 'أباذر الحلواجي',
      durationText: '06:15',
      audioUrl: 'https://server8.mp3quran.net/afs/005.mp3',
      text: '''الْحَمْدُ لِلَّهِ الأَوَّلِ قَبْلَ الإِنْشَاءِ وَالإِحْيَاءِ، وَالآخِرِ بَعْدَ فَنَاءِ الأَشْيَاءِ، الْعَلِيمِ الَّذِي لا يَنْسَى مَنْ ذَكَرَهُ، وَلا يَنْقُصُ مَنْ شَكَرَهُ، وَلا يَخِيبُ مَنْ دَعَاهُ، وَلا يَقْطَعُ رَجَاءَ مَنْ رَجَاهُ.''',
    ),
    DuaAudioItem(
      id: 'audio_dua_saturday',
      categoryId: 'cat_audio_daily',
      title: 'دعاء يوم السبت',
      reciter: 'باسم الكربلائي',
      durationText: '05:40',
      audioUrl: 'https://server8.mp3quran.net/afs/001.mp3',
      text: '''بِسْمِ اللهِ كَلِمَةِ الْمُعْتَصِمِينَ، وَمَقَالَةِ الْمُتَحَرِّزِينَ، وَأَعُوذُ بِاللهِ تَعَالَى مِنْ جَوْرِ الْجَائِرِينَ، وَكَيْدِ الْحَاسِدِينَ، وَبَغْيِ الظَّالِمِينَ، وَأَحْمَدُهُ فَوْقَ حَمْدِ الْحَامِدِينَ.''',
    ),
  ];

  // آیتم‌های مرئیات نمونه
  static const List<DuaVideoItem> testVideos = [
    DuaVideoItem(
      id: 'video_kumayl',
      categoryId: 'cat_video_harams',
      title: 'دعاء كميل من جوار المرقد الحسيني المطهر',
      reciter: 'أباذر الحلواجي',
      durationText: '35:10',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    ),
    DuaVideoItem(
      id: 'video_warith',
      categoryId: 'cat_video_harams',
      title: 'زيارة وارث في ليلة الجمعة المباركة',
      reciter: 'باسم الكربلائي',
      durationText: '12:45',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    ),
    DuaVideoItem(
      id: 'video_nudba',
      categoryId: 'cat_video_friday',
      title: 'دعاء الندبة - صبيحة يوم الجمعة المباركة',
      reciter: 'الشيخ باقر المقدسي',
      durationText: '42:20',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    ),
    DuaVideoItem(
      id: 'video_kumayl_najaf',
      categoryId: 'cat_video_friday',
      title: 'دعاء كميل من الصحن العلوي الشريف',
      reciter: 'حسين الأكرف',
      durationText: '28:15',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    ),
    DuaVideoItem(
      id: 'video_yasin',
      categoryId: 'cat_video_ziyarat',
      title: 'زيارة آل ياسين الشريفة مصورة',
      reciter: 'ميثم التمار',
      durationText: '16:30',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    ),
    DuaVideoItem(
      id: 'video_ashura_karbala',
      categoryId: 'cat_video_ziyarat',
      title: 'زيارة عاشوراء برحاب كربلاء المقدسة',
      reciter: 'باسم الكربلائي',
      durationText: '20:10',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyBlazes.mp4',
    ),
  ];
}
