import 'package:gabungyuk/feature/auth/service/firebase_password_service.dart';

/// Compatibility wrapper untuk flow reset password lama.
/// Semua implementasi sekarang 100% via Firebase.
class ResetPasswordService {
  ResetPasswordService._();
  static final ResetPasswordService instance = ResetPasswordService._();

  Future<void> sendPasswordResetEmail(String email) {
    return FirebasePasswordService.instance.sendPasswordResetEmail(email.trim());
  }

  Future<void> changePasswordForCurrentUser({
    required String oldPassword,
    required String newPassword,
  }) {
    return FirebasePasswordService.instance.updatePasswordForCurrentUser(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }

  // Backward-compatible method: code reset should use confirmPasswordReset.
  Future<void> resetPasswordWithOtp({
    required String email,
    required String newPassword,
  }) async {
    throw Exception(
      'Flow OTP tidak dipakai lagi. Gunakan reset email Firebase (sendPasswordResetEmail).',
    );
  }

  Future<void> resetPasswordForGoogleUser({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) {
    return FirebasePasswordService.instance.updatePasswordForCurrentUser(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }
}

