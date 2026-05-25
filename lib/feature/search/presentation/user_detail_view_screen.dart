import 'package:flutter/material.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/core/common/color_value.dart';
import 'package:gabungyuk/core/widget/loading_shimmer.dart';
import 'package:gabungyuk/feature/profile/model/profile_model.dart';
import 'package:gabungyuk/feature/profile/model/view_profile_model.dart';
import 'package:gabungyuk/feature/profile/presentation/widgets/profile_header.dart';
import 'package:gabungyuk/feature/profile/repository/profile_repository.dart';

class UserDetailViewScreen extends StatefulWidget {
  final int userId;

  const UserDetailViewScreen({
    super.key,
    required this.userId,
  });

  @override
  State<UserDetailViewScreen> createState() =>
      _UserDetailViewScreenState();
}

class _UserDetailViewScreenState
    extends State<UserDetailViewScreen> {
  final ProfileRepository _profileRepository =
  ProfileRepositoryImpl();

  late Future<ViewProfileModel> _profileFuture;

  @override
  void initState() {
    super.initState();

    _profileFuture =
        _profileRepository.getViewProfileById(
          widget.userId,
        );
  }

  Future<void> _reload() async {
    setState(() {
      _profileFuture =
          _profileRepository.getViewProfileById(
            widget.userId,
          );
    });
  }

  Widget _buildShimmerHeader() {
    return SingleChildScrollView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          children: [
            Row(
              children: [
                LoadingShimmer.circle(size: 70),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      LoadingShimmer(
                        height: 18,
                        width: 150,
                      ),
                      const SizedBox(height: 8),
                      LoadingShimmer(
                        height: 14,
                        width: 120,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            LoadingShimmer(
              height: 12,
              width: double.infinity,
            ),

            const SizedBox(height: 8),

            LoadingShimmer(
              height: 12,
              width: double.infinity,
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: LoadingShimmer(
                    height: 45,
                    width: double.infinity,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LoadingShimmer(
                    height: 45,
                    width: double.infinity,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LoadingShimmer(
                    height: 45,
                    width: double.infinity,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LoadingShimmer(
                    height: 45,
                    width: double.infinity,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ProfileModel _mapToProfileModel(
      ViewProfileModel profile,
      ) {
    return ProfileModel(
      idPengguna: profile.idPengguna,
      namaLengkap: profile.namaLengkap,
      email: profile.email,
      bio: profile.bio,
      lokasi: profile.lokasi,
      institusi: profile.institusi,
      profilePicture: profile.profilePicture,
      keahlian: profile.keahlian,
      instagram: profile.instagram,
      linkedin: profile.linkedin,
      facebook: profile.facebook,
      whatsapp: profile.whatsapp,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: ColorValue.textPrimary,
          ),
        ),
        title: const Text(
          'Profil Pengguna',
          style: TextStyle(
            color: ColorValue.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SafeArea(
        child: FutureBuilder<ViewProfileModel>(
          future: _profileFuture,
          builder: (context, snapshot) {
            /// LOADING
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return _buildShimmerHeader();
            }

            /// ERROR
            if (snapshot.hasError) {
              final message =
              snapshot.error is ApiException
                  ? (snapshot.error
              as ApiException)
                  .message
                  : 'Gagal memuat profil pengguna';

              return Center(
                child: Padding(
                  padding:
                  const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 70,
                        color: Colors.red
                            .withValues(alpha: 0.5),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: ColorValue
                              .textSecondary,
                        ),
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: _reload,
                        child:
                        const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }

            /// EMPTY
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            /// SUCCESS
            final profile = snapshot.data!;

            return RefreshIndicator(
              onRefresh: _reload,
              child: SingleChildScrollView(
                physics:
                const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    /// HEADER PROFILE
                    Padding(
                      padding:
                      const EdgeInsets.all(20),
                      child: ProfileHeader(
                        profile:
                        _mapToProfileModel(
                          profile,
                        ),
                      ),
                    ),

                    /// SEPARATOR
                    Container(
                      height: 8,
                      color: Colors.grey.shade100,
                    ),

                    const SizedBox(height: 20),
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