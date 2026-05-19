import 'package:flutter/foundation.dart';
import 'package:gabungyuk/feature/auth/service/firebase_auth_token_service.dart';

/// 🎯 Firebase Token Helper
///
/// Utility class untuk memudahkan mendapatkan Firebase ID Token
/// dari mana saja di aplikasi dengan error handling yang aman
class FirebaseTokenHelper {
  FirebaseTokenHelper._();
  static final FirebaseTokenHelper instance = FirebaseTokenHelper._();

  /// ⚡ Get token quickly (tanpa refresh)
  ///
  /// Gunakan ini ketika Anda hanya perlu token yang sudah ada
  /// Lebih cepat tapi mungkin token sudah expired
  static Future<String?> getToken() async {
    try {
      return await FirebaseAuthTokenService.instance.getCurrentIdToken();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FirebaseTokenHelper: Error getting token: $e');
      }
      return null;
    }
  }

  /// 🔄 Get token dengan refresh (recommended untuk API calls)
  ///
  /// Selalu refresh token sebelum return untuk memastikan valid
  /// Lebih aman tapi sedikit lebih lambat
  static Future<String?> getTokenRefreshed() async {
    try {
      return await FirebaseAuthTokenService.instance.getIdTokenWithRefresh();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FirebaseTokenHelper: Error getting refreshed token: $e');
      }
      return null;
    }
  }

  /// 📧 Get token untuk manual login
  static Future<String?> getTokenAfterManualLogin({
    required String email,
    required String password,
  }) async {
    try {
      return await FirebaseAuthTokenService.instance.getTokenAfterManualLogin(
        email: email,
        password: password,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FirebaseTokenHelper: Error during manual login: $e');
      }
      return null;
    }
  }

  /// 📝 Get token untuk manual register
  static Future<String?> getTokenAfterManualRegister({
    required String email,
    required String password,
  }) async {
    try {
      return await FirebaseAuthTokenService.instance.getTokenAfterManualRegister(
        email: email,
        password: password,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FirebaseTokenHelper: Error during manual register: $e');
      }
      return null;
    }
  }

  /// 🔐 Get token dari Google sign-in
  static Future<String?> getTokenFromGoogle() async {
    try {
      return await FirebaseAuthTokenService.instance.getTokenFromGoogleSignIn();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FirebaseTokenHelper: Error during Google signin: $e');
      }
      return null;
    }
  }

  /// 🚪 Logout
  static Future<void> logout() async {
    try {
      await FirebaseAuthTokenService.instance.logout();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FirebaseTokenHelper: Error during logout: $e');
      }
    }
  }

  /// 📊 Check if user authenticated
  static bool isAuthenticated() {
    return FirebaseAuthTokenService.instance.isUserAuthenticated();
  }

  /// 🧑 Get current user
  static dynamic getCurrentUser() {
    return FirebaseAuthTokenService.instance.getCurrentUser();
  }
}

