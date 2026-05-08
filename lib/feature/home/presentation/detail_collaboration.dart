import 'package:flutter/material.dart';
import 'package:gabungyuk/core/common/auth_ui_helper.dart';
import 'package:gabungyuk/core/common/color_value.dart';
import 'package:gabungyuk/feature/home/presentation/widget/skill_tag.dart';

import 'package:gabungyuk/feature/home/model/detail_project_model.dart';
import 'package:gabungyuk/feature/home/model/view_project_model.dart';
import 'package:gabungyuk/feature/home/service/collaboration_service.dart';
import 'package:gabungyuk/feature/profile/model/view_profile_model.dart';
import 'edit_collaboration.dart';

// ─── Member Tile Widget ───────────────────────────────────────────────────────
class MemberTile extends StatelessWidget {
  final String name;
  final String role;
  final String imageUrl;
  final int rating;

  const MemberTile({
    super.key,
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[200],
            backgroundImage: (imageUrl.isNotEmpty && imageUrl.startsWith('http'))
                ? NetworkImage(imageUrl)
                : null,
            child: (imageUrl.isEmpty || !imageUrl.startsWith('http'))
                ? const Icon(Icons.person, color: Colors.grey, size: 30)
                : null,
          ),
          const SizedBox(width: 14),

          // Name & Role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ColorValue.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.star_rounded,
                      color: ColorValue.starColor,
                      size: 18,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '$rating',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColorValue.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 13,
                    color: ColorValue.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
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
  bool _isLoading = true;
  DetailProjectModel? _detailModel;
  bool _isExpanded = false;
  late String _projectStatus;

  @override
  void initState() {
    super.initState();
    _projectStatus = _mapBackendStatus(widget.project.status);
    _fetchProjectDetail();
  }

  Future<void> _fetchProjectDetail() async {
    try {
      final detail = await _collaborationService.getProjectDetail(widget.project.id);
      if (mounted) {
        setState(() {
          _detailModel = detail;
          _isLoading = false;
          if (detail.data.project.status.isNotEmpty) {
            _projectStatus = _mapBackendStatus(detail.data.project.status);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('Error fetching project detail: $e');
    }
  }

  String _mapBackendStatus(String? status) {
    if (status == null) return 'Belum Dimulai';
    
    // Jika status sudah dalam bahasa Indonesia, langsung kembalikan
    if (_statusOptions.contains(status)) return status;

    switch (status.toUpperCase()) {
      case 'OPEN':
        return 'Sedang Berjalan';
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
    'Ditunda',
  ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final project = _detailModel?.data.project;
    final collaborators = _detailModel?.data.collaborators ?? [];

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
                    // if (widget.owner?.idPengguna == widget.project.idPengguna)
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
                                  category: project?.category ?? widget.project.category ?? '',
                                  status: _projectStatus,
                                  repositoryLink: project?.repositoryLink ?? widget.project.repositoryLink ?? '',
                                  imageUrl: project?.projectPicture ?? widget.project.projectPicture,
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
                    const SizedBox(height: 8),

                    // Type & Date
                    Row(
                      children: [
                        Text(
                          project?.category ?? widget.project.category ?? 'General',
                          style: const TextStyle(
                            fontSize: 13,
                            color: ColorValue.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: ColorValue.textSecondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '12 Maret 2023',
                          style: TextStyle(
                            fontSize: 13,
                            color: ColorValue.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: () => _showStatusPicker(context),
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
                            const SizedBox(width: 6),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: _statusColor(_projectStatus),
                            ),
                          ],
                        ),
                      ),
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
                        SkillTag(label: project?.category ?? widget.project.category ?? 'General'),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Team Members Section ─────────────────────────────
                    Row(
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
                            '${collaborators.length}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: ColorValue.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Divider
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ],
                ),
              ),
            ),

            // ── Member List ────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, i) {
                    final m = collaborators[i];
                    return Column(
                      children: [
                        MemberTile(
                          name: m.namaLengkap,
                          role: m.role,
                          imageUrl: m.profilePicture ?? 'https://i.pravatar.cc/150?img=8',
                          rating: 5, // Rating default karena belum ada di model
                        ),
                        if (i < collaborators.length - 1)
                          const Divider(
                              height: 1, color: Color(0xFFEEEEEE)),
                      ],
                    );
                  },
                  childCount: collaborators.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // ── Join Button ────────────────────────────────────────────────
            if (widget.owner?.idPengguna != widget.project.idPengguna)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (_detailModel?.data.status == 'accepted' || _detailModel?.data.status == 'pending') 
                          ? null 
                          : () {
                              // Tambahkan fungsi join di sini
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
                        _getJoinButtonText(_detailModel?.data.status),
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
                setState(() => _projectStatus = s);
                Navigator.pop(context);

                try {
                  final project = _detailModel?.data.project;
                  await _collaborationService.updateCollaboration(
                    id: widget.project.id.toString(),
                    title: project?.title ?? widget.project.title,
                    description: project?.description ?? widget.project.description,
                    category: project?.category ?? widget.project.category ?? '',
                    status: _mapToBackendStatus(s),
                    repositoryLink: project?.repositoryLink ?? widget.project.repositoryLink ?? '',
                  );
                  if (mounted) {
                    AuthUiHelper.showSuccess(context, 'Status diperbarui ke $s');
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

  Color _statusColor(String status) {
    switch (status) {
      case 'Sedang Berjalan':
        return Colors.green;
      case 'Selesai':
        return Colors.blue;
      case 'Ditunda':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getJoinButtonText(String? status) {
    if (status == 'accepted') return 'Sudah Bergabung';
    if (status == 'pending') return 'Menunggu Persetujuan';
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
}
