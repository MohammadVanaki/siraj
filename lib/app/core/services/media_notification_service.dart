import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

/// مدل آیتم رسانه‌ای برای ارسال به کنترلر پیش‌فرض سیستم (MediaSession / Lock Screen)
class MediaNotificationItem {
  final String id;
  final String title;
  final String subtitle;
  final bool isPlaying;
  final Duration? duration;
  final Duration? position;
  final String? artUri;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final Future<void> Function(Duration)? onSeek;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final VoidCallback onStop;

  const MediaNotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.isPlaying,
    this.duration,
    this.position,
    this.artUri,
    required this.onPlay,
    required this.onPause,
    this.onSeek,
    this.onNext,
    this.onPrevious,
    required this.onStop,
  });

  MediaNotificationItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    bool? isPlaying,
    Duration? duration,
    Duration? position,
    String? artUri,
    VoidCallback? onPlay,
    VoidCallback? onPause,
    Future<void> Function(Duration)? onSeek,
    VoidCallback? onNext,
    VoidCallback? onPrevious,
    VoidCallback? onStop,
  }) {
    return MediaNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      isPlaying: isPlaying ?? this.isPlaying,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      artUri: artUri ?? this.artUri,
      onPlay: onPlay ?? this.onPlay,
      onPause: onPause ?? this.onPause,
      onSeek: onSeek ?? this.onSeek,
      onNext: onNext ?? this.onNext,
      onPrevious: onPrevious ?? this.onPrevious,
      onStop: onStop ?? this.onStop,
    );
  }
}

/// هندلر اتصال به سیستم‌عامل برای MediaSession بومی اندروید و کنترل سنتر iOS
class AppAudioHandler extends BaseAudioHandler with SeekHandler {
  MediaNotificationItem? _currentItem;

  MediaNotificationItem? get currentItem => _currentItem;

  void setMediaItem(MediaNotificationItem item, {Uri? defaultArtUri}) {
    _currentItem = item;

    Uri? resolvedArt;
    if (item.artUri != null && item.artUri!.isNotEmpty) {
      resolvedArt = Uri.tryParse(item.artUri!);
    }
    resolvedArt ??= defaultArtUri;

    mediaItem.add(
      MediaItem(
        id: item.id,
        title: item.title,
        artist: item.subtitle,
        album: 'السراج',
        duration: item.duration,
        artUri: resolvedArt,
      ),
    );

    _updateState(
      isPlaying: item.isPlaying,
      position: item.position ?? Duration.zero,
      duration: item.duration,
    );
  }

  void updatePlaybackState({
    required bool isPlaying,
    Duration? position,
    Duration? duration,
  }) {
    if (_currentItem == null) return;
    _currentItem = _currentItem!.copyWith(
      isPlaying: isPlaying,
      position: position,
      duration: duration,
    );
    _updateState(
      isPlaying: isPlaying,
      position: position ?? _currentItem?.position ?? Duration.zero,
      duration: duration ?? _currentItem?.duration,
    );
  }

  void _updateState({
    required bool isPlaying,
    required Duration position,
    Duration? duration,
  }) {
    final hasNext = _currentItem?.onNext != null;
    final hasPrev = _currentItem?.onPrevious != null;

    final controls = <MediaControl>[
      if (hasPrev) MediaControl.skipToPrevious,
      if (isPlaying) MediaControl.pause else MediaControl.play,
      if (hasNext) MediaControl.skipToNext,
      MediaControl.stop,
    ];

    final compactIndices = <int>[];
    for (int i = 0; i < controls.length && compactIndices.length < 3; i++) {
      compactIndices.add(i);
    }

    playbackState.add(
      playbackState.value.copyWith(
        controls: controls,
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.stop,
        },
        androidCompactActionIndices: compactIndices,
        processingState: AudioProcessingState.ready,
        playing: isPlaying,
        updatePosition: position,
        bufferedPosition: position,
        speed: 1.0,
      ),
    );
  }

  void clear(String? id) {
    if (id != null && _currentItem?.id != id) return;
    _currentItem = null;
    playbackState.add(
      playbackState.value.copyWith(
        playing: false,
        processingState: AudioProcessingState.idle,
        controls: const [],
      ),
    );
    mediaItem.add(null);
  }

  @override
  Future<void> play() async {
    _currentItem?.onPlay();
  }

  @override
  Future<void> pause() async {
    _currentItem?.onPause();
  }

  @override
  Future<void> seek(Duration position) async {
    if (_currentItem?.onSeek != null) {
      await _currentItem!.onSeek!(position);
    }
  }

  @override
  Future<void> skipToNext() async {
    _currentItem?.onNext?.call();
  }

  @override
  Future<void> skipToPrevious() async {
    _currentItem?.onPrevious?.call();
  }

  @override
  Future<void> stop() async {
    _currentItem?.onStop();
    clear(_currentItem?.id);
    await super.stop();
  }
}

