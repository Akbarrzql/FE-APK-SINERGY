import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gabungyuk/core/common/firebase_user_sync_helper.dart';
import 'package:gabungyuk/core/widget/bottom_navigation.dart';
import 'package:gabungyuk/feature/auth/forgot_password/set_password_for_new_google_user_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'account_linking_service.dart';

class FirebaseIntegrationService {
  FirebaseIntegrationService._();
  static final FirebaseIntegrationService instance = FirebaseIntegrationService._();

  Future<void> signInWithGoogleAndSync(BuildContext context) async {
    try {
      if (kDebugMode) debugPrint('GOOGLE SIGNIN: starting');

      // ✅ 1. Google Sign-In
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn.instance.authenticate();

      if (googleUser == null) {
        throw Exception('Login dibatalkan user');
      }

      final String email = googleUser.email;
      final String fullName = googleUser.displayName ?? '';
      final String googleUid = googleUser.id;

      if (kDebugMode) {
        debugPrint('GOOGLE SIGNIN: email=$email');
        debugPrint('GOOGLE SIGNIN: name=$fullName');
        debugPrint('GOOGLE SIGNIN: googleUid=$googleUid');
      }

      // ✅ 2. Sign in ke Firebase Auth
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception('Gagal mendapatkan ID Token dari Google');
      }

      final AuthCredential credential =
          GoogleAuthProvider.credential(idToken: idToken);

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Firebase user tidak ditemukan');
      }

      if (kDebugMode) debugPrint('GOOGLE SIGNIN: Firebase Auth success, uid=${firebaseUser.uid}');

       final existingUser = await FirebaseUserSyncHelper.instance.findUserByEmail(email);
       final bool hasLocalPassword = existingUser?['has_local_password'] as bool? ?? false;
       final String provider = hasLocalPassword ? 'multi' : 'google';

       if (kDebugMode) {
         debugPrint('GOOGLE SIGNIN: hasLocalPassword=$hasLocalPassword, provider=$provider');
       }

       // ✅ 3. Sync ke Firestore
       await FirebaseUserSyncHelper.instance.upsertUserDoc(
         uid: firebaseUser.uid,
         email: email,
         fullName: fullName,
         provider: provider,
         googleUid: googleUid,
         hasLocalPassword: hasLocalPassword,
       );

      if (kDebugMode) debugPrint('GOOGLE SIGNIN: Firestore sync success');

      // ✅ 4. Sync ke backend manual login/register
      await AccountLinkingService.instance.smartAccountLink(
        email: email,
        googleUid: googleUid,
        fullName: fullName,
      );

      if (kDebugMode) debugPrint('GOOGLE SIGNIN: backend sync success');

      if (kDebugMode) {
        debugPrint('GOOGLE SIGNIN: hasLocalPassword=$hasLocalPassword');
      }

      if (!context.mounted) return;

      // ✅ 5. Navigation decision
      if (!hasLocalPassword) {
        // Belum set password → redirect ke set password screen
        if (kDebugMode) debugPrint('GOOGLE SIGNIN: Redirecting to SetPasswordScreen');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                SetPasswordForNewGoogleUserScreen(email: email, googleUid: googleUid),
          ),
        );
      } else {
        // Sudah set password → langsung ke dashboard
        if (kDebugMode) debugPrint('GOOGLE SIGNIN: Redirecting to Dashboard');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BottomNavigation()),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('GOOGLE SIGNIN ERROR: $e');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login gagal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// COMMENTED: Backend Google endpoints (siapa tahu nanti bisa dipakai)
  /// Future<void> _syncToBackendGoogle({
  ///   required String email,
  ///   required String googleIdToken,
  /// }) async {
  ///   // POST /api/v1/users/login/google dengan body {"idToken":"..."}
  ///   // atau POST /api/v1/users/register/google
  /// }
}
