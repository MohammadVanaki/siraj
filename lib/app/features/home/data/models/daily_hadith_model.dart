class DailyHadithModel {
  final int? id;
  final String speaker;
  final String text;
  final String? source;
  final String? date;

  const DailyHadithModel({
    this.id,
    required this.speaker,
    required this.text,
    this.source,
    this.date,
  });

  factory DailyHadithModel.fromJson(Map<String, dynamic> json) {
    return DailyHadithModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? ''),
      speaker: json['speaker'] ??
          json['narrator'] ??
          json['author'] ??
          'قال رسول الله (ص)',
      text: json['text'] ?? json['hadith'] ?? json['content'] ?? '',
      source: json['source'] ?? json['reference'] ?? '',
      date: json['date']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'speaker': speaker,
      'text': text,
      'source': source,
      'date': date,
    };
  }

  String get fullShareText {
    final buffer = StringBuffer();
    buffer.writeln(speaker);
    buffer.writeln('«$text»');
    if (source != null && source!.trim().isNotEmpty) {
      buffer.writeln('📚 المصدر: $source');
    }
    buffer.writeln('\nمن تطبيق السراج');
    return buffer.toString();
  }
}
