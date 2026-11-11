import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../../../core/common/widgets/custom_app_bar.dart';
import '../../../../core/routes/routes.dart';
import '../../controller/chelleh_controller.dart';
import '../../model/arbaeen_dhikr_model.dart';
import '../widgets/chelleh_info_sheet.dart';

class CreateChellehPage extends StatefulWidget {
  final bool isStandalone;

  const CreateChellehPage({
    super.key,
    this.isStandalone = true,
  });

  @override
  State<CreateChellehPage> createState() => _CreateChellehPageState();
}

class _CreateChellehPageState extends State<CreateChellehPage> {
  final ChellehController controller = Get.isRegistered<ChellehController>()
      ? Get.find<ChellehController>()
      : Get.put(ChellehController());

  late TextEditingController _niyyahController;
  late TextEditingController _customCountController;
  late TextEditingController _customDaysController;
  late TextEditingController _searchController;

  ArbaeenDhikrModel? _selectedDhikr;
  int _selectedTargetCount = 100;
  int _selectedDays = 40;
  bool _isCustomDays = false;
  bool _isCustomCount = false;
  bool _reminderEnabled = true;
  int _reminderHour = 8;
  int _reminderMinute = 0;
  int _filterCategoryIndex = 0; // 0: الكل, 1: أذكار, 2: سور وأدعية

  final List<String> _niyyahSuggestions = [
    'تعجيل في فرج مولانا صاحب الزمان (عج)',
    'قضاء الحوائج وشفاء المرضى وتفريج الهموم',
    'طلب الرزق الحلال وتيسير الأمور الصعبة',
    'غفران الذنوب والتوفيق لطاعة الله والتقوى',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDhikr = controller.activeDhikr.value ??
        (controller.adhkarList.isNotEmpty ? controller.adhkarList.first : null);

    if (_selectedDhikr != null && _selectedDhikr!.isDhikr) {
      _selectedTargetCount = _selectedDhikr!.repetitionCount > 1
          ? _selectedDhikr!.repetitionCount
          : 100;
    }

    _niyyahController = TextEditingController(
      text: 'تعجيل في فرج مولانا صاحب الزمان (عج)',
    );
    _customCountController = TextEditingController(text: '100');
    _customDaysController = TextEditingController(text: '40');
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _niyyahController.dispose();
    _customCountController.dispose();
    _customDaysController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<ArbaeenDhikrModel> _getFilteredDhkar() {
    final list = controller.adhkarList;
    final query = _searchController.text.trim().toLowerCase();

    return list.where((item) {
      final matchesQuery = query.isEmpty ||
          item.titleArabic.toLowerCase().contains(query) ||
          item.bodyArabic.toLowerCase().contains(query);

      if (!matchesQuery) return false;

      if (_filterCategoryIndex == 1) {
        return item.isDhikr;
      } else if (_filterCategoryIndex == 2) {
        return item.isDuaOrSurah;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final brandColor = colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: widget.isStandalone
          ? CustomAppBar(
              title: 'إنشاء عهد أو أربعينية جديدة',
              actions: [
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
            )
          : null,
      body: Obx(() {
        if (!controller.isLoaded.value && controller.adhkarList.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: brandColor),
          );
        }

        final filteredList = _getFilteredDhkar();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
          children: [
            // 1. Intro Header Banner
            _buildIntroBanner(context, brandColor, isDark),

            const Gap(20),

            // 2. Step 1: Select Dhikr or Dua/Surah
            _buildSectionHeader(
              title: '١. اختيار الذكر أو السورة / الدعاء',
              subtitle: 'اختر الورد الذي ترغب في عقد العهد المبارك به',
              brandColor: brandColor,
            ),

            const Gap(12),

            // Search and Category Tabs
            _buildFilterTabs(brandColor, isDark),

            const Gap(10),

            // Dhikr / Dua List
            _buildDhikrList(filteredList, brandColor, isDark),

            const Gap(22),

            // 3. Step 2: Repetitions (ONLY FOR DHIKR!)
            if (_selectedDhikr != null && _selectedDhikr!.isDhikr) ...[
              _buildSectionHeader(
                title: '٢. عدد تكرار الذكر في اليوم',
                subtitle: 'كم مرة تود قراءة هذا الذكر يومياً؟',
                brandColor: brandColor,
              ),
              const Gap(10),
              _buildRepetitionSelector(brandColor, isDark),
              const Gap(22),
            ] else if (_selectedDhikr != null && _selectedDhikr!.isDuaOrSurah) ...[
              _buildSurahNoticeCard(brandColor, isDark),
              const Gap(22),
            ],

            // 4. Step 3: Duration / Number of Days
            _buildSectionHeader(
              title: '٣. مدة العهد (عدد الأيام)',
              subtitle: 'حدد عدد الأيام المطلوبة لإتمام هذا العهد المبارك',
              brandColor: brandColor,
            ),

            const Gap(10),

            _buildDurationSelector(brandColor, isDark),

            const Gap(22),

            // 5. Step 4: Intention (النية)
            _buildSectionHeader(
              title: '٤. النية المباركة للعهد',
              subtitle: 'اكتب نيتك أو اختر من المقترحات المباركة',
              brandColor: brandColor,
            ),

            const Gap(10),

            _buildNiyyahInput(brandColor, isDark),

            const Gap(22),

            // 6. Step 5: Reminder Settings
            _buildSectionHeader(
              title: '٥. التذكير اليومي',
              subtitle: 'تنبيه لطيف لتثبيت الورد في موعد محدد',
              brandColor: brandColor,
            ),

            const Gap(10),

            _buildReminderCard(brandColor, isDark),

            const Gap(30),

            // Submit Button
            _buildSubmitButton(brandColor),
          ],
        );
      }),
    );
  }

  /// بنر تعریفی ابتدای صفحه
  Widget _buildIntroBanner(BuildContext context, Color brandColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF242022), const Color(0xFF17191C)]
              : [brandColor.withAlpha(25), brandColor.withAlpha(10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: brandColor.withAlpha(isDark ? 40 : 30),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: brandColor.withAlpha(isDark ? 35 : 20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.amber,
              size: 26,
            ),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'عقد عهد جديد (الأربعينية)',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(3),
                Text(
                  'اختر ذكرك أو سورتك المباركة، حدد مدة العهد، وابدأ مسيرتك الروحية مع المتابعة اليومية.',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 12.5,
                    height: 1.5,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required Color brandColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: brandColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Gap(2),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs(Color brandColor, bool isDark) {
    return Column(
      children: [
        // Search Input
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2226) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.grey.shade300,
            ),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'ابحث في الأذكار والسور...',
              hintStyle: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),

        const Gap(10),

        // Tabs
        Row(
          children: [
            _filterChip('الكل', 0, brandColor, isDark),
            const Gap(8),
            _filterChip('أذكار وأوراد', 1, brandColor, isDark),
            const Gap(8),
            _filterChip('سور وأدعية', 2, brandColor, isDark),
          ],
        ),
      ],
    );
  }

