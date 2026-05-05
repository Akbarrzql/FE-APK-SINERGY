import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/core/common/firebase_user_sync_helper.dart';
import 'package:gabungyuk/feature/auth/repository/login_repository/login_repository.dart';
import 'package:gabungyuk/feature/profile/repository/profile_repository.dart';

/// Service untuk reset password (convert Google-only users ke multi-login)
class ResetPasswordService {
  ResetPasswordService._();
  static final ResetPasswordService instance = ResetPasswordService._();

  final _loginRepo = LoginRepositoryImpl();
  final _profileRepo = ProfileRepositoryImpl();

  /// Change password flow untuk user login biasa (dari halaman profile).
  ///
  /// Validasi password lama dilakukan dengan:
  /// 1) login backend (primary source of truth)
  /// 2) fallback Firestore (plain_password / local_password hash)
  Future<void> changePasswordForCurrentUser({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final profile = await _profileRepo.getProfile();
      final email = profile.email.trim();

      if (email.isEmpty) {
        throw ApiException('Email pengguna tidak ditemukan.', 400);
      }

      bool oldPasswordValid = false;

      // 1) Cek old password via login backend
      try {
        await _loginRepo.loginUser(email: email, password: oldPassword);
        oldPasswordValid = true;
      } catch (_) {
        oldPasswordValid = false;
      }

      // 2) Fallback cek dari Firestore jika login backend gagal
      if (!oldPasswordValid) {
        final userData = await FirebaseUserSyncHelper.instance.findUserByEmail(email);
        if (userData != null) {
          final plain = userData['plain_password']?.toString() ?? '';
          final localHash = userData['local_password']?.toString() ?? '';

          if (plain.isNotEmpty && plain == oldPassword) {
            oldPasswordValid = true;
          } else if (localHash.isNotEmpty &&
              FirebaseUserSyncHelper.instance.verifyPassword(oldPassword, localHash)) {
            oldPasswordValid = true;
          }
        }
      }

      if (!oldPasswordValid) {
        throw ApiException('Password lama tidak sesuai. Silakan coba lagi.', 401);
      }

      // Update password di backend (endpoint profile update)
      await _profileRepo.updateProfile({'password': newPassword});

      // Best effort update Firebase Auth (jika akun email/password)
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.email != null) {
        try {
          await currentUser.reauthenticateWithCredential(
            EmailAuthProvider.credential(
              email: currentUser.email!,
              password: oldPassword,
            ),
          );
          await currentUser.updatePassword(newPassword);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('CHANGE PASSWORD: skip Firebase update: $e');
          }
        }
      }

      // Sinkron metadata password ke Firestore agar konsisten fallback di device lain
      final userData = await FirebaseUserSyncHelper.instance.findUserByEmail(email);
      if (userData != null) {
        await FirebaseUserSyncHelper.instance.upsertUserDoc(
          uid: userData['uid']?.toString() ?? '',
          email: email,
          fullName: userData['full_name']?.toString() ?? '',
          provider: userData['provider']?.toString() ?? 'multi',
          googleUid: userData['google_uid']?.toString(),
          hasLocalPassword: true,
          passwordJustSet: true,
          localPassword: FirebaseUserSyncHelper.instance.hashPassword(newPassword),
          plainPassword: newPassword,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('CHANGE PASSWORD ERROR: $e');
      }
      rethrow;
    }
  }

  /// 🔄 Flow Reset Password untuk Google Users:
  /// 1. Verifikasi old password (login ke backend)
  /// 2. Update password di backend
  /// 3. Update Firebase Auth
  /// 4. Update Firestore `has_local_password` flag
  Future<void> resetPasswordForGoogleUser({
    required String email,
    required String oldPassword, // Bisa berupa Google secret atau actual password
    required String newPassword,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('RESET PASSWORD: starting for $email');
      }

      // ✅ Step 1: Verify old password dengan backend
      if (kDebugMode) debugPrint('RESET PASSWORD: verifying old password');
      try {
        await _loginRepo.loginUser(email: email, password: oldPassword);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('RESET PASSWORD: verification failed: $e');
        }
        throw ApiException('Password lama tidak sesuai. Silakan coba lagi.', 401);
      }

      // ✅ Step 2: Update password di backend
      if (kDebugMode) debugPrint('RESET PASSWORD: updating backend password');
      await _profileRepo.updateProfile({'password': newPassword});

      // ✅ Step 3: Update Firebase Auth dengan password baru
      if (kDebugMode) {
        debugPrint('RESET PASSWORD: updating Firebase Auth password');
      }
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await currentUser.updatePassword(newPassword);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
              'RESET PASSWORD: Firebase Auth update skipped (user may have OAuth): $e');
        }
        // Bisa diabaikan jika user hanya OAuth
      }

      // ✅ Step 4: Re-link menggunakan password baru
      if (kDebugMode) {
        debugPrint('RESET PASSWORD: re-linking Firebase credentials');
      }
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          // Hapus credential lama (jika ada)
          final providers = currentUser.providerData
              .map((p) => p.providerId)
              .toList();

          if (providers.contains('password')) {
            await currentUser.unlink('password');
          }

          // Link dengan credential baru
          await currentUser.linkWithCredential(
            EmailAuthProvider.credential(
              email: email,
              password: newPassword,
            ),
          );
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('RESET PASSWORD: credential re-linking: $e');
        }
        // Bisa diabaikan, main purpose sudah tercapai
      }

       // ✅ Step 5: Update Firestore: set has_local_password = true
       if (kDebugMode) {
         debugPrint('RESET PASSWORD: updating Firestore has_local_password flag');
       }
       final userData = await FirebaseUserSyncHelper.instance.findUserByEmail(email);
       if (userData != null) {
         final hashedPassword = FirebaseUserSyncHelper.instance.hashPassword(newPassword);
         await FirebaseUserSyncHelper.instance.upsertUserDoc(
           uid: userData['uid']?.toString() ?? '',
           email: email,
           fullName: userData['full_name']?.toString() ?? '',
           provider: 'multi',
           googleUid: userData['google_uid']?.toString(),
           hasLocalPassword: true, // ✅ Mark bahwa user sekarang punya local password
           passwordJustSet: true,
           localPassword: hashedPassword,
           plainPassword: newPassword, // 🔑 SAVE plaintext for backend login
         );
       }

      if (kDebugMode) {
        debugPrint('RESET PASSWORD: SUCCESS for $email');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('RESET PASSWORD ERROR: $e');
      }
      rethrow;
    }
  }
}

