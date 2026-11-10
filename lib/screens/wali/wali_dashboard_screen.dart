import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../constants/app_spacing.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/headers/header_with_gradient.dart';
import '../../widgets/cards/soft_card.dart';
import '../../widgets/cards/attendance_donut_card.dart';
import '../../widgets/cards/data_state_view.dart';
import '../../widgets/cards/today_info_card.dart';
import '../../widgets/menu_grid.dart';

class WaliDashboardScreen extends StatelessWidget {
  final AppState state;
  final Function(String routeName) onNavigate;

  const WaliDashboardScreen({
    super.key,
    required this.state,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final user = state.currentUser;
    final summary = state.homeroomSummary;
    final allRequests = state.leaveRequests;
    final pendingRequests =
        allRequests.where((r) => r.status == LeaveStatus.pending).toList();

    final isBk = user.role == UserRole.guruBk;
    final roleTitle = isBk ? 'Guru BK' : 'Wali Kelas';
    final targetClassLabel = user.className.isNotEmpty
        ? user.className
        : (isBk ? 'Semua Kelas' : 'Kelas Binaan');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primaryIndigo,
        onRefresh: () async {
          await Future.wait([
            state.fetchHomeroomDashboardData(),
            state.fetchHomeroomLeavesData(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER PERSONAL
              HeaderWithGradient(
                isDashboard: true,
                greeting: 'Selamat bertugas,',
                userName: user.name,
                userSubtitle: '$roleTitle • ${user.identifier}',
                avatarUrl: user.avatarUrl,
                badgeText: '${state.activeCycle.label} Aktif',
                secondaryBadgeText: isBk
                    ? 'Bimbingan Konseling'
                    : 'Kelas Binaan: $targetClassLabel',
                secondaryBadgeIcon: Icons.verified_user_rounded,
                onAvatarTap: () => onNavigate('profile'),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.dashboardError != null) ...[
                      DataErrorCard(
                        title: 'Gagal Memuat Data Dashboard',
                        message: state.dashboardError!,
                        onRetry: () => state.fetchHomeroomDashboardData(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // INFORMASI HARI INI & KALENDER
                    TodayInfoCard(
                      formattedDate: state.currentDateLabel,
                      todayEvent: state.todayEvent,
                      activeCycle: state.activeCycle,
                      calendarEvents: state.calendarEvents,
                      upcomingEvent: state.upcomingEvent,
                      onTapCalendarStatus: () => onNavigate('academic_calendar'),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // 2. RINGKASAN KEHADIRAN (Donut Chart)
                    if (state.isLoadingDashboard && summary.totalStudents == 0)
                      const DataLoadingCard(
                        message: 'Memuat data presensi kelas binaan...',
                      )
                    else
                      AttendanceDonutCard(
                        title: isBk
                            ? 'Ringkasan Presensi Sekolah'
                            : 'Ringkasan Kehadiran Kelas',
                        subtitle:
                            'Monitoring Presensi $targetClassLabel Hari Ini (${summary.percentage.toStringAsFixed(1)}%)',
                        totalStudents: summary.totalStudents > 0
                            ? summary.totalStudents
                            : null,
                        hadirCount: summary.hadir,
                        sakitCount: summary.sakit,
                        izinCount: summary.izin,
                        alpaCount: summary.alpa,
                        onTapDetail: () => onNavigate('wali_students'),
                      ),

                    const SizedBox(height: AppSpacing.lg),

                    // 3. CARD PENGAJUAN IZIN PENDING
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: pendingRequests.isNotEmpty
                            ? AppColors.statusPendingBg.withValues(alpha: 0.78)
                            : AppColors.statusApprovedBg.withValues(alpha: 0.65),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusLarge),
                        border: Border.all(
                          color: pendingRequests.isNotEmpty
                              ? AppColors.statusSakit.withValues(alpha: 0.45)
                              : AppColors.statusHadir.withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: pendingRequests.isNotEmpty
                                      ? AppColors.statusSakit
                                          .withValues(alpha: 0.16)
                                      : AppColors.statusHadir
                                          .withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: Icon(
                                  pendingRequests.isNotEmpty
                                      ? Icons.mark_email_unread_rounded
                                      : Icons.verified_rounded,
                                  color: pendingRequests.isNotEmpty
                                      ? AppColors.statusPendingText
                                      : AppColors.statusApprovedText,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            pendingRequests.isNotEmpty
                                                ? 'Perlu Verifikasi'
                                                : 'Verifikasi Terkendali',
                                            style: AppTypography.cardTitle
                                                .copyWith(
                                              color: pendingRequests.isNotEmpty
                                                  ? AppColors.statusPendingText
                                                  : AppColors.statusApprovedText,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        if (pendingRequests.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.statusSakit,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                AppSpacing.radiusPill,
                                              ),
                                            ),
                                            child: Text(
                                              '${pendingRequests.length} Pending',
                                              style: AppTypography.microBadge
                                                  .copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      pendingRequests.isNotEmpty
                                          ? '${pendingRequests.length} surat izin menunggu pemeriksaan Anda.'
                                          : 'Seluruh surat perizinan siswa telah diverifikasi.',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 42,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: pendingRequests.isNotEmpty
                                    ? AppColors.primaryIndigo
                                    : AppColors.secondaryTeal,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => onNavigate('wali_leave_queue'),
                              icon: const Icon(
                                Icons.fact_check_rounded,
                                size: 18,
                              ),
                              label: Text(
                                'Buka Verifikasi',
                                style: AppTypography.labelButton.copyWith(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // 4. AKSES CEPAT
                    MenuGrid(
                      sectionTitle: 'Akses Cepat',
                      items: [
                        MenuItemData(
                          label: 'Verifikasi Izin',
                          icon: Icons.fact_check_rounded,
                          iconColor: AppColors.brandPrimary,
                          bgColor: AppColors.brandAccent,
                          badge: pendingRequests.isNotEmpty
                              ? '${pendingRequests.length}'
                              : null,
                          onTap: () => onNavigate('wali_leave_queue'),
                        ),
                        MenuItemData(
                          label: 'Data Siswa',
                          icon: Icons.people_alt_rounded,
                          iconColor: AppColors.secondaryTeal,
                          bgColor: AppColors.lightTealBg,
                          onTap: () => onNavigate('wali_students'),
                        ),
                        MenuItemData(
                          label: 'Rekap Presensi',
                          icon: Icons.pie_chart_rounded,
                          iconColor: AppColors.brandPrimary,
                          bgColor: AppColors.brandAccent,
                          onTap: () => onNavigate('wali_students'),
                        ),
                        MenuItemData(
                          label: 'Riwayat Perizinan',
                          icon: Icons.folder_shared_rounded,
                          iconColor: AppColors.secondaryTeal,
                          bgColor: AppColors.lightTealBg,
                          onTap: () => onNavigate('wali_leave_queue'),
                        ),
                        MenuItemData(
                          label: 'Kalender',
                          icon: Icons.date_range_rounded,
                          iconColor: AppColors.brandNavy,
                          bgColor: AppColors.brandAccent,
                          onTap: () => onNavigate('academic_calendar'),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // 5. INFORMASI AKTIVITAS TERBARU
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Informasi Aktivitas Terbaru',
                            style: AppTypography.sectionTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton(
                          onPressed: () => onNavigate('wali_leave_queue'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Semua ›',
                            style: AppTypography.smallHint.copyWith(
                              color: AppColors.primaryIndigo,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    if (allRequests.isEmpty)
                      SoftCard(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'Belum ada aktivitas perizinan terbaru.',
                              style: AppTypography.smallHint,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: allRequests.take(4).length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final req = allRequests[index];
                          final bool isPending =
                              req.status == LeaveStatus.pending;
                          final bool isApproved =
                              req.status == LeaveStatus.approved;

                          final Color statusBg = isPending
                              ? AppColors.statusPendingBg
                              : isApproved
                                  ? AppColors.statusApprovedBg
                                  : AppColors.statusRejectedBg;
                          final Color statusText = isPending
                              ? AppColors.statusPendingText
                              : isApproved
                                  ? AppColors.statusApprovedText
                                  : AppColors.statusRejectedText;

                          return SoftCard(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            borderRadius: AppSpacing.radiusLarge,
                            onTap: () => onNavigate('wali_leave_queue'),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.lightIndigoBg,
                                  child: Text(
                                    req.studentName.isNotEmpty
                                        ? req.studentName[0].toUpperCase()
                                        : 'S',
                                    style: AppTypography.cardTitle.copyWith(
                                      color: AppColors.primaryIndigo,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              req.studentName,
                                              style: AppTypography.cardTitle
                                                  .copyWith(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusBg,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                AppSpacing.radiusPill,
                                              ),
                                            ),
                                            child: Text(
                                              req.status.label,
                                              style: AppTypography.microBadge
                                                  .copyWith(
                                                color: statusText,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 9.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${req.className} • ${req.type.label}${req.leaveTime != null ? " (${req.leaveTime} WIB)" : ""}',
                                        style:
                                            AppTypography.microBadge.copyWith(
                                          color: AppColors.secondaryTeal,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        req.reason,
                                        style: AppTypography.smallHint.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
