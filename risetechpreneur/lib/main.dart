/// Application entrypoint for the RiseTechpreneur mobile app.
///
/// This file wires up global providers, theming, and the root navigation shell.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:risetechpreneur/presentation/screens/main_navigation.dart';
import 'core/app_theme.dart';

void main() {
  runApp(
    // Riverpod needs a [ProviderScope] at the root of the widget tree.
    const ProviderScope(child: MyApp()),
  );
}

/// Root widget that configures global theme and the initial navigation screen.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RiseTech App',
      debugShowCheckedModeBanner: false,
      // 2. Apply the centralized theme
      theme: AppTheme.lightTheme,
      home: const MainNavigation(),
    );
  }
}
