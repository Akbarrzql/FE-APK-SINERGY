import 'package:flutter/material.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/core/common/color_value.dart';
import 'package:gabungyuk/core/widget/loading_shimmer.dart';
import 'package:gabungyuk/feature/profile/model/profile_model.dart';
import 'package:gabungyuk/feature/profile/model/view_profile_model.dart';
import 'package:gabungyuk/feature/profile/presentation/widgets/profile_header.dart';
import 'package:gabungyuk/feature/profile/repository/profile_repository.dart';
import 'package:gabungyuk/feature/rating/model/user_rating_average_model.dart'
as average_model;
import 'package:gabungyuk/feature/rating/model/user_rating_by_project_model.dart'
as review_model;
import 'package:gabungyuk/feature/rating/presentation/all_reviews_screen.dart';
import 'package:gabungyuk/feature/rating/presentation/user_review_section.dart';
import 'package:gabungyuk/feature/rating/repository/rating_repository.dart';

// ── Data bundle ───────────────────────────────────────────────────────────────
class _UserRatingBundle {
  final review_model.UserRatingByProjectModel? reviews;
  final average_model.UserRatingAverageModel? average;
  final Object? error;

  const _UserRatingBundle({this.reviews, this.average, this.error});

  bool get hasError => reviews == null && average == null && error != null;
}

// ── Screen ────────────────────────────────────────────────────────────────────
class UserDetailViewScreen extends StatefulWidget {
  final int userId;

  const UserDetailViewScreen({
    super.key,
    required this.userId,
  });

  @override
  State<UserDetailViewScreen> createState() => _UserDetailViewScreenState();
}

class _UserDetailViewScreenState extends State<UserDetailViewScreen> {
  final ProfileRepository _profileRepository = ProfileRepositoryImpl();
  final RatingRepository _ratingRepository = RatingRepositoryImpl();

  late Future<ViewProfileModel> _profileFuture;
  late Future<_UserRatingBundle> _ratingFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _profileRepository.getViewProfileById(widget.userId);
    _ratingFuture = _loadUserRatings();
  }

  // ── Data loaders ──────────────────────────────────────────────────────────
  Future<void> _reload() async {
    setState(() {
      _profileFuture = _profileRepository.getViewProfileById(widget.userId);
      _ratingFuture = _loadUserRatings();
    });
  }

  Future<_UserRatingBundle> _loadUserRatings() async {
    review_model.UserRatingByProjectModel? reviews;
    average_model.UserRatingAverageModel? average;
    Object? error;

    try {
      reviews = await _ratingRepository.getRatingsByUser(widget.userId);
    } catch (e) {
      error = e;
    }

    try {
      average = await _ratingRepository.getAverageRating(widget.userId);
    } catch (e) {
      error ??= e;
    }

    return _UserRatingBundle(reviews: reviews, average: average, error: error);
  }

  ProfileModel _mapToProfileModel(ViewProfileModel p) => ProfileModel(
    idPengguna: p.idPengguna,
    namaLengkap: p.namaLengkap,
    email: p.email,
    bio: p.bio,
    lokasi: p.lokasi,
    institusi: p.institusi,
    profilePicture: p.profilePicture,
    keahlian: p.keahlian,
    instagram: p.instagram,
    linkedin: p.linkedin,
    facebook: p.facebook,
    whatsapp: p.whatsapp,
  );

  // ── Shimmer placeholder ───────────────────────────────────────────────────
  Widget _buildShimmer() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ShimmerHeader(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                LoadingShimmer(height: 130, width: double.infinity),
                const SizedBox(height: 12),
                LoadingShimmer(height: 80, width: double.infinity),
                const SizedBox(height: 12),
                LoadingShimmer(height: 80, width: double.infinity),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Error state ───────────────────────────────────────────────────────────
  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 34,
                color: Colors.red.shade300,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat profil',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _reload,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorValue.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade100),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: ColorValue.textPrimary,
        ),
        title: const Text(
          'Profil Pengguna',
          style: TextStyle(
            color: ColorValue.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: FutureBuilder<ViewProfileModel>(
          future: _profileFuture,
          builder: (context, snapshot) {
            // ── Loading ──────────────────────────────────────────────────
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmer();
            }

            // ── Error ────────────────────────────────────────────────────
            if (snapshot.hasError) {
              final msg = snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'Coba periksa koneksi internet Anda.';
              return _buildError(msg);
            }

            // ── Empty ────────────────────────────────────────────────────
            if (!snapshot.hasData) return const SizedBox.shrink();

            // ── Success ──────────────────────────────────────────────────
            final profile = snapshot.data!;

            return RefreshIndicator(
              onRefresh: _reload,
              color: ColorValue.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Profile header ─────────────────────────────────
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(28),
                          bottomRight: Radius.circular(28),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      child: ProfileHeader(
                        profile: _mapToProfileModel(profile),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Rating & reviews ───────────────────────────────
                    FutureBuilder<_UserRatingBundle>(
                      future: _ratingFuture,
                      builder: (context, ratingSnap) {
                        if (ratingSnap.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: UserReviewSection(
                              reviews: [],
                              isLoading: true,
                            ),
                          );
                        }

                        if (!ratingSnap.hasData) {
                          return const SizedBox.shrink();
                        }

                        final bundle = ratingSnap.data!;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: UserReviewSection(
                            reviews: bundle.reviews?.data?.ratings ?? const [],
                            averageRating:
                                bundle.reviews?.data?.averageRating ??
                                    bundle.average?.data?.averageRating,
                            totalReviews: bundle.reviews?.data?.totalRatings ??
                                bundle.average?.data?.totalReviews,
                            isLoading: false,
                            hasError: bundle.hasError,
                            onViewAll: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AllReviewsScreen(
                                    reviews:
                                        bundle.reviews?.data?.ratings ?? [],
                                    averageRating:
                                        bundle.reviews?.data?.averageRating ??
                                            bundle.average?.data?.averageRating,
                                    totalReviews:
                                        bundle.reviews?.data?.totalRatings ??
                                            bundle.average?.data?.totalReviews,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Shimmer header (extracted widget) ────────────────────────────────────────
class _ShimmerHeader extends StatelessWidget {
  const _ShimmerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
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
          LoadingShimmer(height: 10, width: 220),
        ],
      ),
    );
  }
}