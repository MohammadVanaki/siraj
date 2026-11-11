class ReciterModel {
  final String id;
  final String name;
  final String subName;
  final int bitrateKbps;
  final bool isAvailable;

  const ReciterModel({
    required this.id,
    required this.name,
    this.subName = 'مرتل',
    this.bitrateKbps = 128,
    this.isAvailable = true,
  });

  factory ReciterModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final name = json['nameArabic'] as String? ?? json['name'] as String? ?? id;
    final bitrate = json['bitrateKbps'] as int? ?? 128;
    return ReciterModel(
      id: id,
      name: name,
      subName: 'مرتل ($bitrate kbps)',
      bitrateKbps: bitrate,
      isAvailable: true,
    );
  }

  /// نقشه پوشه پیش‌فرض سرور EveryAyah برای هر قاری
  static const Map<String, String> _everyAyahFolders = {
    'alafasy': 'Alafasy_128kbps',
    'husary': 'Husary_128kbps',
    'maher': 'MaherAlMuaiqly128kbps',
    'sudais': 'Abdurrahmaan_As-Sudais_192kbps',
    'shaatree': 'Abu_Bakr_Ash-Shaatree_128kbps',
    'basfar': 'Abdullah_Basfar_192kbps',
    'minshawy': 'Minshawy_Murattal_128kbps',
    'ajamy': 'Ahmed_ibn_Ali_al-Ajamy_128kbps_ketaballah.net',
  };

  /// تولید آدرس مستقیم فایل صوتی آیه بر اساس الگوی رسمی EveryAyah
  String getFallbackAudioUrl({
    required int surahNumber,
    required int ayahNumber,
  }) {
    final folder = _everyAyahFolders[id] ?? 'Alafasy_128kbps';
    final s = surahNumber.toString().padLeft(3, '0');
    final a = ayahNumber.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/$folder/$s$a.mp3';
  }

  /// لیست پیش‌فرض قاریان متصل به سرور دجله
  static const List<ReciterModel> defaultReciters = [
    ReciterModel(
      id: 'alafasy',
      name: 'مشاري العفاسي',
      subName: 'مرتل (128 kbps)',
      bitrateKbps: 128,
      isAvailable: true,
    ),
    ReciterModel(
      id: 'husary',
      name: 'محمود خليل الحصري',
      subName: 'مرتل (128 kbps)',
      bitrateKbps: 128,
      isAvailable: true,
    ),
    ReciterModel(
      id: 'maher',
      name: 'ماهر المعيقلي',
      subName: 'مرتل (128 kbps)',
      bitrateKbps: 128,
      isAvailable: true,
    ),
    ReciterModel(
      id: 'sudais',
      name: 'عبد الرحمن السديس',
      subName: 'مرتل (192 kbps)',
      bitrateKbps: 192,
      isAvailable: true,
    ),
    ReciterModel(
      id: 'shaatree',
      name: 'أبو بكر الشاطري',
      subName: 'مرتل (128 kbps)',
      bitrateKbps: 128,
      isAvailable: true,
    ),
    ReciterModel(
      id: 'basfar',
      name: 'عبد الله بصفر',
      subName: 'مرتل (192 kbps)',
      bitrateKbps: 192,
      isAvailable: true,
    ),
    ReciterModel(
      id: 'minshawy',
      name: 'محمد صديق المنشاوي',
      subName: 'مرتل (128 kbps)',
      bitrateKbps: 128,
      isAvailable: true,
    ),
    ReciterModel(
      id: 'ajamy',
      name: 'أحمد بن علي العجمي',
      subName: 'مرتل (128 kbps)',
      bitrateKbps: 128,
      isAvailable: true,
    ),
  ];
}
