import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mawsueat/app/features/library/controller/book_detail_controller.dart';
import 'package:mawsueat/app/features/library/data/models/book_model.dart';
import 'package:mawsueat/app/features/library/data/repositories/library_repository.dart';
import 'package:mawsueat/app/features/library/view/screens/book_content_reader_page.dart';
import 'package:mawsueat/app/features/library/view/screens/book_reader_page.dart';
import 'package:mawsueat/app/features/library/view/screens/encyclopedia_entry_reader_page.dart';
import 'package:mawsueat/app/features/library/view/widgets/book_cover_3d.dart';
import 'package:mawsueat/app/features/library/view/widgets/book_rating_bar_widget.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class BookDetailPage extends StatefulWidget {
  final BookModel book;

  const BookDetailPage({super.key, required this.book});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late final BookDetailController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      BookDetailController(Get.find<LibraryRepository>(), widget.book),
      tag: 'book_${widget.book.id}',
    );
  }

  @override
  void dispose() {
    Get.delete<BookDetailController>(tag: 'book_${widget.book.id}');
    super.dispose();
  }

  void _showRatingDialog(BuildContext context) {
    double selectedRating = controller.book.value.userRating ?? 5.0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final primaryColor = theme.colorScheme.onPrimary;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Gap(16),
                  Text(
                    'تقييم الكتاب',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'ما هو تقييمك لكتاب "${controller.book.value.title}"؟',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const Gap(20),
                  BookRatingBarWidget(
                    rating: selectedRating,
                    size: 36,
                    isInteractive: true,
                    onRatingChanged: (val) {
                      setModalState(() {
                        selectedRating = val;
                      });
                    },
                  ),
                  const Gap(24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        controller.submitRating(selectedRating);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'إرسال التقييم',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const Gap(8),
                ],
              ),
            ),
          ),
        );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'تفاصيل الكتاب',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() {
            final isFav = controller.isFavorite;
            return IconButton(
              icon: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                color: isFav ? Colors.redAccent : theme.colorScheme.onSurface,
              ),
              onPressed: controller.toggleFavorite,
              tooltip: isFav ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
            );
          }),
          Obx(() {
            final book = controller.book.value;
            if (!book.isDownloaded) return const SizedBox.shrink();

            return PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: theme.colorScheme.onSurface),
              onSelected: (val) {
                if (val == 'delete') {
                  controller.deleteDownload();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                      Gap(8),
                      Text('حذف من التحميلات', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        final book = controller.book.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Hero 3D Book Cover
              Center(
                child: BookCover3D(
                  coverUrl: book.coverUrl,
                  heroTag: 'book_cover_${book.id}',
                  width: 175,
                  height: 255,
                  pageThickness: 8.5,
                  cornerRadius: 7.0,
                ),
              ),

              const Gap(20),

              // Title & Author
              Text(
                book.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Gap(6),
              Text(
                book.author,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: theme.colorScheme.secondary,
                ),
              ),

              const Gap(16),

              // 5-Star Rating Card (Interactive if downloaded, Display if not)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.dividerTheme.color ?? Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BookRatingBarWidget(
                          rating: book.rating,
                          size: 20,
                        ),
                        const Gap(8),
                        Text(
                          book.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          '(${book.reviewsCount} تقييم)',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const Gap(8),
                    if (book.isDownloaded) ...[
                      Divider(height: 1, color: theme.dividerTheme.color),
                      const Gap(8),
                      ZoomTapAnimation(
                        onTap: () => _showRatingDialog(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              book.userRating != null ? Icons.star_rounded : Icons.star_border_rounded,
                              size: 18,
                              color: const Color(0xFFFFB800),
                            ),
                            const Gap(6),
                            Text(
                              book.userRating != null
                                  ? 'تقييمك: ${book.userRating} نجوم (تعديل)'
                                  : 'اضغط هنا لتقييم هذا الكتاب',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Text(
                        'قم بتحميل الكتاب لتتمكن من إضافة تقييمك',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.secondary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const Gap(16),

              // Metadata Stats Grid (Category, Pages, File Size, Year)
              Row(
                children: [
                  _buildStatItem(
                    context,
                    title: 'القسم',
                    value: book.categoryName,
                    icon: Icons.category_outlined,
                  ),
                  const Gap(10),
                  _buildStatItem(
                    context,
                    title: 'الصفحات',
                    value: '${book.totalPages} ص',
                    icon: Icons.auto_stories_outlined,
                  ),
                  const Gap(10),
                  _buildStatItem(
                    context,
                    title: 'الحجم',
                    value: book.formattedFileSize,
                    icon: Icons.data_usage_rounded,
                  ),
                  if (book.publishedYear != null) ...[
                    const Gap(10),
                    _buildStatItem(
                      context,
                      title: 'السنة',
                      value: book.publishedYear!,
                      icon: Icons.calendar_today_outlined,
                    ),
                  ],
                ],
              ),

              const Gap(16),

              // Reading Progress Status (if started)
              if (book.hasStartedReading) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.bookmark_outline_rounded, size: 18, color: primaryColor),
                              const Gap(6),
                              Text(
                                'موضع القراءة الأخير',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${book.readProgressPercent}%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const Gap(8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: book.readProgress,
                          backgroundColor: Colors.white.withValues(alpha: 0.5),
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          minHeight: 6,
                        ),
                      ),
                      const Gap(6),
                      Text(
                        'قرأت ${book.lastReadPage} من أصل ${book.totalPages} صفحة',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(16),
              ],

              // Book Description Section (if available)
              if (book.description.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'نبذة عن الكتاب',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const Gap(8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    book.description,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.7,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],

              // Entries / Chapters list
              Obx(() {
                if (controller.isLoadingEntries.value) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: LoadingAnimationWidget.waveDots(
                        color: primaryColor,
                        size: 32,
                      ),
                    ),
                  );
                }

                if (controller.entries.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'أبواب ومداخل الموسوعة',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${controller.entries.length} مدخل',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.entries.length,
                      separatorBuilder: (_, __) => const Gap(8),
                      itemBuilder: (context, index) {
                        final entry = controller.entries[index];
                        return ZoomTapAnimation(
                          onTap: () {
                            Get.to(
                              () => EncyclopediaEntryReaderPage(
                                entryId: entry.id,
                                title: entry.title,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: theme.dividerTheme.color ?? Colors.grey.shade200,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        color: primaryColor.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                            color: primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Gap(10),
                                    Expanded(
                                      child: Text(
                                        entry.title,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                      color: theme.colorScheme.secondary.withValues(alpha: 0.7),
                                    ),
                                  ],
                                ),
                                if (entry.excerpt.isNotEmpty) ...[
                                  const Gap(8),
                                  Text(
                                    entry.excerpt.trim(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      height: 1.5,
                                      color: theme.colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              }),

              const Gap(100), // Space for bottom action bar
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        final book = controller.book.value;
        final isDownloadingDb = controller.isDownloadingDb.value;
        final dbProgress = controller.downloadDbProgress.value;
        final isDbDownloaded = controller.isDbDownloaded.value;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 52,
              child: isDownloadingDb
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'جاري تحميل داتابيز الكتاب واستخراجه...',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            Text(
                              '${(dbProgress * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const Gap(6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: dbProgress > 0 ? dbProgress : null,
                            backgroundColor: primaryColor.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        // دکمه ۱: قراءة الكتاب (قاعدة البيانات النصية SQLite)
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if (isDbDownloaded) {
                                  final dbPath = await controller.getBookDbPath();
                                  Get.to(() => BookContentReaderPage(
                                        book: controller.book.value,
                                        dbPath: dbPath,
                                      ));
                                } else {
                                  final path = await controller.startDbDownload();
                                  if (path != null) {
                                    Get.to(() => BookContentReaderPage(
                                          book: controller.book.value,
                                          dbPath: path,
                                        ));
                                  }
                                }
                              },
                              icon: Icon(
                                isDbDownloaded && book.hasStartedReading
                                    ? Icons.bookmark_added_rounded
                                    : Icons.auto_stories_rounded,
                                color: Colors.white,
                                size: 19,
                              ),
                              label: Text(
                                isDbDownloaded
                                    ? (book.hasStartedReading
                                        ? 'متابعة القراءة (ص ${book.lastReadPage})'
                                        : 'قراءة الكتاب')
                                    : 'تحميل وقراءة الكتاب',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // دکمه ۲: نسخة PDF (المشاهدة المباشرة لملف PDF)
                        const Gap(10),
                        SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Get.to(() => BookReaderPage(book: controller.book.value));
                            },
                            icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                            label: const Text(
                              'نسخة PDF',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryColor,
                              side: BorderSide(color: primaryColor, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.onPrimary;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.dividerTheme.color ?? Colors.grey.shade200,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: primaryColor),
            const Gap(4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Gap(2),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
