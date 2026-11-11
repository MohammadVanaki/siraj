import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mawsueat/app/features/misbaha/model/bead_theme.dart';
import 'package:mawsueat/app/features/misbaha/model/dhikr_item.dart';

class MisbahaController extends GetxController {
  static MisbahaController get to => Get.find<MisbahaController>();

  final GetStorage _storage = GetStorage();

  // Round-robin pool of AudioPlayers to guarantee continuous, zero-latency clicks on rapid taps
  final List<AudioPlayer> _audioPlayers = [
    AudioPlayer(),
    AudioPlayer(),
    AudioPlayer(),
    AudioPlayer(),
  ];
  int _currentPlayerIndex = 0;

  final RxInt currentCount = 0.obs;
  final RxInt roundCount = 0.obs;
  final RxInt totalCount = 0.obs;

  final Rx<DhikrItem> selectedDhikr = DhikrItem.defaultList[0].obs;
  final Rx<BeadTheme> selectedTheme = BeadTheme.themes[0].obs;
  final RxBool isVibrationEnabled = true.obs;
  final RxBool isSoundEnabled = true.obs;

  // Custom target if user overrides it, 0 means open/unlimited
  final RxInt customTarget = 0.obs;

  // Notifier to trigger horizontal bead animation step
  final RxInt beadStepNotifier = 0.obs;

  int get effectiveTarget =>
      customTarget.value > 0 ? customTarget.value : selectedDhikr.value.target;

  String get currentZahraPhase {
    if (selectedDhikr.value.id != 'zahra') return '';
    final count = currentCount.value;
    if (count < 34) {
      return 'الله أكبر (${count + 1}/34)';
    } else if (count < 67) {
      return 'الحمد لله (${count - 33}/33)';
    } else if (count < 100) {
      return 'سبحان الله (${count - 66}/33)';
    }
    return 'اكتمل تسبيح الزهراء (ع)';
  }

  String get displayedDhikrText {
    if (selectedDhikr.value.id == 'zahra') {
      final count = currentCount.value;
      if (count < 34) return 'اللهُ أَكْبَرُ';
      if (count < 67) return 'الحَمْدُ لِلَّهِ';
      if (count < 100) return 'سُبْحَانَ اللهِ';
      return 'اللهُ أَكْبَرُ';
    }
    return selectedDhikr.value.title;
  }

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
    _initAudio();
  }

  void _initAudio() {
    final audioContext = AudioContext(
      android: const AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: false,
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.assistanceSonification,
        audioFocus: AndroidAudioFocus.none,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.ambient,
        options: const {},
      ),
    );

    for (final player in _audioPlayers) {
      try {
        player.setAudioContext(audioContext);
        player.setPlayerMode(PlayerMode.lowLatency);
        player.setVolume(1.0);
      } catch (_) {}
    }
  }

  void _loadPreferences() {
    isVibrationEnabled.value = _storage.read<bool>('misbaha_vibration') ?? true;
    isSoundEnabled.value = _storage.read<bool>('misbaha_sound') ?? true;
    totalCount.value = _storage.read<int>('misbaha_total_count') ?? 0;

    final themeId = _storage.read<String>('misbaha_theme_id');
    if (themeId != null) {
      final found = BeadTheme.themes.firstWhereOrNull((t) => t.id == themeId);
      if (found != null) {
        selectedTheme.value = found;
      }
    }
  }

  void _playClickSound() async {
    if (!isSoundEnabled.value) return;
    try {
      final player = _audioPlayers[_currentPlayerIndex];
      _currentPlayerIndex = (_currentPlayerIndex + 1) % _audioPlayers.length;

      // In lowLatency mode, player must be stopped to reset playback position for re-triggering
      await player.stop();
      await player.play(
        AssetSource('audio/click.mp3'),
        mode: PlayerMode.lowLatency,
        volume: 1.0,
      );
    } catch (e) {
      debugPrint('Misbaha click sound error: $e');
    }
  }

  void increment() {
    final target = effectiveTarget;

    // Trigger horizontal bead visual movement
    beadStepNotifier.value++;

    currentCount.value++;
    totalCount.value++;
    _storage.write('misbaha_total_count', totalCount.value);

    // Play click sound using AudioPlayer pool
    _playClickSound();

    // Haptic feedback
    if (isVibrationEnabled.value) {
      if (target > 0 && currentCount.value >= target) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.selectionClick();
      }
    }

    // Check target completion
    if (target > 0 && currentCount.value >= target) {
      roundCount.value++;
      currentCount.value = 0;
    }
  }

  void reset() {
    currentCount.value = 0;
    roundCount.value = 0;
    if (isVibrationEnabled.value) {
      HapticFeedback.mediumImpact();
    }
  }

  void selectDhikr(DhikrItem item) {
    selectedDhikr.value = item;
    customTarget.value = 0;
    currentCount.value = 0;
    roundCount.value = 0;
  }

  void selectTheme(BeadTheme theme) {
    selectedTheme.value = theme;
    _storage.write('misbaha_theme_id', theme.id);
    if (isVibrationEnabled.value) {
      HapticFeedback.selectionClick();
    }
  }

  void setCustomTarget(int target) {
    customTarget.value = target;
    currentCount.value = 0;
    roundCount.value = 0;
  }

  void toggleVibration() {
    isVibrationEnabled.value = !isVibrationEnabled.value;
    _storage.write('misbaha_vibration', isVibrationEnabled.value);
  }

  void toggleSound() {
    isSoundEnabled.value = !isSoundEnabled.value;
    _storage.write('misbaha_sound', isSoundEnabled.value);
  }

  @override
  void onClose() {
    for (final player in _audioPlayers) {
      player.dispose();
    }
    super.onClose();
  }
}
