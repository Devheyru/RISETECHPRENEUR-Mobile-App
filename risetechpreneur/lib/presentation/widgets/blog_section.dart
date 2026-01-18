import 'package:flutter/material.dart';
import 'package:risetechpreneur/data/models.dart';
import 'package:risetechpreneur/presentation/widgets/components.dart';

/// Home‑page section that surfaces a limited number of [BlogPost] items
/// with a "View All" button for navigation to full blogs list.
class BlogSection extends StatelessWidget {
  final List<BlogPost> blogs;
  final VoidCallback? onViewAll;
  final int maxDisplay;
  final bool isLoading;
  final String? error;

  const BlogSection({
    super.key,
    required this.blogs,
    this.onViewAll,
    this.maxDisplay = 3,
    this.isLoading = false,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (isLoading && blogs.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: "Latest Blog News",
            subtitle:
                "Explore our blog for expert advice\n and actionable strategies.",
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: List.generate(
                maxDisplay,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    height: 112,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Show error state
    if (error != null && blogs.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: "Latest Blog News",
            subtitle:
                "Explore our blog for expert advice\n and actionable strategies.",
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 32,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error ?? 'Failed to load blogs',
                    style: TextStyle(color: Colors.red.shade700),
                    textAlign: TextAlign.center,
                  ),
                  if (onViewAll != null) ...[
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: onViewAll,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Retry'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Show empty state
    if (blogs.isEmpty) {
      return const SizedBox.shrink();
    }

    final blogsToShow = blogs.take(maxDisplay).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: "Latest Blog News",
          subtitle:
              "Explore our blog for expert advice\n and actionable strategies.",
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children:
                blogsToShow
                    .map((blog) => RepaintBoundary(child: BlogCard(blog: blog)))
                    .toList(),
          ),
        ),
        // View All button
        if (onViewAll != null && blogs.length > maxDisplay)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: TextButton.icon(
                onPressed: onViewAll,
                icon: const Text(
                  "View All Blogs",
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
