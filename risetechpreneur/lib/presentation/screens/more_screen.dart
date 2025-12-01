import 'package:flutter/material.dart';
import 'package:risetechpreneur/core/app_theme.dart';
import 'package:risetechpreneur/presentation/screens/settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'More',
          style: TextStyle(
            color: AppColors.secondaryNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _MoreOptionItem(
            icon: Icons.event_available_outlined,
            title: 'Events',
            subtitle: 'Upcoming workshops & webinars',
            onTap: () {
              // Navigate to Events
            },
          ),
          const SizedBox(height: 16),
          _MoreOptionItem(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {
              // Navigate to Terms
            },
          ),
          const SizedBox(height: 16),
          _MoreOptionItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              // Navigate to Privacy
            },
          ),
          const SizedBox(height: 16),
          _MoreOptionItem(
            icon: Icons.settings_outlined,
            title: 'App Settings',
            subtitle: 'Notifications, Theme, Language',
            onTap: () {
              // Navigate to App Settings (or reuse SettingsScreen if appropriate,
              // but user wanted "Personal Settings" on profile click)
            },
          ),
        ],
      ),
    );
  }
}

class _MoreOptionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _MoreOptionItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.secondaryNavy,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}
