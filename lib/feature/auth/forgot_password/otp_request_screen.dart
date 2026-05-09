import 'package:flutter/material.dart';
import 'package:gabungyuk/core/common/shared_code.dart';
import 'package:gabungyuk/feature/auth/service/otp_service.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../core/common/auth_ui_helper.dart';
import '../../../core/common/color_value.dart';
import 'package:gabungyuk/core/widget/loading_shimmer.dart';
import 'otp_verify_screen.dart';

class OtpRequestScreen extends StatefulWidget {
  const OtpRequestScreen({super.key});

  @override
  State<OtpRequestScreen> createState() => _OtpRequestScreenState();
}

class _OtpRequestScreenState extends State<OtpRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final SharedCode _shared = SharedCode();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSubmitting = true);
    final email = _emailController.text.trim();
    try {
      final code = await OtpService.instance.generateAndSaveOtp(email);

      if (!mounted) return;
      
      AuthUiHelper.showSuccess(
        context, 
        'Kode OTP telah dikirim ke email $email. Silakan periksa kotak masuk atau spam.'
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OtpVerifyScreen(email: email)),
      );
    } catch (e) {
      if (!mounted) return;
      AuthUiHelper.showError(context, 'Gagal mengirim OTP. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: ColorValue.textPrimary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Lupa Kata Sandi',
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
                        'Verifikasi Email',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: ColorValue.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Masukkan alamat email Anda untuk menerima\nkode verifikasi (OTP).',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _shared.emailValidator,
                        style: const TextStyle(fontSize: 14, color: ColorValue.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Masukkan alamat email',
                          hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
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
                          onPressed: _isSubmitting ? null : _requestOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorValue.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: _isSubmitting
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
                                  'Kirim Kode OTP',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
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
}
