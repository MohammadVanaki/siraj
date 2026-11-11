import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/data_sources/duas_mock_data.dart';
import '../data/models/dua_media_item.dart';
import '../data/repositories/duas_repository.dart';
import '../data/repositories/remote_duas_repository.dart';
import '../data/services/duas_audio_cache_service.dart';
import 'package:mawsueat/app/core/services/media_notification_service.dart';

enum DuasMediaType {
  audio, // صوتيات
  video, // مرئيات
}

class DuasController extends GetxController {
  DuasRepository get _repository {
    if (Get.isRegistered<DuasRepository>()) {
      return Get.find<DuasRepository>();
    }
    return Get.put<DuasRepository>(RemoteDuasRepository());
  }

  DuasAudioCacheService get _cacheService {
    if (Get.isRegistered<DuasAudioCacheService>()) {
      return Get.find<DuasAudioCacheService>();
    }
    return Get.put(DuasAudioCacheService());
  }

  // تب جاری (صوتيات / مرئيات)
  final Rx<DuasMediaType> selectedTab = DuasMediaType.audio.obs;

  // دسته‌بندی‌های صوتیات
  final RxList<DuaCategoryModel> audioCategories = <DuaCategoryModel>[].obs;
  final RxList<DuaCategoryModel> filteredAudioCategories = <DuaCategoryModel>[].obs;

  // دسته‌بندی‌های مرئیات
  final RxList<DuaCategoryModel> videoCategories = <DuaCategoryModel>[].obs;
  final RxList<DuaCategoryModel> filteredVideoCategories = <DuaCategoryModel>[].obs;

  // کل آیتم‌ها
  final RxList<DuaAudioItem> allAudios = <DuaAudioItem>[].obs;
  final RxList<DuaVideoItem> allVideos = <DuaVideoItem>[].obs;

  final TextEditingController searchController = TextEditingController();

  // وضعیت بارگذاری شبکه
  final RxBool isLoadingData = false.obs;

  // وضعیت پخش صوت
  final AudioPlayer _audioPlayer = AudioPlayer();
  final RxnString activePlayingId = RxnString();
  final RxBool isPlaying = false.obs;
  final RxBool isLoadingAudio = false.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> bufferedPosition = Duration.zero.obs;

  // وضعیت دانلود و کش بایت‌ها
  final RxMap<String, double> downloadProgress = <String, double>{}.obs;
  final RxSet<String> cachedIds = <String>{}.obs;
  CancelToken? _currentDownloadCancel;

  bool isItemCached(String id) => cachedIds.contains(id);

  // آی‌دی آیتم‌هایی که متن آن‌ها باز (Expand) شده است
  final RxSet<String> expandedTextIds = <String>{}.obs;

  StreamSubscription? _playerStateSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _positionSub;

  @override
  void onInit() {
    super.onInit();
    _initAudioListeners();
    loadData();
    searchController.addListener(_onSearchChanged);
  }

  static const String _kPlayerId = 'duas_player';

  @override
  void onClose() {
    _currentDownloadCancel?.cancel();
    _playerStateSub?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    searchController.dispose();
    if (Get.isRegistered<MediaNotificationService>()) {
      MediaNotificationService.to.hideNotification(id: _kPlayerId);
    }
    super.onClose();
  }

