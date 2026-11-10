import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_typography.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/cards/soft_card.dart';
import '../../widgets/cards/data_state_view.dart';
import '../../widgets/headers/header_with_gradient.dart';

class AcademicCalendarScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback? onBack;

  const AcademicCalendarScreen({
    super.key,
    required this.state,
    this.onBack,
  });

  @override
  State<AcademicCalendarScreen> createState() => _AcademicCalendarScreenState();
}

class _AcademicCalendarScreenState extends State<AcademicCalendarScreen> {
  late DateTime _selectedMonth;
  DateTime? _selectedDay;
  String _selectedFilter = 'Semua'; // 'Semua', 'Libur', 'Kegiatan'

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
    _selectedDay = DateTime(now.year, now.month, now.day);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEventsForMonth(_selectedMonth);
    });
  }

  Future<void> _loadEventsForMonth(DateTime month) async {
    await widget.state.fetchAcademicCalendarEvents(
      month: month.month,
      year: month.year,
    );
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
      _selectedDay = null;
    });
    _loadEventsForMonth(_selectedMonth);
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
      _selectedDay = null;
    });
    _loadEventsForMonth(_selectedMonth);
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _selectedMonth = DateTime(now.year, now.month, 1);
      _selectedDay = DateTime(now.year, now.month, now.day);
    });
    _loadEventsForMonth(_selectedMonth);
  }

  List<AcademicEventInfo> _filterEvents(List<AcademicEventInfo> events) {
    if (_selectedFilter == 'Libur') {
      return events.where((e) => e.isHoliday || e.disableKbm).toList();
    }
    if (_selectedFilter == 'Kegiatan') {
      return events.where((e) => !e.isHoliday && !e.disableKbm).toList();
    }
    return events;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _eventOccursOnDay(AcademicEventInfo event, DateTime day) {
    if (event.startDate == null) return false;
    final start = DateTime.tryParse(event.startDate!);
    if (start == null) return false;

    final end = event.endDate != null ? DateTime.tryParse(event.endDate!) : start;
    if (end == null) return false;

    final targetDate = DateTime(day.year, day.month, day.day);
    final startDateOnly = DateTime(start.year, start.month, start.day);
    final endDateOnly = DateTime(end.year, end.month, end.day);

    return (targetDate.isAtSameMomentAs(startDateOnly) || targetDate.isAfter(startDateOnly)) &&
        (targetDate.isAtSameMomentAs(endDateOnly) || targetDate.isBefore(endDateOnly));
  }

  Color _getEventColor(AcademicEventInfo event) {
    if (event.isHoliday) return AppColors.errorAlpa;
    if (event.disableKbm) return AppColors.warningSakit;
    return AppColors.secondaryTeal;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final events = widget.state.calendarEvents;
    final filteredEvents = _filterEvents(events);

    // Filter events for selected day if chosen
    final activeEventsForDay = _selectedDay != null
        ? filteredEvents.where((e) => _eventOccursOnDay(e, _selectedDay!)).toList()
        : <AcademicEventInfo>[];

    final monthLabel = DateFormat('MMMM yyyy', 'id_ID').format(_selectedMonth);
    final isCurrentMonth = _selectedMonth.year == now.year && _selectedMonth.month == now.month;

    final holidaysCount = events.where((e) => e.isHoliday || e.disableKbm).length;
    final activitiesCount = events.where((e) => !e.isHoliday && !e.disableKbm).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header With Gradient
          HeaderWithGradient(
            userName: 'Kalender Akademik',
            userSubtitle: 'Agenda Pembelajaran & Hari Libur Sekolah',
            leading: widget.onBack != null
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: widget.onBack,
                  )
                : null,
          ),

          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryIndigo,
              onRefresh: () => _loadEventsForMonth(_selectedMonth),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month Navigation Header
                    SoftCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm + 4,
                      ),
                      borderRadius: AppSpacing.radiusLarge,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textPrimary),
                            onPressed: _previousMonth,
                            tooltip: 'Bulan Sebelumnya',
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  monthLabel,
                                  style: AppTypography.cardTitle.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (!isCurrentMonth)
                                  GestureDetector(
                                    onTap: _goToToday,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        'Kembali ke Bulan Ini',
                                        style: AppTypography.microBadge.copyWith(
                                          color: AppColors.primaryIndigo,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textPrimary),
                            onPressed: _nextMonth,
                            tooltip: 'Bulan Selanjutnya',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Quick Summary Bar
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryPill(
                            label: 'Total Agenda',
                            count: events.length,
                            color: AppColors.primaryIndigo,
                            bgColor: AppColors.lightIndigoBg,
                            icon: Icons.event_note_rounded,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _buildSummaryPill(
                            label: 'Libur / Non-KBM',
                            count: holidaysCount,
                            color: AppColors.errorAlpa,
                            bgColor: AppColors.alertRedBg,
                            icon: Icons.event_busy_rounded,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _buildSummaryPill(
                            label: 'Kegiatan Siswa',
                            count: activitiesCount,
                            color: AppColors.secondaryTeal,
                            bgColor: AppColors.lightTealBg,
                            icon: Icons.celebration_rounded,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Calendar Grid Card
                    SoftCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      borderRadius: AppSpacing.radiusLarge,
                      child: Column(
                        children: [
                          _buildDaysOfWeekHeader(),
                          const SizedBox(height: 8),
                          const Divider(height: 1, color: AppColors.border),
                          const SizedBox(height: 8),
                          _buildCalendarMonthGrid(events),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Category Filter Pills
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterPill('Semua', events.length),
                          const SizedBox(width: AppSpacing.sm),
                          _buildFilterPill('Kegiatan', activitiesCount),
                          const SizedBox(width: AppSpacing.sm),
                          _buildFilterPill('Libur', holidaysCount),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Agenda Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDay != null
                                ? 'Agenda ${DateFormat('d MMMM yyyy', 'id_ID').format(_selectedDay!)}'
                                : 'Agenda Bulan Ini ($monthLabel)',
                            style: AppTypography.sectionTitle,
                          ),
                        ),
                        if (_selectedDay != null)
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => setState(() => _selectedDay = null),
                            child: const Text('Lihat Semua Bulan', style: TextStyle(fontSize: 12)),
                          ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Events List or Empty State
                    if (widget.state.isLoadingCalendarEvents) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 36),
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.primaryIndigo),
                        ),
                      ),
                    ] else if (widget.state.calendarEventsError != null) ...[
                      DataErrorCard(
                        title: 'Gagal Memuat Kalender',
                        message: widget.state.calendarEventsError!,
                        onRetry: () => _loadEventsForMonth(_selectedMonth),
                      ),
                    ] else if (_selectedDay != null && activeEventsForDay.isEmpty) ...[
                      _buildEmptyDayState(),
                    ] else if (_selectedDay == null && filteredEvents.isEmpty) ...[
                      _buildEmptyMonthState(),
                    ] else ...[
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedDay != null
                            ? activeEventsForDay.length
                            : filteredEvents.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final event = _selectedDay != null
                              ? activeEventsForDay[index]
                              : filteredEvents[index];
                          return _buildEventCard(event);
                        },
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPill({
    required String label,
    required int count,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: AppTypography.cardTitle.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: AppTypography.microBadge.copyWith(
              fontSize: 10,
              color: color.withOpacity(0.85),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDaysOfWeekHeader() {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return Row(
      children: days.map((day) {
        final bool isSunday = day == 'Min';
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: AppTypography.microBadge.copyWith(
                fontWeight: FontWeight.w700,
                color: isSunday ? AppColors.errorAlpa : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarMonthGrid(List<AcademicEventInfo> events) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;

    // Monday is 1, Sunday is 7 in Dart DateTime
    final startingWeekday = firstDayOfMonth.weekday; // 1 (Mon) - 7 (Sun)
    final leadingEmptyBoxes = startingWeekday - 1;

    final totalGridCells = ((leadingEmptyBoxes + daysInMonth + 6) ~/ 7) * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalGridCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        final dayNumber = index - leadingEmptyBoxes + 1;

        if (index < leadingEmptyBoxes || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }

        final cellDate = DateTime(_selectedMonth.year, _selectedMonth.month, dayNumber);
        final bool isToday = _isSameDay(cellDate, now);
        final bool isSelected = _selectedDay != null && _isSameDay(cellDate, _selectedDay!);
        final bool isSunday = cellDate.weekday == DateTime.sunday;

        // Find events on this date
        final dayEvents = events.where((e) => _eventOccursOnDay(e, cellDate)).toList();
        final bool hasHoliday = dayEvents.any((e) => e.isHoliday || e.disableKbm);
        final bool hasEvent = dayEvents.isNotEmpty;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedDay = cellDate;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryIndigo
                  : isToday
                      ? AppColors.lightIndigoBg
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isToday && !isSelected
                  ? Border.all(color: AppColors.primaryIndigo, width: 1.5)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$dayNumber',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : isSunday || hasHoliday
                            ? AppColors.errorAlpa
                            : AppColors.textPrimary,
                  ),
                ),
                if (hasEvent) ...[
                  const SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: dayEvents.take(3).map((e) {
                      final dotColor = isSelected ? Colors.white : _getEventColor(e);
                      return Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterPill(String title, int count) {
    final bool isSelected = _selectedFilter == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryIndigo : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(
            color: isSelected ? AppColors.primaryIndigo : AppColors.border,
          ),
        ),
        child: Text(
          '$title ($count)',
          style: AppTypography.microBadge.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 11.5,
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(AcademicEventInfo event) {
    final bool isHolidayOrNonKbm = event.isHoliday || event.disableKbm;
    final color = _getEventColor(event);
    final bgColor = isHolidayOrNonKbm ? AppColors.alertRedBg : AppColors.lightTealBg;

    // Date range display
    String dateRangeLabel = event.startDate ?? '-';
    if (event.startDate != null) {
      final s = DateTime.tryParse(event.startDate!);
      if (s != null) {
        if (event.endDate != null && event.endDate != event.startDate) {
          final e = DateTime.tryParse(event.endDate!);
          if (e != null) {
            dateRangeLabel = '${DateFormat('d MMM', 'id_ID').format(s)} - ${DateFormat('d MMM yyyy', 'id_ID').format(e)}';
          } else {
            dateRangeLabel = DateFormat('d MMMM yyyy', 'id_ID').format(s);
          }
        } else {
          dateRangeLabel = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(s);
        }
      }
    }

    return SoftCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppSpacing.radiusLarge,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Icon(
              event.isHoliday
                  ? Icons.event_busy_rounded
                  : event.disableKbm
                      ? Icons.pause_circle_outline_rounded
                      : Icons.event_available_rounded,
              color: color,
              size: 22,
            ),
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
                        event.title,
                        style: AppTypography.cardTitle.copyWith(fontSize: 14),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                      ),
                      child: Text(
                        event.categoryLabel,
                        style: AppTypography.microBadge.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        dateRangeLabel,
                        style: AppTypography.smallHint.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (event.description != null && event.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    event.description!.trim(),
                    style: AppTypography.smallHint.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
                if (event.isHoliday || event.disableKbm) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.alertAmberBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      event.isHoliday ? '• Libur Resmi Sekolah' : '• Kegiatan Non-KBM Normal',
                      style: AppTypography.microBadge.copyWith(
                        color: AppColors.warningSakit,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDayState() {
    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.event_available_outlined, size: 40, color: AppColors.secondaryTeal),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tidak Ada Agenda Khusus',
              style: AppTypography.cardTitle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              'Kegiatan Belajar Mengajar (KBM) berjalan normal sesuai jadwal.',
              style: AppTypography.smallHint.copyWith(color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMonthState() {
    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.calendar_month_outlined, size: 42, color: AppColors.primaryIndigo),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Belum Ada Agenda Terjadwal',
              style: AppTypography.cardTitle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              'Tidak ada kegiatan khusus atau libur pada bulan ini.',
              style: AppTypography.smallHint.copyWith(color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
