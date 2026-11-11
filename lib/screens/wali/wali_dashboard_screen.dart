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
import '../../widgets/buttons/pill_button.dart';
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
    final availableClasses = state.assignedClassrooms;
    final targetClassLabel = user.className.isNotEmpty
        ? user.className
        : (isBk ? 'Semua Kelas' : 'Kelas Binaan');

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
            state.fetchHomeroomDashboardData(),
            state.fetchHomeroomLeavesData(),
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
                userSubtitle: '$roleTitle • ${user.identifier}',
                avatarUrl: user.avatarUrl,
                badgeText: '${state.activeCycle.label} Aktif',
                secondaryBadgeText: isBk
                    ? (availableClasses.isNotEmpty
                        ? 'BK: ${availableClasses.length} Kelas Binaan'
                        : 'Bimbingan Konseling')
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
                        onRetry: () {
                          state.fetchHomeroomDashboardData();
                          state.fetchTeacherDashboardData();
                        },
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

                    // 2. ALERT JURNAL MENGAJAR TERLAMBAT (>30 menit)
                    if (!isBk && delayedAlerts.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Builder(
                        builder: (context) {
                          final alert = delayedAlerts.first;
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: AppColors.statusRejectedBg.withValues(alpha: 0.75),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusLarge),
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
                                        color: AppColors.statusAlpa
                                            .withValues(alpha: 0.14),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Jurnal mengajar belum diisi',
                                                  style: AppTypography.cardTitle
                                                      .copyWith(
                                                    color: AppColors
                                                        .statusRejectedText,
                                                    fontSize: 14.5,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 7,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.statusAlpa,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    AppSpacing.radiusPill,
                                                  ),
                                                ),
                                                child: Text(
                                                  '+${alert.minutesLate}m',
                                                  style: AppTypography.microBadge
                                                      .copyWith(
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
                                            style: AppTypography.cardTitle
                                                .copyWith(
                                              color: AppColors.textPrimary,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Kelas ${alert.className} • ${alert.roomName} (${alert.timeSlot})',
                                            style: AppTypography.smallHint
                                                .copyWith(
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
                                    onPressed: () {
                                      final match = state.todaySchedules
                                          .where((s) => s.id == alert.scheduleId)
                                          .firstOrNull;
                                      if (match != null) {
                                        state.selectScheduleForJournal(match);
                                      }
                                      onNavigate('guru_journal_input');
                                    },
                                    icon: const Icon(Icons.edit_note_rounded,
                                        size: 19),
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
                    ],

                    const SizedBox(height: AppSpacing.lg),

                    // 3. RINGKASAN KEHADIRAN KELAS BINAAN (Donut Chart)
                    if (isBk && availableClasses.length > 1) ...[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: AppSpacing.sm),
                              child: PillButton(
                                label: 'Semua Kelas',
                                isActive: state.selectedHomeroomClassroomId == null,
                                activeColor: AppColors.primaryIndigo,
                                onPressed: () => state.selectHomeroomClassroom(null),
                              ),
                            ),
                            ...availableClasses.map((cls) {
                              final isSelected = state.selectedHomeroomClassroomId != null &&
                                  state.selectedHomeroomClassroomId.toString() == cls.id.toString();

                              return Padding(
                                padding: const EdgeInsets.only(right: AppSpacing.sm),
                                child: PillButton(
                                  label: cls.name,
                                  isActive: isSelected,
                                  activeColor: AppColors.primaryIndigo,
                                  onPressed: () => state.selectHomeroomClassroom(cls.id),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    if (state.isLoadingDashboard && summary.totalStudents == 0)
                      const DataLoadingCard(
                        message: 'Memuat data presensi kelas binaan...',
                      )
                    else
                      Builder(
                        builder: (context) {
                          final selectedCls = isBk
                              ? availableClasses
                                  .where((c) =>
                                      c.id.toString() ==
                                      state.selectedHomeroomClassroomId?.toString())
                                  .firstOrNull
                              : null;
                          final classLabel = isBk
                              ? (selectedCls != null
                                  ? 'Kelas ${selectedCls.name}'
                                  : 'Semua Kelas Binaan')
                              : targetClassLabel;

                          return AttendanceDonutCard(
                            title: 'Ringkasan Kehadiran Kelas',
                            subtitle:
                                'Monitoring Presensi $classLabel Hari Ini (${summary.percentage.toStringAsFixed(1)}%)',
                            totalStudents: summary.totalStudents > 0
                                ? summary.totalStudents
                                : null,
                            hadirCount: summary.hadir,
                            sakitCount: summary.sakit,
                            izinCount: summary.izin,
                            alpaCount: summary.alpa,
                            onTapDetail: () => onNavigate('wali_students'),
                          );
                        },
                      ),

                    const SizedBox(height: AppSpacing.lg),

                    // 4. CARD PENGAJUAN IZIN PENDING
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

                    // 5. RINGKASAN JADWAL MENGAJAR GURU (Wali Kelas & Guru BK)
                    const SizedBox(height: AppSpacing.lg),
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
                                      'Rekap sesi pembelajaran Anda hari ini (${state.activeCycle.label})',
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

                    // 6. AKSES CEPAT (Menu Grid Terintegrasi)
                    MenuGrid(
                      sectionTitle: 'Akses Cepat',
                      items: [
                        MenuItemData(
                          label: 'Isi Jurnal',
                          icon: Icons.edit_document,
                          iconColor: AppColors.secondaryTeal,
                          bgColor: AppColors.lightTealBg,
                          badge: unfilledCount > 0 ? '$unfilledCount' : null,
                          onTap: () {
                            final unfilled = activeSchedules
                                .where((s) => !s.hasJournal)
                                .firstOrNull;
                            if (unfilled != null) {
                              state.selectScheduleForJournal(unfilled);
                            }
                            onNavigate('guru_journal_input');
                          },
                        ),
                        MenuItemData(
                          label: 'Jadwal Mengajar',
                          icon: Icons.calendar_month_rounded,
                          iconColor: AppColors.brandPrimary,
                          bgColor: AppColors.brandAccent,
                          onTap: () => onNavigate('guru_my_schedule'),
                        ),
                        MenuItemData(
                          label: 'Riwayat Jurnal',
                          icon: Icons.history_edu_rounded,
                          iconColor: AppColors.brandPrimary,
                          bgColor: AppColors.brandAccent,
                          onTap: () => onNavigate('guru_journal_history'),
                        ),
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

                    // 7. JADWAL MENGAJAR HARI INI (Wali Kelas & Guru BK)
                    const SizedBox(height: AppSpacing.xl),
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

                      if (activeSchedules.isEmpty)
                        SoftCard(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'Tidak ada jadwal mengajar untuk Anda hari ini (${state.activeCycle.label}).',
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
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
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
                                                    style: AppTypography
                                                        .microBadge
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
                                              style: AppTypography.smallHint
                                                  .copyWith(
                                                color: AppColors.textSecondary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${s.day}, ${s.startTime} - ${s.endTime} WIB',
                                              style: AppTypography.smallHint
                                                  .copyWith(
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
                                            onPressed: () => onNavigate(
                                                'guru_journal_history'),
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
                                            onPressed: () {
                                              state.selectScheduleForJournal(s);
                                              onNavigate('guru_journal_input');
                                            },
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

                    const SizedBox(height: AppSpacing.xl),

                    // 8. INFORMASI AKTIVITAS TERBARU (Perizinan Masuk)
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
