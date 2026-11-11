import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/widgets/custom_loading.dart';
import 'package:mawsueat/app/features/home/view/controller/content_controller.dart';
import 'package:mawsueat/app/features/home/view/screens/home_dashboard_page.dart';

// splash_page.dart
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _controllerInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      print('🚀 Starting app initialization...');

      // 2. Initialize ContentController
      await _initializeContentController();

      // 3. Minimum splash time
      await Future.delayed(const Duration(seconds: 2));

      // 4. Navigate to home
      if (mounted && _controllerInitialized) {
        _navigateToHome();
      }
    } catch (e) {
      print('❌ Initialization error: $e');
      if (mounted) {
        _navigateToHome();
      }
    }
  }

  Future<void> _initializeContentController() async {
    try {
      print('🔄 Initializing ContentController...');

      if (Get.isRegistered<ContentController>()) {
        print('⚠️ ContentController already exists, removing...');
        await Get.delete<ContentController>();
      }

      Get.lazyPut(() => ContentController(), fenix: true);

      final controller = Get.find<ContentController>();
      print('✅ ContentController initialized successfully');

      _controllerInitialized = true;
    } catch (e) {
      print('❌ Error initializing ContentController: $e');
      _controllerInitialized = false;
    }
  }

  void _navigateToHome() {
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.off(() => HomeDashboardPage());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    // Detect tablet or wide aspect ratio
    final isTablet =
        size.shortestSide >= 600 || (size.width / size.height) > 0.58;

    return Scaffold(
      backgroundColor: const Color(0xFFD2E7DE),
      body: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Image.asset(
                isTablet
                    ? 'assets/images/alseraj-splash-tablet.jpg'
                    : 'assets/images/alseraj-splash.jpg',
                width: size.width,
                height: size.height,
                fit: BoxFit.cover,
              ),
            ),

            Positioned(
              bottom: isTablet ? size.height * 0.16 : size.height * 0.18,
              left: 0,
              right: 0,
              child: const Center(
                child: CustomLoading(
                  color: Color(0xFF165B4C),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
