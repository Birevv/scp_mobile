# Flutter Design Tokens & Theme Configuration

## Color Tokens (lib/constants/app_colors.dart) - Tema Biru Pendidikan (Kemendikbud)

```dart
class AppColors {
  // Primary Education Blue Palette (Biru Pendidikan & Akademik)
  static const Color primaryBlue = Color(0xFF1E40AF);       // Royal Education Blue (Warna Utama)
  static const Color primaryNavy = Color(0xFF0F2C59);       // Deep Academic Navy
  static const Color accentBlue = Color(0xFF2563EB);        // Vibrant Blue
  static const Color skyBlue = Color(0xFF0284C7);           // Bright Sky Blue
  static const Color lightBlueBg = Color(0xFFEFF6FF);       // Soft Blue 50 Tint
  static const Color lightBlueBorder = Color(0xFFDBEAFE);   // Soft Blue 100 Border

  // Backward-compatible Aliases
  static const Color primaryIndigo = Color(0xFF1E40AF);     // Mapped to Education Royal Blue
  static const Color primaryPurple = Color(0xFF2563EB);     // Replaced purple with Accent Blue
  static const Color lavenderLight = Color(0xFFDBEAFE);     // Replaced lavender with Light Sky Tint

  // Semantic Status Colors
  static const Color successHadir = Color(0xFF10B981);      // Emerald Green (Hadir)
  static const Color warningSakit = Color(0xFFF59E0B);      // Amber Orange (Sakit)
  static const Color infoIzin = Color(0xFF0284C7);          // Ocean Blue (Izin)
  static const Color errorAlpa = Color(0xFFEF4444);         // Rose Red (Alpa)
  static const Color teamTeal = Color(0xFF0D9488);          // Teal (Tefa / Praktik)

  // Neutral Colors (Simple, High Readability)
  static const Color background = Color(0xFFF8FAFC);        // Soft Slate 50
  static const Color white = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);            // Slate 200
  static const Color textPrimary = Color(0xFF0F172A);       // Slate 900
  static const Color textSecondary = Color(0xFF475569);     // Slate 600
  static const Color textTertiary = Color(0xFF94A3B8);      // Slate 400

  // Semantic Alert & Badge Backgrounds
  static const Color alertAmberBg = Color(0xFFFEF3C7);      // Sakit / Menunggu
  static const Color alertRedBg = Color(0xFFFEE2E2);        // Alpa / Ditolak
  static const Color alertGreenBg = Color(0xFFD1FAE5);      // Hadir / Disetujui
  static const Color alertBlueBg = Color(0xFFE0F2FE);       // Izin / Info Sekolah

  // Gradient Colors
  static const List<Color> headerGradient = [
    Color(0xFF0F2C59),  // Start: Deep Navy
    Color(0xFF1E40AF),  // Middle: Royal Education Blue
    Color(0xFF2563EB),  // End: Vibrant Blue
  ];
}
```


## Typography Tokens (lib/constants/app_typography.dart)

```dart
class AppTypography {
  // Font Family
  static const String fontFamily = 'PlusJakartaSans';
  
  // Type Styles
  static const TextStyle pageTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.bold,    // 700
    height: 1.2,
  );
  
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,    // 700
    height: 1.2,
  );
  
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.bold,    // 700
    height: 1.2,
  );
  
  static const TextStyle labelButton = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,    // 600
    height: 1.4,
  );
  
  static const TextStyle bodyText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,    // 500
    height: 1.5,
  );
  
  static const TextStyle smallHint = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,    // 500
    height: 1.4,
  );
  
  static const TextStyle microBadge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.bold,    // 700
    height: 1.2,
  );
}
```

## Spacing Tokens (lib/constants/app_spacing.dart)

```dart
class AppSpacing {
  // Base spacing unit (4px grid)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  
  // Card padding
  static const double cardPadding = xl;         // 20px
  static const double cardSmallPadding = md;    // 12px
  
  // Border radius
  static const double radiusSmall = 12.0;       // rounded-lg
  static const double radiusMedium = 20.0;      // rounded-xl
  static const double radiusLarge = 24.0;       // rounded-2xl
  static const double radiusXL = 32.0;          // rounded-b-[40px] for headers
  
  // Gaps & Margins
  static const double gapBetweenCards = lg;     // 16px
  static const double headerPadding = 56.0;     // pt-14 (top safe area)
  static const double footerHeight = 72.0;      // h-[72px]
  static const double footerPaddingBottom = 34.0; // pb-[34px] for iOS safe area
}
```

## Shadow/Elevation Tokens (lib/constants/app_shadows.dart)

