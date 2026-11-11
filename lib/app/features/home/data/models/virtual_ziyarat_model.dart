class RemoteZiyarahReadingModel {
  final String id;
  final String locationId;
  final String titleArabic;
  final String bodyArabic;
  final int sortOrder;
  final bool published;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RemoteZiyarahReadingModel({
    required this.id,
    required this.locationId,
    required this.titleArabic,
    required this.bodyArabic,
    this.sortOrder = 0,
    this.published = true,
    this.createdAt,
    this.updatedAt,
  });

  factory RemoteZiyarahReadingModel.fromJson(Map<String, dynamic> json) {
    return RemoteZiyarahReadingModel(
      id: json['id']?.toString() ?? '',
      locationId: json['locationId']?.toString() ?? '',
      titleArabic: json['titleArabic'] ?? json['title'] ?? '',
      bodyArabic: json['bodyArabic'] ?? json['body'] ?? json['text'] ?? '',
      sortOrder: json['sortOrder'] is int
          ? json['sortOrder']
          : int.tryParse(json['sortOrder']?.toString() ?? '0') ?? 0,
      published: json['published'] == null ? true : json['published'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'locationId': locationId,
      'titleArabic': titleArabic,
      'bodyArabic': bodyArabic,
      'sortOrder': sortOrder,
      'published': published,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class VirtualZiyaratModel {
  final String id;
  final String slug;
  final String nameArabic; // المدينة المنورة
  final String shrineNameArabic; // المسجد النبوي
  final String? descriptionArabic;
  final double latitude;
  final double longitude;
  final String liveUrl;
  final int sortOrder;
  final bool enabled;
  final int readingCount;
  final String? posterUrl;
  final List<RemoteZiyarahReadingModel> readings;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VirtualZiyaratModel({
    required this.id,
    this.slug = '',
    required this.nameArabic,
    required this.shrineNameArabic,
    this.descriptionArabic,
    required this.latitude,
    required this.longitude,
    required this.liveUrl,
    this.sortOrder = 0,
    this.enabled = true,
    this.readingCount = 0,
    this.posterUrl,
    this.readings = const [],
    this.createdAt,
    this.updatedAt,
  });

  // Backward-compatible convenience getters for UI & Controller
  String get shrineName =>
      shrineNameArabic.isNotEmpty ? shrineNameArabic : nameArabic;
  String get city => nameArabic;
  String get imamName => shrineNameArabic;
  String get streamUrl => _getEmbedUrl(liveUrl);
  String get externalUrl => liveUrl;
  String get ziyaratTitle => readings.isNotEmpty
      ? readings.first.titleArabic
      : 'زيارة $shrineName';
  String get ziyaratArabicText => readings.isNotEmpty
      ? readings.first.bodyArabic
      : (descriptionArabic ?? '');
  String? get prayerName => ziyaratTitle;

  /// تبدیل خودکار لینک‌های یوتیوب یا آپارات به پلیر اختصاصی توکار (Embed)
  /// تا کل سایت یوتیوب باز نشود و فقط ویدیو به صورت تمام‌کادر پخش شود
  static String _getEmbedUrl(String rawUrl) {
    if (rawUrl.isEmpty) return rawUrl;

    // ۱. بررسی لینک‌های یوتیوب (watch?v=, youtu.be, live/, embed/, shorts/)
    final ytRegex = RegExp(
      r'(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=|live\/|shorts\/))([\w-]{11})',
      caseSensitive: false,
    );
    final ytMatch = ytRegex.firstMatch(rawUrl);
    if (ytMatch != null && ytMatch.groupCount >= 1) {
      final videoId = ytMatch.group(1);
      return 'https://www.youtube.com/embed/$videoId?autoplay=1&playsinline=1&rel=0&modestbranding=1&enablejsapi=1';
    }

    // ۲. بررسی لینک‌های آپارات
    final aparatRegex = RegExp(r'aparat\.com\/v\/([a-zA-Z0-9]+)');
    final aparatMatch = aparatRegex.firstMatch(rawUrl);
    if (aparatMatch != null) {
      final hash = aparatMatch.group(1);
      return 'https://www.aparat.com/video/video/embed/videohash/$hash/vt/frame';
    }

    return rawUrl;
  }

  factory VirtualZiyaratModel.fromJson(Map<String, dynamic> json) {
    final rawReadings = json['readings'] as List?;
    final readingsList = (rawReadings
            ?.map((e) =>
                RemoteZiyarahReadingModel.fromJson(Map<String, dynamic>.from(e)))
            .where((r) => r.published)
            .toList() ??
        [])
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return VirtualZiyaratModel(
      id: json['id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      nameArabic: json['nameArabic'] ?? json['city'] ?? '',
      shrineNameArabic:
          json['shrineNameArabic'] ?? json['shrineName'] ?? json['name'] ?? '',
      descriptionArabic: json['descriptionArabic'] ?? json['description'],
      latitude: json['latitude'] is num
          ? (json['latitude'] as num).toDouble()
          : double.tryParse(json['latitude']?.toString() ?? '0.0') ?? 0.0,
      longitude: json['longitude'] is num
          ? (json['longitude'] as num).toDouble()
          : double.tryParse(json['longitude']?.toString() ?? '0.0') ?? 0.0,
      liveUrl: json['liveUrl'] ??
          json['streamUrl'] ??
          json['externalUrl'] ??
          '',
      sortOrder: json['sortOrder'] is int
          ? json['sortOrder']
          : int.tryParse(json['sortOrder']?.toString() ?? '0') ?? 0,
      enabled: json['enabled'] == null ? true : json['enabled'] == true,
      readingCount: json['readingCount'] is int
          ? json['readingCount']
          : int.tryParse(json['readingCount']?.toString() ?? '0') ??
              readingsList.length,
      posterUrl: json['posterUrl'] ?? json['coverUrl'] ?? json['imageUrl'],
      readings: readingsList,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'nameArabic': nameArabic,
      'shrineNameArabic': shrineNameArabic,
      'descriptionArabic': descriptionArabic,
      'latitude': latitude,
      'longitude': longitude,
      'liveUrl': liveUrl,
      'sortOrder': sortOrder,
      'enabled': enabled,
      'readingCount': readingCount,
      'posterUrl': posterUrl,
      'readings': readings.map((e) => e.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  VirtualZiyaratModel copyWith({
    String? id,
    String? slug,
    String? nameArabic,
    String? shrineNameArabic,
    String? descriptionArabic,
    double? latitude,
    double? longitude,
    String? liveUrl,
    int? sortOrder,
    bool? enabled,
    int? readingCount,
    String? posterUrl,
    List<RemoteZiyarahReadingModel>? readings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VirtualZiyaratModel(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      nameArabic: nameArabic ?? this.nameArabic,
      shrineNameArabic: shrineNameArabic ?? this.shrineNameArabic,
      descriptionArabic: descriptionArabic ?? this.descriptionArabic,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      liveUrl: liveUrl ?? this.liveUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      enabled: enabled ?? this.enabled,
      readingCount: readingCount ?? this.readingCount,
      posterUrl: posterUrl ?? this.posterUrl,
      readings: readings ?? this.readings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
