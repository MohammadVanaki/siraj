import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../model/adhan_voice_model.dart';
import '../model/prayer_settings_model.dart';

class PrayerAudioService extends GetxController {
  static PrayerAudioService get to => Get.find<PrayerAudioService>();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final RxBool isPlaying = false.obs;
  final RxString currentPlayingPrayer = ''.obs;
  final RxString currentPlayingVoiceId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      isPlaying.value = (state == PlayerState.playing);
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        currentPlayingPrayer.value = '';
        currentPlayingVoiceId.value = '';
      }
    });
  }

  /// Toggle preview playback for a specific voice in settings sheet
  Future<void> toggleVoicePreview(AdhanVoiceModel voice) async {
    if (isPlaying.value && currentPlayingVoiceId.value == voice.id) {
      await stopAdhan();
    } else {
      await playVoicePreview(voice);
    }
  }

  /// Play preview for a specific voice
  Future<void> playVoicePreview(AdhanVoiceModel voice) async {
    try {
      await stopAdhan();
      currentPlayingPrayer.value = 'معاينة - ${voice.name}';
      currentPlayingVoiceId.value = voice.id;

      // audioplayers AssetSource expects path without leading 'assets/'
      final cleanPath = voice.assetPath.startsWith('assets/')
          ? voice.assetPath.substring(7)
          : voice.assetPath;

      await _audioPlayer.play(AssetSource(cleanPath));
    } catch (e) {
      debugPrint('Error previewing adhan: $e');
      isPlaying.value = false;
      currentPlayingVoiceId.value = '';
    }
  }

  /// Play Adhan sound for a specific prayer
  Future<void> playAdhan({
    String prayerName = '',
    String? customAssetPath,
    String? remoteUrl,
  }) async {
    try {
      await stopAdhan();
      currentPlayingPrayer.value = prayerName;

      // If remote URL is provided
      if (remoteUrl != null && remoteUrl.isNotEmpty) {
        await _audioPlayer.play(UrlSource(remoteUrl));
        return;
      }

      // Determine selected voice from settings
      String path = customAssetPath ?? '';
      if (path.isEmpty) {
        final storage = GetStorage();
        final storedJson =
            storage.read<Map<String, dynamic>>('prayer_settings');
        String voiceId = 'moazenzadeh';
        if (storedJson != null) {
          final settings = PrayerSettingsModel.fromJson(storedJson);
          voiceId = settings.adhanVoiceId;
        }
        final voice = AdhanVoiceModel.getById(voiceId);
        path = voice.assetPath;
        currentPlayingVoiceId.value = voice.id;
      }

      // audioplayers AssetSource expects path without leading 'assets/'
      final cleanPath =
          path.startsWith('assets/') ? path.substring(7) : path;

      try {
        await _audioPlayer.play(AssetSource(cleanPath));
      } catch (e) {
        debugPrint('Local asset audio failed: $e, falling back to online stream');
        await _audioPlayer.play(
          UrlSource(
            'https://ia801308.us.archive.org/28/items/Adhan_Ahlulbayt/Adhan.mp3',
          ),
        );
      }
    } catch (e) {
      debugPrint('Error playing Adhan audio: $e');
      isPlaying.value = false;
      currentPlayingVoiceId.value = '';
    }
  }

  /// Stop playing Adhan
  Future<void> stopAdhan() async {
    try {
      await _audioPlayer.stop();
      isPlaying.value = false;
      currentPlayingPrayer.value = '';
      currentPlayingVoiceId.value = '';
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  /// Set audio volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}
