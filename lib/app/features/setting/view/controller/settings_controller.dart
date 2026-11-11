import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/constants/constants.dart';

class SettingsController extends GetxController {
  static SettingsController get instance => Get.find<SettingsController>();
  var selectedTheme = const Color(0xFF4B6969).obs;
  var fontSize = 16.0.obs;
  var lineHeight = 1.8.obs;
  var fontFamily = 'IBMPlexSansArabic'.obs;
  var verticalScroll = true.obs;
  var isApplying = false.obs;
  var isDarkMode = false.obs;
  var themeIndex = 1.obs;
  var isNotificationsEnabled = true.obs;

  /// لیست فونت‌های برتر و پرطرفدار عربی و اسلامی
  final List<AppFontOption> availableFonts = const [
    AppFontOption(
      id: 'IBMPlexSansArabic',
      name: 'خط آی‌بی‌ام پلکس (IBM Plex Sans)',
      subtitle: 'الخط الرسمي الأساسي للتطبيق بتصميم عصري وأنيق ومريح للعين',
      fontFamily: 'IBMPlexSansArabic',
      sample: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    ),
    AppFontOption(
      id: 'uthman_taha',
      name: 'خط عثمان طه',
      subtitle: 'الخط القرآني الأصيل لمصحف المدينة المنورة',
      fontFamily: 'uthman_taha',
      sample: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    ),
    AppFontOption(
      id: 'dijlah',
      name: 'خط دجلة',
      subtitle: 'نسخ إسلامي كلاسيكي ممتاز للقرآن والكتب والزيارات',
      fontFamily: 'dijlah',
      sample: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    ),
    AppFontOption(
      id: 'aljazeera',
      name: 'خط الجزيرة',
      subtitle: 'خط عربي حديث وسلس ومريح جداً للمطالعة الطويلة',
      fontFamily: 'aljazeera',
      sample: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    ),
    AppFontOption(
      id: 'SegoeUI',
      name: 'خط سگو (Segoe UI)',
      subtitle: 'خط عصري واضح ومخصص للشاشات الرقمية',
      fontFamily: 'SegoeUI',
      sample: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    ),
  ];

  /// بازگرداندن نام معتبر فونت بر اساس مقدار ذخیره شده
  String get effectiveFontFamily {
    final val = fontFamily.value.trim();
    if (val == 'IBMPlexSansArabic' || val == 'IBM Plex Sans Arabic' || val == 'آی‌بی‌ام پلکس') return 'IBMPlexSansArabic';
    if (val == 'uthman_taha' || val == 'عثمان طه') return 'uthman_taha';
    if (val == 'aljazeera' || val == 'الجزيرة') return 'aljazeera';
    if (val == 'SegoeUI' || val == 'سگو') return 'SegoeUI';
    if (val == 'dijlah' || val == 'دجلة') return 'dijlah';
    return 'IBMPlexSansArabic';
  }

  var backgroundColor = Colors.white.obs;
  var selectedColorScheme = ThemeColorScheme(
    primary: Color.fromARGB(255, 175, 236, 250),
    onPrimary: Color.fromARGB(255, 17, 171, 205),
    surface: Color.fromARGB(255, 248, 252, 254),
    index: 1,
  ).obs;
  var showAllPages = true.obs;
  final ThemeColorScheme darkColorScheme = ThemeColorScheme(
    primary: Color(0xFF383838),
    onPrimary: Color(0xFFACACAC),
    surface: Color(0xFF1A1717),
    index: 10,
  );

