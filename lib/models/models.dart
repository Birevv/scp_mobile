import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum UserRole {
  siswa('Siswa'),
  guru('Guru Mata Pelajaran'),
  waliKelas('Wali Kelas'),
  guruBk('Guru BK'),
  unsupported('Akses Panel Web');

  final String title;
  const UserRole(this.title);

  bool get isHomeroomOrBk =>
      this == UserRole.waliKelas || this == UserRole.guruBk;

  bool get isTeacher => this == UserRole.guru || this == UserRole.waliKelas;

  bool get isMobileSupported => this != UserRole.unsupported;

  static UserRole fromApiRole(String? roleName) {
    final normalized = (roleName ?? '').trim().toLowerCase();
    if (normalized == 'siswa') return UserRole.siswa;
    if (normalized == 'guru') return UserRole.guru;
    if (normalized == 'wali kelas') return UserRole.waliKelas;
    if (normalized == 'guru bk') return UserRole.guruBk;
    return UserRole.unsupported;
  }
}

enum CycleType {
  putaran1('Putaran 1', 'Minggu Blok 1 & 2 (Teori / Workshop A)'),
  putaran2('Putaran 2', 'Minggu Blok 3 & 4 (Praktik Tefa / Lab B)');

  final String label;
  final String description;
  const CycleType(this.label, this.description);

  static CycleType fromString(String? value) {
    if (value != null && value.toLowerCase().contains('2')) {
      return CycleType.putaran2;
    }
    return CycleType.putaran1;
  }
}

enum AttendanceStatus {
  hadir('Hadir', AppColors.successHadir, AppColors.alertGreenBg),
  izin('Izin', AppColors.infoIzin, AppColors.alertBlueBg),
  sakit('Sakit', AppColors.warningSakit, AppColors.alertAmberBg),
  alpa('Alpa', AppColors.errorAlpa, AppColors.alertRedBg);

  final String label;
  final Color color;
  final Color bgColor;
  const AttendanceStatus(this.label, this.color, this.bgColor);

  static AttendanceStatus fromString(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'izin':
        return AttendanceStatus.izin;
      case 'sakit':
        return AttendanceStatus.sakit;
      case 'alpa':
        return AttendanceStatus.alpa;
      case 'hadir':
      default:
        return AttendanceStatus.hadir;
    }
  }
}

enum LeaveStatus {
  pending('Pending', AppColors.statusPendingText, AppColors.statusPendingBg),
  approved('Approved', AppColors.statusApprovedText, AppColors.statusApprovedBg),
  rejected('Rejected', AppColors.statusRejectedText, AppColors.statusRejectedBg);

  final String label;
  final Color color;
  final Color bgColor;
  const LeaveStatus(this.label, this.color, this.bgColor);

  String get displayLabel {
    switch (this) {
      case LeaveStatus.pending:
        return 'Menunggu Verifikasi';
      case LeaveStatus.approved:
        return 'Disetujui';
      case LeaveStatus.rejected:
        return 'Ditolak';
    }
  }

  static LeaveStatus fromString(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'approved':
      case 'disetujui':
        return LeaveStatus.approved;
      case 'rejected':
      case 'ditolak':
        return LeaveStatus.rejected;
      case 'pending':
      default:
        return LeaveStatus.pending;
    }
  }
}

/// Sinkron dengan ReasonTypeEnum di Website (SCP_SMK/app/Enums/ReasonTypeEnum.php)
/// dan StoreLeaveRequest.php: sakit, izin, pulang_cepat, kegiatan_luar
enum LeaveType {
  sakit('Sakit', 'Sakit', 'Surat Keterangan Dokter / Klinik', false),
  izin('Izin', 'Izin', 'Keperluan Keluarga / Mendesak', false),
  pulangCepat(
    'Pulang Cepat',
    'Pulang Cepat',
    'Izin Meninggalkan Sekolah Lebih Awal',
    true,
  ),
  kegiatanLuar(
    'Kegiatan Luar',
    'Kegiatan Luar',
    'Dispensasi Lomba / Tugas Sekolah',
    true,
  );

