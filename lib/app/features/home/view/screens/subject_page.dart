import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/config/status.dart';
import 'package:mawsueat/app/core/common/widgets/custom_loading.dart';
import 'package:mawsueat/app/features/favorite%20&%20comment/view/controller/favorite_controller.dart';
import 'package:mawsueat/app/features/home/repository/modal_comment.dart';
import 'package:mawsueat/app/features/home/view/controller/content_controller.dart';
import 'package:mawsueat/app/features/home/view/screens/content_page.dart';
import 'package:mawsueat/app/features/setting/view/controller/settings_controller.dart';
import 'package:share_plus/share_plus.dart';

abstract class SubjectListItem {}

class GroupHeaderItem extends SubjectListItem {
  final int bookId;
  final String groupTitle;
  final Map<String, dynamic> groupData;
  final int subItemsCount;
  final bool isExpanded;
  final bool hasSubItems;

  GroupHeaderItem({
    required this.bookId,
    required this.groupTitle,
    required this.groupData,
    required this.subItemsCount,
    required this.isExpanded,
    required this.hasSubItems,
  });
}

class SubTopicItem extends SubjectListItem {
  final int bookId;
  final String groupTitle;
  final int textId;
  final int index;
  final int pageNumber;
  final String subTitle;
  final String rawText;
  final bool isLastInGroup;

  SubTopicItem({
    required this.bookId,
    required this.groupTitle,
    required this.textId,
    required this.index,
    required this.pageNumber,
    required this.subTitle,
    required this.rawText,
    required this.isLastInGroup,
  });
}

class GroupLoadingItem extends SubjectListItem {
  final int bookId;
  GroupLoadingItem({required this.bookId});
}

