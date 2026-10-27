import 'package:flutter/material.dart';

/// App color tokens for SocialFlow AI
/// Featuring restrained blue and purple accents with pristine light and dark neutrals.
class AppColors {
  AppColors._();

  // Primary Brand Accents
  static const Color primaryBlue = Color(0xFF2563EB); // Royal / Electric Blue
  static const Color primaryBlueDark = Color(0xFF3B82F6);
  static const Color accentPurple = Color(0xFF7C3AED); // Modern Violet
  static const Color accentPurpleLight = Color(0xFF8B5CF6);

  // Gradient definitions
  static const LinearGradient brandGradient = LinearGradient(
    colors: [primaryBlue, accentPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleLightGradient = LinearGradient(
    colors: [Color(0xFFEFF6FF), Color(0xFFFAF5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleDarkGradient = LinearGradient(
    colors: [Color(0xFF1E2433), Color(0xFF1E1E2E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Status & Semantic Colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Rose/Red
  static const Color info = Color(0xFF0EA5E9); // Sky

  // Light Palette
  static const Color lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSecondary = Color(0xFFF1F5F9); // Slate 100
  static const Color lightBorder = Color(0xFFE2E8F0); // Slate 200
  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate 900
  static const Color lightTextSecondary = Color(0xFF64748B); // Slate 500
  static const Color lightTextMuted = Color(0xFF94A3B8); // Slate 400

  // Dark Palette
  static const Color darkBackground = Color(0xFF0B0F19); // Deep Slate
  static const Color darkSurface = Color(0xFF111827); // Dark Card / Surface
  static const Color darkSurfaceSecondary = Color(0xFF1F2937); // Elevated surface
  static const Color darkBorder = Color(0xFF2E384D); // Subtle Dark border
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Crisp light text
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color darkTextMuted = Color(0xFF64748B); // Slate 500
}