  final List<ThemeColorScheme> themeColorSchemes = [
    ThemeColorScheme(
      primary: const Color(0xFF0F5A47),
      onPrimary: const Color(0xFF1E8267),
      surface: const Color.fromARGB(255, 250, 252, 249),
      index: 0,
    ),
    ThemeColorScheme(
      primary: Color.fromARGB(255, 175, 236, 250),
      onPrimary: Color.fromARGB(255, 17, 171, 205),
      surface: Color.fromARGB(255, 248, 252, 254),
      index: 1,
    ),
    ThemeColorScheme(
      primary: Color.fromARGB(255, 169, 144, 100),
      onPrimary: Color.fromARGB(255, 103, 75, 25),
      surface: Color.fromARGB(255, 255, 253, 250),
      index: 2,
    ),
    ThemeColorScheme(
      primary: Color.fromARGB(255, 141, 148, 176),
      onPrimary: Color.fromARGB(255, 76, 82, 104),
      surface: Color.fromARGB(255, 249, 250, 253),
      index: 3,
    ),
    ThemeColorScheme(
      primary: Color.fromARGB(255, 45, 105, 151),
      onPrimary: Color.fromARGB(255, 0, 57, 102),
      surface: Color.fromARGB(255, 248, 251, 254),
      index: 4,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    isNotificationsEnabled.value =
        Constants.localStorage.read('notifications_enabled') ?? true;
    isDarkMode.value = Constants.localStorage.read('isDarkMode') ?? false;
    themeIndex.value = Constants.localStorage.read('themeIndex') ?? 1;

    final savedFont = Constants.localStorage.read('fontFamily');
    if (savedFont != null && savedFont.toString().isNotEmpty) {
      final s = savedFont.toString().trim();
      if (s == 'IBMPlexSansArabic' || s == 'IBM Plex Sans Arabic') {
        fontFamily.value = 'IBMPlexSansArabic';
      } else if (s == 'aljazeera' || s == 'الجزيرة') {
        fontFamily.value = 'aljazeera';
      } else if (s == 'SegoeUI' || s == 'سگو') {
        fontFamily.value = 'SegoeUI';
      } else if (s == 'dijlah' || s == 'دجلة') {
        fontFamily.value = 'dijlah';
      } else if (s == 'uthman_taha' || s == 'عثمان طه') {
        fontFamily.value = 'uthman_taha';
      } else {
        fontFamily.value = 'IBMPlexSansArabic';
        Constants.localStorage.write('fontFamily', 'IBMPlexSansArabic');
      }
    } else {
      fontFamily.value = 'IBMPlexSansArabic';
      Constants.localStorage.write('fontFamily', 'IBMPlexSansArabic');
    }

    fontSize.value = Constants.localStorage.read('fontSize') ?? 16.0;
    lineHeight.value = Constants.localStorage.read('lineHeight') ?? 1.8;
    verticalScroll.value =
        Constants.localStorage.read('verticalScroll') ?? true;

    final int? colorValue = Constants.localStorage.read('backgroundColor');
    if (colorValue != null) {
      backgroundColor.value = Color(colorValue);
    }

    if (isDarkMode.value) {
      selectedColorScheme.value = darkColorScheme;
    } else {
      final primary = Constants.localStorage.read('theme_primary');
      final onPrimary = Constants.localStorage.read('theme_onPrimary');
      final surface = Constants.localStorage.read('theme_surface');

      if (primary != null && onPrimary != null && surface != null) {
        selectedColorScheme.value = ThemeColorScheme(
          primary: Color(primary),
          onPrimary: Color(onPrimary),
          surface: Color(surface),
          index: themeIndex.value,
        );
      }
    }

    setTheme(
      selectedColorScheme.value,
      isDarkMode: isDarkMode.value,
      themeindex: themeIndex.value,
      isInitial: true,
    );
  }

  void setTheme(
    ThemeColorScheme scheme, {
    bool isDarkMode = false,
    required int themeindex,
    bool isInitial = false,
  }) {
    // اگر تم انتخابی هم‌اکنون فعال است، برای جلوگیری از لگ مجدد اجرا نشود
    if (!isInitial &&
        selectedColorScheme.value.index == themeindex &&
        this.isDarkMode.value == isDarkMode) {
      return;
    }

    final bool modeChanged = this.isDarkMode.value != isDarkMode;
    this.isDarkMode.value = isDarkMode;
    themeIndex.value = themeindex;
    selectedColorScheme.value = scheme;

    // ذخیره در پس‌زمینه بدون بلاک کردن فریم رندر دکمه
    Future.microtask(() {
      if (!isDarkMode) {
        Constants.localStorage.write('theme_primary', scheme.primary.value);
        Constants.localStorage.write('theme_onPrimary', scheme.onPrimary.value);
        Constants.localStorage.write('theme_surface', scheme.surface.value);
      }
      Constants.localStorage.write('themeIndex', themeindex);
      Constants.localStorage.write('isDarkMode', isDarkMode);
    });

    // ساخت بهینه ThemeData هماهنگ با تم
    final ThemeData newTheme = ThemeData(
      dividerTheme: DividerThemeData(color: scheme.onPrimary.withAlpha(50)),
      elevatedButtonTheme: isDarkMode
          ? darkElevatedButtonTheme()
          : lightElevatedButtonTheme(scheme),
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      fontFamily: effectiveFontFamily,
      useMaterial3: true,
      scaffoldBackgroundColor: isDarkMode
          ? const Color.fromARGB(255, 26, 23, 23)
          : scheme.surface,
      canvasColor: isDarkMode
          ? const Color.fromARGB(255, 26, 23, 23)
          : scheme.surface,
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: isDarkMode
            ? const Color.fromARGB(255, 172, 172, 172)
            : scheme.onPrimary,
      ),
      colorScheme: isDarkMode
          ? ColorScheme.dark(
              primary: const Color.fromARGB(255, 56, 56, 56),
              onPrimary: const Color.fromARGB(255, 172, 172, 172),
              surface: const Color.fromARGB(255, 26, 23, 23),
              onSurface: Colors.white,
              secondary: Colors.grey,
              onSecondary: Colors.white,
              error: Colors.red,
              onError: Colors.white,
            )
          : ColorScheme.light(
              primary: Colors.white,
              onPrimary: scheme.onPrimary,
              surface: scheme.surface,
              onSurface: Colors.black,
              secondary: Colors.grey,
              onSecondary: Colors.black,
              error: Colors.red,
              onError: Colors.white,
            ),
    );

    if (isInitial) {
      Get.changeTheme(newTheme);
      Get.changeThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);
    } else {
      // موکول کردن تغییر تم سراسری به فریم بعد جهت اجرای روان انیمیشن لمس دکمه
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.changeTheme(newTheme);
        if (modeChanged) {
          Get.changeThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);
        }
      });
    }
  }

  // Light theme for ElevatedButton
  ElevatedButtonThemeData lightElevatedButtonTheme(ThemeColorScheme scheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
  }

  // Dark theme for ElevatedButton
  ElevatedButtonThemeData darkElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: const Color.fromARGB(255, 172, 172, 172),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
  }

  void setFontSize(double size) {
    fontSize.value = size;
    Constants.localStorage.write('fontSize', size);
  }

  void setLineHeight(double height) {
    lineHeight.value = height;
    Constants.localStorage.write('lineHeight', height);
  }

  void setFontFamily(String family) {
    fontFamily.value = family;
    Constants.localStorage.write('fontFamily', family);
    // اعمال سریع و بلافاصله فونت بر روی تم سراسری برنامه
    setTheme(
      selectedColorScheme.value,
      isDarkMode: isDarkMode.value,
      themeindex: themeIndex.value,
    );
  }

  void setBackgroundColor(Color color) {
    backgroundColor.value = color;
    Constants.localStorage.write('backgroundColor', color.value);
  }

  void setVerticalScroll(bool isVertical) {
    verticalScroll.value = isVertical;
    Constants.localStorage.write('verticalScroll', isVertical);
  }

  Future<void> toggleNotifications(bool value) async {
    isNotificationsEnabled.value = value;
    Constants.localStorage.write('notifications_enabled', value);
    try {
      if (value) {
        await FirebaseMessaging.instance.subscribeToTopic("alhabwah_android");
      } else {
        await FirebaseMessaging.instance.unsubscribeFromTopic("alhabwah_android");
      }
    } catch (e) {
      debugPrint("Error toggling notifications: $e");
    }
  }
}

class AppFontOption {
  final String id;
  final String name;
  final String subtitle;
  final String fontFamily;
  final String sample;

  const AppFontOption({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.fontFamily,
    required this.sample,
  });
}

class ThemeColorScheme {
  final Color primary;
  final Color onPrimary;
  final Color surface;
  final int index;

  ThemeColorScheme({
    required this.primary,
    required this.onPrimary,
    required this.surface,
    required this.index,
  });
}
