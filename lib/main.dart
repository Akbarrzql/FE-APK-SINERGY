// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gabungyuk/core/common/app_navigator.dart';
import 'package:gabungyuk/feature/splash_screen/splash_screen.dart';
import 'package:gabungyuk/core/service/notification_service.dart';
import 'package:gabungyuk/feature/auth/forgot_password/reset_password_in_app_screen.dart';
import 'package:gabungyuk/core/widget/bottom_navigation.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Inisialisasi Firebase Messaging
  await NotificationService.instance.initialize();
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
