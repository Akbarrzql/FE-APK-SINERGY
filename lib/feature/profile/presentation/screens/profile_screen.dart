import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gabungyuk/core/common/auth_ui_helper.dart';
import 'package:gabungyuk/core/common/auth_session_manager.dart';
import 'package:gabungyuk/core/common/color_value.dart';
import 'package:gabungyuk/feature/auth/forgot_password/edit_password_screen.dart';
import '../../model/profile_model.dart';
import '../widgets/profile_header.dart';
import '../widgets/stat_card_widget.dart';
import 'edit_profile_screen.dart';
import 'package:gabungyuk/feature/collaboration/presentation/collaboration_profile_screen.dart';
import 'package:gabungyuk/feature/rating/model/user_rating_by_project_model.dart'
as review_model;
import 'package:gabungyuk/feature/rating/presentation/all_reviews_screen.dart';
import 'package:gabungyuk/feature/rating/presentation/user_review_section.dart';
import 'package:gabungyuk/feature/rating/repository/rating_repository.dart';
import 'package:gabungyuk/feature/profile/bloc/profile_bloc.dart';
import 'package:gabungyuk/feature/profile/bloc/profile_event.dart';
import 'package:gabungyuk/feature/profile/bloc/profile_state.dart';
import 'package:gabungyuk/feature/profile/repository/profile_repository.dart';
import 'package:gabungyuk/core/widget/loading_shimmer.dart';

class ProfileScreen extends StatefulWidget {
  final bool hideMenus;

  const ProfileScreen({
    super.key,
    this.hideMenus = false,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileBloc _profileBloc;
  final RatingRepository _ratingRepository = RatingRepositoryImpl();
  bool _isLoadingRatings = true;
  bool _hasRatingError = false;
  List<review_model.Datum> _userReviews = [];
  double? _averageRating;
  int? _totalReviews;

  @override
  void initState() {
    super.initState();
    _profileBloc = ProfileBloc(profileRepository: ProfileRepositoryImpl());
    _profileBloc.add(LoadProfile());
  }

  Future<void> _loadUserRatings(int userId) async {
    setState(() {
      _isLoadingRatings = true;
      _hasRatingError = false;
    });

    try {
      final reviews = await _ratingRepository.getRatingsByUser(userId);
      final avg = await _ratingRepository.getAverageRating(userId);
      setState(() {
        _userReviews = reviews.data?.ratings ?? [];
        _averageRating = reviews.data?.averageRating ?? avg.data?.averageRating;
        _totalReviews = reviews.data?.totalRatings ?? avg.data?.totalReviews;
        _isLoadingRatings = false;
      });
    } catch (e) {
      setState(() {
        _userReviews = [];
        _isLoadingRatings = false;
        _hasRatingError = true;
      });
      debugPrint('Error loading profile ratings: $e');
    }
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
          if (state is ProfileLoaded) {
            _loadUserRatings(state.profile.idPengguna);
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FB),
          body: SafeArea(
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header area with soft gradient backdrop ──────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  if (state is ProfileLoading) return _buildShimmerHeader();
                  if (state is ProfileLoaded) {
                    return ProfileHeader(profile: state.profile);
                  }
                  return const ProfileHeader();
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Stat cards ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Kolaborasi',
                    icon: Icons.groups_rounded,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CollaborationProfileScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Portofolio',
                    icon: Icons.grid_view_rounded,
                    onTap: () => debugPrint('Pindah ke halaman Portofolio'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Rating & review preview ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoading) {
                  return const UserReviewSection(
                    reviews: [],
                    isLoading: true,
                  );
                }
                if (state is ProfileLoaded) {
                  return UserReviewSection(
                    reviews: _userReviews,
                    averageRating: _averageRating,
                    totalReviews: _totalReviews,
                    isLoading: _isLoadingRatings,
                    hasError: _hasRatingError,
                    onViewAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllReviewsScreen(
                            reviews: _userReviews,
                            averageRating: _averageRating,
                            totalReviews: _totalReviews,
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          // ── Settings / menu section ──────────────────────────────────────
          if (!widget.hideMenus) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Pengaturan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _menuItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Informasi Pribadi',
                    subtitle: 'Ubah nama, foto, dan bio',
                    isFirst: true,
                    onTap: () async {
                      final state = _profileBloc.state;
                      ProfileModel? p;
                      if (state is ProfileLoaded) p = state.profile;

                      final result = await Navigator.push<bool?>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: _profileBloc,
                            child: EditProfileScreen(profile: p),
                          ),
                        ),
                      );
                      if (result == true) _profileBloc.add(LoadProfile());
                    },
                  ),
                  _divider(),
                  _menuItem(
                    icon: Icons.lock_outline_rounded,
                    title: 'Reset Password',
                    subtitle: 'Perbarui kata sandi akun',
                    onTap: () async {
                      final result = await Navigator.push<bool?>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditPasswordScreen(),
                        ),
                      );
                      if (result == true) _profileBloc.add(LoadProfile());
                    },
                  ),
                  _divider(),
                  _menuItem(
                    icon: Icons.logout_rounded,
                    title: 'Keluar',
                    subtitle: 'Keluar dari akun ini',
                    isLogout: true,
                    isLast: true,
                    onTap: () async {
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
                            child: Text(
                              'Batal',
                              style: TextStyle(color: ColorValue.primaryColor),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Keluar'),
                          ),
                        ],
                      );
                      if (confirm == true) {
                        await AuthSessionManager.instance.forceLogout();
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ],
      ),
    );
  }

  // ── Shimmer placeholder ────────────────────────────────────────────────────
  Widget _buildShimmerHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            LoadingShimmer.circle(size: 72),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LoadingShimmer(height: 18, width: 160),
                  const SizedBox(height: 8),
                  LoadingShimmer(height: 13, width: 110),
                  const SizedBox(height: 8),
                  LoadingShimmer(height: 13, width: 80),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LoadingShimmer(height: 10, width: double.infinity),
        const SizedBox(height: 8),
        LoadingShimmer(height: 10, width: 200),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _divider() => Divider(
    height: 1,
    indent: 58,
    endIndent: 0,
    color: Colors.grey.shade100,
  );

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLogout = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final Color accent =
    isLogout ? Colors.red.shade400 : ColorValue.primaryColor;
    final Color bgIcon =
    isLogout ? Colors.red.shade50 : ColorValue.primaryColor.withValues(alpha: 0.08);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.only(
          topLeft: isFirst ? const Radius.circular(20) : Radius.zero,
          topRight: isFirst ? const Radius.circular(20) : Radius.zero,
          bottomLeft: isLast ? const Radius.circular(20) : Radius.zero,
          bottomRight: isLast ? const Radius.circular(20) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bgIcon,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isLogout ? Colors.red.shade600 : const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isLogout ? Colors.red.shade300 : Colors.grey.shade300,
              ),
            ],
          ),
        ),
      ),
    );
  }
}