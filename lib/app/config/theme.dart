import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/setting/view/controller/settings_controller.dart';

class MyThemes {
  static final SettingsController settingsController = Get.find();

  static ThemeData get lightTheme {
    final scheme = settingsController.selectedColorScheme.value;
    final font = settingsController.effectiveFontFamily;

    return ThemeData(
      brightness: Brightness.light,
      fontFamily: font,
      textTheme: ThemeData.light().textTheme.apply(
        fontFamily: font,
      ),
      useMaterial3: true,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.onPrimary.withAlpha(50),
      ),
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.onPrimary,
      ),
      colorScheme: ColorScheme(
        brightness: Brightness.light,
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
  }

  static ThemeData get darkTheme {
    const darkSurface = Color.fromARGB(255, 26, 23, 23);
    final font = settingsController.effectiveFontFamily;

    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: font,
      textTheme: ThemeData.dark().textTheme.apply(
        fontFamily: font,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: darkSurface,
      canvasColor: darkSurface,
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color.fromARGB(255, 172, 172, 172),
      ),
      dividerTheme:
          const DividerThemeData(color: Color.fromARGB(50, 210, 210, 210)),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 55, 55, 55),
          backgroundColor: const Color.fromARGB(255, 194, 194, 194),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color.fromARGB(255, 56, 56, 56),
        onPrimary: Color.fromARGB(255, 172, 172, 172),
        surface: darkSurface,
        onSurface: Colors.white,
        secondary: Colors.grey,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
      ),
    );
  }
}
