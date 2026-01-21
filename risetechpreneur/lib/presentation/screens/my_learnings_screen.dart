import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:risetechpreneur/core/app_theme.dart';
import 'package:risetechpreneur/core/error_handler.dart';
import 'package:risetechpreneur/data/auth_provider.dart';
import 'package:risetechpreneur/data/models.dart';
import 'package:risetechpreneur/data/my_learnings_merge.dart';
import 'package:risetechpreneur/data/order_models.dart';
import 'package:risetechpreneur/data/order_providers.dart';
import 'package:risetechpreneur/data/providers.dart';
import 'package:risetechpreneur/presentation/screens/auth_screen.dart';
import 'package:risetechpreneur/presentation/screens/course_detail_screen.dart';
import 'package:risetechpreneur/presentation/widgets/enrollment_status_badge.dart';

class MyLearningsScreen extends ConsumerWidget {
  const MyLearningsScreen({super.key});

  void _openCourse(BuildContext context, Course course) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(course: course),
      ),
    );
  }

  void _openAuth(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AuthScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'My Learnings',
            style: TextStyle(
              color: AppColors.secondaryNavy,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 40,
                  color: AppColors.textGrey,
                ),
                const SizedBox(height: 12),
                Text(
                  'Sign in to view your enrolled courses.',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textGrey),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _openAuth(context),
                  child: const Text('Sign in'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final learningsAsync = ref.watch(myLearningsProvider);
    final pendingAsync = ref.watch(pendingSubmissionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Learnings',
          style: TextStyle(
            color: AppColors.secondaryNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryBlue,
        onRefresh: () async {
          ref.invalidate(myLearningsProvider);
          ref.invalidate(pendingSubmissionsProvider);
          try {
            await ref.read(myLearningsProvider.future);
          } catch (_) {
            // handled by UI state
          }
        },
        child: learningsAsync.when(
          loading: () {
            return const _CenteredProgress();
          },
          error: (error, st) {
            final message = ErrorHandler.handleError(error, st);
            final showAuthCta =
                error is AuthException &&
                (error.code == 'UNAUTHORIZED' ||
                    error.message.toLowerCase().contains('unauthorized'));

            return _ErrorState(
              message: message,
              primaryLabel: showAuthCta ? 'Sign in' : 'Retry',
              onPrimary:
                  showAuthCta
                      ? () => _openAuth(context)
                      : () {
                        ref.invalidate(myLearningsProvider);
                      },
            );
          },
          data: (learnings) {
            return pendingAsync.when(
              loading: () {
                // Show the server list immediately while pending cache loads.
                return _LearningsList(
                  learnings: learnings,
                  pendingOnly: const <PendingSubmission>[],
                  onOpenCourse: (course) => _openCourse(context, course),
                );
              },
              error: (error, st) {
                // Pending cache is optional; render server list and log.
                ErrorHandler.logError(error, st);
                return _LearningsList(
                  learnings: learnings,
                  pendingOnly: const <PendingSubmission>[],
                  onOpenCourse: (course) => _openCourse(context, course),
                );
              },
              data: (pendingByCourseId) {
                final merge = mergeMyLearningsPendingOnly(
                  serverCourseIds: learnings.map((e) => e.course.id).toList(),
                  pendingByCourseId: pendingByCourseId,
                );

                return _LearningsList(
                  learnings: learnings,
                  pendingOnly: merge.pendingOnly,
                  onOpenCourse: (course) => _openCourse(context, course),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CenteredProgress extends StatelessWidget {
  const _CenteredProgress();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;

  const _ErrorState({
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, color: AppColors.textGrey, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textGrey),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onPrimary, child: Text(primaryLabel)),
          ],
        ),
      ),
    );
  }
}

class _LearningsList extends ConsumerWidget {
  final List<Learning> learnings;
  final List<PendingSubmission> pendingOnly;
  final ValueChanged<Course> onOpenCourse;

  const _LearningsList({
    required this.learnings,
    required this.pendingOnly,
    required this.onOpenCourse,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (learnings.isEmpty && pendingOnly.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No enrollments yet.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textGrey),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (pendingOnly.isNotEmpty) ...[
          Text(
            'Pending submissions',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...pendingOnly.map((p) {
            final courseAsync = ref.watch(courseByIdProvider(p.courseId));
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: courseAsync.when(
                loading:
                    () => _LearningCard.loading(
                      status: p.status,
                      subtitle: 'Saved locally',
                    ),
                error: (error, st) {
                  ErrorHandler.logError(error, st);
                  return _LearningCard(
                    title: 'Course #${p.courseId}',
                    subtitle: 'Saved locally',
                    status: p.status,
                    thumbnailUrl: null,
                    onTap: null,
                  );
                },
                data: (course) {
                  return _LearningCard(
                    title: course.title,
                    subtitle: 'Saved locally',
                    status: p.status,
                    thumbnailUrl: course.imageUrl,
                    onTap: () => onOpenCourse(course),
                  );
                },
              ),
            );
          }),
          const SizedBox(height: 8),
          const Divider(height: 24),
        ],

        Text(
          'From server',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        ...learnings.map((l) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _LearningCard(
              title: l.course.title,
              subtitle: l.course.categoryName,
              status: l.status,
              thumbnailUrl: l.course.imageUrl,
              onTap: () => onOpenCourse(l.course),
            ),
          );
        }),
      ],
    );
  }
}

class _LearningCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final OrderStatus status;
  final String? thumbnailUrl;
  final VoidCallback? onTap;

  const _LearningCard({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.thumbnailUrl,
    required this.onTap,
  });

  const _LearningCard.loading({required this.status, this.subtitle})
    : title = 'Loading…',
      thumbnailUrl = null,
      onTap = null;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
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
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 56,
                width: 56,
                child:
                    thumbnailUrl == null
                        ? Container(color: AppColors.background)
                        : Image.network(
                          thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: AppColors.background,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: AppColors.textGrey,
                                ),
                              ),
                        ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.secondaryNavy,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  EnrollmentStatusBadge(status: status),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}
