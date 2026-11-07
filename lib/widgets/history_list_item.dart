import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/lucide_icons.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

class HistoryListItem extends StatelessWidget {
  final DateTime date;
  final String title;
  final String subtitle;
  final String timeText;
  final AttendanceStatus status;
  final bool isAutoSynced;
  final String? autoSyncedNote;
  final VoidCallback? onTap;

  const HistoryListItem({
    super.key,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.timeText,
    required this.status,
    this.isAutoSynced = false,
    this.autoSyncedNote,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayNum = DateFormat('dd').format(date);
    final dayName = DateFormat('EEE', 'id_ID').format(date).toUpperCase();
    final monthName = DateFormat('MMM', 'id_ID').format(date);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppTheme.cardDecoration(
          radius: AppTheme.radiusMedium,
          shadow: AppTheme.softShadow,
        ),
        child: Row(
          children: [
            // Big Date Box on Left
            Container(
              width: 52,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.tintBackground,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(color: AppTheme.secondaryBlue.withValues(alpha: 0.4)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dayName,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryBlueDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    dayNum,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryBlueDark,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    monthName,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // Middle Column (Title, Subtitle, Time)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.clock,
                        size: 11,
                        color: AppTheme.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeText,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      if (isAutoSynced) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.tintBackground,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.refreshCw, size: 8, color: AppTheme.primaryBlue),
                              SizedBox(width: 2),
                              Text(
                                'Auto-synced',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryBlueDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Status Badge on Right
            StatusBadge.fromAttendance(
              status,
              isSmall: true,
              isAutoSynced: isAutoSynced,
            ),
          ],
        ),
      ),
    );
  }
}