  void _initAudioListeners() {
    _playerStateSub = _audioPlayer.onPlayerStateChanged.listen((state) async {
      isPlaying.value = (state == PlayerState.playing);
      if (state == PlayerState.playing || state == PlayerState.paused) {
        isLoadingAudio.value = false;
        if (duration.value == Duration.zero) {
          final d = await _audioPlayer.getDuration();
          if (d != null && d > Duration.zero) {
            duration.value = d;
          }
        }
      }
      if (state == PlayerState.playing) {
        _updateMediaNotification(isPlaying: true);
      } else if (state == PlayerState.paused) {
        _updateMediaNotification(isPlaying: false);
      } else if (state == PlayerState.completed) {
        position.value = Duration.zero;
        isPlaying.value = false;
        isLoadingAudio.value = false;
        activePlayingId.value = null;
        if (Get.isRegistered<MediaNotificationService>()) {
          MediaNotificationService.to.hideNotification(id: _kPlayerId);
        }
      }
    });

    _durationSub = _audioPlayer.onDurationChanged.listen((d) {
      if (d > Duration.zero) {
        duration.value = d;
      }
    });

    _positionSub = _audioPlayer.onPositionChanged.listen((p) {
      position.value = p;

      // در صورتی که فایل هنوز کامل کش نشده، پیشروی بافر تخمینی را هم حداقل تا ثانیه‌های بعد نگه می‌دارد
      if (activePlayingId.value != null && !isItemCached(activePlayingId.value!)) {
        final target = p + const Duration(seconds: 35);
        if (duration.value > Duration.zero && target > duration.value) {
          bufferedPosition.value = duration.value;
        } else if (target > bufferedPosition.value) {
          bufferedPosition.value = target;
        }
      }
    });
  }

  void _updateMediaNotification({required bool isPlaying}) {
    if (Get.isRegistered<MediaNotificationService>() && activePlayingId.value != null) {
      final item = allAudios.firstWhereOrNull((a) => a.id == activePlayingId.value);
      if (item == null) return;
      MediaNotificationService.to.showMediaNotification(
        MediaNotificationItem(
          id: _kPlayerId,
          title: item.title,
          subtitle: item.reciter,
          isPlaying: isPlaying,
          position: position.value,
          duration: duration.value,
          onPlay: () {
            if (activePlayingId.value != null) {
              final active = allAudios.firstWhereOrNull((a) => a.id == activePlayingId.value);
              if (active != null) togglePlayAudio(active);
            }
          },
          onPause: () {
            if (activePlayingId.value != null) {
              final active = allAudios.firstWhereOrNull((a) => a.id == activePlayingId.value);
              if (active != null) togglePlayAudio(active);
            }
          },
          onSeek: seekAudio,
          onNext: playNextAudio,
          onPrevious: playPreviousAudio,
          onStop: stopAudio,
        ),
      );
    }
  }

  void playNextAudio() {
    if (activePlayingId.value != null && allAudios.isNotEmpty) {
      final currentIndex = allAudios.indexWhere((a) => a.id == activePlayingId.value);
      if (currentIndex != -1 && currentIndex + 1 < allAudios.length) {
        togglePlayAudio(allAudios[currentIndex + 1]);
      }
    }
  }

  void playPreviousAudio() {
    if (activePlayingId.value != null && allAudios.isNotEmpty) {
      final currentIndex = allAudios.indexWhere((a) => a.id == activePlayingId.value);
      if (currentIndex > 0) {
        togglePlayAudio(allAudios[currentIndex - 1]);
      }
    }
  }

  Future<void> stopAudio() async {
    _currentDownloadCancel?.cancel();
    await _audioPlayer.stop();
    position.value = Duration.zero;
    bufferedPosition.value = Duration.zero;
    isPlaying.value = false;
    isLoadingAudio.value = false;
    activePlayingId.value = null;
    if (Get.isRegistered<MediaNotificationService>()) {
      MediaNotificationService.to.hideNotification(id: _kPlayerId);
    }
  }

  Future<void> loadData() async {
    _checkCachedAudios();

    // واکشی مستقیم دسته‌بندی‌ها و محتواهای صوتی و تصویری از API دجله
    await fetchRemoteData();
    _checkCachedAudios();

    // پشتیبان آفلاین در صورت خالی بودن اولیه یا عدم دسترسی به شبکه
    if (videoCategories.isEmpty) {
      videoCategories.assignAll(DuasMockData.videoCategories);
      _applyFilter();
    }
    if (allVideos.isEmpty) {
      allVideos.assignAll(DuasMockData.testVideos);
    }
  }

  Future<void> _checkCachedAudios() async {
    for (final audio in allAudios) {
      final path = await _cacheService.getCachedFilePath(audio.id);
      if (path != null) {
        cachedIds.add(audio.id);
        downloadProgress[audio.id] = 1.0;
      }
    }
  }

