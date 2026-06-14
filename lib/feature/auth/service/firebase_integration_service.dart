import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
    var currentStep = 'google_authenticate';

    try {
      if (kDebugMode) debugPrint('GOOGLE SIGNIN: starting');
      await _safeLogAnalyticsEvent(
        name: 'google_sign_in_start',
        parameters: {'step': currentStep},
      );

      await _setCrashlyticsContext(step: currentStep);

      // ✅ 1. Google Sign-In
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      currentStep = 'google_authentication_success';
      await _setCrashlyticsContext(step: currentStep);

      final String email = googleUser.email;
      final String fullName = googleUser.displayName ?? '';
      final String googleUid = googleUser.id;

      if (kDebugMode) {
        debugPrint('GOOGLE SIGNIN: email=$email');
        debugPrint('GOOGLE SIGNIN: name=$fullName');
        debugPrint('GOOGLE SIGNIN: googleUid=$googleUid');
      }

      // ✅ 2. Sign in ke Firebase Auth
      currentStep = 'google_get_authentication';
      await _setCrashlyticsContext(step: currentStep);

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        currentStep = 'google_id_token_missing';
        await _setCrashlyticsContext(step: currentStep);
        throw StateError('Gagal mendapatkan ID Token dari Google');
      }

      currentStep = 'firebase_sign_in_with_credential';
      await _setCrashlyticsContext(step: currentStep);

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
      currentStep = 'firebase_session_token';
      await _setCrashlyticsContext(step: currentStep);

      final firebaseIdToken = await FirebaseAuthTokenService.instance.getTokenFromGoogleSignIn();

      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        currentStep = 'firebase_session_token_missing';
        await _setCrashlyticsContext(step: currentStep);
        throw StateError('Gagal mendapatkan token sesi Firebase setelah login Google');
      }

      // ✅ Simpan ke SharedPreferences untuk akses API Backend
      await _sharedCode.saveFirebaseAuthSession(token: firebaseIdToken);

      // ✅ 4. Sync ke Firestore dengan token
      currentStep = 'firestore_sync';
      await _setCrashlyticsContext(step: currentStep);

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
        debugPrint('GOOGLE SIGNIN: Firebase ID Token saved: ${firebaseIdToken.substring(0, 20)}...');
      }

      if (kDebugMode) {
        debugPrint('GOOGLE SIGNIN: hasLocalPassword=$hasLocalPassword');
      }

      await FirebaseAnalytics.instance.logEvent(
        name: 'google_sign_in_success',
        parameters: {
          'step': currentStep,
          'provider': provider,
        },
      );

      if (!context.mounted) return;

      // ✅ 6. Navigation: Langsung ke dashboard
      if (kDebugMode) debugPrint('GOOGLE SIGNIN: Redirecting to Dashboard');

      if (!context.mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const BottomNavigation()),
        (route) => false,
      );
    } catch (e, stack) {
      if (_isCancellationError(e)) {
        if (kDebugMode) debugPrint('GOOGLE SIGNIN: cancelled by user - $e');

        await _safeLogAnalyticsEvent(
          name: 'google_sign_in_cancelled',
          parameters: {'step': currentStep},
        );

        if (!context.mounted) return;
        AuthUiHelper.showInfo(context, 'Login dibatalkan');
        return;
      }

      final failureType = _classifyGoogleAuthFailure(e);
      await _recordGoogleFailure(
        error: e,
        stack: stack,
        step: currentStep,
        failureType: failureType,
      );

      await _safeLogAnalyticsEvent(
        name: 'google_sign_in_failed',
        parameters: {
          'step': currentStep,
          'failure_type': failureType,
        },
      );

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

  Future<void> _setCrashlyticsContext({
    required String step,
    String? failureType,
  }) async {
    try {
      await FirebaseCrashlytics.instance.setCustomKey('auth_provider', 'google');
      await FirebaseCrashlytics.instance.setCustomKey('auth_step', step);
      if (failureType != null) {
        await FirebaseCrashlytics.instance.setCustomKey('failure_type', failureType);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('GOOGLE SIGNIN: Crashlytics context failed: $e');
    }
  }

  Future<void> _safeLogAnalyticsEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('GOOGLE SIGNIN: Analytics log failed: $e');
    }
  }

  Future<void> _recordGoogleFailure({
    required Object error,
    required StackTrace stack,
    required String step,
    required String failureType,
  }) async {
    try {
      await _setCrashlyticsContext(step: step, failureType: failureType);
      await FirebaseCrashlytics.instance.log(
        'Google sign-in failed at $step ($failureType): $error',
      );
      await FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        reason: 'Google sign-in failed at $step ($failureType)',
        fatal: false,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('GOOGLE SIGNIN: Crashlytics log failed: $e');
    }
  }

  bool _isCancellationError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('cancel') ||
        message.contains('canceled') ||
        message.contains('cancelled') ||
        message.contains('dismiss') ||
        message.contains('closed_by_user') ||
        message.contains('sign_in_canceled') ||
        message.contains('sign_in_cancelled');
  }

  String _classifyGoogleAuthFailure(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('id token') || message.contains('token sesi')) {
      return 'token_missing';
    }
    if (message.contains('developer_error') ||
        message.contains('sign_in_failed') ||
        message.contains('operation-not-allowed') ||
        message.contains('invalid-credential') ||
        message.contains('invalid credential') ||
        message.contains('configuration')) {
      return 'configuration';
    }
    if (message.contains('network') ||
        message.contains('socket') ||
        message.contains('timeout')) {
      return 'network';
    }
    if (message.contains('firestore') ||
        message.contains('firebaseuser') ||
        message.contains('sync')) {
      return 'sync';
    }
    return 'unknown';
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
