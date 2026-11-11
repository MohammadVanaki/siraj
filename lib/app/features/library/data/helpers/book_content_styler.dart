import 'package:mawsueat/app/features/library/controller/book_content_reader_controller.dart';

class BookContentStyler {
  /// ۱. پیش‌پردازش متن خام دیتابیس:
  /// - تبدیل تگ‌های پاورقی/تولتیپ (<span title="..." data-toggle="tooltip">متن</span>) به تگ <a> اینلاین
  ///   با فرمت: <a href="tooltip:$encodedTitle" class="fn-tooltip">$innerText</a>
  /// - هایلایت کردن کلمه جستجو شده (در صورت وجود) با تگ <span class="highlight">...</span>
  static String preprocessHtml(String rawHtml, {String? searchQuery}) {
    if (rawHtml.trim().isEmpty) return rawHtml;

    String processed = rawHtml;

    // ۱. استخراج و تبدیل انواع تگ‌های پاورقی و تولتیپ
    final tooltipTagRegex = RegExp(
      r'''<(span|a|sup|sub)\b([^>]*)>(.*?)<\/\1>''',
      caseSensitive: false,
      dotAll: true,
    );

    processed = processed.replaceAllMapped(tooltipTagRegex, (match) {
      final tag = match.group(1)!.toLowerCase();
      final attrs = match.group(2) ?? '';
      final innerText = match.group(3) ?? '';

      // استخراج صفت title یا data-original-title با پشتیبانی از هر دو حالت کوتیشن "..." یا '...'
      final titleMatch = RegExp(
        r'''(?:title|data-original-title)\s*=\s*(?:"([^"]*)"|'([^']*)')''',
        caseSensitive: false,
        dotAll: true,
      ).firstMatch(attrs);

      final title = titleMatch?.group(1) ?? titleMatch?.group(2);

      final lowerAttrs = attrs.toLowerCase();
      final isCandidate = lowerAttrs.contains('tooltip') ||
          lowerAttrs.contains('fn') ||
          lowerAttrs.contains('fm') ||
          tag == 'sup' ||
          (title != null && title.trim().isNotEmpty);

      if (title != null && title.trim().isNotEmpty && isCandidate) {
        final encodedTitle = Uri.encodeComponent(title.trim());
        final cleanInner = innerText.replaceAll('&nbsp;', ' ').trim();
        final displayInner = cleanInner.isEmpty ? '•' : innerText;
        return '<a href="tooltip:$encodedTitle" class="fn-tooltip" data-tooltip="$encodedTitle">$displayInner</a>';
      }

      return match.group(0)!;
    });

    // ۲. هایلایت کردن کلمه سرچ شده بدون آسیب رساندن به تگ‌ها و مقادیر صفت‌های HTML
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      processed = _highlightQuery(processed, searchQuery.trim());
    }

