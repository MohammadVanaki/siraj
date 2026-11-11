import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mawsueat/app/features/library/controller/encyclopedia_entry_controller.dart';
import 'package:mawsueat/app/features/library/data/repositories/library_repository.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class EncyclopediaEntryReaderPage extends StatefulWidget {
  final int entryId;
  final String title;

  const EncyclopediaEntryReaderPage({
    super.key,
    required this.entryId,
    required this.title,
  });

  @override
  State<EncyclopediaEntryReaderPage> createState() =>
      _EncyclopediaEntryReaderPageState();
}

class _EncyclopediaEntryReaderPageState
    extends State<EncyclopediaEntryReaderPage> {
  late final EncyclopediaEntryController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      EncyclopediaEntryController(
        Get.find<LibraryRepository>(),
        initialEntryId: widget.entryId,
        initialTitle: widget.title,
      ),
      tag: 'entry_${widget.entryId}',
    );
  }

  @override
  void dispose() {
    Get.delete<EncyclopediaEntryController>(tag: 'entry_${widget.entryId}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.onPrimary;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Obx(() {
          final entry = controller.entry.value;
          return Text(
            entry?.title ?? widget.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
            ),
          );
        }),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.copy_rounded, color: theme.colorScheme.onSurface, size: 20),
            tooltip: 'نسخ',
            onPressed: controller.copyText,
          ),
          IconButton(
            icon: Icon(Icons.share_rounded, color: theme.colorScheme.onSurface, size: 20),
            tooltip: 'مشاركة',
            onPressed: controller.shareText,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: LoadingAnimationWidget.waveDots(
              color: primaryColor,
              size: 38,
            ),
          );
        }

        final entry = controller.entry.value;
        if (entry == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book_rounded, size: 48, color: Colors.grey[400]),
                const Gap(12),
                Text(
                  'تعذر تحميل المدخل',
                  style: TextStyle(color: theme.colorScheme.secondary),
                ),
                const Gap(16),
                ElevatedButton(
                  onPressed: () => controller.loadEntry(controller.currentEntryId.value),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Top Font & Info Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerTheme.color ?? Colors.grey.shade200,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Book title badge if available
                  if (entry.bookTitle != null && entry.bookTitle!.isNotEmpty)
                    Expanded(
                      child: Text(
                        entry.bookTitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const Spacer(),

                  // Font Size Buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ZoomTapAnimation(
                        onTap: controller.increaseFontSize,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.black.withAlpha(8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'A+',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const Gap(6),
                      ZoomTapAnimation(
                        onTap: controller.decreaseFontSize,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.black.withAlpha(8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'A-',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Text Scroll Area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title Header Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        entry.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const Gap(18),

                    // Entry Content
                    SelectableText(
                      entry.text,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: controller.fontSize.value,
                        height: 2.1,
                        letterSpacing: 0.2,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                      ),
                    ),

                    const Gap(80),
                  ],
                ),
              ),
            ),

            // Bottom Navigation (Previous / Next Entry)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous Entry Button
                    if (entry.previousEntryId != null)
                      ZoomTapAnimation(
                        onTap: controller.loadPrevious,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white12 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.arrow_forward_ios_rounded,
                                  size: 14, color: theme.colorScheme.onSurface),
                              const Gap(6),
                              Text(
                                'المدخل السابق',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),

                    // Next Entry Button
                    if (entry.nextEntryId != null)
                      ZoomTapAnimation(
                        onTap: controller.loadNext,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'المدخل التالي',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Gap(6),
                              Icon(Icons.arrow_back_ios_new_rounded,
                                  size: 14, color: Colors.white),
                            ],
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
