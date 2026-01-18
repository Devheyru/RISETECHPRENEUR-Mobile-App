import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:risetechpreneur/core/constants.dart';
import 'package:risetechpreneur/data/blog_repository.dart';
import 'package:risetechpreneur/data/course_repository.dart';
import 'models.dart';

// ============================================================================
// COURSE PROVIDERS (API-INTEGRATED)
// ============================================================================

/// Repository provider for dependency injection
final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  final repository = CourseRepository();
  ref.onDispose(() => repository.dispose());
  return repository;
});

/// State class for courses with loading and pagination
class CoursesState {
  final List<Course> courses;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasMore;

  const CoursesState({
    this.courses = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 0,
    this.lastPage = 1,
    this.total = 0,
    this.hasMore = true,
  });

  CoursesState copyWith({
    List<Course>? courses,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? hasMore,
  }) {
    return CoursesState(
      courses: courses ?? this.courses,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  /// Check if initial data has been loaded
  bool get hasData => courses.isNotEmpty || (!isLoading && error == null);
}

/// StateNotifier for managing courses state and API operations
class CoursesNotifier extends StateNotifier<CoursesState> {
  final CourseRepository _repository;

  CoursesNotifier(this._repository) : super(const CoursesState()) {
    // Auto-load courses on initialization
    loadCourses();
  }

  /// Load initial courses (first page)
  Future<void> loadCourses() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repository.getCourses(
        page: 1,
        perPage: defaultCoursesPerPage,
      );

      state = state.copyWith(
        courses: response.courses,
        isLoading: false,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        total: response.total,
        hasMore: response.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load more courses (next page)
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final response = await _repository.getCourses(
        page: nextPage,
        perPage: defaultCoursesPerPage,
      );

      state = state.copyWith(
        courses: [...state.courses, ...response.courses],
        isLoadingMore: false,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        total: response.total,
        hasMore: response.hasMore,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        // Don't set error for load more failures, just stop loading
      );
      debugPrint('Failed to load more courses: $e');
    }
  }

  /// Refresh courses (pull-to-refresh)
  Future<void> refresh() async {
    state = state.copyWith(currentPage: 0, hasMore: true, error: null);
    await loadCourses();
  }
}

/// Main courses state provider
final coursesStateProvider =
    StateNotifierProvider<CoursesNotifier, CoursesState>((ref) {
      final repository = ref.watch(courseRepositoryProvider);
      return CoursesNotifier(repository);
    });

/// Convenience provider to get just the courses list
final coursesListProvider = Provider<List<Course>>((ref) {
  return ref.watch(coursesStateProvider).courses;
});

/// Provider for checking if courses are loading
final coursesLoadingProvider = Provider<bool>((ref) {
  return ref.watch(coursesStateProvider).isLoading;
});

/// Provider for courses error state
final coursesErrorProvider = Provider<String?>((ref) {
  return ref.watch(coursesStateProvider).error;
});

// ============================================================================
// CATEGORIES PROVIDER (MOCK DATA - TO BE REPLACED WITH API)
// ============================================================================

final categoriesProvider = Provider<List<Category>>((ref) {
  return [
    const Category(id: '1', name: 'Design', iconAsset: '🎨', coursesCount: 120),
    const Category(
      id: '2',
      name: 'Programming',
      iconAsset: '💻',
      coursesCount: 250,
    ),
    const Category(
      id: '3',
      name: 'Marketing',
      iconAsset: '📢',
      coursesCount: 80,
    ),
    const Category(
      id: '4',
      name: 'Business',
      iconAsset: '💼',
      coursesCount: 100,
    ),
    const Category(id: "5", name: "Web 3", iconAsset: "🕸️", coursesCount: 112),
    const Category(id: "6", name: "AI", iconAsset: "🤖", coursesCount: 150),
    const Category(
      id: "7",
      name: "Automation",
      iconAsset: "⚙️",
      coursesCount: 80,
    ),
    const Category(
      id: "8",
      name: "Languages",
      iconAsset: "🌍",
      coursesCount: 0,
    ),
    const Category(id: "9", name: "Finance", iconAsset: "💰", coursesCount: 0),
    const Category(id: "10", name: "Writing", iconAsset: "✍️", coursesCount: 0),
    const Category(
      id: "11",
      name: "Psychology",
      iconAsset: "🧠",
      coursesCount: 0,
    ),
    const Category(
      id: "12",
      name: "Communication",
      iconAsset: "🗣️",
      coursesCount: 0,
    ),
  ];
});

// ============================================================================
// TESTIMONIALS PROVIDER (MOCK DATA)
// ============================================================================

final testimonialsProvider = Provider<List<Testimonial>>((ref) {
  return [
    const Testimonial(
      id: '1',
      userName: 'Sarah Jenkins',
      role: 'Product Designer',
      userImage: 'https://randomuser.me/api/portraits/women/44.jpg',
      comment:
          "This platform completely changed my career path. The UI course was fantastic!",
      rating: 4.8,
    ),
    const Testimonial(
      id: '2',
      userName: 'Mike Ross',
      role: 'Flutter Dev',
      userImage: 'https://randomuser.me/api/portraits/men/32.jpg',
      comment:
          "The best investment I've made for my skills. Highly recommended.",
      rating: 4.8,
    ),
    const Testimonial(
      id: "3",
      userName: "Heyru Jemal",
      role: "Developer",
      userImage: "https://randomuser.me/api/portraits/men/68.jpg",
      comment: "Great platform to learn and grow!",
      rating: 4.9,
    ),
  ];
});

// ============================================================================
// BLOGS PROVIDERS (API-INTEGRATED)
// ============================================================================

/// Repository provider for blogs
final blogRepositoryProvider = Provider<BlogRepository>((ref) {
  final repository = BlogRepository();
  ref.onDispose(() => repository.dispose());
  return repository;
});

/// State class for blogs with loading and pagination
class BlogsState {
  final List<BlogPost> blogs;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasMore;

