import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/common/shared_code.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../core/widget/bottom_navigation.dart';
import '../auth/login/login_screen.dart';
import '../onboarding/onboarding_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SharedCode _sharedCode = SharedCode();
  Timer? _splashTimer;

  Future<void> _routeAfterSplash() async {
    final token = await _sharedCode.getAuthToken();
    if (!mounted) return;

    if (token.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingPage()),
      );
      return;
    }

    final isExpired = await _sharedCode.isAuthSessionExpired();
    if (!mounted) return;

    if (isExpired) {
      await _sharedCode.clearAuthSession();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const BottomNavigation()),
    );
  }

  void _startSplashScreen() {
    const duration = Duration(seconds: 3);
    _splashTimer = Timer(duration, () {
      _routeAfterSplash();
    });
  }

  @override
  void initState() {
    super.initState();
    _startSplashScreen();
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Image.asset(Assets.image.png.gabungyukLogo.path)],
            ),
          ),
        ),
      ),
    );
  }
}
