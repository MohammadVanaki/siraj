import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mawsueat/app/core/common/constants/constants.dart';
import '../data/data_sources/surah_constants.dart';
import '../data/models/ayah_model.dart';
import '../data/models/reciter_model.dart';
import '../data/models/surah_model.dart';
import '../data/models/tafsir_source.dart';
import '../data/repositories/quran_repository.dart';
import 'package:mawsueat/app/core/services/media_notification_service.dart';

enum QuranViewMode {
  cards, // آية بعد آية (بطاقات منفصلة)
  mushaf, // المصحف المتصل (قراءة مستمرة كصفحة المصحف)
}

class SurahDetailController extends GetxController {
  final SurahModel surah;
  final QuranRepository _repository;
  final int? initialAyahNumber;

  SurahDetailController({
    required this.surah,
    required TafsirSource initialTafsir,
    this.initialAyahNumber,
    QuranRepository? repository,
  }) : _repository =
           repository ??
           (Get.isRegistered<QuranRepository>()
               ? Get.find<QuranRepository>()
               : QuranRepository()),
       selectedTafsir = initialTafsir.obs {
    activePlayingSurah = surah.number.obs;
  }

  final Rx<TafsirSource> selectedTafsir;
  final RxList<TafsirSource> availableTafsirs = <TafsirSource>[].obs;
  final RxList<AyahModel> ayahs = <AyahModel>[].obs;

  // وضعیت و کش صفحات مصحف شریف (1 تا 604)
  PageController? mushafPageController;
  final RxInt currentMushafPage = 1.obs;
  final RxMap<int, List<AyahModel>> mushafPagesCache = <int, List<AyahModel>>{}.obs;
  final RxSet<int> loadingMushafPages = <int>{}.obs;
  final RxMap<int, String> mushafPageErrors = <int, String>{}.obs;
  late final RxInt activePlayingSurah;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // حالت نمایش (کارت‌های جدا یا مصحف پیوسته)
  final Rx<QuranViewMode> viewMode = QuranViewMode.cards.obs;

  // تنظیمات اندازه و نوع قلم
  final RxDouble quranFontSize = 23.0.obs;
  final RxDouble tafsirFontSize = 16.0.obs;
  final RxString quranFontFamily = 'uthman_taha'.obs;

  // آیه‌ای که در حال حاضر تفسیر آن باز است
  final Rxn<AyahModel> activeTafsirAyah = Rxn<AyahModel>();

  // سیستم پخش صوت قرآن
  final AudioPlayer _audioPlayer = AudioPlayer();
  final RxBool isAudioPlaying = false.obs;
  final RxBool isAudioLoading = false.obs;
  final Rx<Duration> audioDuration = Duration.zero.obs;
  final Rx<Duration> audioPosition = Duration.zero.obs;
  final RxList<ReciterModel> availableReciters = <ReciterModel>[].obs;
  final Rx<ReciterModel> selectedReciter =
      ReciterModel.defaultReciters.first.obs;
  final RxBool showAudioPlayer = false.obs;
  final RxnInt activePlayingAyah = RxnInt(); // null = تلاوت کامل سوره

  // حافظه کش آدرس‌های صوتی آیات
  final Map<String, String> _audioUrlCache = {};

  StreamSubscription? _playerStateSub;
  StreamSubscription? _playerCompleteSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _positionSub;
  DateTime? _lastAdvanceTime;
  int? _completedAyahNumber;
  bool _isAdvancing = false;

  void setViewMode(QuranViewMode mode) {
    viewMode.value = mode;
    Constants.localStorage.write('quranViewMode', mode.name);
    if (mode == QuranViewMode.mushaf) {
      final targetPage = activePlayingAyah.value != null
          ? (ayahs.firstWhereOrNull((a) => a.numberInSurah == activePlayingAyah.value)?.page ?? currentMushafPage.value)
          : currentMushafPage.value;
      jumpToMushafPage(targetPage);
    }
  }

  // کلیدهای هر آیه برای هایلایت و اسکرول خودکار
  final Map<int, GlobalKey> _ayahKeys = {};
  GlobalKey getAyahKey(int ayahNumber) {
    return _ayahKeys.putIfAbsent(ayahNumber, () => GlobalKey());
  }