  Future<void> fetchRemoteData() async {
    try {
      isLoadingData.value = true;

      // ۱. واکشی صوتیات (دسته‌ها و فایل‌های صوتی)
      final remoteVoiceCategories = await _repository.getVoiceCategories();
      if (remoteVoiceCategories.isNotEmpty) {
        audioCategories.assignAll(remoteVoiceCategories);
      }

      final remoteVoices = await _repository.getVoices();
      if (remoteVoices.isNotEmpty) {
        allAudios.assignAll(remoteVoices);
      }

      // ۲. واکشی مرئیات (دسته‌ها و فایل‌های تصویری)
      final remoteVideoCategories = await _repository.getVideoCategories();
      if (remoteVideoCategories.isNotEmpty) {
        videoCategories.assignAll(remoteVideoCategories);
      }

      final remoteVideos = await _repository.getVideos();
      if (remoteVideos.isNotEmpty) {
        allVideos.assignAll(remoteVideos);
      } else if (remoteVideoCategories.isNotEmpty) {
        // در صورتی که اندپوینت کلی خالی بود، ویدیوهای هر دسته به‌صورت مجزا واکشی می‌شوند
        for (final cat in remoteVideoCategories) {
          final catVideos = await _repository.getVideos(categoryId: cat.id);
          if (catVideos.isNotEmpty) {
            for (final v in catVideos) {
              if (!allVideos.any((item) => item.id == v.id)) {
                allVideos.add(v);
              }
            }
          }
        }
      }

      _applyFilter();
    } catch (e) {
      debugPrint('Error fetching remote duas and videos data: $e');
    } finally {
      isLoadingData.value = false;
    }
  }

  Future<void> loadCategoryVideosIfNeeded(String categoryId) async {
    try {
      final videos = await _repository.getVideos(categoryId: categoryId);
      if (videos.isNotEmpty) {
        for (final video in videos) {
          allVideos.removeWhere((v) => v.id == video.id);
          allVideos.add(video);
        }
      }
    } catch (e) {
      debugPrint('Error loading category videos ($categoryId): $e');
    }
  }

  Future<void> refreshData() async {
    await fetchRemoteData();
    await _checkCachedAudios();
  }

  void setTab(DuasMediaType tab) {
    selectedTab.value = tab;
    _applyFilter();
  }

  List<DuaAudioItem> getAudiosForCategory(String categoryId) {
    return allAudios.where((a) => a.categoryId == categoryId).toList();
  }

  List<DuaVideoItem> getVideosForCategory(String categoryId) {
    return allVideos.where((v) => v.categoryId == categoryId).toList();
  }

  void toggleExpandText(String id) {
    if (expandedTextIds.contains(id)) {
      expandedTextIds.remove(id);
    } else {
      // برای جلوگیری از پرش و تغییر ارتفاع سایر کارت‌ها، در هر لحظه یک متن باز است
      expandedTextIds.clear();
      expandedTextIds.add(id);
    }
  }

  bool isTextExpanded(String id) => expandedTextIds.contains(id);

  // اندازه قلم متن دعاها
  final RxDouble duaFontSize = 15.0.obs;

  void increaseDuaFontSize() {
    if (duaFontSize.value < 28.0) {
      duaFontSize.value += 1.0;
    }
  }

  void decreaseDuaFontSize() {
    if (duaFontSize.value > 12.0) {
      duaFontSize.value -= 1.0;
    }
  }

