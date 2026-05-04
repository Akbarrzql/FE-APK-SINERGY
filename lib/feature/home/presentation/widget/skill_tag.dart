import 'package:flutter/material.dart';
import '../../../../core/common/color_value.dart';

class SkillTag extends StatelessWidget {
  final String label;

  const SkillTag({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ColorValue.tagBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: ColorValue.tagText,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}