class SubjectPage extends StatefulWidget {
  const SubjectPage({super.key});

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final ContentController contentController = Get.find<ContentController>();
    _searchController = TextEditingController(
      text: contentController.searchQuery.value,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ContentController contentController = Get.find<ContentController>();

    return Obx(() {
      final filteredList = contentController.filteredGroups;
      final query = contentController.searchQuery.value;
      final expandedGroupIds = contentController.expandedGroupIds;
      final SearchScope scope = contentController.searchScope.value;

      final List<SubjectListItem> items = [];
      for (final group in filteredList) {
        final int bookId = group["id"] is int
            ? group["id"]
            : (int.tryParse(group["id"]?.toString() ?? '1') ?? 1);
        final String groupTitle = (group["title"] ?? '')
            .replaceAll('&nbsp;', ' ')
            .trim();

        final subItems = contentController.getSubItemsForBook(bookId);
        final bool isExp = expandedGroupIds.contains(bookId);
        final int totalEntriesCount = group['entriesCount'] is int
            ? group['entriesCount']
            : (int.tryParse(group['entriesCount']?.toString() ?? '') ?? subItems.length);
        final bool hasSubItems = totalEntriesCount > 0 || subItems.isNotEmpty;
        final bool isBookLoading = contentController.isBookLoading(bookId);

        items.add(
          GroupHeaderItem(
            bookId: bookId,
            groupTitle: groupTitle,
            groupData: group,
            subItemsCount: totalEntriesCount,
            isExpanded: isExp,
            hasSubItems: hasSubItems,
          ),
        );

        if (isExp) {
          if (isBookLoading && subItems.isEmpty) {
            items.add(GroupLoadingItem(bookId: bookId));
          } else {
            for (int i = 0; i < subItems.length; i++) {
              final subItem = subItems[i];
              final subTitle = (subItem["title"] ?? '')
                  .toString()
                  .replaceAll('&nbsp;', ' ')
                  .trim();
              final int textId = subItem['id'] is int
                  ? subItem['id']
                  : (int.tryParse(subItem['id']?.toString() ?? '0') ?? 0);
              final int pageNumber = (subItem['_pageIndex'] is int)
                  ? subItem['_pageIndex']
                  : i;
              final rawText = (subItem["_text"] ?? subItem["text"] ?? subItem["excerpt"] ?? '')
                  .toString();

              items.add(
                SubTopicItem(
                  bookId: bookId,
                  groupTitle: groupTitle,
                  textId: textId,
                  index: i + 1,
                  pageNumber: pageNumber,
                  subTitle: subTitle,
                  rawText: rawText,
                  isLastInGroup: i == subItems.length - 1,
                ),
              );
            }
          }
        }
      }

      return Column(
        children: [
          // 🔍 فیلد جستجو جمع‌وجور به همراه دراپ‌داون انتخاب دامنه جستجو درون خود فیلد
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: SizedBox(
              height: 42,
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onChanged: (value) {
                  contentController.updateSearchQuery(value);
                },
                onSubmitted: (value) {
                  contentController.updateSearchQuery(value);
                },
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: scope == SearchScope.titles
                      ? 'بحث في العناوین والأبواب...'
                      : 'بحث في نصوص ومحتوى الکتب...',
                  hintStyle: const TextStyle(
                    color: Colors.black38,
                    fontSize: 13,
                  ),
                  prefixIcon: PopupMenuButton<SearchScope>(
                    initialValue: scope,
                    tooltip: 'نطاق البحث',
                    offset: const Offset(0, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (SearchScope newScope) {
                      contentController.searchScope.value = newScope;
                      contentController.updateSearchQuery(_searchController.text);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: SearchScope.titles,
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Icon(
                              Icons.title_rounded,
                              size: 18,
                              color: scope == SearchScope.titles
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Colors.black54,
                            ),
                            const Gap(8),
                            Text(
                              'في العناوين',
                              style: TextStyle(
                                fontFamily: 'IBMPlexSansArabic',
                                fontSize: 13,
                                fontWeight: scope == SearchScope.titles
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: scope == SearchScope.titles
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: SearchScope.content,
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Icon(
                              Icons.article_outlined,
                              size: 18,
                              color: scope == SearchScope.content
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Colors.black54,
                            ),
                            const Gap(8),
                            Text(
                              'في النصوص',
                              style: TextStyle(
                                fontFamily: 'IBMPlexSansArabic',
                                fontSize: 13,
                                fontWeight: scope == SearchScope.content
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: scope == SearchScope.content
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            scope == SearchScope.titles
                                ? Icons.title_rounded
                                : Icons.article_outlined,
                            size: 16,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          const Gap(4),
                          Text(
                            scope == SearchScope.titles ? 'العناوين' : 'النصوص',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontFamily: 'IBMPlexSansArabic',
                            ),
                          ),
                          const Gap(2),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          const Gap(6),
                          Container(
                            height: 18,
                            width: 1,
                            color: Colors.black12,
                          ),
                          const Gap(4),
                        ],
                      ),
                    ),
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (query.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          tooltip: 'مسح',
                          onPressed: () {
                            _searchController.clear();
                            contentController.updateSearchQuery('');
                          },
                        ),
                      IconButton(
                        icon: Icon(
                          Icons.search_rounded,
                          size: 22,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        tooltip: 'بحث',
                        onPressed: () {
                          contentController.updateSearchQuery(
                            _searchController.text,
                          );
                        },
                      ),
                      const Gap(4),
                    ],
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.black26,
                      width: 0.8,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.black26,
                      width: 0.8,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onPrimary,
                      width: 1.5,
                    ),
                  ),
                ),
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ),

          // 🧾 لیست گروه‌ها و موضوعات به صورت مجازی و فوق‌العاده سریع
          Expanded(
            child: contentController.status.value == Status.loading &&
                    filteredList.isEmpty
                ? Center(
                    child: CustomLoading(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                : items.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد نتائج مطابقة',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'IBMPlexSansArabic',
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          if (item is GroupHeaderItem) {
                            return _buildGroupHeader(
                              context,
                              item,
                              query,
                              contentController,
                            );
                          } else if (item is SubTopicItem) {
                            return _buildSubTopicRow(
                              context,
                              item,
                              query,
                              contentController,
                            );
                          } else if (item is GroupLoadingItem) {
                            return _buildGroupLoadingRow(context);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
          ),
        ],
      );
    });
  }

  Widget _buildGroupLoadingRow(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      child: Center(
        child: CustomLoading(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildGroupHeader(
    BuildContext context,
    GroupHeaderItem item,
    String query,
    ContentController contentController,
  ) {
    final bool isExp = item.isExpanded;
    final bool hasSubItems = item.hasSubItems;

    return Container(
      margin: EdgeInsets.only(top: 8, bottom: isExp && hasSubItems ? 0 : 8),
      decoration: BoxDecoration(
        color: isExp && hasSubItems
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.primary.withOpacity(0.88),
        borderRadius: isExp && hasSubItems
            ? const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              )
            : BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: isExp && hasSubItems
            ? const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              )
            : BorderRadius.circular(14),
        child: InkWell(
          borderRadius: isExp && hasSubItems
              ? const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                )
              : BorderRadius.circular(14),
          onTap: () {
            if (hasSubItems) {
              contentController.toggleGroupExpansion(item.bookId);
            } else {
              _navigateToContentPage(
                context: context,
                bookId: item.bookId,
                bookTitle: item.groupTitle,
                textId: null,
                contentController: contentController,
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(
                  Icons.auto_stories_rounded,
                  size: 22,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const Gap(10),
                Expanded(
                  child: _buildHighlightedText(
                    item.groupTitle,
                    query,
                    isMain: true,
                  ),
                ),
                if (hasSubItems) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${item.subItemsCount}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Gap(6),
                  AnimatedRotation(
                    turns: isExp ? -0.25 : 0.0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      Icons.keyboard_arrow_left_rounded,
                      size: 22,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubTopicRow(
    BuildContext context,
    SubTopicItem item,
    String query,
    ContentController contentController,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: item.isLastInGroup ? 8 : 0),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: item.isLastInGroup
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              )
            : BorderRadius.zero,
        boxShadow: item.isLastInGroup
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          SubItemAccordionWidget(
            key: ValueKey('subitem_${item.textId}'),
            bookId: item.bookId,
            groupTitle: item.groupTitle,
            textId: item.textId,
            index: item.index,
            pageNumber: item.pageNumber,
            subTitle: item.subTitle,
            rawText: item.rawText,
            searchQuery: query,
            onOpenFull: () {
              _navigateToContentPage(
                context: context,
                bookId: item.bookId,
                bookTitle: item.groupTitle,
                textId: item.textId,
                contentController: contentController,
              );
            },
          ),
          if (!item.isLastInGroup)
            const Divider(height: 1, thickness: 0.6, color: Colors.black12),
        ],
      ),
    );
  }

  void _navigateToContentPage({
    required BuildContext context,
    required int bookId,
    required String bookTitle,
    required int? textId,
    required ContentController contentController,
  }) async {
    await contentController.preparePagesForBook(bookId, targetEntryId: textId);
    double targetScroll = 0.0;
    if (textId != null) {
      final pageIndex = contentController.pages.indexWhere(
        (p) => (p['id'] == textId || p['id'].toString() == textId.toString()),
      );
      targetScroll = pageIndex >= 0 ? pageIndex.toDouble() : 0.0;
    }

    contentController.scrollPosetion.value = targetScroll;

    Get.to(
      () => ContentPage(
        bookId: bookId,
        bookName: bookTitle,
        scrollPosetion: targetScroll,
        searchWord: contentController.searchQuery.value,
      ),
    );
  }
}

/// 📝 ویجت واکنش‌گرای آکاردئونی هر زیرمجموعه و متن آن
class SubItemAccordionWidget extends StatelessWidget {
  final int bookId;
  final String groupTitle;
  final int textId;
  final int index;
  final int pageNumber;
  final String subTitle;
  final String rawText;
  final String searchQuery;
  final VoidCallback onOpenFull;

  const SubItemAccordionWidget({
    super.key,
    required this.bookId,
    required this.groupTitle,
    required this.textId,
    required this.index,
    required this.pageNumber,
    required this.subTitle,
    required this.rawText,
    required this.searchQuery,
    required this.onOpenFull,
  });

  @override
  Widget build(BuildContext context) {
    final ContentController contentController = Get.find<ContentController>();
    final FavoriteController favoriteController =
        Get.isRegistered<FavoriteController>()
        ? Get.find<FavoriteController>()
        : Get.put(FavoriteController());

    return Obx(() {
      final String query = contentController.searchQuery.value;
      final SearchScope scope = contentController.searchScope.value;
      final bool isSubExpanded = contentController.isSubItemExpanded(textId);
      final bool isSaved = favoriteController.isBookmarked(bookId, pageNumber);
      final bool hasComment = favoriteController.hasComment(bookId, pageNumber);
      final String fullOrExcerpt = contentController.fullTextsCache[textId] ?? rawText;
      final String cleanText = isSubExpanded ? cleanHtmlContent(fullOrExcerpt) : '';
      final bool isDetailLoading = contentController.isEntryDetailLoading(textId);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(vertical: 3),
        decoration: BoxDecoration(
          color: isSubExpanded ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSubExpanded
              ? Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimary.withOpacity(0.2),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // سربرگ زیرمجموعه
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  contentController.toggleSubItemExpansion(textId, bookId: bookId);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 8,
                  ),
                  child: Row(
                    children: [
                      // 🔘 آیکون دایره برای زیرمجموعه
                      Icon(
                        Icons.circle,
                        size: 9,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      const Gap(8),
                      Expanded(
                        child: _buildHighlightedText(
                          subTitle.isNotEmpty ? subTitle : 'موضوع $index',
                          query,
                          isMain: false,
                          maxLines: isSubExpanded ? null : 1,
                          overflow: isSubExpanded
                              ? null
                              : TextOverflow.ellipsis,
                        ),
                      ),
                      const Gap(8),
                      // 🔖 نمایش آیکون در صورت بوک‌مارک بودن
                      if (isSaved)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.bookmark_rounded,
                            size: 18,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      // 💬 نمایش آیکون در صورت داشتن یادداشت/تعلیق
                      if (hasComment)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.comment_rounded,
                            size: 16,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$index',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Gap(6),
                      AnimatedRotation(
                        turns: isSubExpanded ? -0.25 : 0.0,
                        duration: const Duration(milliseconds: 180),
                        child: const Icon(
                          Icons.keyboard_arrow_left_rounded,
                          size: 20,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 📖 متن نمایش‌داده‌شده هنگام کلیک و کلاپس (_text) - محاسبه سبک و تنبل
            if (isSubExpanded) ...[
              Builder(
                builder: (context) {
                  final SettingsController settingsController =
                      Get.isRegistered<SettingsController>()
                      ? Get.find<SettingsController>()
                      : Get.put(SettingsController());

                  String currentFont = 'dijlah';
                  switch (settingsController.fontFamily.value) {
                    case 'لوتوس':
                      currentFont = 'lotus';
                      break;
                    case 'البهيج':
                      currentFont = 'bahij';
                      break;
                    case 'دجلة':
                    default:
                      currentFont = 'dijlah';
                  }

                  return Obx(() {
                    final bgColor = settingsController.backgroundColor.value;
                    final currentFontSize = settingsController.fontSize.value;
                    final currentLineHeight =
                        settingsController.lineHeight.value;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      margin: const EdgeInsets.only(
                        left: 6,
                        right: 6,
                        bottom: 8,
                      ),
                      decoration: BoxDecoration(
                        color: bgColor == Colors.white
                            ? Colors.grey.shade50
                            : bgColor.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.06),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (isDetailLoading) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                minHeight: 2,
                                color: Theme.of(context).colorScheme.onPrimary,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .onPrimary
                                    .withOpacity(0.15),
                              ),
                            ),
                            const Gap(8),
                          ],
                          SelectableText.rich(
                            TextSpan(
                              children: _buildHighlightedSpans(
                                cleanText.isNotEmpty
                                    ? cleanText
                                    : 'لا يوجد نص متاح لهذا الموضوع.',
                                query,
                                TextStyle(
                                  fontFamily: currentFont,
                                  fontSize: currentFontSize,
                                  height: currentLineHeight,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            textAlign: TextAlign.justify,
                            textDirection: TextDirection.rtl,
                          ),
                          const Gap(12),
                          const Divider(height: 1, thickness: 0.5),
                          const Gap(8),
                          // تولبار عملیات متن
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // دکمه کپی متن
                              TextButton.icon(
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(
                                      text: '$subTitle\n\n$cleanText',
                                    ),
                                  );
                                  ScaffoldMessenger.of(
                                    context,
                                  ).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'تم نسخ النص بنجاح إلى الحافظة',
                                        style: TextStyle(fontFamily: 'IBMPlexSansArabic'),
                                        textDirection: TextDirection.rtl,
                                      ),
                                      duration: const Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy, size: 16),
                                label: const Text(
                                  'نسخ',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black54,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                              ),
                              // دکمه اشتراک‌گذاری
                              TextButton.icon(
                                onPressed: () {
                                  Share.share('$subTitle\n\n$cleanText');
                                },
                                icon: const Icon(Icons.share, size: 16),
                                label: const Text(
                                  'مشاركة',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black54,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                              ),
                              // دکمه افزودن / مشاهده تعلیق (کامنت)
                              TextButton.icon(
                                onPressed: () {
                                  final commentData = favoriteController
                                      .getComment(bookId, pageNumber);
                                  ModalComment.show(
                                    context,
                                    idBook: bookId,
                                    bookname: subTitle.isNotEmpty
                                        ? '$groupTitle - $subTitle'
                                        : groupTitle,
                                    idPage: pageNumber + 1,
                                    updateMode: commentData != null,
                                    id: commentData?['id'] is int
                                        ? commentData!['id']
                                        : (int.tryParse(
                                                commentData?['id']
                                                        ?.toString() ??
                                                    '0',
                                              ) ??
                                              0),
                                    oldTitle: commentData?['title'] ?? subTitle,
                                    oldComment: commentData?['comment'],
                                  );
                                },
                                icon: Icon(
                                  hasComment
                                      ? Icons.comment_rounded
                                      : Icons.comment_outlined,
                                  size: 16,
                                  color: hasComment
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Colors.black54,
                                ),
                                label: Text(
                                  hasComment ? 'معلّق' : 'تعليق',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: hasComment
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onPrimary
                                        : Colors.black54,
                                    fontWeight: hasComment
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: hasComment
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Colors.black54,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // دکمه نشانه‌گذاری / إشارة مرجعية
                              TextButton.icon(
                                onPressed: () {
                                  final String bookmarkTitle =
                                      subTitle.isNotEmpty
                                      ? '$groupTitle - $subTitle'
                                      : groupTitle;

                                  final bool added = favoriteController
                                      .toggleBookmark(
                                        bookId: bookId,
                                        pageNumber: pageNumber,
                                        bookName: bookmarkTitle,
                                      );

                                  ScaffoldMessenger.of(
                                    context,
                                  ).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        added
                                            ? 'تم حفظ "$subTitle" في الإشارات المرجعية'
                                            : 'تم حذف "$subTitle" من الإشارات المرجعية',
                                        style: const TextStyle(
                                          fontFamily: 'IBMPlexSansArabic',
                                        ),
                                        textDirection: TextDirection.rtl,
                                      ),
                                      duration: const Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  isSaved
                                      ? Icons.bookmark
                                      : Icons.bookmark_border_rounded,
                                  size: 16,
                                  color: isSaved
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Colors.black54,
                                ),
                                label: Text(
                                  isSaved ? 'محفوظ' : 'إشارة',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSaved
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onPrimary
                                        : Colors.black54,
                                    fontWeight: isSaved
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: isSaved
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Colors.black54,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                              ),
                              const Gap(4),
                            ],
                          ),
                        ],
                      ),
                    );
                  });
                },
              ),
            ],
          ],
        ),
      );
    });
  }
}

/// تمیزکاری تگ‌های HTML و آماده‌سازی متن
String cleanHtmlContent(String raw) {
  if (raw.isEmpty) return '';
  String text = raw;
  // تبدیل تگ‌های شکست خط به newline
  text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
  text = text.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n');
  text = text.replaceAll(RegExp(r'</div>', caseSensitive: false), '\n');
  // حذف سایر تگ‌های HTML
  text = text.replaceAll(RegExp(r'<[^>]*>'), '');
  // تبدیل Entityهای وب
  text = text.replaceAll('&nbsp;', ' ');
  text = text.replaceAll('&quot;', '"');
  text = text.replaceAll('&amp;', '&');
  text = text.replaceAll('&lt;', '<');
  text = text.replaceAll('&gt;', '>');
  text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return text.trim();
}

class _NormalizedString {
  final String text;
  final List<int> originalIndices;

  _NormalizedString(this.text, this.originalIndices);
}

_NormalizedString _normalizeWithMapping(String raw) {
  final buffer = StringBuffer();
  final indices = <int>[];
  final diacriticRegex = RegExp(
    r'[\u064B-\u065F\u0670\u0640\u06D6-\u06ED\u200C\u200D\u200E\u200F\uFEFF]',
  );

  for (int i = 0; i < raw.length; i++) {
    final char = raw[i];
    if (diacriticRegex.hasMatch(char)) {
      continue;
    }

    String mappedChar = char;
    if ('أإآٱٵٲ'.contains(char)) {
      mappedChar = 'ا';
    } else if ('ىیئؽؾؿػؼۍېي'.contains(char)) {
      mappedChar = 'ي';
    } else if (char == 'ک' || char == 'ك') {
      mappedChar = 'ك';
    } else if ('ؤۇۆۉۊۋ'.contains(char)) {
      mappedChar = 'و';
    } else if ('ةۃۂە'.contains(char)) {
      mappedChar = 'ه';
    }

    buffer.write(mappedChar.toLowerCase());
    indices.add(i);
  }

  return _NormalizedString(buffer.toString(), indices);
}

List<TextSpan> _buildHighlightedSpans(
  String text,
  String query,
  TextStyle baseStyle, {
  Color highlightColor = const Color(0xFFFFD54F),
  Color highlightTextColor = Colors.black,
}) {
  if (query.trim().isEmpty || text.isEmpty) {
    return [TextSpan(text: text, style: baseStyle)];
  }

  final ContentController contentController = Get.find<ContentController>();
  final queryTokens = query
      .trim()
      .split(RegExp(r'\s+'))
      .map((s) => contentController.normalizeArabic(s))
      .where((s) => s.isNotEmpty)
      .toSet()
      .toList();

  if (queryTokens.isEmpty) {
    return [TextSpan(text: text, style: baseStyle)];
  }

  final normalizedData = _normalizeWithMapping(text);
  final normText = normalizedData.text;
  final origIndices = normalizedData.originalIndices;

  if (origIndices.isEmpty) {
    return [TextSpan(text: text, style: baseStyle)];
  }

  // جمع‌آوری تمامی محدوده‌های تطابق (start, end) در متن اصلی
  final List<List<int>> rawMatches = [];

  for (final token in queryTokens) {
    if (token.isEmpty) continue;
    int searchIdx = 0;
    while (searchIdx < normText.length) {
      final matchStartInNorm = normText.indexOf(token, searchIdx);
      if (matchStartInNorm == -1) break;

      final matchEndInNorm = matchStartInNorm + token.length - 1;
      if (matchEndInNorm < origIndices.length) {
        final rawStart = origIndices[matchStartInNorm];
        int rawEnd = origIndices[matchEndInNorm] + 1;
        // گسترش برای دربرگرفتن اعراب/تطویل چسبیده به انتهای کلمه
        while (rawEnd < text.length &&
            RegExp(r'[\u064B-\u065F\u0670\u0640\u06D6-\u06ED]').hasMatch(text[rawEnd])) {
          rawEnd++;
        }
        if (rawEnd > rawStart) {
          rawMatches.add([rawStart, rawEnd]);
        }
      }
      searchIdx = matchStartInNorm + 1;
    }
  }

  if (rawMatches.isEmpty) {
    return [TextSpan(text: text, style: baseStyle)];
  }

  // مرتب‌سازی و ادغام محدوده‌های هم‌پوشان (Interval Merging)
  rawMatches.sort((a, b) => a[0].compareTo(b[0]));
  final List<List<int>> mergedMatches = [];
  for (final match in rawMatches) {
    if (mergedMatches.isEmpty) {
      mergedMatches.add(List.from(match));
    } else {
      final last = mergedMatches.last;
      if (match[0] <= last[1]) {
        if (match[1] > last[1]) {
          last[1] = match[1];
        }
      } else {
        mergedMatches.add(List.from(match));
      }
    }
  }

  final List<TextSpan> spans = [];
  int currentRawIndex = 0;

  for (final range in mergedMatches) {
    final start = range[0];
    final end = range[1];

    if (start > currentRawIndex) {
      spans.add(
        TextSpan(
          text: text.substring(currentRawIndex, start),
          style: baseStyle,
        ),
      );
    }

    spans.add(
      TextSpan(
        text: text.substring(start, end),
        style: baseStyle.copyWith(
          backgroundColor: highlightColor,
          color: highlightTextColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    currentRawIndex = end;
  }

  if (currentRawIndex < text.length) {
    spans.add(
      TextSpan(
        text: text.substring(currentRawIndex),
        style: baseStyle,
      ),
    );
  }

  return spans;
}

Widget _buildHighlightedText(
  String text,
  String query, {
  bool isMain = true,
  int? maxLines,
  TextOverflow? overflow,
}) {
  final baseStyle = TextStyle(
    fontSize: isMain ? 14 : 13,
    color: isMain ? Colors.black : Colors.black87,
    fontFamily: 'IBMPlexSansArabic',
    fontWeight: isMain ? FontWeight.w600 : FontWeight.normal,
  );

  if (query.isEmpty) {
    return Text(text, style: baseStyle, maxLines: maxLines, overflow: overflow);
  }

  final spans = _buildHighlightedSpans(text, query, baseStyle);
  return RichText(
    text: TextSpan(style: baseStyle, children: spans),
    maxLines: maxLines,
    overflow: overflow ?? TextOverflow.clip,
  );
}
