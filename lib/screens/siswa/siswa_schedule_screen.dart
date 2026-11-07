import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../constants/app_spacing.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/headers/header_with_gradient.dart';
import '../../widgets/cards/soft_card.dart';
import '../../widgets/buttons/pill_button.dart';

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
  late CycleType _selectedCycle;

  final List<String> _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];

  @override
  void initState() {
    super.initState();
    _selectedCycle = widget.state.activeCycle;
  }

  @override
  Widget build(BuildContext context) {
    final schedules = widget.state.teachingSchedules
        .where((s) => s.cycle == _selectedCycle && s.day.toLowerCase() == _selectedDay.toLowerCase())
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header with Gradient
          HeaderWithGradient(
            userName: widget.state.currentUser.name,
            userSubtitle: 'Jadwal Pelajaran Kelas ${widget.state.currentUser.className}',
            badgeText: _selectedCycle.label,
            actionButton: widget.onBack != null
                ? IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: widget.onBack,
                  )
                : null,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cycle Toggle Selector (Putaran 1 vs Putaran 2)
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

                  // Horizontal Day Filter Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _days.map((day) {
                        final isSelected = _selectedDay == day;
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: PillButton(
                            label: day,
                            isActive: isSelected,
                            onPressed: () => setState(() => _selectedDay = day),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Section Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Jadwal Hari $_selectedDay',
                        style: AppTypography.sectionTitle,
                      ),
                      Text(
                        '${schedules.length} Sesi Mapel',
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
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.event_available_outlined,
                                size: 48,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Tidak Ada Jadwal Belajar',
                                style: AppTypography.cardTitle.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tidak ada jadwal pelajaran untuk hari $_selectedDay pada ${_selectedCycle.label}.',
                                style: AppTypography.smallHint,
                                textAlign: TextAlign.center,
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
                        final bool isOngoing = index == 0; // Simulate first one ongoing

                        return SoftCard(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          border: isOngoing
                              ? Border.all(color: AppColors.primaryBlue, width: 1.5)
                              : null,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    'assets/images/SMK_Negeri_1_Bantul_logo.png',
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.contain,
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
                                                s.subjectName,
                                                style: AppTypography.cardTitle.copyWith(
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            if (isOngoing)
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.alertGreenBg,
                                                  borderRadius: BorderRadius.circular(
                                                    AppSpacing.radiusSmall,
                                                  ),
                                                ),
                                                child: Text(
                                                  'Sedang Berlangsung',
                                                  style: AppTypography.microBadge.copyWith(
                                                    color: AppColors.successHadir,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          s.teacherName,
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
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 15,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${s.startTime} - ${s.endTime} WIB',
                                        style: AppTypography.smallHint.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Flexible(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.meeting_room_outlined,
                                          size: 15,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            s.roomName,
                                            style: AppTypography.smallHint.copyWith(
                                              color: AppColors.textPrimary,
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
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
