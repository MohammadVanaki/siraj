class AdhanVoiceModel {
  final String id;
  final String name;
  final String desc;
  final String assetPath;
  final String rawResource;
  final String duration;

  const AdhanVoiceModel({
    required this.id,
    required this.name,
    required this.desc,
    required this.assetPath,
    required this.rawResource,
    required this.duration,
  });

  static const List<AdhanVoiceModel> availableVoices = [
    AdhanVoiceModel(
      id: 'moazenzadeh',
      name: 'المرحوم رحيم مؤذن‌زاده أردبيلي',
      desc: 'صوت تاريخي وروحاني (بيات ترك)',
      assetPath: 'assets/audio/adhan/adhan_moazenzadeh.mp3',
      rawResource: 'adhan_moazenzadeh',
      duration: '04:25',
    ),
    AdhanVoiceModel(
      id: 'rezaeian',
      name: 'الأستاذ حسن رضائيان',
      desc: 'أداء حزين ومؤثر',
      assetPath: 'assets/audio/adhan/adhan_rezaeian.mp3',
      rawResource: 'adhan_rezaeian',
      duration: '04:30',
    ),
    AdhanVoiceModel(
      id: 'karami',
      name: 'الأستاذ حسين كرمي',
      desc: 'صوت هادئ وخاشع',
      assetPath: 'assets/audio/adhan/adhan_karami.mp3',
      rawResource: 'adhan_karami',
      duration: '04:43',
    ),
  ];

  static AdhanVoiceModel getById(String? id) {
    return availableVoices.firstWhere(
      (v) => v.id == id,
      orElse: () => availableVoices.first,
    );
  }
}
