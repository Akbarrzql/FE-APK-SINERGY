
import 'package:flutter/material.dart';
import 'package:gabungyuk/core/common/typography.dart';
import 'color_value.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;
  int selectedRadio = 0;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme(int number) {
    selectedRadio = number;
    themeMode = number == 0 ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

class AppThemeData {
  static ThemeData getThemeLight() {
    const Color primaryColor = ColorValue.primaryColor;
    final Map<int, Color> primaryColorMap = {
      50: primaryColor,
      100: primaryColor,
      200: primaryColor,
      300: primaryColor,
      400: primaryColor,
      500: primaryColor,
      600: primaryColor,
      700: primaryColor,
      800: primaryColor,
      900: primaryColor,
    };
    final MaterialColor primaryMaterialColor =
    MaterialColor(primaryColor.value, primaryColorMap);

    return ThemeData(
      primaryColor: primaryColor,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        elevation: 0,
        titleTextStyle: typography.SemiBold.copyWith(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: ColorValue.secondaryColor,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: typography.Medium.copyWith(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: typography.Bold.copyWith(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        displayMedium: typography.Regular.copyWith(
          color: Colors.black,
          fontSize: 20,
        ),
        displaySmall:  typography.Regular.copyWith(
          color: Colors.black,
          fontSize: 16,
        ),
        headlineMedium:  typography.Regular.copyWith(
          color: Colors.black,
          fontSize: 14,
        ),
        titleLarge:  typography.Regular.copyWith(
          color: Colors.black,
          fontSize: 16,
        ),
        bodyLarge:  typography.Regular.copyWith(
          color: ColorValue.greyColor,
          fontSize: 12,
        ),
        bodyMedium:  typography.Regular.copyWith  (
          color: ColorValue.greyColor,
          fontSize: 10,
        ),
      ), colorScheme: ColorScheme.fromSwatch(primarySwatch: primaryMaterialColor).copyWith(surface: Colors.white),
    );
  }
}