    return processed;
  }

  /// متد کمکی برای هایلایت امن کلمه جستجو در خارج از تگ‌های HTML
  static String _highlightQuery(String html, String query) {
    if (query.isEmpty) return html;
    final escapedQuery = RegExp.escape(query);
    // تطبیق تگ‌های کامل HTML یا عبارت سرچ
    final pattern = RegExp('(<[^>]+>)|($escapedQuery)', caseSensitive: false);
    return html.replaceAllMapped(pattern, (match) {
      final tagMatch = match.group(1);
      if (tagMatch != null) {
        // تگ HTML است، دست نخورده باقی می‌ماند
        return tagMatch;
      }
      final matchedText = match.group(2) ?? '';
      return '<span class="highlight">$matchedText</span>';
    });
  }

  /// تولید کد CSS متناسب با تم جاری
  static String getEmbeddedCss(
    ReaderThemeMode theme,
    double fontSize,
    double lineHeight, {
    String fontFamily = 'dijlah',
  }) {
    final isDark =
        theme == ReaderThemeMode.dark || theme == ReaderThemeMode.black;

    final primaryTextColor = isDark
        ? '#E1E3E6'
        : (theme == ReaderThemeMode.sepia ? '#382E1E' : '#1E2022');
    final quranColor = isDark ? '#4CAF50' : '#008000';
    final fnoteColor = isDark ? '#4DD0E1' : '#337777';
    final fnColor = isDark ? '#4CAF50' : '#008000';
    final tit1Color = '#00AA00';
    final tit2Color = isDark ? '#90CAF9' : '#000080';
    final tit3Color = isDark ? '#E0E0E0' : '#111111';
    final tit4Color = isDark ? '#D0D0D0' : '#222222';
    final tit5Color = isDark ? '#C0C0C0' : '#333333';
    final marginTextColor = isDark ? '#FFCC80' : '#764C01';
    final hrColor = isDark ? '#424242' : '#E0E0E0';

    return '''
<style>
  body, .book-content {
    font-family: '$fontFamily', sans-serif;
    font-size: ${fontSize}px;
    line-height: $lineHeight;
    color: $primaryTextColor;
    direction: rtl;
    text-align: justify;
    word-spacing: 1.1px;
    letter-spacing: 0.15px;
  }

  p {
    text-indent: 1em;
    margin: 4px 0 !important;
    padding: 0 !important;
  }

  /* ۱. عناوین و تیترها */
  h1, .tit1 {
    color: $tit1Color !important;
    font-weight: bold !important;
    text-align: center !important;
    margin-top: 14px !important;
    margin-bottom: 8px !important;
    display: block;
    width: 100%;
  }

  h2, .tit2 {
    color: $tit2Color !important;
    font-weight: bold !important;
    text-align: center !important;
    font-size: 1.25em !important;
    margin-top: 12px !important;
    display: block;
    width: 100%;
  }

  h3, .tit3 {
    color: $tit3Color !important;
    font-weight: bold !important;
    text-align: center !important;
    font-size: 1.15em !important;
    margin-top: 10px !important;
    display: block;
    width: 100%;
  }

  h4, .tit4 {
    color: $tit4Color !important;
    font-weight: bold !important;
    text-align: center !important;
    display: block;
    width: 100%;
  }

  h5, .tit5 {
    color: $tit5Color !important;
    font-weight: bold !important;
    text-align: right !important;
    display: block;
  }

  /* ۲. آیات قرآن و احادیث */
  .quran {
    color: $quranColor !important;
    font-weight: bold !important;
  }

  .hadith {
    font-weight: bold !important;
    color: $primaryTextColor !important;
  }

  /* ۳. پاورقی‌ها و شماره‌های ارجاع */
  sup, sub, a.fn, a.fm, a.fn-tooltip, .fn, .fm, .fn-tooltip, a[href^="tooltip:"] {
    color: $fnColor !important;
    font-weight: bold !important;
    text-decoration: none !important;
    font-size: 0.82em !important;
    vertical-align: middle !important;
    line-height: 1 !important;
    margin: 0 2px !important;
    padding: 0 2px !important;
    display: inline !important;
  }

  .fnote, .fnote2 {
    color: $fnoteColor !important;
    font-size: 0.85em !important;
    line-height: 1.5 !important;
    display: block;
  }

  /* ۴. شعر و متون وسط‌چین */
  .sher, .centertxt, .centertxt2 {
    text-align: center !important;
    font-size: 0.9em !important;
    display: block;
    width: 100%;
  }

  /* ۵. سایر استایل‌ها */
  p.pagen, .pagen {
    text-align: center !important;
    color: #D32F2F !important;
    font-size: 0.75em !important;
    display: block;
  }

  .marging_text {
    color: $marginTextColor !important;
  }

  .highlight {
    background-color: #FFF176 !important;
    color: #D32F2F !important;
    font-weight: bold !important;
    border-radius: 3px !important;
    padding: 0 2px !important;
  }

  .fnote_line, hr.fnote {
    color: $fnoteColor;
    border-top: 1px solid $hrColor;
    width: 50%;
    margin: 16px auto 10px 0;
    display: block;
  }

  .paragraph {
    color: $primaryTextColor !important;
    margin: 4px 0;
  }

  .hashieh {
    width: 100%;
    color: $fnoteColor !important;
    font-size: 85%;
  }

  .book-image {
    text-align: center;
    margin: 12px auto;
  }

  .book-image img {
    max-width: 95%;
    margin: auto;
    border-radius: 6px;
  }
</style>
''';
  }

  /// آماده‌سازی محتوا با کپسوله‌سازی و استایل‌ها
  static String wrapHtmlWithTheme({
    required String rawHtml,
    required ReaderThemeMode theme,
    required double fontSize,
    required double lineHeight,
    String fontFamily = 'dijlah',
  }) {
    final css = getEmbeddedCss(theme, fontSize, lineHeight, fontFamily: fontFamily);
    final themeClass =
        (theme == ReaderThemeMode.dark || theme == ReaderThemeMode.black)
        ? 'dark'
        : (theme == ReaderThemeMode.sepia ? 'sepia' : 'light');

    return '''
$css
<div class="book-content $themeClass" style="text-align: justify;">
$rawHtml
</div>
''';
  }

  /// متد customStylesBuilder برای پکیج flutter_widget_from_html
  static Map<String, String>? resolveCustomStyle(
    dynamic element,
    ReaderThemeMode theme,
  ) {
    final isDark =
        theme == ReaderThemeMode.dark || theme == ReaderThemeMode.black;

    final tit2Color = isDark ? '#90CAF9' : '#000080';
    final tit3Color = isDark ? '#E0E0E0' : '#111111';
    final tit4Color = isDark ? '#D0D0D0' : '#222222';
    final tit5Color = isDark ? '#C0C0C0' : '#333333';
    final quranColor = isDark ? '#4CAF50' : '#008000';
    final fnoteColor = isDark ? '#4DD0E1' : '#337777';
    final fnColor = isDark ? '#4CAF50' : '#008000';
    final marginTextColor = isDark ? '#FFCC80' : '#764C01';

    final classes = element.classes != null
        ? Set<String>.from(element.classes)
        : <String>{};
    final localName = (element.localName ?? '').toString().toLowerCase();

    // ۱. پاراگراف‌ها و متن اصلی کتاب - Justify
    if (localName == 'p' ||
        classes.contains('paragraph') ||
        classes.contains('book-content')) {
      return {
        'text-align': 'justify',
        'margin': '4px 0',
      };
    }

    // ۲. عناوین و تیترها
    // کلاس tit1 یا تگ h1
    if (classes.contains('tit1') || localName == 'h1') {
      return {
        'color': '#00AA00',
        'font-weight': 'bold',
        'text-align': 'center',
        'margin-top': '14px',
        'margin-bottom': '8px',
      };
    }

    // کلاس tit2 یا تگ h2
    if (classes.contains('tit2') || localName == 'h2') {
      return {
        'color': tit2Color,
        'font-weight': 'bold',
        'text-align': 'center',
        'font-size': '1.25em',
        'margin-top': '12px',
      };
    }

    // کلاس tit3 یا تگ h3
    if (classes.contains('tit3') || localName == 'h3') {
      return {
        'color': tit3Color,
        'font-weight': 'bold',
        'text-align': 'center',
        'font-size': '1.15em',
        'margin-top': '10px',
      };
    }

    // کلاس tit4 یا تگ h4
    if (classes.contains('tit4') || localName == 'h4') {
      return {
        'color': tit4Color,
        'font-weight': 'bold',
        'text-align': 'center',
      };
    }

    // کلاس tit5 یا تگ h5
    if (classes.contains('tit5') || localName == 'h5') {
      return {
        'color': tit5Color,
        'font-weight': 'bold',
        'text-align': 'right',
      };
    }

    // ۲. آیات قرآن و احادیث
    if (classes.contains('quran')) {
      return {
        'color': quranColor,
        'font-weight': 'bold',
      };
    }

    if (classes.contains('hadith')) {
      return {
        'font-weight': 'bold',
      };
    }

    // ۳. پاورقی‌ها و شماره‌های ارجاع
    if (classes.contains('fn') ||
        classes.contains('fm') ||
        classes.contains('fn-tooltip') ||
        localName == 'sup' ||
        localName == 'sub' ||
        (localName == 'a' && (element.attributes['href'] ?? '').startsWith('tooltip:'))) {
      return {
        'color': fnColor,
        'font-weight': 'bold',
        'text-decoration': 'none',
        'font-size': '0.82em',
        'vertical-align': 'middle',
        'line-height': '1',
        'display': 'inline',
      };
    }

    // کلاس fnote و fnote2
    if (classes.contains('fnote') || classes.contains('fnote2')) {
      return {
        'color': fnoteColor,
        'font-size': '0.85em',
        'line-height': '1.5',
        'text-align': 'justify',
      };
    }

    // ۴. شعر و متون وسط‌چین
    if (classes.contains('sher') ||
        classes.contains('centertxt') ||
        classes.contains('centertxt2')) {
      return {
        'text-align': 'center',
        'font-size': '0.9em',
      };
    }

    // ۵. سایر استایل‌ها
    // شماره صفحه چاپی در متن
    if (classes.contains('pagen') ||
        (localName == 'p' && classes.contains('pagen'))) {
      return {
        'text-align': 'center',
        'color': '#D32F2F',
        'font-size': '0.75em',
      };
    }

    if (classes.contains('marging_text')) {
      return {
        'color': marginTextColor,
      };
    }

    if (classes.contains('highlight')) {
      return {
        'background-color': '#FFF176',
        'color': '#D32F2F',
        'font-weight': 'bold',
        'border-radius': '3px',
      };
    }

    if (classes.contains('fnote_line') ||
        (localName == 'hr' && classes.contains('fnote'))) {
      return {
        'color': fnoteColor,
        'width': '50%',
        'margin-top': '16px',
        'margin-bottom': '8px',
      };
    }

    if (classes.contains('hashieh')) {
      return {
        'width': '100%',
        'color': fnoteColor,
        'font-size': '85%',
      };
    }

    if (classes.contains('book-image')) {
      return {
        'text-align': 'center',
        'margin': '12px 0',
      };
    }

    return null;
  }
}