  const BlogsState({
    this.blogs = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 0,
    this.lastPage = 1,
    this.total = 0,
    this.hasMore = true,
  });

  BlogsState copyWith({
    List<BlogPost>? blogs,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? hasMore,
  }) {
    return BlogsState(
      blogs: blogs ?? this.blogs,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// StateNotifier for managing blogs state and API operations
class BlogsNotifier extends StateNotifier<BlogsState> {
  final BlogRepository _repository;

  BlogsNotifier(this._repository) : super(const BlogsState()) {
    loadBlogs();
  }

  /// Load initial blogs (first page)
  Future<void> loadBlogs() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repository.getBlogs(page: 1, size: 6);

      state = state.copyWith(
        blogs: response.blogs,
        isLoading: false,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        total: response.total,
        hasMore: response.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load more blogs (next page)
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final response = await _repository.getBlogs(page: nextPage, size: 6);

      state = state.copyWith(
        blogs: [...state.blogs, ...response.blogs],
        isLoadingMore: false,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        total: response.total,
        hasMore: response.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
      debugPrint('Failed to load more blogs: $e');
    }
  }

  /// Refresh blogs
  Future<void> refresh() async {
    state = state.copyWith(currentPage: 0, hasMore: true, error: null);
    await loadBlogs();
  }
}

/// Main blogs state provider
final blogsStateProvider = StateNotifierProvider<BlogsNotifier, BlogsState>((
  ref,
) {
  final repository = ref.watch(blogRepositoryProvider);
  return BlogsNotifier(repository);
});

/// Convenience provider to get just the blogs list
final blogsProvider = Provider<List<BlogPost>>((ref) {
  return ref.watch(blogsStateProvider).blogs;
});

/// Provider for checking if blogs are loading
final blogsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(blogsStateProvider).isLoading;
});

/// Provider for blogs error state
final blogsErrorProvider = Provider<String?>((ref) {
  return ref.watch(blogsStateProvider).error;
});
