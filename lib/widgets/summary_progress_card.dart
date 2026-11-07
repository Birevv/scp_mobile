import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SummaryProgressCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int hadirCount;
  final int izinCount;
  final int sakitCount;
  final int alpaCount;
  final String? actionText;
  final VoidCallback? onActionTap;

  const SummaryProgressCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.hadirCount,
    required this.izinCount,
    required this.sakitCount,
    required this.alpaCount,
    this.actionText,
    this.onActionTap,
  });

  int get total => hadirCount + izinCount + sakitCount + alpaCount;
  double get hadirPercent => total > 0 ? (hadirCount / total) * 100 : 0;
  double get izinPercent => total > 0 ? (izinCount / total) * 100 : 0;
  double get sakitPercent => total > 0 ? (sakitCount / total) * 100 : 0;
  double get alpaPercent => total > 0 ? (alpaCount / total) * 100 : 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(
        radius: AppTheme.radiusXLarge,
        shadow: AppTheme.softShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
              if (actionText != null)
                InkWell(
                  onTap: onActionTap,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      actionText!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Big Percentage Metric & Sub-stat
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${hadirPercent.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryBlueDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Tingkat Kehadiran',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textMuted,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.tintBackground,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  '$total Total Pertemuan',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlueDark,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Multi-Segmented Horizontal Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            child: Container(
              height: 10,
              width: double.infinity,
              color: AppTheme.borderLight.withValues(alpha: 0.5),
              child: Row(
                children: [
                  if (hadirCount > 0)
                    Flexible(
                      flex: hadirCount,
                      child: Container(color: AppTheme.success),
                    ),
                  if (izinCount > 0)
                    Flexible(
                      flex: izinCount,
                      child: Container(color: AppTheme.warning),
                    ),
                  if (sakitCount > 0)
                    Flexible(
                      flex: sakitCount,
                      child: Container(color: const Color(0xFF0288D1)),
                    ),
                  if (alpaCount > 0)
                    Flexible(
                      flex: alpaCount,
                      child: Container(color: AppTheme.danger),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Colored Dot Legends with counts and labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegendItem(
                color: AppTheme.success,
                label: 'Hadir',
                count: hadirCount,
              ),
              _buildLegendItem(
                color: AppTheme.warning,
                label: 'Izin',
                count: izinCount,
              ),
              _buildLegendItem(
                color: const Color(0xFF0288D1),
                label: 'Sakit',
                count: sakitCount,
              ),
              _buildLegendItem(
                color: AppTheme.danger,
                label: 'Alpa',
                count: alpaCount,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required int count,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
