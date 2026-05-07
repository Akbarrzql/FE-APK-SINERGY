import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

/// Service untuk menangani OTP (One-Time Password)
/// Menyimpan kode di Firestore dan mengirimkan email langsung via SMTP dari aplikasi.
class OtpService {
  OtpService._();
  static final OtpService instance = OtpService._();

  final _firestore = FirebaseFirestore.instance;

  /// Generate OTP 6 digit, simpan di Firestore, dan kirim email langsung via SMTP.
  Future<String> generateAndSaveOtp(String email, {int digits = 6, int ttlMinutes = 5}) async {
    final rnd = Random.secure();
    final max = pow(10, digits).toInt();
    final code = (rnd.nextInt(max - (max ~/ 10)) + (max ~/ 10)).toString();

    final expiresAt = DateTime.now().toUtc().add(Duration(minutes: ttlMinutes));

    final docRef = _firestore.collection('password_reset_otps').doc();
    await docRef.set({
      'email': email.trim().toLowerCase(),
      'code': code,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'used': false,
    });

    // Kirim email langsung menggunakan SMTP dari aplikasi
    await _sendEmailDirectly(email, code);

    return code;
  }

  /// Mengirim email OTP langsung menggunakan paket mailer via SMTP.
  /// PERHATIAN: Gunakan 'App Password' (16 digit) jika menggunakan Gmail.
  Future<void> _sendEmailDirectly(String email, String code) async {
    // ⚠️ PENTING: Ganti dengan kredensial email Anda
    // Jangan gunakan password email utama Anda. Gunakan "App Password".
    String username = 'email-anda@gmail.com'; 
    String password = 'abcd efgh ijkl mnop'; // Masukkan 16 digit App Password Anda di sini

    final smtpServer = gmail(username, password);

    // Buat template pesan email HTML yang menarik
    final message = Message()
      ..from = Address(username, 'GabungYuk Admin')
      ..recipients.add(email)
      ..subject = 'Kode OTP Reset Password - GabungYuk'
      ..html = """
        <div style="font-family: sans-serif; padding: 20px; border: 1px solid #eee; border-radius: 12px; max-width: 500px; margin: auto;">
          <h2 style="color: #2F80ED; text-align: center;">Verifikasi Akun</h2>
          <p>Halo,</p>
          <p>Kami menerima permintaan untuk mengatur ulang kata sandi akun Anda di <b>GabungYuk</b>.</p>
          <p>Silakan gunakan kode OTP di bawah ini untuk melanjutkan:</p>
          <div style="font-size: 32px; font-weight: bold; color: #2F80ED; padding: 20px; text-align: center; letter-spacing: 8px; background-color: #f4f8ff; border-radius: 8px; margin: 20px 0;">
            $code
          </div>
          <p style="margin-top: 20px;">Kode ini hanya berlaku selama <b>5 menit</b>. Jika Anda tidak merasa melakukan permintaan ini, silakan abaikan email ini.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
          <p style="font-size: 11px; color: #999; text-align: center;">Email otomatis dari sistem GabungYuk. Mohon tidak membalas.</p>
        </div>
      """;

    try {
      final sendReport = await send(message, smtpServer);
      if (kDebugMode) {
        print('Email terkirim ke $email: ' + sendReport.toString());
      }
    } catch (e) {
      if (kDebugMode) {
        print('Gagal mengirim email: $e');
      }
      // Lempar error agar UI dapat menangani dan menampilkan snackbar error
      throw Exception('Gagal mengirim email verifikasi. Pastikan koneksi internet aktif dan App Password sudah benar.');
    }
  }

  /// Verifikasi OTP: cek apakah email dan kode cocok, belum dipakai, dan belum expired.
  Future<bool> verifyOtp(String email, String code) async {
    final q = await _firestore
        .collection('password_reset_otps')
        .where('email', isEqualTo: email.trim().toLowerCase())
        .where('code', isEqualTo: code.trim())
        .where('used', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (q.docs.isEmpty) return false;

    final doc = q.docs.first;
    final data = doc.data();
    final expires = (data['expiresAt'] as Timestamp?)?.toDate();
    if (expires == null) return false;

    if (DateTime.now().toUtc().isAfter(expires.toUtc())) {
      return false;
    }

    // Tandai sudah digunakan
    await doc.reference.update({'used': true, 'usedAt': FieldValue.serverTimestamp()});
    return true;
  }
}
