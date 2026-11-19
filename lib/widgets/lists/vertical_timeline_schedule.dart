import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../models/models.dart';

/// VerticalTimelineSchedule - Tampilan Jadwal Berbasis Garis Waktu Vertikal
/// Terinspirasi dari Referensi Task Manager & CareSync:
/// - Kolom kiri: Penanda jam pelajaran (07.00 - 08.30 WIB) & indeks sesi
/// - Garis vertikal & node status: Menghubungkan urutan jam pelajaran secara hierarkis
/// - Kartu kanan: Detail mapel, kelas, ruang belajar, dan tombol aksi langsung (Isi Jurnal)
class VerticalTimelineSchedule extends StatelessWidget {
  final List<TeachingSchedule> schedules;
  final String dayName;
  final String cycleLabel;
  final bool isTeacher;
  final CycleType? activeCycle;
  final String? todayDayName;
  final bool isCurrentCycleActive;
  final void Function(TeachingSchedule schedule)? onActionTap;
  final VoidCallback? onAddTap;

  const VerticalTimelineSchedule({
    super.key,
    required this.schedules,
    required this.dayName,
    required this.cycleLabel,
    this.isTeacher = false,
    this.activeCycle,
    this.todayDayName,
    this.isCurrentCycleActive = true,
    this.onActionTap,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.brandAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                size: 36,
                color: AppColors.brandPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak Ada Sesi Pelajaran',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Belum ada jadwal mengajar/belajar di hari $dayName ($cycleLabel).',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (isTeacher && onAddTap != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Tambah Jadwal Sekarang'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brandPrimary,
                  side: const BorderSide(color: AppColors.brandPrimary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: onAddTap,
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        final isLast = index == schedules.length - 1;

        final CycleType resolvedActiveCycle = activeCycle ?? schedule.cycle;
        final bool isCycleActive =
            isCurrentCycleActive && schedule.isCycleActive(resolvedActiveCycle);
        final String resolvedTodayName =
            (todayDayName != null && todayDayName!.trim().isNotEmpty)
                ? todayDayName!.trim()
                : TeachingSchedule.indonesianDayName(DateTime.now());
        final String effectiveDay =
            (schedule.day.trim().isNotEmpty && schedule.day.trim() != '-')
                ? schedule.day.trim()
                : dayName.trim();
        final bool isTodayDay =
            effectiveDay.toLowerCase() == resolvedTodayName.toLowerCase();

        final bool isExpired = !schedule.hasJournal &&
            isCycleActive &&
            (schedule.isExpired ||
                (!isTodayDay &&
                    schedule
                        .copyWith(day: effectiveDay)
                        .isExpiredSchedule()));
        final bool isFuture = !schedule.hasJournal &&
            isCycleActive &&
            !isExpired &&
            (schedule.isFuture ||
                !isTodayDay ||
                schedule.copyWith(day: effectiveDay).isFutureSchedule());
        final bool canFill = !schedule.hasJournal &&
            isCycleActive &&
            !isFuture &&
            !isExpired &&
            (schedule.canFillOverride ?? isTodayDay);

        // Status node color
        Color nodeColor = AppColors.brandPrimary;
        if (schedule.hasJournal) {
          nodeColor = AppColors.statusSuccess;
        } else if (!isCycleActive) {
          nodeColor = AppColors.textTertiary;
        } else if (isExpired) {
          nodeColor = AppColors.statusAlpa;
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. SISI KIRI: PENANDA WAKTU (JAM)
              SizedBox(
                width: 76,
                child: Padding(
                  padding: const EdgeInsets.only(top: 2, right: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        schedule.startTime,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        schedule.endTime,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.brandAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Sesi ${index + 1}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brandNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. TENGAH: GARIS & BULATAN TIMELINE
              SizedBox(
                width: 24,
                child: Column(
                  children: [
                    // Node Bulatan
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: nodeColor,
                          width: 3.5,
                        ),
                      ),
                    ),
                    // Garis Penghubung Vertikal
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: AppColors.border,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // 3. SISI KANAN: KARTU SESI JADWAL
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: schedule.hasJournal
                            ? AppColors.statusSuccess.withValues(alpha: 0.35)
                            : AppColors.border,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mapel Title & Cycle Tag
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                schedule.subjectName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.brandAccent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                schedule.cycle.label,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.brandNavy,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Badges: Kelas & Ruangan
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            // Kelas Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
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
                                    Icons.school_rounded,
                                    size: 13,
                                    color: AppColors.brandNavy,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    schedule.className,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Ruangan Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
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
                                    Icons.meeting_room_rounded,
                                    size: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    schedule.roomName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Info Guru (jika di tampilan siswa)
                        if (!isTeacher && schedule.teacherName.isNotEmpty && schedule.teacherName != '-') ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline_rounded,
                                size: 14,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  schedule.teacherName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],

                        // Action / Status Area (jika Guru)
                        if (isTeacher) ...[
                          const SizedBox(height: 10),
                          const Divider(height: 1, color: AppColors.border),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                // Status Jurnal (Kontras WCAG AA terverifikasi)
                              if (schedule.hasJournal)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.statusApprovedBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        size: 13,
                                        color: AppColors.statusApprovedText,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          'Jurnal Terisi',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.statusApprovedText,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else if (isExpired)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.statusRejectedBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.cancel_rounded,
                                        size: 13,
                                        color: AppColors.statusRejectedText,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          'Tidak Mengisi Jurnal',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.statusRejectedText,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.statusPendingBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    canFill ? 'Jurnal Belum Diisi' : 'Belum Diisi',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.statusPendingText,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                              // Kontrol Aksi atau Indikator Tanggal Jadwal (Non-interaktif jika belum waktunya)
                              if (canFill && onActionTap != null)
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () => onActionTap!(schedule),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.brandPrimary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              'Isi Jurnal',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 3),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 13,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              else if (!schedule.hasJournal && !isCycleActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.lock_clock_rounded,
                                        size: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          'Aktif saat ${schedule.cycle.label}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textSecondary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else if (!schedule.hasJournal && isExpired)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.lock_outline_rounded,
                                        size: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          'Waktu Lewat',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textSecondary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else if (!schedule.hasJournal && isFuture)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_rounded,
                                        size: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          'Diisi pada ${schedule.copyWith(day: effectiveDay).resolvedTargetDateLabel()}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textSecondary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

