import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:risetechpreneur/core/app_theme.dart';
import 'package:risetechpreneur/data/models.dart';
import 'package:risetechpreneur/data/providers.dart';
import 'package:risetechpreneur/presentation/screens/blog_detail_screen.dart';

/// Premium blogs list screen with featured blog, search, and grid layout.
class BlogsScreen extends ConsumerStatefulWidget {
  const BlogsScreen({super.key});

  @override
  ConsumerState<BlogsScreen> createState() => _BlogsScreenState();
}

class _BlogsScreenState extends ConsumerState<BlogsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final blogsState = ref.watch(blogsStateProvider);

    // Filter blogs by search query
    final filteredBlogs =
        blogsState.blogs.where((blog) {
          if (_searchQuery.isEmpty) return true;
          return blog.title.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              blog.tags.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => ref.read(blogsStateProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            // App Bar with gradient
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Blog',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primaryBlue, AppColors.secondaryNavy],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 60),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Center(
                          child: Text(
                            'Insights & Strategies for Tech Entrepreneurs',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 24,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search articles...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textGrey,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

            // Content
            _buildContent(context, blogsState, filteredBlogs),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    BlogsState state,
    List<BlogPost> filteredBlogs,
  ) {
    // Loading state
    if (state.isLoading && state.blogs.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _ShimmerBlogCard(),
            ),
            childCount: 4,
          ),
        ),
      );
    }

    // Error state
    if (state.error != null && state.blogs.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                'Failed to load blogs',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed:
                    () => ref.read(blogsStateProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (filteredBlogs.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _searchQuery.isNotEmpty
                    ? Icons.search_off
                    : Icons.article_outlined,
                size: 64,
                color: AppColors.textGrey.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty
                    ? 'No blogs match "$_searchQuery"'
                    : 'No blogs available',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppColors.textGrey),
              ),
            ],
          ),
        ),
      );
    }

    // Featured blog (first one) + regular list
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == 0 && filteredBlogs.isNotEmpty) {
            // Featured blog card
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _FeaturedBlogCard(
                blog: filteredBlogs.first,
                onTap: () => _navigateToBlog(context, filteredBlogs.first),
              ),
            );
          }

          final listIndex = index - 1;
          if (listIndex >= filteredBlogs.length - 1) {
            // Load more indicator
            if (state.hasMore && !state.isLoadingMore) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(blogsStateProvider.notifier).loadMore();
              });
            }
            if (state.isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _BlogListCard(
              blog: filteredBlogs[listIndex + 1],
              onTap: () =>
                  _navigateToBlog(context, filteredBlogs[listIndex + 1]),
            ),
          );
        }, childCount: filteredBlogs.length + (state.hasMore ? 1 : 0)),
      ),
    );
  }

  void _navigateToBlog(BuildContext context, BlogPost blog) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BlogDetailScreen(blog: blog)),
    );
  }
}

/// Featured blog card with large image
class _FeaturedBlogCard extends StatelessWidget {
  final BlogPost blog;
  final VoidCallback? onTap;

  const _FeaturedBlogCard({required this.blog, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              blog.imageUrl.isNotEmpty
                  ? Image.network(
                    blog.imageUrl,
                    fit: BoxFit.cover,
                    cacheWidth: 800,
                    errorBuilder:
                        (_, __, ___) => Container(
                          color: AppColors.primaryBlue.withValues(alpha: 0.2),
                          child: const Icon(
                            Icons.article,
                            size: 64,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                  )
                  : Container(
                    color: AppColors.primaryBlue.withValues(alpha: 0.2),
                    child: const Icon(
                      Icons.article,
                      size: 64,
                      color: AppColors.primaryBlue,
                    ),
                  ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
              // Featured badge
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'FEATURED',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Content
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tags
                    if (blog.tagsList.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        children:
                            blog.tagsList.take(2).map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    const SizedBox(height: 12),
                    // Title
                    Text(
                      blog.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Meta
                    Row(
                      children: [
                        Text(
                          blog.formattedDate,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          blog.readTime,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Regular blog list card
class _BlogListCard extends StatelessWidget {
  final BlogPost blog;
  final VoidCallback? onTap;

  const _BlogListCard({required this.blog, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 100,
                height: 100,
                child:
                    blog.imageUrl.isNotEmpty
                        ? Image.network(
                          blog.imageUrl,
                          fit: BoxFit.cover,
                          cacheWidth: 300,
                          errorBuilder:
                              (_, __, ___) => Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.article,
                                  color: AppColors.textGrey,
                                ),
                              ),
                        )
                        : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.article,
                            color: AppColors.textGrey,
                          ),
                        ),
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                  if (blog.tagsList.isNotEmpty)
                    Text(
                      blog.tagsList.take(2).map((t) => '#$t').join(' '),
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 6),
                  // Title
                  Text(
                    blog.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Meta
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textGrey.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${blog.formattedDate} • ${blog.readTime}',
                        style: TextStyle(
                          color: AppColors.textGrey.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textGrey,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading placeholder
class _ShimmerBlogCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
