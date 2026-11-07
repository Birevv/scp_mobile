import 'package:flutter/material.dart';

/// AppColors - Palet Warna SCP Mobile (SMK Negeri 1 Bantul)
/// Berdasarkan prinsip Unslopping:
/// - Chrome tenang dengan neutral ramp bersahaja.
/// - Akses primer Indigo (#1E3A8A) dan aksen sekunder Teal (#0D9488).
/// - Empat warna semantik presensi baku tanpa border neon atau glow berlebih.
class AppColors {
  // Brand Accents
  static const Color primaryIndigo = Color(0xFF1E3A8A);     // Primary Indigo (#1E3A8A)
  static const Color secondaryTeal = Color(0xFF0D9488);     // Secondary Teal (#0D9488)

  // Backward-compatible Aliases
  static const Color primaryNavy = Color(0xFF1E3A8A);
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color teamTeal = Color(0xFF0D9488);
  static const Color skyBlue = Color(0xFF0284C7);
  static const Color primaryPurple = Color(0xFF1E3A8A);
  static const Color lavenderLight = Color(0xFFF1F5F9);

  // Neutral Ramp (Slate / Tinted Neutral)
  static const Color background = Color(0xFFF8FAFC);        // Page background: #F8FAFC
  static const Color surface = Color(0xFFFFFFFF);           // Cards / Modals: #FFFFFF
  static const Color white = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);            // Hairline border: #E2E8F0
  static const Color borderSubtle = Color(0xFFF1F5F9);      // Muted inner divider
  static const Color borderFocus = Color(0xFF1E3A8A);       // Focused border

  // Text Roles (Three crisp levels)
  static const Color textPrimary = Color(0xFF0F172A);       // Slate 900
  static const Color textSecondary = Color(0xFF475569);     // Slate 600
  static const Color textTertiary = Color(0xFF94A3B8);      // Slate 400

  // Semantic Attendance Status Colors (Carry true meaning only)
  static const Color statusHadir = Color(0xFF10B981);       // Hadir: Emerald 500
  static const Color statusIzin = Color(0xFF0284C7);        // Izin: Sky 600
  static const Color statusSakit = Color(0xFFF59E0B);       // Sakit: Amber 500
  static const Color statusAlpa = Color(0xFFEF4444);        // Alpa: Rose 500

  // Semantic Aliases
  static const Color successHadir = statusHadir;
  static const Color infoIzin = statusIzin;
  static const Color warningSakit = statusSakit;
  static const Color errorAlpa = statusAlpa;

  // Calm Semantic Backgrounds (Restrained, low-saturation tints)
  static const Color statusPendingBg = Color(0xFFFEF9C3);   // Pale Amber
  static const Color statusApprovedBg = Color(0xFFECFDF5);  // Pale Emerald
  static const Color statusRejectedBg = Color(0xFFFEF2F2);  // Pale Rose

  static const Color statusPendingText = Color(0xFF854D0E); // Deep Amber
  static const Color statusApprovedText = Color(0xFF065F46);// Deep Emerald
  static const Color statusRejectedText = Color(0xFF991B1B);// Deep Rose

  static const Color alertAmberBg = Color(0xFFFEF9C3);
  static const Color alertAmberBorder = Color(0xFFFEF08A);
  static const Color alertRedBg = Color(0xFFFEF2F2);
  static const Color alertRedBorder = Color(0xFFFECACA);
  static const Color alertGreenBg = Color(0xFFECFDF5);
  static const Color alertBlueBg = Color(0xFFF0F9FF);

  static const Color tealLightBg = Color(0xFFF0FDFA);
  static const Color lightTealBg = Color(0xFFF0FDFA);
  static const Color lightTealBorder = Color(0xFFCCFBF1);
  static const Color lightBlueBg = Color(0xFFF8FAFC);
  static const Color lightBlueBorder = Color(0xFFE2E8F0);
  static const Color lightIndigoBg = Color(0xFFF1F5F9);
  static const Color lightIndigoBorder = Color(0xFFE2E8F0);

  // Header Background: Deep solid Indigo with subtle depth, no slop radial blobs
  static const List<Color> headerGradient = [
    Color(0xFF1E3A8A),
    Color(0xFF1E3A8A),
  ];

  static const List<Color> indigoTealGradient = [
    Color(0xFF1E3A8A),
    Color(0xFF1E3A8A),
  ];

  static const List<Color> primaryGradient = [
    Color(0xFF1E3A8A),
    Color(0xFF1E3A8A),
  ];

  static const List<Color> lightBlueGradient = [
    Color(0xFFF8FAFC),
    Color(0xFFF1F5F9),
  ];
}
