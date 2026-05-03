import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gabungyuk/feature/profile/repository/profile_repository.dart';

class ResetPasswordInAppScreen extends StatefulWidget {
  final String oobCode;
  const ResetPasswordInAppScreen({super.key, required this.oobCode});

  @override
  State<ResetPasswordInAppScreen> createState() => _ResetPasswordInAppScreenState();
}

class _ResetPasswordInAppScreenState extends State<ResetPasswordInAppScreen> {
  String? _email;
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _resolveEmail();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _resolveEmail() async {
    try {
      final email = await FirebaseAuth.instance.verifyPasswordResetCode(widget.oobCode);
      if (mounted) setState(() => _email = email);
    } catch (e) {
      if (kDebugMode) debugPrint('verifyPasswordResetCode error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Link reset tidak valid atau sudah kadaluarsa.')));
      Navigator.of(context).pop();
    }
  }

  Future<void> _submitNewPassword() async {
    final newPwd = _newPasswordController.text;
    final confirm = _confirmController.text;
    if (newPwd.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password minimal 6 karakter')));
      return;
    }
    if (newPwd != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password tidak cocok')));
      return;
    }
    if (_email == null) return;

    try {
      setState(() => _loading = true);
      // Confirm password reset with Firebase using oobCode
      await FirebaseAuth.instance.confirmPasswordReset(code: widget.oobCode, newPassword: newPwd);

      // Sign in to Firebase to ensure credentials work
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email!, password: newPwd);

      // Update backend password via existing profile update endpoint
      final repo = ProfileRepositoryImpl();
      await repo.updateProfile({'password': newPwd});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password berhasil diubah dan disinkronkan. Silakan masuk.')));
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('confirmPasswordReset error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengganti password: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubah Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${_email ?? '...'}'),
            const SizedBox(height: 12),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password Baru'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Konfirmasi Password'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submitNewPassword,
                child: _loading ? const CircularProgressIndicator() : const Text('Ganti Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