```dart
class AppShadows {
  // Soft shadow for cards
  static const BoxShadow softShadow = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.06),
    blurRadius: 8.0,
    offset: Offset(0, 2),
  );
  
  // Medium shadow for elevated elements
  static const BoxShadow mediumShadow = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.10),
    blurRadius: 12.0,
    offset: Offset(0, 4),
  );
  
  // Large shadow for modals/bottom sheets
  static const BoxShadow largeShadow = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.15),
    blurRadius: 16.0,
    offset: Offset(0, 8),
  );
  
  // List of shadows for common use cases
  static const List<BoxShadow> cardShadows = [softShadow];
  static const List<BoxShadow> elevatedShadows = [mediumShadow];
  static const List<BoxShadow> modalShadows = [largeShadow];
}
```

## Theme Configuration (lib/theme/app_theme.dart)

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_spacing.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      
      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryIndigo,
        secondary: AppColors.teamTeal,
        surface: AppColors.white,
        background: AppColors.background,
        error: AppColors.errorAlpa,
        onBackground: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.white,
      ),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.pageTitle.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          side: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          borderSide: BorderSide(color: AppColors.primaryIndigo, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          borderSide: BorderSide(color: AppColors.errorAlpa),
        ),
        hintStyle: AppTypography.smallHint.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryIndigo,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          textStyle: AppTypography.labelButton,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryIndigo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          ),
          side: BorderSide(color: AppColors.border),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          textStyle: AppTypography.labelButton,
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryIndigo,
          textStyle: AppTypography.labelButton,
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryIndigo,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        enableFeedback: true,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.background,
        selectedColor: AppColors.primaryIndigo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        ),
        labelStyle: AppTypography.smallHint.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      
      // Dialog Theme
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
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
```

## pubspec.yaml Configuration

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
  fonts:
    - family: PlusJakartaSans
      fonts:
        - asset: assets/fonts/PlusJakartaSans-Regular.ttf
          weight: 400
        - asset: assets/fonts/PlusJakartaSans-Medium.ttf
          weight: 500
        - asset: assets/fonts/PlusJakartaSans-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/PlusJakartaSans-Bold.ttf
          weight: 700
```

## Alternative: Using google_fonts Package

If you prefer not to bundle fonts, use google_fonts in your MaterialApp:

```dart
import 'package:google_fonts/google_fonts.dart';

MaterialApp(
  theme: ThemeData(
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      Theme.of(context).textTheme,
    ),
  ),
  home: YourApp(),
)
```

# SCP Mobile - Material Component Protocol (MCP)

## Overview
Comprehensive UI component specifications for SCP Mobile Flutter app implementation. Each component follows the Material Design 3 guidelines with custom theming for SCP brand.

---

## 1. HEADER COMPONENTS

### 1.1 HeaderWithGradient
**Purpose:** Main app header with user greeting and gradient background
**Location:** lib/widgets/headers/header_with_gradient.dart

```dart
class HeaderWithGradient extends StatelessWidget {
  final String userName;
  final String userSubtitle;
  final String? avatarUrl;
  final Widget? actionButton;
  
  const HeaderWithGradient({
    required this.userName,
    required this.userSubtitle,
    this.avatarUrl,
    this.actionButton,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.headerPadding,
        bottom: AppSpacing.xl,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.headerGradient,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSpacing.radiusXL),
          bottomRight: Radius.circular(AppSpacing.radiusXL),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: avatarUrl != null
                      ? NetworkImage(avatarUrl!)
                      : AssetImage('assets/images/placeholder.png'),
                ),
                SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: AppTypography.pageTitle.copyWith(
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        userSubtitle,
                        style: AppTypography.smallHint.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (actionButton != null) actionButton!,
        ],
      ),
    );
  }
}
```

---

## 2. CARD COMPONENTS

### 2.1 SoftCardComponent
**Purpose:** Base card component with consistent styling
**Location:** lib/widgets/cards/soft_card.dart

```dart
class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final double? height;
  
  const SoftCard({
    required this.child,
    this.padding,
    this.onTap,
    this.height,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: padding ?? EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
          boxShadow: AppShadows.cardShadows,
        ),
        child: child,
      ),
    );
  }
}
```

### 2.2 MetricCardComponent
**Purpose:** Display attendance metrics (Hadir, Sakit, Izin, Alpa)
**Location:** lib/widgets/cards/metric_card.dart