  final String label;
  final String apiValue;
  final String description;
  final bool requiresLeaveTime;
  const LeaveType(
    this.label,
    this.apiValue,
    this.description,
    this.requiresLeaveTime,
  );

  static LeaveType fromString(String? value) {
    final normalized = (value ?? '').toLowerCase().replaceAll(' ', '_');
    if (normalized.contains('sakit')) return LeaveType.sakit;
    if (normalized.contains('pulang')) return LeaveType.pulangCepat;
    if (normalized.contains('kegiatan') || normalized.contains('luar')) {
      return LeaveType.kegiatanLuar;
    }
    return LeaveType.izin;
  }
}

class AcademicEventInfo {
  final int id;
  final String title;
  final String category;
  final String categoryLabel;
  final bool isHoliday;
  final bool disableKbm;
  final bool requiresAttendance;
  final String? startDate;
  final String? endDate;
  final String? description;
  final bool isConfigured;
  final String? statusLabel;

  const AcademicEventInfo({
    this.id = 0,
    required this.title,
    required this.category,
    required this.categoryLabel,
    this.isHoliday = false,
    this.disableKbm = false,
    this.requiresAttendance = true,
    this.startDate,
    this.endDate,
    this.description,
    this.isConfigured = false,
    this.statusLabel,
  });

  factory AcademicEventInfo.unconfigured() {
    return const AcademicEventInfo(
      title: 'Informasi kalender belum tersedia.',
      category: 'unconfigured',
      categoryLabel: 'Kalender Akademik',
      isHoliday: false,
      disableKbm: false,
      requiresAttendance: false,
      isConfigured: false,
      statusLabel: 'Belum Dikonfigurasi',
    );
  }

  factory AcademicEventInfo.fromJson(Map<String, dynamic> json) {
    return AcademicEventInfo(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? 'Informasi kalender belum tersedia.').toString(),
      category: (json['category'] ?? 'kegiatan').toString(),
      categoryLabel:
          (json['category_label'] ?? 'Agenda Akademik').toString(),
      isHoliday: json['is_holiday'] == true,
      disableKbm: json['disable_kbm'] == true,
      requiresAttendance: json['requires_attendance'] != false,
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      description: json['description']?.toString(),
      isConfigured: json['is_configured'] != false,
      statusLabel: json['status_label']?.toString(),
    );
  }
}

class ReferenceOption {
  final int id;
  final String name;

  const ReferenceOption({
    required this.id,
    required this.name,
  });

  factory ReferenceOption.fromJson(Map<String, dynamic> json) {
    return ReferenceOption(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
    );
  }
}

class StudentAttendanceSummary {
  final String month;
  final int hadir;
  final int sakit;
  final int izin;
  final int alpa;
  final int total;
  final double? percentage;

  const StudentAttendanceSummary({
    this.month = '',
    this.hadir = 0,
    this.sakit = 0,
    this.izin = 0,
    this.alpa = 0,
    this.total = 0,
    this.percentage,
  });

  bool get hasData => total > 0;

  factory StudentAttendanceSummary.fromJson(Map<String, dynamic> json) {
    final int tot = (json['total'] as num?)?.toInt() ?? 0;
    final num? pctNum = json['percentage'] as num?;
    return StudentAttendanceSummary(
      month: (json['month'] ?? '').toString(),
      hadir: (json['hadir'] as num?)?.toInt() ?? 0,
      sakit: (json['sakit'] as num?)?.toInt() ?? 0,
      izin: (json['izin'] as num?)?.toInt() ?? 0,
      alpa: (json['alpa'] as num?)?.toInt() ?? 0,
      total: tot,
      percentage: tot > 0 ? (pctNum?.toDouble() ?? 0.0) : null,
    );
  }
}

