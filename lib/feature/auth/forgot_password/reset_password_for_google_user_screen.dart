import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/feature/auth/service/reset_password_service.dart';

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
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showOldPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _loading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final oldPwd = _oldPasswordController.text.trim();
    final newPwd = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    // ✅ Validation
    if (oldPwd.isEmpty) {
      _showSnackBar('Masukkan password lama', Colors.orange);
      return;
    }

    if (newPwd.isEmpty) {
      _showSnackBar('Masukkan password baru', Colors.orange);
      return;
    }

    if (newPwd.length < 6) {
      _showSnackBar('Password minimal 6 karakter', Colors.orange);
      return;
    }

    if (newPwd != confirm) {
      _showSnackBar('Password baru tidak cocok', Colors.red);
      return;
    }

    if (newPwd == oldPwd) {
      _showSnackBar('Password baru tidak boleh sama dengan yang lama',
          Colors.orange);
      return;
    }

    setState(() => _loading = true);
    try {
      if (kDebugMode) {
        debugPrint(
            'RESET PASSWORD SCREEN: submitting for ${widget.email}');
      }

      await ResetPasswordService.instance.resetPasswordForGoogleUser(
        email: widget.email,
        oldPassword: oldPwd,
        newPassword: newPwd,
      );

      if (!mounted) return;

      _showSnackBar(
        'Password berhasil diubah! Anda sekarang bisa login dengan email dan password baru.',
        Colors.green,
      );

      // Tunggu 2 detik, lalu kembali ke login
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pop(true); // Indicate success
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        debugPrint('RESET PASSWORD SCREEN ERROR: ${e.message}');
      }
      _showSnackBar(e.message, Colors.red);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('RESET PASSWORD SCREEN ERROR: $e');
      }
      _showSnackBar('Gagal mengubah password: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🖼️ Illustration
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: Colors.blue.shade300,
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                const Text(
                  'Reset Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'Masukkan password lama dan password baru untuk mengubah akses masuk Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                // ❌ Important info for Google users
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    border: Border.all(color: Colors.amber.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.amber.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Jika ini login pertama kali dari Google, gunakan "Lihat Password Lama" untuk melihat password yang sudah terisi otomatis.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Old Password Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Password Lama',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      controller: _oldPasswordController,
                      hintText: 'Masukkan password lama',
                      obscure: !_showOldPassword,
                      onToggleVisibility: () {
                        setState(() => _showOldPassword = !_showOldPassword);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // New Password Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Password Baru',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      controller: _newPasswordController,
                      hintText: 'Masukkan password baru (minimal 6 karakter)',
                      obscure: !_showNewPassword,
                      onToggleVisibility: () {
                        setState(() => _showNewPassword = !_showNewPassword);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Confirm Password Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Konfirmasi Password Baru',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      hintText: 'Konfirmasi password baru',
                      obscure: !_showConfirmPassword,
                      onToggleVisibility: () {
                        setState(() =>
                            _showConfirmPassword = !_showConfirmPassword);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F80ED),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Reset Password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscure,
    required VoidCallback onToggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      enabled: !_loading,
      decoration: InputDecoration(
        hintText: hintText,
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
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: const Color(0xFFA7A7A7),
            size: 20,
          ),
          onPressed: onToggleVisibility,
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
      ),
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xFF111111),
      ),
    );
  }
}