  void scrollToAyah(int ayahNumber) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _ayahKeys[ayahNumber];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 400),
          alignment: 0.25,
          curve: Curves.easeInOut,
        );
      }
    });
  }

  final RxBool isConsecutivePlay = true.obs;

  @override
  void onInit() {
    super.onInit();
    final savedMode = Constants.localStorage.read('quranViewMode');
    if (savedMode == QuranViewMode.mushaf.name) {
      viewMode.value = QuranViewMode.mushaf;
    } else if (savedMode == QuranViewMode.cards.name) {
      viewMode.value = QuranViewMode.cards;
    }

    final savedFont = Constants.localStorage.read('quranFontFamily');
    if (savedFont != null &&
        savedFont is String &&
        savedFont.isNotEmpty &&
        savedFont != 'abo' &&
        savedFont != 'dijlah') {
      quranFontFamily.value = savedFont;
    } else {
      quranFontFamily.value = 'uthman_taha';
      Constants.localStorage.write('quranFontFamily', 'uthman_taha');
    }
    final savedSize = Constants.localStorage.read('quranFontSize');
    if (savedSize != null && savedSize is num) {
      quranFontSize.value = savedSize.toDouble();
    }

    final startPage = SurahConstants.getStartPage(surah.number);
    currentMushafPage.value = startPage;
    mushafPageController = PageController(initialPage: startPage - 1);
    loadMushafPage(startPage);
    _prefetchNearbyMushafPages(startPage);

    availableReciters.assignAll(ReciterModel.defaultReciters);
    availableTafsirs.assignAll(
        TafsirSource.defaultTafsirs.where((t) => t.isAvailable));
    _loadReciters();
    _loadTafsirs();
    _initAudioListeners();
    loadVerses();
  }

  Future<void> _loadReciters() async {
    try {
      final reciters = await _repository.getReciters();
      if (reciters.isNotEmpty) {
        availableReciters.assignAll(reciters);
        final match = availableReciters.firstWhereOrNull(
          (r) => r.id == selectedReciter.value.id,
        );
        if (match != null) {
          selectedReciter.value = match;
        } else {
          selectedReciter.value = availableReciters.first;
        }
      }
    } catch (e) {
      debugPrint('Error loading reciters: $e');
    }
  }

  Future<void> _loadTafsirs() async {
    try {
      final tafsirs = await _repository.getTafsirs();
      final available = tafsirs.where((t) => t.isAvailable).toList();
      if (available.isNotEmpty) {
        availableTafsirs.assignAll(available);
        final match = availableTafsirs.firstWhereOrNull(
          (t) => t.id == selectedTafsir.value.id,
        );
        if (match != null) {
          selectedTafsir.value = match;
        } else {
          selectedTafsir.value = availableTafsirs.first;
        }
      }
    } catch (e) {
      debugPrint('Error loading tafsirs: $e');
    }
  }

  static const String _kPlayerId = 'quran_player';

  @override
  void onClose() {
    _playerStateSub?.cancel();
    _playerCompleteSub?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    mushafPageController?.dispose();
    if (Get.isRegistered<MediaNotificationService>()) {
      MediaNotificationService.to.hideNotification(id: _kPlayerId);
    }
    super.onClose();
  }

  Future<void> loadMushafPage(int pageNumber) async {
    if (pageNumber < 1 || pageNumber > 604) return;
    if (mushafPagesCache.containsKey(pageNumber)) return;
    if (loadingMushafPages.contains(pageNumber)) return;

    try {
      loadingMushafPages.add(pageNumber);
      mushafPageErrors.remove(pageNumber);
      final verses = await _repository.getPageVerses(pageNumber);
      mushafPagesCache[pageNumber] = verses;
    } catch (e) {
      mushafPageErrors[pageNumber] = e.toString();
    } finally {
      loadingMushafPages.remove(pageNumber);
    }
  }

  void _prefetchNearbyMushafPages(int pageNumber) {
    if (pageNumber + 1 <= 604 && !mushafPagesCache.containsKey(pageNumber + 1)) {
      loadMushafPage(pageNumber + 1);
    }
    if (pageNumber - 1 >= 1 && !mushafPagesCache.containsKey(pageNumber - 1)) {
      loadMushafPage(pageNumber - 1);
    }
  }

  void jumpToMushafPage(int pageNumber) {
    if (pageNumber < 1 || pageNumber > 604) return;
    currentMushafPage.value = pageNumber;
    if (mushafPageController != null && mushafPageController!.hasClients) {
      final targetIndex = pageNumber - 1;
      if (mushafPageController!.page?.round() != targetIndex) {
        mushafPageController!.jumpToPage(targetIndex);
      }
    }
    loadMushafPage(pageNumber);
    _prefetchNearbyMushafPages(pageNumber);
  }

  void onMushafPageChanged(int index) {
    final pageNumber = index + 1;
    currentMushafPage.value = pageNumber;
    loadMushafPage(pageNumber);
    _prefetchNearbyMushafPages(pageNumber);
  }

  void _initAudioListeners() {
    _playerCompleteSub = _audioPlayer.onPlayerComplete.listen((_) {
      _handleTrackCompletion();
    });

    _playerStateSub = _audioPlayer.onPlayerStateChanged.listen((state) {
      isAudioPlaying.value = (state == PlayerState.playing);
      if (state == PlayerState.playing || state == PlayerState.paused || state == PlayerState.stopped) {
        isAudioLoading.value = false;
      }
      if (state == PlayerState.playing) {
        _updateMediaNotification(isPlaying: true);
      } else if (state == PlayerState.paused) {
        _updateMediaNotification(isPlaying: false);
      }
    }, onError: (e) {
      _showAudioUnavailableMessage();
    });

    _durationSub = _audioPlayer.onDurationChanged.listen((d) {
      audioDuration.value = d;
    });

    _positionSub = _audioPlayer.onPositionChanged.listen((p) {
      audioPosition.value = p;
    });
  }

  Future<void> _handleTrackCompletion() async {
    if (_isAdvancing) return;
    _isAdvancing = true;

    try {
      final currentNumber = activePlayingAyah.value;
      if (currentNumber == null) return;
      if (_completedAyahNumber == currentNumber) return;

      // دی‌بانس زمانی برای جلوگیری از فراخوانی تکراری
      final now = DateTime.now();
      if (_lastAdvanceTime != null &&
          now.difference(_lastAdvanceTime!) < const Duration(milliseconds: 1000)) {
        return;
      }
      _lastAdvanceTime = now;
      _completedAyahNumber = currentNumber;

      audioPosition.value = Duration.zero;
      isAudioPlaying.value = false;
      isAudioLoading.value = false;

      // پخش آیه بعدی در صورت فعال بودن پخش متوالی
      if (isConsecutivePlay.value) {
        final currentIndex = ayahs.indexWhere(
          (a) => a.numberInSurah == currentNumber && a.surahNumber == activePlayingSurah.value,
        );
        if (currentIndex != -1 && currentIndex + 1 < ayahs.length) {
          final nextAyah = ayahs[currentIndex + 1];
          await playAyah(nextAyah, isConsecutive: true);
          return;
        } else if (viewMode.value == QuranViewMode.mushaf) {
          final pageVerses = mushafPagesCache[currentMushafPage.value];
          if (pageVerses != null && pageVerses.isNotEmpty) {
            final pageIndex = pageVerses.indexWhere(
              (a) => a.numberInSurah == currentNumber && a.surahNumber == activePlayingSurah.value,
            );
            if (pageIndex != -1 && pageIndex + 1 < pageVerses.length) {
              final nextAyah = pageVerses[pageIndex + 1];
              await playAyah(nextAyah, isConsecutive: true);
              return;
            }
          }
        }
      }

      // در صورتی که به انتهای سوره رسیدیم
      activePlayingAyah.value = null;
      if (Get.isRegistered<MediaNotificationService>()) {
        MediaNotificationService.to.hideNotification(id: _kPlayerId);
      }
    } finally {
      // تاخیر کوتاه برای گذر از تمامی ایونت‌های احتمالی هنگام تعویض سورس صدا
      await Future.delayed(const Duration(milliseconds: 500));
      _isAdvancing = false;
    }
  }

  void _showAudioUnavailableMessage() {
    isAudioLoading.value = false;
    isAudioPlaying.value = false;
    isConsecutivePlay.value = false;

    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.snackbar(
      'التلاوة الصوتية',
      'التسجيلات الصوتية غير متاحة حالياً على الخادم، وستكون متوفرة قريباً إن شاء الله.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 24),
    );
  }

  void _updateMediaNotification({required bool isPlaying}) {
    if (Get.isRegistered<MediaNotificationService>()) {
      final ayahText = activePlayingAyah.value != null ? ' (آية ${activePlayingAyah.value})' : '';
      MediaNotificationService.to.showMediaNotification(
        MediaNotificationItem(
          id: _kPlayerId,
          title: 'سورة ${surah.name}$ayahText',
          subtitle: selectedReciter.value.name,
          isPlaying: isPlaying,
          position: audioPosition.value,
          duration: audioDuration.value,
          onPlay: togglePlaySurah,
          onPause: togglePlaySurah,
          onSeek: seekAudio,
          onNext: playNextAyah,
          onPrevious: playPreviousAyah,
          onStop: closeAudioPlayer,
        ),
      );
    }
  }

  void playNextAyah() {
    if (activePlayingAyah.value != null && ayahs.isNotEmpty) {
      final currentIndex = ayahs.indexWhere((a) => a.numberInSurah == activePlayingAyah.value);
      if (currentIndex != -1 && currentIndex + 1 < ayahs.length) {
        playAyah(ayahs[currentIndex + 1], isConsecutive: isConsecutivePlay.value);
      }
    } else if (ayahs.isNotEmpty) {
      playAyah(ayahs.first, isConsecutive: isConsecutivePlay.value);
    }
  }

  void playPreviousAyah() {
    if (activePlayingAyah.value != null && ayahs.isNotEmpty) {
      final currentIndex = ayahs.indexWhere((a) => a.numberInSurah == activePlayingAyah.value);
      if (currentIndex > 0) {
        playAyah(ayahs[currentIndex - 1], isConsecutive: isConsecutivePlay.value);
      }
    }
  }

  Future<void> togglePlaySurah() async {
    showAudioPlayer.value = true;

    if (isAudioPlaying.value) {
      await _audioPlayer.pause();
    } else {
      if (activePlayingAyah.value != null &&
          audioPosition.value > Duration.zero) {
        await _audioPlayer.resume();
      } else {
        if (ayahs.isNotEmpty) {
          final targetAyah = activePlayingAyah.value != null
              ? (ayahs.firstWhereOrNull(
                      (a) => a.numberInSurah == activePlayingAyah.value,
                    ) ??
                    ayahs.first)
              : ayahs.first;
          await playAyah(targetAyah, isConsecutive: true);
        }
      }
    }
  }

  void _prefetchNextAyahAudio(int currentAyahNumber, {int? surahNumber}) {
    final sNum = surahNumber ?? surah.number;
    final nextAyah = ayahs.firstWhereOrNull((a) => a.numberInSurah == currentAyahNumber + 1 && a.surahNumber == sNum);
    final targetAyahNumber = nextAyah?.numberInSurah ?? (currentAyahNumber + 1);
    final targetSurahNumber = nextAyah?.surahNumber ?? sNum;

    final cacheKey = '${targetSurahNumber}_${targetAyahNumber}_${selectedReciter.value.id}';
    if (!_audioUrlCache.containsKey(cacheKey)) {
      _repository.getAyahAudioUrl(
        surahNumber: targetSurahNumber,
        ayahNumber: targetAyahNumber,
        reciterId: selectedReciter.value.id,
      ).then((url) {
        if (url != null && url.isNotEmpty) {
          _audioUrlCache[cacheKey] = url;
        }
      }).catchError((_) {});
    }
  }

  Future<void> playAyah(AyahModel ayah, {bool isConsecutive = true}) async {
    showAudioPlayer.value = true;
    activePlayingSurah.value = ayah.surahNumber;
    activePlayingAyah.value = ayah.numberInSurah;
    isConsecutivePlay.value = isConsecutive;
    isAudioLoading.value = true;
    _completedAyahNumber = null;
    audioPosition.value = Duration.zero;
    audioDuration.value = Duration.zero;

    if (viewMode.value == QuranViewMode.mushaf) {
      if (ayah.page != null && ayah.page != currentMushafPage.value) {
        jumpToMushafPage(ayah.page!);
      }
    } else {
      scrollToAyah(ayah.numberInSurah);
    }

    try {
      final targetSurahNumber = ayah.surahNumber;
      final targetAyahNumber = ayah.numberInSurah;
      final cacheKey = '${targetSurahNumber}_${targetAyahNumber}_${selectedReciter.value.id}';
      String? audioUrl = _audioUrlCache[cacheKey];

      if (audioUrl == null || audioUrl.isEmpty) {
        audioUrl = await _repository.getAyahAudioUrl(
          surahNumber: targetSurahNumber,
          ayahNumber: targetAyahNumber,
          reciterId: selectedReciter.value.id,
        );
        if (audioUrl != null && audioUrl.isNotEmpty) {
          _audioUrlCache[cacheKey] = audioUrl;
        }
      }

      // فال‌بک مستقیم بر اساس شناسه قاری
      audioUrl ??= selectedReciter.value.getFallbackAudioUrl(
        surahNumber: targetSurahNumber,
        ayahNumber: targetAyahNumber,
      );

      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(audioUrl));

      // پیش‌دریافت آدرس صوت آیه بعدی جهت پخش پیوسته و بدون مکث
      if (isConsecutive) {
        _prefetchNextAyahAudio(targetAyahNumber, surahNumber: targetSurahNumber);
      }
    } catch (e) {
      debugPrint('Error playing ayah audio: $e');
      _showAudioUnavailableMessage();
    }
  }

  Future<void> resumeAudio() async {
    if (activePlayingAyah.value != null && audioPosition.value > Duration.zero) {
      await _audioPlayer.resume();
      isAudioPlaying.value = true;
    } else {
      await togglePlaySurah();
    }
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> seekAudio(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> changeReciter(ReciterModel reciter) async {
    if (selectedReciter.value.id == reciter.id) return;
    selectedReciter.value = reciter;

    if (isAudioPlaying.value && activePlayingAyah.value != null) {
      final currentAyah = ayahs.firstWhereOrNull(
        (a) => a.numberInSurah == activePlayingAyah.value,
      );
      if (currentAyah != null) {
        await playAyah(currentAyah, isConsecutive: isConsecutivePlay.value);
      }
    }
  }

  void closeAudioPlayer() {
    _audioPlayer.stop();
    showAudioPlayer.value = false;
    isAudioPlaying.value = false;
    activePlayingAyah.value = null;
    if (Get.isRegistered<MediaNotificationService>()) {
      MediaNotificationService.to.hideNotification(id: _kPlayerId);
    }
  }

  Future<void> loadVerses() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final list = await _repository.getSurahVerses(
        surah.number,
        selectedTafsir.value,
      );
      ayahs.assignAll(list);

      // به‌روزرسانی صفحه مصحف در صورت وجود آیه اولیه یا بارگذاری اولیه
      if (ayahs.isNotEmpty && ayahs.first.page != null) {
        final startPage = ayahs.first.page!;
        if (currentMushafPage.value != startPage && activePlayingAyah.value == null && initialAyahNumber == null) {
          jumpToMushafPage(startPage);
        }
      }

      if (initialAyahNumber != null) {
        scrollToAyah(initialAyahNumber!);
        final initialAyah = ayahs.firstWhereOrNull((a) => a.numberInSurah == initialAyahNumber);
        if (initialAyah?.page != null) {
          jumpToMushafPage(initialAyah!.page!);
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeTafsir(TafsirSource newTafsir) async {
    if (selectedTafsir.value.id == newTafsir.id) return;
    selectedTafsir.value = newTafsir;
  }

  Future<String?> getAyahTafsir(int ayahNumber) {
    return _repository.getAyahTafsir(
      surahNumber: surah.number,
      ayahNumber: ayahNumber,
      tafsirId: selectedTafsir.value.apiIdentifier ?? selectedTafsir.value.id,
    );
  }

  void openTafsir(AyahModel ayah) {
    activeTafsirAyah.value = ayah;
  }

  void setQuranFontFamily(String family) {
    quranFontFamily.value = family;
    Constants.localStorage.write('quranFontFamily', family);
  }

  void setQuranFontSize(double size) {
    quranFontSize.value = size;
    Constants.localStorage.write('quranFontSize', size);
  }

  void increaseQuranFontSize() {
    if (quranFontSize.value < 36.0) {
      quranFontSize.value += 2.0;
      Constants.localStorage.write('quranFontSize', quranFontSize.value);
    }
  }

  void decreaseQuranFontSize() {
    if (quranFontSize.value > 18.0) {
      quranFontSize.value -= 2.0;
      Constants.localStorage.write('quranFontSize', quranFontSize.value);
    }
  }

  void copyAyah(AyahModel ayah) {
    final text =
        '﴿ ${ayah.text} ﴾\n[سورة ${surah.name} - الآية ${ayah.numberInSurah}]';
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'تم النسخ',
      'تم نسخ الآية الكريمة إلى الحافظة',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void shareAyah(AyahModel ayah) {
    final text =
        '﴿ ${ayah.text} ﴾\n[سورة ${surah.name} - الآية ${ayah.numberInSurah}]\n\nعبر تطبيق السراج';
    Share.share(text);
  }
}
