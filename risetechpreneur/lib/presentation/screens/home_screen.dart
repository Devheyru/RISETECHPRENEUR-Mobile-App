import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:risetechpreneur/core/app_theme.dart';
import 'package:risetechpreneur/data/auth_provider.dart';
import 'package:risetechpreneur/data/providers.dart';
import 'package:risetechpreneur/presentation/widgets/components.dart';
import 'package:risetechpreneur/presentation/widgets/popular_courses.dart';
import 'package:risetechpreneur/presentation/widgets/blog_section.dart';
import 'package:risetechpreneur/presentation/widgets/category_section.dart';
import 'auth_screen.dart'; // Import Auth Screen

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const int _initialTestimonialPage = 1000;
  late final PageController _testimonialController;
  Timer? _testimonialTimer;
  int _currentTestimonialPage = _initialTestimonialPage;

  @override
  void initState() {
    super.initState();
    _testimonialController = PageController(
      viewportFraction: 0.9,
      initialPage: _initialTestimonialPage,
    );
    _startTestimonialsAutoScroll();
  }

  void _startTestimonialsAutoScroll() {
    _testimonialTimer?.cancel();
    _testimonialTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_testimonialController.hasClients) return;
      final testimonials = ref.read(testimonialsProvider);
      if (testimonials.length <= 1) return;
      final nextPage = _currentTestimonialPage + 1;
      _testimonialController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() => _currentTestimonialPage = nextPage);
    });
  }

  @override
  void dispose() {
    _testimonialTimer?.cancel();
    _testimonialController.dispose();
    super.dispose();
  }

  // --- NEW LOGIC: Centralized Enrollment Handler ---
  void _handleEnrollment(
    BuildContext context,
    WidgetRef ref,
    String courseTitle,
  ) {
    final user = ref.read(authProvider); // Check current user state

    if (user == null) {
      // Not logged in? Redirect to Auth Screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    } else {
      // Logged in? Proceed to Course (Mock Success)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Enrollment started for $courseTitle!"),
          backgroundColor: AppColors.primaryBlue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final courses = ref.watch(coursesProvider);
    final categories = ref.watch(categoriesProvider);
    final testimonials = ref.watch(testimonialsProvider);
    final blogs = ref.watch(blogsProvider); // 1. Watch Blogs
    final user = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(user),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... existing Hero, Popular Courses, Categories ...
            _buildHeroSection(context, ref),
            const SizedBox(height: 32),

            // Popular Courses Section
            PopularCoursesSection(courses: courses),
            const SizedBox(height: 32),

            // Categories Section
            CategorySection(categories: categories),

            const SizedBox(height: 48),

            // ... existing Testimonials Section ...
            if (testimonials.isNotEmpty)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    const SectionHeader(title: "What Our Students Say"),
                    SizedBox(
                      height: 200,
                      child: PageView.builder(
                        controller: _testimonialController,
                        onPageChanged:
                            (index) =>
                                setState(() => _currentTestimonialPage = index),
                        itemBuilder: (context, index) {
                          final t = testimonials[index % testimonials.length];
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: List.generate(5, (index) {
                                    if (index < t.rating.floor()) {
                                      return const Icon(
                                        Icons.star,
                                        size: 18,
                                        color: AppColors.accentYellow,
                                      );
                                    } else if (index < t.rating) {
                                      return Stack(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 18,
                                            color: Colors.grey[300],
                                          ),
                                          ClipRect(
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              widthFactor: t.rating - index,
                                              child: const Icon(
                                                Icons.star,
                                                size: 18,
                                                color: AppColors.accentYellow,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Icon(
                                        Icons.star,
                                        size: 18,
                                        color: Colors.grey[300],
                                      );
                                    }
                                  }),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '"${t.comment}"',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 3,
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        t.userImage,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t.userName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          t.role,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // --- NEW: Blog Section to match Image ---
            BlogSection(blogs: blogs),
            const SizedBox(height: 48),

            // ----------------------------------------
            _buildFooter(context, ref), // Pass context and ref
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(AppUser? user) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Row(
        children: [
          Icon(Icons.auto_awesome_mosaic, color: AppColors.primaryBlue),
          SizedBox(width: 8),
          Text(
            "RiseTech",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        // Show Profile Pic if logged in, otherwise generic icon
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child:
              user != null
                  ? Chip(
                    avatar: const Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: Text(user.displayName ?? 'User'),
                    backgroundColor: AppColors.primaryBlue,
                    labelStyle: const TextStyle(color: Colors.white),
                  )
                  : IconButton(
                    icon: const Icon(Icons.person_outline, color: Colors.black),
                    onPressed: () {},
                  ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Unlock Your Full\nEntrepreneurial Potential Today!",
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 16),
          Text(
            "Rise Techpreneur provides the essential skills and knowledge to launch and scale your own successful tech venture.Join us!",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  // Trigger protection logic here too
                  onPressed:
                      () =>
                          _handleEnrollment(context, ref, "All Access Bundle"),
                  child: const Text("Get Started"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.primaryBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Learn More"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // ... existing image and stats ...
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://rise-techpreneur.havanacademy.com/assets/img/education/courses-13.webp',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Stats
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StatItem(
                label: "Courses",
                value: "1.2k+",
                icon: Icons.play_circle_outline,
              ),
              StatItem(
                label: "Students",
                value: "50k+",
                icon: Icons.people_outline,
              ),
              StatItem(
                label: "Success ",
                value: "98%",
                icon: Icons.school_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      color: AppColors.footerBg,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Text(
            "Ready to start?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                () => _handleEnrollment(context, ref, "All Access Bundle"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryBlue,
            ),
            child: const Text("Get Started Now"),
          ),
          const SizedBox(height: 32),
          Text(
            "© 2025 RiseTechPrenuer Inc. All rights reserved.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
