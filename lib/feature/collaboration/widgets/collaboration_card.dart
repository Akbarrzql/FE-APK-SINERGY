import 'package:flutter/material.dart';
import '../models/collaboration.dart';
import '../../../app_colors.dart';

class CollaborationCard extends StatelessWidget {
  final CollaborationModel collaboration;

  const CollaborationCard({
    super.key,
    required this.collaboration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Owner Row ──
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: collaboration.ownerColor,
                child: Text(
                  collaboration.ownerInitials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collaboration.ownerName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      collaboration.role,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: collaboration.status),
            ],
          ),

          const SizedBox(height: 12),

          // ── Project Name ──
          Text(
            collaboration.projectName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          // ── Category & Date ──
          Text(
            '${collaboration.category}  •  ${collaboration.date}',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 8),

          // ── Description ──
          Text(
            collaboration.description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // ── Tags + Member Avatars ──
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: collaboration.tags
                      .map((tag) => _TagChip(tag: tag))
                      .toList(),
                ),
              ),
              const SizedBox(width: 8),
              _MemberAvatars(
                members: collaboration.members,
                extraCount: collaboration.extraMembers,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Status Badge
// ─────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  Color get _color {
    switch (status.toLowerCase()) {
      case 'selesai':
        return AppColors.primary;
      case 'aktif':
        return const Color(0xFF3B82F6);
      case 'berlangsung':
        return const Color(0xFFF59E0B);
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Tag Chip
// ─────────────────────────────────────────
class _TagChip extends StatelessWidget {
  final String tag;

  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Member Avatars (overlapping)
// ─────────────────────────────────────────
class _MemberAvatars extends StatelessWidget {
  final List<MemberModel> members;
  final int extraCount;

  const _MemberAvatars({
    required this.members,
    required this.extraCount,
  });

  @override
  Widget build(BuildContext context) {
    const double size = 26;
    const double overlap = 10;

    final displayList = members.take(3).toList();
    final itemCount = displayList.length + (extraCount > 0 ? 1 : 0);
    final totalWidth = size + (itemCount - 1) * (size - overlap);

    return SizedBox(
      width: totalWidth,
      height: size,
      child: Stack(
        children: [
          // Member avatars
          ...List.generate(displayList.length, (i) {
            return Positioned(
              left: i * (size - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: displayList[i].color,
                  border: Border.all(color: AppColors.card, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    displayList[i].initials[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            );
          }),
          // +N badge
          if (extraCount > 0)
            Positioned(
              left: displayList.length * (size - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.chipBg,
                  border: Border.all(color: AppColors.card, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '+$extraCount',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
