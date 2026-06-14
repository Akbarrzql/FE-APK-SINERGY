import 'package:flutter/material.dart';
import 'package:gabungyuk/core/gen/fonts.gen.dart';
import 'package:gabungyuk/core/widget/auth_text_field.dart';
import '../../../core/common/color_value.dart';
import '../../../core/common/shared_code.dart';
import '../../../core/gen/assets.gen.dart';
import 'package:gabungyuk/feature/auth/service/firebase_password_service.dart';
import 'package:gabungyuk/core/common/auth_ui_helper.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? email;

  const ResetPasswordScreen({this.email, super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  bool _isSubmitting = false;
  final SharedCode _sharedCode = SharedCode();

  static const Color _primaryBlue = Color(0xFF2F80ED);
  static const Color _titleColor = Color(0xFF111111);
  static const Color _subtitleColor = Color(0xFF9E9E9E);

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    try {
      final email = _emailController.text.trim();
      
      // Kirim email reset password via Firebase
      await FirebasePasswordService.instance.sendPasswordResetEmail(email);

      if (!mounted) return;
      AuthUiHelper.showSuccess(
        context, 
        'Link pemulihan telah dikirim ke email Anda. Silakan periksa kotak masuk atau folder spam.'
      );
      
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      AuthUiHelper.showError(
        context,
        AuthUiHelper.readableError(
          e,
          fallback: 'Gagal mengirim email. Pastikan email Anda benar dan terdaftar.',
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColorValue.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Lupa Kata Sandi',
          style: TextStyle(color: ColorValue.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  Assets.image.png.resetPasswordIlustration.path,
                  height: 200,
                ),
                const SizedBox(height: 40),
                const Text(
                  'Atur Ulang Kata Sandi',
                  style: TextStyle(
                    fontFamily: FontFamily.poppins,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: _titleColor,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Masukkan email Anda. Kami akan mengirimkan link untuk mengatur ulang kata sandi Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: FontFamily.poppins,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: _subtitleColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                AuthTextField(
                  controller: _emailController,
                  hintText: 'Masukkan email Anda',
                  keyboardType: TextInputType.emailAddress,
                  validator: _sharedCode.emailValidator,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Kirim Link Pemulihan',
                            style: TextStyle(
                              fontFamily: FontFamily.poppins,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
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
}
