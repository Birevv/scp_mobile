import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../models/models.dart';

/// TodayInfoCard - Dual Widget Layar Beranda SCP
/// Sisi Kiri: Jam Digital Real-time (WIB / Waktu Lokal) dengan tema gelap modern & indikator siang/malam.
/// Sisi Kanan: Status Event Sekolah:
/// - Jika ada event sedang berlangsung hari ini (misal UKK): menampilkan status event UKK aktif.
/// - Jika tidak ada event hari ini: menampilkan hitung mundur (countdown) ke event terdekat (misal Ujian Sekolah).
/// - Jika belum dikonfigurasi: menampilkan status kalender jujur tanpa manipulasi.
class TodayInfoCard extends StatefulWidget {
  final String formattedDate;
  final AcademicEventInfo todayEvent;
  final CycleType activeCycle;
  final List<AcademicEventInfo>? calendarEvents;
  final AcademicEventInfo? upcomingEvent;
  final VoidCallback? onTapCalendarStatus;

  const TodayInfoCard({
    super.key,
    required this.formattedDate,
    required this.todayEvent,
    required this.activeCycle,
    this.calendarEvents,
    this.upcomingEvent,
    this.onTapCalendarStatus,
  });

  @override
  State<TodayInfoCard> createState() => _TodayInfoCardState();
}

class _TodayInfoCardState extends State<TodayInfoCard> {
  late DateTime _currentTime;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  /// Memeriksa apakah ada event yang sedang aktif berlangsung hari ini
  bool get _isOngoingEvent {
    // 1. Jika todayEvent terkonfigurasi dan bukan sekadar KBM biasa / unconfigured
    if (widget.todayEvent.isConfigured &&
        widget.todayEvent.category != 'unconfigured' &&
        widget.todayEvent.category != 'effective_day') {
      return true;
    }

    // 2. Cek list calendarEvents apakah hari ini berada dalam rentang startDate s/d endDate
    if (widget.calendarEvents != null && widget.calendarEvents!.isNotEmpty) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      for (final event in widget.calendarEvents!) {
        if (event.startDate == null) continue;
        final start = DateTime.tryParse(event.startDate!);
        if (start == null) continue;
        final end = event.endDate != null ? DateTime.tryParse(event.endDate!) : start;
        if (end == null) continue;

        final sDate = DateTime(start.year, start.month, start.day);
        final eDate = DateTime(end.year, end.month, end.day);

        if (!today.isBefore(sDate) && !today.isAfter(eDate)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Mengambil data event yang sedang berlangsung hari ini
  AcademicEventInfo? get _activeEvent {
    if (widget.todayEvent.isConfigured &&
        widget.todayEvent.category != 'unconfigured' &&
        widget.todayEvent.category != 'effective_day') {
      return widget.todayEvent;
    }

    if (widget.calendarEvents != null && widget.calendarEvents!.isNotEmpty) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      for (final event in widget.calendarEvents!) {
        if (event.startDate == null) continue;
        final start = DateTime.tryParse(event.startDate!);
        if (start == null) continue;
        final end = event.endDate != null ? DateTime.tryParse(event.endDate!) : start;
        if (end == null) continue;

        final sDate = DateTime(start.year, start.month, start.day);
        final eDate = DateTime(end.year, end.month, end.day);

        if (!today.isBefore(sDate) && !today.isAfter(eDate)) {
          return event;
        }
      }
    }

    return null;
  }

  /// Menemukan event mendatang terdekat untuk hitung mundur (countdown)
  AcademicEventInfo? get _resolvedUpcomingEvent {
    if (widget.upcomingEvent != null) return widget.upcomingEvent;

    if (widget.calendarEvents != null && widget.calendarEvents!.isNotEmpty) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      AcademicEventInfo? closest;
      int? minDays;

      for (final event in widget.calendarEvents!) {
        if (event.startDate == null) continue;
        final start = DateTime.tryParse(event.startDate!);
        if (start == null) continue;

        final sDate = DateTime(start.year, start.month, start.day);
        if (sDate.isAfter(today)) {
          final diff = sDate.difference(today).inDays;
          if (minDays == null || diff < minDays) {
            minDays = diff;
            closest = event;
          }
        }
      }
      return closest;
    }

    return null;
  }

  /// Menghitung sisa hari menuju event mendatang
  int? get _daysUntilUpcoming {
    final upcoming = _resolvedUpcomingEvent;
    if (upcoming == null || upcoming.startDate == null) return null;
    final start = DateTime.tryParse(upcoming.startDate!);
    if (start == null) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(start.year, start.month, start.day);
    return targetDate.difference(today).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Baris Header: Label Informasi & Indikator Siklus Blok (Putaran 1 / Putaran 2)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Informasi & Agenda Hari Ini',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Active Cycle Pill Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                    size: 12,
                    color: AppColors.secondaryTeal,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.activeCycle.label,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.secondaryTeal,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Dua Kartu Berdampingan (Dual Cards): Sisi Kiri Jam, Sisi Kanan Event UKK / Countdown
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SISI KIRI: JAM DIGITAL REAL-TIME (Dark Card)
              Expanded(
                child: _buildDigitalClockCard(),
              ),

              const SizedBox(width: 10),

              // SISI KANAN: EVENT UKK / COUNTDOWN / KALENDER (Light Card)
              Expanded(
                child: _buildEventCard(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// KARTU KIRI: Widget Jam Digital Real-Time
  /// Desain gelap premium terinspirasi dari widget dual-clock mobile, dilengkapi indikator siang/malam.
  Widget _buildDigitalClockCard() {
    final hour = _currentTime.hour;
    final isDayTime = hour >= 6 && hour < 18;
    final hoursStr = _currentTime.hour.toString().padLeft(2, '0');
    final minutesStr = _currentTime.minute.toString().padLeft(2, '0');
    final secondsStr = _currentTime.second.toString().padLeft(2, '0');

    // Tanggal singkat format Indonesia (contoh: "Sel, 10 Nov")
    String shortDate;
    try {
      shortDate = DateFormat('EEE, d MMM', 'id_ID').format(_currentTime);
    } catch (_) {
      const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];
      final dayName = days[(_currentTime.weekday - 1) % 7];
      final monthName = months[(_currentTime.month - 1) % 12];
      shortDate = '$dayName, ${_currentTime.day} $monthName';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryIndigo,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryIndigo.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header Kiri: Nama Lokasi / Zona Waktu & Ikon Cuaca / Waktu (Bulan / Matahari)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Jakarta',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFC7D2FE), // Lavender soft indigo
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                isDayTime ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                size: 16,
                color: const Color(0xFFFBBF24), // Gold amber
              ),
            ],
          ),

          // Subtitle: Hari & Tanggal Singkat
          Text(
            shortDate,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFA5B4FC), // Indigo muda
            ),
          ),

