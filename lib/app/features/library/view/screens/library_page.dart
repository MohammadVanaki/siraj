import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mawsueat/app/features/library/controller/library_controller.dart';
import 'package:mawsueat/app/features/library/view/screens/encyclopedia_entry_reader_page.dart';
import 'package:mawsueat/app/features/library/view/widgets/book_card_widget.dart';
import 'package:mawsueat/app/features/library/view/widgets/bookmarked_page_card_widget.dart';
import 'package:mawsueat/app/features/library/view/widgets/continue_reading_card_widget.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class LibraryPage extends GetView<LibraryController> {
  const LibraryPage({super.key});

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
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'المكتبة الإسلامية',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshLibrary,
        color: primaryColor,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Top Tab Switcher: [المكتبة العامة] vs [الكتب المحملة] vs [المفضلة]
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.dividerTheme.color ?? Colors.grey.shade200,
                    ),
                  ),
                  child: Obx(() {
                    final selectedTab = controller.selectedTab.value;
                    final downloadedCount = controller.downloadedBooks.length;
                    final favBooksCount = controller.favoriteBooks.length;
                    final bookmarksCount = controller.bookmarkedPages.length;
                    final totalFavCount = favBooksCount + bookmarksCount;

                    return Row(
                      children: [
                        // تب ۱: المكتبة العامة
                        Expanded(
                          child: ZoomTapAnimation(
                            onTap: () => controller.switchTab(0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: selectedTab == 0
                                    ? primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.library_books_rounded,
                                      size: 16,
                                      color: selectedTab == 0
                                          ? Colors.white
                                          : theme.colorScheme.onSurface,
                                    ),
                                    const Gap(4),
                                    Text(
                                      'المكتبة العامة',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: selectedTab == 0
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: selectedTab == 0
                                            ? Colors.white
                                            : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // تب ۲: الكتب المحملة
                        Expanded(
                          child: ZoomTapAnimation(
                            onTap: () => controller.switchTab(1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: selectedTab == 1
                                    ? primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.download_done_rounded,
                                      size: 16,
                                      color: selectedTab == 1
                                          ? Colors.white
                                          : theme.colorScheme.onSurface,
                                    ),
                                    const Gap(4),
                                    Text(
                                      'المحملة ($downloadedCount)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: selectedTab == 1
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: selectedTab == 1
                                            ? Colors.white
                                            : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // تب ۳: المفضلة
                        Expanded(
                          child: ZoomTapAnimation(
                            onTap: () => controller.switchTab(2),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: selectedTab == 2
                                    ? primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.favorite_rounded,
                                      size: 16,
                                      color: selectedTab == 2
                                          ? Colors.white
                                          : theme.colorScheme.onSurface,
                                    ),
                                    const Gap(4),
                                    Text(
                                      totalFavCount > 0
                                          ? 'المفضلة ($totalFavCount)'
                                          : 'المفضلة',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: selectedTab == 2
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: selectedTab == 2
                                            ? Colors.white
                                            : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),

            // Favorites Sub-Segment Pill Switcher (الكتب المفضلة vs الصفحات المحفوظة)
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.selectedTab.value != 2) {
                  return const SizedBox.shrink();
                }

                final subTab = controller.selectedFavSubTab.value;
                final favBooksCount = controller.favoriteBooks.length;
                final bookmarksCount = controller.bookmarkedPages.length;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.dividerTheme.color ?? Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ZoomTapAnimation(
                            onTap: () => controller.switchFavSubTab(0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              decoration: BoxDecoration(
                                color: subTab == 0
                                    ? primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.favorite_rounded,
                                      size: 15,
                                      color: subTab == 0
                                          ? Colors.white
                                          : theme.colorScheme.onSurface,
                                    ),
                                    const Gap(6),
                                    Text(
                                      'الكتب المفضلة ($favBooksCount)',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: subTab == 0
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: subTab == 0
                                            ? Colors.white
                                            : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ZoomTapAnimation(
                            onTap: () => controller.switchFavSubTab(1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              decoration: BoxDecoration(
                                color: subTab == 1
                                    ? primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.bookmark_rounded,
                                      size: 15,
                                      color: subTab == 1
                                          ? Colors.white
                                          : theme.colorScheme.onSurface,
                                    ),
                                    const Gap(6),
                                    Text(
                                      'الصفحات المحفوظة ($bookmarksCount)',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: subTab == 1
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: subTab == 1
                                            ? Colors.white
                                            : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),

            // Search Input Bar (Shown for Tab 0 & Tab 1)
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.selectedTab.value == 2) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color:
                            theme.dividerTheme.color ?? Colors.grey.shade200,
                      ),
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: controller.onSearch,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن اسم الكتاب، المؤلف، الموضوع...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.secondary,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: primaryColor,
                          size: 22,
                        ),
                        suffixIcon: Obx(
                          () => controller.searchQuery.value.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                  ),
                                  onPressed: controller.clearSearch,
                                )
                              : const SizedBox.shrink(),
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                );
              }),
            ),

            // Categories horizontal list (Only for Tab 0: General Library)
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.selectedTab.value != 0 ||
                    controller.categories.isEmpty) {
                  return const SizedBox.shrink();
                }

                return SizedBox(
                  height: 42,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.categories.length,
                    separatorBuilder: (_, __) => const Gap(8),
                    itemBuilder: (context, index) {
                      final cat = controller.categories[index];

                      return Obx(() {
                        final isSelected =
                            controller.selectedCategoryId.value == cat.id;

                        return ZoomTapAnimation(
                          onTap: () => controller.selectCategory(cat.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor
                                  : theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : (theme.dividerTheme.color ??
                                        Colors.grey.shade200),
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: primaryColor.withValues(
                                          alpha: 0.25,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                cat.title,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        );
                      });
                    },
                  ),
                );
              }),
            ),

            // Continue Reading Section ("واصل القراءة" - only for Tab 0 & Tab 1)
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.selectedTab.value == 2 ||
                    controller.continueReadingBooks.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.history_rounded,
                                size: 20,
                                color: primaryColor,
                              ),
                              const Gap(6),
                              Text(
                                'واصل القراءة',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${controller.continueReadingBooks.length} كتب',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(10),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.continueReadingBooks.length,
                        itemBuilder: (context, index) {
                          final book = controller.continueReadingBooks[index];
                          return ContinueReadingCardWidget(book: book);
                        },
                      ),
                    ),
                    const Gap(12),
                  ],
                );
              }),
            ),

            const SliverToBoxAdapter(child: Gap(8)),

            // Section Header Title
            SliverToBoxAdapter(
              child: Obx(() {
                final tab = controller.selectedTab.value;
                String title;
                String countText;

                if (tab == 2) {
                  final isSubBooks = controller.selectedFavSubTab.value == 0;
                  title = isSubBooks
                      ? 'الكتب المفضلة'
                      : 'الصفحات والعلامات المحفوظة';
                  countText = isSubBooks
                      ? '${controller.favoriteBooks.length} كتاب'
                      : '${controller.bookmarkedPages.length} صفحة';
                } else if (tab == 1) {
                  title = 'الكتب المحملة على جهازك';
                  countText = '${controller.downloadedBooks.length} كتاب محمل';
                } else {
                  title = 'قائمة الكتب';
                  countText = '${controller.books.length} كتاب';
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        countText,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

            const SliverToBoxAdapter(child: Gap(8)),

            // Content Slivers
            Obx(() {
              if (controller.isLoading.value ||
                  controller.isBooksLoading.value) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: primaryColor,
                      size: 40,
                    ),
                  ),
                );
              }

              final tab = controller.selectedTab.value;

              // ==================== تب المفضلة (TAB 2) ====================
              if (tab == 2) {
                final isSubBooks = controller.selectedFavSubTab.value == 0;

                // حالت ۱: تب فرعی کتاب‌های مفضله
                if (isSubBooks) {
                  final favBooks = controller.favoriteBooks;
                  if (favBooks.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite_border_rounded,
                                size: 64,
                                color: theme.colorScheme.secondary.withValues(
                                  alpha: 0.45,
                                ),
                              ),
                              const Gap(14),
                              Text(
                                'لا توجد كتب مضافة إلى المفضلة بعد',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const Gap(8),
                              Text(
                                'يمكنك إضافة أي كتاب إلى المفضلة بالضغط على أيقونة القلب على غلاف الكتاب أو في صفحة تفاصيله.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.secondary,
                                  height: 1.6,
                                ),
                              ),
                              const Gap(20),
                              ElevatedButton.icon(
                                onPressed: () => controller.switchTab(0),
                                icon: const Icon(
                                  Icons.library_books_rounded,
                                  size: 18,
                                ),
                                label: const Text('استكشاف المكتبة العامة'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final book = favBooks[index];
                          return BookCardWidget(book: book);
                        },
                        childCount: favBooks.length,
                      ),
                    ),
                  );
                }

                // حالت ۲: تب فرعی صفحات و علامات مرجعی
                final bookmarks = controller.bookmarkedPages;
                if (bookmarks.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bookmark_border_rounded,
                              size: 64,
                              color: theme.colorScheme.secondary.withValues(
                                alpha: 0.45,
                              ),
                            ),
                            const Gap(14),
                            Text(
                              'لا توجد صفحات محفوظة بعد',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const Gap(8),
                            Text(
                              'أثناء قراءة أي كتاب، اضغط على أيقونة الإشارة المرجعية لحفظ الصفحة والرجوع إليها مباشرة من هنا.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.secondary,
                                height: 1.6,
                              ),
                            ),
                            const Gap(20),
                            ElevatedButton.icon(
                              onPressed: () => controller.switchTab(0),
                              icon: const Icon(
                                Icons.auto_stories_rounded,
                                size: 18,
                              ),
                              label: const Text('بدء القراءة الآن'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final bookmark = bookmarks[index];
                        return BookmarkedPageCardWidget(bookmark: bookmark);
                      },
                      childCount: bookmarks.length,
                    ),
                  ),
                );
              }

              // ==================== تب‌های ۱ و ۰ (المكتبة العامة / المحملة) ====================
              final isSearching =
                  controller.searchQuery.value.trim().isNotEmpty;
              final hasSearchedEntries =
                  controller.searchedEntries.isNotEmpty;

              final isTabDownloaded = tab == 1;
              final displayList = isTabDownloaded
                  ? controller.downloadedBooks
                  : controller.books;

              if (displayList.isEmpty && !hasSearchedEntries) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isTabDownloaded
                              ? Icons.download_for_offline_outlined
                              : Icons.menu_book_rounded,
                          size: 60,
                          color: theme.colorScheme.secondary.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const Gap(12),
                        Text(
                          isTabDownloaded
                              ? 'لم تقم بتحميل أي كتاب بعد\nيمكنك تحميل الكتب من المكتبة العامة لقراءتها دون إنترنت'
                              : 'لا توجد نتائج مطابقة لبحثك',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: theme.colorScheme.secondary,
                            height: 1.6,
                          ),
                        ),
                        if (isTabDownloaded) ...[
                          const Gap(16),
                          ElevatedButton.icon(
                            onPressed: () => controller.switchTab(0),
                            icon: const Icon(Icons.explore_rounded, size: 18),
                            label: const Text('استكشاف المكتبة العامة'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }

              return SliverMainAxisGroup(
                slivers: [
                  // 1. Matching Books
                  if (displayList.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final book = displayList[index];
                            return BookCardWidget(book: book);
                          },
                          childCount: displayList.length,
                        ),
                      ),
                    ),

                  // 2. Matching Entries / Articles (if searching)
                  if (isSearching && hasSearchedEntries) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'نتائج البحث في المداخل والموضوعات',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${controller.searchedEntries.length} نتيجة',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final entry = controller.searchedEntries[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ZoomTapAnimation(
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
                                      color:
                                          theme.dividerTheme.color ??
                                          Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 26,
                                            height: 26,
                                            decoration: BoxDecoration(
                                              color: primaryColor
                                                  .withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${index + 1}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.bold,
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
                                                fontWeight:
                                                    FontWeight.bold,
                                                color: theme
                                                    .colorScheme.onSurface,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons
                                                .arrow_forward_ios_rounded,
                                            size: 14,
                                            color: theme
                                                .colorScheme.secondary
                                                .withValues(alpha: 0.7),
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
                                            color: theme
                                                .colorScheme.secondary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: controller.searchedEntries.length,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            }),

            const SliverToBoxAdapter(child: Gap(24)),
          ],
        ),
      ),
    );
  }
}