class HomeroomAttendanceSummary {
  final String classroomName;
  final int hadir;
  final int sakit;
  final int izin;
  final int alpa;
  final int totalStudents;
  final double percentage;
  final int pendingCount;
  final List<ReferenceOption> classrooms;
  final int? selectedClassroomId;

  const HomeroomAttendanceSummary({
    this.classroomName = '-',
    this.hadir = 0,
    this.sakit = 0,
    this.izin = 0,
    this.alpa = 0,
    this.totalStudents = 0,
    this.percentage = 0.0,
    this.pendingCount = 0,
    this.classrooms = const [],
    this.selectedClassroomId,
  });

  factory HomeroomAttendanceSummary.fromDashboardJson(
    Map<String, dynamic> json,
  ) {
    final att = json['attendance_today'] is Map<String, dynamic>
        ? json['attendance_today'] as Map<String, dynamic>
        : <String, dynamic>{};
    final rawCls = json['classrooms'];
    final parsedCls = rawCls is List
        ? rawCls
            .map((c) => ReferenceOption.fromJson(c as Map<String, dynamic>))
            .toList()
        : const <ReferenceOption>[];
    return HomeroomAttendanceSummary(
      classroomName: (json['classroom_name'] ?? '-').toString(),
      hadir: (att['hadir'] as num?)?.toInt() ?? 0,
      sakit: (att['sakit'] as num?)?.toInt() ?? 0,
      izin: (att['izin'] as num?)?.toInt() ?? 0,
      alpa: (att['alpa'] as num?)?.toInt() ?? 0,
      totalStudents: (att['total_students'] as num?)?.toInt() ?? 0,
      percentage:
          (att['percentage'] as num? ?? att['precentage'] as num?)?.toDouble() ??
              0.0,
      pendingCount: (json['pending_count'] as num?)?.toInt() ?? 0,
      classrooms: parsedCls,
      selectedClassroomId: (json['selected_classroom_id'] as num?)?.toInt(),
    );
  }
}

class HomeroomStudent {
  final String id;
  final String name;
  final String nisn;
  final String className;
  final int? classroomId;
  final int hadir;
  final int sakit;
  final int izin;
  final int alpa;
  final int total;
  final double? percentage;
  final AttendanceStatus todayStatus;
  final bool isAutoSynced;
  final String? leaveReason;

  const HomeroomStudent({
    required this.id,
    required this.name,
    required this.nisn,
    required this.className,
    this.classroomId,
    this.hadir = 0,
    this.sakit = 0,
    this.izin = 0,
    this.alpa = 0,
    this.total = 0,
    this.percentage,
    this.todayStatus = AttendanceStatus.hadir,
    this.isAutoSynced = false,
    this.leaveReason,
  });

  factory HomeroomStudent.fromJson(Map<String, dynamic> json) {
    final int tot = (json['total'] as num?)?.toInt() ?? 0;
    final num? pct = json['percentage'] as num? ?? json['precentage'] as num?;
    return HomeroomStudent(
      id: (json['id'] ?? '').toString(),
      name: (json['student_name'] ?? json['full_name'] ?? '-').toString(),
      nisn: (json['identity_number'] ?? json['nisn'] ?? '-').toString(),
      className: (json['classroom_name'] ?? '-').toString(),
      classroomId: json['classroom_id'] != null
          ? int.tryParse(json['classroom_id'].toString())
          : null,
      hadir: (json['hadir'] as num?)?.toInt() ?? 0,
      sakit: (json['sakit'] as num?)?.toInt() ?? 0,
      izin: (json['izin'] as num?)?.toInt() ?? 0,
      alpa: (json['alpa'] as num?)?.toInt() ?? 0,
      total: tot,
      percentage: tot > 0 ? (pct?.toDouble() ?? 0.0) : null,
      todayStatus: AttendanceStatus.fromString(json['today_status']?.toString()),
      isAutoSynced: json['is_auto_synced'] == true,
      leaveReason: json['leave_reason']?.toString(),
    );
  }
}

