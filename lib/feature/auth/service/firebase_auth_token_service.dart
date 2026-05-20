import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:gabungyuk/core/common/shared_code.dart';

/// 🔐 Firebase Auth Token Service
///
/// Mengelola Firebase ID Token untuk semua metode autentikasi
/// - Manual login/register
/// - Google Sign-In
/// - Token refresh
class FirebaseAuthTokenService {
  FirebaseAuthTokenService._();
  static final FirebaseAuthTokenService instance =
      FirebaseAuthTokenService._();

  final SharedCode _sharedCode = SharedCode();

  bool _isValidJwtToken(String? token) {
    if (token == null || token.isEmpty) return false;

    final parts = token.split('.');
    if (parts.length != 3) return false;

    final lengths = parts.map((s) => s.length).toList();
    if (kDebugMode) {
      debugPrint('FIREBASE TOKEN: JWT segment lengths = $lengths');
    }

    // Segmen signature biasanya panjang (ratusan karakter).
    // Ambang konservatif agar token pendek/bukan JWT tidak lolos.
    return parts[0].length > 10 && parts[1].length > 10 && parts[2].length > 100;
  }

  /// 📱 Get Firebase ID Token dari current user
  ///
  /// Jika user sudah login di Firebase, ambil token langsung
  /// Jika belum, return null
  Future<String?> getCurrentIdToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (kDebugMode) {
          debugPrint(
              'FIREBASE TOKEN: No current user in Firebase Auth');
        }
        return null;
      }

      final tokenResult = await user.getIdTokenResult(true);
      final token = tokenResult.token;

      if (!_isValidJwtToken(token)) {
        if (kDebugMode) {
          debugPrint('FIREBASE TOKEN: Current token failed JWT validation');
        }
        return null;
      }

      // ✅ Update SharedPreferences session
      if (token != null) {
        await _sharedCode.saveAuthSession(
          token: token,
          expiredAt: tokenResult.expirationTime?.millisecondsSinceEpoch ?? 0,
        );
      }

      if (kDebugMode && token != null) {
        debugPrint('FIREBASE TOKEN: Retrieved current token: ${token.substring(0, 20)}...');
        //print all token
        debugPrint('FIREBASE TOKEN: Retrieved current token: $token');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FIREBASE TOKEN: Error getting current token: $e');
      }
      return null;
    }
  }

  /// 🔄 Get Firebase ID Token (dengan force refresh)
  ///
  /// Ambil token dan force refresh jika sudah ada
  Future<String?> getIdTokenWithRefresh() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (kDebugMode) {
          debugPrint(
              'FIREBASE TOKEN: No current user for token refresh');
        }
        return null;
      }

      // Force refresh token
      final tokenResult = await user.getIdTokenResult(true);
      final token = tokenResult.token;

      if (!_isValidJwtToken(token)) {
        if (kDebugMode) {
          debugPrint('FIREBASE TOKEN: Refreshed token failed JWT validation');
        }
        return null;
      }

      // ✅ Update SharedPreferences session
      if (token != null) {
        await _sharedCode.saveAuthSession(
          token: token,
          expiredAt: tokenResult.expirationTime?.millisecondsSinceEpoch ?? 0,
        );
      }

      if (kDebugMode && token != null) {
        debugPrint(
            'FIREBASE TOKEN: Retrieved refreshed token: ${token.substring(0, 20)}...');
        debugPrint('FIREBASE TOKEN: Retrieved current token: $token');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FIREBASE TOKEN: Error getting refreshed token: $e');
      }
      return null;
    }
  }

  /// 📧 Get or Create Firebase user setelah manual login
  ///
  /// Untuk login manual (backend sudah berhasil),
  /// kita buat/sign-in user di Firebase Auth
  Future<String?> getTokenAfterManualLogin({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('FIREBASE TOKEN: Attempting Firebase sign-in for $email');
      }

      // Coba sign in ke Firebase dengan kredensial yang sama
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Firebase user tidak ditemukan setelah login');
      }

      final tokenResult = await user.getIdTokenResult(true);
      final token = tokenResult.token;

      if (!_isValidJwtToken(token)) {
        if (kDebugMode) {
          debugPrint('FIREBASE TOKEN: Firebase login token failed JWT validation');
        }
        return null;
      }

      // ✅ Update SharedPreferences session
      if (token != null) {
        await _sharedCode.saveAuthSession(
          token: token,
          expiredAt: tokenResult.expirationTime?.millisecondsSinceEpoch ?? 0,
        );
      }

      if (kDebugMode && token != null) {
        debugPrint(
            'FIREBASE TOKEN: Firebase login success for $email, token: ${token.substring(0, 20)}...');
        debugPrint('FIREBASE TOKEN: Retrieved current token: $token');
      }
      return token;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint(
            'FIREBASE TOKEN: Firebase auth exception during login: ${e.code} - $e');
      }

      // Jika user sudah exist atau ada error, coba ambil token dari user yang sudah login
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.email == email) {
          final tokenResult = await user.getIdTokenResult(true);
          final token = tokenResult.token;

          if (!_isValidJwtToken(token)) {
            if (kDebugMode) {
              debugPrint('FIREBASE TOKEN: Existing user token failed JWT validation');
            }
            return null;
          }

          // ✅ Update SharedPreferences session
          if (token != null) {
            await _sharedCode.saveAuthSession(
              token: token,
              expiredAt: tokenResult.expirationTime?.millisecondsSinceEpoch ?? 0,
            );
          }

          if (kDebugMode && token != null) {
            debugPrint(
                'FIREBASE TOKEN: Retrieved token from existing user: ${token.substring(0, 20)}...');
            debugPrint('FIREBASE TOKEN: Retrieved current token: $token');
          }
          return token;
        }
      } catch (_) {}

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FIREBASE TOKEN: Unexpected error during manual login: $e');
      }
      return null;
    }
  }

  /// 📝 Get or Create Firebase user setelah manual register
  ///
  /// Untuk register manual (backend sudah berhasil),
  /// kita buat user di Firebase Auth
  Future<String?> getTokenAfterManualRegister({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
            'FIREBASE TOKEN: Attempting Firebase user creation for $email');
      }

      // Coba create user di Firebase
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Firebase user tidak ditemukan setelah register');
      }

      final tokenResult = await user.getIdTokenResult(true);
      final token = tokenResult.token;

      if (!_isValidJwtToken(token)) {
        if (kDebugMode) {
          debugPrint('FIREBASE TOKEN: Firebase register token failed JWT validation');
        }
        return null;
      }

      // ✅ Update SharedPreferences session
      if (token != null) {
        await _sharedCode.saveAuthSession(
          token: token,
          expiredAt: tokenResult.expirationTime?.millisecondsSinceEpoch ?? 0,
        );
      }

      if (kDebugMode && token != null) {
        debugPrint(
            'FIREBASE TOKEN: Firebase register success for $email, token: ${token.substring(0, 20)}...');
        debugPrint('FIREBASE TOKEN: Retrieved current token: $token');
      }
      return token;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint(
            'FIREBASE TOKEN: Firebase auth exception during register: ${e.code} - $e');
      }

      // Jika user sudah ada (email-already-in-use), coba login untuk mendapat token
      if (e.code == 'email-already-in-use') {
        if (kDebugMode) {
          debugPrint('FIREBASE TOKEN: User already exists, trying login');
        }
        return getTokenAfterManualLogin(email: email, password: password);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FIREBASE TOKEN: Unexpected error during manual register: $e');
      }
      return null;
    }
  }

  /// 🔐 Get Firebase token dari ID Token (untuk Google login)
  ///
  /// Ini untuk Google login yang sudah punya Firebase user
  Future<String?> getTokenFromGoogleSignIn() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (kDebugMode) {
          debugPrint('FIREBASE TOKEN: No current Firebase user for Google');
        }
        return null;
      }

      final tokenResult = await user.getIdTokenResult(true);
      final token = tokenResult.token;

      if (!_isValidJwtToken(token)) {
        if (kDebugMode) {
          debugPrint('FIREBASE TOKEN: Google auth token failed JWT validation');
        }
        return null;
      }

      // ✅ Update SharedPreferences session
      if (token != null) {
        await _sharedCode.saveAuthSession(
          token: token,
          expiredAt: tokenResult.expirationTime?.millisecondsSinceEpoch ?? 0,
        );
      }

      if (kDebugMode && token != null) {
        debugPrint(
            'FIREBASE TOKEN: Retrieved Google auth token: ${token.substring(0, 20)}...');
        debugPrint('FIREBASE TOKEN: Retrieved current token: $token');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FIREBASE TOKEN: Error getting token for Google user: $e');
      }
      return null;
    }
  }

  /// 🚪 Logout dan hapus token
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (kDebugMode) {
        debugPrint('FIREBASE TOKEN: User logged out successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FIREBASE TOKEN: Error during logout: $e');
      }
    }
  }

  /// ℹ️ Get current user info
  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  /// 📊 Check if user is authenticated
  bool isUserAuthenticated() {
    return FirebaseAuth.instance.currentUser != null;
  }
}

