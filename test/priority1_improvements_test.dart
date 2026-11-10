import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:scp_mobile/models/models.dart';
import 'package:scp_mobile/screens/siswa/siswa_dashboard_screen.dart';
import 'package:scp_mobile/screens/siswa/siswa_history_screen.dart';
import 'package:scp_mobile/screens/siswa/siswa_leave_request_screen.dart';
import 'package:scp_mobile/screens/siswa/siswa_leave_status_screen.dart';
import 'package:scp_mobile/screens/siswa/siswa_schedule_screen.dart';
import 'package:scp_mobile/state/app_state.dart';
import 'package:scp_mobile/theme/app_theme.dart';
import 'package:scp_mobile/widgets/cards/attendance_donut_card.dart';
import 'package:scp_mobile/widgets/cards/today_info_card.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('id_ID', null);
  });

  const testStudent = UserProfile(
    id: '1',
    name: 'Aditya Pratama',
    identifier: '0051234567',
    role: UserRole.siswa,
    className: 'XI RPL 2',
    email: 'aditya@smkn1bantul.sch.id',
    avatarUrl: '',
  );

  group('Priority 1 - Attendance Calculation Tests', () {
    testWidgets(
        'Scenario A: When zero attendance records exist, percentage displays dash (—) and NOT 100%',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: AttendanceDonutCard(
              hadirCount: 0,
              sakitCount: 0,
              izinCount: 0,
              alpaCount: 0,
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify dash is displayed and 100% is NOT displayed
      expect(find.text('—'), findsOneWidget);
      expect(find.text('100%'), findsNothing);
      expect(find.text('Belum ada data presensi'), findsOneWidget);

      // Verify all counts are 0
      expect(find.text('0'), findsNWidgets(4));
    });

    testWidgets(
        'Scenario B: When attendance data exists, percentage is calculated correctly using (Hadir / Total) * 100%',
        (WidgetTester tester) async {
      // 18 Hadir, 2 Sakit, 0 Izin, 0 Alpa = 20 Total meetings -> 18/20 * 100 = 90.0%
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: AttendanceDonutCard(
              hadirCount: 18,
              sakitCount: 2,
              izinCount: 0,
              alpaCount: 0,
              percentage: 90.0,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('90%'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets(
        'Scenario A in Dashboard: Siswa Dashboard with 0 attendance renders — and Belum ada data presensi',
        (WidgetTester tester) async {
      final state = AppState.forTesting(
        user: testStudent,
        studentSummary: const StudentAttendanceSummary(
          hadir: 0,
          sakit: 0,
          izin: 0,
          alpa: 0,
          total: 0,
          percentage: null,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: SiswaDashboardScreen(
            state: state,
            onNavigate: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('—'), findsOneWidget);
      expect(find.text('100%'), findsNothing);
      expect(find.text('Belum ada data presensi'), findsOneWidget);
    });
  });

  group('Priority 1 - Academic Calendar & Effective School Day Tests', () {
    testWidgets(
        'Scenario D: When calendar is unconfigured, displays neutral status and does NOT fabricate KBM or Sekolah Aktif',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: TodayInfoCard(
              formattedDate: 'Minggu, 8 November 2026',
              todayEvent: AcademicEventInfo.unconfigured(),
              activeCycle: CycleType.putaran1,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Informasi kalender belum tersedia.'), findsOneWidget);
      expect(find.text('Kalender Akademik'), findsOneWidget);
      expect(find.text('Belum Dikonfigurasi'), findsOneWidget);

      // Verify fabricated strings DO NOT appear
      expect(find.text('Hari Sekolah Efektif (KBM Normal)'), findsNothing);
      expect(find.text('Sekolah Aktif'), findsNothing);
    });

    testWidgets(
        'Scenario B: When calendar configures holiday, displays holiday status',
        (WidgetTester tester) async {
      const holidayEvent = AcademicEventInfo(
        id: 10,
        title: 'Tahun Baru Masehi',
        category: 'libur_nasional',
        categoryLabel: 'Libur Nasional',
        isHoliday: true,
        disableKbm: true,
        isConfigured: true,
        statusLabel: 'Hari Libur',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: TodayInfoCard(
              formattedDate: 'Kamis, 1 Januari 2026',
              todayEvent: holidayEvent,
              activeCycle: CycleType.putaran1,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Tahun Baru Masehi'), findsOneWidget);
      expect(find.text('Libur Nasional'), findsOneWidget);
      expect(find.text('Hari Libur'), findsOneWidget);
      expect(find.text('Sekolah Aktif'), findsNothing);
    });
  });

  group('Priority 1 - Leave Request CTA Duplication Tests', () {
    testWidgets(
        'Condition A: Empty state displays ONLY 1 CTA button and HIDES the Floating Action Button',
        (WidgetTester tester) async {
      final state = AppState.forTesting(user: testStudent);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: SiswaLeaveStatusScreen(
            state: state,
            onNewRequest: () {},
          ),
        ),
      );
      await tester.pump();

      // Verify empty state card and single button
      expect(find.text('Belum Ada Pengajuan'), findsOneWidget);
      expect(find.text('Ajukan Izin Sekarang'), findsOneWidget);

      // Verify FloatingActionButton is NOT displayed
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets(
        'Condition B: List state displays Floating Action Button and HIDES empty state CTA',
        (WidgetTester tester) async {
      final dummyLeave = LeaveRequest(
        id: '1',
        studentName: 'Aditya Pratama',
        nisn: '0051234567',
        className: 'XI RPL 2',
        type: LeaveType.sakit,
        startDate: DateTime(2026, 11, 2),
        endDate: DateTime(2026, 11, 3),
        reason: 'Sakit flu dan demam',
        status: LeaveStatus.pending,
        submittedAt: DateTime(2026, 11, 2),
      );
      final state = AppState.forTesting(
        user: testStudent,
        leaveRequests: [dummyLeave],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: SiswaLeaveStatusScreen(
            state: state,
            onNewRequest: () {},
          ),
        ),
      );
      await tester.pump();

      // Verify list item is displayed
      expect(find.text('Sakit flu dan demam'), findsOneWidget);

      // Verify FAB is displayed
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Ajukan Izin'), findsOneWidget);

      // Verify empty state CTA is NOT displayed
      expect(find.text('Ajukan Izin Sekarang'), findsNothing);
      expect(find.text('Belum Ada Pengajuan'), findsNothing);
    });
  });

  group('Priority 1 - Header & Navigation Consistency Tests', () {
    testWidgets(
        'Root page: SiswaScheduleScreen displays page name as main title without back button',
        (WidgetTester tester) async {
      final state = AppState.forTesting(user: testStudent);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: SiswaScheduleScreen(
            state: state,
            onBack: null,
          ),
        ),
      );
      await tester.pump();

      // Main title must be page name
      expect(find.text('Jadwal Pelajaran'), findsOneWidget);

      // No back button on root page
      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
    });

    testWidgets(
        'Root page: SiswaHistoryScreen displays page name as main title without back button',
        (WidgetTester tester) async {
      final state = AppState.forTesting(user: testStudent);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: SiswaHistoryScreen(
            state: state,
            onBack: null,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Riwayat Kehadiran'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
    });

    testWidgets(
        'Child page: SiswaLeaveRequestScreen has leading back button and warns on unsaved form exit',
        (WidgetTester tester) async {
      final state = AppState.forTesting(user: testStudent);
      bool backCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: SiswaLeaveRequestScreen(
            state: state,
            onBack: () => backCalled = true,
            onSuccess: () {},
          ),
        ),
      );
      await tester.pump();

      // Main title is page function
      expect(find.text('Form Pengajuan Izin'), findsOneWidget);

      // Leading back button is present
      final backBtn = find.byIcon(Icons.arrow_back_rounded);
      expect(backBtn, findsOneWidget);

      // Tap back with empty form -> exits directly
      await tester.tap(backBtn);
      await tester.pump();
      expect(backCalled, isTrue);

      // Reset and type a reason into form
      backCalled = false;
      await tester.enterText(
          find.byType(TextFormField).first, 'Perlu menghadiri acara keluarga');
      await tester.pump();

      // Tap back with unsaved data -> triggers confirmation dialog
      await tester.tap(backBtn);
      await tester.pumpAndSettle();

      expect(find.text('Batalkan Pengisian Form?'), findsOneWidget);
      expect(find.text('Lanjut Mengisi'), findsOneWidget);
      expect(find.text('Ya, Batalkan'), findsOneWidget);
      expect(backCalled, isFalse);

      // Tap 'Ya, Batalkan' in dialog -> now exits
      await tester.tap(find.text('Ya, Batalkan'));
      await tester.pumpAndSettle();
      expect(backCalled, isTrue);
    });
  });
}
