import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/gen/assets.gen.dart';
import '../onboarding/onboarding_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Future<bool> _checkOnBoardingStatus() async {
  //   String value = await SharedCode().getToken('token');
  //   if (value == '') {
  //     return false;
  //   } else {
  //     return true;
  //   }
  // }

  Future _startSplashScreen() async {
    var duration = const Duration(seconds: 3);
    // bool status = await _checkOnBoardingStatus();
    return Timer(duration, () {
      // push navigation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OnboardingPage(),
        ),
      );

      // Navigate.navigatorPushAndRemove(
      //   context,
      //   FirebaseAuth.instance.currentUser == null
      //       ? status
      //       ? const LoginPage()
      //       : const OnBoardingScreen()
      //       : const VerificationPage(),
      // );
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
              children: [
                Image.asset(
                  Assets.image.png.gabungyukLogo.path,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
