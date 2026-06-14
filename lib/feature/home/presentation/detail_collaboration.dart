import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gabungyuk/core/widget/loading_shimmer.dart';
import 'package:gabungyuk/core/widget/profile_avatar.dart';
import 'package:gabungyuk/core/common/auth_ui_helper.dart';
import 'package:gabungyuk/core/common/color_value.dart';
import 'package:gabungyuk/feature/home/presentation/widget/skill_tag.dart';

import 'package:gabungyuk/feature/home/model/detail_project_model.dart';
import 'package:gabungyuk/feature/home/model/view_project_model.dart';
import 'package:gabungyuk/feature/home/model/view_collaboration_model.dart' as collab_model;
import 'package:gabungyuk/feature/home/model/pending_collaboration_model.dart' as pending_model;
import 'package:gabungyuk/feature/home/service/collaboration_service.dart';
import 'package:gabungyuk/feature/profile/model/view_profile_model.dart';
import 'package:gabungyuk/feature/rating/bloc/rating_bloc.dart';
import 'package:gabungyuk/feature/rating/presentation/rating_collaborators_dialog.dart';
import 'package:gabungyuk/feature/rating/repository/rating_repository.dart';
import 'package:gabungyuk/feature/rating/user_rating_in_project.dart' as project_rating;
import 'edit_collaboration.dart';

// ─── Member Tile Widget ───────────────────────────────────────────────────────
class MemberTile extends StatelessWidget {
  final String name;
  final String role;
  final String imageUrl;
  final double? rating;
  final String? status;
  final bool isOwner;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const MemberTile({
    super.key,
    required this.name,
    required this.role,
    required this.imageUrl,
    this.rating,
    this.status,
    this.isOwner = false,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPending = status?.toUpperCase() == 'PENDING';
    final hasRating = (rating ?? 0) > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          ProfileAvatar(
            imageUrl: imageUrl,
            fullName: name,
            size: 56,
            fontSize: 18,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: ColorValue.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.star_rounded,
                      color: hasRating ? ColorValue.starColor : Colors.grey.shade400,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hasRating ? rating!.toStringAsFixed(1) : 'Belum ada rating',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: hasRating ? ColorValue.textPrimary : Colors.grey.shade500,
                      ),
                    ),
                    if (hasRating) ...[
                      const SizedBox(width: 4),
                      Text(
                        '/5',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (isOwner && isPending) ...[
            const SizedBox(width: 8),
            _ActionButton(
              icon: Icons.check,
              color: Colors.green,
              onTap: onAccept,
            ),
            const SizedBox(width: 8),
            _ActionButton(
              icon: Icons.close,
              color: Colors.red,
              onTap: onReject,
            ),
          ] else if (isPending) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Pending',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }
}

// ─── Detail Collaboration Screen ──────────────────────────────────────────────
class DetailCollaboration extends StatefulWidget {
  final Datum project;
  final ViewProfileModel? owner;

  const DetailCollaboration({
    super.key,
    required this.project,
    this.owner,
  });

  @override
  State<DetailCollaboration> createState() => _DetailCollaborationState();
}

class _DetailCollaborationState extends State<DetailCollaboration> {
  final CollaborationService _collaborationService = CollaborationService();
  final RatingRepository _ratingRepository = RatingRepositoryImpl();
  bool _isLoading = true;
  DetailProjectModel? _detailModel;
  collab_model.ViewCollaborationModel? _collaborationModel;
  pending_model.PendingCollaborationModel? _pendingModel;
  bool _isExpanded = false;
  late String _projectStatus;
  List<project_rating.Datum> _projectRatings = [];
  bool _hasRequestedLocally = false;

  @override
  void initState() {
    super.initState();
    _projectStatus = _mapBackendStatus(widget.project.status);
    _checkLocalRequestStatus();
    _fetchProjectDetail();
  }

  Future<void> _checkLocalRequestStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'requested_join_${widget.project.id}';
    if (mounted) {
      setState(() {
        _hasRequestedLocally = prefs.getBool(key) ?? false;
      });
    }
  }

  Future<void> _markAsRequestedLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'requested_join_${widget.project.id}';
    await prefs.setBool(key, true);
    if (mounted) {
      setState(() {
        _hasRequestedLocally = true;
      });
    }
  }

  Future<void> _fetchProjectDetail() async {
    try {
      final detail = await _collaborationService.getProjectDetail(widget.project.id);

      collab_model.ViewCollaborationModel? collab;
      pending_model.PendingCollaborationModel? pending;

      final isOwner = widget.owner?.idPengguna == widget.project.owner.id;

      if (!isOwner) {
        collab = await _collaborationService.checkJoinStatus(widget.project.id);
      } else {
        pending = await _collaborationService.getPendingRequests(widget.project.id);
      }

      if (mounted) {
        setState(() {
          _detailModel = detail;
          _collaborationModel = collab;
          _pendingModel = pending;
          _isLoading = false;
          if (detail.data.project.status.isNotEmpty) {
            _projectStatus = _mapBackendStatus(detail.data.project.status);
          }
        });
      }

      await _fetchProjectRatings();

    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('Error fetching project detail: $e');
    }
  }

  Future<void> _fetchProjectRatings() async {
    try {
      final ratings = await _ratingRepository.getRatingsByProject(widget.project.id);
      if (!mounted) return;
      setState(() {
        _projectRatings = ratings.data ?? [];
      });
    } catch (e) {
      debugPrint('Error fetching project ratings: $e');
    }
  }

  String _mapBackendStatus(String? status) {
    if (status == null) return 'Belum Dimulai';

    // Jika status sudah dalam bahasa Indonesia, langsung kembalikan
    if (_statusOptions.contains(status)) return status;

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
        return 'Belum Dimulai';
    }
  }

