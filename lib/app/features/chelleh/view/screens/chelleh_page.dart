import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../../../core/common/widgets/custom_app_bar.dart';
import '../../controller/chelleh_controller.dart';
import '../widgets/chelleh_info_sheet.dart';
import 'create_chelleh_page.dart';
import 'track_chelleh_page.dart';

class ChellehPage extends StatefulWidget {
  final int initialTab;

  const ChellehPage({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<ChellehPage> createState() => _ChellehPageState();
}

class _ChellehPageState extends State<ChellehPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ChellehController controller = Get.isRegistered<ChellehController>()
      ? Get.find<ChellehController>()
      : Get.put(ChellehController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final brandColor = colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: 'الأربعينيات المباركة (الأربعينية)',
        actions: [
          // Refresh API button
          ZoomTapAnimation(
            onTap: () => controller.refreshAdhkarFromApi(),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withAlpha(20)
                    : brandColor.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.refresh_rounded,
                size: 18,
                color: brandColor,
              ),
            ),
          ),

          // Info / Guide button
          ZoomTapAnimation(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const ChellehInfoSheet(),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withAlpha(20)
                    : brandColor.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.help_outline_rounded,
                size: 18,
                color: brandColor,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Elegant Top Segmented Tab Switcher
          Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E2226)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                _buildSegmentTab(
                  index: 0,
                  label: 'تكميل ومتابعة العهد',
                  icon: Icons.check_circle_outline_rounded,
                  brandColor: brandColor,
                  isDark: isDark,
                ),
                _buildSegmentTab(
                  index: 1,
                  label: 'إنشاء عهد جديد',
                  icon: Icons.add_circle_outline_rounded,
                  brandColor: brandColor,
                  isDark: isDark,
                ),
              ],
            ),
          ),

          // Tab Content Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                // صفحه ۱: تکمیل چله
                TrackChellehPage(isStandalone: false),
                // صفحه ۲: ایجاد چله
                CreateChellehPage(isStandalone: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentTab({
    required int index,
    required String label,
    required IconData icon,
    required Color brandColor,
    required bool isDark,
  }) {
    final isSelected = _tabController.index == index;

    return Expanded(
      child: ZoomTapAnimation(
        onTap: () {
          _tabController.animateTo(index);
          setState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? brandColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: brandColor.withAlpha(60),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.grey[400] : Colors.grey[700]),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.grey[400] : Colors.grey[700]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