  Future<void> togglePlayAudio(DuaAudioItem item) async {
    if (activePlayingId.value == item.id) {
      if (isPlaying.value) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
      return;
    }

    _currentDownloadCancel?.cancel();
    _currentDownloadCancel = CancelToken();

    activePlayingId.value = item.id;
    isLoadingAudio.value = true;
    position.value = Duration.zero;
    duration.value = item.estimatedDuration ?? Duration.zero;
    bufferedPosition.value = Duration.zero;
    await _audioPlayer.stop();

    // ۱. اگر فایل قبلاً کامل دانلود و کش شده است، مستقیم از فایل محلی پخش شود
    final cachedPath = await _cacheService.getCachedFilePath(item.id);
    if (cachedPath != null) {
      cachedIds.add(item.id);
      downloadProgress[item.id] = 1.0;
      bufferedPosition.value = duration.value > Duration.zero
          ? duration.value
          : (item.estimatedDuration ?? const Duration(seconds: 180));
      isLoadingAudio.value = false;

      try {
        await _audioPlayer.play(DeviceFileSource(cachedPath));
        final d = await _audioPlayer.getDuration();
        if (d != null && d > Duration.zero) {
          duration.value = d;
          bufferedPosition.value = d;
        }
      } catch (e) {
        debugPrint('Error playing cached audio: $e');
      }
      return;
    }

    // ۲. در صورتی که فایل هنوز کش نشده:
    // بلافاصله به عنوان استریم شروع به پخش می‌کند (بدون هیچ معطلی برای اتمام دانلود)
    try {
      bufferedPosition.value = const Duration(seconds: 15);
      await _audioPlayer.play(UrlSource(item.audioUrl));
      isLoadingAudio.value = false;
      final d = await _audioPlayer.getDuration();
      if (d != null && d > Duration.zero) {
        duration.value = d;
      }
    } catch (e) {
      isLoadingAudio.value = false;
      debugPrint('Error playing audio stream: $e');
    }

    // ۳. همزمان در پس‌زمینه دانلود ادامه می‌یابد و نوار پیشرفت بافر را زنده بروز می‌کند
    _startBackgroundCaching(item, _currentDownloadCancel!);
  }

  void _startBackgroundCaching(DuaAudioItem item, CancelToken cancelToken) {
    _cacheService.downloadAndCache(
      id: item.id,
      url: item.audioUrl,
      cancelToken: cancelToken,
      onProgress: (ratio, received, total) {
        if (cancelToken.isCancelled) return;
        downloadProgress[item.id] = ratio;
        final currentDur = duration.value > Duration.zero
            ? duration.value
            : (item.estimatedDuration ?? Duration.zero);
        if (currentDur > Duration.zero) {
          final targetMs = (currentDur.inMilliseconds * ratio).toInt();
          final newBuffered = Duration(milliseconds: targetMs);
          if (newBuffered > bufferedPosition.value) {
            bufferedPosition.value = newBuffered;
          }
        }
      },
    ).then((cachedPath) {
      if (!cancelToken.isCancelled) {
        cachedIds.add(item.id);
        downloadProgress[item.id] = 1.0;
        if (duration.value > Duration.zero) {
          bufferedPosition.value = duration.value;
        }
      }
    }).catchError((e) {
      if (!cancelToken.isCancelled) {
        debugPrint('Background caching (streaming continues): $e');
      }
    });
  }

  Future<void> seekAudio(Duration newPosition) async {
    try {
      // تغییر آنی موقعیت در رابط کاربری برای پاسخگویی در لحظه
      position.value = newPosition;
      await _audioPlayer.seek(newPosition);
    } catch (e) {
      debugPrint('Error seeking audio: $e');
    }
  }

  void _onSearchChanged() {
    _applyFilter();
  }

  void _applyFilter() {
    final query = searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      filteredAudioCategories.assignAll(audioCategories);
      filteredVideoCategories.assignAll(videoCategories);
      return;
    }

    final normalizedQuery = _normalizeArabic(query);

    filteredAudioCategories.assignAll(audioCategories.where((cat) {
      final titleMatch = _normalizeArabic(cat.title).contains(normalizedQuery);
      final subtitleMatch = _normalizeArabic(cat.subtitle).contains(normalizedQuery);
      return titleMatch || subtitleMatch;
    }).toList());

    filteredVideoCategories.assignAll(videoCategories.where((cat) {
      final titleMatch = _normalizeArabic(cat.title).contains(normalizedQuery);
      final subtitleMatch = _normalizeArabic(cat.subtitle).contains(normalizedQuery);
      return titleMatch || subtitleMatch;
    }).toList());
  }

  String _normalizeArabic(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ي', 'ی')
        .replaceAll('ئ', 'ی')
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        .toLowerCase();
  }
}
