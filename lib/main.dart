import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gabungyuk/core/common/app_navigator.dart';
import 'package:gabungyuk/feature/splash_screen/splash_screen.dart';
import 'package:gabungyuk/feature/auth/forgot_password/reset_password_in_app_screen.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GoogleSignIn.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initDynamicLinks();
  }

  void _handleLink(Uri? link) {
    if (link == null) return;
    final code = link.queryParameters['oobCode'];
    if (code != null && appNavigatorKey.currentState != null) {
      appNavigatorKey.currentState!.push(
        MaterialPageRoute(builder: (_) => ResetPasswordInAppScreen(oobCode: code)),
      );
    }
  }

  Future<void> _initDynamicLinks() async {
    // Handle initial link
    try {
      final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();
      _handleLink(data?.link);
    } catch (e) {
      // ignore
    }

    // Listen for subsequent links
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      _handleLink(dynamicLinkData.link);
    }).onError((e) {
      // ignore errors
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: false,
      ),
      home: const SplashScreen(),
    );
  }
}
