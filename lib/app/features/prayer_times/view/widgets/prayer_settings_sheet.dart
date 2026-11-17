import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../controller/prayer_times_controller.dart';
import '../../model/adhan_voice_model.dart';
import '../../model/prayer_city_model.dart';
import '../../model/prayer_settings_model.dart';
import '../../service/prayer_audio_service.dart';
import 'prayer_offset_sheet.dart';

class PrayerSettingsSheet extends StatelessWidget {
  const PrayerSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final controller = PrayerTimesController.to;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sheet Handle Bar
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withAlpha(100),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'إعدادات الأوقات والأذان',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        if (Get.isRegistered<PrayerAudioService>()) {
                          PrayerAudioService.to.stopAdhan();
                        }
                        Get.back();
                      },
                    ),
                  ],
                ),

                const Divider(height: 24),

                // Section 0: Location / City Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'المدينة والموقع',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => controller.useAutoLocation(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: Icon(
                        Icons.my_location_rounded,
                        size: 16,
                        color: colorScheme.onPrimary,
                      ),
                      label: Text(
                        'تحديد موقعي (GPS)',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                          fontFamily: 'IBMPlexSansArabic',
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Obx(() {
                  final currentSettings = controller.settings.value;
                  final currentCityName = controller.locationCityName.value;
                  final selectedPreset = currentSettings.isManualLocation
                      ? PrayerCityModel.presetCities
                          .where((c) => c.name == currentSettings.cityName)
                          .firstOrNull
                      : null;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withAlpha(10)
                          : Colors.grey.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withAlpha(20)
                            : Colors.grey.withAlpha(50),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedPreset?.name ?? '__auto__',
                        isExpanded: true,
                        dropdownColor:
                            isDark ? const Color(0xFF2C2C2C) : Colors.white,
                        items: [
                          DropdownMenuItem<String>(
                            value: '__auto__',
                            child: Text(
                              currentSettings.isManualLocation
                                  ? 'الموقع التلقائي (GPS)'
                                  : 'الموقع التلقائي: $currentCityName',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onSurface,
                                fontFamily: 'IBMPlexSansArabic',
                              ),
                            ),
                          ),
                          ...PrayerCityModel.presetCities.map((city) {
                            return DropdownMenuItem<String>(
                              value: city.name,
                              child: Text(
                                '${city.name} - ${city.country}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.onSurface,
                                  fontFamily: 'IBMPlexSansArabic',
                                ),
                              ),
                            );
                          }),
                        ],
                        onChanged: (selectedKey) {
                          if (selectedKey == null) return;
                          if (selectedKey == '__auto__') {
                            controller.useAutoLocation();
                          } else {
                            final city = PrayerCityModel.presetCities
                                .firstWhereOrNull((c) => c.name == selectedKey);
                            if (city != null) {
                              controller.setManualCity(city);
                            }
                          }
                        },
                      ),
                    ),
                  );
                }),

                const Gap(20),

                // Section 1: Calculation Method Selector
                Text(
                  'طريقة حساب المواقيت الفقهية',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                    fontFamily: 'IBMPlexSansArabic',
                  ),
                ),
                const Gap(8),
                Obx(() {
                  final currentMethod = controller.settings.value.methodType;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withAlpha(10)
                          : Colors.grey.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withAlpha(20)
                            : Colors.grey.withAlpha(50),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<PrayerCalculationMethodType>(
                        value: currentMethod,
                        isExpanded: true,
                        dropdownColor:
                            isDark ? const Color(0xFF2C2C2C) : Colors.white,
                        items: PrayerCalculationMethodType.values.map((method) {
                          return DropdownMenuItem<PrayerCalculationMethodType>(
                            value: method,
                            child: Text(
                              method.title,
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onSurface,
                                fontFamily: 'IBMPlexSansArabic',
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (newMethod) {
                          if (newMethod != null) {
                            controller.setCalculationMethod(newMethod);
                          }
                        },
                      ),
                    ),
                  );
                }),

                const Gap(20),

                // Section 2: Choose Muazzin / Adhan Voice
                Text(
                  'صوت المؤذن المعتمد',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                    fontFamily: 'IBMPlexSansArabic',
                  ),
                ),
                const Gap(4),
                Text(
                  'اختر صوت الأذان للتنبيهات؛ يمكنك الاستماع والتجربة قبل الاعتماد:',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withAlpha(160),
                    fontFamily: 'IBMPlexSansArabic',
                  ),
                ),
                const Gap(10),

                // List of available Adhan Voices
                Obx(() {
                  final selectedVoiceId =
                      controller.settings.value.adhanVoiceId;
                  final audioService = Get.isRegistered<PrayerAudioService>()
                      ? PrayerAudioService.to
                      : null;
                  final isAudioPlaying = audioService?.isPlaying.value ?? false;
                  final playingVoiceId =
                      audioService?.currentPlayingVoiceId.value ?? '';

                  return Column(
                    children: AdhanVoiceModel.availableVoices.map((voice) {
                      final isSelected = selectedVoiceId == voice.id;
                      final isThisPlaying =
                          isAudioPlaying && (playingVoiceId == voice.id);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.onPrimary.withAlpha(isDark ? 30 : 15)
                              : (isDark
                                  ? Colors.white.withAlpha(8)
                                  : Colors.grey.withAlpha(20)),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.onPrimary
                                : (isDark
                                    ? Colors.white.withAlpha(15)
                                    : Colors.grey.withAlpha(40)),
                            width: isSelected ? 1.8 : 1.0,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              controller.setAdhanVoice(voice.id);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  // Radio selection indicator
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color: isSelected
                                        ? colorScheme.onPrimary
                                        : Colors.grey,
                                    size: 22,
                                  ),
                                  const Gap(12),

                                  // Voice info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          voice.name,
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            color: colorScheme.onSurface,
                                            fontFamily: 'IBMPlexSansArabic',
                                          ),
                                        ),
                                        const Gap(2),
                                        Text(
                                          '${voice.desc} • ${voice.duration}',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: colorScheme.onSurface
                                                .withAlpha(150),
                                            fontFamily: 'IBMPlexSansArabic',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const Gap(8),

                                  // Preview / Play Button
                                  ZoomTapAnimation(
                                    onTap: () {
                                      if (audioService != null) {
                                        audioService.toggleVoicePreview(voice);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isThisPlaying
                                            ? Colors.red.withAlpha(25)
                                            : colorScheme.onPrimary
                                                .withAlpha(25),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isThisPlaying
                                              ? Colors.red
                                              : colorScheme.onPrimary
                                                  .withAlpha(100),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isThisPlaying
                                                ? Icons.stop_rounded
                                                : Icons.play_arrow_rounded,
                                            size: 18,
                                            color: isThisPlaying
                                                ? Colors.red
                                                : colorScheme.onPrimary,
                                          ),
                                          const Gap(4),
                                          Text(
                                            isThisPlaying ? 'إيقاف' : 'استماع',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                              color: isThisPlaying
                                                ? Colors.red
                                                : colorScheme.onPrimary,
                                              fontFamily: 'IBMPlexSansArabic',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),

                const Divider(height: 28),

                // Section 3: Notification Timing Offset (تقديم وتأخير التنبيه)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'توقيت التنبيهات والأذان',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                            fontFamily: 'IBMPlexSansArabic',
                          ),
                        ),
                        const Gap(2),
                        Text(
                          'تخصيص وقت التنبيه لكل صلاة (قبل أو بعد الأذان)',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontFamily: 'IBMPlexSansArabic',
                          ),
                        ),
                      ],
                    ),
                    Obx(() {
                      final hasAnyOffset = controller.settings.value.prayerOffsets.values
                          .any((v) => v != 0);
                      if (!hasAnyOffset) return const SizedBox.shrink();
                      return TextButton.icon(
                        onPressed: () => controller.resetAllPrayerOffsets(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 14, color: Colors.orange),
                        label: const Text(
                          'إعادة ضبط',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange,
                            fontFamily: 'IBMPlexSansArabic',
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const Gap(12),
                Obx(() {
                  final adhanPrayers = controller.todayPrayers.where((p) => p.isAdhan).toList();
                  if (adhanPrayers.isEmpty) return const SizedBox.shrink();

                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: adhanPrayers.map((prayer) {
                      final offset = prayer.notificationOffsetMinutes;
                      final hasOffset = offset != 0;
                      final badgeColor = hasOffset
                          ? (offset < 0 ? const Color(0xFFE65100) : const Color(0xFF00796B))
                          : Colors.grey.shade600;
                      final badgeBg = hasOffset
                          ? (offset < 0 ? const Color(0xFFFFF3E0) : const Color(0xFFE0F2F1))
                          : (isDark ? Colors.grey.shade800 : Colors.grey.shade100);

                      return ZoomTapAnimation(
                        onTap: () => PrayerOffsetSheet.show(context, prayer),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: hasOffset
                                  ? badgeColor.withAlpha(120)
                                  : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                prayer.arabicName,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                  fontFamily: 'IBMPlexSansArabic',
                                ),
                              ),
                              const Gap(6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  prayer.offsetDescription,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: badgeColor,
                                    fontFamily: 'IBMPlexSansArabic',
                                  ),
                                ),
                              ),
                              const Gap(4),
                              Icon(
                                Icons.tune_rounded,
                                size: 14,
                                color: colorScheme.onSurface.withAlpha(140),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),

                const Gap(14),

                // Full Adhan toggle
                Obx(() {
                  final isFullAdhan = controller.settings.value.playFullAdhan;
                  return SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'تشغيل الأذان كاملاً عند دخول الوقت',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                    value: isFullAdhan,
                    activeThumbColor: colorScheme.onPrimary,
                    onChanged: (val) {
                      controller.settings.value.playFullAdhan = val;
                      controller.settings.refresh();
                    },
                  );
                }),

                const Gap(20),

                // Close / Apply button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (Get.isRegistered<PrayerAudioService>()) {
                        PrayerAudioService.to.stopAdhan();
                      }
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.onPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'حفظ وإغلاق',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                  ),
                ),

                const Gap(10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