class UserProfile {
  final String id;
  final String name;
  final String username;
  final String identifier; // NISN or NIP
  final UserRole role;
  final String roleBadge; // Raw role name from backend
  final String className;
  final String assignment;
  final String email;
  final String phone;
  final String avatarUrl;
  final List<ReferenceOption> assignedClassrooms;

  const UserProfile({
    required this.id,
    required this.name,
    this.username = '',
    required this.identifier,
    required this.role,
    this.roleBadge = '',
    required this.className,
    this.assignment = '',
    required this.email,
    this.phone = '-',
    required this.avatarUrl,
    this.assignedClassrooms = const [],
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? username,
    String? identifier,
    UserRole? role,
    String? roleBadge,
    String? className,
    String? assignment,
    String? email,
    String? phone,
    String? avatarUrl,
    List<ReferenceOption>? assignedClassrooms,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      identifier: identifier ?? this.identifier,
      role: role ?? this.role,
      roleBadge: roleBadge ?? this.roleBadge,
      className: className ?? this.className,
      assignment: assignment ?? this.assignment,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      assignedClassrooms: assignedClassrooms ?? this.assignedClassrooms,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final roleStr = (json['role'] ?? json['role_badge'] ?? '').toString();
    final mappedRole = UserRole.fromApiRole(roleStr);
    final classroom = (json['classroom'] ?? '').toString().trim();
    final assignment =
        (json['assignment'] ?? json['penugasan'] ?? '').toString().trim();
    final effectiveClassOrAssignment = classroom.isNotEmpty
        ? classroom
        : (assignment.isNotEmpty ? assignment : roleStr);

    final rawClassrooms = json['classrooms'];
    final assignedClassrooms = rawClassrooms is List
        ? rawClassrooms
            .map((c) => ReferenceOption.fromJson(c as Map<String, dynamic>))
            .toList()
        : <ReferenceOption>[];

    return UserProfile(
      id: (json['id'] ?? '').toString(),
      name: (json['full_name'] ?? json['username'] ?? '-').toString(),
      username: (json['username'] ?? '').toString(),
      identifier:
          (json['identity_number'] ?? json['nisn_nip'] ?? '-').toString(),
      role: mappedRole,
      roleBadge: roleStr,
      className: effectiveClassOrAssignment.isNotEmpty
          ? effectiveClassOrAssignment
          : '-',
      assignment: assignment,
      email: (json['email'] ?? '-').toString(),
      phone: (json['phone'] ?? '-').toString(),
      avatarUrl: (json['profile_photo_url'] ?? '').toString(),
      assignedClassrooms: assignedClassrooms,
    );
  }
}

class StudentAttendance {
  final String id;
  final int? studentId;
  final String studentName;
  final String nisn;
  final String className;
  AttendanceStatus status;
  final bool isAutoSynced;
  final String? leaveReason;
  String? notes;
  final DateTime date;
  final String time;
  final String subject;
  final String teacherName;

  StudentAttendance({
    required this.id,
    this.studentId,
    required this.studentName,
    required this.nisn,
    required this.className,
    required this.status,
    this.isAutoSynced = false,
    this.leaveReason,
    this.notes,
    required this.date,
    required this.time,
    required this.subject,
    required this.teacherName,
  });

  StudentAttendance copyWith({
    String? id,
    int? studentId,
    String? studentName,
    String? nisn,
    String? className,
    AttendanceStatus? status,
    bool? isAutoSynced,
    String? leaveReason,
    String? notes,
    DateTime? date,
    String? time,
    String? subject,
    String? teacherName,
  }) {
    return StudentAttendance(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      nisn: nisn ?? this.nisn,
      className: className ?? this.className,
      status: status ?? this.status,
      isAutoSynced: isAutoSynced ?? this.isAutoSynced,
      leaveReason: leaveReason ?? this.leaveReason,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      time: time ?? this.time,
      subject: subject ?? this.subject,
      teacherName: teacherName ?? this.teacherName,
    );
  }

