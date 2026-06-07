import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF080808);
  static const Color surface = Color(0xFF121212);
  static const Color surfaceVariant = Color(0xFF1A1A1A);
  static const Color cardBlack = Color(0xFF121212);
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldClick = Color(0xFFFFC107);
  static const Color amber = Color(0xFFFFB300);
  static const Color softGold = Color(0xFFF3E5AB);
  static const Color darkGold = Color(0xFF8C6D23);
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textMuted = Color(0xFF616161);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Colors.grey;
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF1565C0);
  static const LinearGradient goldGradient = LinearGradient(
    colors: [
      Color(0xFFBF953F),
      Color(0xFFFCF6BA),
      Color(0xFFB38728),
      Color(0xFFFBF5B7),
      Color(0xFFAA771C),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
