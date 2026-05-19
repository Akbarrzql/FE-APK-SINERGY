import 'dart:convert';

import 'package:flutter/foundation.dart';
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

  /// Hash password untuk disimpan di Firestore
  String hashPassword(String password) {
    final hash = sha256.convert(utf8.encode('gabungyuk_pwd_$password'));
    return hash.toString();
  }

  /// Verify password against hash
  bool verifyPassword(String password, String hash) {
    return hashPassword(password) == hash;
  }

  Future<void> upsertUserDoc({
    required String uid,
    required String email,
    required String fullName,
    required String provider,
    String? googleUid,
    bool hasLocalPassword = true,
    bool passwordJustSet = false,
    String? localPassword,
    String? plainPassword,
    String? firebaseIdToken,
  }) async {
    final docId = email.trim();
    final ref = _firestore.collection('users').doc(docId);
    if (kDebugMode) {
      debugPrint('FIRESTORE SYNC: upserting users/$docId (uid=$uid, provider=$provider, hasLocalPassword=$hasLocalPassword)');
    }
    await ref.set({
      'uid': uid,
      'email': email,
      'full_name': fullName,
      'provider': provider,
      if (googleUid != null) 'google_uid': googleUid,
      'has_local_password': hasLocalPassword,
      if (localPassword != null) 'local_password': localPassword,
      if (plainPassword != null) 'plain_password': plainPassword,
      if (firebaseIdToken != null) 'firebase_id_token': firebaseIdToken,
      if (passwordJustSet) 'password_set_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'created_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    final docSnapshot = await _firestore.collection('users').doc(email.trim()).get();
    if (docSnapshot.exists) {
      return docSnapshot.data();
    }

    final snapshot = await _firestore.collection('users').where('email', isEqualTo: email).limit(1).get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return snapshot.docs.first.data();
  }

  /// Update FCM Token untuk push notifications
  Future<void> updateFcmToken(String email, String token) async {
    final docId = email.trim();
    final ref = _firestore.collection('users').doc(docId);
    await ref.set({
      'fcm_token': token,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Update Firebase ID Token
  Future<void> updateUserFirebaseToken({
    required String uid,
    required String email,
    String? firebaseIdToken,
  }) async {
    final docId = email.trim();
    final ref = _firestore.collection('users').doc(docId);
    if (kDebugMode) {
      debugPrint('FIRESTORE: updating Firebase ID Token for $email');
    }
    await ref.set({
      'uid': uid,
      'firebase_id_token': firebaseIdToken,
      'firebase_token_updated_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
