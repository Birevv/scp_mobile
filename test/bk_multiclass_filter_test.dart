import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:scp_mobile/models/models.dart';
import 'package:scp_mobile/screens/wali/wali_dashboard_screen.dart';
import 'package:scp_mobile/screens/wali/wali_students_screen.dart';
import 'package:scp_mobile/state/app_state.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Guru BK Multi-Classroom & Student Filter Tests', () {
    final assignedClasses = [
      const ReferenceOption(id: 1, name: 'X LPS 2'),
      const ReferenceOption(id: 2, name: 'X RPL 1'),
      const ReferenceOption(id: 3, name: 'X RPL 2'),
    ];

    final students = [
      const HomeroomStudent(
        id: '1',
        name: 'Ahmad Dahlan',
        nisn: '0061112221',
        className: 'X LPS 2',
        classroomId: 1,
        hadir: 18,
        sakit: 1,
        izin: 0,
        alpa: 0,
        total: 19,
        percentage: 94.7,
      ),
      const HomeroomStudent(
        id: '2',
        name: 'Budi Santoso',
        nisn: '0061112222',
        className: 'X RPL 1',
        classroomId: 2,
        hadir: 15,
        sakit: 0,
        izin: 1,
        alpa: 3, // >=3 Alpa
        total: 19,
        percentage: 78.9,
      ),
      const HomeroomStudent(
        id: '3',
        name: 'Citra Kirana',
        nisn: '0061112223',
        className: 'X RPL 2',
        classroomId: 3,
        hadir: 19,
        sakit: 0,
        izin: 0,
        alpa: 0,
        total: 19,
        percentage: 100.0,
      ),
    ];

    testWidgets('Guru BK dashboard shows assigned classroom count badge and class filter chips',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final state = AppState.forTesting(
        user: const UserProfile(
          id: '5',
          name: 'RYAWIDYANINGTYAS',
          email: 'rya@scp.sch.id',
          role: UserRole.guruBk,
          identifier: '198501012010012001',
          className: '',
          avatarUrl: '',
        ),
        classrooms: assignedClasses,
        homeroomStudents: students,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: WaliDashboardScreen(
            state: state,
            onNavigate: (_) {},
          ),
        ),
      );
      await tester.pump();

      // Check BK badge displays number of assigned classes
      expect(find.text('BK: 3 Kelas Binaan'), findsOneWidget);

      // Check class filter chips exist above Donut Card
      expect(find.text('Semua Kelas'), findsOneWidget);
      expect(find.text('X LPS 2'), findsOneWidget);
      expect(find.text('X RPL 1'), findsOneWidget);
      expect(find.text('X RPL 2'), findsOneWidget);
    });

    testWidgets('WaliStudentsScreen displays class filter chips with counts and filters list',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final state = AppState.forTesting(
        user: const UserProfile(
          id: '5',
          name: 'RYAWIDYANINGTYAS',
          email: 'rya@scp.sch.id',
          role: UserRole.guruBk,
          identifier: '198501012010012001',
          className: '',
          avatarUrl: '',
        ),
        classrooms: assignedClasses,
        homeroomStudents: students,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: WaliStudentsScreen(state: state),
        ),
      );
      await tester.pump();

      // Initially "Semua Kelas" is active and shows 3 students
      expect(find.text('Semua Kelas (3)'), findsOneWidget);
      expect(find.text('X LPS 2 (1)'), findsOneWidget);
      expect(find.text('X RPL 1 (1)'), findsOneWidget);
      expect(find.text('X RPL 2 (1)'), findsOneWidget);

      // Verify all 3 students appear in the list with class name prefix
      expect(find.text('Ahmad Dahlan'), findsOneWidget);
      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('Citra Kirana'), findsOneWidget);
      expect(find.text('X LPS 2 • NISN. 0061112221'), findsOneWidget);
      expect(find.text('X RPL 1 • NISN. 0061112222'), findsOneWidget);
      expect(find.text('X RPL 2 • NISN. 0061112223'), findsOneWidget);

      // Filter to X LPS 2 by tapping its chip (ensure visible in horizontal scroll)
      await tester.ensureVisible(find.text('X LPS 2 (1)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('X LPS 2 (1)'));
      await tester.pump();

      // Now only Ahmad Dahlan is shown
      expect(find.text('Ahmad Dahlan'), findsOneWidget);
      expect(find.text('Budi Santoso'), findsNothing);
      expect(find.text('Citra Kirana'), findsNothing);
      expect(find.text('1 Siswa'), findsOneWidget);

      // Filter back to "Semua Kelas"
      await tester.ensureVisible(find.text('Semua Kelas (3)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Semua Kelas (3)'));
      await tester.pump();

      expect(find.text('Ahmad Dahlan'), findsOneWidget);
      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('Citra Kirana'), findsOneWidget);
      expect(find.text('3 Siswa'), findsOneWidget);

      // Search student by query
      await tester.enterText(find.byType(TextField), 'Citra');
      await tester.pump();

      expect(find.text('Citra Kirana'), findsOneWidget);
      expect(find.text('Ahmad Dahlan'), findsNothing);
      expect(find.text('Budi Santoso'), findsNothing);
      expect(find.text('1 Siswa'), findsOneWidget);
    });

    testWidgets('Wali Kelas dashboard and students screen do NOT show multi-class filter chips (only 1 class)',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

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
        classrooms: [const ReferenceOption(id: 2, name: 'XI RPL 1')],
        homeroomStudents: [
          const HomeroomStudent(
            id: '2',
            name: 'Budi Santoso',
            nisn: '0061112222',
            className: 'XI RPL 1',
            classroomId: 2,
            hadir: 18,
            sakit: 0,
            izin: 1,
            alpa: 0,
            total: 19,
            percentage: 94.7,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: WaliDashboardScreen(
            state: state,
            onNavigate: (_) {},
          ),
        ),
      );
      await tester.pump();

      // Wali Kelas badge shows single class, not BK badge
      expect(find.text('Kelas Binaan: XI RPL 1'), findsOneWidget);
      expect(find.text('BK: 3 Kelas Binaan'), findsNothing);

      // Verify NO multi-class filter chips on Wali Kelas dashboard
      expect(find.text('Semua Kelas'), findsNothing);

      // Test WaliStudentsScreen for Wali Kelas
      await tester.pumpWidget(
        MaterialApp(
          home: WaliStudentsScreen(state: state),
        ),
      );
      await tester.pump();

      // Verify NO multi-class filter chips on Wali Kelas students screen
      expect(find.text('Semua Kelas'), findsNothing);
      expect(find.text('Semua Kelas (1)'), findsNothing);

      // Subtitle shows single class
      expect(find.text('XI RPL 1 • 1 Siswa Terdaftar'), findsOneWidget);

      // Student item displays NISN directly without redundant class tag
      expect(find.text('NISN. 0061112222'), findsOneWidget);
      expect(find.text('XI RPL 1 • NISN. 0061112222'), findsNothing);
    });
  });
}
