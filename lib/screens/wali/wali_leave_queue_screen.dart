import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../constants/app_spacing.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/headers/header_with_gradient.dart';
import '../../widgets/inputs/search_bar.dart';
import '../../widgets/buttons/pill_button.dart';
import '../../widgets/lists/leave_request_card.dart';
import '../../widgets/cards/soft_card.dart';

class WaliLeaveQueueScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback onBack;
  final Function(LeaveRequest req) onSelectDetail;

  const WaliLeaveQueueScreen({
    super.key,
    required this.state,
    required this.onBack,
    required this.onSelectDetail,
  });

  @override
  State<WaliLeaveQueueScreen> createState() => _WaliLeaveQueueScreenState();
}

class _WaliLeaveQueueScreenState extends State<WaliLeaveQueueScreen> {
  String _activeTab = 'Menunggu';
  String _searchQuery = '';

  final List<String> _tabs = ['Menunggu', 'Disetujui', 'Ditolak'];

  @override
  Widget build(BuildContext context) {
    final allRequests = widget.state.leaveRequests;

    final filtered = allRequests.where((req) {
      bool statusMatches = false;
      if (_activeTab == 'Menunggu') statusMatches = req.status == LeaveStatus.pending;
      if (_activeTab == 'Disetujui') statusMatches = req.status == LeaveStatus.approved;
      if (_activeTab == 'Ditolak') statusMatches = req.status == LeaveStatus.rejected;

      if (!statusMatches) return false;

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final nameMatches = req.studentName.toLowerCase().contains(q);
        final nisnMatches = req.nisn.toLowerCase().contains(q);
        return nameMatches || nisnMatches;
      }

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header with Gradient
          HeaderWithGradient(
            userName: 'Verifikasi Izin Siswa',
            userSubtitle: 'Wali Kelas XII RPL 1 • Antrean Surat',
            actionButton: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: widget.onBack,
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AppSearchBar
                  AppSearchBar(
                    hintText: 'Cari nama siswa atau NISN...',
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Segmented Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _tabs.map((tab) {
                        final isSelected = _activeTab == tab;
                        int count = 0;
                        if (tab == 'Menunggu') {
                          count = allRequests.where((r) => r.status == LeaveStatus.pending).length;
                        }
                        if (tab == 'Disetujui') {
                          count = allRequests.where((r) => r.status == LeaveStatus.approved).length;
                        }
                        if (tab == 'Ditolak') {
                          count = allRequests.where((r) => r.status == LeaveStatus.rejected).length;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: PillButton(
                            label: tab,
                            count: '$count',
                            isActive: isSelected,
                            activeColor: tab == 'Menunggu'
                                ? AppColors.warningSakit
                                : (tab == 'Disetujui'
                                    ? AppColors.successHadir
                                    : AppColors.errorAlpa),
                            onPressed: () => setState(() => _activeTab = tab),
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
                      Text('Antrean $_activeTab', style: AppTypography.sectionTitle),
                      Text(
                        '${filtered.length} Pengajuan',
                        style: AppTypography.smallHint.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  if (filtered.isEmpty) ...[
                    SoftCard(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.folder_open_outlined,
                                size: 48,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Tidak Ada Pengajuan',
                                style: AppTypography.cardTitle.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tidak ditemukan surat izin berstatus $_activeTab.',
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
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final req = filtered[index];
                        final durationDays =
                            req.endDate.difference(req.startDate).inDays + 1;
                        final dateStr =
                            '${req.startDate.day} ${_getMonthName(req.startDate.month)} - ${req.endDate.day} ${_getMonthName(req.endDate.month)} ${req.startDate.year} ($durationDays Hari)';

                        return LeaveRequestCard(
                          studentName: req.studentName,
                          nisn: 'NISN. ${req.nisn}',
                          leaveType: req.type.label,
                          dateRange: dateStr,
                          leaveTime: req.leaveTime,
                          reason: req.reason,
                          rejectionNote: req.rejectionNote,
                          status: req.status.label,
                          verifiedBy: req.verifiedBy.isNotEmpty ? req.verifiedBy : null,
                          onViewTap: () => widget.onSelectDetail(req),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month];
  }
}
