class DhikrItem {
  final String id;
  final String title;
  final String? subtitle;
  final int target;

  const DhikrItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.target,
  });

  static const List<DhikrItem> defaultList = [
    DhikrItem(
      id: 'zahra',
      title: 'تسبيح سيدة نساء العالمين (ع)',
      subtitle: '٣٤ الله أكبر - ٣٣ الحمد لله - ٣٣ سبحان الله',
      target: 100,
    ),
    DhikrItem(
      id: 'salawat',
      title: 'اللهم صل على محمد وآل محمد',
      subtitle: 'الصلاة على النبي وآله الأطهار',
      target: 100,
    ),
    DhikrItem(
      id: 'subhan_allah',
      title: 'سُبْحَانَ اللهِ',
      subtitle: 'تنزيه الله تعالى عن كل نقص',
      target: 33,
    ),
    DhikrItem(
      id: 'alhamdulillah',
      title: 'الحَمْدُ لِلَّهِ',
      subtitle: 'الثناء والشكر لله رب العالمين',
      target: 33,
    ),
    DhikrItem(
      id: 'allahu_akbar',
      title: 'اللهُ أَكْبَرُ',
      subtitle: 'تعظيم الله وإجلاله',
      target: 34,
    ),
    DhikrItem(
      id: 'la_ilaha_illa_allah',
      title: 'لَا إِلَهَ إِلَّا اللهُ',
      subtitle: 'كلمة التوحيد الخالص',
      target: 100,
    ),
    DhikrItem(
      id: 'astaghfirullah',
      title: 'أَسْتَغْفِرُ اللهَ رَبِّي وَأَتُوبُ إِلَيْهِ',
      subtitle: 'طلب المغفرة والتوبة',
      target: 70,
    ),
    DhikrItem(
      id: 'la_hawla',
      title: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ العَلِيِّ العَظِيمِ',
      subtitle: 'التوكل والتسليم لله',
      target: 100,
    ),
    DhikrItem(
      id: 'free',
      title: 'تسبيح حُر',
      subtitle: 'عدّاد مفتوح لأي ذكر',
      target: 0,
    ),
  ];
}
