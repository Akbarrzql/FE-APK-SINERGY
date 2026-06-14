import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gabungyuk/core/widget/loading_shimmer.dart';
import 'package:gabungyuk/core/common/app_ui_helper.dart';

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
      if (mounted) {
        AppUiHelper.showError(context, 'Tautan reset tidak valid atau sudah kedaluwarsa.');
      }
      Navigator.of(context).pop();
    }
  }

   Future<void> _submitNewPassword() async {
     final newPwd = _newPasswordController.text;
     final confirm = _confirmController.text;
     if (newPwd.length < 6) {
        AppUiHelper.showError(context, 'Kata sandi minimal 6 karakter.');
       return;
     }
     if (newPwd != confirm) {
        AppUiHelper.showError(context, 'Kata sandi tidak cocok.');
       return;
     }
     if (_email == null) return;

      try {
        setState(() => _loading = true);

        // ✅ Confirm password reset with Firebase
        if (kDebugMode) debugPrint('RESET PASSWORD: Confirming Firebase password reset');
        await FirebaseAuth.instance.confirmPasswordReset(
          code: widget.oobCode,
          newPassword: newPwd,
        );

        if (mounted) {
          AppUiHelper.showSuccess(
            context,
            'Kata sandi berhasil diubah. Silakan masuk kembali.'
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        if (kDebugMode) debugPrint('RESET PASSWORD error: $e');
        if (mounted) {
          AppUiHelper.showError(
            context,
            AppUiHelper.readableError(
              e,
              fallback: 'Gagal mengubah kata sandi. Silakan coba lagi.',
            ),
          );
        }
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
                child: _loading ? LoadingShimmer.button() : const Text('Ganti Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

