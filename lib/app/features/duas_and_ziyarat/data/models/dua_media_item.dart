import 'package:flutter/material.dart';

class DuaCategoryModel {
  final String id;
  final String title;
  final String subtitle;
  final IconData? icon;
  final int itemCount;
  final int sortOrder;
  final bool enabled;

  const DuaCategoryModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.icon,
    this.itemCount = 0,
    this.sortOrder = 0,
    this.enabled = true,
  });

  factory DuaCategoryModel.fromJson(Map<String, dynamic> json) {
    final title = json['nameArabic']?.toString() ?? json['title']?.toString() ?? '';
    final subtitle = json['descriptionArabic']?.toString() ?? json['subtitle']?.toString() ?? '';
    final count = json['itemCount'] is int
        ? json['itemCount'] as int
        : (json['voiceCount'] is int
            ? json['voiceCount'] as int
            : (int.tryParse(json['itemCount']?.toString() ?? json['voiceCount']?.toString() ?? '0') ?? 0));
    final sort = json['sortOrder'] is int
        ? json['sortOrder'] as int
        : (int.tryParse(json['sortOrder']?.toString() ?? '0') ?? 0);
    final isEnabled = json['enabled'] == null ? true : (json['enabled'] == true);

    return DuaCategoryModel(
      id: json['id']?.toString() ?? '',
      title: title,
      subtitle: subtitle,
      itemCount: count,
      sortOrder: sort,
      enabled: isEnabled,
      icon: _getIconForCategory(title),
    );
  }

  static IconData _getIconForCategory(String name) {
    if (name.contains('قرآن')) return Icons.menu_book_rounded;
    if (name.contains('دعاء') || name.contains('أدعية') || name.contains('ادعية')) {
      return Icons.volunteer_activism_rounded;
    }
    if (name.contains('زيار')) return Icons.mosque_rounded;
    if (name.contains('مراث') || name.contains('عزاء')) return Icons.auto_stories_rounded;
    if (name.contains('محاضر')) return Icons.record_voice_over_rounded;
    if (name.contains('يوم') || name.contains('أيام') || name.contains('أسبوع')) {
      return Icons.calendar_month_rounded;
    }
    return Icons.ondemand_video_rounded;
  }
}

class DuaAudioItem {
  final String id;
  final String categoryId;
  final String? categoryNameArabic;
  final String? mediaAssetId;
  final String title;
  final String reciter;
  final String durationText;
  final String audioUrl;
  final String? mimeType;
  final int? sizeBytes;
  final int sortOrder;
  final bool published;
  final String? text; // متن دعا جهت نمایش و مطالعه همزمان (قابل باز و بسته شدن)

  const DuaAudioItem({
    required this.id,
    required this.categoryId,
    this.categoryNameArabic,
    this.mediaAssetId,
    required this.title,
    required this.reciter,
    required this.durationText,
    required this.audioUrl,
    this.mimeType,
    this.sizeBytes,
    this.sortOrder = 0,
    this.published = true,
    this.text,
  });

  bool get hasText => text != null && text!.trim().isNotEmpty;

  Duration? get estimatedDuration {
    if (durationText.isNotEmpty && durationText != '--:--') {
      final parts = durationText.trim().split(':');
      if (parts.length == 2) {
        final m = int.tryParse(parts[0]) ?? 0;
        final s = int.tryParse(parts[1]) ?? 0;
        if (m > 0 || s > 0) return Duration(minutes: m, seconds: s);
      } else if (parts.length == 3) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        final s = int.tryParse(parts[2]) ?? 0;
        if (h > 0 || m > 0 || s > 0) {
          return Duration(hours: h, minutes: m, seconds: s);
        }
      }
    }
    if (sizeBytes != null && sizeBytes! > 0) {
      final sec = (sizeBytes! / 16000).round();
      return Duration(seconds: sec > 0 ? sec : 1);
    }
    return null;
  }

  factory DuaAudioItem.fromJson(Map<String, dynamic> json) {
    final size = json['sizeBytes'] is int
        ? json['sizeBytes'] as int
        : (int.tryParse(json['sizeBytes']?.toString() ?? '') ??
           (json['fileSize'] is int ? json['fileSize'] as int : int.tryParse(json['fileSize']?.toString() ?? '')));

    int? durationSec = json['durationSeconds'] is int
        ? json['durationSeconds'] as int
        : (int.tryParse(json['durationSeconds']?.toString() ?? '') ??
           (json['duration'] is int ? json['duration'] as int : int.tryParse(json['duration']?.toString() ?? '')));

    String durText = json['durationText']?.toString() ?? '';
    if (durText.isEmpty && durationSec != null && durationSec > 0) {
      final m = (durationSec ~/ 60).toString().padLeft(2, '0');
      final s = (durationSec % 60).toString().padLeft(2, '0');
      durText = '$m:$s';
    } else if (durText.isEmpty && size != null && size > 0) {
      final totalSec = (size / 16000).round();
      final m = (totalSec ~/ 60).toString().padLeft(2, '0');
      final s = (totalSec % 60).toString().padLeft(2, '0');
      durText = '$m:$s';
    } else if (durText.isEmpty) {
      durText = '--:--';
    }

    final sort = json['sortOrder'] is int
        ? json['sortOrder'] as int
        : (int.tryParse(json['sortOrder']?.toString() ?? '0') ?? 0);

    final url = json['audioUrl']?.toString() ??
        json['url']?.toString() ??
        json['fileUrl']?.toString() ??
        json['streamUrl']?.toString() ??
        '';

    final title = json['titleArabic']?.toString() ??
        json['nameArabic']?.toString() ??
        json['title']?.toString() ??
        '';

    final reciter = json['descriptionArabic']?.toString() ??
        json['reciter']?.toString() ??
        json['authorArabic']?.toString() ??
        json['speakerArabic']?.toString() ??
        '';

    final categoryId = json['categoryId']?.toString() ??
        json['voiceCategoryId']?.toString() ??
        '';

    final text = json['text']?.toString() ??
        json['contentArabic']?.toString() ??
        json['arabicText']?.toString();

    return DuaAudioItem(
      id: json['id']?.toString() ?? '',
      categoryId: categoryId,
      categoryNameArabic: json['categoryNameArabic']?.toString(),
      mediaAssetId: json['mediaAssetId']?.toString(),
      title: title,
      reciter: reciter,
      durationText: durText,
      audioUrl: url,
      mimeType: json['mimeType']?.toString(),
      sizeBytes: size,
      sortOrder: sort,
      published: json['published'] == null ? true : (json['published'] == true),
      text: text,
    );
  }
}

