import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gabungyuk/core/common/api_config.dart';
import 'package:gabungyuk/core/common/shared_code.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _syncEmailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // form key not needed for simple email sender; kept for future use
  final _syncFormKey = GlobalKey<FormState>();
  bool _loading = false;
  final SharedCode _sharedCode = SharedCode();

  @override
  void dispose() {
    _emailController.dispose();
    _syncEmailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    try {
      setState(() => _loading = true);
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email reset telah dikirim. Periksa inbox Anda.')),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('sendPasswordResetEmail error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim email: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _syncNewPassword() async {
    if (!_syncFormKey.currentState!.validate()) return;
    final email = _syncEmailController.text.trim();
    final newPassword = _newPasswordController.text;

    try {
      setState(() => _loading = true);

      // Sign in to Firebase with new password to confirm user owns the password
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: newPassword);

      // Get Firebase idToken
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken(true);
      if (idToken == null) throw Exception('Gagal mendapatkan idToken dari Firebase.');

      // Send idToken + newPassword to backend so server can verify token and update stored password
      final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/users/firebase');
      final payload = {'idToken': idToken, 'newPassword': newPassword};

      if (kDebugMode) debugPrint('SYNC PASSWORD: POST $url payload=${payload}');

      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (kDebugMode) debugPrint('SYNC PASSWORD: status=${resp.statusCode} body=${resp.body}');

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        // try parse app token and save session if provided
        try {
          final Map<String, dynamic> json = jsonDecode(resp.body);
          final data = json['data'] ?? json;
          final token = data['token']?.toString() ?? '';
          final expiredAt = (data['expiredAt'] is int) ? data['expiredAt'] : int.tryParse('${data['expiredAt']}') ?? 0;
          if (token.isNotEmpty) await _sharedCode.saveAuthSession(token: token, expiredAt: expiredAt);
        } catch (_) {}

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password berhasil disinkronkan ke server. Silakan masuk.')),
          );
        }
      } else {
        String message = 'Gagal menyinkronkan ke server.';
        try {
          final Map<String, dynamic> json = jsonDecode(resp.body);
          if (json.containsKey('message')) message = json['message'].toString();
          else if (json.containsKey('error')) message = json['error'].toString();
        } catch (_) {}
        throw Exception(message);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('sync password error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal sinkronisasi: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lupa Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kirim Email Reset', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _sendResetEmail,
                child: _loading ? const CircularProgressIndicator() : const Text('Kirim Email Reset'),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            const Text('Sudah mengganti kata sandi? Sinkronkan ke server', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Form(
              key: _syncFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _syncEmailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v == null || v.isEmpty ? 'Masukkan email' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: const InputDecoration(labelText: 'Password Baru'),
                    obscureText: true,
                    validator: (v) => v == null || v.length < 6 ? 'Password minimal 6 karakter' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(labelText: 'Konfirmasi Password'),
                    obscureText: true,
                    validator: (v) => v != _newPasswordController.text ? 'Password tidak cocok' : null,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _syncNewPassword,
                      child: _loading ? const CircularProgressIndicator() : const Text('Sinkronkan ke Server'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Catatan:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('1) Setelah mengubah password melalui email reset Firebase, masukkan email dan password baru pada form di atas untuk menyinkronkan password ke server.'),
            const SizedBox(height: 6),
            const Text('2) Jika backend Anda belum mendukung sinkronisasi melalui Firebase token, Anda perlu menambahkan endpoint khusus yang menerima idToken dan newPassword.'),
          ],
        ),
      ),
    );
  }
}

