import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../../core/common/widgets/custom_app_bar.dart';
import '../../controller/duas_controller.dart';
import '../../data/models/dua_media_item.dart';
import '../widgets/dua_audio_card.dart';
import '../widgets/dua_video_card.dart';

class DuaCategoryItemsPage extends StatefulWidget {
  final DuaCategoryModel category;
  final bool isAudio;

  const DuaCategoryItemsPage({
    super.key,
    required this.category,
    required this.isAudio,
  });

  @override
  State<DuaCategoryItemsPage> createState() => _DuaCategoryItemsPageState();
}

class _DuaCategoryItemsPageState extends State<DuaCategoryItemsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });

    if (!widget.isAudio) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Get.find<DuasController>().loadCategoryVideosIfNeeded(widget.category.id);
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _normalize(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ي', 'ی')
        .replaceAll('ئ', 'ی')
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        .toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final controller = Get.find<DuasController>();

    final normalizedQuery = _normalize(_searchQuery);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        centerTitle: false,
        titleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.category.title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                fontFamily: 'IBMPlexSansArabic',
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              widget.isAudio ? 'الملفات الصوتية المأثورة' : 'التسجيلات المرئية المباركة',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontFamily: 'IBMPlexSansArabic',
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            children: [
              // نوار جستجو در این گروه
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withAlpha(10) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withAlpha(15)
                          : colorScheme.onPrimary.withAlpha(25),
                    ),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withAlpha(4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText: widget.isAudio
                          ? 'ابحث في ${widget.category.title}...'
                          : 'ابحث في مقاطع ${widget.category.title}...',
                      hintStyle: TextStyle(
                        fontSize: 12.5,
                        fontFamily: 'IBMPlexSansArabic',
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: colorScheme.onPrimary,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),

              // لیست یا گرید آیتم‌های این گروه با قابلیت واکنش‌گرایی به داده‌های سرور
              Expanded(
                child: Obx(() {
                  final audioItems = widget.isAudio
                      ? controller.getAudiosForCategory(widget.category.id).where((a) {
                          if (_searchQuery.isEmpty) return true;
                          return _normalize(a.title).contains(normalizedQuery) ||
                              _normalize(a.reciter).contains(normalizedQuery) ||
                              (a.text != null && _normalize(a.text!).contains(normalizedQuery));
                        }).toList()
                      : <DuaAudioItem>[];

                  final videoItems = !widget.isAudio
                      ? controller.getVideosForCategory(widget.category.id).where((v) {
                          if (_searchQuery.isEmpty) return true;
                          return _normalize(v.title).contains(normalizedQuery) ||
                              _normalize(v.reciter).contains(normalizedQuery);
                        }).toList()
                      : <DuaVideoItem>[];

                  final isEmpty = widget.isAudio ? audioItems.isEmpty : videoItems.isEmpty;

                  if (controller.isLoadingData.value && isEmpty) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.onPrimary,
                      ),
                    );
                  }

                  if (isEmpty) {
                    return RefreshIndicator(
                      onRefresh: controller.refreshData,
                      color: colorScheme.onPrimary,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 50,
                                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                                ),
                                const Gap(10),
                                Text(
                                  'لا توجد عناصر مطابقة في هذه المجموعة',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    fontFamily: 'IBMPlexSansArabic',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: controller.refreshData,
                    color: colorScheme.onPrimary,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;

                        // بخش صوت‌ها
                        if (widget.isAudio) {
                          return ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.only(bottom: 30),
                            itemCount: audioItems.length,
                            itemBuilder: (context, index) {
                              final item = audioItems[index];
                              return DuaAudioCard(
                                key: ValueKey(item.id),
                                item: item,
                              );
                            },
                          );
                        }

                        // بخش ویدیوها (ریسپانسیو بر اساس سایز نمایشگر: موبایل، تبلت، لپ‌تاپ و وب)
                        final int crossAxisCount;
                        if (width >= 1250) {
                          crossAxisCount = 4;
                        } else if (width >= 880) {
                          crossAxisCount = 3;
                        } else if (width >= 560) {
                          crossAxisCount = 2;
                        } else {
                          crossAxisCount = 1;
                        }

                        final double horizontalPadding = width >= 600 ? 20 : 16;
                        const double spacing = 14;

                        if (crossAxisCount == 1) {
                          return ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: EdgeInsets.fromLTRB(horizontalPadding, 4, horizontalPadding, 30),
                            itemCount: videoItems.length,
                            itemBuilder: (context, index) {
                              final item = videoItems[index];
                              return DuaVideoCard(
                                key: ValueKey(item.id),
                                item: item,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                              );
                            },
                          );
                        }

                        // محاسبه دقیق نسبت ابعاد بر اساس نسبت ۱۶:۹ تصویر و ارتفاع بخش اطلاعات
                        final double itemWidth = (width -
                                (horizontalPadding * 2) -
                                ((crossAxisCount - 1) * spacing)) /
                            crossAxisCount;
                        final double itemHeight = (itemWidth * 9 / 16) + 72;
                        final double childAspectRatio = (itemWidth / itemHeight).clamp(0.8, 2.0);

                        return GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: EdgeInsets.fromLTRB(horizontalPadding, 6, horizontalPadding, 30),
                          itemCount: videoItems.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: spacing,
                            mainAxisSpacing: spacing,
                            childAspectRatio: childAspectRatio,
                          ),
                          itemBuilder: (context, index) {
                            final item = videoItems[index];
                            return DuaVideoCard(
                              key: ValueKey(item.id),
                              item: item,
                              margin: EdgeInsets.zero,
                            );
                          },
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
