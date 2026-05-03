import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/core/common/firebase_user_sync_helper.dart';
import 'package:gabungyuk/core/widget/bottom_navigation.dart';
import 'package:gabungyuk/feature/auth/repository/login_repository/login_repository.dart';
import 'package:gabungyuk/feature/auth/repository/register_repository/register_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseIntegrationService {
  FirebaseIntegrationService._();
  static final FirebaseIntegrationService instance = FirebaseIntegrationService._();

  Future<void> signInWithGoogleAndSync(BuildContext context) async {
    try {
      if (kDebugMode) debugPrint('GOOGLE SIGNIN: starting');

      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw Exception('Gagal mendapatkan ID Token dari Google');
      }

      final String email = googleUser.email;
      final String fullName = googleUser.displayName ?? '';
      final String googleUid = googleUser.id;
      final String backendSecret = FirebaseUserSyncHelper.instance.deriveGoogleSecret(googleUid);

      if (kDebugMode) {
        debugPrint('GOOGLE SIGNIN: email=$email');
        debugPrint('GOOGLE SIGNIN: name=$fullName');
        debugPrint('GOOGLE SIGNIN: googleUid=$googleUid');
        debugPrint('GOOGLE SIGNIN: idToken retrieved');
      }

      final AuthCredential credential = GoogleAuthProvider.credential(idToken: idToken);

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Firebase user tidak ditemukan setelah Google sign-in');
      }

      await FirebaseUserSyncHelper.instance.upsertUserDoc(
        uid: firebaseUser.uid,
        email: email,
        fullName: fullName,
        provider: 'google',
        googleUid: googleUid,
        hasLocalPassword: false,
      );

      await _linkEmailPasswordCredential(firebaseUser, email, backendSecret);

      await _syncToBackend(
        email: email,
        fullName: fullName,
        backendSecret: backendSecret,
      );

      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavigation()),
      );
    } on ApiException catch (e) {
      if (kDebugMode) debugPrint('GOOGLE SIGNIN API ERROR: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 4),
        ),
      );
    } on GoogleSignInException catch (e) {
      if (kDebugMode) debugPrint('GOOGLE SIGNIN GOOGLE ERROR: ${e.code} ${e.description}');
      if (!context.mounted) return;

      final message = switch (e.code) {
        GoogleSignInExceptionCode.providerConfigurationError =>
          'Google Play Services di perangkat Anda perlu diperbarui. Coba update Play Services atau pakai perangkat/emulator dengan Google Play Services terbaru.',
        GoogleSignInExceptionCode.canceled => 'Login Google dibatalkan.',
        GoogleSignInExceptionCode.interrupted => 'Login Google terhenti. Silakan coba lagi.',
        _ => e.description ?? 'Terjadi kesalahan saat login Google.',
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 5),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) debugPrint('GOOGLE SIGNIN FIREBASE ERROR: ${e.code} ${e.message}');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_firebaseAuthMessage(e)),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 4),
        ),
      );
    } on SocketException {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tidak ada koneksi internet'),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('GOOGLE SIGNIN ERROR: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login gagal: $e'),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _syncToBackend({
    required String email,
    required String fullName,
    required String backendSecret,
  }) async {
    try {
      if (kDebugMode) debugPrint('GOOGLE SIGNIN: registering backend account for $email');
      await RegisterRepositoryImpl().registerUser(
        name: fullName,
        email: email,
        password: backendSecret,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 409 || _looksLikeDuplicate(e.message)) {
        if (kDebugMode) debugPrint('GOOGLE SIGNIN: backend account exists, login instead for $email');
        await LoginRepositoryImpl().loginUser(
          email: email,
          password: backendSecret,
        );
        return;
      }
      rethrow;
    }
  }

  Future<void> _linkEmailPasswordCredential(
    User firebaseUser,
    String email,
    String password,
  ) async {
    try {
      await firebaseUser.linkWithCredential(
        EmailAuthProvider.credential(email: email, password: password),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked' ||
          e.code == 'email-already-in-use' ||
          e.code == 'credential-already-in-use') {
        return;
      }
      if (kDebugMode) debugPrint('GOOGLE SIGNIN: linkWithCredential ignored: ${e.code} ${e.message}');
    }
  }

  bool _looksLikeDuplicate(String message) {
    final lower = message.toLowerCase();
    return lower.contains('duplicate') ||
        lower.contains('sudah') ||
        lower.contains('exists') ||
        lower.contains('email');
  }

  String _firebaseAuthMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'Akun sudah ada dengan metode login lain.';
      case 'invalid-credential':
        return 'Kredensial Google tidak valid.';
      case 'network-request-failed':
        return 'Koneksi internet gagal.';
      default:
        return e.message ?? 'Terjadi kesalahan saat login Google.';
    }
  }
}
