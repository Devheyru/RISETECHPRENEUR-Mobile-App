import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:risetechpreneur/presentation/screens/main_navigation.dart';
import 'core/app_theme.dart';

void main() {
  runApp(
    // 1. Wrap the app in ProviderScope for Riverpod
    const ProviderScope(child: MyApp()),
  );
}

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
