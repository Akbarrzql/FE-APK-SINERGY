import 'package:flutter/material.dart';
import 'package:gabungyuk/core/common/color_value.dart';
import 'package:gabungyuk/feature/home/presentation/widget/skill_tag.dart';

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
            backgroundImage: NetworkImage(imageUrl),
            backgroundColor: Colors.grey[200],
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
  const DetailCollaboration({super.key});

  @override
  State<DetailCollaboration> createState() => _DetailCollaborationState();
}

class _DetailCollaborationState extends State<DetailCollaboration> {
  bool _isExpanded = false;

  final String _fullDescription =
      'Moneyger adalah sebuah platform aplikasi untuk mengelola keuangan dengan mudah. Aplikasi ini juga menawarkan berbagai fitur yang dapat membantu masyarakat mempermudah produktivitas mereka.';

  final List<Map<String, dynamic>> _members = [
    {
      'name': 'Alexander Arnold',
      'role': 'Pemilik Kolaborasi',
      'imageUrl': 'https://i.pravatar.cc/150?img=51',
      'rating': 120,
    },
    {
      'name': 'Sam Smith',
      'role': 'Back End',
      'imageUrl': 'https://i.pravatar.cc/150?img=12',
      'rating': 60,
    },
    {
      'name': 'James Arthur',
      'role': 'Back End',
      'imageUrl': 'https://i.pravatar.cc/150?img=33',
      'rating': 85,
    },
    {
      'name': 'David Silva',
      'role': 'Front End',
      'imageUrl': 'https://i.pravatar.cc/150?img=68',
      'rating': 55,
    },
    {
      'name': 'Luna Park',
      'role': 'UI/UX Designer',
      'imageUrl': 'https://i.pravatar.cc/150?img=47',
      'rating': 90,
    },
  ];

  String _projectStatus = 'Belum Dimulai';

  final List<String> _statusOptions = [
    'Belum Dimulai',
    'Sedang Berjalan',
    'Selesai',
    'Ditunda',
  ];

  @override
  Widget build(BuildContext context) {
    final shortDesc = _fullDescription.length > 100
        ? '${_fullDescription.substring(0, 100)}...'
        : _fullDescription;

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
                    GestureDetector(
                      child: Text(
                        'Edit',
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
                                title: 'Moneyger Application Project',
                                description:
                                    'Moneyger adalah sebuah platform aplikasi untuk mengelola keuangan dengan mudah. Aplikasi ini juga menawarkan berbagai fitur yang dapat membantu masyarakat mempermudah produktivitas mereka.',
                                category: 'Portofolio project',
                                status: 'Sedang Berjalan',
                                repositoryLink:
                                    'https://github.com/example/moneyger',
                                url: 'https://moneyger.app',
                                imageUrl: 'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=800&q=80'
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── Cover Image ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=800&q=80',
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 220,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: ColorValue.primaryColor,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.grey, size: 48),
                    ),
                  ),
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
                    const Text(
                      'Moneyger Application Project',
                      style: TextStyle(
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
                        const Text(
                          'Portofolio project',
                          style: TextStyle(
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
                          color: _statusColor(_projectStatus).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: _statusColor(_projectStatus).withOpacity(0.2),
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
                            text: _isExpanded ? _fullDescription : shortDesc,
                          ),
                          if (!_isExpanded)
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
                      children: const [
                        SkillTag(label: 'Front End'),
                        SkillTag(label: 'Back End'),
                        SkillTag(label: 'UI/UX'),
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
                            '${_members.length}',
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
                    final m = _members[i];
                    return Column(
                      children: [
                        MemberTile(
                          name: m['name'],
                          role: m['role'],
                          imageUrl: m['imageUrl'],
                          rating: m['rating'],
                        ),
                        if (i < _members.length - 1)
                          const Divider(
                              height: 1, color: Color(0xFFEEEEEE)),
                      ],
                    );
                  },
                  childCount: _members.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // ── Join Button ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorValue.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Bergabung',
                      style: TextStyle(
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pilih Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ColorValue.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ..._statusOptions.map((s) {
                  final isActive = s == _projectStatus;
                  return ListTile(
                    onTap: () {
                      setState(() => _projectStatus = s);
                      Navigator.pop(context);
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
                        color: isActive
                            ? ColorValue.primaryColor
                            : ColorValue.textPrimary,
                      ),
                    ),
                    trailing: isActive
                        ? const Icon(Icons.check,
                        color: ColorValue.primaryColor, size: 18)
                        : null,
                  );
                }),
              ],
            ),
          ),
        );
      },
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
}