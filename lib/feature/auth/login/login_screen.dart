import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gabungyuk/core/common/auth_ui_helper.dart';
import 'package:gabungyuk/core/widget/bottom_navigation.dart';
import 'package:gabungyuk/feature/auth/bloc/login_bloc/login_bloc.dart';
import 'package:gabungyuk/feature/auth/bloc/login_bloc/login_event.dart';
import 'package:gabungyuk/feature/auth/bloc/login_bloc/login_state.dart';
import '../forgot_password/reset_password_screen.dart';
import 'package:gabungyuk/feature/auth/repository/login_repository/login_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gabungyuk/core/common/firebase_user_sync_helper.dart';
import '../../../core/widget/auth_text_field.dart';
import '../service/firebase_integration_service.dart';

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

  bool _isLoading(LoginPageState state) => state is LoginPageLoading;

   void _goToRegister() {
     FocusManager.instance.primaryFocus?.unfocus();
     Navigator.push(
       context,
       MaterialPageRoute(
         builder: (context) => const RegisterScreen(),
       ),
     );
   }

   /// 🔍 Handle login error - check if Google-only user
   Future<void> _handleLoginError(
     BuildContext context,
     String errorMessage,
     String email,
   ) async {
     try {
       // Cek di Firestore apakah user ini Google-only
       final userData =
           await FirebaseUserSyncHelper.instance.findUserByEmail(email);

       if (userData != null) {
         final provider = userData['provider']?.toString() ?? '';
         final hasLocalPassword =
             userData['has_local_password'] as bool? ?? true;
         final googleUid = userData['google_uid']?.toString() ?? '';

         // ✅ Google-only user trying manual login
         if (provider == 'google' && !hasLocalPassword && googleUid.isNotEmpty) {
           if (!context.mounted) return;

           _showGoogleUserOptions(context, email);
           return;
         }
       }

       // ❌ Regular error - show snack bar
       if (!context.mounted) return;
       AuthUiHelper.showError(context, errorMessage);
     } catch (e) {
       if (kDebugMode) {
         debugPrint('_handleLoginError: $e');
       }
       // Show original error
       if (!context.mounted) return;
       AuthUiHelper.showError(context, errorMessage);
     }
   }

   /// 💡 Dialog untuk Google-only users
   void _showGoogleUserOptions(BuildContext context, String email) {
     AuthUiHelper.showAppDialog(
       context: context,
       title: 'Akun Google Terdeteksi',
       content: const Text(
         'Akun Anda terdaftar via Google. Untuk login dengan email dan kata sandi manual, silakan atur ulang kata sandi terlebih dahulu.',
         style: TextStyle(
           fontSize: 14,
           height: 1.5,
           color: Color(0xFF555555),
         ),
       ),
       actions: [
         TextButton(
           onPressed: () => Navigator.pop(context),
           child: const Text('Batal'),
         ),
         ElevatedButton(
           onPressed: () {
             Navigator.pop(context);
             _goToResetPassword(context, email);
           },
           child: const Text('Reset Password'),
         ),
         TextButton(
           onPressed: () {
             Navigator.pop(context);
             AuthUiHelper.showInfo(
               context,
               'Silakan gunakan tombol "Masuk dengan Google".',
             );
           },
           child: const Text('Masuk dengan Google'),
         ),
       ],
     );
   }

   void _goToResetPassword(BuildContext context, String email) {
     Navigator.push(
       context,
       MaterialPageRoute(
         builder: (context) => ResetPasswordScreen(email: email),
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
               // 🔍 Check if it's a Google-only user trying manual login
               _handleLoginError(
                 context,
                 state.errorMessage,
                 _emailController.text.trim(),
               );
             }
          },
          builder: (context, state) {
            return _buildInitialLayout(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildInitialLayout(BuildContext context, LoginPageState state) {
    final bool isLoading = _isLoading(state);

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

                  AuthTextField(
                    controller: _emailController,
                    hintText: 'Masukkan email',
                    keyboardType: TextInputType.emailAddress,
                    validator: _sharedCode.emailValidator,
                  ),

                  const SizedBox(height: 14),

                  AuthTextField(
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
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ResetPasswordScreen(
                                    email: _emailController.text.trim(),
                                  ),
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
                      onPressed: isLoading ? null : _onLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
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
                      child: isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor: AlwaysStoppedAnimation<Color>(_titleColor),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
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
                      onPressed: isLoading
                          ? null
                          : () async {
                              try {
                                await FirebaseIntegrationService.instance.signInWithGoogleAndSync(context);
                              } catch (e) {
                                AuthUiHelper.showError(
                                  context,
                                  AuthUiHelper.readableError(
                                    e,
                                    fallback: 'Gagal masuk dengan Google. Silakan coba lagi.',
                                  ),
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
                        onTap: isLoading ? null : _goToRegister,
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


