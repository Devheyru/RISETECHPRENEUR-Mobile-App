import 'package:flutter/material.dart';
import 'package:risetechpreneur/core/app_theme.dart';
import 'package:risetechpreneur/data/models.dart';

/// Full blog detail screen with hero image, content, and tags.
class BlogDetailScreen extends StatelessWidget {
  final BlogPost blog;

  const BlogDetailScreen({super.key, required this.blog});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero Image App Bar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.white,
            leading: _buildCircularBackButton(context),
            actions: [
              _buildCircularButton(
                icon: Icons.share_outlined,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share feature coming soon!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Hero Image
                  if (blog.imageUrl.isNotEmpty)
                    Image.network(
                      blog.imageUrl,
                      fit: BoxFit.cover,
                      cacheWidth: 800,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            color: AppColors.primaryBlue.withValues(alpha: 0.2),
                            child: const Center(
                              child: Icon(
                                Icons.article,
                                size: 64,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                    )
                  else
                    Container(
                      color: AppColors.primaryBlue.withValues(alpha: 0.2),
                      child: const Center(
                        child: Icon(
                          Icons.article,
                          size: 64,
                          color: AppColors.primaryBlue,
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
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                  // Title overlay at bottom
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Text(
                      blog.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(0, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Blog Content
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta info bar
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Date
                        _MetaItem(
                          icon: Icons.calendar_today_outlined,
                          text: blog.formattedDate,
                        ),
                        const SizedBox(width: 24),
                        // Read time
                        _MetaItem(icon: Icons.access_time, text: blog.readTime),
                        const Spacer(),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                blog.isPublished
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            blog.isPublished ? 'Published' : 'Draft',
                            style: TextStyle(
                              color:
                                  blog.isPublished
                                      ? Colors.green
                                      : Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tags
                  if (blog.tagsList.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            blog.tagsList.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.primaryBlue.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: const TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),

                  // Subtitle
                  if (blog.subtitle != null && blog.subtitle!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Text(
                        blog.subtitle!,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: AppColors.textGrey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                  // Main Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: _FormattedContent(content: blog.content),
                  ),

                  // Bottom spacing
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularBackButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(icon: Icon(icon), onPressed: onPressed),
    );
  }
}

/// Meta item widget for date/read time
class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textGrey),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
        ),
      ],
    );
  }
}

/// Formats blog content with proper paragraphs and headings
class _FormattedContent extends StatelessWidget {
  final String content;

  const _FormattedContent({required this.content});

  @override
  Widget build(BuildContext context) {
    // Split content into paragraphs
    final paragraphs = content.split(RegExp(r'\r?\n\r?\n'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          paragraphs.map((paragraph) {
            final trimmed = paragraph.trim();
            if (trimmed.isEmpty) return const SizedBox.shrink();

            // Check if it's a numbered heading (e.g., "1. Generative & Trustworthy AI")
            final headingMatch = RegExp(
              r'^(\d+)\.\s+(.+)$',
            ).firstMatch(trimmed);
            if (headingMatch != null) {
              return Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          headingMatch.group(1)!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        headingMatch.group(2)!,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Regular paragraph
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                trimmed,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.7,
                  color: Colors.grey.shade800,
                ),
              ),
            );
          }).toList(),
    );
  }
}
