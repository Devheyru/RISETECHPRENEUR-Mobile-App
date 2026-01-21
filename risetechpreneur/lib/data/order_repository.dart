library;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/http.dart' show MultipartFile;
import 'package:risetechpreneur/core/constants.dart';
import 'package:risetechpreneur/core/error_handler.dart';
import 'package:risetechpreneur/data/order_models.dart';

class OrderRepository {
  final http.Client _client;

  OrderRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<Order> placeOrder({
    required int courseId,
    required File screenshot,
    required String token,
  }) async {
    try {
      final uri = Uri.parse('$apiBaseUrl/orders/place');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      request.fields['course_id'] = courseId.toString();
      request.files.add(
        await MultipartFile.fromPath('transaction_screenshot', screenshot.path),
      );

      final streamedResponse = await _client
          .send(request)
          .timeout(const Duration(seconds: 15));
      final body = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        final json = jsonDecode(body);
        if (json is! Map<String, dynamic>) {
          throw ApiException(
            message: 'Unexpected response format',
            userFriendlyMessage:
                'Something went wrong. Please try again later.',
            code: 'BAD_RESPONSE',
          );
        }

        final orderJson = json['order'];
        if (orderJson is! Map<String, dynamic>) {
          throw ApiException(
            message: 'Missing order in response',
            userFriendlyMessage:
                'Something went wrong. Please try again later.',
            code: 'BAD_RESPONSE',
          );
        }

        return Order.fromJson(orderJson);
      }

      if (streamedResponse.statusCode == 401) {
        throw AuthException(
          message: 'Unauthorized',
          userFriendlyMessage: 'Session expired. Please sign in again.',
          code: 'UNAUTHORIZED',
        );
      }

      if (streamedResponse.statusCode >= 500) {
        throw ServerException(
          message: 'Server error: ${streamedResponse.statusCode}',
        );
      }

      // Try to extract backend message.
      try {
        final parsed = jsonDecode(body);
        if (parsed is Map<String, dynamic>) {
          final message =
              parsed['message']?.toString() ?? parsed['error']?.toString();
          if (message != null && message.trim().isNotEmpty) {
            throw ApiException(
              message: message,
              userFriendlyMessage: message,
              code: 'HTTP_${streamedResponse.statusCode}',
            );
          }
        }
      } catch (_) {
        // ignore parse errors
      }

      throw ApiException(
        message: 'HTTP ${streamedResponse.statusCode}: $body',
        userFriendlyMessage: 'Failed to submit enrollment. Please try again.',
        code: 'HTTP_${streamedResponse.statusCode}',
      );
    } on SocketException {
      throw NetworkException();
    } on http.ClientException catch (e) {
      throw NetworkException(message: e.message);
    } catch (e) {
      if (e is AuthException || e is ApiException || e is ServerException) {
        rethrow;
      }
      throw ApiException(
        message: e.toString(),
        userFriendlyMessage: 'Something went wrong. Please try again.',
        code: 'UNKNOWN',
      );
    }
  }

  Future<List<Learning>> fetchMyLearnings({required String token}) async {
    try {
      final uri = Uri.parse('$apiBaseUrl/my-learnings');
      final response = await _client
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json is! Map<String, dynamic>) {
          throw ApiException(
            message: 'Unexpected response format',
            userFriendlyMessage:
                'Something went wrong. Please try again later.',
            code: 'BAD_RESPONSE',
          );
        }

        final data = json['data'];
        if (data is! List) return const <Learning>[];
        return data
            .whereType<Map<String, dynamic>>()
            .map(Learning.fromJson)
            .toList();
      }

      if (response.statusCode == 401) {
        throw AuthException(
          message: 'Unauthorized',
          userFriendlyMessage: 'Session expired. Please sign in again.',
          code: 'UNAUTHORIZED',
        );
      }

      if (response.statusCode >= 500) {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }

      throw ApiException(
        message: 'HTTP ${response.statusCode}: ${response.body}',
        userFriendlyMessage:
            'Failed to load your enrollments. Please try again.',
        code: 'HTTP_${response.statusCode}',
      );
    } on SocketException {
      throw NetworkException();
    } on http.ClientException catch (e) {
      throw NetworkException(message: e.message);
    } catch (e) {
      if (e is AuthException || e is ApiException || e is ServerException) {
        rethrow;
      }
      throw ApiException(
        message: e.toString(),
        userFriendlyMessage: 'Something went wrong. Please try again.',
        code: 'UNKNOWN',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}
