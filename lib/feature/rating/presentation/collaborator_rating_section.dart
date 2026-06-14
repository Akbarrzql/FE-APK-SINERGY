import 'package:flutter/material.dart';
import 'package:gabungyuk/core/common/color_value.dart';
import 'package:gabungyuk/core/widget/profile_avatar.dart';
import 'package:gabungyuk/feature/rating/user_rating_in_project.dart';

class CollaboratorRatingCard extends StatelessWidget {
  final Datum rating;
  final bool isFirstItem;

  const CollaboratorRatingCard({
    super.key,
    required this.rating,
    this.isFirstItem = false,
  });

  @override
  Widget build(BuildContext context) {
    // Build a slightly elevated card with subtle rotation for visual interest
    return Transform.rotate(
      angle: isFirstItem ? -0.006 : 0.0,
      child: Container(
        margin: EdgeInsets.only(bottom: isFirstItem ? 14 : 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar, Name, Rating
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                ProfileAvatar(
                  size: 44,
                  imageUrl: rating.ratedUserProfilePicture?.toString(),
                  fullName: rating.ratedUserName,
                  fontSize: 16,
                ),
                const SizedBox(width: 12),

                // Name & Rating
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rating.ratedUserName ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorValue.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Rating stars
                      Row(
                        children: List.generate(5, (index) {
                          final isFilled = index < (rating.ratingValue ?? 0);
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.star,
                              size: 16,
                              color: isFilled ? Colors.amber : Colors.grey[300],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                // Rating value
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${rating.ratingValue}/5',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),

            // Review text
            if (rating.review != null && rating.review!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                rating.review!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],

            // Owner & Date
            if (rating.ownerName != null || rating.createdAt != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  if (rating.ownerName != null)
                    Expanded(
                      child: Text(
                        'dari ${rating.ownerName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  if (rating.createdAt != null)
                    Text(
                      _formatDate(rating.createdAt!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hari ini';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} minggu lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class CollaboratorRatingSection extends StatelessWidget {
  final List<Datum> ratings;
  final bool isLoading;
  final bool hasError;

  const CollaboratorRatingSection({
    super.key,
    required this.ratings,
    this.isLoading = false,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Rating Collaborator',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ColorValue.textPrimary,
                  ),
                ),
                if (ratings.isNotEmpty)
                  Text(
                    '${ratings.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ColorValue.primaryColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(
                    color: ColorValue.primaryColor,
                  ),
                ),
              ),
            )
          else if (hasError)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Gagal memuat rating',
                style: TextStyle(color: Colors.grey[500]),
              ),
            )
          else if (ratings.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Tidak ada rating untuk project ini',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: ratings
                    .asMap()
                    .entries
                    .map((entry) => Transform.rotate(
                          angle: entry.key.isEven ? -0.006 : 0.006,
                          child: Container(
                            margin: EdgeInsets.only(bottom: entry.key == 0 ? 12 : 8),
                            child: CollaboratorRatingCard(
                              rating: entry.value,
                              isFirstItem: entry.key == 0,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

