// lib/app/features/comment/controller/comment_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/network/api_client.dart';

class CommentController extends GetxController {
  final ApiClient _apiClient = Get.find();

  final RxBool isSubmitting = false.obs;
  final RxString error = ''.obs;
  final RxString success = ''.obs;

  Future<void> submitComment({
    required String title,
    required String content,
    required int pageNumber,
  }) async {
    try {
      isSubmitting.value = true;
      error.value = '';
      success.value = '';

      final response = await _apiClient.post(
        '/api/comment/create',
        data: {
          'title': title,
          'content': content,
          'page_number': pageNumber.toString(),
        },
        body: {},
      );

      print('Comment API Response: $response');

      if (response['status'] == true) {
        success.value = 'تم إرسال التعليق بنجاح';

        Get.snackbar(
          'نجاح',
          'تم إرسال التعليق بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        error.value = response['message'] ?? 'فشل في إرسال التعليق';

        Get.snackbar(
          'خطأ',
          error.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      error.value = 'خطأ في الإرسال: $e';
      print('Error submitting comment: $e');

      Get.snackbar(
        'خطأ',
        'فشل في الاتصال بالخادم',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> updateComment({
    required int id,
    required String title,
    required String content,
    required int pageNumber,
  }) async {
    try {
      isSubmitting.value = true;
      error.value = '';
      success.value = '';

      final response = await _apiClient.put(
        '/api/comment/$id/update',
        data: {
          'title': title,
          'content': content,
          'page_number': pageNumber.toString(),
        },
      );

      if (response['status'] == true) {
        success.value = 'تم تحديث التعليق بنجاح';

        Get.snackbar(
          'نجاح',
          'تم تحديث التعليق بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        error.value = response['message'] ?? 'فشل في تحديث التعليق';

        Get.snackbar(
          'خطأ',
          error.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      error.value = 'خطأ في التحديث: $e';

      Get.snackbar(
        'خطأ',
        'فشل في الاتصال بالخادم',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteComment(int id) async {
    try {
      isSubmitting.value = true;
      error.value = '';
      success.value = '';

      final response = await _apiClient.delete('/api/comment/$id/delete');

      if (response['status'] == true) {
        success.value = 'تم حذف التعليق بنجاح';

        Get.snackbar(
          'نجاح',
          'تم حذف التعلیق بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        error.value = response['message'] ?? 'فشل في حذف التعليق';

        Get.snackbar(
          'خطأ',
          error.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      error.value = 'خطأ في الحذف: $e';

      Get.snackbar(
        'خطأ',
        'فشل في الاتصال بالخادم',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
