import 'package:flutter/material.dart';

enum IstikharaStatus {
  veryGood,
  good,
  medium,
  bad;

  String get labelAr {
    switch (this) {
      case IstikharaStatus.veryGood:
        return 'جيدة جداً ومباركة';
      case IstikharaStatus.good:
        return 'جيدة ومحمودة';
      case IstikharaStatus.medium:
        return 'متوسطة (مع الصدقة والتوكل)';
      case IstikharaStatus.bad:
        return 'غير جيدة (نهي وتجنب)';
    }
  }

  Color get color {
    switch (this) {
      case IstikharaStatus.veryGood:
        return const Color(0xFF10B981); // Emerald Green
      case IstikharaStatus.good:
        return const Color(0xFF059669); // Green
      case IstikharaStatus.medium:
        return const Color(0xFFF59E0B); // Amber / Orange
      case IstikharaStatus.bad:
        return const Color(0xFFEF4444); // Red
    }
  }

  IconData get icon {
    switch (this) {
      case IstikharaStatus.veryGood:
      case IstikharaStatus.good:
        return Icons.check_circle_rounded;
      case IstikharaStatus.medium:
        return Icons.help_rounded;
      case IstikharaStatus.bad:
        return Icons.cancel_rounded;
    }
  }

  static IstikharaStatus fromString(String? val) {
    if (val == null || val.trim().isEmpty) return IstikharaStatus.good;
    final clean = val.toLowerCase().trim();

    // Bad / Nahy patterns
    if (clean.contains('لا تفعل') ||
        clean.contains('نهي') ||
        clean.contains('غير جيد') ||
        clean.contains('احذر') ||
        clean.contains('سيئ') ||
        clean.contains('bad') ||
        clean.contains('nahy')) {
      return IstikharaStatus.bad;
    }

    // Medium / Middle patterns
    if (clean.contains('متوسط') ||
        clean.contains('وسط') ||
        clean.contains('medium') ||
        clean.contains('middle')) {
      return IstikharaStatus.medium;
    }

    // Very Good patterns
    if (clean.contains('إفعل') ||
        clean.contains('افعل') ||
        clean.contains('جيدة جدا') ||
        clean.contains('very_good') ||
        clean.contains('verygood')) {
      return IstikharaStatus.veryGood;
    }

    // Good patterns
    if (clean.contains('جيد') ||
        clean.contains('محمود') ||
        clean.contains('خير') ||
        clean.contains('نعم') ||
        clean.contains('مبارك') ||
        clean.contains('good')) {
      return IstikharaStatus.good;
    }

    return IstikharaStatus.good;
  }

  String get code {
    switch (this) {
      case IstikharaStatus.veryGood:
        return 'very_good';
      case IstikharaStatus.good:
        return 'good';
      case IstikharaStatus.medium:
        return 'medium';
      case IstikharaStatus.bad:
        return 'bad';
    }
  }
}

class IstikharaResultModel {
  final int id;
  final String surahName;
  final int surahNumber;
  final int ayahNumber;
  final int pageNumber;
  final String ayahText;
  final String? answer;
  final IstikharaStatus status;
  final String generalAdvice;
  final String? disclaimer;
  final String? selectionId;
  final String? workAdvice;
  final String? marriageAdvice;
  final DateTime? createdAt;

  IstikharaResultModel({
    required this.id,
    required this.surahName,
    this.surahNumber = 1,
    required this.ayahNumber,
    required this.pageNumber,
    required this.ayahText,
    this.answer,
    required this.status,
    required this.generalAdvice,
    this.disclaimer,
    this.selectionId,
    this.workAdvice,
    this.marriageAdvice,
    this.createdAt,
  });

  /// Returns the text to display in the main result badge
  String get displayAnswer {
    if (answer != null && answer!.trim().isNotEmpty) {
      return answer!.trim();
    }
    return status.labelAr;
  }

  factory IstikharaResultModel.fromJson(Map<String, dynamic> json) {
    final rawAnswer = json['answer']?.toString();
    final rawStatus = json['status']?.toString();

    return IstikharaResultModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      surahName: json['surah'] ?? json['surah_name'] ?? json['surahName'] ?? '',
      surahNumber: json['surah_number'] ?? json['surahNumber'] ?? 1,
      ayahNumber: json['ayahNumber'] ??
          json['ayah_number'] ??
          json['ayah'] ??
          int.tryParse(json['ayah_number']?.toString() ?? '1') ??
          1,
      pageNumber: json['pageNumber'] ??
          json['page_number'] ??
          json['page'] ??
          int.tryParse(json['page_number']?.toString() ?? '1') ??
          1,
      ayahText: json['verseText'] ??
          json['verse_text'] ??
          json['ayah_text'] ??
          json['ayahText'] ??
          '',
      answer: rawAnswer,
      status: IstikharaStatus.fromString(rawStatus ?? rawAnswer),
      generalAdvice: json['description'] ??
          json['general_advice'] ??
          json['generalAdvice'] ??
          '',
      disclaimer: json['disclaimer']?.toString(),
      selectionId: json['selectionId']?.toString() ?? json['selection_id']?.toString(),
      workAdvice: json['work_advice'] ?? json['workAdvice'],
      marriageAdvice: json['marriage_advice'] ?? json['marriageAdvice'],
      createdAt: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString())
          : (json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surah': surahName,
      'surah_name': surahName,
      'surah_number': surahNumber,
      'ayahNumber': ayahNumber,
      'ayah_number': ayahNumber,
      'pageNumber': pageNumber,
      'page_number': pageNumber,
      'verseText': ayahText,
      'ayah_text': ayahText,
      'answer': answer,
      'status': status.code,
      'description': generalAdvice,
      'general_advice': generalAdvice,
      'disclaimer': disclaimer,
      'selectionId': selectionId,
      'work_advice': workAdvice,
      'marriage_advice': marriageAdvice,
      'timestamp': createdAt?.toIso8601String(),
    };
  }
}

