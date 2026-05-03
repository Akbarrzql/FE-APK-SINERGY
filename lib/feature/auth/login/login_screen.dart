import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gabungyuk/core/widget/bottom_navigation.dart';
import 'package:gabungyuk/feature/auth/bloc/login_bloc/login_bloc.dart';
import 'package:gabungyuk/feature/auth/bloc/login_bloc/login_event.dart';
import 'package:gabungyuk/feature/auth/bloc/login_bloc/login_state.dart';
import 'package:gabungyuk/feature/auth/repository/login_repository/login_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gabungyuk/core/common/firebase_user_sync_helper.dart';
import '../service/firebase_integration_service.dart';
import 'package:gabungyuk/feature/auth/forgot_password/forgot_password_screen.dart';

import '../../../../core/gen/assets.gen.dart';
import '../../../../core/gen/fonts.gen.dart';
import '../../../core/common/shared_code.dart';
import '../register/register_screen.dart';

const Color _primaryBlue = Color(0xFF2F80ED);
const Color _titleColor = Color(0xFF111111);
const Color _subtitleColor = Color(0xFF9E9E9E);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final SharedCode _sharedCode = SharedCode();
  late final LoginPageBloc _loginPageBloc;

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loginPageBloc = LoginPageBloc(
      loginRepository: LoginRepositoryImpl(),
    );
  }

  // Try signing in to Firebase but ignore any errors — we only want a local
  // Firebase session when backend login succeeded.
  void _safeFirebaseSignIn(String email, String password) {
    () async {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        try {
          final userData = await FirebaseUserSyncHelper.instance.findUserByEmail(email);
          final provider = userData?['provider']?.toString() ?? '';
          final googleUid = userData?['google_uid']?.toString() ?? '';
          if (provider == 'google' && googleUid.isNotEmpty) {
            final secret = FirebaseUserSyncHelper.instance.deriveGoogleSecret(googleUid);
            await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email,
              password: secret,
            );
            return;
          }
        } catch (fallbackError) {
          if (kDebugMode) debugPrint('SAFE FIREBASE SIGNIN FALLBACK IGNORED: $fallbackError');
        }

        if (kDebugMode) debugPrint('SAFE FIREBASE SIGNIN IGNORED: $e');
      }
    }();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _loginPageBloc.close();
    super.dispose();
  }

  void _onLogin() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      _loginPageBloc.add(
            LoginButtonPressed(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  void _goToRegister() {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _loginPageBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        body: BlocConsumer<LoginPageBloc, LoginPageState>(
          listener: (context, state) {
            if (state is LoginPageLoaded) {
              FocusManager.instance.primaryFocus?.unfocus();

              // Try to sign in to Firebase with the same credentials so Firebase
              // session exists locally. If it fails we ignore and proceed with
              // navigation because backend login already succeeded.
              _safeFirebaseSignIn(_emailController.text.trim(), _passwordController.text);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const BottomNavigation(),
                ),
              );
            } else if (state is LoginPageError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.red.shade600,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(label: 'Tutup', onPressed: () {}),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is LoginPageLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return _buildInitialLayout(context);
          },
        ),
      ),
    );
  }

  Widget _buildInitialLayout(BuildContext context) {
    return SafeArea(
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
                    'Selamat Datang',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: FontFamily.poppins,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _titleColor,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Masukkan email dan password untuk mengakses',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: FontFamily.poppins,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: _subtitleColor,
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
                        color: _subtitleColor,
                        size: 22,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Lupa Password?',
                        style: TextStyle(
                          fontFamily: FontFamily.poppins,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _primaryBlue,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Masuk',
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
                            children: [
                              const Text(
                                'Masuk dengan Google',
                                style: TextStyle(
                                  fontFamily: FontFamily.poppins,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: _titleColor,
                                ),
                              ),
                            ],
                          ),
                          onPressed: () async {
                            try {
                              await FirebaseIntegrationService.instance.signInWithGoogleAndSync(context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          },
                    ),
                  ),

                  const SizedBox(height: 80),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Belum punya akun? ',
                        style: TextStyle(
                          fontFamily: FontFamily.poppins,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: _subtitleColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: _goToRegister,
                        child: const Text(
                          'Daftar',
                          style: TextStyle(
                            fontFamily: FontFamily.poppins,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _primaryBlue,
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
        filled: true,
        fillColor: Colors.transparent,
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