class DuaVideoItem {
  final String id;
  final String categoryId;
  final String? categoryNameArabic;
  final String? mediaAssetId;
  final String? source;
  final String? youtubeVideoId;
  final String? youtubeUrl;
  final String title;
  final String reciter;
  final String durationText;
  final String videoUrl;
  final String? thumbnailUrl;
  final String? mimeType;
  final int? sizeBytes;
  final int sortOrder;
  final bool published;

  const DuaVideoItem({
    required this.id,
    required this.categoryId,
    this.categoryNameArabic,
    this.mediaAssetId,
    this.source,
    this.youtubeVideoId,
    this.youtubeUrl,
    required this.title,
    required this.reciter,
    required this.durationText,
    required this.videoUrl,
    this.thumbnailUrl,
    this.mimeType,
    this.sizeBytes,
    this.sortOrder = 0,
    this.published = true,
  });

  bool get isYouTube =>
      source?.toLowerCase() == 'youtube' ||
      (youtubeVideoId != null && youtubeVideoId!.isNotEmpty) ||
      videoUrl.contains('youtube.com') ||
      videoUrl.contains('youtu.be');

  factory DuaVideoItem.fromJson(Map<String, dynamic> json) {
    final size = json['sizeBytes'] is int
        ? json['sizeBytes'] as int
        : (int.tryParse(json['sizeBytes']?.toString() ?? '') ??
           (json['fileSize'] is int ? json['fileSize'] as int : int.tryParse(json['fileSize']?.toString() ?? '')));

    int? durationSec = json['durationSeconds'] is int
        ? json['durationSeconds'] as int
        : (int.tryParse(json['durationSeconds']?.toString() ?? '') ??
           (json['duration'] is int ? json['duration'] as int : int.tryParse(json['duration']?.toString() ?? '')));

    String durText = json['durationText']?.toString() ?? '';
    if (durText.isEmpty && durationSec != null && durationSec > 0) {
      final m = (durationSec ~/ 60).toString().padLeft(2, '0');
      final s = (durationSec % 60).toString().padLeft(2, '0');
      durText = '$m:$s';
    } else if (durText.isEmpty && size != null && size > 0) {
      final totalSec = (size / 100000).round();
      final m = (totalSec ~/ 60).toString().padLeft(2, '0');
      final s = (totalSec % 60).toString().padLeft(2, '0');
      durText = '$m:$s';
    } else if (durText.isEmpty) {
      durText = '--:--';
    }

    final sort = json['sortOrder'] is int
        ? json['sortOrder'] as int
        : (int.tryParse(json['sortOrder']?.toString() ?? '0') ?? 0);

    final ytUrl = json['youtubeUrl']?.toString();
    final ytId = json['youtubeVideoId']?.toString();
    final src = json['source']?.toString();

    final url = json['videoUrl']?.toString() ??
        ytUrl ??
        (ytId != null && ytId.isNotEmpty ? 'https://www.youtube.com/watch?v=$ytId' : null) ??
        json['url']?.toString() ??
        json['fileUrl']?.toString() ??
        json['streamUrl']?.toString() ??
        '';

    final title = json['titleArabic']?.toString() ??
        json['nameArabic']?.toString() ??
        json['title']?.toString() ??
        '';

    final reciter = json['descriptionArabic']?.toString() ??
        json['reciter']?.toString() ??
        json['speakerArabic']?.toString() ??
        json['authorArabic']?.toString() ??
        '';

    final categoryId = json['categoryId']?.toString() ??
        json['videoCategoryId']?.toString() ??
        '';

    final thumb = json['thumbnailUrl']?.toString() ??
        (ytId != null && ytId.isNotEmpty ? 'https://i.ytimg.com/vi/$ytId/hqdefault.jpg' : null) ??
        json['coverUrl']?.toString() ??
        json['posterUrl']?.toString() ??
        json['imageUrl']?.toString() ??
        json['image']?.toString();

    return DuaVideoItem(
      id: json['id']?.toString() ?? '',
      categoryId: categoryId,
      categoryNameArabic: json['categoryNameArabic']?.toString(),
      mediaAssetId: json['mediaAssetId']?.toString(),
      source: src,
      youtubeVideoId: ytId,
      youtubeUrl: ytUrl,
      title: title,
      reciter: reciter,
      durationText: durText,
      videoUrl: url,
      thumbnailUrl: thumb,
      mimeType: json['mimeType']?.toString(),
      sizeBytes: size,
      sortOrder: sort,
      published: json['published'] == null ? true : (json['published'] == true),
    );
  }
}
