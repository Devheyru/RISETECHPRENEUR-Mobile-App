/// Core domain models used across the RiseTechpreneur app.
library;

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
    required this.createdAt,
    required this.updatedAt,
  });

  /// Full thumbnail URL with base URL prefix
  String get imageUrl => '$assetsBaseUrl/$thumbnail';

  /// Full video URL with base URL prefix (if available)
  String? get videoUrl =>
      overviewVideo != null ? '$assetsBaseUrl/$overviewVideo' : null;

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
    return Course(
      id: json['id'] as int,
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
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
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

/// Lightweight representation of a marketing / content blog post.
class BlogPost {
  final String id;
  final String title;
  final String date;
  final String imageUrl;

  const BlogPost({
    required this.id,
    required this.title,
    required this.date,
    required this.imageUrl,
  });
}
