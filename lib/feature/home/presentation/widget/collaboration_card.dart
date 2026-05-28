import 'package:flutter/material.dart';
import '../../../../core/common/color_value.dart';
import '../../../collaboration/presentation/collaboration_profile_screen.dart';
import 'member_avatar_stack.dart';
import 'skill_tag.dart';

class CollaborationCard extends StatelessWidget {
  final int id;
  final String ownerName;
  final String ownerRole;
  final String ownerImageUrl;
  final List<String> memberImages;
  final int extraMembers;
  final String projectTitle;
  final String projectType;
  final String projectDate;
  final DateTime? deadline;
  final String projectDescription;
  final List<String> skills;
  final VoidCallback? onTap;


  const CollaborationCard({
    super.key,
    required this.id,
    required this.ownerName,
    required this.ownerRole,
    required this.ownerImageUrl,
    required this.memberImages,
    required this.extraMembers,
    required this.projectTitle,
    required this.projectType,
    required this.projectDate,
    this.deadline,
    required this.projectDescription,
    required this.skills,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorValue.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Owner row
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(ownerImageUrl),
                  backgroundColor: Colors.grey[200],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ownerName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorValue.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ownerRole,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ColorValue.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                MemberAvatarsWidget(projectId: id)
              ],
            ),

            const SizedBox(height: 14),

            // Project title
            Text(
              projectTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ColorValue.textPrimary,
              ),
            ),
            const SizedBox(height: 4),

            // Project type & date
            Row(
              children: [
                Text(
                  projectType,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ColorValue.textSecondary,
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
                Text(
                  projectDate,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ColorValue.textSecondary,
                  ),
                ),
              ],
            ),


            const SizedBox(height: 10),

            // Description
            Text(
              projectDescription,
              style: const TextStyle(
                fontSize: 13,
                color: ColorValue.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 14),

            // Skill tags
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((s) => SkillTag(label: s)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}