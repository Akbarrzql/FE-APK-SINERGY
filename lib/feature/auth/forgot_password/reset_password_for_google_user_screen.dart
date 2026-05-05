import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/core/common/auth_ui_helper.dart';
import 'package:gabungyuk/core/common/shared_code.dart';
import 'package:gabungyuk/feature/auth/service/reset_password_service.dart';
import '../../../core/gen/assets.gen.dart';

class ResetPasswordForGoogleUserScreen extends StatefulWidget {
  final String email;

  const ResetPasswordForGoogleUserScreen({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordForGoogleUserScreen> createState() =>
      _ResetPasswordForGoogleUserScreenState();
}

class _ResetPasswordForGoogleUserScreenState
    extends State<ResetPasswordForGoogleUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showOldPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _loading = false;

  final SharedCode _sharedCode = SharedCode();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final oldPwd = _oldPasswordController.text.trim();
    final newPwd = _newPasswordController.text.trim();

    if (newPwd == oldPwd) {
      _showSnackBar(
        'Kata sandi baru tidak boleh sama dengan yang lama.',
        Colors.orange,
      );
      return;
    }

    setState(() => _loading = true);
    try {
      if (kDebugMode) {
        debugPrint('RESET PASSWORD SCREEN: submitting for ${widget.email}');
      }

      await ResetPasswordService.instance.resetPasswordForGoogleUser(
        email: widget.email,
        oldPassword: oldPwd,
        newPassword: newPwd,
      );

      if (!mounted) return;

      _showSnackBar(
        'Kata sandi berhasil diubah! Anda sekarang bisa masuk dengan email dan kata sandi baru.',
        Colors.green,
      );

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (kDebugMode) {
        debugPrint('RESET PASSWORD SCREEN ERROR: ${e.message}');
      }
      _showSnackBar(AuthUiHelper.toIndonesianMessage(e.message), Colors.red);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('RESET PASSWORD SCREEN ERROR: $e');
      }
      _showSnackBar(
        AuthUiHelper.readableError(
          e,
          fallback: 'Gagal mengubah kata sandi. Silakan coba lagi.',
        ),
        Colors.red,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    AuthUiHelper.showSnackBar(
      context,
      message,
      backgroundColor: backgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF111111),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Image.asset(
                        Assets.image.png.resetPasswordIlustration.path,
                        height: 220,
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Masukkan password lama dan password baru untuk\nmengatur ulang kata sandi Anda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildPasswordField(
                        label: 'Password Lama',
                        controller: _oldPasswordController,
                        hint: 'Masukkan password lama',
                        obscure: !_showOldPassword,
                        enabled: !_loading,
                        onToggle: () {
                          setState(() => _showOldPassword = !_showOldPassword);
                        },
                        validator: (v) => _sharedCode.emptyValidator(v),
                      ),
                      const SizedBox(height: 14),
                      _buildPasswordField(
                        label: 'Password Baru',
                        controller: _newPasswordController,
                        hint: 'Masukkan password baru',
                        obscure: !_showNewPassword,
                        enabled: !_loading,
                        onToggle: () {
                          setState(() => _showNewPassword = !_showNewPassword);
                        },
                        validator: (v) {
                          final base = _sharedCode.emptyValidator(v) ??
                              _sharedCode.passwordValidator(v);
                          if (base != null) return base;
                          if (v?.trim() == _oldPasswordController.text.trim()) {
                            return 'Password baru tidak boleh sama dengan yang lama';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildPasswordField(
                        label: 'Konfirmasi Password Baru',
                        controller: _confirmPasswordController,
                        hint: 'Konfirmasi password baru',
                        obscure: !_showConfirmPassword,
                        enabled: !_loading,
                        onToggle: () {
                          setState(
                              () => _showConfirmPassword = !_showConfirmPassword);
                        },
                        validator: (v) {
                          final base = _sharedCode.emptyValidator(v);
                          if (base != null) return base;
                          if (v?.trim() != _newPasswordController.text.trim()) {
                            return 'Password baru tidak cocok';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F80ED),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Reset Password',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed:
                              _loading ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFFD9DDE3),
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111111),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required bool enabled,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          enabled: enabled,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFFA7A7A7),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFFA7A7A7),
                size: 20,
              ),
              onPressed: onToggle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFD9DDE3),
                width: 1.2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFD9DDE3),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF2F80ED),
                width: 1.4,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.2,
              ),
            ),
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF111111),
          ),
        ),
      ],
    );
  }
}

