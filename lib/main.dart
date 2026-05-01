import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'feature/collaboration/screens/collaboration_screen.dart';

void main() {
  runApp(const GabungYukApp());
}

class GabungYukApp extends StatelessWidget {
  const GabungYukApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GabungYuk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
      ),
      home: const CollaborationScreen(),
    );
  }
}
