import 'package:flutter/material.dart';

import '../../../../core/gen/assets.gen.dart';
import '../../../../core/gen/fonts.gen.dart';
import '../../../core/common/shared_code.dart';
import '../login/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final SharedCode _sharedCode = SharedCode();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_formKey.currentState!.validate()) {
      // TODO: proses register
    }
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2F80ED);
    const Color titleColor = Color(0xFF111111);
    const Color subtitleColor = Color(0xFF9E9E9E);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    Image.asset(
                      Assets.image.png.gabungyukLogo.path,
                      width: 210,
                      fit: BoxFit.contain,
                    ),


                    const Text(
                      'Daftar Sekarang',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: FontFamily.poppins,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Masukkan nama, email dan password untuk mengakses',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: FontFamily.poppins,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: subtitleColor,
                      ),
                    ),

                    const SizedBox(height: 28),

                    _AuthTextField(
                      controller: _emailController,
                      hintText: 'Masukkan email',
                      keyboardType: TextInputType.emailAddress,
                      validator: _sharedCode.emailValidator,
                    ),

                    const SizedBox(height: 14),

                    _AuthTextField(
                      controller: _nameController,
                      hintText: 'Masukkan nama',
                      validator: _sharedCode.nameValidator,
                    ),

                    const SizedBox(height: 14),

                    _AuthTextField(
                      controller: _passwordController,
                      hintText: 'Masukkan password',
                      obscureText: _obscurePassword,
                      validator: _sharedCode.passwordValidator,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: subtitleColor,
                          size: 22,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _onRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Daftar',
                          style: TextStyle(
                            fontFamily: FontFamily.poppins,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: register google
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                            color: Color(0xFF222222),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Masuk dengan Google',
                              style: TextStyle(
                                fontFamily: FontFamily.poppins,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: titleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Sudah punya akun? ',
                          style: TextStyle(
                            fontFamily: FontFamily.poppins,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: subtitleColor,
                          ),
                        ),
                        GestureDetector(
                          onTap: _goToLogin,
                          child: const Text(
                            'Masuk',
                            style: TextStyle(
                              fontFamily: FontFamily.poppins,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _AuthTextField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    const Color borderColor = Color(0xFFD9DDE3);
    const Color hintColor = Color(0xFFA7A7A7);
    const Color textColor = Color(0xFF111111);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontFamily: FontFamily.poppins,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontFamily: FontFamily.poppins,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: hintColor,
        ),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: borderColor,
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: borderColor,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF2F80ED),
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        fontFamily: FontFamily.poppins,
        color: Color(0xFFEA4335),
      ),
    );
  }
}