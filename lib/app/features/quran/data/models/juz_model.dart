class JuzSurahRef {
  final int surahNumber;
  final int startAyah;
  final int endAyah;

  const JuzSurahRef({
    required this.surahNumber,
    required this.startAyah,
    required this.endAyah,
  });
}

class JuzModel {
  final int number;
  final String name; // مثال: 'الجزء الأول'
  final String startVerseText; // مثال: 'الم'
  final int startSurahNumber;
  final int startAyahNumber;
  final int endSurahNumber;
  final int endAyahNumber;
  final List<JuzSurahRef> surahs;

  const JuzModel({
    required this.number,
    required this.name,
    required this.startVerseText,
    required this.startSurahNumber,
    required this.startAyahNumber,
    required this.endSurahNumber,
    required this.endAyahNumber,
    required this.surahs,
  });

  /// تعداد کل سوره‌های موجود در این جزء
  int get surahCount => surahs.length;
}
