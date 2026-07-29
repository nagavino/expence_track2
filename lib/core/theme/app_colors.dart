import 'package:flutter/material.dart';

/// App color palette for consistent theming throughout the app
class AppColors {
  AppColors._();

  // Primary gradient colors
  static const Color primaryStart = Color(0xFF6366F1); // Indigo
  static const Color primaryEnd = Color(0xFF8B5CF6);   // Purple

  // Background colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color cardBackground = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Text colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textOnPrimary = Colors.white;

  // Category colors - vibrant and distinct
  static const Color foodColor = Color(0xFFEF4444);      // Red
  static const Color travelColor = Color(0xFF3B82F6);    // Blue
  static const Color shoppingColor = Color(0xFFF59E0B);  // Amber
  static const Color billsColor = Color(0xFF10B981);     // Emerald
  static const Color otherColor = Color(0xFF8B5CF6);     // Purple

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  /// Gradient used for app bar and primary surfaces
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryStart, primaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
