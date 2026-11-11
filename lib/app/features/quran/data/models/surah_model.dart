import '../data_sources/surah_constants.dart';

class SurahModel {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType; // 'Meccan' or 'Medinan'

  const SurahModel({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });

  bool get isMeccan => revelationType.toLowerCase().contains('meccan') || revelationType.contains('مكية');

  String get revelationTypeArabic => isMeccan ? 'مكية' : 'مدنية';

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    final number = json['number'] as int? ?? 1;
    final fallback = SurahConstants.getByNumber(number);

    return SurahModel(
      number: number,
      name: (json['nameArabic'] as String?)?.trim() ??
          (json['name'] as String?)?.trim() ??
          fallback?.name ??
          '',
      englishName: json['englishName'] as String? ?? fallback?.englishName ?? '',
      englishNameTranslation: json['englishNameTranslation'] as String? ?? fallback?.englishNameTranslation ?? '',
      numberOfAyahs: json['verseCount'] as int? ?? json['numberOfAyahs'] as int? ?? fallback?.numberOfAyahs ?? 0,
      revelationType: json['revelationType'] as String? ?? fallback?.revelationType ?? 'Meccan',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'englishName': englishName,
      'englishNameTranslation': englishNameTranslation,
      'numberOfAyahs': numberOfAyahs,
      'revelationType': revelationType,
    };
  }
}