```dart
class MetricCard extends StatelessWidget {
  final String label;
  final int value;
  final Color backgroundColor;
  final Color iconColor;
  final IconData icon;
  
  const MetricCard({
    required this.label,
    required this.value,
    required this.backgroundColor,
    required this.iconColor,
    required this.icon,
  });
  
  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          SizedBox(width: AppSpacing.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTypography.smallHint.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '$value',
                style: AppTypography.sectionTitle.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### 2.3 AlertCardComponent
**Purpose:** Display alerts and notifications
**Location:** lib/widgets/cards/alert_card.dart

```dart
enum AlertType { success, warning, error, info }

class AlertCard extends StatelessWidget {
  final String message;
  final AlertType type;
  final VoidCallback? onClose;
  
  static const Map<AlertType, Color> _bgColors = {
    AlertType.success: Color(0xFFD1FAE5),
    AlertType.warning: Color(0xFFFEF3C7),
    AlertType.error: Color(0xFFFEE2E2),
    AlertType.info: Color(0xFFE0F2FE),
  };
  
  static const Map<AlertType, Color> _textColors = {
    AlertType.success: Color(0xFF065F46),
    AlertType.warning: Color(0xFFB45309),
    AlertType.error: Color(0xFF991B1B),
    AlertType.info: Color(0xFF0C4A6E),
  };
  
  static const Map<AlertType, Color> _iconColors = {
    AlertType.success: Color(0xFF10B981),
    AlertType.warning: Color(0xFFF59E0B),
    AlertType.error: Color(0xFFEF4444),
    AlertType.info: Color(0xFF0284C7),
  };
  
  const AlertCard({
    required this.message,
    required this.type,
    this.onClose,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _bgColors[type],
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(
          color: _iconColors[type]!.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _iconColors[type],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: _getAlertIcon(type),
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              message,
              style: AppTypography.smallHint.copyWith(
                color: _textColors[type],
              ),
            ),
          ),
          if (onClose != null)
            IconButton(
              icon: Icon(Icons.close, size: 16),
              onPressed: onClose,
            ),
        ],
      ),
    );
  }
  
  Widget _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.success:
        return Icon(Icons.check_circle, color: Colors.white, size: 16);
      case AlertType.warning:
        return Icon(Icons.info, color: Colors.white, size: 16);
      case AlertType.error:
        return Icon(Icons.error, color: Colors.white, size: 16);
      case AlertType.info:
        return Icon(Icons.info, color: Colors.white, size: 16);
    }
  }
}
```

---

## 3. BUTTON COMPONENTS

### 3.1 PrimaryButtonComponent
**Purpose:** Main action button for primary actions
**Location:** lib/widgets/buttons/primary_button.dart

```dart
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon),
                    SizedBox(width: AppSpacing.md),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}
```

### 3.2 PillButtonComponent
**Purpose:** Segmented pill buttons for status/filter selection
**Location:** lib/widgets/buttons/pill_button.dart

```dart
class PillButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onPressed;
  final String? count;
  
  const PillButton({
    required this.label,
    required this.isActive,
    required this.onPressed,
    this.count,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryIndigo : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          border: isActive
              ? null
              : Border.all(color: AppColors.border, width: 1),
        ),
        child: Text(
          count != null ? '$label ($count)' : label,
          style: AppTypography.labelButton.copyWith(
            color: isActive ? AppColors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
```

---

## 4. INPUT COMPONENTS

### 4.1 SearchBarComponent
**Purpose:** Search input with icon
**Location:** lib/widgets/inputs/search_bar.dart

```dart
class SearchBar extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final VoidCallback? onFilterTap;
  final Function(String)? onChanged;
  
  const SearchBar({
    required this.hintText,
    this.controller,
    this.onFilterTap,
    this.onChanged,
  });
  
  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.controller,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: Icon(Icons.search, color: AppColors.textTertiary),
              prefixIconConstraints: BoxConstraints(minWidth: 40),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        if (widget.onFilterTap != null)
          IconButton(
            icon: Icon(Icons.tune, color: AppColors.textSecondary),
            onPressed: widget.onFilterTap,
          ),
      ],
    );
  }
}
```

---

## 5. BOTTOM NAVIGATION COMPONENTS

### 5.1 AppBottomNavBar
**Purpose:** Consistent bottom navigation across all screens
**Location:** lib/widgets/navigation/app_bottom_nav_bar.dart

```dart
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onIndexChanged;
  final List<AppBottomNavItem> items;
  
  const AppBottomNavBar({
    required this.currentIndex,
    required this.onIndexChanged,
    required this.items,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onIndexChanged,
        items: items.asMap().entries.map((entry) {
          int index = entry.key;
          AppBottomNavItem item = entry.value;
          
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.label,
            activeIcon: Icon(item.icon),
          );
        }).toList(),
      ),
    );
  }
}

