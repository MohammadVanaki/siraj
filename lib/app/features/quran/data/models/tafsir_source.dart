class TafsirSource {
  final String id;
  final String name;
  final String author;
  final String? apiIdentifier;
  final bool isAvailable;
  final String? description;
  final String? sourceUrl;

  const TafsirSource({
    required this.id,
    required this.name,
    required this.author,
    this.apiIdentifier,
    this.isAvailable = false,
    this.description,
    this.sourceUrl,
  });

  factory TafsirSource.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final name = json['nameArabic'] as String? ?? json['name'] as String? ?? id;
    final author = json['authorArabic'] as String? ?? json['author'] as String? ?? '';
    final sourceUrl = json['sourceUrl'] as String?;
    return TafsirSource(
      id: id,
      name: name,
      author: author,
      apiIdentifier: id,
      isAvailable: true,
      sourceUrl: sourceUrl,
      description: _knownDescriptions[id] ?? 'تفسير معتمد للقرآن الكريم',
    );
  }

  static const Map<String, String> _knownDescriptions = {
    'jalalayn': 'تفسير موجز ودقيق ومشهور للقرآن الكريم',
    'muyassar': 'تفسير ميسر أعده نخبة من العلماء بإشراف مجمع الملك فهد',
  };

  static const List<TafsirSource> defaultTafsirs = [
    TafsirSource(
      id: 'jalalayn',
      name: 'تفسير الجلالين',
      author: 'جلال الدين المحلي وجلال الدين السيوطي',
      apiIdentifier: 'jalalayn',
      isAvailable: true,
      sourceUrl: 'https://tanzil.net/trans/ar.jalalayn',
      description: 'تفسير موجز ودقيق ومشهور للقرآن الكريم',
    ),
    TafsirSource(
      id: 'muyassar',
      name: 'التفسير الميسر',
      author: 'مجمع الملك فهد لطباعة المصحف الشريف',
      apiIdentifier: 'muyassar',
      isAvailable: true,
      sourceUrl: 'https://tanzil.net/trans/ar.muyassar',
      description: 'تفسير ميسر أعده نخبة من العلماء بإشراف مجمع الملك فهد',
    ),
  ];
}
