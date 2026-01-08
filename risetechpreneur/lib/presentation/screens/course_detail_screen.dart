import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:risetechpreneur/core/app_theme.dart';
import 'package:risetechpreneur/core/constants.dart';
import 'package:risetechpreneur/data/auth_provider.dart';
import 'package:risetechpreneur/data/models.dart';
import 'package:risetechpreneur/presentation/screens/auth_screen.dart';
import 'package:url_launcher/url_launcher.dart';

/// Full-featured course detail screen with hero image, tabs, and enrollment.
/// Uses NestedScrollView for proper scroll handling with tabs.
class CourseDetailScreen extends ConsumerStatefulWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleEnrollment() {
    final user = ref.read(authProvider);
    if (user == null) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const AuthScreen()));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to enroll in this course'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      _launchCourseUrl();
    }
  }

  Future<void> _launchCourseUrl() async {
    final url = Uri.parse('$assetsBaseUrl/courses/${widget.course.slug}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open course page'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // Collapsing App Bar with Hero Image
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              floating: false,
              forceElevated: innerBoxIsScrolled,
              backgroundColor: Colors.white,
              foregroundColor:
                  innerBoxIsScrolled ? AppColors.secondaryNavy : Colors.white,
              leading: _buildCircularButton(
                icon: Icons.arrow_back,
                onPressed: () => Navigator.of(context).pop(),
                showBackground: !innerBoxIsScrolled,
              ),
              actions: [
                _buildCircularButton(
                  icon: Icons.share,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share feature coming soon!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  showBackground: !innerBoxIsScrolled,
                ),
              ],
              title: AnimatedOpacity(
                opacity: innerBoxIsScrolled ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  course.title,
                  style: const TextStyle(
                    color: AppColors.secondaryNavy,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: RepaintBoundary(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Hero Image with caching
                      Image.network(
                        course.imageUrl,
                        fit: BoxFit.cover,
                        cacheWidth: 800,
                        frameBuilder: (context, child, frame, loaded) {
                          if (loaded) return child;
                          return AnimatedOpacity(
                            opacity: frame != null ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: child,
                          );
                        },
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              color: AppColors.primaryBlue.withValues(
                                alpha: 0.2,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.school,
                                  size: 64,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.5),
                            ],
                          ),
                        ),
                      ),
                      // Video play button
                      if (course.hasVideo)
                        Center(
                          child: GestureDetector(
                            onTap: () => _playVideo(course.videoUrl!),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                size: 48,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Course Info Section
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badges row
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _CourseBadge(
                          text: course.categoryName,
                          color: AppColors.primaryBlue,
                        ),
                        if (course.isNew)
                          const _CourseBadge(text: 'NEW', color: Colors.green),
                        if (course.isFeatured)
                          const _CourseBadge(
                            text: 'FEATURED',
                            color: AppColors.accentYellow,
                          ),
                        _CourseBadge(
                          text: course.experienceLevel,
                          color: _getExperienceColor(course.experience),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      course.title,
                      style: Theme.of(
                        context,
                      ).textTheme.displayMedium?.copyWith(fontSize: 24),
                    ),
                    if (course.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        course.subtitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Stats row - use Flexible to prevent overflow
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _StatChip(
                            icon: Icons.access_time,
                            text: course.formattedDuration,
                          ),
                          const SizedBox(width: 16),
                          _StatChip(
                            icon: Icons.school_outlined,
                            text: course.educationTarget,
                          ),
                          if (course.hasVideo) ...[
                            const SizedBox(width: 16),
                            const _StatChip(
                              icon: Icons.play_circle_outline,
                              text: 'Video',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sticky Tab Bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primaryBlue,
                  unselectedLabelColor: AppColors.textGrey,
                  indicatorColor: AppColors.primaryBlue,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Curriculum'),
                    Tab(text: 'Reviews'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _OverviewTab(course: course),
            const _CurriculumTab(),
            const _ReviewsTab(),
          ],
        ),
      ),

      // Fixed bottom bar with price and enroll button
      bottomNavigationBar: _EnrollmentBar(
        course: course,
        onEnroll: _handleEnrollment,
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool showBackground,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            showBackground
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: IconButton(icon: Icon(icon), onPressed: onPressed),
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

  Future<void> _playVideo(String videoUrl) async {
    final url = Uri.parse(videoUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not play video'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// ============================================================================
// EXTRACTED WIDGETS FOR PERFORMANCE (const-ified where possible)
// ============================================================================

/// Course badge widget - extracted for const optimization
class _CourseBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _CourseBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Stat chip widget - extracted for const optimization
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _StatChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.textGrey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
        ),
      ],
    );
  }
}

/// Enrollment bar - extracted for cleaner code
class _EnrollmentBar extends StatelessWidget {
  final Course course;
  final VoidCallback onEnroll;

  const _EnrollmentBar({required this.course, required this.onEnroll});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Price
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textGrey),
                ),
                Text(
                  'ETB ${course.price.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 24,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            // Enroll button
            Expanded(
              child: ElevatedButton(
                onPressed: onEnroll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Enroll Now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Overview tab content - separated for performance
class _OverviewTab extends StatelessWidget {
  final Course course;

  const _OverviewTab({required this.course});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'About This Course',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          course.description.isNotEmpty
              ? course.description
              : 'No description available for this course.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
        ),
        const SizedBox(height: 32),

        // What you'll learn section
        Text(
          'What You\'ll Learn',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...course.learningPoints.map((point) => _LearningPoint(text: point)),
        const SizedBox(height: 32),

        // Requirements section
        Text(
          'Requirements',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const _RequirementItem(text: 'A computer with internet access'),
        const _RequirementItem(text: 'Dedication and willingness to learn'),
        _RequirementItem(text: 'Target Level: ${course.educationTarget}'),
        const SizedBox(height: 48),
      ],
    );
  }
}

/// Learning point widget - extracted for const optimization
class _LearningPoint extends StatelessWidget {
  final String text;

  const _LearningPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.green, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

/// Requirement item widget - extracted for const optimization
class _RequirementItem extends StatelessWidget {
  final String text;

  const _RequirementItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_right, color: AppColors.textGrey, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

/// Curriculum tab - placeholder with proper scroll handling
class _CurriculumTab extends StatelessWidget {
  const _CurriculumTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.4,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 64,
              color: AppColors.textGrey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Curriculum Coming Soon',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.secondaryNavy),
            ),
            const SizedBox(height: 8),
            Text(
              'Detailed course curriculum will be available after enrollment.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Reviews tab - placeholder with proper scroll handling
class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.4,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: AppColors.textGrey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Reviews Coming Soon',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.secondaryNavy),
            ),
            const SizedBox(height: 8),
            Text(
              'Student reviews will be displayed here once available.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Sticky tab bar delegate for persistent tabs
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  const _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
