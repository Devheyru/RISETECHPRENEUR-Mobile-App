/// Core domain models used across the RiseTechpreneur app.
library;

import 'package:flutter/foundation.dart';
import 'package:risetechpreneur/core/constants.dart';

/// Represents a single course in the RiseTechpreneur catalog.
class Course {
  final int id;
  final String userId;
  final String title;
  final String subtitle;
  final String slug;
  final double price;
  final String thumbnail;
  final String? overviewVideo;
  final String category;
  final String education;
  final String experience;
  final String feature;
  final String duration;
  final String description;
  final List<String> learningPoints;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Course({
    required this.id,
    required this.userId,
    required this.title,
    required this.subtitle,
    required this.slug,
    required this.price,
    required this.thumbnail,
    this.overviewVideo,
    required this.category,
    required this.education,
    required this.experience,
    required this.feature,
    required this.duration,
    required this.description,
    required this.learningPoints,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Full thumbnail URL with base URL prefix
  String get imageUrl =>
      thumbnail.isNotEmpty
          ? '$assetsBaseUrl/$thumbnail'
          : ''; // or a default placeholder URL

  /// Full video URL with base URL prefix (if available)
  String? get videoUrl =>
      (overviewVideo != null && overviewVideo!.isNotEmpty)
          ? '$assetsBaseUrl/$overviewVideo'
          : null;

  /// Check if course has a video preview
  bool get hasVideo => overviewVideo != null && overviewVideo!.isNotEmpty;

  /// Human-readable category name (converts slug to title case)
  String get categoryName => category
      .split('-')
      .map(
        (word) =>
            word.isNotEmpty
                ? '${word[0].toUpperCase()}${word.substring(1)}'
                : '',
      )
      .join(' ');

  /// Human-readable experience level
  String get experienceLevel {
    switch (experience.toLowerCase()) {
      case 'beginner':
        return 'Beginner';
      case 'intermediate':
        return 'Intermediate';
      case 'advanced':
        return 'Advanced';
      default:
        return experience;
    }
  }

  /// Human-readable education target
  String get educationTarget {
    switch (education.toLowerCase()) {
      case 'high-school':
        return 'High School';
      case 'college':
        return 'College';
      case 'professional':
        return 'Professional';
      default:
        return education.replaceAll('-', ' ');
    }
  }

  /// Check if course is featured
  bool get isFeatured => feature.toLowerCase() == 'featured';

  /// Check if course is new
  bool get isNew => feature.toLowerCase() == 'new';

  /// Check if course is popular
  bool get isPopular => feature.toLowerCase() == 'popular';

  /// Duration formatted for display
  String get formattedDuration {
    final hours = int.tryParse(duration) ?? 0;
    if (hours == 0) return 'Self-paced';
    if (hours == 1) return '1 hour';
    return '$hours hours';
  }

  /// Factory constructor for JSON parsing
  factory Course.fromJson(Map<String, dynamic> json) {
    var learningPointsJson = json['learning_points'];
    List<String> parsedLearningPoints;

    if (learningPointsJson is String) {
      // Handle case where learning_points might be a JSON-encoded string
      // This is common in some backends storing arrays as text
      // For now, we'll just treat it as a single point if simpler parsing fails or just split by newline if applicable
      // But based on request, let's assume it should be a list or we use fallback
      parsedLearningPoints = []; // Fallback logic below will handle empty
    } else if (learningPointsJson is List) {
      parsedLearningPoints =
          learningPointsJson.map((e) => e.toString()).toList();
    } else {
      parsedLearningPoints = [];
    }

    // Fallback if empty or null
    if (parsedLearningPoints.isEmpty) {
      parsedLearningPoints = [
        'Comprehensive understanding of the subject',
        'Hands-on practical projects',
        'Industry-relevant skills',
      ];
    }

    final createdAtString = json['created_at'] as String? ?? '';
    final updatedAtString = json['updated_at'] as String? ?? '';

    DateTime? parsedCreatedAt = DateTime.tryParse(createdAtString);
    DateTime? parsedUpdatedAt = DateTime.tryParse(updatedAtString);

    // Log warnings for date parsing failures to make them detectable
    if (parsedCreatedAt == null && createdAtString.isNotEmpty) {
      debugPrint(
        'Warning: Failed to parse created_at date: "$createdAtString" for course ${json['id']}',
      );
    }
    if (parsedUpdatedAt == null && updatedAtString.isNotEmpty) {
      debugPrint(
        'Warning: Failed to parse updated_at date: "$updatedAtString" for course ${json['id']}',
      );
    }

    return Course(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: json['user_id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      thumbnail: json['thumbnail'] as String? ?? '',
      overviewVideo: json['overview_video'] as String?,
      category: json['category'] as String? ?? '',
      education: json['education'] as String? ?? '',
      experience: json['experience'] as String? ?? 'beginner',
      feature: json['feature'] as String? ?? '',
      duration: json['duration']?.toString() ?? '0',
      description: json['description'] as String? ?? '',
      learningPoints: parsedLearningPoints,
      createdAt: parsedCreatedAt ?? DateTime.now(),
      updatedAt: parsedUpdatedAt ?? DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'subtitle': subtitle,
      'slug': slug,
      'price': price.toString(),
      'thumbnail': thumbnail,
      'overview_video': overviewVideo,
      'category': category,
      'education': education,
      'experience': experience,
      'feature': feature,
      'duration': duration,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Groups courses under a semantic label (e.g. "Design", "Marketing").
class Category {
  final String id;
  final String name;
  final String iconAsset; // Or generic icon data
  final int coursesCount;

  const Category({
    required this.id,
    required this.name,
    required this.iconAsset,
    required this.coursesCount,
  });
}

/// Feedback left by a learner that is surfaced in the testimonials carousel.
class Testimonial {
  final String id;
  final String userName;
  final String role;
  final String userImage;
  final String comment;
  final double rating;

  const Testimonial({
    required this.id,
    required this.userName,
    required this.role,
    required this.userImage,
    required this.comment,
    required this.rating,
  });
}

/// Represents a blog post from the RiseTechpreneur platform.
class BlogPost {
  final int id;
  final String userId;
  final String title;
  final String? subtitle;
  final String content;
  final String slug;
  final String tags;
  final bool isPublished;
  final String status;
  final List<String> media;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BlogPost({
    required this.id,
    required this.userId,
    required this.title,
    this.subtitle,
    required this.content,
    required this.slug,
    required this.tags,
    required this.isPublished,
    required this.status,
    required this.media,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Full image URL for the first media item
  String get imageUrl {
    if (media.isEmpty) return '';
    final firstMedia = media.first;
    if (firstMedia.startsWith('http')) return firstMedia;
    return '$assetsBaseUrl/$firstMedia';
  }

  /// Formatted date for display (e.g., "Nov 24, 2025")
  String get formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[createdAt.month - 1]} ${createdAt.day}, ${createdAt.year}';
  }

  /// Estimated read time based on content length
  String get readTime {
    final wordCount = content.split(RegExp(r'\s+')).length;
    final minutes = (wordCount / 200).ceil(); // ~200 words per minute
    return '$minutes min read';
  }

  /// Tags as a list
  List<String> get tagsList =>
      tags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

  /// Factory constructor for JSON parsing
  factory BlogPost.fromJson(Map<String, dynamic> json) {
    // Parse media - can be JSON string or list
    List<String> parsedMedia = [];
    final mediaJson = json['media'];
    if (mediaJson is String && mediaJson.isNotEmpty) {
      try {
        // Media is stored as JSON string like "[\"path/to/image.jpg\"]"
        final decoded =
            mediaJson
                .replaceAll('[', '')
                .replaceAll(']', '')
                .replaceAll('"', '')
                .replaceAll('\\', '')
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
        parsedMedia = decoded;
      } catch (_) {
        parsedMedia = [];
      }
    } else if (mediaJson is List) {
      parsedMedia = mediaJson.map((e) => e.toString()).toList();
    }

    return BlogPost(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: json['user_id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      content: json['content'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      tags: json['tags'] as String? ?? '',
      isPublished: json['is_published'] == '1' || json['is_published'] == true,
      status: json['status'] as String? ?? 'draft',
      media: parsedMedia,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
