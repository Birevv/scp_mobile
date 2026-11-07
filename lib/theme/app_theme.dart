import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_shadows.dart';

class AppTheme {
  static ThemeData get themeData => lightTheme;

  // Convenient color aliases for widgets using AppTheme.xxx
  static const Color primaryBlue = AppColors.primaryIndigo;     // Primary Indigo #1E3A8A
  static const Color primaryBlueDark = AppColors.primaryNavy;   // Deep Navy #172554
  static const Color primaryIndigo = AppColors.primaryIndigo;   // #1E3A8A
  static const Color secondaryTeal = AppColors.secondaryTeal;   // #0D9488
  static const Color primaryPurple = AppColors.accentBlue;      // #2563EB
  static const Color lavenderLight = AppColors.lightBlueBorder; // #DBEAFE
  static const Color secondaryBlue = AppColors.lightBlueBorder;
  static const Color background = AppColors.background;         // #F8FAFC
  static const Color paleBg = AppColors.background;
  static const Color surfaceWhite = AppColors.white;            // #FFFFFF
  static const Color tintBackground = AppColors.lightBlueBg;    // #EFF6FF

  // Status & Logic Colors
  static const Color success = AppColors.successHadir;          // #10B981
  static const Color successBg = AppColors.statusApprovedBg;    // #D1FAE5
  static const Color danger = AppColors.errorAlpa;              // #EF4444
  static const Color dangerBg = AppColors.statusRejectedBg;     // #FEE2E2
  static const Color warning = AppColors.warningSakit;          // #F59E0B
  static const Color warningBg = AppColors.statusPendingBg;     // #FEF3C7
  static const Color info = AppColors.infoIzin;                 // #0284C7
  static const Color infoBg = AppColors.alertBlueBg;            // #E0F2FE
  static const Color purple = AppColors.accentBlue;
  static const Color purpleBg = AppColors.lightBlueBg;

  // Neutral Colors
  static const Color textDark = AppColors.textPrimary;          // #1E293B
  static const Color textBody = Color(0xFF334155);              // Slate 700
  static const Color textMuted = AppColors.textSecondary;       // #64748B
  static const Color textLight = AppColors.textTertiary;        // #94A3B8
  static const Color borderLight = AppColors.border;            // #E2E8F0
  static const Color divider = Color(0xFFF1F5F9);

  // Radius aliases (16-24px cards per PRD Section 6)
  static const double radiusSmall = 10.0;
  static const double radiusMedium = 14.0;
  static const double radiusLarge = 20.0;
  static const double radiusXLarge = 24.0;
  static const double radiusFull = 999.0;

  // Box shadows
  static List<BoxShadow> get softShadow => AppShadows.cardShadows;
  static List<BoxShadow> get mediumShadow => AppShadows.elevatedShadows;
  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: AppColors.primaryIndigo.withValues(alpha: 0.18),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  // Card Decoration Helper
  static BoxDecoration cardDecoration({
    Color color = AppColors.white,
    double radius = 20.0,
    Border? border,
    List<BoxShadow>? shadow,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: border ?? Border.all(color: AppColors.border, width: 1),
      boxShadow: shadow ?? AppShadows.cardShadows,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryIndigo,
        secondary: AppColors.secondaryTeal,
        tertiary: AppColors.skyBlue,
        surface: AppColors.white,
        error: AppColors.errorAlpa,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textPrimary,
        onError: AppColors.white,
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleLarge: AppTypography.pageTitle.copyWith(color: AppColors.textPrimary),
        titleMedium: AppTypography.sectionTitle.copyWith(color: AppColors.textPrimary),
        titleSmall: AppTypography.cardTitle.copyWith(color: AppColors.textPrimary),
        bodyLarge: AppTypography.bodyText.copyWith(color: AppColors.textPrimary),
        bodyMedium: AppTypography.bodyText.copyWith(color: AppColors.textSecondary),
        bodySmall: AppTypography.smallHint.copyWith(color: AppColors.textTertiary),
        labelLarge: AppTypography.labelButton.copyWith(color: AppColors.white),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.pageTitle.copyWith(
          color: AppColors.textPrimary,
          fontSize: 18,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryIndigo, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.errorAlpa),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.errorAlpa, width: 2),
        ),
        hintStyle: AppTypography.smallHint.copyWith(
          color: AppColors.textTertiary,
        ),
        labelStyle: AppTypography.smallHint.copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryIndigo,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          textStyle: AppTypography.labelButton.copyWith(color: AppColors.white),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryIndigo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: const BorderSide(color: AppColors.border, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          textStyle: AppTypography.labelButton,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryIndigo,
          textStyle: AppTypography.labelButton,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryIndigo,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        enableFeedback: true,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightBlueBg,
        selectedColor: AppColors.primaryIndigo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        labelStyle: AppTypography.smallHint.copyWith(
          color: AppColors.textPrimary,
        ),
      ),

      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: AppColors.white,
        titleTextStyle: AppTypography.sectionTitle.copyWith(
          color: AppColors.textPrimary,
        ),
        contentTextStyle: AppTypography.bodyText.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
