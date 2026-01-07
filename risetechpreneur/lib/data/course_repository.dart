/// Repository for fetching courses from the RiseTechpreneur API.
library;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:risetechpreneur/core/constants.dart';
import 'package:risetechpreneur/core/error_handler.dart';
import 'package:risetechpreneur/data/models.dart';

/// Response wrapper for paginated courses data
class CoursesResponse {
  final List<Course> courses;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  const CoursesResponse({
    required this.courses,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  /// Check if there are more pages to load
  bool get hasMore => currentPage < lastPage;

  /// Factory constructor from API JSON response
  factory CoursesResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> data = json['data'] as List<dynamic>? ?? [];
    final courses =
        data
            .map((item) => Course.fromJson(item as Map<String, dynamic>))
            .toList();

    return CoursesResponse(
      courses: courses,
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      total: json['total'] as int? ?? 0,
      perPage: json['per_page'] as int? ?? defaultCoursesPerPage,
    );
  }
}

/// Repository class for handling course-related API operations
class CourseRepository {
  final http.Client _client;

  CourseRepository({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch paginated courses from the API
  ///
  /// [page] - Page number to fetch (1-indexed)
  /// [perPage] - Number of courses per page
  /// [category] - Optional category filter
  Future<CoursesResponse> getCourses({
    int page = 1,
    int perPage = defaultCoursesPerPage,
    String? category,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      final uri = Uri.parse(
        '$apiBaseUrl/courses',
      ).replace(queryParameters: queryParams);

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
        return CoursesResponse.fromJson(json);
      } else if (response.statusCode == 404) {
        throw AuthException(
          message: 'Courses not found',
          userFriendlyMessage: 'No courses found. Please try again later.',
          code: 'NOT_FOUND',
        );
      } else if (response.statusCode >= 500) {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      } else {
        throw AuthException(
          message: 'HTTP ${response.statusCode}: ${response.body}',
          userFriendlyMessage: 'Failed to load courses. Please try again.',
          code: 'HTTP_ERROR',
        );
      }
    } on SocketException {
      throw NetworkException();
    } on http.ClientException catch (e) {
      throw NetworkException(message: e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: e.toString(),
        userFriendlyMessage: 'Something went wrong. Please try again.',
        code: 'UNKNOWN',
      );
    }
  }

  /// Fetch a single course by ID
  Future<Course> getCourseById(int id) async {
    try {
      final uri = Uri.parse('$apiBaseUrl/courses/$id');

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
        // API might return course directly or wrapped in 'data'
        final courseData = json['data'] ?? json;
        return Course.fromJson(courseData as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw AuthException(
          message: 'Course not found',
          userFriendlyMessage: 'Course not found.',
          code: 'NOT_FOUND',
        );
      } else {
        throw AuthException(
          message: 'HTTP ${response.statusCode}',
          userFriendlyMessage: 'Failed to load course details.',
          code: 'HTTP_ERROR',
        );
      }
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: e.toString(),
        userFriendlyMessage: 'Something went wrong. Please try again.',
        code: 'UNKNOWN',
      );
    }
  }

  /// Dispose the HTTP client
  void dispose() {
    _client.close();
  }
}
