import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../constants/app_spacing.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/headers/header_with_gradient.dart';
import '../../widgets/cards/soft_card.dart';

class GuruJournalHistoryScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback? onBack;

  const GuruJournalHistoryScreen({
    super.key,
    required this.state,
    this.onBack,
  });

  @override
  State<GuruJournalHistoryScreen> createState() => _GuruJournalHistoryScreenState();
}

class _GuruJournalHistoryScreenState extends State<GuruJournalHistoryScreen> {
  String _selectedMonth = 'November 2026';
  CycleType? _selectedCycle;

  final List<String> _months = [
    'November 2026',
    'Oktober 2026',
    'September 2026',
    'Agustus 2026',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reloadJournals();
    });
  }

  int? _parseMonth(String monthStr) {
    final lower = monthStr.toLowerCase();
    if (lower.contains('januari')) return 1;
    if (lower.contains('februari')) return 2;
    if (lower.contains('maret')) return 3;
    if (lower.contains('april')) return 4;
    if (lower.contains('mei')) return 5;
    if (lower.contains('juni')) return 6;
    if (lower.contains('juli')) return 7;
    if (lower.contains('agustus')) return 8;
    if (lower.contains('september')) return 9;
    if (lower.contains('oktober')) return 10;
    if (lower.contains('november')) return 11;
    if (lower.contains('desember')) return 12;
    return null;
  }

  int? _parseYear(String monthStr) {
    final parts = monthStr.split(' ');
    if (parts.length >= 2) {
      return int.tryParse(parts.last);
    }
    return null;
  }

  void _reloadJournals({String? monthStr, CycleType? cycle}) {
    final targetCycle = cycle ?? _selectedCycle ?? widget.state.activeCycle;
    final targetMonthStr = monthStr ?? _selectedMonth;
    final month = _parseMonth(targetMonthStr);
    final year = _parseYear(targetMonthStr);
    widget.state.fetchTeacherJournalsData(
      cycle: targetCycle,
      month: month,
      year: year,
    );
  }

  void _onCycleSelected(CycleType cycle) {
    setState(() {
      _selectedCycle = cycle;
    });
    _reloadJournals(cycle: cycle);
  }

  @override
  Widget build(BuildContext context) {
    final journals = widget.state.teachingJournals;
    final currentCycle = _selectedCycle ?? widget.state.activeCycle;
    final isCurrentSystemActive = currentCycle == widget.state.activeCycle;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header with Gradient
          HeaderWithGradient(
            userName: 'Riwayat Jurnal Mengajar',
            userSubtitle: widget.state.currentUser.name,
            badgeText: currentCycle.label,
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
              onRefresh: () => widget.state.fetchTeacherJournalsData(
                cycle: currentCycle,
                month: _parseMonth(_selectedMonth),
                year: _parseYear(_selectedMonth),
              ),
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
                                    : 'Menampilkan riwayat ${currentCycle.label}. Siklus aktif di website saat ini: ${widget.state.activeCycle.label}.',
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
                                if (val != null && val != _selectedMonth) {
                                  setState(() => _selectedMonth = val);
                                  _reloadJournals(monthStr: val);
                                }
                              },
                            ),
                          ),
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