class AppBottomNavItem {
  final IconData icon;
  final String label;
  
  AppBottomNavItem({required this.icon, required this.label});
}
```

---

## 6. LIST COMPONENTS

### 6.1 StudentListItemComponent
**Purpose:** Student card in list with avatar, info, and status
**Location:** lib/widgets/lists/student_list_item.dart

```dart
class StudentListItem extends StatelessWidget {
  final String studentName;
  final String nisn;
  final String? avatarUrl;
  final String? address;
  final String? statusBadge;
  final VoidCallback onTap;
  
  const StudentListItem({
    required this.studentName,
    required this.nisn,
    this.avatarUrl,
    this.address,
    this.statusBadge,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: avatarUrl != null
                ? NetworkImage(avatarUrl!)
                : AssetImage('assets/images/placeholder.png'),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        studentName,
                        style: AppTypography.cardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (statusBadge != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.alertAmberBg,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                        ),
                        child: Text(
                          statusBadge!,
                          style: AppTypography.microBadge.copyWith(
                            color: Color(0xFFFB923C),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  nisn,
                  style: AppTypography.smallHint.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                if (address != null) ...[
                  SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: AppColors.textTertiary),
                      SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          address!,
                          style: AppTypography.smallHint.copyWith(
                            color: AppColors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}
```

### 6.2 LeaveRequestCardComponent
**Purpose:** Display leave/permission request in list
**Location:** lib/widgets/lists/leave_request_card.dart

```dart
class LeaveRequestCard extends StatelessWidget {
  final String studentName;
  final String nisn;
  final String leaveType;      // 'Sakit' or 'Izin'
  final String dateRange;
  final String reason;
  final String status;         // 'Pending', 'Approved', 'Rejected'
  final String? avatarUrl;
  final VoidCallback onViewTap;
  
  const LeaveRequestCard({
    required this.studentName,
    required this.nisn,
    required this.leaveType,
    required this.dateRange,
    required this.reason,
    required this.status,
    this.avatarUrl,
    required this.onViewTap,
  });
  
  Color _getLeaveTypeColor() {
    return leaveType == 'Sakit' 
        ? AppColors.warningSakit 
        : AppColors.infoIzin;
  }
  
  Color _getStatusColor() {
    switch (status) {
      case 'Pending':
        return AppColors.warningSakit;
      case 'Approved':
        return AppColors.successHadir;
      case 'Rejected':
        return AppColors.errorAlpa;
      default:
        return AppColors.textSecondary;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl!)
                    : AssetImage('assets/images/placeholder.png'),
              ),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: _getLeaveTypeColor().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                          ),
                          child: Text(
                            leaveType,
                            style: AppTypography.microBadge.copyWith(
                              color: _getLeaveTypeColor(),
                            ),
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                          ),
                          child: Text(
                            status,
                            style: AppTypography.microBadge.copyWith(
                              color: _getStatusColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      dateRange,
                      style: AppTypography.cardTitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            reason,
            style: AppTypography.smallHint.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onViewTap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 16),
                  SizedBox(width: AppSpacing.md),
                  Text('Tinjau Surat'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 7. PROGRESS & INDICATOR COMPONENTS

### 7.1 AttendanceProgressBarComponent
**Purpose:** Display attendance percentage with progress bar
**Location:** lib/widgets/indicators/attendance_progress.dart

```dart
class AttendanceProgressBar extends StatelessWidget {
  final double percentage;
  final String label;
  final String? lastUpdated;
  
  const AttendanceProgressBar({
    required this.percentage,
    required this.label,
    this.lastUpdated,
  });
  
  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTypography.cardTitle),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: AppTypography.sectionTitle.copyWith(
                  color: AppColors.teamTeal,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 12,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation(
                LinearGradient(
                  colors: [AppColors.successHadir, AppColors.primaryIndigo],
                ).colors[0],
              ),
            ),
          ),
          if (lastUpdated != null) ...[
            SizedBox(height: AppSpacing.sm),
            Text(
              'Pembaruan terakhir: $lastUpdated',
              style: AppTypography.smallHint.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

---

## 8. ATTENDANCE STATUS COMPONENTS

### 8.1 AttendanceStatusToggleComponent
**Purpose:** Toggle buttons for attendance status [H/I/S/A]
**Location:** lib/widgets/attendance/attendance_status_toggle.dart

```dart
class AttendanceStatusToggle extends StatefulWidget {
  final String? initialStatus; // 'H', 'I', 'S', 'A'
  final Function(String) onStatusChanged;
  
  const AttendanceStatusToggle({
    this.initialStatus,
    required this.onStatusChanged,
  });
  
  @override
  State<AttendanceStatusToggle> createState() => _AttendanceStatusToggleState();
}

class _AttendanceStatusToggleState extends State<AttendanceStatusToggle> {
  late String selectedStatus;
  
  static const Map<String, Color> statusColors = {
    'H': Color(0xFF10B981),  // Hadir - Green
    'I': Color(0xFF0284C7),  // Izin - Blue
    'S': Color(0xFFF59E0B),  // Sakit - Amber
    'A': Color(0xFFEF4444),  // Alpa - Red
  };
  
  static const Map<String, String> statusLabels = {
    'H': 'Hadir',
    'I': 'Izin',
    'S': 'Sakit',
    'A': 'Alpa',
  };
  
  @override
  void initState() {
    super.initState();
    selectedStatus = widget.initialStatus ?? '';
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: statusColors.keys.map((status) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: GestureDetector(
            onTap: () {
              setState(() => selectedStatus = status);
              widget.onStatusChanged(status);
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: selectedStatus == status
                    ? statusColors[status]
                    : AppColors.white,
                border: Border.all(
                  color: selectedStatus == status
                      ? statusColors[status]!
                      : AppColors.border,
                  width: 1.5,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  status,
                  style: AppTypography.microBadge.copyWith(
                    color: selectedStatus == status
                        ? AppColors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
```

---

## 9. MODAL/BOTTOM SHEET COMPONENTS

### 9.1 ScheduleConflictBottomSheet
**Purpose:** Display schedule conflict warning
**Location:** lib/widgets/modals/schedule_conflict_bottom_sheet.dart

```dart
class ScheduleConflictBottomSheet extends StatelessWidget {
  final String conflictDescription;
  final VoidCallback onChangeSchedule;
  final VoidCallback onCancel;
  
  const ScheduleConflictBottomSheet({
    required this.conflictDescription,
    required this.onChangeSchedule,
    required this.onCancel,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusXL),
          topRight: Radius.circular(AppSpacing.radiusXL),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 48,
              height: 4,
              margin: EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Alert Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: Icon(
                Icons.warning_amber,
                color: AppColors.errorAlpa,
                size: 32,
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            
            // Title
            Text(
              'Peringatan Jadwal Bentrok!',
              style: AppTypography.sectionTitle.copyWith(
                color: Color(0xFF991B1B),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            
            // Description
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                border: Border.all(
                  color: Color(0xFFFEE2E2),
                  width: 1,
                ),
              ),
              child: Text(
                conflictDescription,
                style: AppTypography.bodyText.copyWith(
                  color: Color(0xFF991B1B),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            
            // Action Buttons
            PrimaryButton(
              label: 'Ubah Jam / Ruangan',
              onPressed: onChangeSchedule,
            ),
            SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: onCancel,
              child: Text('Batalkan'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Component Organization & Usage

### Directory Structure
```
lib/
├── constants/
│   ├── app_colors.dart
│   ├── app_typography.dart
│   ├── app_spacing.dart
│   └── app_shadows.dart
├── theme/
│   └── app_theme.dart
├── widgets/
│   ├── headers/
│   │   └── header_with_gradient.dart
│   ├── cards/
│   │   ├── soft_card.dart
│   │   ├── metric_card.dart
│   │   └── alert_card.dart
│   ├── buttons/
│   │   ├── primary_button.dart
│   │   └── pill_button.dart
│   ├── inputs/
│   │   └── search_bar.dart
│   ├── navigation/
│   │   └── app_bottom_nav_bar.dart
│   ├── lists/
│   │   ├── student_list_item.dart
│   │   └── leave_request_card.dart
│   ├── indicators/
│   │   └── attendance_progress.dart
│   ├── attendance/
│   │   └── attendance_status_toggle.dart
│   └── modals/
│       └── schedule_conflict_bottom_sheet.dart
├── screens/
│   ├── student/
│   ├── teacher/
│   └── homeroom/
└── main.dart
```

### Example Usage in Screen

```dart
class StudentHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeaderWithGradient(
              userName: 'Annette Putri',
              userSubtitle: 'XII RPL 1',
              avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Annette',
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  // Alert if pending
                  AlertCard(
                    message: '1 Surat Izin Sakit sedang menunggu verifikasi',
                    type: AlertType.warning,
                  ),
                  SizedBox(height: AppSpacing.gapBetweenCards),
                  
                  // Metrics Grid
                  GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.gapBetweenCards,
                    crossAxisSpacing: AppSpacing.gapBetweenCards,
                    children: [
                      MetricCard(
                        label: 'Hadir',
                        value: 42,
                        backgroundColor: Color(0xFFD1FAE5),
                        iconColor: AppColors.successHadir,
                        icon: Icons.check_circle,
                      ),
                      // ... more metrics
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onIndexChanged: (index) {
          // Handle navigation
        },
        items: [
          AppBottomNavItem(icon: Icons.home, label: 'Beranda'),
          AppBottomNavItem(icon: Icons.calendar_today, label: 'Jadwal'),
          // ... more items
        ],
      ),
    );
  }
}
```

# Flutter Implementation Guide & Best Practices

## Project Setup

### 1. Create Flutter Project
```bash
flutter create scp_mobile
cd scp_mobile
```

### 2. Update pubspec.yaml
```yaml
name: scp_mobile
description: SCP Mobile - School Class Progress Educational App

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  google_fonts: ^6.1.0
  http: ^1.1.0
  provider: ^6.0.0
  intl: ^0.19.0
  cached_network_image: ^3.3.1
  flutter_svg: ^2.0.7

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
```

---

## File Structure Best Practices

### Complete Project Structure

```
scp_mobile/
├── lib/
│   ├── main.dart                          # App entry point
│   │
│   ├── constants/
│   │   ├── app_colors.dart               # Color tokens
│   │   ├── app_typography.dart           # Typography scales
│   │   ├── app_spacing.dart              # Spacing & layout
│   │   └── app_shadows.dart              # Shadow definitions
│   │
│   ├── theme/
│   │   └── app_theme.dart                # Theme configuration
│   │
│   ├── models/                            # Data models
│   │   ├── student.dart
│   │   ├── leave_request.dart
│   │   ├── attendance.dart
│   │   └── class_schedule.dart
│   │
│   ├── services/                          # API & business logic
│   │   ├── auth_service.dart
│   │   ├── student_service.dart
│   │   ├── attendance_service.dart
│   │   ├── leave_service.dart
│   │   └── schedule_service.dart
│   │
│   ├── providers/                         # State management (Provider)
│   │   ├── auth_provider.dart
│   │   ├── student_provider.dart
│   │   ├── attendance_provider.dart
│   │   ├── leave_provider.dart
│   │   └── navigation_provider.dart
│   │
│   ├── widgets/
│   │   ├── common/                        # Reusable widgets
│   │   │   └── loading_shimmer.dart
│   │   │
│   │   ├── headers/
│   │   │   └── header_with_gradient.dart
│   │   │
│   │   ├── cards/
│   │   │   ├── soft_card.dart
│   │   │   ├── metric_card.dart
│   │   │   ├── alert_card.dart
│   │   │   ├── leave_request_card.dart
│   │   │   └── schedule_card.dart
│   │   │
│   │   ├── buttons/
│   │   │   ├── primary_button.dart
│   │   │   ├── secondary_button.dart
│   │   │   └── pill_button.dart
│   │   │
│   │   ├── inputs/
│   │   │   ├── search_bar.dart
│   │   │   ├── text_input.dart
│   │   │   └── date_picker.dart
│   │   │
│   │   ├── lists/
│   │   │   ├── student_list_item.dart
│   │   │   ├── leave_request_list.dart
│   │   │   └── attendance_log_list.dart
│   │   │
│   │   ├── navigation/
│   │   │   └── app_bottom_nav_bar.dart
│   │   │
│   │   ├── indicators/
│   │   │   ├── attendance_progress.dart
│   │   │   └── status_badge.dart
│   │   │
│   │   ├── attendance/
│   │   │   └── attendance_status_toggle.dart
│   │   │
│   │   └── modals/
│   │       ├── schedule_conflict_bottom_sheet.dart
│   │       ├── approval_dialog.dart
│   │       └── loading_dialog.dart
│   │
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── splash_screen.dart
│   │   │
│   │   ├── student/
│   │   │   ├── student_home_screen.dart
│   │   │   ├── student_schedule_screen.dart
│   │   │   ├── student_permission_screen.dart
│   │   │   ├── student_history_screen.dart
│   │   │   └── student_profile_screen.dart
│   │   │
│   │   ├── teacher/
│   │   │   ├── teacher_home_screen.dart
│   │   │   ├── teacher_journal_screen.dart
│   │   │   ├── teacher_attendance_screen.dart
│   │   │   ├── teacher_schedule_screen.dart
│   │   │   └── teacher_profile_screen.dart
│   │   │
│   │   └── homeroom/
│   │       ├── homeroom_home_screen.dart
│   │       ├── homeroom_verification_screen.dart
│   │       ├── homeroom_students_screen.dart
│   │       └── homeroom_profile_screen.dart
│   │
│   ├── routes/
│   │   └── app_routes.dart                # Route configuration
│   │
│   └── utils/
│       ├── date_formatter.dart            # Utility functions
│       ├── validators.dart
│       └── extensions.dart
│
├── assets/
│   ├── images/
│   │   ├── logo.png
│   │   ├── placeholder.png
│   │   └── illustrations/
│   │
│   └── fonts/
│       ├── PlusJakartaSans-Regular.ttf
│       ├── PlusJakartaSans-Medium.ttf
│       ├── PlusJakartaSans-SemiBold.ttf
│       └── PlusJakartaSans-Bold.ttf
│
├── test/
│   └── widget_test.dart
│
├── analysis_options.yaml
├── pubspec.yaml
└── pubspec.lock
```

---

## 3. Implementation Patterns

### 3.1 Color Usage Pattern

```dart
// ❌ DON'T - Hardcode colors
Container(
  color: Color(0xFF1E3A8A),
  child: Text('Hello'),
)

// ✅ DO - Use color tokens
Container(
  color: AppColors.primaryIndigo,
  child: Text('Hello'),
)
```

### 3.2 Spacing Usage Pattern

```dart
// ❌ DON'T - Use magic numbers
Padding(
  padding: EdgeInsets.all(16),
  child: Text('Hello'),
)

// ✅ DO - Use spacing tokens
Padding(
  padding: EdgeInsets.all(AppSpacing.lg),
  child: Text('Hello'),
)
```

### 3.3 Typography Usage Pattern

```dart
// ❌ DON'T - Create TextStyle inline
Text(
  'Hello',
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    fontFamily: 'PlusJakartaSans',
  ),
)

// ✅ DO - Use predefined typography
Text(
  'Hello',
  style: AppTypography.pageTitle,
)
```

### 3.4 Card Usage Pattern

```dart
// ✅ DO - Use SoftCard component
SoftCard(
  child: Column(
    children: [
      Text('Card Title', style: AppTypography.cardTitle),
      SizedBox(height: AppSpacing.md),
      Text('Card content', style: AppTypography.bodyText),
    ],
  ),
)
```

---

## 4. State Management with Provider

### 4.1 Auth Provider Example

```dart
import 'package:provider/provider.dart';

class AuthProvider extends ChangeNotifier {
  String? _userRole; // 'student', 'teacher', 'homeroom'
  String? _userId;
  bool _isLoading = false;
  
  String? get userRole => _userRole;
  String? get userId => _userId;
  bool get isLoading => _isLoading;
  
  Future<void> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Call AuthService
      final response = await AuthService.login(username, password);
      _userRole = response.role;
      _userId = response.userId;
    } catch (e) {
      // Handle error
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> logout() async {
    _userRole = null;
    _userId = null;
    notifyListeners();
  }
}
```

### 4.2 Using Provider in Screens

```dart
class StudentHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beranda Siswa'),
      ),
      body: Consumer<StudentProvider>(
        builder: (context, studentProvider, _) {
          if (studentProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          return ListView(
            children: [
              HeaderWithGradient(
                userName: studentProvider.studentName,
                userSubtitle: studentProvider.className,
              ),
              // ... more widgets
            ],
          );
        },
      ),
    );
  }
}
```

---

## 5. API Integration Pattern

### 5.1 Service Layer Example

```dart
class StudentService {
  static const String _baseUrl = 'https://api.scp-mobile.id';
  
  static Future<Student> fetchStudentProfile(String studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/students/$studentId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return Student.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to fetch student');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  static Future<void> updateAttendance(
    String studentId,
    String status, // 'H', 'I', 'S', 'A'
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/attendance'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'student_id': studentId,
          'status': status,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to update attendance');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
```

---

## 6. Validation & Error Handling

### 6.1 Form Validator

```dart
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    return null;
  }
  
  static String? validateNISN(String? value) {
    if (value == null || value.isEmpty) {
      return 'NISN tidak boleh kosong';
    }
    if (value.length != 10) {
      return 'NISN harus 10 digit';
    }
    return null;
  }
}
```

### 6.2 Error Handling in Screens

```dart
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  String? _errorMessage;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                if (_errorMessage != null)
                  AlertCard(
                    message: _errorMessage!,
                    type: AlertType.error,
                    onClose: () => setState(() => _errorMessage = null),
                  ),
                SizedBox(height: AppSpacing.gapBetweenCards),
                
                TextFormField(
                  validator: Validators.validateEmail,
                  onSaved: (value) => _username = value ?? '',
                ),
                SizedBox(height: AppSpacing.lg),
                
                TextFormField(
                  validator: Validators.validatePassword,
                  obscureText: true,
                  onSaved: (value) => _password = value ?? '',
                ),
                SizedBox(height: AppSpacing.xl),
                
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return PrimaryButton(
                      label: 'Masuk',
                      isLoading: authProvider.isLoading,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          
                          try {
                            await authProvider.login(_username, _password);
                            // Navigate to home
                          } catch (e) {
                            setState(() => _errorMessage = e.toString());
                          }
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 7. Navigation Setup

### 7.1 Routes Configuration

```dart
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String studentHome = '/student/home';
  static const String studentSchedule = '/student/schedule';
  static const String studentPermission = '/student/permission';
  static const String teacherHome = '/teacher/home';
  static const String teacherJournal = '/teacher/journal';
  static const String homeroomHome = '/homeroom/home';
  
  static Map<String, WidgetBuilder> routes = {
    splash: (context) => SplashScreen(),
    login: (context) => LoginScreen(),
    studentHome: (context) => StudentHomeScreen(),
    studentSchedule: (context) => StudentScheduleScreen(),
    studentPermission: (context) => StudentPermissionScreen(),
    teacherHome: (context) => TeacherHomeScreen(),
    teacherJournal: (context) => TeacherJournalScreen(),
    homeroomHome: (context) => HomeroomHomeScreen(),
  };
  
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    
    switch (settings.name) {
      case studentHome:
        return MaterialPageRoute(builder: (_) => StudentHomeScreen());
      default:
        return MaterialPageRoute(builder: (_) => SplashScreen());
    }
  }
}
```

### 7.2 Main App Configuration

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => LeaveProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SCP Mobile',
      theme: AppTheme.lightTheme,
      home: SplashScreen(),
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
```

---

## 8. Performance Optimization

### 8.1 Image Optimization

```dart
// ✅ DO - Use CachedNetworkImage for profile pictures
import 'package:cached_network_image/cached_network_image.dart';

CachedNetworkImage(
  imageUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Annette',
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  width: 48,
  height: 48,
  fit: BoxFit.cover,
)
```

### 8.2 List Optimization

```dart
// ✅ DO - Use ListView.builder for large lists
ListView.builder(
  itemCount: students.length,
  itemBuilder: (context, index) {
    return StudentListItem(
      studentName: students[index].name,
      nisn: students[index].nisn,
      avatarUrl: students[index].avatar,
      onTap: () => navigateToDetail(students[index].id),
    );
  },
)
```

### 8.3 Memory Management

```dart
// ✅ DO - Dispose resources in State
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  late TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // ...
  }
}
```

---

## 9. Testing

### 9.1 Widget Test Example

```dart
void main() {
  testWidgets('StudentHomeScreen displays header', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: StudentHomeScreen(),
        theme: AppTheme.lightTheme,
      ),
    );
    
    expect(find.text('Halo, Annette'), findsOneWidget);
    expect(find.text('XII RPL 1'), findsOneWidget);
  });
}
```

---

## 10. Deployment Checklist

### Pre-Release Checklist
- [ ] Run `flutter analyze` - no warnings
- [ ] Run all tests - 100% passing
- [ ] Update version in pubspec.yaml
- [ ] Update app name and bundle ID
- [ ] Generate app icon using Flutter Launcher Icons
- [ ] Create release keystore (Android)
- [ ] Review all permissions in AndroidManifest.xml
- [ ] Test on multiple devices/screen sizes
- [ ] Verify API endpoints for production
- [ ] Enable ProGuard for Android release
- [ ] Set up crash reporting (Firebase Crashlytics)
- [ ] Test offline mode functionality

### Build Commands

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

---

## Common Issues & Solutions

### Issue 1: Font Not Loading
**Solution:** Ensure fonts are added to pubspec.yaml and run `flutter pub get`

### Issue 2: Network Timeout
**Solution:** Implement timeout and retry logic in service layer

### Issue 3: Memory Leak with Images
**Solution:** Always dispose image cache and use CachedNetworkImage

### Issue 4: SafeArea Not Working
**Solution:** Use MediaQuery.of(context).padding instead of SafeArea

### Issue 5: Theme Not Applied
**Solution:** Restart app after changing theme, don't use hot reload