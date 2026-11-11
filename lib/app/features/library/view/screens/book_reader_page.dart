import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mawsueat/app/features/library/controller/book_reader_controller.dart';
import 'package:mawsueat/app/features/library/data/models/book_model.dart';
import 'package:mawsueat/app/features/library/data/repositories/library_repository.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class BookReaderPage extends StatefulWidget {
  final BookModel book;

  const BookReaderPage({super.key, required this.book});

  @override
  State<BookReaderPage> createState() => _BookReaderPageState();
}

class _BookReaderPageState extends State<BookReaderPage> {
  late final BookReaderController controller;
  InAppWebViewController? webViewController;
  bool isWebviewReady = false;
  String? htmlContent;
  bool isGeneratingHtml = true;
  final isDraggingSlider = false.obs;
  final dragPage = 1.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      BookReaderController(Get.find<LibraryRepository>(), widget.book),
    );
    dragPage.value = controller.currentPage.value;
    _preparePdfHtml();
  }

  Future<void> _preparePdfHtml() async {
    final pdfUrl = widget.book.pdfUrl.trim();
    final localPath = widget.book.localPath;

    String loadJs;
    // اگر فایل محلی از قبل موجود بود از آن استفاده کن، در غیر این صورت مستقیماً آنلاین لود کن
    if (localPath != null && localPath.toLowerCase().endsWith('.pdf') && File(localPath).existsSync()) {
      try {
        final bytes = await File(localPath).readAsBytes();
        final base64Pdf = base64Encode(bytes);
        loadJs = '''
    const pdfData = atob("$base64Pdf");
    const uint8Array = new Uint8Array(pdfData.length);
    for (let i = 0; i < pdfData.length; i++) {
      uint8Array[i] = pdfData.charCodeAt(i);
    }
    const loadingTask = pdfjsLib.getDocument({ data: uint8Array });
''';
      } catch (e) {
        debugPrint('Error reading local pdf: $e');
        loadJs = 'const loadingTask = pdfjsLib.getDocument({ url: "$pdfUrl", withCredentials: false });';
      }
    } else {
      // کاملاً آنلاین و مستقیم بدون ذخیره فایل در حافظه
      loadJs = 'const loadingTask = pdfjsLib.getDocument({ url: "$pdfUrl", withCredentials: false });';
    }

    htmlContent = '''
<!DOCTYPE html>
<html dir="rtl">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=3.0, user-scalable=yes">
  <script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js"></script>
  <style>
    * { box-sizing: border-box; }
    body {
      margin: 0;
      padding: 0;
      background-color: #1e1e1e;
      display: flex;
      flex-direction: column;
      align-items: center;
      min-height: 100vh;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    }
    #loading-container {
      position: fixed;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      color: #ffffff;
      font-size: 15px;
      text-align: center;
    }
    #pdf-container {
      width: 100%;
      display: flex;
      flex-direction: column;
      align-items: center;
      padding: 30vh 0 35vh 0;
    }
    .page-wrapper {
      margin: 14px auto;
      position: relative;
      box-shadow: 0 4px 15px rgba(0,0,0,0.4);
      background-color: #ffffff;
      border-radius: 4px;
      overflow: hidden;
    }
    canvas {
      display: block;
      width: 100% !important;
      height: auto !important;
    }
  </style>
</head>
<body>
  <div id="loading-container">
    <div style="font-size: 28px; margin-bottom: 12px;">📖</div>
    <div id="loading-text" style="margin-bottom: 10px; font-weight: bold;">جاري عرض ملف الـ PDF عبر الإنترنت...</div>
  </div>
  <div id="pdf-container"></div>

  <script>
    pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js';

    $loadJs

    let pdfDoc = null;
    let initialScrollDone = false;
    const initialPage = ${widget.book.lastReadPage > 0 ? widget.book.lastReadPage : 1};

    loadingTask.onProgress = function(progress) {
      if (progress.total > 0) {
        const pct = Math.round((progress.loaded / progress.total) * 100);
        const textEl = document.getElementById('loading-text');
        if (textEl) {
          textEl.innerText = 'جاري تحميل الـ PDF آنلاین (' + pct + '%)...';
        }
      }
    };

    loadingTask.promise.then(function(pdf) {
      pdfDoc = pdf;
      const total = pdf.numPages;
      document.getElementById('loading-container').style.display = 'none';

      if (window.flutter_inappwebview) {
        window.flutter_inappwebview.callHandler('onPdfLoaded', total);
      }

      for (let pageNum = 1; pageNum <= total; pageNum++) {
        renderPage(pageNum);
      }
    }).catch(function(error) {
      document.getElementById('loading-container').innerHTML = '<div style="color: #ff6b6b; padding: 20px;">خطأ في فتح ملف الـ PDF: ' + error.message + '</div>';
    });

    function renderPage(num) {
      pdfDoc.getPage(num).then(function(page) {
        const viewport = page.getViewport({ scale: 1.5 });
        const wrapper = document.createElement('div');
        wrapper.className = 'page-wrapper';
        wrapper.id = 'page-' + num;
        wrapper.style.width = '96%';
        wrapper.style.maxWidth = viewport.width + 'px';

        const canvas = document.createElement('canvas');
        const ctx = canvas.getContext('2d');
        canvas.height = viewport.height;
        canvas.width = viewport.width;

        wrapper.appendChild(canvas);
        document.getElementById('pdf-container').appendChild(wrapper);

        const renderContext = {
          canvasContext: ctx,
          viewport: viewport
        };
        page.render(renderContext).promise.then(function() {
          if (!initialScrollDone && num === initialPage) {
            initialScrollDone = true;
            setTimeout(function() {
              scrollToPage(initialPage);
            }, 250);
          }
        });
      });
    }

    // Scroll listener to report current visible page closest to viewport center
    let scrollTimeout;
    window.addEventListener('scroll', function() {
      clearTimeout(scrollTimeout);
      scrollTimeout = setTimeout(function() {
        const pages = document.querySelectorAll('.page-wrapper');
        let currentVisiblePage = 1;
        let minDistance = Infinity;
        const viewportCenter = window.scrollY + (window.innerHeight / 2);

        pages.forEach((p, idx) => {
          const pageCenter = p.offsetTop + (p.offsetHeight / 2);
          const dist = Math.abs(viewportCenter - pageCenter);
          if (dist < minDistance) {
            minDistance = dist;
            currentVisiblePage = idx + 1;
          }
        });

        if (window.flutter_inappwebview) {
          window.flutter_inappwebview.callHandler('onPageScrolled', currentVisiblePage);
        }
      }, 80);
    });

    function scrollToPage(pageNumber) {
      const target = document.getElementById('page-' + pageNumber);
      if (target) {
        const targetTop = target.offsetTop;
        const targetHeight = target.offsetHeight;
        const windowHeight = window.innerHeight;
        
        // Exact vertical center alignment on device screen
        const desiredScrollY = targetTop - ((windowHeight - targetHeight) / 2);

        window.scrollTo({
          top: Math.max(0, desiredScrollY),
          behavior: 'smooth'
        });
      }
    }
  </script>
</body>
</html>
''';

    if (mounted) {
      setState(() {
        isGeneratingHtml = false;
      });
    }
  }

  void _scrollToPageInWebView(int page) {
    if (webViewController != null && isWebviewReady) {
      webViewController?.evaluateJavascript(source: 'scrollToPage($page);');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // PDF Viewer Area
            Positioned.fill(
              child: GestureDetector(
                onTap: () => controller.toggleControls(),
                child: isGeneratingHtml
                    ? Center(
                        child: LoadingAnimationWidget.waveDots(
                          color: primaryColor,
                          size: 36,
                        ),
                      )
                    : htmlContent != null
                        ? InAppWebView(
                            initialData: InAppWebViewInitialData(
                              data: htmlContent ?? '',
                            ),
                            initialSettings: InAppWebViewSettings(
                              useHybridComposition: true,
                              supportZoom: true,
                              builtInZoomControls: true,
                              displayZoomControls: false,
                              allowFileAccess: true,
                              allowFileAccessFromFileURLs: true,
                              allowUniversalAccessFromFileURLs: true,
                              javaScriptEnabled: true,
                              domStorageEnabled: true,
                            ),
                            onWebViewCreated: (wController) {
                              webViewController = wController;

                              // دریافت تعداد کل صفحات از JS
                              wController.addJavaScriptHandler(
                                handlerName: 'onPdfLoaded',
                                callback: (args) {
                                  if (args.isNotEmpty && args[0] is int) {
                                    controller.totalPages.value = args[0] as int;
                                  }
                                },
                              );

                              // دریافت شماره صفحه در حال نمایش از JS
                              wController.addJavaScriptHandler(
                                handlerName: 'onPageScrolled',
                                callback: (args) {
                                  if (args.isNotEmpty && args[0] is int) {
                                    final page = args[0] as int;
                                    controller.setPage(page);
                                  }
                                },
                              );

                              setState(() {
                                isWebviewReady = true;
                              });
                            },
                          )
                        : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: theme.colorScheme.error,
                            ),
                            const Gap(12),
                            Text(
                              'فایل کتاب یافت نشد یا حذف شده است',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),

            // Sleek Floating Top Bar
            Obx(() {
              final show = controller.showControls.value;
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                top: show ? 10 : -90,
                left: 14,
                right: 14,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: show ? 1.0 : 0.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ZoomTapAnimation(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.07),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 15,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const Gap(10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.book.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  if (widget.book.author.isNotEmpty)
                                    Text(
                                      widget.book.author,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: theme.colorScheme.secondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Gap(8),
                            // Quick Jump to Page Pill
                            ZoomTapAnimation(
                              onTap: () => _showJumpToPageDialog(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: primaryColor.withValues(alpha: 0.25),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.auto_stories_rounded,
                                      size: 13,
                                      color: primaryColor,
                                    ),
                                    const Gap(4),
                                    Obx(
                                      () => Text(
                                        '${controller.currentPage.value}/${controller.totalPages.value}',
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),

            // Sleek Floating Bottom Controls
            Obx(() {
              final show = controller.showControls.value;
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                bottom: show ? 12 : -110,
                left: 14,
                right: 14,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: show ? 1.0 : 0.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 14,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header: Current Page and Percentage
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ZoomTapAnimation(
                                    onTap: () => _showJumpToPageDialog(context),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Obx(() {
                                          final cur = isDraggingSlider.value
                                              ? dragPage.value
                                              : controller.currentPage.value;
                                          return Text(
                                            'صفحة $cur من ${controller.totalPages.value}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: theme.colorScheme.onSurface,
                                            ),
                                          );
                                        }),
                                        const Gap(3),
                                        Icon(
                                          Icons.edit_outlined,
                                          size: 13,
                                          color: theme.colorScheme.secondary,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Obx(() {
                                    final cur = isDraggingSlider.value
                                        ? dragPage.value
                                        : controller.currentPage.value;
                                    final total = controller.totalPages.value > 0
                                        ? controller.totalPages.value
                                        : 1;
                                    final percent = ((cur / total) * 100).toInt();
                                    return Text(
                                      '$percent%',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            const Gap(2),

                            // Controls Row: Previous Button + Slim Slider + Next Button
                            Row(
                              children: [
                                // Previous Page Button
                                ZoomTapAnimation(
                                  onTap: () {
                                    controller.prevPage();
                                    _scrollToPageInWebView(controller.currentPage.value);
                                  },
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.chevron_right_rounded,
                                      size: 22,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),

                                // Slim Interactive Slider with Tooltip (ValueIndicator)
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: primaryColor,
                                      inactiveTrackColor: theme.colorScheme.onSurface.withValues(alpha: 0.12),
                                      thumbColor: primaryColor,
                                      overlayColor: primaryColor.withValues(alpha: 0.15),
                                      trackHeight: 3.5,
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.5),
                                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 15),
                                      showValueIndicator: ShowValueIndicator.always,
                                      valueIndicatorColor: primaryColor,
                                      valueIndicatorShape: const RectangularSliderValueIndicatorShape(),
                                      valueIndicatorTextStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    child: Obx(
                                      () {
                                        final curPage = isDraggingSlider.value
                                            ? dragPage.value
                                            : controller.currentPage.value;
                                        return Slider(
                                          value: curPage.toDouble().clamp(
                                                1.0,
                                                controller.totalPages.value.toDouble(),
                                              ),
                                          min: 1.0,
                                          max: controller.totalPages.value.toDouble() > 1
                                              ? controller.totalPages.value.toDouble()
                                              : 2.0,
                                          divisions: controller.totalPages.value > 1
                                              ? controller.totalPages.value - 1
                                              : 1,
                                          label: 'صفحة $curPage',
                                          onChangeStart: (val) {
                                            isDraggingSlider.value = true;
                                            dragPage.value = val.toInt();
                                          },
                                          onChanged: (val) {
                                            dragPage.value = val.toInt();
                                          },
                                          onChangeEnd: (val) {
                                            isDraggingSlider.value = false;
                                            final page = val.toInt();
                                            controller.setPage(page);
                                            _scrollToPageInWebView(page);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),

                                // Next Page Button
                                ZoomTapAnimation(
                                  onTap: () {
                                    controller.nextPage();
                                    _scrollToPageInWebView(controller.currentPage.value);
                                  },
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryColor.withValues(alpha: 0.35),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.chevron_left_rounded,
                                      size: 22,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showJumpToPageDialog(BuildContext context) {
    final textController = TextEditingController(
      text: controller.currentPage.value.toString(),
    );
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.onPrimary;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'الانتقال إلى صفحة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'أدخل رقم الصفحة (1 إلى ${controller.totalPages.value}):',
                style: TextStyle(
                  fontSize: 12.5,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const Gap(14),
              TextField(
                controller: textController,
                keyboardType: TextInputType.number,
                autofocus: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: theme.scaffoldBackgroundColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.dividerTheme.color ?? Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'إلغاء',
                style: TextStyle(color: theme.colorScheme.secondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final targetPage = int.tryParse(textController.text.trim());
                if (targetPage != null &&
                    targetPage >= 1 &&
                    targetPage <= controller.totalPages.value) {
                  controller.setPage(targetPage);
                  _scrollToPageInWebView(targetPage);
                  Navigator.of(ctx).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('انتقال'),
            ),
          ],
        );
      },
    );
  }
}
