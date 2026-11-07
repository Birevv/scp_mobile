import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../constants/app_spacing.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/headers/header_with_gradient.dart';
import '../../widgets/cards/soft_card.dart';
import '../../widgets/buttons/primary_button.dart';

class WaliLeaveDetailScreen extends StatefulWidget {
  final AppState state;
  final LeaveRequest request;
  final VoidCallback onBack;
  final VoidCallback onCompleted;

  const WaliLeaveDetailScreen({
    super.key,
    required this.state,
    required this.request,
    required this.onBack,
    required this.onCompleted,
  });

  @override
  State<WaliLeaveDetailScreen> createState() => _WaliLeaveDetailScreenState();
}

class _WaliLeaveDetailScreenState extends State<WaliLeaveDetailScreen> {
  final _rejectReasonController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _rejectReasonController.dispose();
    super.dispose();
  }

  void _handleApprove() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Setujui Pengajuan Izin?'),
        content: Text(
          'Setelah disetujui, presensi ananda ${widget.request.studentName} akan otomatis tersinkronisasi sebagai "${widget.request.type.label}" di jurnal mengajar guru bersangkutan.',
          style: AppTypography.bodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successHadir,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _processDecision(true);
            },
            child: const Text('Ya, Setujui'),
          ),
        ],
      ),
    );
  }

  void _handleReject() {
    _rejectReasonController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Pengajuan Izin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan alasan penolakan untuk diberikan kepada siswa & orang tua:',
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _rejectReasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Misal: Dokumen surat dokter tidak valid atau tanggal kadaluarsa.',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorAlpa,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (_rejectReasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Harap tuliskan alasan penolakan!'),
                    backgroundColor: AppColors.errorAlpa,
                  ),
                );
                return;
              }
              Navigator.pop(ctx);
              _processDecision(false, _rejectReasonController.text.trim());
            },
            child: const Text('Tolak Surat'),
          ),
        ],
      ),
    );
  }

  Future<void> _processDecision(bool isApproved, [String? rejectReason]) async {
    setState(() => _isProcessing = true);

    final res = await widget.state.verifyHomeroomLeave(
      id: widget.request.id,
      approve: isApproved,
      rejectionNote: rejectReason,
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isApproved
              ? 'Surat berhasil disetujui & otomatis tersinkron ke jurnal guru!'
              : 'Pengajuan izin telah ditolak.'),
          backgroundColor:
              isApproved ? AppColors.statusHadir : AppColors.statusAlpa,
        ),
      );
      widget.onCompleted();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message),
          backgroundColor: AppColors.statusAlpa,
        ),
      );
    }
  }

  void _showDocumentPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.radiusLarge),
                  topRight: Radius.circular(AppSpacing.radiusLarge),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pratinjau Bukti Surat',
                    style: AppTypography.cardTitle.copyWith(color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Container(
                    height: 260,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      child: InteractiveViewer(
                        minScale: 1.0,
                        maxScale: 4.0,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.description_outlined,
                                size: 64,
                                color: AppColors.primaryIndigo,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                widget.request.documentName ?? 'Surat_Keterangan_Resmi.pdf',
                                style: AppTypography.cardTitle.copyWith(fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Dokumen Resmi Terverifikasi (Digital Scan)',
                                style: AppTypography.smallHint,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.alertGreenBg,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.verified, size: 14, color: AppColors.successHadir),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Tanda Tangan & Cap Sah',
                                      style: AppTypography.microBadge.copyWith(
                                        color: AppColors.successHadir,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Dapat diperbesar dengan gesture cubit zoom.',
                    style: AppTypography.smallHint.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    final durationDays = req.endDate.difference(req.startDate).inDays + 1;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: req.status == LeaveStatus.pending
          ? Container(
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: 12,
                bottom: bottomInset > 0 ? bottomInset + 8 : 14,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: const Border(top: BorderSide(color: AppColors.border)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A0F172A),
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.errorAlpa,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(
                        Icons.cancel_outlined,
                        color: AppColors.errorAlpa,
                        size: 18,
                      ),
                      label: Text(
                        'Tolak',
                        style: AppTypography.labelButton.copyWith(
                          color: AppColors.errorAlpa,
                          fontSize: 13,
                        ),
                      ),
                      onPressed: _handleReject,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      label: 'Setujui (Approve)',
                      icon: Icons.check_circle_outline_rounded,
                      backgroundColor: AppColors.successHadir,
                      isLoading: _isProcessing,
                      onPressed: _handleApprove,
                    ),
                  ),
                ],
              ),
            )
          : null,
      body: Column(
        children: [
          // Header with Gradient
          HeaderWithGradient(
            userName: 'Tinjau Surat Perizinan',
            userSubtitle: '${req.studentName} • ${req.className}',
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
                  // Student Profile Card
                  SoftCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: AppColors.lightBlueBorder,
                              child: Text(
                                req.studentName.isNotEmpty ? req.studentName[0] : 'S',
                                style: AppTypography.sectionTitle.copyWith(
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(req.studentName, style: AppTypography.cardTitle),
                                  const SizedBox(height: 2),
                                  Text(
                                    'NISN. ${req.nisn} • ${req.className}',
                                    style: AppTypography.smallHint.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: req.status.bgColor,
                                      borderRadius:
                                          BorderRadius.circular(AppSpacing.radiusSmall),
                                    ),
                                    child: Text(
                                      req.status.label,
                                      style: AppTypography.microBadge.copyWith(
                                        color: req.status.color,
                                      ),
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
                        // Parent contact action
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.phone_outlined, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  'Wali: +62 812-3456-7890',
                                  style: AppTypography.smallHint.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.teamTeal),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                                ),
                              ),
                              icon: const Icon(Icons.chat_outlined, size: 14, color: AppColors.teamTeal),
                              label: Text(
                                'WhatsApp Ortu',
                                style: AppTypography.microBadge.copyWith(
                                  color: AppColors.teamTeal,
                                ),
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Membuka kontak WhatsApp orang tua siswa...'),
                                    backgroundColor: AppColors.teamTeal,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Detail Rentang Waktu
                  Text('Rincian Jadwal Izin', style: AppTypography.sectionTitle),
                  const SizedBox(height: AppSpacing.sm),
                  SoftCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Jenis Surat:', style: AppTypography.smallHint),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: req.type == LeaveType.sakit
                                    ? AppColors.alertAmberBg
                                    : AppColors.alertBlueBg,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                              ),
                              child: Text(
                                req.type.label,
                                style: AppTypography.microBadge.copyWith(
                                  color: req.type == LeaveType.sakit
                                      ? AppColors.warningSakit
                                      : AppColors.infoIzin,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Rentang Tanggal:', style: AppTypography.smallHint),
                            Text(
                              '${req.startDate.day}/${req.startDate.month}/${req.startDate.year} s/d ${req.endDate.day}/${req.endDate.month}/${req.endDate.year}',
                              style: AppTypography.smallHint.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Durasi:', style: AppTypography.smallHint),
                            Text(
                              '$durationDays Hari Pembelajaran',
                              style: AppTypography.smallHint.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Alasan Lengkap
                  Text('Alasan Tertulis dari Siswa / Wali Murid',
                      style: AppTypography.sectionTitle),
                  const SizedBox(height: AppSpacing.sm),
                  SoftCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      req.reason,
                      style: AppTypography.bodyText,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Lampiran Dokumen
                  Text('Bukti Lampiran Dokumen', style: AppTypography.sectionTitle),
                  const SizedBox(height: AppSpacing.sm),
                  SoftCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.attachment_rounded,
                              color: AppColors.primaryBlue,
                              size: 24,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                req.documentName ?? 'Surat_Keterangan_Dokter.pdf',
                                style: AppTypography.cardTitle.copyWith(fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                                ),
                              ),
                              icon: const Icon(Icons.fullscreen, size: 16, color: Colors.white),
                              label: Text(
                                'Buka Bukti',
                                style: AppTypography.microBadge.copyWith(color: Colors.white),
                              ),
                              onPressed: () => _showDocumentPreview(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  if (req.status != LeaveStatus.pending) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: req.status.bgColor,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      ),
                      child: Center(
                        child: Text(
                          'Surat ini telah diproses dengan status: ${req.status.label}',
                          style: AppTypography.cardTitle.copyWith(color: req.status.color),
                        ),
                      ),
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
}
