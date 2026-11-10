import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../constants/app_spacing.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/headers/scp_page_header.dart';
import '../../widgets/buttons/pill_button.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/lists/leave_request_card.dart';
import '../../widgets/cards/soft_card.dart';
import '../../widgets/cards/data_state_view.dart';

class SiswaLeaveStatusScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback? onBack;
  final VoidCallback onNewRequest;

  const SiswaLeaveStatusScreen({
    super.key,
    required this.state,
    this.onBack,
    required this.onNewRequest,
  });

  @override
  State<SiswaLeaveStatusScreen> createState() => _SiswaLeaveStatusScreenState();
}

class _SiswaLeaveStatusScreenState extends State<SiswaLeaveStatusScreen> {
  String _activeTab = 'Semua';

  final List<String> _tabs = ['Semua', 'Menunggu', 'Disetujui', 'Ditolak'];

  void _confirmCancelRequest(BuildContext context, LeaveRequest req) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Batalkan Pengajuan Izin?',
          style: AppTypography.sectionTitle,
        ),
        content: Text(
          'Apakah Anda yakin ingin membatalkan permohonan izin ${req.type.label} yang masih berstatus Pending?',
          style: AppTypography.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusAlpa,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final res = await widget.state.cancelStudentLeaveRequest(req.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res.success
                        ? 'Pengajuan izin berhasil dibatalkan.'
                        : res.message),
                    backgroundColor: res.success
                        ? AppColors.secondaryTeal
                        : AppColors.statusAlpa,
                  ),
                );
              }
            },
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.state.currentUser;
    final allRequests = widget.state.leaveRequests;
    final isLoading = widget.state.isLoadingLeaves;
    final hasError = widget.state.leavesError != null;
    final hasAnyRequest = allRequests.isNotEmpty;

    final filteredRequests = allRequests.where((r) {
      if (_activeTab == 'Menunggu') return r.status == LeaveStatus.pending;
      if (_activeTab == 'Disetujui') return r.status == LeaveStatus.approved;
      if (_activeTab == 'Ditolak') return r.status == LeaveStatus.rejected;
      return true;
    }).toList();

    // Sesuai PRD Priority 1:
    // FAB hanya ditampilkan pada List State (ketika siswa sudah punya pengajuan)
    // Sembunyikan FAB pada Empty State, Loading, dan Error State
    final bool showFab = hasAnyRequest && !isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: showFab
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primaryIndigo,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                'Ajukan Izin',
                style: AppTypography.labelButton.copyWith(color: Colors.white),
              ),
              onPressed: widget.onNewRequest,
            )
          : null,
      body: Column(
        children: [
          // Standardized SCP Page Header
          ScpPageHeader(
            title: 'Perizinan Saya',
            studentName: user.name,
            className: user.className,
            cycleLabel: null,
            showCycleBadge: false,
            leading: widget.onBack != null
                ? IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                    onPressed: widget.onBack,
                  )
                : null,
          ),

          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryIndigo,
              onRefresh: () => widget.state.fetchStudentLeavesData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error state banner if API failed
                    if (hasError) ...[
                      DataErrorCard(
                        title: 'Gagal Memuat Data Perizinan',
                        message: widget.state.leavesError!,
                        onRetry: () => widget.state.fetchStudentLeavesData(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // Tab filter
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _tabs.map((tab) {
                          final isSelected = _activeTab == tab;
                          int count = 0;
                          if (tab == 'Semua') count = allRequests.length;
                          if (tab == 'Menunggu') {
                            count = allRequests
                                .where((r) => r.status == LeaveStatus.pending)
                                .length;
                          }
                          if (tab == 'Disetujui') {
                            count = allRequests
                                .where((r) => r.status == LeaveStatus.approved)
                                .length;
                          }
                          if (tab == 'Ditolak') {
                            count = allRequests
                                .where((r) => r.status == LeaveStatus.rejected)
                                .length;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.sm),
                            child: PillButton(
                              label: tab,
                              count: count > 0 ? '$count' : null,
                              isActive: isSelected,
                              onPressed: () => setState(() => _activeTab = tab),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Condition C: Loading State
                    if (isLoading && allRequests.isEmpty) ...[
                      const DataLoadingCard(
                        message: 'Memuat data perizinan...',
                      ),
                    ]
                    // Condition D: Error State (and no existing requests)
                    else if (hasError && allRequests.isEmpty) ...[
                      // DataErrorCard is already shown above, do NOT show empty state
                      const SizedBox.shrink(),
                    ]
                    // Condition A: Empty State (siswa belum mempunyai pengajuan)
                    else if (allRequests.isEmpty) ...[
                      SoftCard(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.assignment_turned_in_outlined,
                                  size: 52,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  'Belum Ada Pengajuan',
                                  style: AppTypography.cardTitle.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Anda belum memiliki riwayat permohonan izin.',
                                  style: AppTypography.smallHint,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                PrimaryButton(
                                  label: 'Ajukan Izin Sekarang',
                                  width: 210,
                                  onPressed: widget.onNewRequest,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]
                    // Tab Filter Empty State (siswa punya pengajuan, namun filter tab ini kosong)
                    else if (filteredRequests.isEmpty) ...[
                      SoftCard(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 36),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.filter_list_off_rounded,
                                  size: 44,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Tidak Ada Surat $_activeTab',
                                  style: AppTypography.cardTitle.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tidak ada surat perizinan dengan status $_activeTab.',
                                  style: AppTypography.smallHint,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]
                    // Condition B: List State (tampilkan daftar pengajuan)
                    else ...[
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredRequests.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final req = filteredRequests[index];
                        final durationDays =
                            req.endDate.difference(req.startDate).inDays + 1;
                        final dateStr =
                            '${req.startDate.day} ${_getMonthName(req.startDate.month)} - ${req.endDate.day} ${_getMonthName(req.endDate.month)} ${req.startDate.year} ($durationDays Hari)';

                        return LeaveRequestCard(
                          studentName: req.studentName,
                          nisn: 'NISN. ${req.nisn} • ${req.className}',
                          leaveType: req.type.label,
                          leaveTime: req.leaveTime,
                          dateRange: dateStr,
                          reason: req.reason,
                          status: req.status.label,
                          rejectionNote: req.rejectReason,
                          verifiedBy:
                              req.verifiedBy.isNotEmpty ? req.verifiedBy : null,
                          actionLabel: 'Detail Surat',
                          onViewTap: () => _showLeaveDetailModal(context, req),
                          onCancelTap: req.status == LeaveStatus.pending
                              ? () => _confirmCancelRequest(context, req)
                              : null,
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

  void _showLeaveDetailModal(BuildContext context, LeaveRequest req) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detail Pengajuan Izin',
                    style: AppTypography.sectionTitle,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: req.status.bgColor,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                    child: Text(
                      req.status.label,
                      style: AppTypography.microBadge.copyWith(
                        color: req.status.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Kategori: ${req.type.label}${req.leaveTime != null ? " (${req.leaveTime} WIB)" : ""}',
                style: AppTypography.cardTitle,
              ),
              const SizedBox(height: 4),
              Text(
                'Tanggal: ${req.startDate.day}/${req.startDate.month}/${req.startDate.year} s/d ${req.endDate.day}/${req.endDate.month}/${req.endDate.year}',
                style: AppTypography.smallHint,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Alasan Izin:', style: AppTypography.cardTitle),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(req.reason, style: AppTypography.bodyText),
              ),
              if (req.rejectReason != null && req.rejectReason!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.statusRejectedBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Catatan Penolakan: ${req.rejectReason}',
                    style: AppTypography.smallHint.copyWith(
                      color: AppColors.statusRejectedText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              if (req.documentName != null) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    const Icon(
                      Icons.attach_file_rounded,
                      size: 16,
                      color: AppColors.primaryIndigo,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        req.documentName!,
                        style: AppTypography.smallHint.copyWith(
                          color: AppColors.primaryIndigo,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'Tutup',
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
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
