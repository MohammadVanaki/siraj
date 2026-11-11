import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../controller/chelleh_controller.dart';

class ChellehSettingsSheet extends StatefulWidget {
  const ChellehSettingsSheet({super.key});

  @override
  State<ChellehSettingsSheet> createState() => _ChellehSettingsSheetState();
}

class _ChellehSettingsSheetState extends State<ChellehSettingsSheet> {
  late final TextEditingController _niyyahController;
  late bool _reminderEnabled;
  late int _reminderHour;
  late int _reminderMinute;

  @override
  void initState() {
    super.initState();
    final controller = ChellehController.to;
    _niyyahController =
        TextEditingController(text: controller.chelleh.value.niyyah);
    _reminderEnabled = controller.chelleh.value.isReminderEnabled;
    _reminderHour = controller.chelleh.value.reminderHour;
    _reminderMinute = controller.chelleh.value.reminderMinute;
  }

  @override
  void dispose() {
    _niyyahController.dispose();
    super.dispose();
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

  void _saveSettings() {
    final controller = ChellehController.to;
    controller.updateNiyyah(_niyyahController.text.trim());
    controller.updateReminderSettings(
      isEnabled: _reminderEnabled,
      hour: _reminderHour,
      minute: _reminderMinute,
    );
    Navigator.of(context).pop();
  }

  void _confirmRestart() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'إعادة ضبط الأربعينية',
            style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.bold),
          ),
          content: Text(
            'هل أنت متأكد من إعادة بدء ${ChellehController.to.chelleh.value.title} من اليوم الأول وتصفير الأيام المنجزة؟',
            style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(ctx).pop(); // close dialog
                Navigator.of(context).pop(); // close sheet
                ChellehController.to.restartChelleh();
              },
              child: const Text('إعادة البدء من اليوم الأول'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final formattedTime =
        '${_reminderHour.toString().padLeft(2, '0')}:${_reminderMinute.toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'إعدادات أربعينية الصلوات',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Niyyah Input
            Text(
              'نية الأربعينية أو الحاجة المباركة:',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _niyyahController,
              maxLines: 2,
              style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 14),
              decoration: InputDecoration(
                hintText: 'اكتب نيتك أو حاجتك هنا...',
                filled: true,
                fillColor: isDark ? Colors.white.withAlpha(10) : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Daily Reminder Switch & Time
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withAlpha(10) : Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notifications_active_outlined,
                            size: 20,
                            color: colorScheme.onPrimary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'تذكير يومي بالصلوات',
                            style: TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _reminderEnabled,
                        activeColor: colorScheme.onPrimary,
                        onChanged: (val) => setState(() => _reminderEnabled = val),
                      ),
                    ],
                  ),
                  if (_reminderEnabled) ...[
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'وقت التذكير اليومي:',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 13,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                        ZoomTapAnimation(
                          onTap: _pickTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.onPrimary.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              formattedTime,
                              style: TextStyle(
                                fontFamily: 'IBMPlexSansArabic',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _saveSettings,
                child: const Text(
                  'حفظ الإعدادات',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Restart Button
            Center(
              child: TextButton.icon(
                onPressed: _confirmRestart,
                icon: const Icon(Icons.restart_alt_rounded,
                    color: Colors.red, size: 18),
                label: const Text(
                  'إعادة بدء الأربعينية من اليوم الأول',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 13,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
  }
}
