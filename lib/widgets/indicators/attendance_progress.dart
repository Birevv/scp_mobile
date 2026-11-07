import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../constants/app_spacing.dart';
import '../cards/soft_card.dart';

class AttendanceProgressBar extends StatelessWidget {
  final double percentage;
  final String label;
  final String? lastUpdated;
  final Widget? trailing;

  const AttendanceProgressBar({
    super.key,
    required this.percentage,
    required this.label,
    this.lastUpdated,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final clampedPercentage = percentage.clamp(0.0, 100.0);

    return SoftCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.cardTitle,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: AppTypography.sectionTitle.copyWith(
                      color: AppColors.primaryBlue,
                      fontSize: 18,
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            child: LinearProgressIndicator(
              value: clampedPercentage / 100,
              minHeight: 10,
              backgroundColor: AppColors.lightBlueBorder,
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue),
            ),
          ),
          if (lastUpdated != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Pembaruan: $lastUpdated',
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
