import 'package:flutter/material.dart';
import 'color_value.dart';

class AppTypography {
  AppTypography._();

  static const TextStyle heading1 = TextStyle(
    color: ColorValue.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle heading2 = TextStyle(
    color: ColorValue.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle heading3 = TextStyle(
    color: ColorValue.textPrimary,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    color: ColorValue.textSecondary,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    color: ColorValue.textMuted,
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle label = TextStyle(
    color: ColorValue.textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle badge = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );
}
