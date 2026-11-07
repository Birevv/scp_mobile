import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../constants/app_spacing.dart';
import '../cards/soft_card.dart';

class LeaveRequestCard extends StatelessWidget {
  final String studentName;
  final String nisn;
  final String leaveType; // 'Sakit', 'Izin', 'Pulang Cepat', 'Kegiatan Luar'
  final String dateRange;
  final String? leaveTime;
  final String reason;
  final String status; // 'Pending', 'Approved', 'Rejected' or Indonesian labels
  final String? avatarUrl;
  final String? verifiedBy;
  final String? rejectionNote;
  final String actionLabel;
  final VoidCallback onViewTap;
  final VoidCallback? onCancelTap;

  const LeaveRequestCard({
    super.key,
    required this.studentName,
    required this.nisn,
    required this.leaveType,
    required this.dateRange,
    this.leaveTime,
    required this.reason,
    required this.status,
    this.avatarUrl,
    this.verifiedBy,
    this.rejectionNote,
    this.actionLabel = 'Tinjau Surat',
    required this.onViewTap,
    this.onCancelTap,
  });

  Color _getLeaveTypeColor() {
    final lower = leaveType.toLowerCase();
    if (lower.contains('sakit')) return AppColors.statusSakit;
    if (lower.contains('pulang')) return AppColors.primaryIndigo;
    if (lower.contains('kegiatan')) return AppColors.secondaryTeal;
    return AppColors.statusIzin;
  }

  Color _getLeaveTypeBg() {
    final lower = leaveType.toLowerCase();
    if (lower.contains('sakit')) return AppColors.alertAmberBg;
    if (lower.contains('pulang')) return AppColors.lightIndigoBg;
    if (lower.contains('kegiatan')) return AppColors.lightTealBg;
    return AppColors.alertBlueBg;
  }

  Color _getStatusTextColor() {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'menunggu':
      case 'menunggu verifikasi':
        return AppColors.statusPendingText;
      case 'approved':
      case 'disetujui':
        return AppColors.statusApprovedText;
      case 'rejected':
      case 'ditolak':
        return AppColors.statusRejectedText;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusBg() {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'menunggu':
      case 'menunggu verifikasi':
        return AppColors.statusPendingBg; // #FEF3C7
      case 'approved':
      case 'disetujui':
        return AppColors.statusApprovedBg; // #D1FAE5
      case 'rejected':
      case 'ditolak':
        return AppColors.statusRejectedBg; // #FEE2E2
      default:
        return AppColors.background;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppSpacing.radiusLarge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Builder(
                builder: (context) {
                  final bool isTest =
                      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
                  final bool hasNetImage = !isTest &&
                      avatarUrl != null &&
                      avatarUrl!.startsWith('http');
                  return CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.lightIndigoBg,
                    backgroundImage:
                        hasNetImage ? NetworkImage(avatarUrl!) : null,
                    onBackgroundImageError: hasNetImage ? (_, _) {} : null,
                    child: !hasNetImage
                        ? Text(
                            studentName.isNotEmpty
                                ? studentName[0].toUpperCase()
                                : 'S',
                            style: AppTypography.cardTitle.copyWith(
                              color: AppColors.primaryIndigo,
                              fontSize: 14,
                            ),
                          )
                        : null,
                  );
                },
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            studentName,
                            style: AppTypography.cardTitle.copyWith(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusBg(),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusPill),
                          ),
                          child: Text(
                            status,
                            style: AppTypography.microBadge.copyWith(
                              color: _getStatusTextColor(),
                              fontWeight: FontWeight.w600,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          nisn,
                          style: AppTypography.smallHint.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getLeaveTypeBg(),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            leaveType,
                            style: AppTypography.microBadge.copyWith(
                              color: _getLeaveTypeColor(),
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        if (leaveTime != null && leaveTime!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.schedule_rounded,
                                  size: 11,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${leaveTime!} WIB',
                                  style: AppTypography.microBadge.copyWith(
                                    color: AppColors.textPrimary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: AppColors.primaryIndigo,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    dateRange,
                    style: AppTypography.smallHint.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            reason,
            style: AppTypography.smallHint.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (rejectionNote != null && rejectionNote!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.statusRejectedBg.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.alertRedBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: AppColors.statusRejectedText,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Alasan Ditolak: $rejectionNote',
                      style: AppTypography.microBadge.copyWith(
                        color: AppColors.statusRejectedText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (verifiedBy != null && verifiedBy!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  size: 13,
                  color: AppColors.secondaryTeal,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Diverifikasi oleh: $verifiedBy',
                    style: AppTypography.microBadge.copyWith(
                      color: AppColors.secondaryTeal,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryIndigo),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: onViewTap,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.assignment_outlined,
                          size: 16,
                          color: AppColors.primaryIndigo,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          actionLabel,
                          style: AppTypography.labelButton.copyWith(
                            fontSize: 12.5,
                            color: AppColors.primaryIndigo,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (onCancelTap != null) ...[
                const SizedBox(width: 8),
                SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorAlpa,
                      side: const BorderSide(color: AppColors.alertRedBorder),
                      backgroundColor:
                          AppColors.statusRejectedBg.withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: onCancelTap,
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: Text(
                      'Batalkan',
                      style: AppTypography.microBadge.copyWith(
                        color: AppColors.errorAlpa,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