  factory StudentAttendance.fromHistoryJson(
    Map<String, dynamic> json, {
    String fallbackStudentName = '',
    String fallbackNisn = '',
    String fallbackClassName = '',
  }) {
    final startTime = (json['start_time'] ?? '').toString();
    final endTime = (json['end_time'] ?? '').toString();
    final timeStr = startTime.isNotEmpty && endTime.isNotEmpty
        ? '${startTime.length >= 5 ? startTime.substring(0, 5) : startTime} - ${endTime.length >= 5 ? endTime.substring(0, 5) : endTime} WIB'
        : (startTime.isNotEmpty ? '$startTime WIB' : '-');
    return StudentAttendance(
      id: (json['id'] ?? '').toString(),
      studentName:
          (json['student_name'] ?? fallbackStudentName).toString(),
      nisn: (json['identity_number'] ?? fallbackNisn).toString(),
      className:
          (json['classroom_name'] ?? fallbackClassName).toString(),
      status: AttendanceStatus.fromString(json['status']?.toString()),
      leaveReason: json['notes']?.toString(),
      notes: json['notes']?.toString(),
      date: DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
      time: timeStr,
      subject: (json['subject_name'] ?? '-').toString(),
      teacherName: (json['teacher_name'] ?? '-').toString(),
    );
  }

  factory StudentAttendance.fromScheduleRosterJson(
    Map<String, dynamic> json, {
    String className = '-',
    String subjectName = '-',
    String teacherName = '-',
  }) {
    final hasApprovedLeave = json['has_approved_leave'] == true;
    final leaveReason = json['leave_reason']?.toString();
    AttendanceStatus initialStatus = AttendanceStatus.hadir;
    if (hasApprovedLeave) {
      if ((leaveReason ?? '').toLowerCase().contains('sakit')) {
        initialStatus = AttendanceStatus.sakit;
      } else {
        initialStatus = AttendanceStatus.izin;
      }
    }
    return StudentAttendance(
      id: (json['id'] ?? '').toString(),
      studentId: (json['id'] as num?)?.toInt(),
      studentName: (json['full_name'] ?? '-').toString(),
      nisn: (json['identity_number'] ?? '-').toString(),
      className: className,
      status: initialStatus,
      isAutoSynced: hasApprovedLeave,
      leaveReason: leaveReason,
      notes: leaveReason,
      date: DateTime.now(),
      time: '-',
      subject: subjectName,
      teacherName: teacherName,
    );
  }
}

class LeaveRequest {
  final String id;
  final String studentName;
  final String nisn;
  final String className;
  final DateTime startDate;
  final DateTime endDate;
  final LeaveType type;
  final String? leaveTime;
  final String reason;
  final String? documentPath;
  final String? documentName;
  LeaveStatus status;
  final String? rejectReason;
  final DateTime submittedAt;
  final String verifiedBy;

  LeaveRequest({
    required this.id,
    required this.studentName,
    required this.nisn,
    required this.className,
    required this.startDate,
    required this.endDate,
    required this.type,
    this.leaveTime,
    required this.reason,
    this.documentPath,
    this.documentName,
    this.status = LeaveStatus.pending,
    this.rejectReason,
    required this.submittedAt,
    this.verifiedBy = '',
  });

  String? get rejectionNote => rejectReason;

  LeaveRequest copyWith({
    String? studentName,
    String? nisn,
    String? className,
    LeaveStatus? status,
    String? rejectReason,
    String? verifiedBy,
    String? documentPath,
    String? documentName,
  }) {
    return LeaveRequest(
      id: id,
      studentName: studentName ?? this.studentName,
      nisn: nisn ?? this.nisn,
      className: className ?? this.className,
      startDate: startDate,
      endDate: endDate,
      type: type,
      leaveTime: leaveTime,
      reason: reason,
      documentPath: documentPath ?? this.documentPath,
      documentName: documentName ?? this.documentName,
      status: status ?? this.status,
      rejectReason: rejectReason ?? this.rejectReason,
      submittedAt: submittedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
    );
  }

