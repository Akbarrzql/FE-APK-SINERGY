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

  Future<void> _routeAfterSplash() async {
    final token = await _sharedCode.getAuthToken();
    if (!mounted) return;

    if (token.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OnboardingPage(),
        ),
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
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const BottomNavigation(),
      ),
    );
  }

  Future _startSplashScreen() async {
    var duration = const Duration(seconds: 3);
    return Timer(duration, () {
      _routeAfterSplash();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _startSplashScreen();
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
