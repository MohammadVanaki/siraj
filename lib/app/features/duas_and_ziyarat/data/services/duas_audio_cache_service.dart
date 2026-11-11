import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DuasAudioCacheService extends GetxService {
  static DuasAudioCacheService get to => Get.find<DuasAudioCacheService>();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(minutes: 5),
      followRedirects: true,
    ),
  );

  Directory? _cachedDir;

  Future<Directory> _getCacheDirectory() async {
    if (_cachedDir != null && await _cachedDir!.exists()) {
      return _cachedDir!;
    }
    final tempDir = await getTemporaryDirectory();
    final cacheDir = Directory(p.join(tempDir.path, 'duas_audio_cache'));
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    _cachedDir = cacheDir;
    return cacheDir;
  }

  /// دریافت مسیر فایل کش شده در صورتی که قبلاً کامل دانلود شده باشد
  Future<String?> getCachedFilePath(String id) async {
    try {
      final dir = await _getCacheDirectory();
      final file = File(p.join(dir.path, '$id.mp3'));
      if (await file.exists() && (await file.length()) > 0) {
        return file.path;
      }
    } catch (e) {
      debugPrint('Error checking cached file: $e');
    }
    return null;
  }

  /// دانلود و ذخیره در کش محلی با گزارش دقیق پیشرفت بایت به بایت
  Future<String> downloadAndCache({
    required String id,
    required String url,
    required Function(double progress, int received, int total) onProgress,
    CancelToken? cancelToken,
  }) async {
    final dir = await _getCacheDirectory();
    final finalFile = File(p.join(dir.path, '$id.mp3'));
    final tempFile = File(p.join(dir.path, '${id}_temp.tmp'));

    if (await finalFile.exists() && (await finalFile.length()) > 0) {
      onProgress(1.0, await finalFile.length(), await finalFile.length());
      return finalFile.path;
    }

    try {
      await _dio.download(
        url,
        tempFile.path,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final ratio = (received / total).clamp(0.0, 1.0);
            onProgress(ratio, received, total);
          } else if (received > 0) {
            onProgress(0.5, received, total);
          }
        },
      );

      if (await tempFile.exists() && (await tempFile.length()) > 0) {
        if (await finalFile.exists()) {
          await finalFile.delete();
        }
        await tempFile.rename(finalFile.path);
        final len = await finalFile.length();
        onProgress(1.0, len, len);
        return finalFile.path;
      } else {
        throw Exception('فایل دانلود شده خالی است');
      }
    } catch (e) {
      if (await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
      rethrow;
    }
  }

  /// حذف فایل از کش
  Future<void> removeCache(String id) async {
    try {
      final dir = await _getCacheDirectory();
      final file = File(p.join(dir.path, '$id.mp3'));
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting cache: $e');
    }
  }
}
