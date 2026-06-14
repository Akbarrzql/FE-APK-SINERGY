import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gabungyuk/core/common/app_ui_helper.dart';
import 'package:gabungyuk/core/widget/auth_text_field.dart';
import 'package:gabungyuk/feature/auth/bloc/register_bloc/register_bloc.dart';
import 'package:gabungyuk/feature/auth/bloc/register_bloc/register_event.dart';
import 'package:gabungyuk/feature/auth/bloc/register_bloc/register_state.dart';
import '../forgot_password/reset_password_screen.dart';

import '../../../../core/gen/assets.gen.dart';
import '../../../../core/gen/fonts.gen.dart';
import '../../../core/common/shared_code.dart';
import '../service/firebase_integration_service.dart';
import '../../../core/widget/bottom_navigation.dart';
import '../login/login_screen.dart';
import '../repository/register_repository/register_repository.dart';

const Color _primaryBlue = Color(0xFF2F80ED);
const Color _titleColor = Color(0xFF111111);
const Color _subtitleColor = Color(0xFF9E9E9E);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final SharedCode _sharedCode = SharedCode();
  late final RegisterPageBloc _registerPageBloc;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _isLoading(RegisterPageState state) => state is RegisterPageLoading;

  @override
  void initState() {
    super.initState();
    _registerPageBloc = RegisterPageBloc(
      registerRepository: RegisterRepositoryImpl(),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _registerPageBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _registerPageBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        body: BlocConsumer<RegisterPageBloc, RegisterPageState>(
          listener: (context, state) {
            if (state is RegisterPageLoaded) {
              FocusManager.instance.primaryFocus?.unfocus();

              AppUiHelper.showSuccess(context, 'Registrasi berhasil! Silakan masuk.');
              
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            } else if (state is RegisterPageError) {
              AppUiHelper.showError(context, state.errorMessage);
            }
          },
          builder: (context, state) {
            return _buildInitialLayout(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildInitialLayout(BuildContext context, RegisterPageState state) {
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
                    'Daftar Sekarang',
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
                    'Masukkan nama, email dan password untuk mengakses',
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
                    controller: _nameController,
                    hintText: 'Masukkan nama',
                    validator: _sharedCode.nameValidator,
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
                  const SizedBox(height: 14),
                  AuthTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Konfirmasi password',
                    obscureText: _obscureConfirmPassword,
                    validator: (value) => _sharedCode.confirmPasswordValidator(
                      value,
                      _passwordController.text,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: _subtitleColor,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              if (_formKey.currentState!.validate()) {
                                context.read<RegisterPageBloc>().add(
                                  RegisterButtonPressed(
                                    name: _nameController.text.trim(),
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text,
                                  ),
                                );
                              }
                            },
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
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
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
                                await FirebaseIntegrationService.instance
                                    .signInWithGoogleAndSync(context);
                              } catch (e) {
                                AppUiHelper.showError(
                                  context,
                                  AppUiHelper.readableError(
                                    e,
                                    fallback:
                                        'Gagal masuk dengan Google. Silakan coba lagi.',
                                  ),
                                );
                              }
                            },
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
                          color: _subtitleColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: isLoading
                            ? null
                            : () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                        child: const Text(
                          'Masuk',
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

// Removed _AuthTextField as it is now using the global AuthTextField component
