import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../constants/app_spacing.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/headers/header_with_gradient.dart';
import '../../widgets/cards/soft_card.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/buttons/pill_button.dart';
import '../../widgets/modals/schedule_conflict_bottom_sheet.dart';

class GuruScheduleInputScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback onBack;
  final VoidCallback onSuccess;

  const GuruScheduleInputScreen({
    super.key,
    required this.state,
    required this.onBack,
    required this.onSuccess,
  });

  @override
  State<GuruScheduleInputScreen> createState() =>
      _GuruScheduleInputScreenState();
}

class _GuruScheduleInputScreenState extends State<GuruScheduleInputScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedDay = 'Senin';
  late CycleType _selectedCycle;

  int? _selectedClassroomId;
  int? _selectedRoomId;
  int? _selectedSubjectId;

  TimeOfDay _startTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 15);

  bool _isSubmitting = false;

  final List<String> _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];

  @override
  void initState() {
    super.initState();
    _selectedCycle = widget.state.activeCycle;
    _initReferenceData();
  }

  Future<void> _initReferenceData() async {
    if (widget.state.classrooms.isEmpty ||
        widget.state.rooms.isEmpty ||
        widget.state.subjects.isEmpty) {
      await widget.state.fetchReferenceData();
    }
    if (mounted) {
      setState(() {
        if (widget.state.classrooms.isNotEmpty &&
            _selectedClassroomId == null) {
          _selectedClassroomId = widget.state.classrooms.first.id;
        }
        if (widget.state.rooms.isNotEmpty && _selectedRoomId == null) {
          _selectedRoomId = widget.state.rooms.first.id;
        }
        if (widget.state.subjects.isNotEmpty && _selectedSubjectId == null) {
          _selectedSubjectId = widget.state.subjects.first.id;
        }
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
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
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  int _calculateDurationMinutes() {
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    return endMinutes > startMinutes ? endMinutes - startMinutes : 0;
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hour.toString().padLeft(2, '0');
    final minute = tod.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _handleSaveSchedule() async {
    if (!_formKey.currentState!.validate()) return;

    final classId = _selectedClassroomId;
    final roomId = _selectedRoomId;
    final subjectId = _selectedSubjectId;

    if (classId == null || roomId == null || subjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilihan kelas, ruangan, dan mata pelajaran wajib diisi!'),
          backgroundColor: AppColors.statusAlpa,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final res = await widget.state.createTeacherSchedule(
      dayOfWeek: _selectedDay,
      startTime: _formatTimeOfDay(_startTime),
      endTime: _formatTimeOfDay(_endTime),
      classroomId: classId,
      roomId: roomId,
      subjectId: subjectId,
      cycle: _selectedCycle,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jadwal mengajar berhasil disimpan ke server!'),
          backgroundColor: AppColors.statusHadir,
        ),
      );
      widget.onSuccess();
    } else {
      final isConflict = res.statusCode == 422 ||
          res.message.toLowerCase().contains('bentrok') ||
          res.message.toLowerCase().contains('tabrakan');

      if (isConflict) {
        ScheduleConflictBottomSheet.show(
          context: context,
          conflictType: 'Bentrok Jadwal / Ruangan',
          conflictDescription: res.message,
          onChangeSchedule: () {},
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message),
            backgroundColor: AppColors.statusAlpa,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final durationMins = _calculateDurationMinutes();
    final durationHours = durationMins / 60.0;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    final classrooms = widget.state.classrooms;
    final rooms = widget.state.rooms;
    final subjects = widget.state.subjects;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: Container(
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
        child: PrimaryButton(
          label: 'Simpan Jadwal Mengajar',
          icon: Icons.check_circle_outline_rounded,
          isLoading: _isSubmitting,
          onPressed: _handleSaveSchedule,
        ),
      ),
      body: Column(
        children: [
          HeaderWithGradient(
            userName: 'Tambah Jadwal Mengajar',
            userSubtitle: widget.state.currentUser.name,
            actionButton: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                    // Cycle Type
                    Text('Siklus Pembelajaran (Blok Tefa)',
                        style: AppTypography.cardTitle),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: PillButton(
                            label: 'Putaran 1 (Teori)',
                            isActive: _selectedCycle == CycleType.putaran1,
                            onPressed: () => setState(
                                () => _selectedCycle = CycleType.putaran1),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: PillButton(
                            label: 'Putaran 2 (Praktik)',
                            isActive: _selectedCycle == CycleType.putaran2,
                            onPressed: () => setState(
                                () => _selectedCycle = CycleType.putaran2),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Day of Week
                    Text('Hari Mengajar', style: AppTypography.cardTitle),
                    const SizedBox(height: AppSpacing.sm),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _days.map((day) {
                          return Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.sm),
                            child: PillButton(
                              label: day,
                              isActive: _selectedDay == day,
                              onPressed: () =>
                                  setState(() => _selectedDay = day),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Kelas
                    Text('Kelas', style: AppTypography.cardTitle),
                    const SizedBox(height: AppSpacing.sm),
                    SoftCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 4,
                      ),
                      child: classrooms.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text('Memuat daftar kelas...'),
                            )
                          : DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _selectedClassroomId ??
                                    (classrooms.isNotEmpty
                                        ? classrooms.first.id
                                        : null),
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: AppColors.primaryIndigo,
                                ),
                                items: classrooms.map((cls) {
                                  return DropdownMenuItem<int>(
                                    value: cls.id,
                                    child: Text(
                                      cls.name,
                                      style: AppTypography.cardTitle.copyWith(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedClassroomId = val);
                                  }
                                },
                              ),
                            ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Mata Pelajaran
                    Text('Mata Pelajaran', style: AppTypography.cardTitle),
                    const SizedBox(height: AppSpacing.sm),
                    SoftCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 4,
                      ),
                      child: subjects.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text('Memuat daftar mapel...'),
                            )
                          : DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _selectedSubjectId ??
                                    (subjects.isNotEmpty
                                        ? subjects.first.id
                                        : null),
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: AppColors.primaryIndigo,
                                ),
                                items: subjects.map((sub) {
                                  return DropdownMenuItem<int>(
                                    value: sub.id,
                                    child: Text(
                                      sub.name,
                                      style: AppTypography.cardTitle.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedSubjectId = val);
                                  }
                                },
                              ),
                            ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Ruangan / Lab
                    Text('Ruangan / Lab Praktik',
                        style: AppTypography.cardTitle),
                    const SizedBox(height: AppSpacing.sm),
                    SoftCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 4,
                      ),
                      child: rooms.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text('Memuat daftar ruangan...'),
                            )
                          : DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _selectedRoomId ??
                                    (rooms.isNotEmpty ? rooms.first.id : null),
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: AppColors.primaryIndigo,
                                ),
                                items: rooms.map((room) {
                                  return DropdownMenuItem<int>(
                                    value: room.id,
                                    child: Text(
                                      room.name,
                                      style: AppTypography.cardTitle.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedRoomId = val);
                                  }
                                },
                              ),
                            ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Rentang Waktu KBM
                    Text('Rentang Waktu Pelajaran (KBM)',
                        style: AppTypography.cardTitle),
                    const SizedBox(height: AppSpacing.sm),
                    SoftCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _pickTime(true),
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMedium,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(
                                      AppSpacing.md,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusMedium,
                                      ),
                                      border: Border.all(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Jam Mulai',
                                            style: AppTypography.smallHint),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.access_time_rounded,
                                              size: 16,
                                              color: AppColors.primaryIndigo,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              _formatTimeOfDay(_startTime),
                                              style: AppTypography.cardTitle
                                                  .copyWith(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  color: AppColors.textTertiary,
                                  size: 18,
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _pickTime(false),
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMedium,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(
                                      AppSpacing.md,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusMedium,
                                      ),
                                      border: Border.all(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Jam Selesai',
                                            style: AppTypography.smallHint),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.access_time_filled_rounded,
                                              size: 16,
                                              color: AppColors.primaryIndigo,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              _formatTimeOfDay(_endTime),
                                              style: AppTypography.cardTitle
                                                  .copyWith(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.timer_outlined,
                                size: 14,
                                color: AppColors.secondaryTeal,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Durasi: $durationMins Menit (${durationHours.toStringAsFixed(1)} Jam Pelajaran)',
                                style: AppTypography.smallHint.copyWith(
                                  color: AppColors.secondaryTeal,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
