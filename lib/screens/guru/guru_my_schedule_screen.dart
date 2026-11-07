import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../constants/app_spacing.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/headers/header_with_gradient.dart';
import '../../widgets/cards/soft_card.dart';
import '../../widgets/cards/alert_card.dart';
import '../../widgets/buttons/pill_button.dart';

class GuruMyScheduleScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback onBack;
  final VoidCallback onAddSchedule;

  const GuruMyScheduleScreen({
    super.key,
    required this.state,
    required this.onBack,
    required this.onAddSchedule,
  });

  @override
  State<GuruMyScheduleScreen> createState() => _GuruMyScheduleScreenState();
}

class _GuruMyScheduleScreenState extends State<GuruMyScheduleScreen> {
  String _selectedDay = 'Senin';
  late CycleType _selectedCycle;

  final List<String> _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];

  @override
  void initState() {
    super.initState();
    _selectedCycle = widget.state.activeCycle;
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.state.currentUser;
    final schedules = widget.state.teachingSchedules
        .where((s) => s.cycle == _selectedCycle && s.day.toLowerCase() == _selectedDay.toLowerCase())
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: widget.state.isScheduleLocked
          ? null
          : FloatingActionButton.extended(
              backgroundColor: AppColors.primaryIndigo,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                'Tambah Jadwal',
                style: AppTypography.labelButton.copyWith(color: Colors.white),
              ),
              onPressed: widget.onAddSchedule,
            ),
      body: Column(
        children: [
          // Header with Gradient
          HeaderWithGradient(
            userName: 'Jadwal Mengajar Guru',
            userSubtitle: '${user.name} • ${user.className}',
            badgeText: _selectedCycle.label,
            actionButton: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: widget.onBack,
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryIndigo,
              onRefresh: () =>
                  widget.state.fetchTeacherSchedulesData(cycle: _selectedCycle),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Schedule Locked Info Banner (if locked)
                  if (widget.state.isScheduleLocked) ...[
                    AlertCard(
                      type: AlertType.warning,
                      title: 'Pengaturan Jadwal Terkunci',
                      message:
                          'Waka Kurikulum telah mengunci jadwal mengajar. Hubungi kurikulum jika memerlukan penyesuaian jam atau ruangan.',
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Cycle Selector
                  Row(
                    children: [
                      Expanded(
                        child: PillButton(
                          label: 'Putaran 1 (Teori & Lab A)',
                          isActive: _selectedCycle == CycleType.putaran1,
                          onPressed: () => setState(() => _selectedCycle = CycleType.putaran1),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: PillButton(
                          label: 'Putaran 2 (Praktik Tefa)',
                          isActive: _selectedCycle == CycleType.putaran2,
                          onPressed: () => setState(() => _selectedCycle = CycleType.putaran2),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Day Selector Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _days.map((day) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: PillButton(
                            label: day,
                            isActive: _selectedDay == day,
                            onPressed: () => setState(() => _selectedDay = day),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Header of list
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Jadwal Hari $_selectedDay', style: AppTypography.sectionTitle),
                      Text(
                        '${schedules.length} Sesi Terjadwal',
                        style: AppTypography.smallHint.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  if (schedules.isEmpty) ...[
                    SoftCard(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 48,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Tidak Ada Jadwal Mengajar',
                                style: AppTypography.cardTitle.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Belum ada sesi mengajar di hari $_selectedDay (${_selectedCycle.label}).',
                                style: AppTypography.smallHint,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: schedules.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final s = schedules[index];

                        return SoftCard(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.alertBlueBg,
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                                    ),
                                    child: const Icon(
                                      Icons.menu_book,
                                      color: AppColors.infoIzin,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.subjectName,
                                          style: AppTypography.cardTitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${s.className} • ${s.roomName}',
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
                              const SizedBox(height: AppSpacing.md),
                              const Divider(height: 1, color: AppColors.border),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 14, color: AppColors.textTertiary),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${s.startTime} - ${s.endTime} WIB',
                                        style: AppTypography.smallHint.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    _selectedCycle.label,
                                    style: AppTypography.microBadge.copyWith(
                                      color: AppColors.teamTeal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 80),
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
