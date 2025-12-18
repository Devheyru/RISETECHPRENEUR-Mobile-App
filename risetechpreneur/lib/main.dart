/// Application entrypoint for the RiseTechpreneur mobile app.
///
/// This file wires up global providers, theming, and the root navigation shell.
library;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kReleaseMode
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';
import 'package:device_preview/device_preview.dart';
import 'package:risetechpreneur/presentation/screens/main_navigation.dart';
import 'package:risetechpreneur/presentation/screens/reset_password_screen.dart';
import 'package:risetechpreneur/presentation/screens/auth_screen.dart';
import 'core/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    // Riverpod needs a [ProviderScope] at the root of the widget tree.
    ProviderScope(
      child: DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => const MyApp(),
      ),
    ),
  );
}

/// Root widget that configures global theme and the initial navigation screen.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  Uri? _pendingDeepLink;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle links launched when app is closed
    final uri = await _appLinks.getInitialLink();
    if (uri != null) {
      // Store pending link - will be processed after navigator is ready
      _pendingDeepLink = uri;
      // Use post-frame callback to ensure navigator is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _processPendingDeepLink();
      });
    }

    // Handle links while app is open
    _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _processPendingDeepLink() {
    if (_pendingDeepLink != null) {
      _handleDeepLink(_pendingDeepLink!);
      _pendingDeepLink = null;
    }
  }

  void _handleDeepLink(Uri uri) {
    // Handle different deep link types:
    // 1. Password reset with token: risetechpreneur://reset-password?token=xxx&email=xxx
    // 2. Password reset success (from web): risetechpreneur://password-reset-success
    // 3. HTTPS Universal Links for password reset

    // Check for password reset success callback (from web page after reset)
    final isResetSuccess =
        uri.scheme == 'risetechpreneur' && uri.host == 'password-reset-success';

    if (isResetSuccess) {
      // User completed password reset on web, redirect to login with success message
      _navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const AuthScreen(showPasswordResetSuccess: true),
        ),
        (route) => route.isFirst,
      );
      return;
    }

    // Check for password reset with token
    final isCustomScheme =
        uri.scheme == 'risetechpreneur' && uri.host == 'reset-password';
    final isHttpsScheme =
        uri.scheme == 'https' &&
        uri.host == 'rise-techpreneur.havanacademy.com' &&
        (uri.path.contains('/password/reset') ||
            uri.path.contains('/app/reset-password'));

    if (isCustomScheme || isHttpsScheme) {
      final token = uri.queryParameters['token'];
      final email = uri.queryParameters['email'];

      if (token != null && email != null) {
        // Ensure we don't push duplicate screens
        _navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder:
                (context) => ResetPasswordScreen(token: token, email: email),
          ),
          (route) => route.isFirst, // Keep only the first route (MainNavigation)
        );
      } else {
        // Missing parameters - show error to user
        _showDeepLinkError(
          token == null && email == null
              ? 'Invalid reset link. Please request a new password reset.'
              : token == null
                  ? 'Reset token is missing. Please request a new password reset.'
                  : 'Email is missing from the reset link. Please request a new password reset.',
        );
      }
    }
  }

  void _showDeepLinkError(String message) {
    // Wait for navigator to be ready, then show error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _navigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'RiseTech App',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      // 2. Apply the centralized theme
      theme: AppTheme.lightTheme,
      home: const MainNavigation(),
    );
  }
}
