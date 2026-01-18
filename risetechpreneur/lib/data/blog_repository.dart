import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:risetechpreneur/core/constants.dart';
import 'package:risetechpreneur/core/error_handler.dart';
import 'package:risetechpreneur/data/models.dart';

/// Response model for paginated blogs API
class BlogsResponse {
  final List<BlogPost> blogs;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMore;

  const BlogsResponse({
    required this.blogs,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMore,
  });

  factory BlogsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List? ?? [];
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};

    final blogs =
        data.map((e) => BlogPost.fromJson(e as Map<String, dynamic>)).toList();
    final currentPage = pagination['current_page'] as int? ?? 1;
    final lastPage = pagination['last_page'] as int? ?? 1;

    return BlogsResponse(
      blogs: blogs,
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: pagination['per_page'] as int? ?? 6,
      total: pagination['total'] as int? ?? blogs.length,
      hasMore: currentPage < lastPage,
    );
  }
}

/// Repository for blog-related API operations
class BlogRepository {
  final http.Client _client;

  BlogRepository({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch blogs with pagination
  Future<BlogsResponse> getBlogs({int page = 1, int size = 6}) async {
    try {
      final uri = Uri.parse('$apiBaseUrl/blogs').replace(
        queryParameters: {'page': page.toString(), 'size': size.toString()},
      );

      final response = await _client
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return BlogsResponse.fromJson(json);
      } else if (response.statusCode == 404) {
        throw ApiException(
          message: 'Blogs not found',
          userFriendlyMessage: 'No blogs found. Please try again later.',
          code: 'NOT_FOUND',
        );
      } else if (response.statusCode >= 500) {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      } else {
        throw ApiException(
          message: 'HTTP ${response.statusCode}: ${response.body}',
          userFriendlyMessage: 'Failed to load blogs. Please try again.',
          code: 'HTTP_ERROR',
        );
      }
    } on ApiException {
      rethrow;
    } on ServerException {
      rethrow;
    } on http.ClientException catch (e) {
      throw NetworkException(message: 'Network error: ${e.message}');
    } catch (e) {
      debugPrint('BlogRepository.getBlogs error: $e');
      throw ApiException(
        message: e.toString(),
        userFriendlyMessage:
            'Failed to load blogs. Please check your connection.',
        code: 'UNKNOWN',
      );
    }
  }

  /// Dispose the HTTP client
  void dispose() {
    _client.close();
  }
}
