import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    scaffoldBackgroundColor: AppColors.background,

    primaryColor: AppColors.gold,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),

    cardColor: AppColors.cardBlack,

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),

      bodyLarge: TextStyle(color: Colors.white70),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,

        foregroundColor: Colors.black,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

        elevation: 10,

        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
    ),
  );
}
