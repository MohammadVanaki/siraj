import 'package:flutter/material.dart';

class BeadTheme {
  final String id;
  final String name;
  final List<Color> beadColors;
  final List<Color> separatorColors;
  final Color threadColor;
  final Color glowColor;

  const BeadTheme({
    required this.id,
    required this.name,
    required this.beadColors,
    required this.separatorColors,
    required this.threadColor,
    required this.glowColor,
  });

  static const List<BeadTheme> themes = [
    // 1. Emerald / الزمرد الأخضر
    BeadTheme(
      id: 'emerald',
      name: 'الزمرد الأخضر',
      beadColors: [
        Color(0xFFA7F3D0),
        Color(0xFF10B981),
        Color(0xFF047857),
        Color(0xFF064E3B),
      ],
      separatorColors: [
        Color(0xFFFFFBEB),
        Color(0xFFFBBF24),
        Color(0xFFD97706),
        Color(0xFF78350F),
      ],
      threadColor: Color(0xFFC5A059),
      glowColor: Color(0xFF10B981),
    ),

    // 2. Persian Turquoise / الفيروزج
    BeadTheme(
      id: 'turquoise',
      name: 'الفيروزج الملكي',
      beadColors: [
        Color(0xFFBAE6FD),
        Color(0xFF0EA5E9),
        Color(0xFF0284C7),
        Color(0xFF0369A1),
      ],
      separatorColors: [
        Color(0xFFFFDF79),
        Color(0xFFD4AF37),
        Color(0xFF996515),
        Color(0xFF5A3D0B),
      ],
      threadColor: Color(0xFFD4AF37),
      glowColor: Color(0xFF0EA5E9),
    ),

    // 3. Golden Amber / العقيق الكهرماني
    BeadTheme(
      id: 'amber',
      name: 'العقيق الكهرماني',
      beadColors: [
        Color(0xFFFEF08A),
        Color(0xFFF59E0B),
        Color(0xFFB45309),
        Color(0xFF78350F),
      ],
      separatorColors: [
        Color(0xFFFFFFFF),
        Color(0xFFE2E8F0),
        Color(0xFF94A3B8),
        Color(0xFF475569),
      ],
      threadColor: Color(0xFFB45309),
      glowColor: Color(0xFFF59E0B),
    ),

    // 4. Royal Pearl / اللؤلؤ الأبيض
    BeadTheme(
      id: 'pearl',
      name: 'اللؤلؤ النقي',
      beadColors: [
        Color(0xFFFFFFFF),
        Color(0xFFF1F5F9),
        Color(0xFFCBD5E1),
        Color(0xFF64748B),
      ],
      separatorColors: [
        Color(0xFFFFDF79),
        Color(0xFFD4AF37),
        Color(0xFF996515),
        Color(0xFF5A3D0B),
      ],
      threadColor: Color(0xFF94A3B8),
      glowColor: Color(0xFFE2E8F0),
    ),

    // 5. Ebony & Gold / خشب الأبنوس المذهب
    BeadTheme(
      id: 'ebony',
      name: 'الأبنوس المذهب',
      beadColors: [
        Color(0xFF78716C),
        Color(0xFF44403C),
        Color(0xFF292524),
        Color(0xFF1C1917),
      ],
      separatorColors: [
        Color(0xFFFFDF79),
        Color(0xFFD4AF37),
        Color(0xFFB45309),
        Color(0xFF78350F),
      ],
      threadColor: Color(0xFFD4AF37),
      glowColor: Color(0xFFD4AF37),
    ),
  ];
}
