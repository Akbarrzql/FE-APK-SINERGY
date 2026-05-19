import 'package:flutter/material.dart';
import 'package:gabungyuk/feature/auth/service/firebase_password_service.dart';
import 'package:gabungyuk/feature/auth/forgot_password/reset_password_in_app_screen.dart';
import 'package:gabungyuk/core/common/auth_ui_helper.dart';
import 'package:gabungyuk/core/common/color_value.dart';
import '../../../core/gen/assets.gen.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String email;
  const OtpVerifyScreen({required this.email, super.key});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _codeController = TextEditingController();
  bool _isVerifying = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      AuthUiHelper.showError(context, 'Masukkan kode verifikasi.');
      return;
    }

    setState(() => _isVerifying = true);
    try {
      // ✅ Verify code dengan Firebase
      await FirebasePasswordService.instance.verifyPasswordResetCode(code);

      if (!mounted) return;
      AuthUiHelper.showSuccess(context, 'Verifikasi berhasil!');

      // Navigate to password reset form
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordInAppScreen(oobCode: code),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      AuthUiHelper.showError(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: ColorValue.textPrimary, size: 22),
                  ),
                  const SizedBox(width: 12),
                   const Text(
                     'Verifikasi Email',
                     style: TextStyle(
                       fontSize: 18,
                       fontWeight: FontWeight.w700,
                       color: ColorValue.textPrimary,
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
                      'Masukkan Kode Verifikasi',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: ColorValue.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                          height: 1.6,
                          fontFamily: 'Poppins',
                        ),
                        children: [
                          const TextSpan(text: 'Masukkan kode verifikasi yang telah dikirimkan ke email '),
                          TextSpan(
                            text: widget.email,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: ColorValue.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 8,
                        color: ColorValue.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: '000000',
                        hintStyle: TextStyle(fontSize: 24, color: Colors.grey[300], letterSpacing: 8),
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: ColorValue.primaryColor, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isVerifying ? null : _verify,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorValue.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _isVerifying
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Lanjutkan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Tidak menerima kode? ',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Logic to resend OTP
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Kirim Ulang',
                            style: TextStyle(
                              color: ColorValue.primaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