  Widget _filterChip(String label, int index, Color brandColor, bool isDark) {
    final isSelected = _filterCategoryIndex == index;
    return Expanded(
      child: ZoomTapAnimation(
        onTap: () {
          setState(() {
            _filterCategoryIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? brandColor
                : (isDark ? Colors.white.withAlpha(10) : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? brandColor
                  : (isDark ? Colors.white12 : Colors.grey.shade300),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.grey[300] : Colors.grey[700]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDhikrList(
    List<ArbaeenDhikrModel> list,
    Color brandColor,
    bool isDark,
  ) {
    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        alignment: Alignment.center,
        child: Text(
          'لم يتم العثور على أذكار مطابقة',
          style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.grey.shade500),
        ),
      );
    }

    return Column(
      children: list.map((item) {
        final isSelected = _selectedDhikr?.id == item.id;
        final isDuaOrSurah = item.isDuaOrSurah;

        return ZoomTapAnimation(
          onTap: () {
            setState(() {
              _selectedDhikr = item;
              if (item.isDhikr) {
                _selectedTargetCount =
                    item.repetitionCount > 1 ? item.repetitionCount : 100;
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? brandColor.withAlpha(isDark ? 30 : 15)
                  : (isDark ? const Color(0xFF1E2226) : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? brandColor
                    : (isDark ? Colors.white10 : Colors.grey.shade200),
                width: isSelected ? 1.8 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: brandColor.withAlpha(20),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Radio indicator
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? brandColor : Colors.grey.shade400,
                      width: 2,
                    ),
                    color: isSelected ? brandColor : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),

                const Gap(12),

                // Title and Body Preview
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.titleArabic,
                              style: TextStyle(
                                fontFamily: 'IBMPlexSansArabic',
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? brandColor
                                    : (isDark ? Colors.white : Colors.black87),
                              ),
                            ),
                          ),
                          const Gap(8),
                          // Type Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isDuaOrSurah
                                  ? Colors.teal.withAlpha(isDark ? 40 : 25)
                                  : Colors.indigo.withAlpha(isDark ? 40 : 25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isDuaOrSurah ? 'سورة / دعاء' : 'ذكر وردي',
                              style: TextStyle(
                                fontFamily: 'IBMPlexSansArabic',
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: isDuaOrSurah ? Colors.teal : Colors.indigo,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (item.bodyArabic.isNotEmpty) ...[
                        const Gap(3),
                        Text(
                          item.bodyArabic.length > 70
                              ? '${item.bodyArabic.substring(0, 68)}...'
                              : item.bodyArabic,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// نشانگر سوره و ادعیه (بدون تکرار عددی)
  Widget _buildSurahNoticeCard(Color brandColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.withAlpha(isDark ? 25 : 15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.teal.withAlpha(isDark ? 50 : 35),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.teal.withAlpha(isDark ? 40 : 25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.teal,
              size: 24,
            ),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'قراءة كاملة مرة واحدة يومياً',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const Gap(3),
                Text(
                  'هذا الورد المبارك عبارة عن سورة أو دعاء؛ لذلك يتم إتمامه بقراءة النص الكامل مرة واحدة كل يوم دون تكرار عددي.',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 12,
                    height: 1.5,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// انتخاب تکرار روزانه (فقط برای ذکرها مثل صلوات)
  Widget _buildRepetitionSelector(Color brandColor, bool isDark) {
    final presets = [100, 313, 500, 1000];

    return Column(
      children: [
        Row(
          children: presets.map((count) {
            final isSelected = !_isCustomCount && _selectedTargetCount == count;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: ZoomTapAnimation(
                  onTap: () {
                    setState(() {
                      _isCustomCount = false;
                      _selectedTargetCount = count;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? brandColor
                          : (isDark ? const Color(0xFF1E2226) : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? brandColor
                            : (isDark ? Colors.white12 : Colors.grey.shade300),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.grey[300] : Colors.grey[800]),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const Gap(8),

        // Custom Count Toggle
        ZoomTapAnimation(
          onTap: () {
            setState(() {
              _isCustomCount = true;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _isCustomCount
                  ? brandColor.withAlpha(isDark ? 30 : 15)
                  : (isDark ? const Color(0xFF1E2226) : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isCustomCount
                    ? brandColor
                    : (isDark ? Colors.white12 : Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.edit_note_rounded,
                  size: 20,
                  color: _isCustomCount ? brandColor : Colors.grey,
                ),
                const Gap(8),
                Text(
                  'عدد مخصص آخر:',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 13,
                    fontWeight:
                        _isCustomCount ? FontWeight.bold : FontWeight.normal,
                    color: _isCustomCount
                        ? brandColor
                        : (isDark ? Colors.grey[300] : Colors.grey[700]),
                  ),
                ),
                const Gap(12),
                if (_isCustomCount)
                  Expanded(
                    child: TextField(
                      controller: _customCountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (val) {
                        final parsed = int.tryParse(val);
                        if (parsed != null && parsed > 0) {
                          _selectedTargetCount = parsed;
                        }
                      },
                      style: const TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'مثال: 70',
                        border: InputBorder.none,
                      ),
                    ),
                  )
                else
                  Text(
                    'انقر للتحديد',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// انتخاب مدت زمان چله (تعداد روزها)
  Widget _buildDurationSelector(Color brandColor, bool isDark) {
    final daysOptions = [
      {'days': 40, 'label': '40 يوماً\n(الأربعينية)'},
      {'days': 21, 'label': '21 يوماً\n(ثلاثة أسابيع)'},
      {'days': 14, 'label': '14 يوماً\n(أسبوعان)'},
      {'days': 7, 'label': '7 أيام\n(أسبوع)'},
    ];

    return Column(
      children: [
        Row(
          children: daysOptions.map((opt) {
            final days = opt['days'] as int;
            final label = opt['label'] as String;
            final isSelected = !_isCustomDays && _selectedDays == days;

            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: ZoomTapAnimation(
                  onTap: () {
                    setState(() {
                      _isCustomDays = false;
                      _selectedDays = days;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? brandColor
                          : (isDark ? const Color(0xFF1E2226) : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? brandColor
                            : (isDark ? Colors.white12 : Colors.grey.shade300),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 11.5,
                        height: 1.3,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.grey[300] : Colors.grey[800]),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const Gap(8),

        // Custom Days
        ZoomTapAnimation(
          onTap: () {
            setState(() {
              _isCustomDays = true;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _isCustomDays
                  ? brandColor.withAlpha(isDark ? 30 : 15)
                  : (isDark ? const Color(0xFF1E2226) : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isCustomDays
                    ? brandColor
                    : (isDark ? Colors.white12 : Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: _isCustomDays ? brandColor : Colors.grey,
                ),
                const Gap(8),
                Text(
                  'مدة مخصصة بالأيام:',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 13,
                    fontWeight:
                        _isCustomDays ? FontWeight.bold : FontWeight.normal,
                    color: _isCustomDays
                        ? brandColor
                        : (isDark ? Colors.grey[300] : Colors.grey[700]),
                  ),
                ),
                const Gap(12),
                if (_isCustomDays)
                  Expanded(
                    child: TextField(
                      controller: _customDaysController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (val) {
                        final parsed = int.tryParse(val);
                        if (parsed != null && parsed > 0 && parsed <= 365) {
                          _selectedDays = parsed;
                        }
                      },
                      style: const TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'مثال: 30',
                        border: InputBorder.none,
                      ),
                    ),
                  )
                else
                  Text(
                    'انقر للتحديد',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// نیت و پیشنهادات
  Widget _buildNiyyahInput(Color brandColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text field
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2226) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.grey.shade300,
            ),
          ),
          child: TextField(
            controller: _niyyahController,
            maxLines: 2,
            style: const TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'اكتب نيتك المباركة لهذا العهد...',
              hintStyle: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ),

        const Gap(8),

        // Quick suggestions
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _niyyahSuggestions.map((suggestion) {
            return ZoomTapAnimation(
              onTap: () {
                setState(() {
                  _niyyahController.text = suggestion;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  suggestion,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 11,
                    color: isDark ? Colors.grey[300] : Colors.grey[800],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// تنظیم یادآور
  Widget _buildReminderCard(Color brandColor, bool isDark) {
    final timeStr =
        '${_reminderHour.toString().padLeft(2, '0')}:${_reminderMinute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2226) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.notifications_active_rounded,
                    color: brandColor,
                    size: 20,
                  ),
                  const Gap(10),
                  const Text(
                    'تفعيل التذكير اليومي للعهد',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Switch(
                value: _reminderEnabled,
                activeColor: brandColor,
                onChanged: (val) {
                  setState(() {
                    _reminderEnabled = val;
                  });
                },
              ),
            ],
          ),
          if (_reminderEnabled) ...[
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'وقت التذكير اليومي:',
                  style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 13),
                ),
                ZoomTapAnimation(
                  onTap: _pickTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: brandColor.withAlpha(isDark ? 30 : 15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: brandColor.withAlpha(50)),
                    ),
                    child: Text(
                      timeStr,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: brandColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _reminderHour, minute: _reminderMinute),
    );
    if (picked != null) {
      setState(() {
        _reminderHour = picked.hour;
        _reminderMinute = picked.minute;
      });
    }
  }

  /// دکمه ثبت و ایجاد چله
  Widget _buildSubmitButton(Color brandColor) {
    return ZoomTapAnimation(
      onTap: _submitChelleh,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: brandColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: brandColor.withAlpha(80),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag_rounded, color: Colors.white, size: 20),
            Gap(8),
            Text(
              'بدء العهد المبارك',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitChelleh() {
    final dhikr = _selectedDhikr;
    if (dhikr == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى اختيار الذكر أو السورة أولاً',
            style: TextStyle(fontFamily: 'IBMPlexSansArabic'),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final int targetCount = dhikr.isDuaOrSurah ? 1 : _selectedTargetCount;
    final int days = _selectedDays > 0 ? _selectedDays : 40;
    final String niyyah = _niyyahController.text.trim();

    controller.createNewChelleh(
      dhikr: dhikr,
      totalDays: days,
      targetCountPerDay: targetCount,
      niyyah: niyyah,
      isReminderEnabled: _reminderEnabled,
      reminderHour: _reminderHour,
      reminderMinute: _reminderMinute,
    );

    // If standalone screen, push to track screen or return true
    if (widget.isStandalone) {
      Get.offNamed(Routes.chellehTrack);
    } else {
      // If used inside TabBar of ChellehPage, parent can listen or we notify
      Get.toNamed(Routes.chellehTrack);
    }
  }
}
