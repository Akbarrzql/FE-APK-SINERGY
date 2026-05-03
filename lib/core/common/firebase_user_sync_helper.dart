import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

class FirebaseUserSyncHelper {
  FirebaseUserSyncHelper._();
  static final FirebaseUserSyncHelper instance = FirebaseUserSyncHelper._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String deriveGoogleSecret(String googleUid) {
    final hash = sha256.convert(utf8.encode('gabungyuk_google_$googleUid'));
    return '${hash.toString().substring(0, 24)}Ab@1';
  }

  Future<void> upsertUserDoc({
    required String uid,
    required String email,
    required String fullName,
    required String provider,
    String? googleUid,
    bool hasLocalPassword = true,
  }) async {
    final ref = _firestore.collection('users').doc(uid);
    await ref.set({
      'email': email,
      'full_name': fullName,
      'provider': provider,
      if (googleUid != null) 'google_uid': googleUid,
      'has_local_password': hasLocalPassword,
      'updated_at': FieldValue.serverTimestamp(),
      'created_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return snapshot.docs.first.data();
  }
}