  factory LeaveRequest.fromJson(
    Map<String, dynamic> json, {
    String fallbackStudentName = '-',
    String fallbackNisn = '-',
    String fallbackClass = '-',
  }) {
    final studentMap = json['student'] is Map<String, dynamic>
        ? json['student'] as Map<String, dynamic>
        : null;
    final leaveInfoMap = json['leave_info'] is Map<String, dynamic>
        ? json['leave_info'] as Map<String, dynamic>
        : json;

    final attachmentUrl =
        (leaveInfoMap['attachment_url'] ?? json['attachment_url'])?.toString();

    return LeaveRequest(
      id: (json['id'] ?? '').toString(),
      studentName: (json['student_name'] ??
              studentMap?['full_name'] ??
              fallbackStudentName)
          .toString(),
      nisn: (json['identity_number'] ??
              studentMap?['identity_number'] ??
              fallbackNisn)
          .toString(),
      className: (json['classroom'] ??
              studentMap?['classroom'] ??
              fallbackClass)
          .toString(),
      startDate: DateTime.tryParse(
            (leaveInfoMap['start_date'] ?? json['start_date'] ?? '').toString(),
          ) ??
          DateTime.now(),
      endDate: DateTime.tryParse(
            (leaveInfoMap['end_date'] ?? json['end_date'] ?? '').toString(),
          ) ??
          DateTime.now(),
      type: LeaveType.fromString(
        (leaveInfoMap['reason_type'] ?? json['reason_type'])?.toString(),
      ),
      leaveTime: (leaveInfoMap['leave_time'] ?? json['leave_time'])?.toString(),
      reason:
          (leaveInfoMap['description'] ?? json['description'] ?? '').toString(),
      documentPath: attachmentUrl,
      documentName:
          attachmentUrl != null && attachmentUrl.isNotEmpty
              ? attachmentUrl.split('/').last
              : null,
      status: LeaveStatus.fromString(
        (leaveInfoMap['status'] ?? json['status'])?.toString(),
      ),
      rejectReason:
          (leaveInfoMap['rejection_note'] ?? json['rejection_note'])
              ?.toString(),
      submittedAt: DateTime.tryParse(
            (json['submitted_at'] ?? json['created_at'] ?? '').toString(),
          ) ??
          DateTime.now(),
      verifiedBy: (json['verified_by'] ?? '').toString(),
    );
  }
}

class TeachingSchedule {
  final String id;
  final String day;
  final String startTime;
  final String endTime;
  final String className;
  final String roomName;
  final String subjectName;
  final CycleType cycle;
  final String teacherName;
  final bool hasJournal;

  const TeachingSchedule({
    required this.id,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.className,
    required this.roomName,
    required this.subjectName,
    required this.cycle,
    required this.teacherName,
    this.hasJournal = false,
  });

  TeachingSchedule copyWith({
    String? id,
    String? day,
    String? startTime,
    String? endTime,
    String? className,
    String? roomName,
    String? subjectName,
    CycleType? cycle,
    String? teacherName,
    bool? hasJournal,
  }) {
    return TeachingSchedule(
      id: id ?? this.id,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      className: className ?? this.className,
      roomName: roomName ?? this.roomName,
      subjectName: subjectName ?? this.subjectName,
      cycle: cycle ?? this.cycle,
      teacherName: teacherName ?? this.teacherName,
      hasJournal: hasJournal ?? this.hasJournal,
    );
  }

