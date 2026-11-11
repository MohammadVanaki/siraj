import '../data_sources/surah_constants.dart';

class AyahModel {
  final int surah;
  final int number;
  final int numberInSurah;
  final String text;
  final int? juz;
  final int? page;
  final String? tafsirText;
  final String? tafsirName;

  const AyahModel({
    this.surah = 1,
    required this.number,
    required this.numberInSurah,
    required this.text,
    this.juz,
    this.page,
    this.tafsirText,
    this.tafsirName,
  });

  int get surahNumber => surah;

  /// تبدیل عدد به ارقام عربی أصيل (٠، ١، ٢، ٣، ٤، ٥، ٦، ٧، ٨، ٩)
  static String toArabicDigits(dynamic input) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return input.toString().split('').map((c) {
      final d = int.tryParse(c);
      return d != null ? digits[d] : c;
    }).join();
  }

  String get numberInSurahArabic => toArabicDigits(numberInSurah);

  /// Calculates cumulative ayah number in the Quran (1 to 6236)
  static int calculateOverallNumber(int surahNumber, int ayahNumberInSurah) {
    int total = 0;
    for (int i = 1; i < surahNumber; i++) {
      final s = SurahConstants.getByNumber(i);
      if (s != null) {
        total += s.numberOfAyahs;
      }
    }
    return total + ayahNumberInSurah;
  }

  /// Strips leading bismillah from ayah text if it was prepended by API for surahs > 1 (excluding surah 9)
  String get displayArabicText {
    if (numberInSurah == 1) {
      final bismillahRegex = RegExp(
        r'^بِسْمِ\s+[ٱا]?للَّ?هِ\s+[ٱا]?لرَّحْم[َـٰ\u0640\u0670]*نِ\s+[ٱا]?لرَّحِيمِ\s*',
      );
      final match = bismillahRegex.firstMatch(text);
      if (match != null) {
        final remaining = text.substring(match.end).trim();
        if (remaining.isNotEmpty) return remaining;
      }
    }
    return text.trim();
  }

  factory AyahModel.fromJson(Map<String, dynamic> json, {String? tafsirText, String? tafsirName}) {
    final surahNumber = json['surah'] as int? ?? 1;
    final numberInSurah = json['ayah'] as int? ?? json['numberInSurah'] as int? ?? 0;
    final overallNumber = json['number'] as int? ??
        (numberInSurah > 0 ? calculateOverallNumber(surahNumber, numberInSurah) : 0);

    final rawText = json['textUthmani'] as String? ?? json['text'] as String? ?? '';

    return AyahModel(
      surah: surahNumber,
      number: overallNumber,
      numberInSurah: numberInSurah,
      text: rawText,
      juz: json['juz'] as int?,
      page: json['page'] as int?,
      tafsirText: tafsirText ?? json['tafsirText'] as String?,
      tafsirName: tafsirName ?? json['tafsirName'] as String?,
    );
  }

  AyahModel copyWith({
    int? surah,
    int? number,
    int? numberInSurah,
    String? text,
    int? juz,
    int? page,
    String? tafsirText,
    String? tafsirName,
  }) {
    return AyahModel(
      surah: surah ?? this.surah,
      number: number ?? this.number,
      numberInSurah: numberInSurah ?? this.numberInSurah,
      text: text ?? this.text,
      juz: juz ?? this.juz,
      page: page ?? this.page,
      tafsirText: tafsirText ?? this.tafsirText,
      tafsirName: tafsirName ?? this.tafsirName,
    );
  }
}
