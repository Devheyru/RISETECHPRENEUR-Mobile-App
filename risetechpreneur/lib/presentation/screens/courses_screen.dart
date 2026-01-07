import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:risetechpreneur/core/app_theme.dart';
import 'package:risetechpreneur/data/models.dart';
import 'package:risetechpreneur/data/providers.dart';
import 'package:risetechpreneur/presentation/screens/course_detail_screen.dart';
import 'package:risetechpreneur/presentation/widgets/course_loading_shimmer.dart';

/// Displays the full catalog of courses with category filters.
///
/// Categories are rendered as horizontally scrollable chips; selecting one
/// updates the grid below without leaving the screen.
class CoursesScreen extends ConsumerStatefulWidget {
  const CoursesScreen({super.key});

  @override
  ConsumerState<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends ConsumerState<CoursesScreen> {
  String _selectedCategory = 'All';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Load more courses when scrolled to bottom
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(coursesStateProvider.notifier).loadMore();
    }
  }

  /// Filter courses by selected category
  List<Course> _filterCourses(List<Course> courses) {
    if (_selectedCategory == 'All') return courses;
    return courses.where((course) {
      // Match by category name (case-insensitive)
      return course.categoryName.toLowerCase() ==
              _selectedCategory.toLowerCase() ||
          course.category.toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();
  }

  /// Navigate to course detail screen
  void _openCourseDetail(Course course) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(course: course),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coursesState = ref.watch(coursesStateProvider);
    final categories = ref.watch(categoriesProvider);
    final filteredCourses = _filterCourses(coursesState.courses);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'All Courses',
          style: TextStyle(
            color: AppColors.secondaryNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (coursesState.total > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  '${coursesState.total} courses',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textGrey),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(coursesStateProvider.notifier).refresh(),
        color: AppColors.primaryBlue,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Categories Filter
            SliverToBoxAdapter(
              child: SizedBox(
                height: 60,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _CategoryChip(
                        label: 'All',
                        isActive: _selectedCategory == 'All',
                        onSelected:
                            () => setState(() => _selectedCategory = 'All'),
                      );
                    }
                    final category = categories[index - 1];
                    return _CategoryChip(
                      label: category.name,
                      icon: category.iconAsset,
                      isActive: _selectedCategory == category.name,
                      onSelected:
                          () =>
                              setState(() => _selectedCategory = category.name),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: categories.length + 1,
                ),
              ),
            ),

            // Content
            if (coursesState.isLoading && coursesState.courses.isEmpty)
              // Initial loading state
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: CoursesGridShimmer(itemCount: 6),
                ),
              )
            else if (coursesState.error != null && coursesState.courses.isEmpty)
              // Error state
              SliverFillRemaining(
                child: CoursesErrorWidget(
                  message: coursesState.error!,
                  onRetry:
                      () =>
                          ref.read(coursesStateProvider.notifier).loadCourses(),
                ),
              )
            else if (filteredCourses.isEmpty)
              // Empty state
              SliverFillRemaining(
                child: CoursesEmptyWidget(
                  category:
                      _selectedCategory != 'All' ? _selectedCategory : null,
                ),
              )
            else ...[
              // Courses Grid
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final course = filteredCourses[index];
                    return _GridCourseCard(
                      course: course,
                      onTap: () => _openCourseDetail(course),
                    );
                  }, childCount: filteredCourses.length),
                ),
              ),

              // Loading more indicator
              if (coursesState.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ),

              // Bottom spacing
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ],
        ),
      ),
    );
  }
}

// Grid-friendly Course Card without fixed width
class _GridCourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;

  const _GridCourseCard({required this.course, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image with feature badge
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      course.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      cacheWidth: 600,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
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
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
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
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Video indicator
                  if (course.hasVideo)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.play_circle_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              course.categoryName.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
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
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        course.title,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    course.formattedDuration,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Text(
                              "ETB ${course.price.toStringAsFixed(0)}",
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final String? icon;
  final bool isActive;
  final VoidCallback onSelected;

  const _CategoryChip({
    required this.label,
    this.icon,
    required this.isActive,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: isActive,
      onSelected: (_) => onSelected(),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Text(icon!), const SizedBox(width: 6)],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.secondaryNavy,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      selectedColor: AppColors.primaryBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.primaryBlue),
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
