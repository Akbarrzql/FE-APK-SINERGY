import 'package:flutter/material.dart';
import '../../../app_colors.dart';

class CollaborationFilterTabs extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  final List<String> tabs;

  const CollaborationFilterTabs({
    super.key,
    required this.selected,
    required this.onChanged,
    this.tabs = const ['Semua', 'Anda'],
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: tabs.map((tab) {
        final isSelected = tab == selected;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onChanged(tab),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.chipBg : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? AppColors.border
                      : AppColors.border.withOpacity(0.4),
                ),
              ),
              child: Text(
                tab,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
