import 'package:flutter/material.dart';
import 'package:risetechpreneur/core/app_theme.dart';
import 'package:risetechpreneur/data/models.dart';
import 'package:risetechpreneur/presentation/screens/course_detail_screen.dart';
import 'package:risetechpreneur/presentation/widgets/components.dart';
import 'package:risetechpreneur/presentation/widgets/course_loading_shimmer.dart';

/// Home‑page section that highlights a curated list of popular courses
/// with optional "View All" navigation and performance optimizations.
class PopularCoursesSection extends StatelessWidget {
  final List<Course> courses;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;
  final VoidCallback? onViewAll;
  final int maxDisplay;

  const PopularCoursesSection({
    super.key,
    required this.courses,
    this.isLoading = false,
    this.error,
    this.onRetry,
    this.onViewAll,
    this.maxDisplay = 3,
  });

  void _navigateToCourse(BuildContext context, Course course) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(course: course),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (isLoading && courses.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: "Popular Courses",
            subtitle:
                "Explore our diverse range of tech courses\ndesigned to equip you with the skills and knowledge",
          ),
          ListView.builder(
            padding: const EdgeInsets.only(left: 24, right: 8),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: maxDisplay,
            itemBuilder:
                (context, index) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CourseCarouselShimmer(),
                ),
          ),
        ],
      );
    }

    // Show error state
    if (error != null && courses.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: "Popular Courses",
            subtitle:
                "Explore our diverse range of tech courses\ndesigned to equip you with the skills and knowledge",
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Failed to load courses',
                    style: TextStyle(
                      color: AppColors.secondaryNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (onRetry != null)
                    TextButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Show empty state
    if (courses.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: "Popular Courses",
            subtitle:
                "Explore our diverse range of tech courses\ndesigned to equip you with the skills and knowledge",
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 48,
                    color: AppColors.textGrey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No courses available',
                    style: TextStyle(
                      color: AppColors.secondaryNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final coursesToShow = courses.take(maxDisplay).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: "Popular Courses",
          subtitle:
              "Explore our diverse range of tech courses\ndesigned to equip you with the skills and knowledge",
        ),

        ListView.builder(
          padding: const EdgeInsets.only(left: 24, right: 8),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
          itemCount: coursesToShow.length,
          itemBuilder:
              (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: RepaintBoundary(
                  child: _PopularCourseCard(
                    course: coursesToShow[index],
                    onTap:
                        () => _navigateToCourse(context, coursesToShow[index]),
                  ),
                ),
              ),
        ),

        // View All button
        if (onViewAll != null && courses.length > maxDisplay)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: TextButton.icon(
                onPressed: onViewAll,
                icon: const Text(
                  "View All Courses",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                label: const Icon(Icons.arrow_forward, size: 18),
              ),
            ),
          ),
      ],
    );
  }
}

/// Improved course card for popular courses section with feature badges
class _PopularCourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;

  const _PopularCourseCard({required this.course, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    course.imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    cacheHeight: 400,
                    cacheWidth: 800,
                    key: ValueKey(course.imageUrl),
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          height: 160,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ),
                  ),
                ),
                // Feature badge
                if (course.isNew || course.isFeatured)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            course.isNew
                                ? Colors.green
                                : AppColors.accentYellow,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        course.isNew ? 'NEW' : 'FEATURED',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Video indicator
                if (course.hasVideo)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withAlpha(26),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          course.categoryName.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _getExperienceColor(
                            course.experience,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          course.experienceLevel,
                          style: TextStyle(
                            color: _getExperienceColor(course.experience),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (course.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      course.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            course.formattedDuration,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "ETB ${course.price.toStringAsFixed(0)}",
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "View",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getExperienceColor(String experience) {
    switch (experience.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return AppColors.textGrey;
    }
  }
}
