enum OccasionType {
  joy,      // ولادات، أعياد، مسرات، أفراح
  mourning, // شهادات، وفيات، أحزان، مآتم
  general,  // مناسبات دينية، أيام مباركة، أحداث تاريخية
}

class Occasion {
  final int id;
  final int hijriMonth; // 1 (Muharram) to 12 (Dhu al-Hijjah)
  final int hijriDay;   // 1 to 30
  final String title;
  final String? subtitle;
  final String description;
  final OccasionType type;
  final List<String> recommendedActs; // الأعمال المستحبة
  final bool isMajor; // مناسبة رئيسية بارزة
  final bool isHoliday; // عطلة رسمية أو دينية
  final String? ziyarahText; // اسم الزيارة أو الدعاء المستحب

  const Occasion({
    required this.id,
    required this.hijriMonth,
    required this.hijriDay,
    required this.title,
    this.subtitle,
    required this.description,
    required this.type,
    this.recommendedActs = const [],
    this.isMajor = false,
    this.isHoliday = false,
    this.ziyarahText,
  });

  String get typeName {
    switch (type) {
      case OccasionType.joy:
        return 'ولادة / عيد مبارك';
      case OccasionType.mourning:
        return 'شهادة / وفاة';
      case OccasionType.general:
        return 'مناسبة دينية';
    }
  }
}
