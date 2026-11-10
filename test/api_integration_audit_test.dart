import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:scp_mobile/models/models.dart';
import 'package:scp_mobile/screens/shared/academic_calendar_screen.dart';
import 'package:scp_mobile/screens/siswa/siswa_schedule_screen.dart';
import 'package:scp_mobile/screens/wali/wali_students_screen.dart';
import 'package:scp_mobile/state/app_state.dart';
import 'package:scp_mobile/theme/app_theme.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('id_ID', null);
  });

  const testStudentUser = UserProfile(
    id: '1',
    name: 'Bima Revan Saputra',
    identifier: '0051234567',
    role: UserRole.siswa,
    className: 'XII RPL 1',
    email: 'bima@smkn1bantul.sch.id',
    avatarUrl: '',
  );

  const testHomeroomUser = UserProfile(
    id: '2',
    name: 'Dra. Sri Mulyani',
    identifier: '197505122000032001',
    role: UserRole.waliKelas,
    className: 'XII RPL 1',
    email: 'sri@smkn1bantul.sch.id',
    avatarUrl: '',
  );

  group('HomeroomStudent Model & JSON Deserialization', () {
    test('Correctly deserializes from Backend API format', () {
      final json = {
        'id': 101,
        'student_name': 'Ahmad Fauzi',
        'nisn': '0061234567',
        'classroom_name': 'XII RPL 1',
        'hadir': 18,
        'sakit': 2,
        'izin': 1,
        'alpa': 0,
        'total': 21,
        'percentage': 85.7,
        'today_status': 'Hadir',
        'is_auto_synced': false,
        'leave_reason': null,
      };

      final student = HomeroomStudent.fromJson(json);

      expect(student.id, '101');
      expect(student.name, 'Ahmad Fauzi');
      expect(student.nisn, '0061234567');
      expect(student.className, 'XII RPL 1');
      expect(student.hadir, 18);
      expect(student.sakit, 2);
      expect(student.izin, 1);
      expect(student.alpa, 0);
      expect(student.percentage, 85.7);
      expect(student.todayStatus, AttendanceStatus.hadir);
      expect(student.isAutoSynced, false);
    });

    test('DelayedJournalAlert defaults minutesLate to 30', () {
      const alert = DelayedJournalAlert(
        scheduleId: 's-1',
        subjectName: 'Basis Data',
        className: 'XII RPL 1',
        roomName: 'Lab 2',
        timeSlot: '07:15 - 09:15',
        message: 'Jurnal belum diisi (>30 menit terlambat)',
      );

      expect(alert.minutesLate, 30);
      expect(alert.message, contains('30 menit'));
    });
  });

  group('WaliStudentsScreen Integration Tests', () {
    testWidgets('Renders homeroom student list with attendance counts and badges', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockStudents = [
        const HomeroomStudent(
          id: '101',
          name: 'Ahmad Fauzi',
          nisn: '0061234567',
          className: 'XII RPL 1',
          hadir: 20,
          sakit: 1,
          izin: 0,
          alpa: 0,
          total: 21,
          percentage: 95.2,
          todayStatus: AttendanceStatus.hadir,
        ),
        const HomeroomStudent(
          id: '102',
          name: 'Bima Revan',
          nisn: '0061234568',
          className: 'XII RPL 1',
          hadir: 15,
          sakit: 3,
          izin: 2,
          alpa: 1,
          total: 21,
          percentage: 71.4,
          todayStatus: AttendanceStatus.sakit,
          isAutoSynced: true,
          leaveReason: 'Sakit',
        ),
      ];

      final state = AppState.forTesting(
        user: testHomeroomUser,
        homeroomStudents: mockStudents,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WaliStudentsScreen(state: state),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ahmad Fauzi'), findsOneWidget);
      expect(find.text('Bima Revan'), findsOneWidget);
      expect(find.textContaining('0061234567'), findsOneWidget);
      expect(find.text('Hadir'), findsWidgets);
      expect(find.text('Sakit'), findsWidgets);

      // Tap on student to view modal detail
      await tester.tap(find.text('Ahmad Fauzi'));
      await tester.pumpAndSettle();

      expect(find.textContaining('95.2%'), findsOneWidget);
      expect(find.text('Rekapitulasi Presensi Semester:'), findsOneWidget);
    });
  });

  group('SiswaScheduleScreen Weekly Schedules', () {
    testWidgets('Renders schedules for selected cycle and day tab', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockSchedules = [
        const TeachingSchedule(
          id: 'sc-1',
          subjectName: 'Pemrograman Mobile',
          teacherName: 'Pak Budi Hartono',
          className: 'XII RPL 1',
          roomName: 'Lab RPL',
          day: 'Senin',
          startTime: '07:15',
          endTime: '09:15',
          cycle: CycleType.putaran1,
        ),
        const TeachingSchedule(
          id: 'sc-2',
          subjectName: 'Basis Data Lanjut',
          teacherName: 'Bu Siti Rahma',
          className: 'XII RPL 1',
          roomName: 'Lab RPL',
          day: 'Selasa',
          startTime: '09:30',
          endTime: '11:30',
          cycle: CycleType.putaran1,
        ),
      ];

      final state = AppState.forTesting(
        user: testStudentUser,
        teachingSchedules: mockSchedules,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SiswaScheduleScreen(state: state),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Jadwal Pelajaran'), findsOneWidget);
      expect(find.textContaining('Putaran 1'), findsWidgets);
      expect(find.text('Aktif'), findsOneWidget);
      expect(find.text('Putaran 2'), findsOneWidget);
    });
  });

  group('AcademicCalendarScreen Integration Tests', () {
    testWidgets('Renders calendar header, month grid, and academic events for any user', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final now = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(now);

      final mockEvents = [
        AcademicEventInfo(
          id: 1,
          title: 'Penilaian Sumatif Akhir Semester',
          category: 'penilaian',
          categoryLabel: 'Ujian / Penilaian',
          isHoliday: false,
          disableKbm: true,
          startDate: todayStr,
          endDate: todayStr,
          description: 'Ujian teori kejuruan serentak di lab komputer',
        ),
        AcademicEventInfo(
          id: 2,
          title: 'Hari Guru Nasional',
          category: 'libur',
          categoryLabel: 'Libur Sekolah',
          isHoliday: true,
          disableKbm: true,
          startDate: todayStr,
          endDate: todayStr,
          description: 'Peringatan Hari Guru Nasional dan Apel Bersama',
        ),
      ];

      final state = AppState.forTesting(
        user: testStudentUser,
        calendarEvents: mockEvents,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AcademicCalendarScreen(state: state),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kalender Akademik'), findsOneWidget);
      expect(find.text('Penilaian Sumatif Akhir Semester'), findsWidgets);
      expect(find.text('Hari Guru Nasional'), findsWidgets);
      expect(find.text('Total Agenda'), findsOneWidget);
      expect(find.text('Libur / Non-KBM'), findsOneWidget);
      expect(find.text('Kegiatan Siswa'), findsOneWidget);
    });
  });
}
