import 'package:flutter/material.dart';
import 'package:gabungyuk/core/common/color_value.dart';
import 'package:gabungyuk/feature/rating/model/user_rating_by_project_model.dart';

class UserReviewSection extends StatelessWidget {
  final List<Datum> reviews;
  final double? averageRating;
  final int? totalReviews;
  final bool isLoading;
  final bool hasError;
  final VoidCallback? onViewAll;

  const UserReviewSection({
    super.key,
    required this.reviews,
    this.averageRating,
    this.totalReviews,
    this.isLoading = false,
    this.hasError = false,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final total = totalReviews ?? reviews.length;

    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFE6A700),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Rating & Review',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: ColorValue.textPrimary,
                    ),
                  ),
                ),
                _CountBadge(count: total),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Rating summary ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: _SummaryRow(
              averageRating: averageRating,
              totalReviews: totalReviews,
            ),
          ),

          const SizedBox(height: 14),

          // ── Review list / states ─────────────────────────────────────────
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            )
          else if (hasError)
            _EmptyState(
              icon: Icons.wifi_off_rounded,
              title: 'Gagal memuat review',
              subtitle: 'Periksa koneksi dan coba lagi.',
              iconColor: Colors.red.shade300,
            )
          else if (reviews.isEmpty)
              _EmptyState(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Belum ada review',
                subtitle: 'Review akan muncul setelah ada penilaian.',
                iconColor: Colors.grey.shade400,
              )
            else
              Column(
                children: [
                  SizedBox(
                    height: 140,
                    child: PageView.builder(
                      itemCount: reviews.length > 3 ? 3 : reviews.length,
                      controller: PageController(viewportFraction: 0.9),
                      itemBuilder: (context, i) {
                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: ReviewTile(
                            review: reviews[i],
                            maxLines: 2,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (reviews.length > 3)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: onViewAll,
                          style: TextButton.styleFrom(
                            foregroundColor: ColorValue.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: ColorValue.primaryColor
                                      .withOpacity(0.2)),
                            ),
                          ),
                          child: const Text(
                            'Lihat Semua Ulasan',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

          if (isLoading || hasError || reviews.isEmpty)
            const SizedBox(height: 18),
        ],
      ),
    );
  }
}

// ── Count badge ──────────────────────────────────────────────────────────────
class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: ColorValue.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count ulasan',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: ColorValue.primaryColor,
        ),
      ),
    );
  }
}

// ── Compact summary row ──────────────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final double? averageRating;
  final int? totalReviews;

  const _SummaryRow({this.averageRating, this.totalReviews});

  @override
  Widget build(BuildContext context) {
    final avg = averageRating ?? 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE6A7)),
      ),
      child: Row(
        children: [
          // Numeric score
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                averageRating != null ? avg.toStringAsFixed(1) : '-',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'dari 5',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 40, color: const Color(0xFFFFE6A7)),
          const SizedBox(width: 16),
          // Stars + description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(
                    5,
                        (i) => Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Icon(
                        i < avg.floor()
                            ? Icons.star_rounded
                            : (avg > i
                            ? Icons.star_half_rounded
                            : Icons.star_border_rounded),
                        color: Colors.amber,
                        size: 17,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  averageRating != null
                      ? '${avg.toStringAsFixed(1)} • ${totalReviews ?? 0} ulasan'
                      : 'Belum ada rating',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Dinilai oleh project owner',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single review tile ───────────────────────────────────────────────────────
class ReviewTile extends StatelessWidget {
  final Datum review;
  final int? maxLines;

  const ReviewTile({
    super.key,
    required this.review,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final rating = review.ratingValue ?? 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: _imageProvider(review.ownerProfilePicture),
          child: _imageProvider(review.ownerProfilePicture) == null
              ? const Icon(Icons.person_rounded, size: 18, color: Colors.grey)
              : null,
        ),
        const SizedBox(width: 12),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      review.ownerName ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  // Star score
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Colors.amber, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        '$rating',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                review.projectTitle?.isNotEmpty == true
                    ? review.projectTitle!
                    : 'Project',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              if ((review.review ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  review.review!,
                  maxLines: maxLines,
                  overflow: maxLines != null ? TextOverflow.ellipsis : null,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                _formatDate(review.createdAt),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
      ],
    );
  }

  ImageProvider? _imageProvider(dynamic value) {
    final url = value?.toString().trim();
    if (url == null || url.isEmpty || !url.startsWith('http')) return null;
    return NetworkImage(url);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Hari ini';
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }
}

// ── Empty / error state ──────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 28, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ColorValue.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}