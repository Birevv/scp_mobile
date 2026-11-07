import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../constants/app_spacing.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/headers/header_with_gradient.dart';
import '../../widgets/cards/soft_card.dart';
import '../../widgets/buttons/primary_button.dart';

class SiswaLeaveRequestScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback onBack;
  final VoidCallback onSuccess;

  const SiswaLeaveRequestScreen({
    super.key,
    required this.state,
    required this.onBack,
    required this.onSuccess,
  });

  @override
  State<SiswaLeaveRequestScreen> createState() =>
      _SiswaLeaveRequestScreenState();
}

class _SiswaLeaveRequestScreenState extends State<SiswaLeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  LeaveType _selectedType = LeaveType.sakit;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  TimeOfDay _leaveTime = const TimeOfDay(hour: 10, minute: 30);

  XFile? _pickedFile;
  String? _attachedFileName;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String get _formattedLeaveTime {
    final hh = _leaveTime.hour.toString().padLeft(2, '0');
    final mm = _leaveTime.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryIndigo,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickLeaveTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _leaveTime,
    );
    if (picked != null) {
      setState(() => _leaveTime = picked);
    }
  }

  Future<void> _pickAttachment(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _pickedFile = picked;
          _attachedFileName = picked.name;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lampiran siap diunggah: ${picked.name}'),
              backgroundColor: AppColors.secondaryTeal,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih berkas: $e'),
          backgroundColor: AppColors.statusAlpa,
        ),
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_attachedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Harap lampirkan bukti surat dokter / foto surat izin orang tua!',
          ),
          backgroundColor: AppColors.statusAlpa,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final res = await widget.state.submitStudentLeaveRequest(
      type: _selectedType,
      startDate: _startDate,
      endDate: _endDate,
      leaveTime:
          _selectedType.requiresLeaveTime ? _formattedLeaveTime : null,
      reason: _reasonController.text.trim(),
      attachmentFilePath: _pickedFile?.path,
      attachmentFileName: _pickedFile?.name,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Surat perizinan berhasil dikirim untuk diverifikasi!',
          ),
          backgroundColor: AppColors.statusHadir,
        ),
      );
      widget.onSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message),
          backgroundColor: AppColors.statusAlpa,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.state.currentUser;
    final durationDays = _endDate.difference(_startDate).inDays + 1;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          HeaderWithGradient(
            userName: 'Form Pengajuan Izin',
            userSubtitle: '${user.name} • ${user.className}',
            badgeText: widget.state.activeCycle.label,
            actionButton: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: widget.onBack,
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Jenis Perizinan (4 Tipe sesuai Website SCP_SMK)
                    Text('Jenis Perizinan', style: AppTypography.sectionTitle),
                    const SizedBox(height: 4),
                    Text(
                      'Pilih kategori izin sesuai kondisi atau kegiatan Anda.',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTypeCard(
                            type: LeaveType.sakit,
                            title: 'Sakit',
                            subtitle: 'Surat Dokter / Klinik',
                            icon: Icons.medical_services_outlined,
                            color: AppColors.statusSakit,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTypeCard(
                            type: LeaveType.izin,
                            title: 'Izin',
                            subtitle: 'Keperluan Keluarga',
                            icon: Icons.assignment_outlined,
                            color: AppColors.statusIzin,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTypeCard(
                            type: LeaveType.pulangCepat,
                            title: 'Pulang Cepat',
                            subtitle: 'Izin Meninggalkan KBM',
                            icon: Icons.directions_walk_rounded,
                            color: AppColors.primaryIndigo,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTypeCard(
                            type: LeaveType.kegiatanLuar,
                            title: 'Kegiatan Luar',
                            subtitle: 'Dispensasi / Lomba',
                            icon: Icons.emoji_events_outlined,
                            color: AppColors.secondaryTeal,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // 2. Rentang Tanggal & Jam Keluar (bila Pulang Cepat / Kegiatan Luar)
                    Text(
                      'Waktu & Durasi Perizinan',
                      style: AppTypography.sectionTitle,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SoftCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      borderRadius: AppSpacing.radiusLarge,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildDateBox(
                                  label: 'Tanggal Mulai',
                                  date: _startDate,
                                  icon: Icons.calendar_today_rounded,
                                  onTap: () => _pickDate(true),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildDateBox(
                                  label: 'Tanggal Selesai',
                                  date: _endDate,
                                  icon: Icons.event_available_rounded,
                                  onTap: () => _pickDate(false),
                                ),
                              ),
                            ],
                          ),
                          if (_selectedType.requiresLeaveTime) ...[
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: _pickLeaveTime,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.lightIndigoBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.lightIndigoBorder,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time_filled_rounded,
                                      size: 18,
                                      color: AppColors.primaryIndigo,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Jam Meninggalkan Kelas / Mulai Kegiatan',
                                            style: AppTypography.microBadge
                                                .copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          Text(
                                            '$_formattedLeaveTime WIB',
                                            style: AppTypography.tabularFigure.copyWith(
                                              fontSize: 14,
                                              color: AppColors.primaryIndigo,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'Ubah Jam',
                                      style: AppTypography.microBadge.copyWith(
                                        color: AppColors.primaryIndigo,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusPill,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  size: 14,
                                  color: AppColors.secondaryTeal,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Total Durasi Izin: $durationDays Hari',
                                    style: AppTypography.microBadge.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.secondaryTeal,
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
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // 3. Alasan Izin
                    Text(
                      'Keterangan / Alasan Lengkap',
                      style: AppTypography.sectionTitle,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SoftCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      borderRadius: AppSpacing.radiusLarge,
                      child: TextFormField(
                        controller: _reasonController,
                        maxLines: 4,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText:
                              'Tuliskan alasan perizinan secara jelas (contoh: demam tinggi sesuai surat dokter, mengikuti lomba LKS, dsb.)',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Alasan perizinan tidak boleh kosong';
                          }
                          if (value.trim().length < 10) {
                            return 'Jelaskan alasan minimal 10 karakter';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // 4. Bukti Dokumen Pendukung
                    Text(
                      'Lampiran Bukti Surat / Dokumen',
                      style: AppTypography.sectionTitle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Unggah foto surat dokter, surat izin orang tua, atau surat dispensasi (JPG, PNG, PDF maks. 2MB).',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    if (_attachedFileName != null)
                      SoftCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        borderRadius: AppSpacing.radiusLarge,
                        color: AppColors.statusApprovedBg.withValues(alpha: 0.6),
                        border: Border.all(
                          color: AppColors.statusHadir.withValues(alpha: 0.4),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.statusHadir,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _attachedFileName!,
                                    style: AppTypography.cardTitle.copyWith(
                                      fontSize: 13,
                                      color: AppColors.statusApprovedText,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '1.2 MB • Siap dikirim ke Wali Kelas / BK',
                                    style: AppTypography.microBadge.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: AppColors.statusAlpa,
                              ),
                              onPressed: () => setState(() {
                                _pickedFile = null;
                                _attachedFileName = null;
                              }),
                            ),
                          ],
                        ),
                      )
                    else
                      SoftCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        borderRadius: AppSpacing.radiusLarge,
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.primaryIndigo,
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.camera_alt_outlined,
                                  color: AppColors.primaryIndigo,
                                  size: 18,
                                ),
                                label: Text(
                                  'Ambil Foto',
                                  style: AppTypography.microBadge.copyWith(
                                    color: AppColors.primaryIndigo,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                                onPressed: () => _pickAttachment(ImageSource.camera),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.secondaryTeal,
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.upload_file_rounded,
                                  color: AppColors.secondaryTeal,
                                  size: 18,
                                ),
                                label: Text(
                                  'Pilih File/PDF',
                                  style: AppTypography.microBadge.copyWith(
                                    color: AppColors.secondaryTeal,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                                onPressed: () => _pickAttachment(ImageSource.gallery),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Sticky Bottom Action Bar (One-Handed Ergonomics)
          Container(
            padding: EdgeInsets.only(
              top: 12,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
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
            child: PrimaryButton(
              label: 'Kirim Surat Izin',
              icon: Icons.send_rounded,
              isLoading: _isSubmitting,
              onPressed: _handleSubmit,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard({
    required LeaveType type,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final bool isSelected = _selectedType == type;
    return InkWell(
      onTap: () => setState(() => _selectedType = type),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected
                    ? color
                    : color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : color,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.cardTitle.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.microBadge.copyWith(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBox({
    required String label,
    required DateTime date,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.microBadge),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(icon, size: 15, color: AppColors.primaryIndigo),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                    style: AppTypography.cardTitle.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
