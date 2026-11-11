import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:mawsueat/app/config/theme.dart';
import 'package:mawsueat/app/core/common/constants/constants.dart';
import 'package:mawsueat/app/core/init/init.dart';
import 'package:mawsueat/app/core/routes/routes.dart';
import 'package:mawsueat/app/features/setting/view/controller/settings_controller.dart';
import 'package:mawsueat/notif/firebase_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase.initializeApp error: $e');
  }

  await init();

  // Set system UI overlay style globally
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  if (Platform.isAndroid) {
    try {
      await checkGooglePlayServices().timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint(
        'Timeout: Google Play Services check took too long, skipping.',
      );
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SettingsController());
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
      locale: const Locale('ar'),
      title: Constants.appTitle,
      themeMode: ThemeMode.light,
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 280),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
            systemNavigationBarColor: theme.scaffoldBackgroundColor,
            systemNavigationBarDividerColor: Colors.transparent,
            systemNavigationBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
          ),
          child: MediaQuery(
            data: mediaQuery.copyWith(textScaler: const TextScaler.linear(1.0)),
            child: ColoredBox(
              color: theme.scaffoldBackgroundColor,
              child: SafeArea(
                top: false,
                bottom: true,
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
      initialRoute: Routes.splash,
      getPages: Routes.pages,
    );
  }
}

Future<void> checkGooglePlayServices() async {
  GooglePlayServicesAvailability availability = await GoogleApiAvailability
      .instance
      .checkGooglePlayServicesAvailability();

  if (availability != GooglePlayServicesAvailability.success) {
    debugPrint('Google Play Services not available: $availability');

    debugPrint(
      'Google Play Services is not available: ${availability.toString()}',
    );
  } else {
    debugPrint('Google Play Services is available.');

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp().timeout(const Duration(seconds: 5));
      }
    } catch (e) {
      debugPrint('Firebase init failed or timed out: $e');
    }

    FirebaseMessaging.onBackgroundMessage(handleFirebaseBackgroundMessage);

    await FirebaseNotificationService().initializeNotifications();
  }
}