/// سرویس مدیریت کنترلر پیش‌فرض سیستم (Default OS Media Controller)
/// از طریق استانداردهای MediaSession در اندروید و MPNowPlayingInfoCenter در iOS
class MediaNotificationService extends GetxService {
  static MediaNotificationService get to {
    if (!Get.isRegistered<MediaNotificationService>()) {
      final s = MediaNotificationService();
      Get.put(s, permanent: true);
      return s;
    }
    return Get.find<MediaNotificationService>();
  }

  AppAudioHandler? _audioHandler;
  bool _isInitialized = false;
  static Uri? _defaultArtUri;

  AppAudioHandler? get audioHandler => _audioHandler;

  static Future<MediaNotificationService> initService() async {
    final service = MediaNotificationService();
    await service._initAudioHandler();
    await getOrCreateDefaultArtUri();
    return service;
  }

  /// آماده‌سازی تصویر و آیکون پیش‌فرض برنامه برای نمایش در پس‌زمینه مدیا پلیر و صفحه قفل
  static Future<Uri?> getOrCreateDefaultArtUri() async {
    if (_defaultArtUri != null) return _defaultArtUri;
    try {
      final byteData = await rootBundle.load('assets/images/appIcon.png');
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/app_media_cover.png');
      if (!await file.exists() ||
          await file.length() != byteData.lengthInBytes) {
        await file.writeAsBytes(
          byteData.buffer.asUint8List(
            byteData.offsetInBytes,
            byteData.lengthInBytes,
          ),
        );
      }
      _defaultArtUri = file.uri;
      return _defaultArtUri;
    } catch (e) {
      debugPrint('Error preparing default artUri: $e');
      return null;
    }
  }

  Future<void> _initAudioHandler() async {
    if (_isInitialized) return;
    try {
      _audioHandler = await AudioService.init(
        builder: () => AppAudioHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.dijlah.alseraj.media',
          androidNotificationChannelName: 'مشغل الصوتيات - السراج',
          androidNotificationChannelDescription:
              'التحكم بالصوتيات والقرآن الكريم وقفل الشاشة',
          androidNotificationIcon: 'mipmap/ic_launcher',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
          androidShowNotificationBadge: false,
          notificationColor: Color(0xFF1B5E20),
        ),
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing AudioService: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (!_isInitialized) {
      _initAudioHandler();
    }
    if (_defaultArtUri == null) {
      getOrCreateDefaultArtUri();
    }
  }

  /// نمایش و ارسال اطلاعات به کنترلر پیش‌فرض سیستم و قفل صفحه همراه با عکس و آیکون
  Future<void> showMediaNotification(MediaNotificationItem item) async {
    if (!_isInitialized || _audioHandler == null) {
      await _initAudioHandler();
    }
    if (_defaultArtUri == null) {
      await getOrCreateDefaultArtUri();
    }
    _audioHandler?.setMediaItem(item, defaultArtUri: _defaultArtUri);
  }

  /// به‌روزرسانی زنده وضعیت پخش، زمان و نوار پیشرفت در کنترلر سیستم
  void updatePlaybackState({
    required String id,
    required bool isPlaying,
    Duration? position,
    Duration? duration,
  }) {
    if (_audioHandler?.currentItem?.id == id) {
      _audioHandler?.updatePlaybackState(
        isPlaying: isPlaying,
        position: position,
        duration: duration,
      );
    }
  }

  /// حذف کنترلر رسانه از قفل صفحه و نوار کنترل سیستم
  void hideNotification({String? id}) {
    _audioHandler?.clear(id);
  }
}
