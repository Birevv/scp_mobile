import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../constants/app_spacing.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/headers/scp_page_header.dart';
import '../../widgets/navigation/horizontal_date_strip.dart';
import '../../widgets/lists/vertical_timeline_schedule.dart';

class SiswaScheduleScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback? onBack;

  const SiswaScheduleScreen({
    super.key,
    required this.state,
    this.onBack,
  });

  @override
  State<SiswaScheduleScreen> createState() => _SiswaScheduleScreenState();
}

class _SiswaScheduleScreenState extends State<SiswaScheduleScreen> {
  String _selectedDay = 'Senin';
  CycleType? _selectedCycle;

  @override
  void initState() {
    super.initState();
    _selectedDay = _getInitialDay();
    _selectedCycle = widget.state.activeCycle;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchedules();
    });
  }

  String _getInitialDay() {
    final now = DateTime.now();
    switch (now.weekday) {
      case DateTime.monday:
        return 'Senin';
      case DateTime.tuesday:
        return 'Selasa';
      case DateTime.wednesday:
        return 'Rabu';
      case DateTime.thursday:
        return 'Kamis';
      case DateTime.friday:
        return 'Jumat';
      default:
        return 'Senin';
    }
  }

  Future<void> _loadSchedules([CycleType? cycle]) async {
    await widget.state.fetchStudentSchedulesData(cycle: cycle);
    if (mounted && cycle == null) {
      setState(() {
        _selectedCycle = widget.state.activeCycle;
      });
    }
  }

  void _onCycleSelected(CycleType cycle) {
    setState(() {
      _selectedCycle = cycle;
    });
    _loadSchedules(cycle);
  }

  @override
  Widget build(BuildContext context) {
    final currentCycle = _selectedCycle ?? widget.state.activeCycle;
    final isCurrentSystemActive = currentCycle == widget.state.activeCycle;
    final schedules = widget.state.teachingSchedules
        .where((s) {
          if (s.day.toLowerCase() != _selectedDay.toLowerCase()) return false;
          return s.cycle == currentCycle ||
              widget.state.teachingSchedules.every((item) => item.cycle == s.cycle);
        })
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Standardized SCP Page Header
          ScpPageHeader(
            title: 'Jadwal Pelajaran',
            studentName: widget.state.currentUser.name,
            className: widget.state.currentUser.className,
            cycleLabel: currentCycle.label,
            showCycleBadge: true,
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
              onRefresh: () => _loadSchedules(currentCycle),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selector Putaran Pembelajaran (Auto-Sync Website + Opsi Putaran 1 & 2)
                    Row(
                      children: CycleType.values.map((cycle) {
                        final isSelected = currentCycle == cycle;
                        final isSystemActive = widget.state.activeCycle == cycle;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: cycle == CycleType.values.first ? 6 : 0,
                              left: cycle == CycleType.values.last ? 6 : 0,
                            ),
                            child: InkWell(
                              onTap: () => _onCycleSelected(cycle),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.brandPrimary : Colors.white,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                                  border: Border.all(
                                    color: isSelected ? AppColors.brandPrimary : AppColors.border,
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.brandPrimary.withValues(alpha: 0.22),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        cycle.label,
                                        style: AppTypography.cardTitle.copyWith(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected ? Colors.white : AppColors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isSystemActive) ...[
                                      const SizedBox(width: 5),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.white.withValues(alpha: 0.22)
                                              : AppColors.statusApprovedBg,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.white.withValues(alpha: 0.4)
                                                : AppColors.statusSuccess.withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Text(
                                          'Aktif',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected
                                                ? Colors.white
                                                : AppColors.statusApprovedText,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Indikator Siklus Putaran Aktif (Otomatis dari Sistem / Website)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: isCurrentSystemActive ? AppColors.lightIndigoBg : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                        border: Border.all(
                          color: isCurrentSystemActive
                              ? AppColors.lightIndigoBorder
                              : const Color(0xFFFDE68A),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: isCurrentSystemActive
                                  ? AppColors.brandPrimary
                                  : const Color(0xFFD97706),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Icon(
                              isCurrentSystemActive ? Icons.autorenew_rounded : Icons.info_outline_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Text(
                                isCurrentSystemActive
                                    ? '${currentCycle.label} (Aktif di Sistem)'
                                    : '${currentCycle.label} (Pratinjau)',
                                style: AppTypography.cardTitle.copyWith(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: isCurrentSystemActive
                                      ? AppColors.brandNavy
                                      : const Color(0xFF92400E),
                                ),
                              ),
                                const SizedBox(height: 1),
                                Text(
                                  isCurrentSystemActive
                                      ? 'Siklus otomatis disinkronkan dengan website kurikulum.'
                                      : 'Menampilkan jadwal ${currentCycle.label}. Siklus aktif di website saat ini: ${widget.state.activeCycle.label}.',
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 10.5,
                                    color: isCurrentSystemActive
                                        ? AppColors.textSecondary
                                        : const Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                  // Horizontal Date Strip (Interaktif & Modern)
                  HorizontalDateStrip(
                    selectedDay: _selectedDay,
                    onDaySelected: (day) => setState(() => _selectedDay = day),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Section Title & Tombol Uji Notifikasi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Jadwal Hari $_selectedDay',
                          style: AppTypography.sectionTitle,
                        ),
                      ),
                      Row(
                        children: [
                          // Tombol Uji Notifikasi 15 Menit (Demo UKK)
                          InkWell(
                            onTap: () => widget.state.triggerTestClassEndingNotification(
                              context: context,
                              onNavigateToSchedule: () {},
                            ),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.brandAccent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.brandPrimary.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.notifications_active_rounded,
                                    size: 13,
                                    color: AppColors.brandPrimary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Uji Notif 15m',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.brandPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${schedules.length} Sesi',
                              style: AppTypography.smallHint.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Vertical Timeline Schedule
                  VerticalTimelineSchedule(
                    schedules: schedules,
                    dayName: _selectedDay,
                    cycleLabel: currentCycle.label,
                    isTeacher: false,
                  ),
                ],
              ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
