import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../constants/app_spacing.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/headers/header_with_gradient.dart';
import '../../widgets/cards/soft_card.dart';
import '../../widgets/buttons/pill_button.dart';

class GuruJournalHistoryScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback onBack;

  const GuruJournalHistoryScreen({
    super.key,
    required this.state,
    required this.onBack,
  });

  @override
  State<GuruJournalHistoryScreen> createState() => _GuruJournalHistoryScreenState();
}

class _GuruJournalHistoryScreenState extends State<GuruJournalHistoryScreen> {
  String _selectedMonth = 'Oktober 2026';
  late CycleType _selectedCycle;

  final List<String> _months = ['Oktober 2026', 'September 2026', 'Agustus 2026'];

  @override
  void initState() {
    super.initState();
    _selectedCycle = widget.state.activeCycle;
  }

  @override
  Widget build(BuildContext context) {
    final journals = widget.state.teachingJournals;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header with Gradient
          HeaderWithGradient(
            userName: 'Riwayat Jurnal Mengajar',
            userSubtitle: widget.state.currentUser.name,
            actionButton: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: widget.onBack,
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryIndigo,
              onRefresh: () =>
                  widget.state.fetchTeacherJournalsData(cycle: _selectedCycle),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Month Dropdown & Cycle Selector
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedMonth,
                              isExpanded: true,
                              items: _months
                                  .map((m) => DropdownMenuItem(
                                        value: m,
                                        child: Text(m, style: AppTypography.bodyText),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedMonth = val);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Row(
                    children: [
                      Expanded(
                        child: PillButton(
                          label: 'Putaran 1',
                          isActive: _selectedCycle == CycleType.putaran1,
                          onPressed: () => setState(() => _selectedCycle = CycleType.putaran1),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: PillButton(
                          label: 'Putaran 2',
                          isActive: _selectedCycle == CycleType.putaran2,
                          onPressed: () => setState(() => _selectedCycle = CycleType.putaran2),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  Text('Daftar Jurnal Terisi', style: AppTypography.sectionTitle),
                  const SizedBox(height: AppSpacing.sm),

                  if (journals.isEmpty) ...[
                    SoftCard(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          child: Text(
                            'Belum ada riwayat jurnal yang disimpan.',
                            style: AppTypography.smallHint,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: journals.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final j = journals[index];

                        return SoftCard(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.alertGreenBg,
                                      borderRadius:
                                          BorderRadius.circular(AppSpacing.radiusMedium),
                                    ),
                                    child: const Icon(
                                      Icons.assignment_turned_in,
                                      color: AppColors.successHadir,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          j.subjectName,
                                          style: AppTypography.cardTitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${j.className} • ${j.date.day}/${j.date.month}/${j.date.year}',
                                          style: AppTypography.smallHint.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        Text(
                                          j.timeSlot,
                                          style: AppTypography.microBadge.copyWith(
                                            color: AppColors.primaryBlue,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(AppSpacing.sm + 2),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius:
                                      BorderRadius.circular(AppSpacing.radiusSmall),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Materi Pembelajaran:',
                                      style: AppTypography.microBadge.copyWith(
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      j.topic,
                                      style: AppTypography.smallHint.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              // Attendance summary pills
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  _buildTag('Hadir: ${j.presentCount}', AppColors.alertGreenBg, AppColors.successHadir),
                                  _buildTag('Izin: ${j.permissionCount}', AppColors.alertBlueBg, AppColors.infoIzin),
                                  _buildTag('Sakit: ${j.sickCount}', AppColors.alertAmberBg, AppColors.warningSakit),
                                  _buildTag('Alpa: ${j.absentCount}', AppColors.alertRedBg, AppColors.errorAlpa),
                                ],
                              ),
                              if (j.photoUrl != null) ...[
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  children: [
                                    const Icon(Icons.photo_camera, size: 14, color: AppColors.teamTeal),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Foto dokumentasi: ${j.photoUrl}',
                                        style: AppTypography.microBadge.copyWith(
                                          color: AppColors.teamTeal,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
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

  Widget _buildTag(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      ),
      child: Text(
        text,
        style: AppTypography.microBadge.copyWith(color: textColor),
      ),
    );
  }
}
