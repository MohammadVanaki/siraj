import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/quran/controller/surah_detail_controller.dart';
import 'package:mawsueat/app/features/quran/data/data_sources/surah_constants.dart';
import 'package:mawsueat/app/features/quran/data/models/ayah_model.dart';
import 'package:mawsueat/app/features/quran/data/models/tafsir_source.dart';
import 'package:mawsueat/app/features/quran/data/repositories/quran_repository.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'tafsir_selector_sheet.dart';

class TafsirBottomSheet extends StatefulWidget {
  final AyahModel ayah;
  final SurahDetailController? controller;
  final TafsirSource? initialTafsir;

  const TafsirBottomSheet({
    super.key,
    required this.ayah,
    this.controller,
    this.initialTafsir,
  });

  static void show(
    BuildContext context, {
    required AyahModel ayah,
    SurahDetailController? controller,
    TafsirSource? initialTafsir,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TafsirBottomSheet(
        ayah: ayah,
        controller: controller,
        initialTafsir: initialTafsir,
      ),
    );
  }

  @override
  State<TafsirBottomSheet> createState() => _TafsirBottomSheetState();
}

class _TafsirBottomSheetState extends State<TafsirBottomSheet> {
  late final QuranRepository _repository;
  late TafsirSource _selectedTafsir;
  List<TafsirSource> _availableTafsirs = TafsirSource.defaultTafsirs;

  String? _tafsirText;
  bool _isLoading = true;
  String? _errorMessage;
  late double _fontSize;

  @override
  void initState() {
    super.initState();
    _repository = Get.isRegistered<QuranRepository>()
        ? Get.find<QuranRepository>()
        : QuranRepository();

    _selectedTafsir = widget.controller?.selectedTafsir.value ??
        widget.initialTafsir ??
        TafsirSource.defaultTafsirs.first;

    _fontSize = widget.controller?.tafsirFontSize.value ?? 16.0;

    if (widget.controller != null &&
        widget.controller!.availableTafsirs.isNotEmpty) {
      _availableTafsirs = widget.controller!.availableTafsirs;
    }

    _loadAvailableTafsirs();
    _fetchTafsir();
  }

