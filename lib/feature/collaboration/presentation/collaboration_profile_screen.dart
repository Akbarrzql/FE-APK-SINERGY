import 'package:flutter/material.dart';
import 'package:gabungyuk/core/widget/loading_shimmer.dart';
import 'package:gabungyuk/core/common/color_value.dart';
import 'package:gabungyuk/feature/collaboration/model/collaboration_profile_model.dart';
import 'package:gabungyuk/feature/home/service/collaboration_service.dart';
import 'package:gabungyuk/feature/home/presentation/detail_collaboration.dart';
import 'package:gabungyuk/feature/home/model/view_project_model.dart';
import 'package:gabungyuk/feature/home/model/request_collaboration_model.dart' as request_model;
import 'package:gabungyuk/feature/profile/model/view_profile_model.dart';
import 'package:gabungyuk/feature/profile/repository/profile_repository.dart';
import 'package:gabungyuk/feature/rating/model/user_rating_by_project_model.dart' as review_model;
import 'package:gabungyuk/feature/rating/presentation/user_review_section.dart' as user_review;
import 'package:gabungyuk/feature/rating/repository/rating_repository.dart';

class CollaborationProfileScreen extends StatefulWidget {
  const CollaborationProfileScreen({super.key});

  @override
  State<CollaborationProfileScreen> createState() => _CollaborationProfileScreenState();
}

