import 'package:flutter/material.dart';

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "$twoDigitMinutes:$twoDigitSeconds";
}

extension ColorToCss on Color {
  String toCssHex() {
    // Returns hex string like #RRGGBB
    return '#${red.toRadixString(16).padLeft(2, '0')}'
        '${green.toRadixString(16).padLeft(2, '0')}'
        '${blue.toRadixString(16).padLeft(2, '0')}';
  }

  String toCssRgba() {
    // Returns rgba(R, G, B, A) string
    return 'rgba($r, $g, $b, ${(a / 255).toStringAsFixed(2)})';
  }
}

String removeHtmlTags(String htmlText) {
  final regExp = RegExp(r'<[^>]*>');
  String cleanText = htmlText.replaceAll(regExp, '');
  cleanText = cleanText.replaceAll(RegExp(r'&nbsp;'), ' ');
  return cleanText;
}

List<TextSpan> highlightSearchTerm(String text, String searchTerm) {
  List<TextSpan> spans = [];
  if (searchTerm.isEmpty) {
    spans.add(TextSpan(text: text));
    return spans;
  }

  int start = 0;
  RegExp regExp = RegExp(searchTerm, caseSensitive: false);
  Iterable<RegExpMatch> matches = regExp.allMatches(text);

  for (var match in matches) {
    // قسمت قبل از کلمه جستجو
    if (match.start > start) {
      spans.add(TextSpan(
        text: text.substring(start, match.start),
        style: TextStyle(
            fontFamily: 'IBMPlexSansArabic'), // فونت فمیلی را اینجا هم اضافه کنید
      ));
    }

    // قسمت کلمه جستجو
    spans.add(TextSpan(
      text: text.substring(match.start, match.end),
      style: TextStyle(
        color: Colors.yellow, // رنگ هایلایت
        fontWeight: FontWeight.w700, // فونت بولد
        fontFamily: 'IBMPlexSansArabic', // فونت فمیلی برای هایلایت
      ),
    ));

    // به روز رسانی شروع از جایی که کلمه جستجو تمام شده
    start = match.end;
  }

  // اضافه کردن قسمت باقی‌مانده از متن
  if (start < text.length) {
    spans.add(TextSpan(
      text: text.substring(start),
      style: TextStyle(fontFamily: 'IBMPlexSansArabic'), // فونت فمیلی برای باقی متن
    ));
  }

  return spans;
}
