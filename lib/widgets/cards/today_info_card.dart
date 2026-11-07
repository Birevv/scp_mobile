import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_typography.dart';
import '../../models/models.dart';
import 'soft_card.dart';

class TodayInfoCard extends StatelessWidget {
  final String formattedDate;
  final AcademicEventInfo todayEvent;
  final CycleType activeCycle;
  final VoidCallback? onTapCalendarStatus;

  const TodayInfoCard({
    super.key,
    required this.formattedDate,
    required this.todayEvent,
    required this.activeCycle,
    this.onTapCalendarStatus,
  });

  @override
  Widget build(BuildContext context) {
    final bool isHolidayOrSpecial =
        todayEvent.isHoliday || todayEvent.disableKbm;
    final Color statusColor = isHolidayOrSpecial
        ? AppColors.warningSakit
        : AppColors.successHadir;
    final Color statusBg = isHolidayOrSpecial
        ? AppColors.alertAmberBg
        : AppColors.alertGreenBg;

    return SoftCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppSpacing.radiusLarge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.lightIndigoBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.lightIndigoBorder,
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.primaryIndigo,
                    size: 21,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Hari Ini',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedDate,
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Active Block Cycle Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightTealBg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  border: Border.all(color: AppColors.lightTealBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.autorenew_rounded,
                      size: 13,
                      color: AppColors.secondaryTeal,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      activeCycle.label,
                      style: AppTypography.microBadge.copyWith(
                        color: AppColors.secondaryTeal,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          InkWell(
            onTap: onTapCalendarStatus,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: statusBg.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isHolidayOrSpecial
                        ? Icons.event_busy_rounded
                        : Icons.verified_rounded,
                    size: 17,
                    color: statusColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todayEvent.categoryLabel,
                          style: AppTypography.microBadge.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          todayEvent.title,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      isHolidayOrSpecial ? 'Libur / Non-KBM' : 'Sekolah Aktif',
                      style: AppTypography.microBadge.copyWith(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
