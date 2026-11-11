// lib/app/core/network/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/constants/api_constants.dart';

class ApiClient extends GetxService {
  Uri _buildUri(String endpoint, [Map<String, String>? queryParameters]) {
    final isFullUrl =
        endpoint.startsWith('http://') || endpoint.startsWith('https://');
    final baseUri = isFullUrl
        ? Uri.parse(endpoint)
        : Uri.parse('${ApiConstants.baseUrl}$endpoint');
    return queryParameters != null && queryParameters.isNotEmpty
        ? baseUri.replace(queryParameters: queryParameters)
        : baseUri;
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);

      print('API GET Request: $uri');

      final requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (headers != null) ...headers,
      };

      final response = await http.get(uri, headers: requestHeaders);

      print('API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('فشل في جلب البيانات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
    required Map<String, double> body,
  }) async {
    try {
      final uri = _buildUri(endpoint);

      print('API POST Request: $uri');
      print('POST Data: $data');

      final requestHeaders = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
        if (headers != null) ...headers,
      };

      final response = await http.post(
        uri,
        headers: requestHeaders,
        body: _encodeFormData(data),
      );

      print('API POST Response Status: ${response.statusCode}');
      print('API POST Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('فشل في إرسال البيانات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الإرسال: $e');
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);

      print('API PUT Request: $uri');

      final requestHeaders = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
        if (headers != null) ...headers,
      };

      final response = await http.put(
        uri,
        headers: requestHeaders,
        body: _encodeFormData(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('فشل في تحديث البيانات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في التحديث: $e');
    }
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);

      print('API DELETE Request: $uri');

      final requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (headers != null) ...headers,
      };

      final response = await http.delete(uri, headers: requestHeaders);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('فشل في حذف البيانات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الحذف: $e');
    }
  }

  // تابع کمکی برای encode کردن data به فرم application/x-www-form-urlencoded
  String _encodeFormData(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return '';

    final pairs = <String>[];
    data.forEach((key, value) {
      pairs.add(
        '${Uri.encodeComponent(key)}=${Uri.encodeComponent(value.toString())}',
      );
    });

    return pairs.join('&');
  }

  // متد اضافی برای ارسال JSON
  Future<Map<String, dynamic>> postJson(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);

      print('API POST JSON Request: $uri');

      final requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (headers != null) ...headers,
      };

      final response = await http.post(
        uri,
        headers: requestHeaders,
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('فشل في إرسال البيانات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الإرسال: $e');
    }
  }
}
