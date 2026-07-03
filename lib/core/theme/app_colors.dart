import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color bgPrimary = Color(0xFF000000);
  static const Color bgSecondary = Color(0xFF0A0A0F);
  static const Color surfaceCard = Color(0xFF1A1A1E);
  static const Color surfaceCardHover = Color(0xFF232328);

  // Borders
  static const Color borderSubtle = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const Color borderActive = Color(0xFF4A7DFF);

  // Accent
  static const Color accentPrimary = Color(0xFF4A7DFF);
  static const Color accentPrimaryDark = Color(0xFF2D5BD9);

  // Status
  static const Color statusConnected = Color(0xFF22C55E);
  static const Color statusConnecting = Color(0xFFF59E0B);
  static const Color statusDisconnected = Color(0xFF6B7280);
  static const Color statusError = Color(0xFFEF4444);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color textSuccess = Color(0xFF22C55E);

  // Gradient colors
  static const Color gradientUpgradeStart = Color(0xFFA855F7);
  static const Color gradientUpgradeMid = Color(0xFF4A7DFF);
  static const Color gradientUpgradeEnd = Color(0xFFFF8A4C);

  static const Color gradientVipGold = Color(0xFFFFD700);
  static const Color gradientVipPurple = Color(0xFFA855F7);

  // Glass
  static Color get surfaceGlass =>
      const Color(0xFF1A1A1E).withValues(alpha: 0.6);

  // Gradients
  static const LinearGradient gradientUpgrade = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFA855F7),
      Color(0xFF4A7DFF),
      Color(0xFFFF8A4C),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient gradientVipBorder = LinearGradient(
    colors: [
      Color(0xFFFFD700),
      Color(0xFFA855F7),
      Color(0xFFFFD700),
    ],
  );

  static const LinearGradient gradientConnected = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF22C55E), Color(0xFF4A7DFF)],
  );

  // Shadows & Glows
  static List<BoxShadow> get shadowCard => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get glowConnected => [
        BoxShadow(
          color: const Color(0xFF22C55E).withValues(alpha: 0.5),
          blurRadius: 40,
        ),
        BoxShadow(
          color: const Color(0xFF22C55E).withValues(alpha: 0.2),
          blurRadius: 80,
        ),
      ];

  static List<BoxShadow> get glowConnecting => [
        BoxShadow(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
          blurRadius: 30,
        ),
      ];

  static List<BoxShadow> get glowAccent => [
        BoxShadow(
          color: const Color(0xFF4A7DFF).withValues(alpha: 0.4),
          blurRadius: 24,
        ),
      ];
}
