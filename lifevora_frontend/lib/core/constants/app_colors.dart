// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF3730A3);

  // Secondary
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFF6EE7B7);

  // Accent
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentBlue = Color(0xFF3B82F6);

  // Background
  static const Color background = Color(0xFFF8F9FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3FF);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Semi-transparent (replaces withOpacity)
  static const Color primaryAlpha10 = Color(0x1A4F46E5);
  static const Color primaryAlpha15 = Color(0x264F46E5);
  static const Color primaryAlpha20 = Color(0x334F46E5);
  static const Color primaryAlpha30 = Color(0x4D4F46E5);
  static const Color secondaryAlpha10 = Color(0x1A10B981);
  static const Color accentAlpha10 = Color(0x1AF59E0B);
  static const Color accentPurpleAlpha10 = Color(0x1A8B5CF6);
  static const Color whiteAlpha15 = Color(0x26FFFFFF);
  static const Color whiteAlpha20 = Color(0x33FFFFFF);
  static const Color blackAlpha05 = Color(0x0D000000);
  static const Color blackAlpha06 = Color(0x0F000000);
  static const Color blackAlpha08 = Color(0x14000000);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Activity Colors
  static const Map<String, Color> activityColors = {
    'Course': Color(0xFFF59E0B),
    'Marche': Color(0xFF10B981),
    'Vélo': Color(0xFF3B82F6),
    'Yoga': Color(0xFF8B5CF6),
    'Natation': Color(0xFF06B6D4),
    'Musculation': Color(0xFFEF4444),
  };
}