class _CollaborationProfileScreenState extends State<CollaborationProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CollaborationService _collaborationService = CollaborationService();
  final ProfileRepository _profileRepository = ProfileRepositoryImpl();
  final RatingRepository _ratingRepository = RatingRepositoryImpl();
  bool _isLoading = true;
  CollaborationProfileModel? _profileData;
  ViewProfileModel? _profile;
  String _searchQuery = "";
  bool _isLoadingRatings = true;
  bool _hasRatingError = false;
  List<review_model.Datum> _userReviews = [];
  double? _averageRating;
  int? _totalReviews;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _collaborationService.getCollaborationDashboard(),
        _profileRepository.getViewProfile(),
      ]);
      
      setState(() {
        _profileData = results[0] as CollaborationProfileModel;
        _profile = results[1] as ViewProfileModel;
        _isLoading = false;
      });
      _fetchUserRatings();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  Future<void> _fetchUserRatings() async {
    setState(() {
      _isLoadingRatings = true;
      _hasRatingError = false;
    });
    try {
      final reviews = await _ratingRepository.getRatingsByUser(_profile!.idPengguna);
      final avg = await _ratingRepository.getAverageRating(_profile!.idPengguna);
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
      debugPrint('Error loading user ratings: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kolaborasi Saya',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildSearchField(),
          // User rating preview for account owner
          if (!_isLoading)
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: user_review.UserReviewSection(
            //     reviews: _userReviews,
            //     averageRating: _averageRating,
            //     totalReviews: _totalReviews,
            //     isLoading: _isLoadingRatings,
            //     hasError: _hasRatingError,
            //   ),
            // ),
          _buildTabBar(),
          Expanded(
            child: _isLoading
                ? _buildShimmerLoading()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProjectList(isOwned: true),
                      _buildProjectList(isOwned: false),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 50,
        child: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
          decoration: InputDecoration(
            hintText: 'Cari Kolaborasi',
            hintStyle: const TextStyle(
              color: ColorValue.textSecondary,
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: ColorValue.textSecondary,
              size: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: ColorValue.borderColor,
                width: 1.2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: ColorValue.borderColor,
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
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Colors.transparent,
        dividerColor: Colors.transparent,
        labelColor: ColorValue.primaryColor,
        unselectedLabelColor: Colors.grey,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        tabAlignment: TabAlignment.start,
        tabs: [
          _buildTabItem('Proyek Saya', 0),
          _buildTabItem('Kolaborasi Saya', 1),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    return Tab(
      child: AnimatedBuilder(
        animation: _tabController.animation!,
        builder: (context, child) {
          double offset = _tabController.animation!.value;
          bool isSelected = (offset - index).abs() < 0.5;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? ColorValue.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectList({required bool isOwned}) {
    List<dynamic> projects = [];
    if (_profileData?.data != null) {
      if (isOwned) {
        projects = (_profileData!.data!.ownedProjects ?? []).reversed.toList();
      } else {
        projects = (_profileData!.data!.requestCollab ?? []).reversed.toList();
      }
    }

    if (_searchQuery.isNotEmpty) {
      projects = projects.where((p) {
        final title = _projectTitle(p);
        return title.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Tidak ada proyek ditemukan',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return _buildProjectCard(project, isOwned);
      },
    );
  }

  Widget _buildProjectCard(dynamic project, bool isOwned) {
    final String title = _projectTitle(project);
    final String description = _projectDescription(project);
    final List<String> category = _projectCategory(project);
    final String statusLabel = _projectStatusLabel(project);
    final int id = _projectId(project);
    final DateTime? deadlineDate = _projectDeadline(project);

    final String deadlineStr = deadlineDate != null
        ? '${deadlineDate.day}/${deadlineDate.month}/${deadlineDate.year}'
        : "";


    final String displayStatus = _mapStatus(statusLabel);
    final Color statusColor = _statusColor(displayStatus);

    final String ownerName = isOwned ? (_profile?.namaLengkap ?? 'Anda') : _projectOwnerName(project);
    final String? ownerImage = isOwned ? _profile?.profilePicture : _projectOwnerImage(project);

    return GestureDetector(
      onTap: () {
        // Pastikan kita punya data profil sebelum navigasi
        if (_profile == null || id == 0) return;

        final datum = Datum(
          id: id,
          title: title,
          description: description,
          category: category,
          status: statusLabel, // Gunakan status asli (backend)
          repositoryLink: _projectRepositoryLink(project),
          projectPicture: _projectPicture(project),
          owner: Owner(
            id: isOwned 
                ? _profile!.idPengguna 
                : _projectOwnerId(project),
            fullName: isOwned ? _profile!.namaLengkap : ownerName,
            email: isOwned ? _profile!.email : '',
            profilePicture: isOwned ? _profile!.profilePicture : ownerImage,
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailCollaboration(
              project: datum,
              owner: _profile,
            ),
          ),
        ).then((result) {
          if (result == true) {
            _loadData();
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[100],
                  backgroundImage: ownerImage != null && ownerImage.isNotEmpty ? NetworkImage(ownerImage) : null,
                  child: ownerImage == null || ownerImage.isEmpty ? const Icon(Icons.person, size: 20, color: Colors.blue) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ownerName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        isOwned ? 'Pemilik Kolaborasi' : 'Kolaborator',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (statusLabel.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      displayStatus,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: ColorValue.textPrimary),
            ),
            const SizedBox(height: 4),
            if (deadlineStr.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_outlined, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      deadlineStr,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ...(category.isNotEmpty ? category : const ['General'])
                        .map((item) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _buildTag(item),
                            )),
                  ],
                ),
                MemberAvatarsWidget(projectId: id),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _projectId(dynamic project) {
    if (project is OwnedProject) return project.id ?? 0;
    if (project is request_model.Data) {
      return project.projectId ?? project.project?.projectId ?? 0;
    }
    if (project is Map) {
      final value = project['projectId'] ?? project['id'] ?? project['project']?['projectId'] ?? project['project']?['id'];
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }
    return 0;
  }

  String _projectTitle(dynamic project) {
    if (project is OwnedProject) return project.title ?? '';
    if (project is request_model.Data) return project.project?.title ?? '';
    if (project is Map) return project['title']?.toString() ?? project['project']?['title']?.toString() ?? '';
    return '';
  }

  String _projectDescription(dynamic project) {
    if (project is OwnedProject) return project.description ?? '';
    if (project is request_model.Data) return project.project?.description ?? '';
    if (project is Map) return project['description']?.toString() ?? project['project']?['description']?.toString() ?? '';
    return '';
  }

  List<String> _projectCategory(dynamic project) {
    if (project is OwnedProject) return project.category.isNotEmpty ? project.category : const [];
    if (project is request_model.Data) return project.project?.category ?? const [];
    if (project is Map) {
      final raw = project['category'] ?? project['project']?['category'];
      if (raw is List) return List<String>.from(raw);
    }
    return const [];
  }

  String _projectStatusLabel(dynamic project) {
    if (project is OwnedProject) return project.status ?? '';
    if (project is request_model.Data) return project.project?.status ?? project.status ?? '';
    if (project is Map) return project['status']?.toString() ?? project['project']?['status']?.toString() ?? '';
    return '';
  }

  DateTime? _projectDeadline(dynamic project) {
    if (project is OwnedProject) return project.deadline;
    if (project is request_model.Data) {
      // Request-collab items don't expose deadline in the current model, so use nested project data if available.
      return null;
    }
    if (project is Map) {
      final raw = project['deadline'] ?? project['project']?['deadline'];
      if (raw == null) return null;
      return DateTime.tryParse(raw.toString());
    }
    return null;
  }

  String _projectPicture(dynamic project) {
    if (project is OwnedProject) return project.projectPicture ?? '';
    if (project is request_model.Data) return project.project?.projectPicture ?? '';
    if (project is Map) return project['projectPicture']?.toString() ?? project['project']?['projectPicture']?.toString() ?? '';
    return '';
  }

  String _projectRepositoryLink(dynamic project) {
    if (project is OwnedProject) return project.repositoryLink ?? '';
    if (project is request_model.Data) return project.project?.repositoryLink ?? '';
    if (project is Map) return project['repositoryLink']?.toString() ?? project['project']?['repositoryLink']?.toString() ?? '';
    return '';
  }

  int _projectOwnerId(dynamic project) {
    if (project is request_model.Data) return project.owner?.idPengguna ?? 0;
    if (project is Map) {
      final value = project['owner']?['idPengguna'] ?? project['owner']?['id'] ?? 0;
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }
    return 0;
  }

  String _projectOwnerName(dynamic project) {
    if (project is request_model.Data) return project.owner?.namaLengkap ?? 'Pemilik Kolaborasi';
    if (project is Map) return project['owner']?['namaLengkap']?.toString() ?? project['owner']?['fullName']?.toString() ?? 'Pemilik Kolaborasi';
    return 'Pemilik Kolaborasi';
  }

  String? _projectOwnerImage(dynamic project) {
    if (project is request_model.Data) return project.owner?.profilePicture;
    if (project is Map) return project['owner']?['profilePicture']?.toString();
    return null;
  }

  String _mapStatus(String? status) {
    if (status == null || status.isEmpty) return 'Belum Dimulai';

    // Jika status sudah dalam bahasa Indonesia, kembalikan
    const statusOptions = ['Belum Dimulai', 'Sedang Berjalan', 'Selesai', 'Project Berakhir', 'Ditunda'];
    if (statusOptions.contains(status)) return status;

    switch (status.toUpperCase()) {
      case 'OPEN':
        return 'Sedang Berjalan';
      case 'COMPLETED':
        return 'Project Berakhir';
      case 'DONE':
        return 'Selesai';
      case 'HOLD':
        return 'Ditunda';
      case 'NOT OPEN':
        return 'Belum Dimulai';
      default:
        return status;
    }
  }

  Color _statusColor(String displayStatus) {
    switch (displayStatus) {
      case 'Sedang Berjalan':
        return Colors.green;
      case 'Selesai':
        return Colors.blue;
      case 'Project Berakhir':
        return Colors.purple;
      case 'Ditunda':
        return Colors.orange;
      case 'Belum Dimulai':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTag(String label) {
    if (label.isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ColorValue.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: ColorValue.primaryColor, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: LoadingShimmer(
            width: double.infinity,
            height: 200,
            borderRadius: 16,
          ),
        );
      },
    );
  }
}

class MemberAvatarsWidget extends StatelessWidget {
  final int projectId;
  const MemberAvatarsWidget({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final CollaborationService service = CollaborationService();
    
    return FutureBuilder(
      future: service.getProjectDetail(projectId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(width: 40, height: 32);
        }

        final collaborators = snapshot.data!.data.collaborators;
        final displayCount = collaborators.length > 3 ? 3 : collaborators.length;
        final extraCount = collaborators.length - displayCount;

        if (collaborators.isEmpty) return const SizedBox();

        return SizedBox(
          width: 32.0 + (displayCount * 14.0),
          height: 32,
          child: Stack(
            children: [
              for (int i = 0; i < displayCount; i++)
                Positioned(
                  left: i * 16.0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 13,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: (collaborators[i].profilePicture != null && collaborators[i].profilePicture!.isNotEmpty)
                          ? NetworkImage(collaborators[i].profilePicture!)
                          : null,
                      child: (collaborators[i].profilePicture == null || collaborators[i].profilePicture!.isEmpty)
                          ? const Icon(Icons.person, size: 12)
                          : null,
                    ),
                  ),
                ),
              if (extraCount > 0)
                Positioned(
                  left: displayCount * 16.0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 13,
                      backgroundColor: const Color(0xFFF0F5FF),
                      child: Text(
                        '${extraCount}+',
                        style: const TextStyle(
                          fontSize: 9, 
                          fontWeight: FontWeight.bold,
                          color: ColorValue.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