  factory TeachingSchedule.fromJson(
    Map<String, dynamic> json, {
    String fallbackTeacher = '-',
    String fallbackDay = '-',
    CycleType fallbackCycle = CycleType.putaran1,
  }) {
    String trimTime(String raw) {
      if (raw.length >= 5) return raw.substring(0, 5);
      return raw;
    }

    return TeachingSchedule(
      id: (json['id'] ?? '').toString(),
      day: (json['day_of_week'] ?? fallbackDay).toString(),
      startTime: trimTime((json['start_time'] ?? '').toString()),
      endTime: trimTime((json['end_time'] ?? '').toString()),
      className: (json['classroom_name'] ?? '-').toString(),
      roomName: (json['room_name'] ?? '-').toString(),
      subjectName: (json['subject_name'] ?? '-').toString(),
      cycle: json['cycle_type'] != null
          ? CycleType.fromString(json['cycle_type'].toString())
          : fallbackCycle,
      teacherName: (json['teacher_name'] ?? fallbackTeacher).toString(),
      hasJournal: json['has_journal'] == true,
    );
  }
}

class DelayedJournalAlert {
  final String scheduleId;
  final String subjectName;
  final String className;
  final String roomName;
  final String timeSlot;
  final int minutesLate;
  final String message;

  String get classroomName => className;

  const DelayedJournalAlert({
    required this.scheduleId,
    required this.subjectName,
    this.className = '-',
    this.roomName = '-',
    this.timeSlot = '',
    this.minutesLate = 30,
    required this.message,
  });

  factory DelayedJournalAlert.fromJson(Map<String, dynamic> json) {
    return DelayedJournalAlert(
      scheduleId: (json['schedule_id'] ?? '').toString(),
      subjectName: (json['subject_name'] ?? '-').toString(),
      className: (json['classroom_name'] ?? '-').toString(),
      roomName: (json['room_name'] ?? '-').toString(),
      timeSlot: (json['time_slot'] ?? '').toString(),
      minutesLate: (json['minutes_late'] as num?)?.toInt() ?? 30,
      message: (json['message'] ?? 'Jurnal mengajar belum diisi').toString(),
    );
  }
}

class TeachingJournal {
  final String id;
  final String scheduleId;
  final DateTime date;
  final String timeSlot;
  final String className;
  final String roomName;
  final String subjectName;
  final String teacherName;
  final String topic;
  final String? notes;
  final String? photoUrl;
  final CycleType cycle;
  final int totalStudents;
  final int presentCount;
  final int permissionCount;
  final int sickCount;
  final int absentCount;

  const TeachingJournal({
    required this.id,
    required this.scheduleId,
    required this.date,
    required this.timeSlot,
    required this.className,
    this.roomName = '-',
    required this.subjectName,
    required this.teacherName,
    required this.topic,
    this.notes,
    this.photoUrl,
    this.cycle = CycleType.putaran1,
    required this.totalStudents,
    required this.presentCount,
    this.permissionCount = 0,
    this.sickCount = 0,
    this.absentCount = 0,
  });

  factory TeachingJournal.fromJson(
    Map<String, dynamic> json, {
    String teacherName = '-',
  }) {
    final total = (json['attendance_count'] as num?)?.toInt() ?? 0;
    final present = (json['present_count'] as num?)?.toInt() ?? 0;
    final izin = (json['permission_count'] as num?)?.toInt() ?? 0;
    final sakit = (json['sick_count'] as num?)?.toInt() ?? 0;
    final alpa = (json['absent_count'] as num?)?.toInt() ??
        (total - present - izin - sakit).clamp(0, total);
    return TeachingJournal(
      id: (json['id'] ?? '').toString(),
      scheduleId: (json['schedule_id'] ?? '').toString(),
      date: DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
      timeSlot: (json['time_slot'] ?? '').toString(),
      className: (json['classroom_name'] ?? '-').toString(),
      roomName: (json['room_name'] ?? '-').toString(),
      subjectName: (json['subject_name'] ?? '-').toString(),
      teacherName: teacherName,
      topic: (json['teaching_material'] ?? '').toString(),
      notes: json['notes']?.toString(),
      photoUrl: json['activity_photo_url']?.toString(),
      cycle: CycleType.fromString(json['cycle_type']?.toString()),
      totalStudents: total,
      presentCount: present,
      permissionCount: izin,
      sickCount: sakit,
      absentCount: alpa,
    );
  }
}
