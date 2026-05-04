import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gabungyuk/core/widget/bottom_navigation.dart';
import 'package:gabungyuk/feature/auth/service/account_linking_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseIntegrationService {
  FirebaseIntegrationService._();
  static final FirebaseIntegrationService instance = FirebaseIntegrationService._();

  Future<void> signInWithGoogleAndSync(BuildContext context) async {
    try {
      if (kDebugMode) debugPrint('GOOGLE SIGNIN: starting');

      final GoogleSignInAccount? googleUser =
          await GoogleSignIn.instance.authenticate();

      if (googleUser == null) {
        throw Exception('Login dibatalkan user');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception('Gagal mendapatkan Google ID Token');
      }

      final String email = googleUser.email;
      final String fullName = googleUser.displayName ?? '';
      final String googleUid = googleUser.id;
      final String googleToken = googleAuth.idToken ?? '';
      final String googlePhotoUrl = googleUser.photoUrl ?? '';

      print('GOOGLE SIGNIN: $email');
      print('GOOGLE SIGNIN: $fullName');
      print('GOOGLE SIGNIN: $googleUid');
      print('GOOGLE SIGNIN: $googleToken');
      print('GOOGLE SIGNIN: $googlePhotoUrl');


      if (kDebugMode) {
        final tokenPreview = idToken.length > 20
            ? '${idToken.substring(0, 20)}...'
            : idToken;
        debugPrint('EMAIL: $email');
        debugPrint('NAME: $fullName');
        debugPrint('UID: $googleUid');
        // Safety checks requested: ensure full JWT (header.payload.signature)
        final segments = idToken.split('.');
        final bool hasThreeSegments = segments.length == 3;
        final int tokenLength = idToken.length;

        debugPrint('ID TOKEN (preview): $tokenPreview');
        debugPrint('ID TOKEN not empty: ${idToken.isNotEmpty}');
        debugPrint('ID TOKEN segments == 3: $hasThreeSegments');
        debugPrint('ID TOKEN length: $tokenLength');
        // print the full token in a delimited block so it's easier to copy from logs
        debugPrint('--- BEGIN FULL ID TOKEN ---');
        debugPrint(idToken);
        debugPrint('--- END FULL ID TOKEN ---');
      }

      await AccountLinkingService.instance.smartAccountLink(
        email: email,
        googleUid: googleUid,
        fullName: fullName,
        googleIdToken: idToken,
      );

      if (!context.mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavigation()),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('GOOGLE SIGNIN ERROR: $e');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login gagal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