          const SizedBox(height: 6),

          // Jam Digital Besar (Menit & Detik Berjalan Real-time)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$hoursStr.$minutesStr',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  ':$secondsStr',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFA5B4FC),
                  ),
                ),
              ],
            ),
          ),

          // Micro label: Waktu Standar Indonesia
          Text(
            'Waktu Standar WIB',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  /// KARTU KANAN: Widget Event UKK / Countdown Event Mendatang
  /// Menampilkan event berlangsung (UKK) atau hitung mundur ke event berikutnya.
  Widget _buildEventCard() {
    final bool isUnconfigured = !widget.todayEvent.isConfigured;
    final ongoingEvent = _activeEvent;
    final upcomingEvent = _resolvedUpcomingEvent;
    final daysUntil = _daysUntilUpcoming;

    // Menentukan Status Tampilan
    final String categoryText;
    final String titleText;
    final String bigDisplayText;
    final String captionText;
    final IconData statusIcon;

    if (_isOngoingEvent && ongoingEvent != null) {
      // 1. EVENT SEDANG BERLANGSUNG HARI INI (MISAL: UKK, Ujian, Libur)
      categoryText = ongoingEvent.categoryLabel.isNotEmpty
          ? ongoingEvent.categoryLabel
          : 'Event Aktif';
      titleText = ongoingEvent.title;
      statusIcon = Icons.wb_sunny_rounded;

      // Jika judul mengandung "UKK", prioritaskan teks UKK besar
      if (titleText.toUpperCase().contains('UKK')) {
        bigDisplayText = 'UKK';
      } else if (ongoingEvent.statusLabel != null && ongoingEvent.statusLabel!.isNotEmpty) {
        bigDisplayText = ongoingEvent.statusLabel!;
      } else if (ongoingEvent.isHoliday) {
        bigDisplayText = 'Hari Libur';
      } else if (ongoingEvent.disableKbm) {
        bigDisplayText = 'Non-KBM';
      } else {
        bigDisplayText = 'Hari Ke-1';
      }
      captionText = ongoingEvent.isHoliday
          ? 'Libur Sekolah'
          : (ongoingEvent.disableKbm ? 'Kegiatan Non-KBM' : 'Sedang Berlangsung');
    } else if (upcomingEvent != null && daysUntil != null) {
      // 2. HITUNG MUNDUR KE EVENT YANG AKAN DATANG (MISAL: Ujian Sekolah tinggal berapa hari)
      categoryText = 'Hitung Mundur';
      titleText = upcomingEvent.title;
      bigDisplayText = '$daysUntil Hari';
      captionText = 'Tinggal $daysUntil hari lagi';
      statusIcon = Icons.hourglass_top_rounded;
    } else if (!isUnconfigured) {
      // 3. HARI SEKOLAH EFEKTIF (KBM NORMAL)
      categoryText = widget.todayEvent.categoryLabel.isNotEmpty
          ? widget.todayEvent.categoryLabel
          : 'Agenda Sekolah';
      titleText = widget.todayEvent.title;
      bigDisplayText = 'KBM Aktif';
      captionText = widget.todayEvent.statusLabel ?? 'Kegiatan Sekolah';
      statusIcon = Icons.event_available_rounded;
    } else {
      // 4. BELUM DIKONFIGURASI (EMPTY / UNCONFIGURED STATE)
      categoryText = widget.todayEvent.categoryLabel;
      titleText = widget.todayEvent.title;
      bigDisplayText = widget.todayEvent.statusLabel ?? 'Belum Dikonfigurasi';
      captionText = 'Ketuk untuk lihat kalender';
      statusIcon = Icons.event_note_outlined;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      elevation: 0,
      child: InkWell(
        onTap: widget.onTapCalendarStatus,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primaryIndigo,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryIndigo.withValues(alpha: 0.22),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header Kanan: Kategori Event & Ikon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      categoryText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFC7D2FE),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    statusIcon,
                    size: 16,
                    color: const Color(0xFFFBBF24),
                  ),
                ],
              ),

              // Subtitle: Nama Event Lengkap / Status
              Text(
                titleText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFA5B4FC),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 6),

              // Tampilan Angka / Teks Besar (misal UKK atau "5 Hari")
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  bigDisplayText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: bigDisplayText.length > 10 ? 16 : 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Caption Status / Keterangan Waktu
              Text(
                captionText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
