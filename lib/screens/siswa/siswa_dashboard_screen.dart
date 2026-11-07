import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../constants/app_spacing.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/headers/header_with_gradient.dart';
import '../../widgets/cards/soft_card.dart';
import '../../widgets/cards/today_info_card.dart';
import '../../widgets/cards/attendance_donut_card.dart';
import '../../widgets/cards/data_state_view.dart';
import '../../widgets/menu_grid.dart';

class SiswaDashboardScreen extends StatelessWidget {
  final AppState state;
  final Function(String routeName) onNavigate;

  const SiswaDashboardScreen({
    super.key,
    required this.state,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final user = state.currentUser;
    final summary = state.studentSummary;
    final todaySchedules = state.todaySchedules;
    final pendingRequests = state.leaveRequests
        .where((r) => r.status == LeaveStatus.pending)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primaryIndigo,
        onRefresh: () async {
          await Future.wait([
            state.fetchStudentDashboardData(),
            state.fetchStudentLeavesData(),
            state.fetchStudentHistoryData(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER PERSONAL (Logo SCP, Greeting, Name, Avatar, Class, Putaran 1/2 Badge)
              HeaderWithGradient(
                isDashboard: true,
                greeting: 'Selamat datang,',
                userName: user.name,
                userSubtitle: 'Siswa • ${user.className}',
                avatarUrl: user.avatarUrl,
                badgeText: '${state.activeCycle.label} Aktif',
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
                    // Error state if dashboard data failed to load
                    if (state.dashboardError != null) ...[
                      DataErrorCard(
                        title: 'Gagal Memuat Data Dashboard',
                        message: state.dashboardError!,
                        onRetry: () => state.fetchStudentDashboardData(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // 2. CARD INFORMASI HARI INI
                    TodayInfoCard(
                      formattedDate: state.currentDateLabel,
                      todayEvent: state.todayEvent,
                      activeCycle: state.activeCycle,
                      onTapCalendarStatus: null,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // 3. CARD RINGKASAN KEHADIRAN (Donut Chart + 4 Indikator)
                    if (state.isLoadingDashboard && summary.total == 0)
                      const DataLoadingCard(
                        message: 'Memuat ringkasan kehadiran siswa...',
                      )
                    else
                      AttendanceDonutCard(
                        title: 'Ringkasan Kehadiran',
                        subtitle:
                            'Persentase Kehadiran Semester Ini (${summary.percentage.toStringAsFixed(1)}%)',
                        hadirCount: summary.hadir,
                        sakitCount: summary.sakit,
                        izinCount: summary.izin,
                        alpaCount: summary.alpa,
                        onTapDetail: () => onNavigate('siswa_history'),
                      ),

                    const SizedBox(height: AppSpacing.lg),

                    // 4. AKSES CEPAT (Grid 4 Menu dengan Ikon Ilustratif)
                    MenuGrid(
                      sectionTitle: 'Akses Cepat',
                      items: [
                        MenuItemData(
                          label: 'Jadwal Pelajaran',
                          icon: Icons.calendar_month_rounded,
                          iconColor: AppColors.primaryIndigo,
                          bgColor: AppColors.lightIndigoBg,
                          onTap: () => onNavigate('siswa_schedule'),
                        ),
                        MenuItemData(
                          label: 'Ajukan Izin',
                          icon: Icons.note_add_rounded,
                          iconColor: AppColors.secondaryTeal,
                          bgColor: AppColors.lightTealBg,
                          onTap: () => onNavigate('siswa_leave_request'),
                        ),
                        MenuItemData(
                          label: 'Riwayat Presensi',
                          icon: Icons.fact_check_rounded,
                          iconColor: AppColors.primaryIndigo,
                          bgColor: AppColors.lightIndigoBg,
                          onTap: () => onNavigate('siswa_history'),
                        ),
                        MenuItemData(
                          label: 'Perizinan Saya',
                          icon: Icons.mark_email_read_rounded,
                          iconColor: AppColors.secondaryTeal,
                          bgColor: AppColors.lightTealBg,
                          badge: pendingRequests.isNotEmpty
                              ? '${pendingRequests.length}'
                              : null,
                          onTap: () => onNavigate('siswa_leave_status'),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // 5. JADWAL HARI INI
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Jadwal Hari Ini',
                            style: AppTypography.sectionTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton(
                          onPressed: () => onNavigate('siswa_schedule'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Lihat Semua ›',
                            style: AppTypography.smallHint.copyWith(
                              color: AppColors.primaryIndigo,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    if (state.isLoadingDashboard && todaySchedules.isEmpty)
                      const DataLoadingCard(
                        message: 'Memuat jadwal hari ini...',
                      )
                    else if (todaySchedules.isEmpty)
                      SoftCard(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'Tidak ada jadwal pelajaran untuk hari ini.',
                              style: AppTypography.smallHint,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: todaySchedules.take(3).length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final s = todaySchedules[index];
                          final bool isOngoing =
                              index == 0 && !state.todayEvent.disableKbm;

                          return SoftCard(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            borderRadius: AppSpacing.radiusLarge,
                            border: isOngoing
                                ? Border.all(
                                    color: AppColors.secondaryTeal,
                                    width: 1.5,
                                  )
                                : null,
                            onTap: () => onNavigate('siswa_schedule'),
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
                                        color: isOngoing
                                            ? AppColors.lightTealBg
                                            : AppColors.lightIndigoBg,
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: Icon(
                                        Icons.menu_book_rounded,
                                        color: isOngoing
                                            ? AppColors.secondaryTeal
                                            : AppColors.primaryIndigo,
                                        size: 21,
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
                                                  s.subjectName,
                                                  style: AppTypography.cardTitle
                                                      .copyWith(
                                                    fontSize: 14.5,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (isOngoing) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors
                                                        .statusApprovedBg,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      AppSpacing.radiusPill,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        width: 6,
                                                        height: 6,
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: AppColors
                                                              .statusHadir,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Sedang Berlangsung',
                                                        style: AppTypography
                                                            .microBadge
                                                            .copyWith(
                                                          color: AppColors
                                                              .statusApprovedText,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 9.5,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            s.teacherName,
                                            style: AppTypography.smallHint
                                                .copyWith(
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
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time_rounded,
                                        size: 14,
                                        color: AppColors.primaryIndigo,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${s.startTime} - ${s.endTime} WIB',
                                        style:
                                            AppTypography.microBadge.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(
                                        Icons.meeting_room_outlined,
                                        size: 14,
                                        color: AppColors.secondaryTeal,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          s.roomName,
                                          style: AppTypography.microBadge
                                              .copyWith(
                                            color: AppColors.textSecondary,
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
                          );
                        },
                      ),

                    // 6. INFORMASI PENGAJUAN IZIN (Hanya jika ada pending)
                    if (pendingRequests.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Informasi Pengajuan Izin',
                        style: AppTypography.sectionTitle,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SoftCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        borderRadius: AppSpacing.radiusLarge,
                        color: AppColors.statusPendingBg.withValues(alpha: 0.55),
                        border: Border.all(
                          color: AppColors.statusSakit.withValues(alpha: 0.4),
                          width: 1,
                        ),
                        onTap: () => onNavigate('siswa_leave_status'),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.statusPendingBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.hourglass_top_rounded,
                                color: AppColors.statusSakit,
                                size: 21,
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
                                          'Pengajuan ${pendingRequests.first.type.label}',
                                          style:
                                              AppTypography.cardTitle.copyWith(
                                            fontSize: 14,
                                            color: AppColors.statusPendingText,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.statusPendingBg,
                                          borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusPill,
                                          ),
                                          border: Border.all(
                                            color: AppColors.statusSakit
                                                .withValues(alpha: 0.35),
                                          ),
                                        ),
                                        child: Text(
                                          'Pending',
                                          style:
                                              AppTypography.microBadge.copyWith(
                                            color: AppColors.statusPendingText,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    pendingRequests.first.reason,
                                    style: AppTypography.smallHint.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Lihat detail status verifikasi',
                                          style:
                                              AppTypography.microBadge.copyWith(
                                            color: AppColors.primaryIndigo,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 13,
                                        color: AppColors.primaryIndigo,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

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
