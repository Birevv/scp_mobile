import 'package:flutter/material.dart';

/// AppColors - Palet Warna Resmi SCP Mobile (SMK Negeri 1 Bantul)
/// Berdasarkan Design System Board Resmi:
/// 1. Primary: #2563EB (Vibrant Royal Blue) - Tombol utama, FAB, aksi aktif, progress
/// 2. Navy: #1E3A8A (Deep Institutional Navy) - Header, judul institusional, branding
/// 3. Accent: #DBEAFE (Soft Pastel Blue Tint) - Chip aktif, background container, hover/tint
/// 4. Success: #22C55E (Emerald Green) - Hadir, Disetujui (Approved), Sukses
/// 5. Warning: #F59E0B (Amber) - Sakit, Izin, Pending, Peringatan batas waktu
/// 6. Error: #EF4444 (Rose Red) - Alpa, Ditolak (Rejected), Bentrok Jadwal, Alert
class AppColors {
  // === 6 PALET WARNA RESMI (OFFICIAL DESIGN SYSTEM) ===
  static const Color brandPrimary = Color(0xFF2563EB); // #2563EB
  static const Color brandNavy = Color(0xFF1E3A8A);    // #1E3A8A
  static const Color brandAccent = Color(0xFFDBEAFE);  // #DBEAFE
  static const Color statusSuccess = Color(0xFF22C55E);// #22C55E
  static const Color statusWarning = Color(0xFFF59E0B);// #F59E0B
  static const Color statusError = Color(0xFFEF4444);  // #EF4444

  // Primary & Secondary Brand Tokens
  static const Color primaryIndigo = Color(0xFF1E3A8A); // #1E3A8A
  static const Color primaryNavy = Color(0xFF1E3A8A);   // #1E3A8A
  static const Color primaryBlue = Color(0xFF2563EB);   // #2563EB
  static const Color accentBlue = Color(0xFF2563EB);    // #2563EB
  static const Color accentTint = Color(0xFFDBEAFE);    // #DBEAFE
  static const Color softBlue = Color(0xFFDBEAFE);      // #DBEAFE
  static const Color secondaryTeal = Color(0xFF0D9488); // #0D9488
  static const Color teamTeal = Color(0xFF0D9488);
  static const Color skyBlue = Color(0xFF0284C7);
  static const Color primaryPurple = Color(0xFF1E3A8A);
  static const Color lavenderLight = Color(0xFFF1F5F9);

  // Neutral Ramp (Clean White & Slate)
  static const Color background = Color(0xFFF8FAFC);        // Page background: #F8FAFC
  static const Color surface = Color(0xFFFFFFFF);           // Cards / Modals: #FFFFFF
  static const Color white = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);            // Hairline border: #E2E8F0
  static const Color borderSubtle = Color(0xFFF1F5F9);      // Muted inner divider
  static const Color borderFocus = Color(0xFF2563EB);       // Focused border: #2563EB

  // Text Roles (Three crisp levels)
  static const Color textPrimary = Color(0xFF0F172A);       // Slate 900
  static const Color textSecondary = Color(0xFF475569);     // Slate 600
  static const Color textTertiary = Color(0xFF94A3B8);      // Slate 400

  // Semantic Attendance Status Colors (Carry true meaning only)
  static const Color statusHadir = Color(0xFF22C55E);       // Hadir: #22C55E
  static const Color statusIzin = Color(0xFF0284C7);        // Izin: #0284C7
  static const Color statusSakit = Color(0xFFF59E0B);       // Sakit: #F59E0B
  static const Color statusAlpa = Color(0xFFEF4444);        // Alpa: #EF4444

  // Semantic Aliases
  static const Color successHadir = statusHadir;
  static const Color infoIzin = statusIzin;
  static const Color warningSakit = statusSakit;
  static const Color errorAlpa = statusAlpa;

  // Calm Semantic Backgrounds (Restrained, low-saturation tints)
  static const Color statusPendingBg = Color(0xFFFEF9C3);   // Pale Amber
  static const Color statusApprovedBg = Color(0xFFDCFCE7);  // Pale Emerald #DCFCE7
  static const Color statusRejectedBg = Color(0xFFFEE2E2);  // Pale Rose #FEE2E2

  static const Color statusPendingText = Color(0xFF854D0E); // Deep Amber
  static const Color statusApprovedText = Color(0xFF166534);// Deep Emerald
  static const Color statusRejectedText = Color(0xFF991B1B);// Deep Rose

  static const Color alertAmberBg = Color(0xFFFEF9C3);
  static const Color alertAmberBorder = Color(0xFFFEF08A);
  static const Color alertRedBg = Color(0xFFFEE2E2);
  static const Color alertRedBorder = Color(0xFFFECACA);
  static const Color alertGreenBg = Color(0xFFDCFCE7);
  static const Color alertBlueBg = Color(0xFFEFF6FF);

  static const Color tealLightBg = Color(0xFFF0FDFA);
  static const Color lightTealBg = Color(0xFFF0FDFA);
  static const Color lightTealBorder = Color(0xFFCCFBF1);
  static const Color lightBlueBg = Color(0xFFEFF6FF);
  static const Color lightBlueBorder = Color(0xFFDBEAFE);
  static const Color lightIndigoBg = Color(0xFFDBEAFE);
  static const Color lightIndigoBorder = Color(0xFFBFDBFE);

  // Standardized Page Header (#203F91 per UX Specification)
  static const Color pageHeaderBackground = Color(0xFF203F91);
  static const Color pageHeaderBadge = Color(0xFF079F92);

  // Header Background: Deep solid Navy with subtle depth, no slop radial blobs
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
    Color(0xFF2563EB),
  ];

  static const List<Color> lightBlueGradient = [
    Color(0xFFF8FAFC),
    Color(0xFFEFF6FF),
  ];
}
