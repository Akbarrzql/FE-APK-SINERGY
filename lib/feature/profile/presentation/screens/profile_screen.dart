import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gabungyuk/core/common/auth_ui_helper.dart';
import 'package:gabungyuk/core/common/auth_session_manager.dart';
import 'package:gabungyuk/core/common/color_value.dart';
import 'package:gabungyuk/feature/auth/forgot_password/edit_password_screen.dart';
import '../../model/profile_model.dart';
import '../widgets/profile_header.dart';
import '../widgets/stat_card_widget.dart';
// 1. Tambahkan import file edit profile di sini
import 'edit_profile_screen.dart';
import 'package:gabungyuk/feature/collaboration/presentation/collaboration_profile_screen.dart';
import 'package:gabungyuk/feature/profile/bloc/profile_bloc.dart';
import 'package:gabungyuk/feature/profile/bloc/profile_event.dart';
import 'package:gabungyuk/feature/profile/bloc/profile_state.dart';
import 'package:gabungyuk/feature/profile/repository/profile_repository.dart';
import 'package:gabungyuk/core/widget/loading_shimmer.dart';

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
            AuthUiHelper.showError(context, state.message);
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CollaborationProfileScreen(),
                          ),
                        );
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
                      builder: (context) => BlocProvider.value(
                        value: _profileBloc,
                        child: EditProfileScreen(profile: p),
                      ),
                    ),
                  );

                  // If edit screen signalled an update, reload profile immediately
                  if (result == true) {
                    _profileBloc.add(LoadProfile());
                  }
                }),
                 const SizedBox(height: 2),
                 _menuItem(Icons.lock_open_rounded, 'Reset Password', () async {
                   final result = await Navigator.push<bool?>(
                     context,
                     MaterialPageRoute(
                       builder: (context) => const EditPasswordScreen(),
                     ),
                   );

                   if (result == true) {
                     _profileBloc.add(LoadProfile());
                   }
                 }),
                 const SizedBox(height: 2),
                _menuItem(Icons.logout, 'Keluar', () async {
                  final confirm = await AuthUiHelper.showAppDialog<bool>(
                    context: context,
                    title: 'Konfirmasi',
                    content: const Text(
                      'Anda yakin ingin keluar dari akun?',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF555555),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('Batal', style: TextStyle(color: ColorValue.primaryColor)),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Keluar'),
                      ),
                    ],
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
      child: Column(
        children: [
          Row(
            children: [
              LoadingShimmer.circle(size: 70),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LoadingShimmer(height: 18, width: 150),
                    const SizedBox(height: 8),
                    LoadingShimmer(height: 14, width: 120),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LoadingShimmer(height: 10, width: double.infinity),
          const SizedBox(height: 8),
          LoadingShimmer(height: 10, width: double.infinity),
        ],
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

}
