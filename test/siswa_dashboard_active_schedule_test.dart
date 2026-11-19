import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:scp_mobile/models/models.dart';
import 'package:scp_mobile/screens/siswa/siswa_dashboard_screen.dart';
import 'package:scp_mobile/state/app_state.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  const siswaUser = UserProfile(
    id: '1',
    name: 'Ahmad Fauzan',
    identifier: '0011223344',
    role: UserRole.siswa,
    roleBadge: 'Siswa',
    className: 'XII RPL 1',
    email: 'ahmad@smkn1bantul.sch.id',
    avatarUrl: '',
  );

  final schedules = [
    const TeachingSchedule(
      id: '1',
      day: 'Kamis',
      startTime: '07:30',
      endTime: '09:00',
      className: 'XII RPL 1',
      roomName: 'Ruang 101',
      subjectName: 'Matematika',
      cycle: CycleType.putaran1,
      teacherName: 'Pak Budi',
    ),
    const TeachingSchedule(
      id: '2',
      day: 'Kamis',
      startTime: '09:00',
      endTime: '10:30',
      className: 'XII RPL 1',
      roomName: 'Lab Bahasa',
      subjectName: 'Bahasa Inggris',
      cycle: CycleType.putaran1,
      teacherName: 'Bu Sari',
    ),
  ];

  testWidgets('Jam aktif sekarang kosong sebelum jam pertama & sesudah jam terakhir', (tester) async {
    final state = AppState.forTesting(
      user: siswaUser,
      teachingSchedules: schedules,
    );

    // Sebelum jam pertama (06:30)
    await tester.pumpWidget(
      MaterialApp(
        home: SiswaDashboardScreen(
          state: state,
          onNavigate: (_) {},
          clock: () => DateTime(2026, 11, 19, 6, 30),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Jam aktif sekarang:'), findsNothing);
    expect(find.text('Sedang Berlangsung'), findsNothing);

    // Sesudah jam terakhir (11:00)
    await tester.pumpWidget(
      MaterialApp(
        home: SiswaDashboardScreen(
          state: state,
          onNavigate: (_) {},
          clock: () => DateTime(2026, 11, 19, 11, 0),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('Jam aktif sekarang:'), findsNothing);
    expect(find.text('Sedang Berlangsung'), findsNothing);
  });

  testWidgets('Jam aktif sekarang berubah otomatis saat berganti jam pelajaran', (tester) async {
    final state = AppState.forTesting(
      user: siswaUser,
      teachingSchedules: schedules,
    );

    DateTime currentNow = DateTime(2026, 11, 19, 8, 15);

    await tester.pumpWidget(
      MaterialApp(
        home: SiswaDashboardScreen(
          state: state,
          onNavigate: (_) {},
          clock: () => currentNow,
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text('Jam aktif sekarang: 07:30 - 09:00 WIB (Matematika)'),
      findsOneWidget,
    );
    expect(find.text('Sedang Berlangsung'), findsOneWidget);

    // Simulasikan pergantian jam ke sesi kedua (09:00)
    currentNow = DateTime(2026, 11, 19, 9, 0);
    await tester.pump(const Duration(seconds: 1));

    expect(
      find.text('Jam aktif sekarang: 09:00 - 10:30 WIB (Bahasa Inggris)'),
      findsOneWidget,
    );
    expect(find.text('Sedang Berlangsung'), findsOneWidget);

    // Simulasikan jam sudah melewati sesi terakhir (10:35)
    currentNow = DateTime(2026, 11, 19, 10, 35);
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('Jam aktif sekarang:'), findsNothing);
    expect(find.text('Sedang Berlangsung'), findsNothing);
  });
}
