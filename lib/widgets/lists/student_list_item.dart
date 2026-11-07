import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../constants/app_spacing.dart';
import '../cards/soft_card.dart';

class StudentListItem extends StatelessWidget {
  final String studentName;
  final String nisn;
  final String? avatarUrl;
  final String? address;
  final String? statusBadge;
  final Color? statusBadgeColor;
  final Color? statusBadgeBgColor;
  final Widget? trailing;
  final VoidCallback onTap;

  const StudentListItem({
    super.key,
    required this.studentName,
    required this.nisn,
    this.avatarUrl,
    this.address,
    this.statusBadge,
    this.statusBadgeColor,
    this.statusBadgeBgColor,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.lightBlueBorder,
            backgroundImage: avatarUrl != null && avatarUrl!.startsWith('http')
                ? NetworkImage(avatarUrl!)
                : null,
            child: avatarUrl == null || !avatarUrl!.startsWith('http')
                ? Text(
                    studentName.isNotEmpty ? studentName[0].toUpperCase() : 'S',
                    style: AppTypography.cardTitle.copyWith(
                      color: AppColors.primaryBlue,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusBadgeBgColor ?? AppColors.alertAmberBg,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                        ),
                        child: Text(
                          statusBadge!,
                          style: AppTypography.microBadge.copyWith(
                            color: statusBadgeColor ?? const Color(0xFFFB923C),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  nisn,
                  style: AppTypography.smallHint.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                if (address != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: AppSpacing.xs),
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
          const SizedBox(width: AppSpacing.sm),
          trailing ?? const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
        ],
      ),
    );
  }
}
