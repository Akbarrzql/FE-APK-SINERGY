import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gabungyuk/core/common/auth_ui_helper.dart';
import 'package:gabungyuk/core/common/firebase_user_sync_helper.dart';
import 'package:gabungyuk/core/common/shared_code.dart';
import 'package:gabungyuk/core/widget/bottom_navigation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_auth_token_service.dart';

class FirebaseIntegrationService {
  FirebaseIntegrationService._();
  static final FirebaseIntegrationService instance = FirebaseIntegrationService._();

  final SharedCode _sharedCode = SharedCode();

  Future<void> signInWithGoogleAndSync(BuildContext context) async {
    try {
      if (kDebugMode) debugPrint('GOOGLE SIGNIN: starting');

      // ✅ 1. Google Sign-In
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();


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
          googleUser.authentication;
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

      // Check if user already exists in Firestore
      final existingUser = await FirebaseUserSyncHelper.instance.findUserByEmail(email);
      final bool hasLocalPassword = existingUser?['has_local_password'] as bool? ?? false;
      final String provider = hasLocalPassword ? 'multi' : 'google';

      if (kDebugMode) {
        debugPrint('GOOGLE SIGNIN: hasLocalPassword=$hasLocalPassword, provider=$provider');
      }

      // ✅ 3. Get Firebase ID Token
      final firebaseIdToken = await FirebaseAuthTokenService.instance.getTokenFromGoogleSignIn();

      // ✅ Simpan ke SharedPreferences untuk akses API Backend
      if (firebaseIdToken != null) {
        await _sharedCode.saveFirebaseAuthSession(token: firebaseIdToken);
      }

      // ✅ 4. Sync ke Firestore dengan token
      await FirebaseUserSyncHelper.instance.upsertUserDoc(
        uid: firebaseUser.uid,
        email: email,
        fullName: fullName,
        provider: provider,
        googleUid: googleUid,
        hasLocalPassword: hasLocalPassword,
        firebaseIdToken: firebaseIdToken,
      );

      if (kDebugMode) {
        debugPrint('GOOGLE SIGNIN: Firestore sync success');
        if (firebaseIdToken != null) {
          debugPrint('GOOGLE SIGNIN: Firebase ID Token saved: ${firebaseIdToken.substring(0, 20)}...');
        }
      }

      if (kDebugMode) {
        debugPrint('GOOGLE SIGNIN: hasLocalPassword=$hasLocalPassword');
      }

      if (!context.mounted) return;

      // ✅ 6. Navigation: Langsung ke dashboard
      if (kDebugMode) debugPrint('GOOGLE SIGNIN: Redirecting to Dashboard');

      if (!context.mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const BottomNavigation()),
        (route) => false,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('GOOGLE SIGNIN ERROR: $e');

      if (!context.mounted) return;

      AuthUiHelper.showError(
        context,
        AuthUiHelper.readableError(
          e,
          fallback: 'Gagal masuk dengan Google. Silakan coba lagi.',
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
