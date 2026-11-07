import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../constants/app_spacing.dart';

class HeaderWithGradient extends StatelessWidget {
  final String userName;
  final String userSubtitle;
  final String? greeting;
  final String? avatarUrl;
  final Widget? actionButton;
  final Widget? bottomChild;
  final String? badgeText;
  final String? secondaryBadgeText;
  final IconData? secondaryBadgeIcon;
  final bool isDashboard;
  final VoidCallback? onAvatarTap;

  const HeaderWithGradient({
    super.key,
    required this.userName,
    required this.userSubtitle,
    this.greeting,
    this.avatarUrl,
    this.actionButton,
    this.bottomChild,
    this.badgeText,
    this.secondaryBadgeText,
    this.secondaryBadgeIcon,
    this.isDashboard = false,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bool usePersonalLayout = isDashboard || greeting != null;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primaryIndigo,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: topPad + 14,
            bottom: AppSpacing.lg,
            left: AppSpacing.xl,
            right: AppSpacing.xl,
          ),
          child: usePersonalLayout
              ? _buildPersonalDashboardHeader(context)
              : _buildSubpageHeader(context),
        ),
      ),
    );
  }

  Widget _buildPersonalDashboardHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Row: [Logo SCP] ..................... [Action] [Foto Profil]
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SCP Brand Identity Pill
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/SMK_Negeri_1_Bantul_logo.png',
                    width: 34,
                    height: 34,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SCP Mobile',
                          style: AppTypography.microBadge.copyWith(
                            color: Colors.white,
                            fontSize: 12,
                            letterSpacing: 0.2,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'SMK Negeri 1 Bantul',
                          style: AppTypography.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (actionButton != null) ...[
                  actionButton!,
                  const SizedBox(width: 10),
                ],
                GestureDetector(
                  onTap: onAvatarTap,
                  child: _buildAvatar(radius: 20),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Greeting & User Name
        Text(
          greeting ?? 'Selamat datang,',
          style: AppTypography.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          userName,
          style: AppTypography.heading2.copyWith(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          userSubtitle,
          style: AppTypography.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        // Status / Cycle Pills Row
        if (badgeText != null || secondaryBadgeText != null) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4.5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryTeal,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF5EEAD4),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          badgeText!,
                          style: AppTypography.microBadge.copyWith(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              if (secondaryBadgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        secondaryBadgeIcon ?? Icons.access_time_filled_rounded,
                        size: 12,
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          secondaryBadgeText!,
                          style: AppTypography.microBadge.copyWith(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],

        if (bottomChild != null) ...[
          const SizedBox(height: 14),
          bottomChild!,
        ],
      ],
    );
  }

  Widget _buildSubpageHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  if (avatarUrl != null) ...[
                    _buildAvatar(radius: 21),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                userName,
                                style: AppTypography.pageTitle.copyWith(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (badgeText != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryTeal,
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusPill,
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  badgeText!,
                                  style: AppTypography.microBadge.copyWith(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          userSubtitle,
                          style: AppTypography.smallHint.copyWith(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (actionButton != null) ...[
              const SizedBox(width: 8),
              actionButton!,
            ],
          ],
        ),
        if (bottomChild != null) ...[
          const SizedBox(height: 14),
          bottomChild!,
        ],
      ],
    );
  }

  Widget _buildAvatar({required double radius}) {
    final bool isTest = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    final bool hasNetImage =
        !isTest && avatarUrl != null && avatarUrl!.startsWith('http');
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.lightIndigoBg,
        backgroundImage: hasNetImage ? NetworkImage(avatarUrl!) : null,
        onBackgroundImageError: hasNetImage ? (_, _) {} : null,
        child: !hasNetImage
            ? Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: AppTypography.pageTitle.copyWith(
                  color: AppColors.primaryIndigo,
                  fontSize: radius * 0.78,
                ),
              )
            : null,
      ),
    );
  }
}