  String _mapToBackendStatus(String label) {
    switch (label) {
      case 'Sedang Berjalan':
        return 'OPEN';
      case 'Selesai':
        return 'DONE';
      case 'Ditunda':
        return 'HOLD';
      case 'Project Berakhir':
        return 'COMPLETED';
      case 'Belum Dimulai':
        return 'NOT OPEN';
      default:
        return 'NOT OPEN';
    }
  }

  final List<String> _statusOptions = [
    'Belum Dimulai',
    'Sedang Berjalan',
    'Selesai',
    'Project Berakhir',
    'Ditunda',
  ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildShimmerLoading();
    }

    final project = _detailModel?.data.project;
    final allCollaborators = _detailModel?.data.collaborators ?? [];
    final isProjectOwner = widget.owner?.idPengguna == widget.project.owner.id;
    final ratingByUserId = <int, double>{};

    for (final userId in _projectRatings.map((e) => e.ratedUserId).whereType<int>().toSet()) {
      final userRatings = _projectRatings.where((r) => r.ratedUserId == userId).toList();
      if (userRatings.isEmpty) continue;
      final average = userRatings.fold<double>(0, (sum, item) => sum + (item.ratingValue ?? 0)) / userRatings.length;
      ratingByUserId[userId] = average;
    }

    final acceptedMembers = allCollaborators.where((c) => c.requestStatus.toUpperCase() == 'ACCEPTED').toList();
    // For owner view, separate requests from team. For others, show everyone with status badges.
    final displayMembers = isProjectOwner ? acceptedMembers : allCollaborators;

    final isUserAccepted = (isProjectOwner || _collaborationModel?.data?.status?.toUpperCase() == 'ACCEPTED' || 
        allCollaborators.any((c) => c.idPengguna == widget.owner?.idPengguna && c.requestStatus.toUpperCase() == 'ACCEPTED'));
    final showFullDetails = isProjectOwner || isUserAccepted;

    final fullDescription = project?.description ?? widget.project.description;
    final shortDesc = fullDescription.length > 100
        ? '${fullDescription.substring(0, 100)}...'
        : fullDescription;

