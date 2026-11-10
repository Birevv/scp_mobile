import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../constants/app_spacing.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/headers/header_with_gradient.dart';
import '../../widgets/inputs/search_bar.dart';
import '../../widgets/lists/student_list_item.dart';
import '../../widgets/cards/soft_card.dart';
import '../../widgets/cards/data_state_view.dart';

class WaliStudentsScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback? onBack;

  const WaliStudentsScreen({
    super.key,
    required this.state,
    this.onBack,
  });

  @override
  State<WaliStudentsScreen> createState() => _WaliStudentsScreenState();
}

class _WaliStudentsScreenState extends State<WaliStudentsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.state.homeroomStudents.isEmpty) {
        widget.state.fetchHomeroomStudentsData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final students = widget.state.homeroomStudents;

    final filtered = students.where((s) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return s.name.toLowerCase().contains(q) || s.nisn.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header with Gradient
          HeaderWithGradient(
            userName: 'Daftar Siswa Binaan',
            userSubtitle: '${widget.state.currentUser.className} • ${students.length} Siswa Terdaftar',
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
              onRefresh: () => Future.wait([
                widget.state.fetchHomeroomStudentsData(),
                widget.state.fetchHomeroomDashboardData(),
                widget.state.fetchHomeroomLeavesData(),
              ]),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    AppSearchBar(
                      hintText: 'Cari siswa atau NISN...',
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text('Rekap Kehadiran Siswa', style: AppTypography.sectionTitle),
                        ),
                        Text(
                          '${filtered.length} Siswa',
                          style: AppTypography.smallHint.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    if (widget.state.isLoadingHomeroomStudents) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryIndigo,
                          ),
                        ),
                      ),
                    ] else if (widget.state.homeroomStudentsError != null) ...[
                      DataErrorCard(
                        title: 'Gagal Memuat Data Siswa',
                        message: widget.state.homeroomStudentsError!,
                        onRetry: () => widget.state.fetchHomeroomStudentsData(),
                      ),
                    ] else if (filtered.isEmpty) ...[
                      SoftCard(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 36),
                            child: Text(
                              'Tidak ada siswa yang sesuai pencarian.',
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
                          final student = filtered[index];
                          final bool hasAttention = student.alpa >= 3;

                          return StudentListItem(
                            studentName: student.name,
                            nisn: 'NISN. ${student.nisn}',
                            statusBadge: student.todayStatus.label,
                            statusBadgeColor: student.todayStatus.color,
                            statusBadgeBgColor: student.todayStatus.bgColor,
                            address: hasAttention ? 'Perlu perhatian khusus BK (≥3 Alpa)' : null,
                            onTap: () => _showStudentDetailModal(context, student),
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

  void _showStudentDetailModal(BuildContext context, HomeroomStudent student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.radiusXL),
            topRight: Radius.circular(AppSpacing.radiusXL),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.lightBlueBorder,
                  child: Text(
                    student.name.isNotEmpty ? student.name[0] : 'S',
                    style: AppTypography.sectionTitle.copyWith(color: AppColors.primaryBlue),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name, style: AppTypography.cardTitle),
                      Text('NISN. ${student.nisn}', style: AppTypography.smallHint),
                      Text('Kelas: ${student.className}', style: AppTypography.smallHint),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: AppSpacing.md),
            Text('Rekapitulasi Presensi Semester:', style: AppTypography.cardTitle),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _buildStatPill('Hadir', student.hadir, AppColors.alertGreenBg, AppColors.successHadir),
                const SizedBox(width: 6),
                _buildStatPill('Sakit', student.sakit, AppColors.alertAmberBg, AppColors.warningSakit),
                const SizedBox(width: 6),
                _buildStatPill('Izin', student.izin, AppColors.alertBlueBg, AppColors.infoIzin),
                const SizedBox(width: 6),
                _buildStatPill('Alpa', student.alpa, AppColors.alertRedBg, AppColors.errorAlpa),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Text(
                  'Persentase Kehadiran: ',
                  style: AppTypography.smallHint.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  student.percentage != null ? '${student.percentage}%' : '— (Belum ada presensi)',
                  style: AppTypography.smallHint.copyWith(
                    color: (student.percentage ?? 0) >= 85 ? AppColors.successHadir : AppColors.errorAlpa,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: AppSpacing.md),
            Text('Status Presensi Hari Ini:', style: AppTypography.cardTitle),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: student.todayStatus.bgColor,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 10, color: student.todayStatus.color),
                  const SizedBox(width: 6),
                  Text(
                    student.todayStatus.label,
                    style: AppTypography.labelButton.copyWith(color: student.todayStatus.color),
                  ),
                  if (student.isAutoSynced) ...[
                    const SizedBox(width: 8),
                    Text(
                      '(Tersinkron Surat Izin Approved)',
                      style: AppTypography.microBadge.copyWith(color: student.todayStatus.color),
                    ),
                  ],
                ],
              ),
            ),
            if (student.leaveReason != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Keterangan: ${student.leaveReason}',
                style: AppTypography.smallHint.copyWith(color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(String label, int count, Color bg, Color text) {
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
              count.toString(),
              style: AppTypography.cardTitle.copyWith(color: text, fontSize: 16),
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
