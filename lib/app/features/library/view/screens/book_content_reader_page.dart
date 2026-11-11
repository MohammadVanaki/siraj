import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mawsueat/app/features/library/controller/book_content_reader_controller.dart';
import 'package:mawsueat/app/features/library/data/helpers/book_content_styler.dart';
import 'package:mawsueat/app/features/library/data/models/book_content_model.dart';
import 'package:mawsueat/app/features/library/data/models/book_model.dart';
import 'package:mawsueat/app/features/library/data/repositories/library_repository.dart';
import 'package:mawsueat/app/features/setting/view/controller/settings_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class BookContentReaderPage extends StatefulWidget {
  final BookModel book;
  final String dbPath;
  final int? initialPage;

  const BookContentReaderPage({
    super.key,
    required this.book,
    required this.dbPath,
    this.initialPage,
  });

  @override
  State<BookContentReaderPage> createState() => _BookContentReaderPageState();
}

class _BookContentReaderPageState extends State<BookContentReaderPage>
    with TickerProviderStateMixin {
  late final BookContentReaderController controller;

  OverlayEntry? _tooltipOverlayEntry;
  AnimationController? _tooltipAnimController;
  Timer? _tooltipTimer;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      BookContentReaderController(
        repository: Get.find<LibraryRepository>(),
        book: widget.book,
        dbPath: widget.dbPath,
        initialPage: widget.initialPage,
      ),
      tag: 'reader_${widget.book.id}',
    );
  }

  @override
  void dispose() {
    _tooltipTimer?.cancel();
    _tooltipTimer = null;
    if (_tooltipOverlayEntry != null) {
      _tooltipOverlayEntry?.remove();
      _tooltipOverlayEntry = null;
    }
    _tooltipAnimController?.dispose();
    _tooltipAnimController = null;
    Get.delete<BookContentReaderController>(tag: 'reader_${widget.book.id}');
    super.dispose();
  }

  /// نمایش تولتیپ درون‌متنی شناور در پایین صفحه به صورت OverlayEntry با انیمیشن ورود و خروج
  void _showTooltip(String content) {
    if (!mounted || content.trim().isEmpty) return;

    // بستن تولتیپ قبلی و لغو تایمر در صورت باز بودن
    _tooltipTimer?.cancel();
    _tooltipTimer = null;

    if (_tooltipOverlayEntry != null) {
      _tooltipOverlayEntry?.remove();
      _tooltipOverlayEntry = null;
    }
    _tooltipAnimController?.dispose();
    _tooltipAnimController = null;

    // ایجاد کنترلر انیمیشن جدید
    final animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _tooltipAnimController = animController;

    final curved = CurvedAnimation(
      parent: animController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
    final slideAnim = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(curved);

    final overlayState = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (ctx) {
        return Obx(() {
          final readerTheme = controller.readerTheme.value;
          final bottomInset = MediaQuery.of(ctx).padding.bottom;

          return Positioned(
            left: 16,
            right: 16,
            bottom: bottomInset > 0 ? bottomInset + 16 : 24,
            child: Material(
              color: Colors.transparent,
              child: FadeTransition(
                opacity: fadeAnim,
                child: SlideTransition(
                  position: slideAnim,
                  child: _ReaderTooltipCard(
                    text: content,
                    readerTheme: readerTheme,
                    onClose: _hideTooltip,
                  ),
                ),
              ),
            ),
          );
        });
      },
    );

    _tooltipOverlayEntry = entry;
    overlayState.insert(entry);
    animController.forward();

    // بستن خودکار پس از ۸ ثانیه
    _tooltipTimer = Timer(const Duration(seconds: 8), () {
      _hideTooltip();
    });
  }

  /// بستن انیمیشنی تولتیپ جاری
  void _hideTooltip() {
    _tooltipTimer?.cancel();
    _tooltipTimer = null;

    if (_tooltipAnimController != null && _tooltipOverlayEntry != null) {
      final ctrl = _tooltipAnimController!;
      final entry = _tooltipOverlayEntry!;
      ctrl.reverse().then((_) {
        if (_tooltipOverlayEntry == entry) {
          entry.remove();
          _tooltipOverlayEntry = null;
          ctrl.dispose();
          if (_tooltipAnimController == ctrl) {
            _tooltipAnimController = null;
          }
        }
      });
    } else {
      _tooltipOverlayEntry?.remove();
      _tooltipOverlayEntry = null;
      _tooltipAnimController?.dispose();
      _tooltipAnimController = null;
    }
  }

  void _showChaptersModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        final readerTheme = controller.readerTheme.value;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            height: MediaQuery.of(ctx).size.height * 0.75,
            decoration: BoxDecoration(
              color: readerTheme.cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border.all(color: readerTheme.borderColor),
            ),
            child: SafeArea(
              top: false,
              bottom: true,
              child: Column(
                children: [
                  const Gap(12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: readerTheme.textColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.list_alt_rounded,
                              color: readerTheme.accentColor,
                              size: 22,
                            ),
                            const Gap(8),
                            Text(
                              'فهرس الفصول والمواضيع',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: readerTheme.textColor,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${controller.chapters.length} فصل',
                          style: TextStyle(
                            fontSize: 12,
                            color: readerTheme.textColor.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: readerTheme.borderColor),
                  Expanded(
                    child: Obx(() {
                      if (controller.chapters.isEmpty) {
                        return Center(
                          child: Text(
                            'لا يوجد فهرس معرّف لهذا الكتاب',
                            style: TextStyle(
                              fontSize: 14,
                              color: readerTheme.textColor.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          12,
                          8,
                          12,
                          MediaQuery.of(ctx).padding.bottom + 20,
                        ),
                        itemCount: controller.chapters.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: readerTheme.borderColor.withValues(alpha: 0.5),
                        ),
                        itemBuilder: (context, index) {
                          final chapter = controller.chapters[index];
                          final isCurrent =
                              controller.currentPage.value >=
                                  chapter.pageNumber &&
                              (index == controller.chapters.length - 1 ||
                                  controller.currentPage.value <
                                      controller
                                          .chapters[index + 1]
                                          .pageNumber);

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            tileColor: isCurrent
                                ? readerTheme.accentColor.withValues(
                                    alpha: 0.12,
                                  )
                                : null,
                            leading: Container(
                              width: 34,
                              height: 34,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? readerTheme.accentColor
                                    : readerTheme.textColor.withValues(
                                        alpha: 0.08,
                                      ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isCurrent
                                      ? Colors.white
                                      : readerTheme.textColor,
                                ),
                              ),
                            ),
                            title: Text(
                              chapter.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isCurrent
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isCurrent
                                    ? readerTheme.accentColor
                                    : readerTheme.textColor,
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: readerTheme.textColor.withValues(
                                  alpha: 0.06,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'ص ${chapter.pageNumber}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: readerTheme.textColor.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              controller.jumpToPage(chapter.pageNumber);
                            },
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSearchModal(BuildContext context) {
    final searchInputController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        final readerTheme = controller.readerTheme.value;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            height: MediaQuery.of(ctx).size.height * 0.8,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: readerTheme.cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border.all(color: readerTheme.borderColor),
            ),
            child: SafeArea(
              top: false,
              bottom: true,
              child: Column(
                children: [
                  const Gap(12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: readerTheme.textColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: readerTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: readerTheme.borderColor,
                              ),
                            ),
                            child: TextField(
                              controller: searchInputController,
                              autofocus: true,
                              textInputAction: TextInputAction.search,
                              style: TextStyle(
                                color: readerTheme.textColor,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: 'ابحث عن كلمة أو عبارة في الكتاب...',
                                hintStyle: TextStyle(
                                  color: readerTheme.textColor.withValues(
                                    alpha: 0.5,
                                  ),
                                  fontSize: 13,
                                ),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: readerTheme.accentColor,
                                  size: 20,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              onSubmitted: (val) {
                                controller.search(val);
                              },
                            ),
                          ),
                        ),
                        const Gap(8),
                        ElevatedButton(
                          onPressed: () {
                            controller.search(searchInputController.text);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: readerTheme.accentColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'بحث',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: readerTheme.borderColor),
                  Expanded(
                    child: Obx(() {
                      if (controller.isSearching.value) {
                        return Center(
                          child: LoadingAnimationWidget.waveDots(
                            color: readerTheme.accentColor,
                            size: 32,
                          ),
                        );
                      }

                      if (controller.searchResults.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.find_in_page_outlined,
                                size: 44,
                                color: readerTheme.textColor.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              const Gap(8),
                              Text(
                                searchInputController.text.isEmpty
                                    ? 'اكتب كلمة البحث واضغط على زر البحث'
                                    : 'لم يتم العثور على نتائج مطابقة',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: readerTheme.textColor.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          12,
                          12,
                          12,
                          MediaQuery.of(ctx).padding.bottom + 20,
                        ),
                        itemCount: controller.searchResults.length,
                        separatorBuilder: (_, __) => const Gap(8),
                        itemBuilder: (context, index) {
                          final item = controller.searchResults[index];

                          return InkWell(
                            onTap: () {
                              Navigator.pop(ctx);
                              controller.jumpToPage(item.pageNumber);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: readerTheme.backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: readerTheme.borderColor,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (item.chapterTitle.isNotEmpty)
                                        Expanded(
                                          child: Text(
                                            item.chapterTitle,
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold,
                                              color: readerTheme.accentColor,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )
                                      else
                                        const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: readerTheme.accentColor
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          'صفحة ${item.pageNumber}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: readerTheme.accentColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(6),
                                  Text(
                                    item.snippet,
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.5,
                                      color: readerTheme.textColor.withValues(
                                        alpha: 0.85,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Obx(() {
            final readerTheme = controller.readerTheme.value;
            final settingsController = Get.isRegistered<SettingsController>()
                ? Get.find<SettingsController>()
                : Get.put(SettingsController());

            return Container(
              decoration: BoxDecoration(
                color: readerTheme.cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border.all(color: readerTheme.borderColor),
              ),
              child: SafeArea(
                top: false,
                bottom: true,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    MediaQuery.of(ctx).padding.bottom + 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: readerTheme.textColor.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const Gap(16),
                      Text(
                        'خيارات القراءة والخط',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: readerTheme.textColor,
                        ),
                      ),
                      const Gap(18),

                      // تم مطالعه
                      Text(
                        'نمط العرض والخلفية',
                        style: TextStyle(
                          fontSize: 13,
                          color: readerTheme.textColor.withValues(alpha: 0.7),
                        ),
                      ),
                      const Gap(10),
                      Row(
                        children: ReaderThemeMode.values.map((mode) {
                          final isSelected =
                              controller.readerTheme.value == mode;

                          return Expanded(
                            child: GestureDetector(
                              onTap: () => controller.setTheme(mode),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: mode.backgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? controller
                                              .readerTheme
                                              .value
                                              .accentColor
                                        : mode.borderColor,
                                    width: isSelected ? 2.5 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      mode.title,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: mode.textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const Gap(20),

                      // نوع الخط
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'نوع الخط',
                            style: TextStyle(
                              fontSize: 13,
                              color: readerTheme.textColor.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                          Obx(() {
                            final currentFont =
                                settingsController.effectiveFontFamily;
                            final activeOption = settingsController
                                .availableFonts
                                .firstWhere(
                                  (f) => f.fontFamily == currentFont,
                                  orElse: () =>
                                      settingsController.availableFonts.first,
                                );
                            return Text(
                              activeOption.name,
                              style: TextStyle(
                                fontFamily: activeOption.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: readerTheme.accentColor,
                              ),
                            );
                          }),
                        ],
                      ),
                      const Gap(10),
                      Obx(() {
                        final currentFont =
                            settingsController.effectiveFontFamily;
                        return Row(
                          children: settingsController.availableFonts.map((
                            font,
                          ) {
                            final isSelected = currentFont == font.fontFamily;

                            return Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    settingsController.setFontFamily(font.id),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? readerTheme.accentColor.withValues(
                                            alpha: 0.15,
                                          )
                                        : readerTheme.textColor.withValues(
                                            alpha: 0.05,
                                          ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? readerTheme.accentColor
                                          : readerTheme.borderColor,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        font.name,
                                        style: TextStyle(
                                          fontFamily: font.fontFamily,
                                          fontSize: 13,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? readerTheme.accentColor
                                              : readerTheme.textColor,
                                        ),
                                      ),
                                      const Gap(3),
                                      Text(
                                        'بسم الله',
                                        style: TextStyle(
                                          fontFamily: font.fontFamily,
                                          fontSize: 11,
                                          color: isSelected
                                              ? readerTheme.accentColor
                                                    .withValues(alpha: 0.85)
                                              : readerTheme.textColor
                                                    .withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),

                      const Gap(22),

                      // اتجاه القراءة والتصفح
                      Text(
                        'طريقة تصفح الصفحات',
                        style: TextStyle(
                          fontSize: 13,
                          color: readerTheme.textColor.withValues(alpha: 0.7),
                        ),
                      ),
                      const Gap(10),
                      Row(
                        children: [
                          // گزینه عمودي (تمرير)
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.setScrollDirection(true),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: controller.isVertical.value
                                      ? readerTheme.accentColor.withValues(
                                          alpha: 0.15,
                                        )
                                      : readerTheme.textColor.withValues(
                                          alpha: 0.05,
                                        ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: controller.isVertical.value
                                        ? readerTheme.accentColor
                                        : readerTheme.borderColor,
                                    width: controller.isVertical.value ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.swap_vert_rounded,
                                      size: 19,
                                      color: controller.isVertical.value
                                          ? readerTheme.accentColor
                                          : readerTheme.textColor.withValues(
                                              alpha: 0.6,
                                            ),
                                    ),
                                    const Gap(6),
                                    Text(
                                      'عمودي (تمرير)',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: controller.isVertical.value
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: controller.isVertical.value
                                            ? readerTheme.accentColor
                                            : readerTheme.textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Gap(10),
                          // گزینه تصفح (أفقي)
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.setScrollDirection(false),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: !controller.isVertical.value
                                      ? readerTheme.accentColor.withValues(
                                          alpha: 0.15,
                                        )
                                      : readerTheme.textColor.withValues(
                                          alpha: 0.05,
                                        ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: !controller.isVertical.value
                                        ? readerTheme.accentColor
                                        : readerTheme.borderColor,
                                    width: !controller.isVertical.value ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.swap_horiz_rounded,
                                      size: 19,
                                      color: !controller.isVertical.value
                                          ? readerTheme.accentColor
                                          : readerTheme.textColor.withValues(
                                              alpha: 0.6,
                                            ),
                                    ),
                                    const Gap(6),
                                    Text(
                                      'تصفح',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: !controller.isVertical.value
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: !controller.isVertical.value
                                            ? readerTheme.accentColor
                                            : readerTheme.textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Gap(22),

                      // اندازه فونت
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'حجم الخط',
                            style: TextStyle(
                              fontSize: 13,
                              color: readerTheme.textColor.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                          Text(
                            '${controller.fontSize.value.toInt()} pt',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: readerTheme.accentColor,
                            ),
                          ),
                        ],
                      ),
                      const Gap(8),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => controller.decreaseFontSize(),
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: readerTheme.textColor.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.text_decrease_rounded,
                                color: readerTheme.textColor,
                                size: 20,
                              ),
                            ),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(ctx).copyWith(
                                activeTrackColor: readerTheme.accentColor,
                                inactiveTrackColor: readerTheme.textColor
                                    .withValues(alpha: 0.15),
                                thumbColor: readerTheme.accentColor,
                              ),
                              child: Slider(
                                value: controller.fontSize.value,
                                min: 14.0,
                                max: 32.0,
                                divisions: 12,
                                onChanged: (val) {
                                  controller.setFontSize(val);
                                },
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => controller.increaseFontSize(),
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: readerTheme.textColor.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.text_increase_rounded,
                                color: readerTheme.textColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Gap(12),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  void _showJumpToPageDialog(BuildContext context) {
    final textEditController = TextEditingController(
      text: controller.currentPage.value.toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) {
        final readerTheme = controller.readerTheme.value;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: readerTheme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'الانتقال إلى صفحة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: readerTheme.textColor,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'أدخل رقم الصفحة بين 1 و ${controller.totalPages.value}:',
                  style: TextStyle(
                    fontSize: 13,
                    color: readerTheme.textColor.withValues(alpha: 0.7),
                  ),
                ),
                const Gap(12),
                TextField(
                  controller: textEditController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: readerTheme.textColor,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: readerTheme.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: readerTheme.accentColor,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'إلغاء',
                  style: TextStyle(
                    color: readerTheme.textColor.withValues(alpha: 0.6),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final pageNum = int.tryParse(textEditController.text.trim());
                  if (pageNum != null &&
                      pageNum >= 1 &&
                      pageNum <= controller.totalPages.value) {
                    Navigator.pop(ctx);
                    controller.jumpToPage(pageNum);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: readerTheme.accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('انتقال'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final readerTheme = controller.readerTheme.value;

      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: readerTheme.backgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                // بدنه اصلی خوانش صفحات (PageView)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => controller.toggleControls(),
                    child: Obx(() {
                      if (controller.isLoadingInitial.value) {
                        return Center(
                          child: LoadingAnimationWidget.waveDots(
                            color: readerTheme.accentColor,
                            size: 36,
                          ),
                        );
                      }

                      final isVertical = controller.isVertical.value;

                      return PageView.builder(
                        key: ValueKey('pageview_$isVertical'),
                        controller: controller.pageController,
                        scrollDirection: isVertical
                            ? Axis.vertical
                            : Axis.horizontal,
                        itemCount: controller.totalPages.value,
                        onPageChanged: controller.onPageViewChanged,
                        itemBuilder: (context, index) {
                          final pageNum = index + 1;

                          return _PageContentWidget(
                            key: ValueKey('page_${pageNum}_$isVertical'),
                            pageNum: pageNum,
                            controller: controller,
                            readerTheme: readerTheme,
                            isVertical: isVertical,
                            onShowTooltip: _showTooltip,
                          );
                        },
                      );
                    }),
                  ),
                ),

                // کپسول شناور نوار بالا (Top Controls)
                Obx(() {
                  final isVisible = controller.showControls.value;

                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    top: isVisible ? 12 : -90,
                    left: 14,
                    right: 14,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          height: 54,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: readerTheme.cardColor.withValues(
                              alpha: 0.92,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: readerTheme.borderColor.withValues(
                                alpha: 0.8,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // دکمه بازگشت
                              ZoomTapAnimation(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: readerTheme.textColor.withValues(
                                      alpha: 0.06,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: readerTheme.textColor,
                                  ),
                                ),
                              ),
                              const Gap(8),

                              // عنوان کتاب و فصل
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.book.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: readerTheme.textColor,
                                      ),
                                    ),
                                    Obx(() {
                                      final ch =
                                          controller.currentChapterTitle.value;
                                      if (ch.isEmpty ||
                                          ch == widget.book.title) {
                                        return const SizedBox.shrink();
                                      }
                                      return Text(
                                        ch,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: readerTheme.accentColor,
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),

                              // دکمه بوکمارک (نشانه‌گذاری)
                              Obx(() {
                                final isFav =
                                    controller.isCurrentPageBookmarked.value;
                                return IconButton(
                                  icon: Icon(
                                    isFav
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_border_rounded,
                                    color: isFav
                                        ? const Color(0xFFFFB800)
                                        : readerTheme.textColor,
                                    size: 21,
                                  ),
                                  onPressed: () =>
                                      controller.toggleCurrentPageBookmark(),
                                  tooltip: 'نشانه‌گذاری صفحه',
                                );
                              }),

                              // دکمه جستجو
                              IconButton(
                                icon: Icon(
                                  Icons.search_rounded,
                                  color: readerTheme.textColor,
                                  size: 21,
                                ),
                                onPressed: () => _showSearchModal(context),
                                tooltip: 'بحث في الكتاب',
                              ),

                              // دکمه تنظیمات فونت و تم
                              IconButton(
                                icon: Icon(
                                  Icons.format_size_rounded,
                                  color: readerTheme.textColor,
                                  size: 21,
                                ),
                                onPressed: () => _showSettingsModal(context),
                                tooltip: 'حجم الخط والمظهر',
                              ),

                              // دکمه فهرست فصول
                              IconButton(
                                icon: Icon(
                                  Icons.menu_book_rounded,
                                  color: readerTheme.accentColor,
                                  size: 21,
                                ),
                                onPressed: () => _showChaptersModal(context),
                                tooltip: 'فهرس الفصول',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                // خط نشانگر پیشرفت مطالعه در لبه صفحه در حالت عمودی وقتی کنترل‌ها مخفی هستند
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Obx(() {
                    final isVisible = controller.showControls.value;
                    final isVertical = controller.isVertical.value;

                    if (!isVertical || isVisible)
                      return const SizedBox.shrink();

                    final cur = controller.currentPage.value;
                    final total = controller.totalPages.value;
                    final progress = total > 0
                        ? (cur / total).clamp(0.0, 1.0)
                        : 0.0;

                    return Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 3.5,
                        height: MediaQuery.of(context).size.height * progress,
                        decoration: BoxDecoration(
                          color: readerTheme.accentColor.withValues(alpha: 0.6),
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(3),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                // کپسول شناور پروگرس عمودی (Vertical Progress Controls) در حالت مطالعه عمودی
                Obx(() {
                  final isVisible = controller.showControls.value;
                  final isVertical = controller.isVertical.value;

                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    left: (isVisible && isVertical) ? 8 : -90,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        width: 44,
                        height: 350,
                        decoration: BoxDecoration(
                          color: readerTheme.cardColor.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: readerTheme.borderColor.withValues(
                              alpha: 0.8,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 16,
                              offset: const Offset(2, 0),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Column(
                                children: [
                                  // دکمه صفحه قبلی (بالا)
                                  SizedBox(
                                    height: 36,
                                    width: 36,
                                    child: IconButton(
                                      tooltip: 'الصفحة السابقة',
                                      padding: EdgeInsets.zero,
                                      icon: Icon(
                                        Icons.keyboard_arrow_up_rounded,
                                        color: controller.currentPage.value > 1
                                            ? readerTheme.textColor
                                            : readerTheme.textColor.withValues(
                                                alpha: 0.2,
                                              ),
                                        size: 26,
                                      ),
                                      onPressed:
                                          controller.currentPage.value > 1
                                          ? () => controller.previousPage()
                                          : null,
                                    ),
                                  ),

                                  const Gap(2),

                                  // چیپ شماره صفحه و درصد
                                  ZoomTapAnimation(
                                    onTap: () => _showJumpToPageDialog(context),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: readerTheme.accentColor
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Obx(() {
                                        final maxPages = controller
                                            .totalPages
                                            .value
                                            .toDouble();
                                        final current = controller
                                            .currentPage
                                            .value
                                            .toDouble()
                                            .clamp(
                                              1.0,
                                              maxPages > 1.0 ? maxPages : 1.0,
                                            );
                                        final displayVal =
                                            controller.isDraggingSlider.value
                                            ? controller.dragPage.value
                                                  .toDouble()
                                                  .clamp(
                                                    1.0,
                                                    maxPages > 1.0
                                                        ? maxPages
                                                        : 1.0,
                                                  )
                                            : current;
                                        final pct = maxPages > 0
                                            ? ((displayVal / maxPages) * 100)
                                                  .toInt()
                                            : 0;

                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '$pct%',
                                              style: TextStyle(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.bold,
                                                color: readerTheme.accentColor,
                                              ),
                                            ),
                                            Text(
                                              '${displayVal.toInt()}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: readerTheme.textColor,
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                    ),
                                  ),

                                  const Gap(4),

                                  // اسلایدر عمودی از بالا به پایین (با Directionality LTR و RotatedBox)
                                  Expanded(
                                    child: LayoutBuilder(
                                      builder: (ctx, constraints) {
                                        final sliderLength =
                                            constraints.maxHeight;
                                        return Directionality(
                                          textDirection: TextDirection.ltr,
                                          child: RotatedBox(
                                            quarterTurns: 1,
                                            child: SizedBox(
                                              width: sliderLength,
                                              height: 42,
                                              child: SliderTheme(
                                                data: SliderTheme.of(context).copyWith(
                                                  trackHeight: 4,
                                                  thumbShape:
                                                      const RoundSliderThumbShape(
                                                        enabledThumbRadius: 7,
                                                      ),
                                                  activeTrackColor:
                                                      readerTheme.accentColor,
                                                  inactiveTrackColor:
                                                      readerTheme.textColor
                                                          .withValues(
                                                            alpha: 0.15,
                                                          ),
                                                  thumbColor:
                                                      readerTheme.accentColor,
                                                  overlayShape:
                                                      const RoundSliderOverlayShape(
                                                        overlayRadius: 14,
                                                      ),
                                                ),
                                                child: Obx(() {
                                                  final maxPages = controller
                                                      .totalPages
                                                      .value
                                                      .toDouble();
                                                  final current = controller
                                                      .currentPage
                                                      .value
                                                      .toDouble()
                                                      .clamp(
                                                        1.0,
                                                        maxPages > 1.0
                                                            ? maxPages
                                                            : 1.0,
                                                      );
                                                  final displayVal =
                                                      controller
                                                          .isDraggingSlider
                                                          .value
                                                      ? controller
                                                            .dragPage
                                                            .value
                                                            .toDouble()
                                                            .clamp(
                                                              1.0,
                                                              maxPages > 1.0
                                                                  ? maxPages
                                                                  : 1.0,
                                                            )
                                                      : current;

                                                  return Slider(
                                                    value: displayVal,
                                                    min: 1.0,
                                                    max: maxPages > 1.0
                                                        ? maxPages
                                                        : 1.0,
                                                    divisions: maxPages > 1
                                                        ? (maxPages - 1).toInt()
                                                        : 1,
                                                    onChangeStart: (_) {
                                                      controller
                                                              .isDraggingSlider
                                                              .value =
                                                          true;
                                                    },
                                                    onChanged: (val) {
                                                      controller
                                                          .dragPage
                                                          .value = val
                                                          .toInt();
                                                    },
                                                    onChangeEnd: (val) {
                                                      controller
                                                              .isDraggingSlider
                                                              .value =
                                                          false;
                                                      controller.jumpToPage(
                                                        val.toInt(),
                                                      );
                                                    },
                                                  );
                                                }),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  const Gap(4),

                                  // دکمه صفحه بعدی (پایین)
                                  SizedBox(
                                    height: 36,
                                    width: 36,
                                    child: IconButton(
                                      tooltip: 'الصفحة التالية',
                                      padding: EdgeInsets.zero,
                                      icon: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color:
                                            controller.currentPage.value <
                                                controller.totalPages.value
                                            ? readerTheme.textColor
                                            : readerTheme.textColor.withValues(
                                                alpha: 0.2,
                                              ),
                                        size: 26,
                                      ),
                                      onPressed:
                                          controller.currentPage.value <
                                              controller.totalPages.value
                                          ? () => controller.nextPage()
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                // کپسول شناور نوار پایین (Bottom Controls)
                Obx(() {
                  final isVisible = controller.showControls.value;
                  final isVertical = controller.isVertical.value;

                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    bottom: isVisible ? 12 : -110,
                    left: 14,
                    right: 14,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: readerTheme.cardColor.withValues(
                              alpha: 0.94,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: readerTheme.borderColor.withValues(
                                alpha: 0.8,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 18,
                                offset: const Offset(0, -4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ردیف اطلاعات صفحه و درصد
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ZoomTapAnimation(
                                    onTap: () => _showJumpToPageDialog(context),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: readerTheme.textColor.withValues(
                                          alpha: 0.08,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.edit_note_rounded,
                                            size: 14,
                                            color: readerTheme.accentColor,
                                          ),
                                          const Gap(4),
                                          Obx(
                                            () => Text(
                                              'صفحة ${controller.currentPage.value} من ${controller.totalPages.value}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: readerTheme.textColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Obx(() {
                                    final cur = controller.currentPage.value;
                                    final total = controller.totalPages.value;
                                    final pct = total > 0
                                        ? ((cur / total) * 100).toInt()
                                        : 0;
                                    return Text(
                                      '$pct%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: readerTheme.accentColor,
                                      ),
                                    );
                                  }),
                                ],
                              ),

                              // اگر در حالت افقی باشیم، اسلایدر افقی در پایین نمایش داده می‌شود
                              if (!isVertical) ...[
                                const Gap(4),
                                Row(
                                  children: [
                                    // دکمه صفحه قبلی
                                    IconButton(
                                      tooltip: 'الصفحة السابقة',
                                      icon: Icon(
                                        Icons.chevron_left_rounded,
                                        color: controller.currentPage.value > 1
                                            ? readerTheme.textColor
                                            : readerTheme.textColor.withValues(
                                                alpha: 0.2,
                                              ),
                                        size: 26,
                                      ),
                                      onPressed:
                                          controller.currentPage.value > 1
                                          ? () => controller.previousPage()
                                          : null,
                                    ),

                                    // اسلایدر جابه‌جایی افقی
                                    Expanded(
                                      child: SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          trackHeight: 4,
                                          thumbShape:
                                              const RoundSliderThumbShape(
                                                enabledThumbRadius: 7,
                                              ),
                                          activeTrackColor:
                                              readerTheme.accentColor,
                                          inactiveTrackColor: readerTheme
                                              .textColor
                                              .withValues(alpha: 0.15),
                                          thumbColor: readerTheme.accentColor,
                                          showValueIndicator:
                                              ShowValueIndicator.always,
                                          valueIndicatorShape:
                                              const PaddleSliderValueIndicatorShape(),
                                          valueIndicatorColor:
                                              readerTheme.accentColor,
                                          valueIndicatorTextStyle:
                                              const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        child: Obx(() {
                                          final maxPages = controller
                                              .totalPages
                                              .value
                                              .toDouble();
                                          final current = controller
                                              .currentPage
                                              .value
                                              .toDouble()
                                              .clamp(
                                                1.0,
                                                maxPages > 1.0 ? maxPages : 1.0,
                                              );
                                          final displayVal =
                                              controller.isDraggingSlider.value
                                              ? controller.dragPage.value
                                                    .toDouble()
                                                    .clamp(
                                                      1.0,
                                                      maxPages > 1.0
                                                          ? maxPages
                                                          : 1.0,
                                                    )
                                              : current;

                                          return Slider(
                                            value: displayVal,
                                            min: 1.0,
                                            max: maxPages > 1.0
                                                ? maxPages
                                                : 1.0,
                                            divisions: maxPages > 1
                                                ? (maxPages - 1).toInt()
                                                : 1,
                                            label: 'صفحة ${displayVal.toInt()}',
                                            onChangeStart: (_) {
                                              controller
                                                      .isDraggingSlider
                                                      .value =
                                                  true;
                                            },
                                            onChanged: (val) {
                                              controller.dragPage.value = val
                                                  .toInt();
                                            },
                                            onChangeEnd: (val) {
                                              controller
                                                      .isDraggingSlider
                                                      .value =
                                                  false;
                                              controller.jumpToPage(
                                                val.toInt(),
                                              );
                                            },
                                          );
                                        }),
                                      ),
                                    ),

                                    // دکمه صفحه بعدی`
                                    IconButton(
                                      tooltip: 'الصفحة التالية',
                                      icon: Icon(
                                        Icons.chevron_right_rounded,
                                        color:
                                            controller.currentPage.value <
                                                controller.totalPages.value
                                            ? readerTheme.textColor
                                            : readerTheme.textColor.withValues(
                                                alpha: 0.2,
                                              ),
                                        size: 26,
                                      ),
                                      onPressed:
                                          controller.currentPage.value <
                                              controller.totalPages.value
                                          ? () => controller.nextPage()
                                          : null,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _PageContentWidget extends StatefulWidget {
  final int pageNum;
  final BookContentReaderController controller;
  final ReaderThemeMode readerTheme;
  final bool isVertical;
  final ValueChanged<String> onShowTooltip;

  const _PageContentWidget({
    super.key,
    required this.pageNum,
    required this.controller,
    required this.readerTheme,
    required this.isVertical,
    required this.onShowTooltip,
  });

  @override
  State<_PageContentWidget> createState() => _PageContentWidgetState();
}

class _PageContentWidgetState extends State<_PageContentWidget> {
  BookPageModel? pageModel;
  bool isLoading = true;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _triggerPrevPage() {
    if (_isNavigating || widget.controller.currentPage.value <= 1) return;
    _isNavigating = true;
    widget.controller.previousPage();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _isNavigating = false;
    });
  }

  void _triggerNextPage() {
    if (_isNavigating ||
        widget.controller.currentPage.value >=
            widget.controller.totalPages.value)
      return;
    _isNavigating = true;
    widget.controller.nextPage();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _isNavigating = false;
    });
  }

  Future<void> _loadData() async {
    final cached = widget.controller.pagesCache[widget.pageNum];
    if (cached != null) {
      if (mounted) {
        setState(() {
          pageModel = cached;
          isLoading = false;
        });
      }
      return;
    }

    final data = await widget.controller.loadPage(widget.pageNum);
    if (mounted) {
      setState(() {
        pageModel = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: LoadingAnimationWidget.waveDots(
          color: widget.readerTheme.accentColor,
          size: 28,
        ),
      );
    }

    final text = pageModel?.text ?? '';

    return Obx(() {
      final showControls = widget.controller.showControls.value;

      final topPadding = showControls ? 74.0 : 12.0;
      final bottomPadding = showControls
          ? (widget.isVertical ? 48.0 : 88.0)
          : 18.0;
      final leftPadding = (showControls && widget.isVertical) ? 56.0 : 18.0;
      const rightPadding = 18.0;

      final scrollContent = AnimatedPadding(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.fromLTRB(
          leftPadding,
          topPadding,
          rightPadding,
          bottomPadding,
        ),
        child: SingleChildScrollView(
          physics: widget.isVertical
              ? const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                )
              : const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // سربرگ صفحه با شماره صفحه
              Container(
                padding: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: widget.readerTheme.borderColor.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الجزء / الصفحة',
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.readerTheme.textColor.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: widget.readerTheme.accentColor.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'صفحة ${widget.pageNum}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: widget.readerTheme.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(14),

              // متن صفحه
              if (text.trim().isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      '[صفحة فارغة]',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: widget.readerTheme.textColor.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Obx(() {
                  final fontSize = widget.controller.fontSize.value;
                  final lineHeight = widget.controller.lineHeight.value;
                  final readerTheme = widget.readerTheme;
                  final searchQuery =
                      widget.controller.currentSearchQuery.value;

                  // ۱. پیش‌پردازش متن خام (تبدیل تولتیپ به تگ <a> اینلاین + هایلایت عبارت جستجو)
                  final preprocessedHtml = BookContentStyler.preprocessHtml(
                    text,
                    searchQuery: searchQuery,
                  );

                  final activeFont = Get.isRegistered<SettingsController>()
                      ? Get.find<SettingsController>().effectiveFontFamily
                      : 'dijlah';

                  // ۲. آماده‌سازی محتوا با تزریق استایل‌ها
                  final styledHtml = BookContentStyler.wrapHtmlWithTheme(
                    rawHtml: preprocessedHtml,
                    theme: readerTheme,
                    fontSize: fontSize,
                    lineHeight: lineHeight,
                    fontFamily: activeFont,
                  );

                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: SelectionArea(
                      child: HtmlWidget(
                        styledHtml,
                        textStyle: TextStyle(
                          fontFamily: activeFont,
                          fontSize: fontSize,
                          height: lineHeight,
                          color: readerTheme.textColor,
                          letterSpacing: 0.15,
                          wordSpacing: 1.1,
                        ),
                        customStylesBuilder: (element) {
                          return BookContentStyler.resolveCustomStyle(
                            element,
                            readerTheme,
                          );
                        },

                        onTapUrl: (url) {
                          if (url.startsWith('tooltip:')) {
                            final rawEncoded = url.substring('tooltip:'.length);
                            try {
                              final decodedText = Uri.decodeComponent(
                                rawEncoded,
                              );
                              widget.onShowTooltip(decodedText);
                            } catch (_) {
                              widget.onShowTooltip(rawEncoded);
                            }
                            return true;
                          }
                          return false;
                        },
                      ),
                    ),
                  );
                }),

              const Gap(18),

              // پانوشت صفحه
              Center(
                child: Text(
                  '- ${widget.pageNum} -',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.readerTheme.textColor.withValues(alpha: 0.45),
                  ),
                ),
              ),
              const Gap(8),
            ],
          ),
        ),
      );

      if (!widget.isVertical) {
        return scrollContent;
      }

      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is OverscrollNotification) {
            if (notification.overscroll > 25) {
              _triggerNextPage();
            } else if (notification.overscroll < -25) {
              _triggerPrevPage();
            }
          } else if (notification is ScrollUpdateNotification) {
            final metrics = notification.metrics;
            if (metrics.pixels >= metrics.maxScrollExtent &&
                (notification.scrollDelta ?? 0) > 20) {
              _triggerNextPage();
            } else if (metrics.pixels <= metrics.minScrollExtent &&
                (notification.scrollDelta ?? 0) < -20) {
              _triggerPrevPage();
            }
          }
          return false;
        },
        child: scrollContent,
      );
    });
  }
}

/// ویجت نمایش کارت تولتیپ / پاورقی شناور
class _ReaderTooltipCard extends StatelessWidget {
  final String text;
  final ReaderThemeMode readerTheme;
  final VoidCallback onClose;

  const _ReaderTooltipCard({
    required this.text,
    required this.readerTheme,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final activeFont = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>().effectiveFontFamily
        : 'dijlah';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.38,
        ),
        decoration: BoxDecoration(
          color: readerTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: readerTheme.borderColor.withValues(alpha: 0.8),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // نوار هدر تولتیپ
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: readerTheme.accentColor.withValues(alpha: 0.08),
                  border: Border(
                    bottom: BorderSide(
                      color: readerTheme.borderColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: 18,
                      color: readerTheme.accentColor,
                    ),
                    const Gap(8),
                    Text(
                      'الهامش',
                      style: TextStyle(
                        fontFamily: activeFont,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: readerTheme.textColor,
                      ),
                    ),
                    const Spacer(),
                    ZoomTapAnimation(
                      onTap: onClose,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: readerTheme.textColor.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 17,
                          color: readerTheme.textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // متن کامل پاورقی با اسکرول
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontFamily: activeFont,
                      fontSize: 14,
                      height: 1.65,
                      color: readerTheme.textColor,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
