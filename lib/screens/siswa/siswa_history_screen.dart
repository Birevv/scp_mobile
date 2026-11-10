import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../constants/app_spacing.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/headers/scp_page_header.dart';
import '../../widgets/cards/soft_card.dart';
import '../../widgets/cards/data_state_view.dart';
import '../../widgets/buttons/pill_button.dart';

class SiswaHistoryScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback? onBack;

  const SiswaHistoryScreen({
    super.key,
    required this.state,
    this.onBack,
  });

  @override
  State<SiswaHistoryScreen> createState() => _SiswaHistoryScreenState();
}

class _SiswaHistoryScreenState extends State<SiswaHistoryScreen> {
  String _selectedMonth = 'Oktober 2026';
  String _selectedFilterStatus = 'Semua';

  final List<String> _months = [
    'November 2026',
    'Oktober 2026',
    'September 2026',
    'Agustus 2026',
    'Juli 2026',
  ];

  final List<String> _filterStatuses = ['Semua', 'Hadir', 'Izin', 'Sakit', 'Alpa'];

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

  void _onMonthChanged(String? val) {
    if (val == null || val == _selectedMonth) return;
    setState(() => _selectedMonth = val);
    final month = _parseMonth(val);
    final year = _parseYear(val);
    widget.state.fetchStudentHistoryData(month: month, year: year);
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.state.currentUser;
    final allHistory = widget.state.personalHistory;

    final filtered = allHistory.where((item) {
      if (_selectedFilterStatus == 'Semua') return true;
      return item.status.label.toLowerCase() == _selectedFilterStatus.toLowerCase();
    }).toList();

    int hadir = allHistory.where((h) => h.status == AttendanceStatus.hadir).length;
    int izin = allHistory.where((h) => h.status == AttendanceStatus.izin).length;
    int sakit = allHistory.where((h) => h.status == AttendanceStatus.sakit).length;
    int alpa = allHistory.where((h) => h.status == AttendanceStatus.alpa).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Standardized SCP Page Header
          ScpPageHeader(
            title: 'Riwayat Kehadiran',
            studentName: user.name,
            className: user.className,
            cycleLabel: null,
            showCycleBadge: false,
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
              onRefresh: () => widget.state.fetchStudentHistoryData(
                month: _parseMonth(_selectedMonth),
                year: _parseYear(_selectedMonth),
              ),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.state.historyError != null) ...[
                      DataErrorCard(
                        title: 'Gagal Memuat Riwayat',
                        message: widget.state.historyError!,
                        onRetry: () => widget.state.fetchStudentHistoryData(
                          month: _parseMonth(_selectedMonth),
                          year: _parseYear(_selectedMonth),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  // Month Dropdown Filter
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, color: AppColors.primaryBlue, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Periode:', style: AppTypography.cardTitle),
                      const SizedBox(width: AppSpacing.sm),
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
                              onChanged: _onMonthChanged,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Mini Status Counter Pills
                  Row(
                    children: [
                      _buildCounterBadge('Hadir', hadir, AppColors.alertGreenBg, AppColors.successHadir),
                      const SizedBox(width: 6),
                      _buildCounterBadge('Izin', izin, AppColors.alertBlueBg, AppColors.infoIzin),
                      const SizedBox(width: 6),
                      _buildCounterBadge('Sakit', sakit, AppColors.alertAmberBg, AppColors.warningSakit),
                      const SizedBox(width: 6),
                      _buildCounterBadge('Alpa', alpa, AppColors.alertRedBg, AppColors.errorAlpa),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Filter Status Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filterStatuses.map((s) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: PillButton(
                            label: s,
                            isActive: _selectedFilterStatus == s,
                            onPressed: () => setState(() => _selectedFilterStatus = s),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // History List
                  Text(
                    'Catatan Presensi Harian',
                    style: AppTypography.sectionTitle,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  if (filtered.isEmpty) ...[
                    SoftCard(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            'Tidak ada catatan presensi untuk filter $_selectedFilterStatus.',
                            style: AppTypography.smallHint,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final item = filtered[index];

                        return SoftCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: item.status.bgColor,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                                ),
                                child: Center(
                                  child: Text(
                                    item.status.label.substring(0, 1).toUpperCase(),
                                    style: AppTypography.cardTitle.copyWith(
                                      color: item.status.color,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
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
                                            item.subject,
                                            style: AppTypography.cardTitle.copyWith(fontSize: 14),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: item.status.bgColor,
                                            borderRadius:
                                                BorderRadius.circular(AppSpacing.radiusSmall),
                                          ),
                                          child: Text(
                                            item.status.label,
                                            style: AppTypography.microBadge.copyWith(
                                              color: item.status.color,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.date.day}/${item.date.month}/${item.date.year} • ${item.time}',
                                      style: AppTypography.smallHint.copyWith(
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                    Text(
                                      'Guru: ${item.teacherName}',
                                      style: AppTypography.smallHint.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    if (item.leaveReason != null && item.leaveReason!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius:
                                              BorderRadius.circular(AppSpacing.radiusSmall),
                                        ),
                                        child: Text(
                                          'Catatan: ${item.leaveReason}',
                                          style: AppTypography.microBadge.copyWith(
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w500,
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

  Widget _buildCounterBadge(String label, int count, Color bg, Color text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: AppTypography.sectionTitle.copyWith(color: text, fontSize: 16),
            ),
            Text(
              label,
              style: AppTypography.microBadge.copyWith(color: text),
            ),
          ],
        ),
      ),
    );
  }
}
