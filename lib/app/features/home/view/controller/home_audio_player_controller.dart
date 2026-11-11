import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/services/media_notification_service.dart';

class HomeAudioPlayerController extends GetxController {
  static HomeAudioPlayerController get to => Get.find<HomeAudioPlayerController>();

  final AudioPlayer _player = AudioPlayer();

  final RxBool isPlaying = false.obs;
  final RxBool isLoading = false.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  final Rx<Duration> position = Duration.zero.obs;

  final RxString title = 'سورة الفاتحة'.obs;
  final RxString reciter = 'الشيخ مشاري راشد العفاسي'.obs;
  // Reliable high-speed test Quran audio URL
  final RxString audioUrl =
      'https://server8.mp3quran.net/afs/001.mp3'.obs;

  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;

  static const String _kPlayerId = 'home_player';

  @override
  void onInit() {
    super.onInit();
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    _playerStateSubscription = _player.onPlayerStateChanged.listen((state) {
      isPlaying.value = (state == PlayerState.playing);
      if (state == PlayerState.playing || state == PlayerState.paused) {
        isLoading.value = false;
      }
      if (state == PlayerState.playing) {
        _updateMediaNotification(isPlaying: true);
      } else if (state == PlayerState.paused) {
        _updateMediaNotification(isPlaying: false);
      } else if (state == PlayerState.completed || state == PlayerState.stopped) {
        position.value = Duration.zero;
        isPlaying.value = false;
        isLoading.value = false;
        if (Get.isRegistered<MediaNotificationService>()) {
          MediaNotificationService.to.hideNotification(id: _kPlayerId);
        }
      }
    });

    _durationSubscription = _player.onDurationChanged.listen((newDuration) {
      duration.value = newDuration;
    });

    _positionSubscription = _player.onPositionChanged.listen((newPosition) {
      position.value = newPosition;
    });
  }

  Future<void> togglePlayPause() async {
    try {
      if (isPlaying.value) {
        await _player.pause();
      } else {
        isLoading.value = true;
        await _player.play(UrlSource(audioUrl.value));
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
      isLoading.value = false;
      isPlaying.value = false;
    }
  }

  Future<void> seek(Duration newPosition) async {
    try {
      await _player.seek(newPosition);
    } catch (e) {
      debugPrint('Error seeking audio: $e');
    }
  }

  Future<void> seekRelative(int seconds) async {
    final currentSec = position.value.inSeconds;
    final totalSec = duration.value.inSeconds;
    final maxLimit = totalSec > 0 ? totalSec : currentSec + seconds;
    final targetSec = (currentSec + seconds).clamp(0, maxLimit);
    await seek(Duration(seconds: targetSec));
  }

  Future<void> stop() async {
    try {
      await _player.stop();
      position.value = Duration.zero;
      isPlaying.value = false;
      isLoading.value = false;
      if (Get.isRegistered<MediaNotificationService>()) {
        MediaNotificationService.to.hideNotification(id: _kPlayerId);
      }
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  void _updateMediaNotification({required bool isPlaying}) {
    if (Get.isRegistered<MediaNotificationService>()) {
      MediaNotificationService.to.showMediaNotification(
        MediaNotificationItem(
          id: _kPlayerId,
          title: title.value,
          subtitle: reciter.value,
          isPlaying: isPlaying,
          position: position.value,
          duration: duration.value,
          onPlay: togglePlayPause,
          onPause: togglePlayPause,
          onSeek: seek,
          onNext: () => seekRelative(10),
          onPrevious: () => seekRelative(-10),
          onStop: stop,
        ),
      );
    }
  }

  String formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void onClose() {
    if (Get.isRegistered<MediaNotificationService>()) {
      MediaNotificationService.to.hideNotification(id: _kPlayerId);
    }
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _player.dispose();
    super.onClose();
  }
}
