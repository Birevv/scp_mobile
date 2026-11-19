import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../constants/app_spacing.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/headers/header_with_gradient.dart';
import '../../widgets/cards/soft_card.dart';
import '../../widgets/cards/data_state_view.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/attendance/attendance_status_toggle.dart';

class GuruJournalInputScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback onBack;
  final VoidCallback onSuccess;
  final TeachingJournal? editingJournal;

  const GuruJournalInputScreen({
    super.key,
    required this.state,
    required this.onBack,
    required this.onSuccess,
    this.editingJournal,
  });

  @override
  State<GuruJournalInputScreen> createState() => _GuruJournalInputScreenState();
}

class _GuruJournalInputScreenState extends State<GuruJournalInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _notesController = TextEditingController();

  XFile? _pickedPhoto;
  String? _activityPhotoName;
  bool _isSubmitting = false;

  TeachingJournal? _activeJournal;
  List<StudentAttendance> _roster = [];

  bool get _isEditMode => widget.editingJournal != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final journal = widget.editingJournal!;
      _activeJournal = journal;
      _topicController.text = journal.topic;
      final existingNotes = (journal.notes ?? '').trim();
      _notesController.text = existingNotes == '-' ? '' : existingNotes;
      if (journal.attendances.isNotEmpty) {
        _roster = journal.attendances.map((s) => s.copyWith()).toList();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadJournalDetailForEdit();
      });
    } else {
      _loadInitialRoster();
    }
  }

  Future<void> _loadJournalDetailForEdit() async {
    final journal = _activeJournal ?? widget.editingJournal;
    if (journal == null) return;
    final detail = await widget.state.fetchTeacherJournalDetailData(journal.id);
    if (!mounted || detail == null) return;
    setState(() {
      _activeJournal = detail;
      if (detail.attendances.isNotEmpty) {
        _roster = detail.attendances.map((s) => s.copyWith()).toList();
      }
    });
  }

  TeachingSchedule? _resolveActiveSchedule() {
    final selected = widget.state.selectedJournalSchedule;
    if (selected != null) return selected;
    final unFilled =
        widget.state.todaySchedules.where((s) => !s.hasJournal).toList();
    if (unFilled.isNotEmpty) return unFilled.first;
    if (widget.state.todaySchedules.isNotEmpty) {
      return widget.state.todaySchedules.first;
    }
    return null;
  }

  Future<void> _loadInitialRoster() async {
    final sched = _resolveActiveSchedule();

    if (sched != null) {
      widget.state.selectScheduleForJournal(sched);
      await widget.state.fetchScheduleStudentsRoster(sched.id);
      if (mounted) {
        setState(() {
          _roster = widget.state.classRoster.map((s) => s.copyWith()).toList();
        });
      }
    }
  }

  void _showSchedulePicker(BuildContext context) {
    final schedules = widget.state.todaySchedules;

    if (schedules.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pilih Jadwal Mengajar',
                        style: AppTypography.cardTitle.copyWith(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: schedules.length,
                    itemBuilder: (_, index) {
                      final item = schedules[index];
                      final isSelected = widget.state.selectedJournalSchedule?.id == item.id;
                      final isAlreadyFilled = item.hasJournal;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isAlreadyFilled
                              ? AppColors.alertGreenBg
                              : AppColors.alertAmberBg,
                          child: Icon(
                            isAlreadyFilled
                                ? Icons.check_circle_rounded
                                : Icons.edit_note_rounded,
                            color: isAlreadyFilled
                                ? AppColors.statusHadir
                                : AppColors.statusSakit,
                            size: 20,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.subjectName,
                                style: AppTypography.cardTitle.copyWith(
                                  fontSize: 14,
                                  color: isAlreadyFilled ? AppColors.textTertiary : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (isAlreadyFilled)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.alertGreenBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Sudah Diisi',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.statusHadir,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          '${item.className} • ${item.roomName} (${item.startTime} - ${item.endTime} WIB)',
                          style: AppTypography.caption.copyWith(
                            color: isAlreadyFilled ? AppColors.textTertiary : AppColors.textSecondary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_rounded, color: AppColors.primaryIndigo)
                            : null,
                        enabled: !isAlreadyFilled,
                        onTap: isAlreadyFilled
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Jadwal ini sudah diisi jurnal hari ini. Tidak dapat diisi lagi.'),
                                    backgroundColor: AppColors.statusAlpa,
                                  ),
                                );
                              }
                            : () async {
                                Navigator.pop(ctx);
                                widget.state.selectScheduleForJournal(item);
                                await widget.state.fetchScheduleStudentsRoster(item.id);
                                if (mounted) {
                                  setState(() {
                                    _roster = widget.state.classRoster
                                        .map((s) => s.copyWith())
                                        .toList();
                                  });
                                }
                              },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _topicController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto([ImageSource source = ImageSource.camera]) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _pickedPhoto = picked;
          _activityPhotoName = picked.name;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Foto kegiatan kelas berhasil diambil: ${picked.name}'),
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
          content: Text('Gagal mengambil foto dari kamera: $e'),
          backgroundColor: AppColors.statusAlpa,
        ),
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isEditMode) {
      final journal = _activeJournal ?? widget.editingJournal;
      if (journal == null) return;

      setState(() => _isSubmitting = true);

      final res = await widget.state.updateTeacherJournalData(
        journalId: journal.id,
        topic: _topicController.text.trim(),
        notes: _notesController.text.trim(),
        roster: _roster,
        photoFilePath: _pickedPhoto?.path,
        photoFileName: _pickedPhoto?.name,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (res.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perubahan jurnal & presensi berhasil disimpan!'),
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
      return;
    }

    final sched = _resolveActiveSchedule();

    if (sched == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada jadwal pelajaran aktif untuk jurnal ini.'),
          backgroundColor: AppColors.statusAlpa,
        ),
      );
      return;
    }

    if (sched.hasJournal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jurnal untuk jadwal mengajar ini sudah pernah diisi hari ini.'),
          backgroundColor: AppColors.statusAlpa,
        ),
      );
      return;
    }

    if (!widget.state.canFillScheduleToday(sched)) {
      final reason = widget.state.journalIneligibilityReason(sched) ??
          'Jurnal mengajar hanya dapat diisi pada hari jadwal berlangsung.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reason),
          backgroundColor: AppColors.statusAlpa,
        ),
      );
      return;
    }

    if (_pickedPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bukti foto kegiatan mengajar wajib diambil secara realtime via kamera!',
          ),
          backgroundColor: AppColors.statusAlpa,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final res = await widget.state.submitTeacherJournalData(
      scheduleId: sched.id,
      topic: _topicController.text.trim(),
      notes: _notesController.text.trim(),
      roster: _roster,
      photoFilePath: _pickedPhoto?.path,
      photoFileName: _pickedPhoto?.name,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jurnal pembelajaran & presensi berhasil disimpan!'),
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

  AttendanceStatus _parseStatus(String code) {
    switch (code) {
      case 'H':
        return AttendanceStatus.hadir;
      case 'I':
        return AttendanceStatus.izin;
      case 'S':
        return AttendanceStatus.sakit;
      case 'A':
      default:
        return AttendanceStatus.alpa;
    }
  }

  String _statusCode(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.hadir:
        return 'H';
      case AttendanceStatus.izin:
        return 'I';
      case AttendanceStatus.sakit:
        return 'S';
      case AttendanceStatus.alpa:
        return 'A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final journal = _activeJournal ?? widget.editingJournal;
    final sched = _isEditMode ? null : _resolveActiveSchedule();
    final bool canFill = _isEditMode
        ? (!widget.state.isLoadingJournalDetail && !_isSubmitting)
        : (sched != null && widget.state.canFillScheduleToday(sched));
    final String? ineligibilityMessage =
        (!_isEditMode && sched != null && !sched.hasJournal && !canFill)
            ? widget.state.journalIneligibilityReason(sched)
            : null;
    final String submitButtonLabel = _isEditMode
        ? 'Simpan Perubahan Jurnal'
        : (sched != null && sched.hasJournal)
            ? 'Jurnal Sudah Pernah Diisi'
            : (sched != null && !canFill)
                ? 'Jadwal Belum Dapat Diisi'
                : 'Simpan Jurnal & Presensi Kelas';

    final int hadirCount =
        _roster.where((r) => r.status == AttendanceStatus.hadir).length;
    final int izinCount =
        _roster.where((r) => r.status == AttendanceStatus.izin).length;
    final int sakitCount =
        _roster.where((r) => r.status == AttendanceStatus.sakit).length;
    final int alpaCount =
        _roster.where((r) => r.status == AttendanceStatus.alpa).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.md,
          bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: const Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: PrimaryButton(
          label: submitButtonLabel,
          icon: _isEditMode
              ? Icons.save_rounded
              : (sched != null && sched.hasJournal)
                  ? Icons.check_circle_rounded
                  : (sched != null && !canFill)
                      ? Icons.lock_clock_rounded
                      : Icons.check_circle_outline,
          isLoading: _isSubmitting,
          onPressed: canFill ? _handleSubmit : null,
        ),
      ),
      body: Column(
        children: [
          HeaderWithGradient(
            userName: _isEditMode
                ? 'Edit Jurnal & Presensi'
                : 'Input Jurnal & Presensi',
            userSubtitle: _isEditMode && journal != null
                ? '${journal.className} • ${journal.subjectName}'
                : sched != null
                    ? '${sched.className} • ${sched.subjectName}'
                    : 'Pilih Jadwal Mengajar',
            badgeText: _isEditMode && journal != null
                ? TeachingSchedule.formatShortIndonesianDate(journal.date)
                : widget.state.currentDateLabel,
            leading: IconButton(
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
                    // Class Summary Header Card
                    if (_isEditMode && journal != null)
                      SoftCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
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
                                  Text(
                                    journal.subjectName,
                                    style: AppTypography.cardTitle.copyWith(
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${journal.className} • ${journal.roomName}',
                                    style: AppTypography.smallHint.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    journal.timeSlot.isNotEmpty
                                        ? '${TeachingSchedule.formatShortIndonesianDate(journal.date)} • ${journal.timeSlot}'
                                        : TeachingSchedule.formatShortIndonesianDate(journal.date),
                                    style: AppTypography.smallHint.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryIndigo,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (sched != null)
                      SoftCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
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
                                  Text(
                                    sched.subjectName,
                                    style: AppTypography.cardTitle.copyWith(
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${sched.className} • ${sched.roomName}',
                                    style: AppTypography.smallHint.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${sched.startTime} - ${sched.endTime} WIB',
                                    style: AppTypography.smallHint.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryIndigo,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (widget.state.todaySchedules.length > 1)
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => _showSchedulePicker(context),
                                icon: const Icon(
                                  Icons.swap_horiz_rounded,
                                  size: 16,
                                  color: AppColors.primaryIndigo,
                                ),
                                label: Text(
                                  'Ganti',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.primaryIndigo,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                    else
                      SoftCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text(
                          'Pilih jadwal mengajar terlebih dahulu dari menu Jadwal Hari Ini.',
                          style: AppTypography.smallHint,
                        ),
                      ),

                    if (sched != null && sched.hasJournal)
                      Container(
                        margin: const EdgeInsets.only(top: AppSpacing.sm),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.alertGreenBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.statusHadir.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.statusApprovedText,
                              size: 18,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'Jurnal untuk jadwal ini sudah diisi hari ini. Setiap jadwal hanya dapat diisi 1 kali.',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.statusApprovedText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (ineligibilityMessage != null)
                      Container(
                        margin: const EdgeInsets.only(top: AppSpacing.sm),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm + 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFFDE68A),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.event_busy_rounded,
                              color: Color(0xFF92400E),
                              size: 18,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                ineligibilityMessage,
                                style: AppTypography.caption.copyWith(
                                  color: const Color(0xFF92400E),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: AppSpacing.lg),

                    // SECTION 1: Jurnal Pembelajaran
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryIndigo,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              '1',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Jurnal Pembelajaran (Wajib)',
                            style: AppTypography.sectionTitle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Teaching Topic Textarea
                    Text('Materi & Topik Pembelajaran *',
                        style: AppTypography.smallHint),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _topicController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText:
                            'Tuliskan kompetensi dasar dan materi yang diajarkan hari ini...',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Materi pembelajaran tidak boleh kosong!';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Notes Textarea
                    Text(
                      'Catatan Tambahan / Kendala Siswa (Opsional)',
                      style: AppTypography.smallHint,
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText:
                            'Kendala lab komputer, siswa yang membutuhkan remidi, dsb.',
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Camera Photo Activity Attachment (Real-time only)
                    Text(
                      _isEditMode
                          ? 'Dokumentasi Foto Kegiatan Kelas'
                          : 'Dokumentasi Foto Kegiatan Kelas (Wajib Realtime)',
                      style: AppTypography.cardTitle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isEditMode
                          ? 'Foto tersimpan akan tetap digunakan jika Anda tidak mengambil foto baru. Ambil ulang langsung dari kamera jika ingin memperbarui.'
                          : 'Ambil foto dokumentasi kegiatan kelas langsung melalui kamera (real-time). Unggah file galeri dinonaktifkan.',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    if (_activityPhotoName != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.alertGreenBg,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMedium,
                          ),
                          border: Border.all(
                            color: AppColors.statusHadir.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.photo_camera_back,
                              color: AppColors.statusHadir,
                              size: 28,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _activityPhotoName!,
                                    style: AppTypography.smallHint.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF065F46),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _isEditMode
                                        ? 'Foto baru siap menggantikan foto sebelumnya'
                                        : 'Foto kamera realtime kegiatan terlampir',
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
                                _pickedPhoto = null;
                                _activityPhotoName = null;
                              }),
                            ),
                          ],
                        ),
                      ),
                    ] else if (_isEditMode &&
                        journal != null &&
                        journal.photoUrl != null &&
                        journal.photoUrl!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.lightIndigoBg,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMedium,
                          ),
                          border: Border.all(color: AppColors.lightIndigoBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: AppColors.primaryIndigo,
                              size: 24,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Foto dokumentasi tersimpan',
                                    style: AppTypography.smallHint.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.brandNavy,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Tetap digunakan kecuali Anda mengambil foto baru.',
                                    style: AppTypography.microBadge.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.primaryIndigo,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMedium,
                              ),
                            ),
                          ),
                          icon: const Icon(
                            Icons.camera_alt_rounded,
                            color: AppColors.primaryIndigo,
                            size: 20,
                          ),
                          label: Text(
                            'Ambil Ulang Foto (Kamera Realtime)',
                            style: AppTypography.labelButton.copyWith(
                              color: AppColors.primaryIndigo,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: () => _pickPhoto(ImageSource.camera),
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.primaryIndigo,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMedium,
                              ),
                            ),
                          ),
                          icon: const Icon(
                            Icons.camera_alt_rounded,
                            color: AppColors.primaryIndigo,
                            size: 20,
                          ),
                          label: Text(
                            'Ambil Foto Kegiatan (Kamera Realtime)',
                            style: AppTypography.labelButton.copyWith(
                              color: AppColors.primaryIndigo,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: () => _pickPhoto(ImageSource.camera),
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xl),

                    // SECTION 2: Checklist Presensi Siswa
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: AppColors.secondaryTeal,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              '2',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Checklist Presensi Siswa',
                            style: AppTypography.sectionTitle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pilih status: [H] Hadir, [I] Izin, [S] Sakit, [A] Alpa.',
                      style: AppTypography.smallHint,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Attendance Stats Bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMedium,
                        ),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMiniCounter(
                              'Hadir',
                              hadirCount,
                              AppColors.statusHadir,
                            ),
                            const SizedBox(width: 14),
                            _buildMiniCounter(
                              'Izin',
                              izinCount,
                              AppColors.statusIzin,
                            ),
                            const SizedBox(width: 14),
                            _buildMiniCounter(
                              'Sakit',
                              sakitCount,
                              AppColors.statusSakit,
                            ),
                            const SizedBox(width: 14),
                            _buildMiniCounter(
                              'Alpa',
                              alpaCount,
                              AppColors.statusAlpa,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Student Roster
                    if (_isEditMode &&
                        widget.state.isLoadingJournalDetail &&
                        _roster.isEmpty)
                      const DataLoadingCard(
                        message: 'Memuat detail jurnal & presensi siswa...',
                      )
                    else if (_isEditMode &&
                        widget.state.journalDetailError != null &&
                        _roster.isEmpty)
                      DataErrorCard(
                        message: widget.state.journalDetailError!,
                        onRetry: _loadJournalDetailForEdit,
                      )
                    else if (!_isEditMode &&
                        widget.state.isLoadingRoster &&
                        _roster.isEmpty)
                      const DataLoadingCard(
                        message: 'Memuat daftar siswa dari server...',
                      )
                    else if (_roster.isEmpty)
                      SoftCard(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'Belum ada data siswa untuk jadwal ini.',
                              style: AppTypography.smallHint,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _roster.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final student = _roster[index];

                          return SoftCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm + 2,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.lightIndigoBg,
                                  child: Text(
                                    student.studentName.isNotEmpty
                                        ? student.studentName[0].toUpperCase()
                                        : 'S',
                                    style: AppTypography.cardTitle.copyWith(
                                      fontSize: 13,
                                      color: AppColors.primaryIndigo,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              student.studentName,
                                              style: AppTypography.cardTitle
                                                  .copyWith(
                                                fontSize: 13,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (student.isAutoSynced)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 1,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.alertGreenBg,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  AppSpacing.radiusSmall,
                                                ),
                                              ),
                                              child: Text(
                                                'Izin Disetujui',
                                                style: AppTypography.microBadge
                                                    .copyWith(
                                                  color: AppColors.statusHadir,
                                                  fontSize: 9,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'NISN. ${student.nisn}',
                                        style: AppTypography.smallHint.copyWith(
                                          color: AppColors.textTertiary,
                                          fontSize: 11,
                                        ),
                                      ),
                                      if (student.leaveReason != null &&
                                          student.leaveReason!.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'Ket: ${student.leaveReason}',
                                          style: AppTypography.microBadge
                                              .copyWith(
                                            color: AppColors.statusIzin,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                // 4-Way Status Toggle
                                AttendanceStatusToggle(
                                  initialStatus: _statusCode(student.status),
                                  onStatusChanged: (newCode) {
                                    setState(() {
                                      student.status = _parseStatus(newCode);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCounter(String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: AppTypography.microBadge.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '$count',
          style: AppTypography.microBadge.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
