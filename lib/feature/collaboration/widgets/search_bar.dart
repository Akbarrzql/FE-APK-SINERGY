import 'package:flutter/material.dart';
import '../../../app_colors.dart';

class CollaborationSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const CollaborationSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.searchBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          hintText: 'Cari Kolaborasi',
          hintStyle: TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textMuted,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