  Future<void> _loadAvailableTafsirs() async {
    try {
      final list = await _repository.getTafsirs();
      final available = list.where((t) => t.isAvailable).toList();
      if (available.isNotEmpty && mounted) {
        setState(() {
          _availableTafsirs = available;
          final match =
              available.firstWhereOrNull((t) => t.id == _selectedTafsir.id);
          if (match != null) {
            _selectedTafsir = match;
          } else {
            _selectedTafsir = available.first;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchTafsir() async {
    if (!_selectedTafsir.isAvailable) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _tafsirText = null;
          _errorMessage =
              'هذا التفسير غير متوفر حالياً على الخادم وسيتم إتاحته قريباً إن شاء الله.';
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final text = await _repository.getAyahTafsir(
        surahNumber: widget.ayah.surahNumber,
        ayahNumber: widget.ayah.numberInSurah,
        tafsirId: _selectedTafsir.apiIdentifier ?? _selectedTafsir.id,
      );

      if (!mounted) return;

      if (text != null && text.trim().isNotEmpty) {
        setState(() {
          _tafsirText = text;
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _tafsirText = null;
          _isLoading = false;
          _errorMessage = 'لم يتوفر نص التفسير لهذه الآية المباركة حالياً.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _tafsirText = null;
        _isLoading = false;
        _errorMessage =
            'تعذر الاتصال بالخادم لجلب التفسير. يرجى التحقق من الاتصال بالإنترنت.';
      });
    }
  }

  void _onSelectTafsir(TafsirSource newTafsir) {
    if (_selectedTafsir.id == newTafsir.id) return;
    setState(() {
      _selectedTafsir = newTafsir;
    });
    widget.controller?.changeTafsir(newTafsir);
    _fetchTafsir();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final surah = widget.controller?.surah ??
        SurahConstants.getByNumber(widget.ayah.surahNumber);
    final surahName = surah?.name ?? 'سورة';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 20,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تفسير الآية (${widget.ayah.numberInSurah})',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBMPlexSansArabic',
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'سورة $surahName',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontFamily: 'IBMPlexSansArabic',
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Change tafsir button
                  ZoomTapAnimation(
                    onTap: () {
                      TafsirSelectorSheet.show(
                        context,
                        tafsirs: _availableTafsirs,
                        currentTafsir: _selectedTafsir,
                        onSelect: _onSelectTafsir,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.onPrimary.withAlpha(50),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 130),
                            child: Text(
                              _selectedTafsir.name,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'IBMPlexSansArabic',
                                color: colorScheme.onPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const Gap(4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: colorScheme.onPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 0.5),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Verse card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withAlpha(12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.onPrimary.withAlpha(30),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '﴿ ${widget.ayah.displayArabicText} ﴾',
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              height: 2.1,
                              fontFamily: 'IBMPlexSansArabic',
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const Gap(10),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.onPrimary.withAlpha(25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '[سورة $surahName - آية ${widget.ayah.numberInSurah}]',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'IBMPlexSansArabic',
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Gap(20),

                    // Tafsir Header & Actions
                    Row(
                      children: [
                        Icon(
                          Icons.format_quote_rounded,
                          size: 18,
                          color: colorScheme.onPrimary,
                        ),
                        const Gap(6),
                        Text(
                          'التفسير',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBMPlexSansArabic',
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),

                        // Font size decrease
                        ZoomTapAnimation(
                          onTap: () {
                            if (_fontSize > 13.0) {
                              setState(() => _fontSize -= 1.5);
                              if (widget.controller != null) {
                                widget.controller!.tafsirFontSize.value =
                                    _fontSize;
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withAlpha(10)
                                  : Colors.black.withAlpha(8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'A-',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                        ),

                        // Font size increase
                        ZoomTapAnimation(
                          onTap: () {
                            if (_fontSize < 28.0) {
                              setState(() => _fontSize += 1.5);
                              if (widget.controller != null) {
                                widget.controller!.tafsirFontSize.value =
                                    _fontSize;
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withAlpha(10)
                                  : Colors.black.withAlpha(8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'A+',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                        ),

                        const Gap(6),

                        // Copy button
                        ZoomTapAnimation(
                          onTap: () {
                            final tafsirName = _selectedTafsir.name;
                            final textToCopy =
                                '﴿ ${widget.ayah.displayArabicText} ﴾\n\n$tafsirName:\n${_tafsirText ?? "لا يوجد نص للتفسير"}\n\n[سورة $surahName - آية ${widget.ayah.numberInSurah}]';
                            Clipboard.setData(ClipboardData(text: textToCopy));
                            Get.snackbar(
                              'تم النسخ',
                              'تم نسخ نص التفسير إلى الحافظة',
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 2),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.copy_rounded,
                              size: 18,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[700],
                            ),
                          ),
                        ),
                        const Gap(4),

                        // Share button
                        ZoomTapAnimation(
                          onTap: () {
                            final tafsirName = _selectedTafsir.name;
                            final textToShare =
                                '﴿ ${widget.ayah.displayArabicText} ﴾\n\n$tafsirName:\n${_tafsirText ?? ""}\n\n[سورة $surahName - آية ${widget.ayah.numberInSurah}]\nعبر تطبيق السراج';
                            Share.share(textToShare);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.share_rounded,
                              size: 18,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Gap(12),

                    // Tafsir Content State
                    if (_isLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 26,
                                height: 26,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  strokeCap: StrokeCap.round,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              const Gap(12),
                              Text(
                                'جاري جلب نص التفسير...',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'IBMPlexSansArabic',
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withAlpha(6)
                              : Colors.grey.withAlpha(15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.amber.withAlpha(50),
                            width: 0.8,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              !_selectedTafsir.isAvailable
                                  ? Icons.access_time_rounded
                                  : Icons.info_outline_rounded,
                              color: Colors.amber,
                              size: 32,
                            ),
                            const Gap(10),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.6,
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                                fontFamily: 'IBMPlexSansArabic',
                              ),
                            ),
                            const Gap(14),
                            if (!_selectedTafsir.isAvailable)
                              ZoomTapAnimation(
                                onTap: () {
                                  final availableOne = _availableTafsirs
                                          .firstWhereOrNull((t) => t.isAvailable) ??
                                      TafsirSource.defaultTafsirs.first;
                                  _onSelectTafsir(availableOne);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.onPrimary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      Gap(6),
                                      Text(
                                        'الانتقال إلى تفسير الجلالين',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'IBMPlexSansArabic',
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ZoomTapAnimation(
                                onTap: _fetchTafsir,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.onPrimary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.refresh_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      Gap(6),
                                      Text(
                                        'إعادة المحاولة',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'IBMPlexSansArabic',
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withAlpha(8)
                              : Colors.black.withAlpha(4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _tafsirText!,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: _fontSize,
                            height: 1.85,
                            color: isDark ? Colors.grey[200] : Colors.grey[900],
                            fontFamily: 'IBMPlexSansArabic',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
