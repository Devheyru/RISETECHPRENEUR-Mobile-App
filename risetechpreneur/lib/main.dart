/// Application entrypoint for the RiseTechpreneur mobile app.
///
/// This file wires up global providers, theming, and the root navigation shell.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';
import 'package:risetechpreneur/presentation/screens/main_navigation.dart';
import 'package:risetechpreneur/presentation/screens/reset_password_screen.dart';
import 'core/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    // Riverpod needs a [ProviderScope] at the root of the widget tree.
    const ProviderScope(child: MyApp()),
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
      _handleDeepLink(uri);
    }

    // Handle links while app is open
    _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    // Expected format: risetechpreneur://reset-password?token=...&email=...
    if (uri.host == 'reset-password') {
      final token = uri.queryParameters['token'];
      final email = uri.queryParameters['email'];

      if (token != null && email != null) {
        _navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder:
                (context) => ResetPasswordScreen(token: token, email: email),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'RiseTech App',
      debugShowCheckedModeBanner: false,
      // 2. Apply the centralized theme
      theme: AppTheme.lightTheme,
      home: const MainNavigation(),
    );
  }
}
