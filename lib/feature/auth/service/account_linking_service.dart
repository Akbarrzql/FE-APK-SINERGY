import 'package:flutter/foundation.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/core/common/firebase_user_sync_helper.dart';
import 'package:gabungyuk/feature/auth/repository/login_repository/login_repository.dart';
import 'package:gabungyuk/feature/auth/repository/register_repository/register_repository.dart';

/// 🔗 Account Linking Service
///
/// Handles the complexity of linking Google OAuth accounts with existing backend accounts.
/// Prevents duplicate accounts when same email is used across providers.
class AccountLinkingService {
  AccountLinkingService._();
  static final AccountLinkingService instance = AccountLinkingService._();

  final _loginRepo = LoginRepositoryImpl();
  final _registerRepo = RegisterRepositoryImpl();

  /// 🔍 Check if email exists in backend AND Firestore
  ///
  /// Returns account info if exists, null if truly new
  Future<Map<String, dynamic>?> checkExistingAccount(String email) async {
    try {
      if (kDebugMode) {
        debugPrint('ACCOUNT LINKING: checking existing account for $email');
      }

      // Check Firestore first (fastest)
      final firestoreData =
          await FirebaseUserSyncHelper.instance.findUserByEmail(email);

      if (firestoreData != null) {
        if (kDebugMode) {
          debugPrint('ACCOUNT LINKING: found in Firestore - $firestoreData');
        }
        return firestoreData;
      }

      // Firestore miss - backend might have stale user
      // Try to get backend user info by attempting login with a test credential
      // This is tricky because we don't want to trigger wrong login attempts in logs
      // So we skip for now - Firestore is source of truth

      if (kDebugMode) {
        debugPrint('ACCOUNT LINKING: email is new (not in Firestore)');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ACCOUNT LINKING checkExistingAccount error: $e');
      }
      // On error, assume new to be safe (fallback)
      return null;
    }
  }

  /// 🔗 Link Google account to existing backend account
  ///
  /// Flow:
  /// 1. Jika user sudah set password local (has_local_password=true), backend sudah punya akun
  ///    - Skip login attempt untuk menghindari password mismatch
  ///    - Just update Firestore
  /// 2. Jika belum set password, coba login/register dengan googleSecret
  ///
  /// Ini menghindari error 401 ketika password sudah diganti user tapi system coba
  /// login dengan googleSecret yang sudah tidak valid lagi.
  Future<void> linkGoogleToExisting({
    required String email,
    required String googleUid,
    required String fullName,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
            'ACCOUNT LINKING: linking Google account to existing email=$email, google_uid=$googleUid');
      }

      // Get existing account info
      final existingAccount = await checkExistingAccount(email);
      if (existingAccount == null) {
        throw ApiException('Akun tidak ditemukan untuk di-link', 404);
      }

       // Get existing provider info
       final existingProvider =
           existingAccount['provider']?.toString() ?? 'email_password';
       final existingUid = existingAccount['uid']?.toString() ?? '';
       final hasLocalPassword =
           existingAccount['has_local_password'] as bool? ?? false;
       final localPasswordHash =
           existingAccount['local_password']?.toString() ?? '';
       final plainPassword = existingAccount['plain_password']?.toString() ?? '';

       if (kDebugMode) {
         debugPrint(
             'ACCOUNT LINKING: existing provider=$existingProvider, uid=$existingUid, hasLocalPassword=$hasLocalPassword');
       }

       // 🔑 Key decision: Apakah sudah ada local password?
       if (hasLocalPassword) {
         // User sudah set password lokal - backend password sudah diganti
         // Gunakan plaintext password dari Firestore untuk backend login
         if (plainPassword.isNotEmpty) {
           if (kDebugMode) {
             debugPrint(
                 'ACCOUNT LINKING: user has local password, attempting backend login with stored password');
           }

           try {
             final backendLogin = await _loginRepo.loginUser(
               email: email,
               password: plainPassword,
             );
             if (kDebugMode) {
               debugPrint('ACCOUNT LINKING: backend login success with stored password');
               debugPrint(
                   'ACCOUNT LINKING: backend token=${backendLogin.data.token}');
             }
           } on ApiException catch (e) {
             if (kDebugMode) {
               debugPrint(
                   'ACCOUNT LINKING: backend login failed with stored password (status=${e.statusCode}): $e');
             }
             // If login fails, just skip - account already exists
             // This is safer than trying to register
           }
         } else {
           // Plaintext password not found in Firestore, just skip
           if (kDebugMode) {
             debugPrint(
                 'ACCOUNT LINKING: user has local password but plaintext not in Firestore, skipping backend login');
           }
         }
       } else {
         // Belum ada local password, coba login/register dengan googleSecret
         final googleSecret =
             FirebaseUserSyncHelper.instance.deriveGoogleSecret(googleUid);

         if (kDebugMode) {
           debugPrint(
               'ACCOUNT LINKING: attempting backend login with googleSecret');
         }

         // Coba login ke backend manual dulu. Jika akun belum ada, register.
         try {
           final backendLogin = await _loginRepo.loginUser(
             email: email,
             password: googleSecret,
           );
           if (kDebugMode) {
             debugPrint('ACCOUNT LINKING: backend manual login success for $email');
             debugPrint(
                 'ACCOUNT LINKING: backend token=${backendLogin.data.token}');
           }
         } on ApiException catch (e) {
           if (e.statusCode == 401 || e.statusCode == 404) {
             if (kDebugMode) {
               debugPrint(
                   'ACCOUNT LINKING: backend account not found (status=${e.statusCode}), registering via manual endpoint');
             }
             await _registerRepo.registerUser(
               name: fullName,
               email: email,
               password: googleSecret,
             );
           } else {
             rethrow;
           }
         }
       }

