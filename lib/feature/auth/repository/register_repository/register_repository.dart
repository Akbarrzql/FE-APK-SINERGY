import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gabungyuk/core/common/auth_ui_helper.dart';
import 'package:gabungyuk/core/common/firebase_user_sync_helper.dart';
import 'package:gabungyuk/feature/auth/service/firebase_auth_token_service.dart';

/// 📝 Register Model - Simple Firebase-based
class FirebaseRegisterResult {
  final User user;
  final String idToken;

  FirebaseRegisterResult({required this.user, required this.idToken});
}

abstract class RegisterRepository {
  Future<FirebaseRegisterResult> registerUser({
    required String name,
    required String email,
    required String password,
  });

  Future<FirebaseRegisterResult> registerGoogle({
    required UserCredential credential,
  });
}

class RegisterRepositoryImpl implements RegisterRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  @override
  Future<FirebaseRegisterResult> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('REGISTER: Attempting Firebase user creation for $email');
      }

      // ✅ Create user di Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Firebase user tidak ditemukan setelah register');
      }

      // ✅ Update display name
      await user.updateDisplayName(name);
      await user.reload();

      // ✅ Get fresh Firebase ID Token
      final idToken = await FirebaseAuthTokenService.instance.getIdTokenWithRefresh();
      if (idToken == null) {
        throw Exception('Gagal mendapatkan ID Token');
      }

      // ✅ Save user profile ke Firestore
      await _syncUserToFirestore(
        uid: user.uid,
        email: email,
        namaLengkap: name,
        provider: 'email_password',
        idToken: idToken,
      );

      if (kDebugMode) {
        debugPrint('REGISTER: Firebase user creation success for $email');
      }

      return FirebaseRegisterResult(user: user, idToken: idToken);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('REGISTER: Firebase auth exception: ${e.code} - $e');
      }

      throw Exception(_getReadableAuthError(e.code));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('REGISTER: Unexpected error: $e');
      }
      throw Exception('Gagal mendaftar. Silakan coba lagi.');
    }
  }

  @override
  Future<FirebaseRegisterResult> registerGoogle({
    required UserCredential credential,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('REGISTER GOOGLE: Processing Google sign-up');
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
        debugPrint('REGISTER GOOGLE: Google sign-up success');
      }

      return FirebaseRegisterResult(user: user, idToken: idToken);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('REGISTER GOOGLE: Error: $e');
      }
      throw Exception('Gagal mendaftar dengan Google. Silakan coba lagi.');
    }
  }

  /// ✅ Simpan user profile ke Firestore
  Future<void> _syncUserToFirestore({
    required String uid,
    required String email,
    required String namaLengkap,
    required String provider,
    required String idToken,
    String? photoUrl,
  }) async {
    try {
      // 1. Sync ke dokumen berdasarkan UID (Primary)
      final userRef = _firestore.collection('users').doc(uid);

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

      // 2. Sync ke dokumen berdasarkan Email (Secondary, untuk Account Linking)
      await FirebaseUserSyncHelper.instance.updateUserFirebaseToken(
        uid: uid,
        email: email,
        firebaseIdToken: idToken,
      );

      if (kDebugMode) {
        debugPrint('REGISTER: User profile synced to Firestore (UID & Email docs)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('REGISTER: Error syncing to Firestore: $e');
      }
      // Don't throw - auth sudah berhasil, Firestore sync optional
    }
  }

  /// ✅ Convert Firebase Auth error ke pesan user-friendly
  String _getReadableAuthError(String errorCode) {
    return AuthUiHelper.toIndonesianMessage(
      switch (errorCode) {
        'weak-password' => 'Password terlalu lemah. Gunakan minimal 6 karakter.',
        'email-already-in-use' => 'Email sudah terdaftar. Silakan login atau gunakan email lain.',
        'invalid-email' => 'Format email tidak valid.',
        'operation-not-allowed' => 'Operasi tidak diizinkan. Hubungi admin.',
        'too-many-requests' => 'Terlalu banyak percobaan. Coba lagi nanti.',
        _ => 'Gagal mendaftar. Silakan coba lagi.',
      },
    );
  }
}