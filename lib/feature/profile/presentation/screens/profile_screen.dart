import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gabungyuk/core/common/auth_session_manager.dart';
import '../../model/profile_model.dart';
import '../widgets/profile_header.dart';
import '../widgets/stat_card_widget.dart';
// 1. Tambahkan import file edit profile di sini
import 'edit_profile_screen.dart';
import 'package:gabungyuk/feature/profile/bloc/profile_bloc.dart';
import 'package:gabungyuk/feature/profile/bloc/profile_event.dart';
import 'package:gabungyuk/feature/profile/bloc/profile_state.dart';
import 'package:gabungyuk/feature/profile/repository/profile_repository.dart';
import 'package:shimmer/shimmer.dart';
import 'package:gabungyuk/feature/auth/forgot_password/forgot_password_screen.dart';
import 'package:gabungyuk/core/common/firebase_user_sync_helper.dart';
import 'package:gabungyuk/feature/auth/forgot_password/reset_password_for_google_user_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    _profileBloc = ProfileBloc(profileRepository: ProfileRepositoryImpl());
    _profileBloc.add(LoadProfile());
  }

  @override
  void dispose() {
    _profileBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileBloc,
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red.shade600,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(label: 'Tutup', onPressed: () {}),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                        if (state is ProfileLoaded) {
                          return ProfileHeader(profile: state.profile);
                        } else if (state is ProfileLoading) {
                          return _buildShimmerHeader();
                        } else {
                          return const ProfileHeader();
                        }
                  },
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    StatCard(
                      title: 'Kolaborasi Anda',
                      icon: Icons.groups_rounded,
                      onTap: () {
                        debugPrint("Pindah ke halaman Kolaborasi");
                      },
                    ),
                    const SizedBox(width: 15),
                    StatCard(
                      title: 'Portofolio Anda',
                      icon: Icons.grid_view_rounded,
                      onTap: () {
                        debugPrint("Pindah ke halaman Portofolio");
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 8, color: Colors.grey.shade100),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 2. Navigasi ke EditProfileScreen ditambahkan di sini
                _menuItem(Icons.person_outline, 'Informasi pribadi', () async {
                  // Pass current profile if loaded
                  final state = _profileBloc.state;
                  ProfileModel? p;
                  if (state is ProfileLoaded) p = state.profile;

                  final result = await Navigator.push<bool?>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(profile: p),
                    ),
                  );

                  // If edit screen signalled an update, reload profile immediately
                  if (result == true) {
                    _profileBloc.add(LoadProfile());
                  }
                }),
                 const SizedBox(height: 2),
                 _menuItem(Icons.lock_open_rounded, 'Reset Password', () async {
                   // Smart routing: check if Google user or email user
                   await _handleResetPasswordTap(context);
                 }),
                 const SizedBox(height: 2),
                _menuItem(Icons.logout, 'Keluar', () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Konfirmasi'),
                      content: const Text('Anda yakin ingin keluar dari akun?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Keluar'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await AuthSessionManager.instance.forceLogout();
                  }
                }, isLogout: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerHeader() {
    // shimmer loading effect
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 18, color: Colors.white, width: 150),
                      const SizedBox(height: 8),
                      Container(height: 14, color: Colors.white, width: 120),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(height: 10, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 10, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    Color themeColor = isLogout ? Colors.red : Colors.black87;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: isLogout ? Colors.red.shade400 : Colors.grey.shade300,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: themeColor, size: 22),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: themeColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isLogout ? Colors.red : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  /// 🔑 Smart reset password routing
  Future<void> _handleResetPasswordTap(BuildContext context) async {
    try {
      // Get current profile email from bloc
      final state = _profileBloc.state;
      String? email;
      if (state is ProfileLoaded) {
        email = state.profile.email;
      }

      if (email == null || email.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email tidak ditemukan')),
        );
        return;
      }

      // At this point email is guaranteed to be non-empty
      final emailStr = email;

      // Check if this is a Google user
      final userData =
          await FirebaseUserSyncHelper.instance.findUserByEmail(emailStr);

      if (userData != null) {
        final provider = userData['provider']?.toString() ?? '';
        final hasLocalPassword =
            userData['has_local_password'] as bool? ?? true;

        if (!context.mounted) return;

        // Google user without local password
        if (provider == 'google' && !hasLocalPassword) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ResetPasswordForGoogleUserScreen(email: emailStr),
            ),
          );
          return;
        }
      }

      // Regular email user or Google user with existing password
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
      );
    } catch (e) {
      if (!context.mounted) return;
      debugPrint('Error in _handleResetPasswordTap: $e');
      // Fallback to regular reset
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
      );
    }
  }
}