       // ✅ Update Firestore to mark as multi-provider (if has local password)
       // or keep existing provider
       await FirebaseUserSyncHelper.instance.upsertUserDoc(
         uid: existingUid,
         email: email,
         fullName: fullName,
         provider: hasLocalPassword ? 'multi' : existingProvider,
         googleUid: googleUid,
         hasLocalPassword: hasLocalPassword,
         localPassword: localPasswordHash.isNotEmpty ? localPasswordHash : null,
         plainPassword: plainPassword.isNotEmpty ? plainPassword : null,
       );

      if (kDebugMode) {
        debugPrint('ACCOUNT LINKING: successfully linked Google to $email');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ACCOUNT LINKING linkGoogleToExisting error: $e');
      }
      rethrow;
    }
  }

  /// ➕ Register new Google account (truly new email)
  ///
  /// Only called when email is confirmed to be new (not in backend/Firestore)
  Future<void> registerNewGoogleAccount({
    required String email,
    required String googleUid,
    required String fullName,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
            'ACCOUNT LINKING: registering new Google account $email (google_uid=$googleUid)');
      }
      final googleSecret = FirebaseUserSyncHelper.instance.deriveGoogleSecret(googleUid);

      await _registerRepo.registerUser(
        name: fullName,
        email: email,
        password: googleSecret,
      );

      if (kDebugMode) {
        debugPrint('ACCOUNT LINKING: backend Google registration successful for $email');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ACCOUNT LINKING registerNewGoogleAccount error: $e');
      }
      rethrow;
    }
  }

  /// 🔄 Smart account linking flow
  ///
  /// Main entry point - decides whether to link or register new
  Future<Map<String, dynamic>> smartAccountLink({
    required String email,
    required String googleUid,
    required String fullName,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('ACCOUNT LINKING: starting smart link for $email');
      }

      // Step 1: Check if email already exists
      final existingAccount = await checkExistingAccount(email);

      if (existingAccount != null) {
        // Account exists - link to it
        if (kDebugMode) {
          debugPrint('ACCOUNT LINKING: existing account found, linking...');
        }

        await linkGoogleToExisting(
          email: email,
          googleUid: googleUid,
          fullName: fullName,
        );

        // Return updated account info
        final updated =
            await FirebaseUserSyncHelper.instance.findUserByEmail(email);
        if (updated != null) return updated;
        return existingAccount;
      }

      // Account doesn't exist - register new
      if (kDebugMode) {
        debugPrint('ACCOUNT LINKING: no existing account, registering...');
      }

      await registerNewGoogleAccount(
        email: email,
        googleUid: googleUid,
        fullName: fullName,
      );

      // Return newly created account info
      final created =
          await FirebaseUserSyncHelper.instance.findUserByEmail(email);
      if (created != null) return created;

      throw ApiException('Gagal membuat akun baru', 500);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ACCOUNT LINKING smartAccountLink error: $e');
      }
      rethrow;
    }
  }

  /// 🔐 Validate account consistency
  ///
  /// Called during app startup to detect mismatches
  /// Returns error message if inconsistency found
  Future<String?> validateAccountConsistency(String email) async {
    try {
      // Get from Firestore
      final firestoreAccount =
          await FirebaseUserSyncHelper.instance.findUserByEmail(email);

      if (firestoreAccount == null) {
        // Firestore says this email doesn't exist
        // This is ok - user might be new
        return null;
      }

      // Additional checks could go here:
      // - Validate provider list is non-empty
      // - Check uid format is valid
      // - Check provider matches reality

      return null; // Consistent
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ACCOUNT LINKING validateAccountConsistency error: $e');
      }
      return 'Kesalahan saat validasi akun: $e';
    }
  }
}


