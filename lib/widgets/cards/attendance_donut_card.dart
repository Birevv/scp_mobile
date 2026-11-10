import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_typography.dart';
import 'soft_card.dart';

class AttendanceDonutCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int hadirCount;
  final int sakitCount;
  final int izinCount;
  final int alpaCount;
  final double? percentage;
  final int? totalStudents;
  final VoidCallback? onTapDetail;

  const AttendanceDonutCard({
    super.key,
    this.title = 'Ringkasan Kehadiran',
    this.subtitle,
    required this.hadirCount,
    required this.sakitCount,
    required this.izinCount,
    required this.alpaCount,
    this.percentage,
    this.totalStudents,
    this.onTapDetail,
  });

  int get totalMeetings => hadirCount + sakitCount + izinCount + alpaCount;
  bool get hasData => totalMeetings > 0;

  double? get calculatedPercentage {
    if (totalMeetings == 0) return null;
    return (hadirCount / totalMeetings) * 100.0;
  }

  @override
  Widget build(BuildContext context) {
    final double? effectivePct = percentage ?? calculatedPercentage;
    final String pctText = hasData && effectivePct != null
        ? '${effectivePct.toStringAsFixed(effectivePct % 1 == 0 ? 0 : 1)}%'
        : '—';

    final String effectiveSubtitle = subtitle ??
        (hasData
            ? 'Rekapitulasi Kehadiran Semester Ini ($pctText)'
            : 'Belum ada data presensi');

    return SoftCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppSpacing.radiusLarge,
      onTap: onTapDetail,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      effectiveSubtitle,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (totalStudents != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightIndigoBg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    border: Border.all(color: AppColors.lightIndigoBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.groups_rounded,
                        size: 14,
                        color: AppColors.primaryIndigo,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '$totalStudents Siswa',
                        style: AppTypography.microBadge.copyWith(
                          color: AppColors.primaryIndigo,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Donut Chart + 4 Indicators
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular Progress / Donut Chart
              SizedBox(
                width: 96,
                height: 96,
                child: CustomPaint(
                  painter: _AttendanceDonutPainter(
                    hadir: hadirCount,
                    sakit: sakitCount,
                    izin: izinCount,
                    alpa: alpaCount,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          pctText,
                          style: AppTypography.tabularFigure.copyWith(
                            fontSize: hasData ? 20 : 22,
                            fontWeight: FontWeight.w700,
                            color: hasData
                                ? AppColors.primaryIndigo
                                : AppColors.textSecondary,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          hasData ? 'Hadir' : 'Presensi',
                          style: AppTypography.microBadge.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // 4 Status Indicators Grid (Hadir, Sakit, Izin, Alpa)
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatusMetric(
                            label: 'Hadir',
                            count: hadirCount,
                            color: AppColors.statusHadir, // #10B981
                            bgColor: AppColors.alertGreenBg,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatusMetric(
                            label: 'Sakit',
                            count: sakitCount,
                            color: AppColors.statusSakit, // #F59E0B
                            bgColor: AppColors.alertAmberBg,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatusMetric(
                            label: 'Izin',
                            count: izinCount,
                            color: AppColors.statusIzin, // #0284C7
                            bgColor: AppColors.alertBlueBg,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatusMetric(
                            label: 'Alpa',
                            count: alpaCount,
                            color: AppColors.statusAlpa, // #EF4444
                            bgColor: AppColors.alertRedBg,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMetric({
    required String label,
    required int count,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: AppTypography.tabularFigure.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
                Text(
                  label,
                  style: AppTypography.microBadge.copyWith(
                    fontSize: 10.5,
                    color: AppColors.textSecondary,
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
    );
  }
}

class _AttendanceDonutPainter extends CustomPainter {
  final int hadir;
  final int sakit;
  final int izin;
  final int alpa;

  _AttendanceDonutPainter({
    required this.hadir,
    required this.sakit,
    required this.izin,
    required this.alpa,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 10.5;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    // Base track
    final Paint trackPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    final int total = hadir + sakit + izin + alpa;
    if (total <= 0) return;

    final segments = <_DonutSegment>[
      if (hadir > 0) _DonutSegment(value: hadir, color: AppColors.statusHadir),
      if (sakit > 0) _DonutSegment(value: sakit, color: AppColors.statusSakit),
      if (izin > 0) _DonutSegment(value: izin, color: AppColors.statusIzin),
      if (alpa > 0) _DonutSegment(value: alpa, color: AppColors.statusAlpa),
    ];

    double startAngle = -math.pi / 2;
    const double fullCircle = 2 * math.pi;

    for (final seg in segments) {
      final double sweepAngle = (seg.value / total) * fullCircle;
      final Paint segPaint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = segments.length == 1 ? StrokeCap.round : StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, segPaint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _AttendanceDonutPainter oldDelegate) {
    return oldDelegate.hadir != hadir ||
        oldDelegate.sakit != sakit ||
        oldDelegate.izin != izin ||
        oldDelegate.alpa != alpa;
  }
}

class _DonutSegment {
  final int value;
  final Color color;

  const _DonutSegment({required this.value, required this.color});
}
