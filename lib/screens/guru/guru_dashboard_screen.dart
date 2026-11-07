import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../constants/app_spacing.dart';
import '../../state/app_state.dart';
import '../../widgets/headers/header_with_gradient.dart';
import '../../widgets/cards/soft_card.dart';
import '../../widgets/cards/data_state_view.dart';
import '../../widgets/menu_grid.dart';

class GuruDashboardScreen extends StatelessWidget {
  final AppState state;
  final Function(String routeName) onNavigate;

  const GuruDashboardScreen({
    super.key,
    required this.state,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final user = state.currentUser;
    final activeSchedules = state.activeCycleSchedules;
    final totalSchedules = state.totalTodaySchedulesCount;
    final filledCount = state.filledJournalsTodayCount;
    final unfilledCount = state.unfilledJournalsTodayCount;
    final delayedAlerts = state.delayedJournalAlerts;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primaryIndigo,
        onRefresh: () async {
          await Future.wait([
            state.fetchTeacherDashboardData(),
            state.fetchTeacherSchedulesData(),
            state.fetchTeacherJournalsData(),
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
                userSubtitle: '${user.className} • ${user.identifier}',
                avatarUrl: user.avatarUrl,
                badgeText: '${state.activeCycle.label} Aktif',
                secondaryBadgeText: '${state.currentTimeLabel} WIB',
                secondaryBadgeIcon: Icons.access_time_filled_rounded,
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
                        onRetry: () => state.fetchTeacherDashboardData(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  // 2. CARD INFORMASI JADWAL MENGAJAR
                  SoftCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    borderRadius: AppSpacing.radiusLarge,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Informasi Jadwal Mengajar',
                                    style: AppTypography.cardTitle.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Rekap sesi pembelajaran hari ini (${state.activeCycle.label})',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.lightIndigoBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.cast_for_education_rounded,
                                size: 20,
                                color: AppColors.primaryIndigo,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildScheduleStatBox(
                                label: 'Jadwal Hari Ini',
                                count: totalSchedules,
                                color: AppColors.primaryIndigo,
                                bgColor: AppColors.lightIndigoBg,
                                icon: Icons.event_note_rounded,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildScheduleStatBox(
                                label: 'Sudah Diisi',
                                count: filledCount,
                                color: AppColors.statusHadir,
                                bgColor: AppColors.alertGreenBg,
                                icon: Icons.task_alt_rounded,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildScheduleStatBox(
                                label: 'Belum Diisi',
                                count: unfilledCount,
                                color: AppColors.statusSakit,
                                bgColor: AppColors.alertAmberBg,
                                icon: Icons.pending_actions_rounded,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // 3. ALERT JURNAL TERLAMBAT (>30 menit dan jurnal belum diisi)
                  if (delayedAlerts.isNotEmpty) ...[
                    Builder(
                      builder: (context) {
                        final alert = delayedAlerts.first;
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.statusRejectedBg.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                            border: Border.all(
                              color: AppColors.statusAlpa.withValues(alpha: 0.45),
                              width: 1.2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A0F172A),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: AppColors.statusAlpa.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.notification_important_rounded,
                                      color: AppColors.statusAlpa,
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
                                                'Jurnal mengajar belum diisi',
                                                style: AppTypography.cardTitle.copyWith(
                                                  color: AppColors.statusRejectedText,
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 7,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.statusAlpa,
                                                borderRadius: BorderRadius.circular(
                                                  AppSpacing.radiusPill,
                                                ),
                                              ),
                                              child: Text(
                                                '+${alert.minutesLate}m',
                                                style: AppTypography.microBadge.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          alert.subjectName,
                                          style: AppTypography.cardTitle.copyWith(
                                            color: AppColors.textPrimary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Kelas ${alert.className} • ${alert.roomName} (${alert.timeSlot})',
                                          style: AppTypography.smallHint.copyWith(
                                            color: AppColors.textSecondary,
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
                                    backgroundColor: AppColors.statusAlpa,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => onNavigate('guru_journal_input'),
                                  icon: const Icon(Icons.edit_note_rounded, size: 19),
                                  label: Text(
                                    'Isi Jurnal Sekarang',
                                    style: AppTypography.labelButton.copyWith(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // 4. AKSES CEPAT (Grid 4 Menu — Tambah Jadwal non-aktif bila dikunci Waka Kurikulum)
                  MenuGrid(
                    sectionTitle: 'Akses Cepat',
                    items: [
                      MenuItemData(
                        label: 'Jadwal Mengajar',
                        icon: Icons.calendar_month_rounded,
                        iconColor: AppColors.primaryIndigo,
                        bgColor: AppColors.lightIndigoBg,
                        onTap: () => onNavigate('guru_my_schedule'),
                      ),
                      MenuItemData(
                        label: 'Isi Jurnal',
                        icon: Icons.edit_document,
                        iconColor: AppColors.secondaryTeal,
                        bgColor: AppColors.lightTealBg,
                        badge: unfilledCount > 0 ? '$unfilledCount' : null,
                        onTap: () => onNavigate('guru_journal_input'),
                      ),
                      MenuItemData(
                        label: 'Riwayat Jurnal',
                        icon: Icons.history_edu_rounded,
                        iconColor: AppColors.primaryIndigo,
                        bgColor: AppColors.lightIndigoBg,
                        onTap: () => onNavigate('guru_journal_history'),
                      ),
                      MenuItemData(
                        label: state.isScheduleLocked
                            ? 'Jadwal Dikunci'
                            : 'Tambah Jadwal',
                        icon: Icons.post_add_rounded,
                        iconColor: AppColors.secondaryTeal,
                        bgColor: AppColors.lightTealBg,
                        isLocked: state.isScheduleLocked,
                        onTap: state.isScheduleLocked
                            ? null
                            : () => onNavigate('guru_schedule_input'),
                      ),
                    ],
                  ),

                  if (state.isScheduleLocked) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.statusPendingBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.alertAmberBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lock_clock_rounded,
                            size: 16,
                            color: AppColors.statusPendingText,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Penambahan jadwal dinonaktifkan karena jadwal sedang dikunci oleh Waka Kurikulum.',
                              style: AppTypography.microBadge.copyWith(
                                color: AppColors.statusPendingText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  // 5. JADWAL MENGAJAR HARI INI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Jadwal Mengajar Hari Ini',
                          style: AppTypography.sectionTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: () => onNavigate('guru_my_schedule'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Semua Jadwal ›',
                          style: AppTypography.smallHint.copyWith(
                            color: AppColors.primaryIndigo,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  if (activeSchedules.isEmpty)
                    SoftCard(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'Tidak ada jadwal mengajar pada siklus ini.',
                            style: AppTypography.smallHint,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activeSchedules.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final s = activeSchedules[index];
                        final bool isFilled = s.hasJournal;

                        return SoftCard(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          borderRadius: AppSpacing.radiusLarge,
                          border: !isFilled
                              ? Border.all(
                                  color: AppColors.statusSakit
                                      .withValues(alpha: 0.55),
                                  width: 1.2,
                                )
                              : null,
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
                                      color: isFilled
                                          ? AppColors.alertGreenBg
                                          : AppColors.alertAmberBg,
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: Icon(
                                      isFilled
                                          ? Icons.fact_check_rounded
                                          : Icons.menu_book_rounded,
                                      color: isFilled
                                          ? AppColors.statusHadir
                                          : AppColors.statusSakit,
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
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            // Badge Sudah Terisi / Belum Diisi
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 9,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isFilled
                                                    ? AppColors.statusApprovedBg
                                                    : AppColors.statusPendingBg,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  AppSpacing.radiusPill,
                                                ),
                                              ),
                                              child: Text(
                                                isFilled
                                                    ? 'Sudah Terisi'
                                                    : 'Belum Diisi',
                                                style: AppTypography.microBadge
                                                    .copyWith(
                                                  color: isFilled
                                                      ? AppColors
                                                          .statusApprovedText
                                                      : AppColors
                                                          .statusPendingText,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Kelas ${s.className} • ${s.roomName}',
                                          style:
                                              AppTypography.smallHint.copyWith(
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${s.day}, ${s.startTime} - ${s.endTime} WIB',
                                          style:
                                              AppTypography.smallHint.copyWith(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 40,
                                child: isFilled
                                    ? OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: AppColors.border,
                                          ),
                                          foregroundColor:
                                              AppColors.textSecondary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(11),
                                          ),
                                        ),
                                        onPressed: () =>
                                            onNavigate('guru_journal_history'),
                                        icon: const Icon(
                                          Icons.check_circle_outline_rounded,
                                          size: 16,
                                          color: AppColors.statusHadir,
                                        ),
                                        label: Text(
                                          'Lihat Riwayat Jurnal',
                                          style: AppTypography.microBadge
                                              .copyWith(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      )
                                    : ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryIndigo,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(11),
                                          ),
                                        ),
                                        onPressed: () =>
                                            onNavigate('guru_journal_input'),
                                        icon: const Icon(
                                          Icons.edit_note_rounded,
                                          size: 18,
                                        ),
                                        label: Text(
                                          'Isi Jurnal & Presensi Kelas',
                                          style: AppTypography.microBadge
                                              .copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
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

  Widget _buildScheduleStatBox({
    required String label,
    required int count,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$count',
                style: AppTypography.tabularFigure.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1.0,
                ),
              ),
              Icon(icon, size: 16, color: color.withValues(alpha: 0.85)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTypography.microBadge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 10.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
