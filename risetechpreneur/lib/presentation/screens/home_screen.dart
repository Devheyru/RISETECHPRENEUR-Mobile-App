import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:risetechpreneur/core/app_theme.dart';
import 'package:risetechpreneur/data/auth_provider.dart';
import 'package:risetechpreneur/data/providers.dart';
import 'package:risetechpreneur/presentation/widgets/components.dart';
import 'package:risetechpreneur/presentation/widgets/popular_courses.dart';
import 'auth_screen.dart'; // Import Auth Screen

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
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
            const SectionHeader(title: "Course Categories"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: categories.length,
                itemBuilder:
                    (context, index) =>
                        CategoryItem(category: categories[index]),
              ),
            ),

            const SizedBox(height: 48),

            // ... existing Testimonials Section ...
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 40),
              // ... existing testimonial content ...
              child: Column(
                children: [
                  const SectionHeader(title: "What Our Students Say"),
                  // ... existing PageView ...
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      // ... existing implementation ...
                      itemCount: testimonials.length,
                      itemBuilder: (context, index) {
                        // ... existing implementation ...
                        final t = testimonials[index];
                        return Container(
                          // ... existing container properties ...
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
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    Icons.star,
                                    size: 18,
                                    color:
                                        i < t.rating
                                            ? AppColors.accentYellow
                                            : Colors.grey[300],
                                  ),
                                ),
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
                                    backgroundImage: NetworkImage(t.userImage),
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
            SectionHeader(title: "Latest Blog News", onSeeAll: () {}),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: blogs.map((blog) => BlogCard(blog: blog)).toList(),
              ),
            ),
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
            "© 2024 RiseTech Inc. All rights reserved.",
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
