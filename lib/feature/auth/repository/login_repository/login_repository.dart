import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gabungyuk/core/common/app_ui_helper.dart';
import 'package:gabungyuk/core/common/firebase_user_sync_helper.dart';
import 'package:gabungyuk/feature/auth/service/firebase_auth_token_service.dart';

/// 🔐 Login Model - Simple Firebase-based
class FirebaseLoginResult {
  final User user;
  final String idToken;

  FirebaseLoginResult({required this.user, required this.idToken});
}

abstract class LoginRepository {
  Future<FirebaseLoginResult> loginUser({
    required String email,
    required String password,
  });

  Future<FirebaseLoginResult> loginGoogle({
    required UserCredential credential,
  });
}

class LoginRepositoryImpl implements LoginRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<FirebaseLoginResult> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('LOGIN: Attempting Firebase sign-in for $email');
      }

      // ✅ Sign in dengan Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Firebase user tidak ditemukan setelah login');
      }

      // ✅ Get fresh Firebase ID Token
      final idToken = await FirebaseAuthTokenService.instance.getIdTokenWithRefresh();
      if (idToken == null) {
        throw Exception('Gagal mendapatkan ID Token');
      }

      // ✅ Update user profile di Firestore
      await _syncUserToFirestore(
        uid: user.uid,
        email: email,
        namaLengkap: user.displayName ?? email,
        provider: 'email_password',
        idToken: idToken,
      );

      if (kDebugMode) {
        debugPrint('LOGIN: Firebase sign-in success for $email');
      }

      return FirebaseLoginResult(user: user, idToken: idToken);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('LOGIN: Firebase auth exception: ${e.code} - $e');
      }
      // Langsung lempar kode error agar diproses oleh AppUiHelper.readableError
      throw e;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('LOGIN: Unexpected error: $e');
      }
      throw Exception('Gagal login. Silakan coba lagi.');
    }
  }

  @override
  Future<FirebaseLoginResult> loginGoogle({
    required UserCredential credential,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('LOGIN GOOGLE: Processing Google sign-in');
      }

      final user = credential.user;
      if (user == null) {
        throw Exception('Google user tidak ditemukan');
      }

      // ✅ Get fresh Firebase ID Token
      final idToken = await FirebaseAuthTokenService.instance.getTokenFromGoogleSignIn();
      if (idToken == null) {
        throw Exception('Gagal mendapatkan ID Token dari Google');
      }

      // ✅ Save user profile ke Firestore
      await _syncUserToFirestore(
        uid: user.uid,
        email: user.email ?? '',
        namaLengkap: user.displayName ?? 'Google User',
        provider: 'google',
        photoUrl: user.photoURL,
        idToken: idToken,
      );

      if (kDebugMode) {
        debugPrint('LOGIN GOOGLE: Google sign-in success');
      }

      return FirebaseLoginResult(user: user, idToken: idToken);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('LOGIN GOOGLE: Error: $e');
      }
      throw Exception('Gagal login dengan Google. Silakan coba lagi.');
    }
  }

  Future<void> _syncUserToFirestore({
    required String uid,
    required String email,
    required String namaLengkap,
    required String provider,
    required String idToken,
    String? photoUrl,
  }) async {
    try {
      // 1. Sync to UID-indexed doc (Primary)
      final userRef = _firestore.collection('users').doc(uid);
      final docSnapshot = await userRef.get();

      if (docSnapshot.exists) {
        await userRef.update({
          'last_login': FieldValue.serverTimestamp(),
          'firebase_id_token': idToken,
        });
      } else {
        await userRef.set({
          'uid': uid,
          'email': email,
          'nama_lengkap': namaLengkap,
          'provider': provider,
          'photo_url': photoUrl,
          'firebase_id_token': idToken,
          'created_at': FieldValue.serverTimestamp(),
          'last_login': FieldValue.serverTimestamp(),
          'bio': '',
          'keahlian': '',
          'lokasi': '',
          'institusi': '',
          'whatsapp': '',
        });
      }

      // 2. Sync to Email-indexed doc (Secondary, for search/linking)
      await FirebaseUserSyncHelper.instance.updateUserFirebaseToken(
        uid: uid,
        email: email,
        firebaseIdToken: idToken,
      );

      if (kDebugMode) {
        debugPrint('LOGIN: User profile synced to Firestore (UID & Email docs)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('LOGIN: Error syncing to Firestore: $e');
      }
      // Don't throw - auth sudah berhasil, Firestore sync optional
    }
  }

  String _getReadableAuthError(String errorCode) {
    return AppUiHelper.toIndonesianMessage(
      switch (errorCode) {
        'user-not-found' || 'invalid-credential' => 'Email atau password salah. Silakan coba lagi.',
        'wrong-password' => 'Password salah. Silakan coba lagi.',
        'invalid-email' => 'Format email tidak valid.',
        'user-disabled' => 'Akun ini telah dinonaktifkan.',
        'too-many-requests' => 'Terlalu banyak percobaan login gagal. Coba lagi nanti.',
        _ => 'Gagal login. Silakan coba lagi.',
      },
    );
  }
}
