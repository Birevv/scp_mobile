import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:scp_mobile/models/models.dart';
import 'package:scp_mobile/screens/wali/wali_dashboard_screen.dart';
import 'package:scp_mobile/state/app_state.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('Wali Kelas Dashboard displays teaching schedule and journal actions',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final testSchedule = TeachingSchedule(
      id: '101',
      subjectName: 'Pemrograman Web',
      className: 'XI RPL 1',
      roomName: 'Lab Komputer 2',
      day: 'Senin',
      startTime: '07:00',
      endTime: '08:30',
      cycle: CycleType.putaran1,
      hasJournal: false,
      teacherName: 'SUJAR HARTONO, S.Pd',
    );

    final state = AppState.forTesting(
      user: const UserProfile(
        id: '4',
        name: 'SUJAR HARTONO, S.Pd',
        email: 'sujar@scp.sch.id',
        role: UserRole.waliKelas,
        identifier: '197501012000031001',
        className: 'XI RPL 1',
        avatarUrl: '',
      ),
      teachingSchedules: [testSchedule],
    );

    String? navigatedRoute;

    await tester.pumpWidget(
      MaterialApp(
        home: WaliDashboardScreen(
          state: state,
          onNavigate: (route) {
            navigatedRoute = route;
          },
        ),
      ),
    );
    await tester.pump();

    // Verify Homeroom components exist
    expect(find.text('Ringkasan Kehadiran Kelas'), findsOneWidget);
    expect(find.text('Verifikasi Terkendali'), findsOneWidget);

    // Verify Teacher components exist on Wali Kelas dashboard
    expect(find.text('Informasi Jadwal Mengajar'), findsOneWidget);
    expect(find.text('Jadwal Mengajar Hari Ini'), findsOneWidget);
    expect(find.text('Pemrograman Web'), findsOneWidget);
    expect(find.text('Belum Diisi'), findsNWidgets(2));
    expect(find.text('Isi Jurnal & Presensi Kelas'), findsOneWidget);

    // Verify Quick Access Menu includes Isi Jurnal, Jadwal Mengajar, and Riwayat Jurnal
    expect(find.text('Isi Jurnal'), findsOneWidget);
    expect(find.text('Jadwal Mengajar'), findsOneWidget);
    expect(find.text('Riwayat Jurnal'), findsOneWidget);

    // Tap "Isi Jurnal & Presensi Kelas" button
    await tester.ensureVisible(find.text('Isi Jurnal & Presensi Kelas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Isi Jurnal & Presensi Kelas'));
    await tester.pump();

    expect(navigatedRoute, equals('guru_journal_input'));
    expect(state.selectedJournalSchedule?.id, equals('101'));
  });

  testWidgets('Guru BK Dashboard displays teaching schedule and journal actions same as Wali Kelas',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final testSchedule = TeachingSchedule(
      id: '202',
      subjectName: 'Bimbingan Karir & Konseling',
      className: 'XII RPL 2',
      roomName: 'Ruang BK',
      day: 'Senin',
      startTime: '09:00',
      endTime: '10:30',
      cycle: CycleType.putaran1,
      hasJournal: false,
      teacherName: 'DRA. SITI RAHAYU, M.Pd',
    );

    final state = AppState.forTesting(
      user: const UserProfile(
        id: '5',
        name: 'DRA. SITI RAHAYU, M.Pd',
        email: 'siti@scp.sch.id',
        role: UserRole.guruBk,
        identifier: '198002022005012002',
        className: '',
        avatarUrl: '',
      ),
      teachingSchedules: [testSchedule],
    );

    String? navigatedRoute;

    await tester.pumpWidget(
      MaterialApp(
        home: WaliDashboardScreen(
          state: state,
          onNavigate: (route) {
            navigatedRoute = route;
          },
        ),
      ),
    );
    await tester.pump();

    // Verify Homeroom components exist for BK
    expect(find.text('Ringkasan Kehadiran Kelas'), findsOneWidget);
    expect(find.text('Verifikasi Terkendali'), findsOneWidget);

    // Verify Teacher components exist on Guru BK dashboard
    expect(find.text('Informasi Jadwal Mengajar'), findsOneWidget);
    expect(find.text('Jadwal Mengajar Hari Ini'), findsOneWidget);
    expect(find.text('Bimbingan Karir & Konseling'), findsOneWidget);
    expect(find.text('Belum Diisi'), findsNWidgets(2));
    expect(find.text('Isi Jurnal & Presensi Kelas'), findsOneWidget);

    // Verify Quick Access Menu includes all 8 menus including Isi Jurnal, Jadwal Mengajar, and Riwayat Jurnal
    expect(find.text('Isi Jurnal'), findsOneWidget);
    expect(find.text('Jadwal Mengajar'), findsOneWidget);
    expect(find.text('Riwayat Jurnal'), findsOneWidget);
    expect(find.text('Verifikasi Izin'), findsOneWidget);
    expect(find.text('Data Siswa'), findsOneWidget);
    expect(find.text('Rekap Presensi'), findsOneWidget);
    expect(find.text('Riwayat Perizinan'), findsOneWidget);
    expect(find.text('Kalender'), findsOneWidget);

    // Tap "Isi Jurnal & Presensi Kelas" button
    await tester.ensureVisible(find.text('Isi Jurnal & Presensi Kelas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Isi Jurnal & Presensi Kelas'));
    await tester.pump();

    expect(navigatedRoute, equals('guru_journal_input'));
    expect(state.selectedJournalSchedule?.id, equals('202'));
  });
}
