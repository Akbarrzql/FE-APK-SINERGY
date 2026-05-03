import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:gabungyuk/core/common/api_config.dart';
import 'package:gabungyuk/core/common/shared_code.dart';
import 'package:gabungyuk/core/widget/bottom_navigation.dart';

class FirebaseIntegrationService {
  FirebaseIntegrationService._();
  static final FirebaseIntegrationService instance = FirebaseIntegrationService._();

  final SharedCode _sharedCode = SharedCode();

  /// Sign in with Google using Firebase, then send the Firebase ID token to
  /// backend to create or login the user there. Backend must expose an
  /// endpoint to accept Firebase ID tokens and return the app session token.
  ///
  /// Expected backend request: POST ${ApiConfig.baseUrl}/api/v1/users/firebase
  /// body: { "idToken": "<firebase-id-token>", "email": "...", "name": "..." }
  /// Expected backend response: JSON containing app token and expiry, e.g.
  /// { "data": { "token": "...", "expiredAt": 1234567890 }, "message": "..." }
  Future<void> signInWithGoogleAndSync(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // user canceled
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('Gagal mendapatkan token dari Google.');
      }

      // Sign in to Firebase with the Google credentials so Firebase session is established locally
      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      // Send idToken to backend to create/update user and return app token
      final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/users/firebase');
      final payload = {
        'idToken': idToken,
        'email': googleUser.email,
        'name': googleUser.displayName,
      };

      if (kDebugMode) {
        debugPrint('FIREBASE INTEGRATION DEBUG: POST $url');
        debugPrint('FIREBASE INTEGRATION DEBUG: payload=${jsonEncode(payload)}');
      }

      final resp = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (kDebugMode) {
        debugPrint('FIREBASE INTEGRATION DEBUG: status=${resp.statusCode} body=${resp.body}');
      }

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        try {
          final Map<String, dynamic> json = jsonDecode(resp.body);
          final data = json['data'] ?? json;
          final token = data['token']?.toString() ?? '';
          final expiredAt = (data['expiredAt'] is int) ? data['expiredAt'] : int.tryParse('${data['expiredAt']}') ?? 0;

          if (token.isNotEmpty) {
            await _sharedCode.saveAuthSession(token: token, expiredAt: expiredAt);
          }

          // Navigate to app main screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BottomNavigation()),
          );
        } catch (e) {
          throw Exception('Respons backend tidak dapat diproses: $e');
        }
      } else {
        // show server error if any
        String message = 'Gagal sinkronisasi dengan server.';
        try {
          final Map<String, dynamic> json = jsonDecode(resp.body);
          if (json.containsKey('message')) message = json['message'].toString();
          else if (json.containsKey('error')) message = json['error'].toString();
          else if (json.containsKey('details')) message = json['details'].toString();
        } catch (_) {}

        throw Exception(message);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('FIREBASE INTEGRATION ERROR: $e');
      rethrow;
    }
  }
}

