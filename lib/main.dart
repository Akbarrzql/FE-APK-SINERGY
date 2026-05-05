// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gabungyuk/core/common/app_navigator.dart';
import 'package:gabungyuk/core/common/deep_link_service.dart';
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
  bool _scheduledPendingLinkFlush = false;

  @override
  void initState() {
    super.initState();
    _schedulePendingLinkFlush();
    if (Firebase.apps.isNotEmpty) {
      _initDynamicLinks();
    }
  }

  void _schedulePendingLinkFlush() {
    if (_scheduledPendingLinkFlush) return;
    _scheduledPendingLinkFlush = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduledPendingLinkFlush = false;
      _flushPendingLink();
    });
  }

  void _handleLink(Uri? link) {
    final normalizedLink = DeepLinkService.instance.normalize(link);
    if (normalizedLink == null) return;
    if (DeepLinkService.instance.wasHandled(normalizedLink)) return;

    if (!DeepLinkService.instance.shouldOpenResetPassword(normalizedLink)) {
      return;
    }

    DeepLinkService.instance.markHandled(normalizedLink);
    DeepLinkService.instance.storePending(normalizedLink);
    DeepLinkService.instance.markBypassSplash();
    _flushPendingLink();
  }

  void _flushPendingLink() {
    final pendingLink = DeepLinkService.instance.pendingLink;
    if (pendingLink == null) return;

    final navigator = appNavigatorKey.currentState;
    if (navigator == null) {
      _schedulePendingLinkFlush();
      return;
    }

    final link = DeepLinkService.instance.takePending();
    if (link == null) return;

    final code = link.queryParameters['oobCode'];
    if (code == null || code.isEmpty) {
      DeepLinkService.instance.clearBypassSplash();
      return;
    }

    navigator.push(
      MaterialPageRoute(
        builder: (_) => ResetPasswordInAppScreen(oobCode: code),
      ),
    );
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
    if (DeepLinkService.instance.pendingLink != null) {
      _schedulePendingLinkFlush();
    }

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
