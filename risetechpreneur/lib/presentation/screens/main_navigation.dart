import 'package:flutter/material.dart';
import 'package:risetechpreneur/core/app_theme.dart';
import 'package:risetechpreneur/presentation/screens/home_screen.dart';
import 'package:risetechpreneur/presentation/screens/courses_screen.dart';
import 'package:risetechpreneur/presentation/screens/blog_screen.dart';
import 'package:risetechpreneur/presentation/screens/contact_screen.dart';
import 'package:risetechpreneur/presentation/screens/more_screen.dart';

/// Root navigation shell with a custom bottom navigation bar.
///
/// Uses [IndexedStack] to preserve the state of each tab when switching.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // List of screens for each tab
  final List<Widget> _screens = [
    const HomeScreen(),
    const CoursesScreen(),
    const BlogScreen(),
    const ContactScreen(),
    const MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
                _buildNavItem(
                  Icons.school_outlined,
                  Icons.school,
                  'Courses',
                  1,
                ),
                _buildNavItem(Icons.article_outlined, Icons.article, 'Blog', 2),
                _buildNavItem(
                  Icons.contact_mail_outlined,
                  Icons.contact_mail,
                  'Contact',
                  3,
                ),
                _buildNavItem(Icons.more_horiz, Icons.more_horiz, 'More', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
  ) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isActive
                  ? AppColors.primaryBlue.withAlpha(26)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primaryBlue : AppColors.textGrey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? AppColors.primaryBlue : AppColors.textGrey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
