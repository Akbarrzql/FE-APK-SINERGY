import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gabungyuk/core/common/firebase_user_sync_helper.dart';
import 'package:gabungyuk/core/widget/bottom_navigation.dart';

class SetPasswordForNewGoogleUserScreen extends StatefulWidget {
  final String email;
  final String googleUid;

  const SetPasswordForNewGoogleUserScreen({
    super.key,
    required this.email,
    required this.googleUid,
  });

  @override
  State<SetPasswordForNewGoogleUserScreen> createState() =>
      _SetPasswordForNewGoogleUserScreenState();
}

class _SetPasswordForNewGoogleUserScreenState
    extends State<SetPasswordForNewGoogleUserScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _setPassword() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validasi
    if (password.isEmpty || confirmPassword.isEmpty) {
      _showError('Password tidak boleh kosong');
      return;
    }

    if (password.length < 6) {
      _showError('Password minimal 6 karakter');
      return;
    }

    if (password != confirmPassword) {
      _showError('Password tidak cocok');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (kDebugMode) {
        debugPrint('SET PASSWORD: Starting for ${widget.email}');
      }

      // ✅ 1. Update Firebase Auth password (link email-password)
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User tidak terautentikasi');
      }

      // Link email-password credential ke Firebase user yang sudah login via Google
      final credential = EmailAuthProvider.credential(
        email: widget.email,
        password: password,
      );

      await currentUser.linkWithCredential(credential);

      if (kDebugMode) {
        debugPrint('SET PASSWORD: Firebase Auth linked successfully');
      }

      // ✅ 2. Update Firestore: mark has_local_password = true
      await FirebaseUserSyncHelper.instance.upsertUserDoc(
        uid: currentUser.uid,
        email: widget.email,
        fullName: currentUser.displayName ?? '',
        provider: 'google', // atau 'multi' untuk multi-provider
        googleUid: widget.googleUid,
        hasLocalPassword: true, // Sekarang sudah ada password
      );

      if (kDebugMode) {
        debugPrint('SET PASSWORD: Firestore updated successfully');
      }

      if (!context.mounted) return;

      // ✅ 3. Show success & navigate to dashboard
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password berhasil diatur! Selamat datang.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (!context.mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BottomNavigation()),
        );
      });
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) debugPrint('SET PASSWORD FIREBASE ERROR: ${e.code} ${e.message}');

      String errorMsg = e.message ?? 'Terjadi kesalahan';

      if (e.code == 'provider-already-linked') {
        errorMsg = 'Email sudah terhubung ke akun lain dengan password';
      } else if (e.code == 'credential-already-in-use') {
        errorMsg = 'Email ini sudah digunakan untuk akun lain';
      }

      if (!context.mounted) return;
      _showError(errorMsg);
    } catch (e) {
      if (kDebugMode) debugPrint('SET PASSWORD ERROR: $e');

      if (!context.mounted) return;
      _showError('Gagal mengatur password: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Atur Password'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Atur Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Anda telah masuk dengan Google. Sekarang atur password agar Anda bisa masuk dengan email & password di lain kali.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email: ${widget.email}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Password field
              TextField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Password Baru',
                  hintText: 'Minimal 6 karakter',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm password field
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_showConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password',
                  hintText: 'Ulangi password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () => setState(
                        () => _showConfirmPassword = !_showConfirmPassword),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _setPassword,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Atur Password',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Info text
              Center(
                child: Text(
                  'Password akan digunakan untuk login manual di kemudian hari',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
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