    return Scaffold(
      backgroundColor: ColorValue.backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: ColorValue.textPrimary,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Detail',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ColorValue.textPrimary,
                        ),
                      ),
                    ),
                    if (widget.owner?.idPengguna == widget.project.owner.id)
                      GestureDetector(
                        child: const Text(
                          'Ubah',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ColorValue.primaryColor,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditCollaborationPage(
                                initialData: CollaborationData(
                                  id: widget.project.id.toString(),
                                  title: project?.title ?? widget.project.title,
                                  description: project?.description ?? widget.project.description,
                                  category: List<String>.from(project?.category ?? widget.project.category),
                                  status: _projectStatus,
                                  repositoryLink: project?.repositoryLink ?? widget.project.repositoryLink ?? '',
                                  imageUrl: project?.projectPicture ?? widget.project.projectPicture,
                                  deadline: project?.deadline ?? widget.project.deadline,
                                ),
                              ),
                            ),
                          ).then((value) {
                            if (value == true) {
                              Navigator.pop(context, true); // Refresh list di Home
                            }
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),

            // ── Project Thumbnail ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: (project?.projectPicture != null && project!.projectPicture.isNotEmpty)
                      ? Image.network(
                    project.projectPicture,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                  )
                      : _buildPlaceholderImage(),
                ),
              ),
            ),

            // ── Project Owner Header ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Row(
                  children: [
                    ProfileAvatar(
                      imageUrl: widget.project.owner.profilePicture,
                      fullName: widget.project.owner.fullName,
                      size: 44,
                      fontSize: 14,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.project.owner.fullName ?? 'Project Owner',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: ColorValue.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Project Owner',
                            style: TextStyle(
                              fontSize: 12,
                              color: ColorValue.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Project Info ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      project?.title ?? widget.project.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: ColorValue.textPrimary,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        GestureDetector(
                          onTap: (widget.owner?.idPengguna == widget.project.owner.id && _projectStatus != 'Project Berakhir')
                              ? () => _showStatusPicker(context)
                              : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: _statusColor(_projectStatus).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: _statusColor(_projectStatus).withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _statusColor(_projectStatus),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _projectStatus,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _statusColor(_projectStatus),
                                  ),
                                ),
                                if (widget.owner?.idPengguna == widget.project.owner.id) ...[
                                  const SizedBox(width: 6),
                                  Icon(
                                    _projectStatus == 'Project Berakhir'
                                        ? Icons.lock_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    size: 16,
                                    color: _statusColor(_projectStatus),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: ColorValue.textSecondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (project?.deadline != null)
                          Text(
                            '${project!.deadline!.day}/${project.deadline!.month}/${project.deadline!.year}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: ColorValue.textSecondary,
                            ),
                          )
                        else
                          const Text(
                            'Tidak ada deadline',
                            style: TextStyle(
                              fontSize: 13,
                              color: ColorValue.textSecondary,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Description with "Baca Selengkapnya"
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: ColorValue.textSecondary,
                          height: 1.6,
                        ),
                        children: [
                          TextSpan(
                            text: _isExpanded ? fullDescription : shortDesc,
                          ),
                          if (!_isExpanded && fullDescription.length > 100)
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _isExpanded = true),
                                child: const Text(
                                  ' Baca Selengkapnya...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: ColorValue.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Skill Tags
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...(((project?.category ?? const []).isNotEmpty)
                            ? (project?.category ?? const [])
                            : widget.project.category)
                            .map((cat) => SkillTag(label: cat)),
                      ],
                    ),

                    if (showFullDetails) ...[
                      const SizedBox(height: 28),
                      const Text(
                        'Detail Proyek Lengkap',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ColorValue.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailItem(
                        icon: Icons.link_rounded,
                        label: 'Link Repository',
                        value: project?.repositoryLink ?? widget.project.repositoryLink ?? 'Tidak ada link',
                        onTap: () async {
                          final link = project?.repositoryLink ?? widget.project.repositoryLink;
                          if (link != null && link.isNotEmpty) {
                            final url = Uri.parse(link);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildDetailItem(
                        icon: Icons.calendar_month_rounded,
                        label: 'Deadline',
                        value: project?.deadline != null
                            ? '${project!.deadline!.day}/${project.deadline!.month}/${project.deadline!.year}'
                            : 'Tidak ada deadline',
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ── Team Members Section ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Row(
                  children: [
                    const Text(
                      'Anggota team',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ColorValue.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: ColorValue.tagBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${acceptedMembers.length}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: ColorValue.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Accepted Members List ─────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, i) {
                    final m = displayMembers[i];
                    return Column(
                      children: [
                        MemberTile(
                          name: m.namaLengkap,
                          role: m.keahlian, // Tampilkan keahlian user
                          imageUrl: m.profilePicture ?? '',
                          rating: ratingByUserId[m.idPengguna],
                          status: m.requestStatus,
                          isOwner: isProjectOwner,
                          onAccept: () => _handleCollaborationAction(m.idPengguna, 'ACCEPT'),
                          onReject: () => _handleCollaborationAction(m.idPengguna, 'REJECT'),
                        ),
                        if (i < displayMembers.length - 1)
                          const Divider(
                              height: 1, color: Color(0xFFEEEEEE)),
                      ],
                    );

                  },
                  childCount: displayMembers.length,
                ),
              ),
            ),

            // ── Pending Requests (Only for Owner) ──────────────────────────
            if (isProjectOwner && (_pendingModel?.data?.collaborators?.isNotEmpty ?? false)) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Row(
                    children: [
                      const Text(
                        'Permintaan bergabung',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ColorValue.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: ColorValue.orangeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_pendingModel?.data?.collaborators?.length ?? 0}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: ColorValue.orangeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, i) {
                      final m = _pendingModel!.data!.collaborators![i];
                      return Column(
                        children: [
                          MemberTile(
                            name: m.namaLengkap ?? '',
                            role: m.keahlian ?? 'Anggota', // Tampilkan keahlian user
                            imageUrl: m.profilePicture ?? '',
                            rating: ratingByUserId[m.idPengguna ?? -1],
                            status: 'PENDING',
                            isOwner: true,
                            onAccept: () => _handleCollaborationAction(m.idPengguna!, 'ACCEPT'),
                            onReject: () => _handleCollaborationAction(m.idPengguna!, 'REJECT'),
                          ),
                          if (i < (_pendingModel?.data?.collaborators?.length ?? 0) - 1)
                            const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        ],
                      );
                    },
                    childCount: _pendingModel?.data?.collaborators?.length ?? 0,
                  ),
                ),
              ),
            ],


            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // ── Join Button ────────────────────────────────────────────────
            if (widget.owner?.idPengguna != widget.project.owner.id &&
                !isUserAccepted &&
                _projectStatus != 'Project Berakhir')
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (_collaborationModel?.data?.status?.toUpperCase() == 'ACCEPTED' ||
                          _collaborationModel?.data?.status?.toUpperCase() == 'PENDING' ||
                          _hasRequestedLocally)
                          ? null
                          : () async {
                        try {
                          setState(() => _isLoading = true);
                          await _collaborationService.requestJoin(widget.project.id);
                          await _markAsRequestedLocally();
                          if (mounted) {
                            AuthUiHelper.showSuccess(context, 'Berhasil mengirim permintaan bergabung');
                            _fetchProjectDetail();
                          }
                        } catch (e) {
                          if (mounted) {
                            AuthUiHelper.showError(context, 'Terjadi kesalahan: $e');
                            setState(() => _isLoading = false);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorValue.primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _hasRequestedLocally && _collaborationModel?.data?.status == null
                            ? 'Menunggu Persetujuan'
                            : _getJoinButtonText(_collaborationModel?.data?.status),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCollaborationAction(int userId, String action) async {
    try {
      setState(() => _isLoading = true);
      await _collaborationService.collaborationAction(
        projectId: widget.project.id,
        userId: userId,
        action: action,
      );
      if (mounted) {
        AuthUiHelper.showSuccess(context, 'Berhasil ${action == 'ACCEPT' ? 'menerima' : 'menolak'} permintaan.');
        _fetchProjectDetail();
      }
    } catch (e) {
      if (mounted) {
        AuthUiHelper.showError(context, 'Gagal memproses aksi: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  void _showStatusPicker(BuildContext context) {
    AuthUiHelper.showAppBottomSheet(
      context: context,
      title: 'Pilih Status',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ..._statusOptions.map((s) {
            final isActive = s == _projectStatus;
            return ListTile(
              onTap: () async {
                if (isActive) {
                  Navigator.pop(context);
                  return;
                }

                // Simpan status lama untuk rollback jika gagal
                final oldStatus = _projectStatus;
                final oldBackendStatus = _mapToBackendStatus(oldStatus);
                setState(() => _projectStatus = s);
                Navigator.pop(context);

                try {
                  final project = _detailModel?.data.project;
                  final newBackendStatus = _mapToBackendStatus(s);
                  await _collaborationService.updateCollaboration(
                    id: widget.project.id.toString(),
                    title: project?.title ?? widget.project.title,
                    description: project?.description ?? widget.project.description,
                    category: List<String>.from(project?.category ?? widget.project.category),
                    status: newBackendStatus,
                    repositoryLink: project?.repositoryLink ?? widget.project.repositoryLink ?? '',
                  );

                  if (mounted) {
                    AuthUiHelper.showSuccess(context, 'Status diperbarui ke $s');
                  }

                  if (newBackendStatus == 'COMPLETED' && oldBackendStatus != 'COMPLETED') {
                    await _showCompletionRatingFlow();
                  }
                } catch (e) {
                  if (mounted) {
                    setState(() => _projectStatus = oldStatus);
                    AuthUiHelper.showError(context, 'Gagal memperbarui status: $e');
                  }
                }
              },
              leading: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _statusColor(s),
                ),
              ),
              title: Text(
                s,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive ? ColorValue.primaryColor : ColorValue.textPrimary,
                ),
              ),
              trailing: isActive
                  ? const Icon(Icons.check, color: ColorValue.primaryColor, size: 18)
                  : null,
            );
          }),
        ],
      ),
    );
  }

  Future<void> _showCompletionRatingFlow() async {
    try {
      final detail = await _collaborationService.getProjectDetail(widget.project.id);
      final collaborators = detail.data.collaborators
          .where((c) => c.requestStatus.toUpperCase() == 'ACCEPTED')
          .toList();

      if (!mounted) return;

      if (collaborators.isEmpty) {
        AuthUiHelper.showSuccess(context, 'Project berhasil diselesaikan.');
        return;
      }

      final collaboratorInfos = collaborators
          .map((c) => CollaboratorInfo(
        userId: c.idPengguna,
        userName: c.namaLengkap,
        profilePicture: c.profilePicture,
        role: c.role,
      ))
          .toList();

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => BlocProvider<RatingBloc>(
          create: (_) => RatingBloc(
            ratingRepository: RatingRepositoryImpl(),
          ),
          child: RatingCollaboratorsDialog(
            projectId: widget.project.id,
            collaborators: collaboratorInfos,
            onComplete: () {
              if (mounted) {
                AuthUiHelper.showSuccess(context, 'Semua rating berhasil disimpan.');
              }
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error opening completion rating dialog: $e');
      AuthUiHelper.showSuccess(context, 'Project berhasil diselesaikan.');
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Sedang Berjalan':
        return Colors.green;
      case 'Selesai':
        return Colors.blue;
      case 'Project Berakhir':
        return Colors.purple;
      case 'Ditunda':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }


  String _getJoinButtonText(String? status) {
    if (status == null) return 'Bergabung';
    final s = status.toUpperCase();
    if (s == 'ACCEPTED') return 'Sudah Bergabung';
    if (s == 'PENDING') return 'Menunggu Persetujuan';
    return 'Bergabung';
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 220,
      width: double.infinity,
      color: Colors.grey[300],
      child: const Icon(Icons.image, size: 50, color: Colors.grey),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ColorValue.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: ColorValue.primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: onTap != null ? ColorValue.primaryColor : ColorValue.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.open_in_new_rounded, size: 16, color: ColorValue.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Scaffold(
      backgroundColor: ColorValue.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: LoadingShimmer(height: 30, width: 100),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LoadingShimmer(
                  height: 220,
                  width: double.infinity,
                  borderRadius: 16,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LoadingShimmer(height: 24, width: 200),
                    const SizedBox(height: 10),
                    LoadingShimmer(height: 16, width: 150),
                    const SizedBox(height: 20),
                    LoadingShimmer(height: 80, width: double.infinity),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}