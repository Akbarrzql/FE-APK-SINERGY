import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gabungyuk/core/common/color_value.dart';
import 'package:gabungyuk/core/common/auth_ui_helper.dart';
import 'package:gabungyuk/core/widget/profile_avatar.dart';
import 'package:gabungyuk/feature/rating/bloc/rating_bloc.dart';
import 'package:gabungyuk/feature/rating/bloc/rating_event.dart';

class CollaboratorInfo {
  final int userId;
  final String userName;
  final String? profilePicture;
  final String role;

  CollaboratorInfo({
    required this.userId,
    required this.userName,
    this.profilePicture,
    required this.role,
  });
}

class RatingCollaboratorsDialog extends StatefulWidget {
  final int projectId;
  final List<CollaboratorInfo> collaborators;
  final VoidCallback onComplete;

  const RatingCollaboratorsDialog({
    super.key,
    required this.projectId,
    required this.collaborators,
    required this.onComplete,
  });

  @override
  State<RatingCollaboratorsDialog> createState() =>
      _RatingCollaboratorsDialogState();
}

class _RatingCollaboratorsDialogState
    extends State<RatingCollaboratorsDialog> {
  late PageController _pageController;
  int _currentIndex = 0;
  late List<CollaboratorRating> _ratings;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _ratings = widget.collaborators
        .map((c) => CollaboratorRating(userId: c.userId))
        .toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _submitRatings() {
    // Validate all ratings are filled
    final incompleteRatings = _ratings.where((r) => r.rating == 0).toList();
    if (incompleteRatings.isNotEmpty) {
      AuthUiHelper.showError(context, 'Masukkan rating untuk semua collaborator');
      return;
    }

    // Submit all ratings
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: ColorValue.primaryColor),
      ),
    );

    // Emit events untuk submit semua rating
    for (final ratingData in _ratings) {
      context.read<RatingBloc>().add(
            SubmitRatingEvent(
              projectId: widget.projectId,
              ratedUserId: ratingData.userId,
              ratingValue: ratingData.rating,
              review: ratingData.review,
            ),
          );
    }

    // Close loading dan dialog after all submitted
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pop(context); // close loading
        Navigator.pop(context); // close dialog
        widget.onComplete();
        AuthUiHelper.showSuccess(
            context, 'Semua rating berhasil disimpan');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Beri Rating Collaborator',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ColorValue.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Berikan rating untuk ${widget.collaborators.length} collaborator',
                  style: const TextStyle(
                    fontSize: 12,
                    color: ColorValue.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          // PageView untuk collaborators
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemCount: widget.collaborators.length,
              itemBuilder: (context, index) {
                final collaborator = widget.collaborators[index];
                final rating = _ratings[index];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Collaborator info
                      Center(
                        child: Column(
                          children: [
                            ProfileAvatar(
                              size: 80,
                              imageUrl: collaborator.profilePicture,
                              fullName: collaborator.userName,
                              fontSize: 24,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              collaborator.userName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: ColorValue.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              collaborator.role,
                              style: const TextStyle(
                                fontSize: 12,
                                color: ColorValue.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Star rating
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              'Berikan Rating',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ColorValue.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (i) {
                                final isFilled = i < rating.rating;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() => rating.rating = i + 1);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Icon(
                                      Icons.star,
                                      size: 32,
                                      color: isFilled
                                          ? Colors.amber
                                          : Colors.grey[300],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Review text
                      Text(
                        'Review (Opsional)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorValue.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: TextEditingController(text: rating.review),
                        onChanged: (value) => rating.review = value,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Tuliskan review...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: ColorValue.primaryColor,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),

          // Progress indicator & buttons
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Progress dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.collaborators.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _currentIndex
                              ? ColorValue.primaryColor
                              : Colors.grey[300],
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 16),

                // Buttons
                Row(
                  children: [
                    if (_currentIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(
                              color: ColorValue.primaryColor,
                            ),
                          ),
                          child: const Text(
                            'Sebelumnya',
                            style: TextStyle(
                              color: ColorValue.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    if (_currentIndex > 0) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentIndex == widget.collaborators.length - 1) {
                            _submitRatings();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorValue.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          _currentIndex == widget.collaborators.length - 1
                              ? 'Simpan Semua Rating'
                              : 'Selanjutnya',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CollaboratorRating {
  final int userId;
  int rating = 0;
  String review = '';

  CollaboratorRating({required this.userId});
}



