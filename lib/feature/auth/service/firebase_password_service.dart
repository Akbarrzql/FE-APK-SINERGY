import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 🔐 Firebase Password Service
///
/// Handle semua password operations:
/// - Forgot Password (send email)
/// - Reset Password (verify code & set new password)
/// - Change Password (for logged-in users)
class FirebasePasswordService {
  FirebasePasswordService._();
  static final FirebasePasswordService instance = FirebasePasswordService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 📧 Kirim reset password email untuk user yang lupa password
  ///
  /// Firebase akan send email dengan link reset password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      if (kDebugMode) {
        debugPrint('PASSWORD: Sending password reset email to $email');
      }

      await _auth.sendPasswordResetEmail(email: email);

      if (kDebugMode) {
        debugPrint('PASSWORD: Reset password email sent to $email');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('PASSWORD: Firebase exception: ${e.code} - $e');
      }

      // Map Firebase error codes ke pesan user-friendly
      final message = switch (e.code) {
        'user-not-found' => 'Email tidak terdaftar di sistem kami.',
        'invalid-email' => 'Format email tidak valid.',
        'too-many-requests' => 'Terlalu banyak request. Coba lagi nanti.',
        _ => 'Gagal mengirim email reset password. Silakan coba lagi.',
      };

      throw Exception(message);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PASSWORD: Unexpected error: $e');
      }
      throw Exception('Gagal mengirim email reset password. Silakan coba lagi.');
    }
  }

  /// 🔑 Confirm password reset dengan verification code dan password baru
  ///
  /// Firebase akan verify code dan set password baru
  /// Code sudah dikirim ke email oleh Firebase
  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('PASSWORD: Confirming password reset with code');
      }

      // Validate password
      if (newPassword.length < 6) {
        throw Exception('Password minimal 6 karakter.');
      }

      await _auth.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );

      if (kDebugMode) {
        debugPrint('PASSWORD: Password reset successful');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('PASSWORD: Firebase exception: ${e.code} - $e');
      }

      final message = switch (e.code) {
        'invalid-action-code' => 'Kode reset sudah invalid atau expired. Silakan minta email baru.',
        'expired-action-code' => 'Kode reset sudah expired. Silakan minta email baru.',
        'weak-password' => 'Password terlalu lemah. Gunakan minimal 6 karakter.',
        _ => 'Gagal reset password. Silakan coba lagi.',
      };

      throw Exception(message);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PASSWORD: Unexpected error: $e');
      }
      throw Exception(e.toString());
    }
  }

  /// Verify password reset code (optional - untuk cek validity sebelum submit)
  Future<void> verifyPasswordResetCode(String code) async {
    try {
      await _auth.verifyPasswordResetCode(code);
      if (kDebugMode) {
        debugPrint('PASSWORD: Reset code is valid');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('PASSWORD: Invalid reset code: ${e.code}');
      }

      final message = switch (e.code) {
        'invalid-action-code' => 'Kode reset tidak valid.',
        'expired-action-code' => 'Kode reset sudah expired.',
        _ => 'Kode tidak valid.',
      };

      throw Exception(message);
    }
  }

  /// 🔄 Update password untuk user yang sudah logged in
  ///
  /// Harus reauthenticate dengan password lama terlebih dahulu
  Future<void> updatePasswordForCurrentUser({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User tidak login. Silakan login terlebih dahulu.');
      }

      final email = currentUser.email;
      if (email == null) {
        throw Exception('Email user tidak ditemukan.');
      }

      if (kDebugMode) {
        debugPrint('PASSWORD: Updating password for $email');
      }

      // Validate passwords
      if (oldPassword.isEmpty) {
        throw Exception('Password lama tidak boleh kosong.');
      }
      if (newPassword.length < 6) {
        throw Exception('Password baru minimal 6 karakter.');
      }
      if (oldPassword == newPassword) {
        throw Exception('Password baru harus berbeda dengan password lama.');
      }

      // Reauthenticate dengan password lama
      try {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: oldPassword,
        );
        await currentUser.reauthenticateWithCredential(credential);

        if (kDebugMode) {
          debugPrint('PASSWORD: Reauthentication successful');
        }
      } on FirebaseAuthException catch (e) {
        if (kDebugMode) {
          debugPrint('PASSWORD: Reauthentication failed: ${e.code}');
        }

        throw Exception('Password lama tidak sesuai. Silakan coba lagi.');
      }

      // Update password
      await currentUser.updatePassword(newPassword);

      if (kDebugMode) {
        debugPrint('PASSWORD: Password updated successfully');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('PASSWORD: Firebase exception during update: ${e.code} - $e');
      }

      final message = switch (e.code) {
        'weak-password' => 'Password terlalu lemah. Gunakan minimal 6 karakter.',
        'requires-recent-login' => 'Silakan login ulang untuk keamanan sebagai tambahan.',
        _ => 'Gagal mengubah password. Silakan coba lagi.',
      };

      throw Exception(message);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PASSWORD: Unexpected error: $e');
      }
      throw Exception(e.toString());
    }
  }

  /// Check apakah user itu provider email/password (bukan Google only)
  ///
  /// Digunakan untuk determine apakah user bisa change password
  bool currentUserHasPasswordProvider() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    return currentUser.providerData
        .any((provider) => provider.providerId == 'password');
  }

  /// Get email dari current user untuk forgot password confirmation
  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }
}

