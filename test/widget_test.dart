import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:scp_mobile/main.dart';
import 'package:scp_mobile/models/models.dart';
import 'package:scp_mobile/state/app_state.dart';
import 'package:scp_mobile/theme/app_theme.dart';
import 'package:scp_mobile/screens/shared/login_screen.dart';
import 'package:scp_mobile/screens/shared/unsupported_role_screen.dart';
import 'package:scp_mobile/screens/siswa/siswa_dashboard_screen.dart';
import 'package:scp_mobile/screens/siswa/siswa_leave_request_screen.dart';
import 'package:scp_mobile/screens/guru/guru_dashboard_screen.dart';
import 'package:scp_mobile/screens/wali/wali_dashboard_screen.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('SCP Mobile App boots and displays branding on Splash',
      (WidgetTester tester) async {
    final state = AppState.forTesting();

    await tester.pumpWidget(
      ScpApp(appState: state),
    );
    await tester.pump();

    expect(find.text('School Class Progress'), findsOneWidget);
    expect(find.text('SMK Negeri 1 Bantul'), findsOneWidget);
  });

  testWidgets('Login Screen displays authentic login form without demo buttons',
      (WidgetTester tester) async {
    final state = AppState.forTesting();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: LoginScreen(
          state: state,
          onLoginSuccess: () {},
        ),
      ),
    );
    await tester.pump();

    // Verify brand and title
    expect(find.text('School Class Progress'), findsOneWidget);
    expect(find.text('SMK Negeri 1 Bantul'), findsOneWidget);
    expect(find.text('Autentikasi Pengguna'), findsOneWidget);
    expect(find.text('Masuk ke Sistem'), findsOneWidget);

    // Verify fields
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Ingat Saya'), findsOneWidget);
    expect(find.text('Lupa Kata Sandi?'), findsOneWidget);
    expect(find.text('Informasi Bantuan Teknis'), findsOneWidget);

    // Verify NO demo persona buttons or bypasses
    expect(find.text('Pilih Persona untuk Masuk Langsung'), findsNothing);
    expect(find.text('Demo Persona'), findsNothing);
    expect(find.text('Bypass Login'), findsNothing);
  });

  const List<double> loginWidths = [320, 360, 375, 390, 414, 430];
  for (final width in loginWidths) {
    testWidgets('Login Screen renders cleanly at ${width.toInt()}px width without overflow',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(Size(width, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final state = AppState.forTesting();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: LoginScreen(
            state: state,
            onLoginSuccess: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Autentikasi Pengguna'), findsOneWidget);
      expect(find.text('Masuk ke Sistem'), findsOneWidget);
      expect(find.text('Informasi Bantuan Teknis'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  const List<double> targetWidths = [360, 375, 390, 412, 430];

  for (final width in targetWidths) {
    testWidgets('Siswa Dashboard renders cleanly at ${width.toInt()}px width',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(Size(width, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final state = AppState.forTesting(
        user: const UserProfile(
          id: '1',
          name: 'Aditya Pratama',
          identifier: '0051234567',
          role: UserRole.siswa,
          className: 'XI RPL 2',
          email: 'aditya@smkn1bantul.sch.id',
          avatarUrl: '',
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

      expect(find.text('Selamat datang,'), findsOneWidget);
      expect(find.text('Aditya Pratama'), findsOneWidget);
      expect(find.text('Ringkasan Kehadiran'), findsOneWidget);
      expect(find.text('Jadwal Pelajaran'), findsOneWidget);
      expect(find.text('Ajukan Izin'), findsOneWidget);
      expect(find.text('Riwayat Presensi'), findsOneWidget);
      expect(find.text('Perizinan Saya'), findsOneWidget);
      expect(find.text('Jadwal Hari Ini'), findsOneWidget);
    });

    testWidgets('Guru Dashboard renders cleanly at ${width.toInt()}px width',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(Size(width, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final state = AppState.forTesting(
        user: const UserProfile(
          id: '2',
          name: 'Budi Santoso, S.Kom',
          identifier: '198501012010011001',
          role: UserRole.guru,
          className: 'Guru Produktif RPL',
          email: 'budi@smkn1bantul.sch.id',
          avatarUrl: '',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: GuruDashboardScreen(
            state: state,
            onNavigate: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Informasi Jadwal Mengajar'), findsOneWidget);
      expect(find.text('Budi Santoso, S.Kom'), findsOneWidget);
      expect(find.text('Akses Cepat'), findsOneWidget);
      expect(find.text('Jadwal Mengajar Hari Ini'), findsOneWidget);
    });

    testWidgets(
        'Wali Kelas / BK Dashboard renders cleanly at ${width.toInt()}px width',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(Size(width, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final state = AppState.forTesting(
        user: const UserProfile(
          id: '3',
          name: 'Dra. Sri Wahyuni, M.Pd',
          identifier: '197505122000032002',
          role: UserRole.waliKelas,
          className: 'XI RPL 2',
          email: 'sri@smkn1bantul.sch.id',
          avatarUrl: '',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: WaliDashboardScreen(
            state: state,
            onNavigate: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Ringkasan Kehadiran Kelas'), findsOneWidget);
      expect(find.text('Dra. Sri Wahyuni, M.Pd'), findsOneWidget);
      expect(find.text('Verifikasi Izin'), findsOneWidget);
      expect(find.text('Data Siswa'), findsOneWidget);
      expect(find.text('Rekap Presensi'), findsOneWidget);
      expect(find.text('Riwayat Perizinan'), findsOneWidget);
      expect(find.text('Informasi Aktivitas Terbaru'), findsOneWidget);
    });
  }

  testWidgets('Siswa Leave Request Form supports all 4 leave types',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final state = AppState.forTesting(
      user: const UserProfile(
        id: '1',
        name: 'Aditya Pratama',
        identifier: '0051234567',
        role: UserRole.siswa,
        className: 'XI RPL 2',
        email: 'aditya@smkn1bantul.sch.id',
        avatarUrl: '',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: SiswaLeaveRequestScreen(
          state: state,
          onBack: () {},
          onSuccess: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Sakit'), findsOneWidget);
    expect(find.text('Izin'), findsOneWidget);
    expect(find.text('Pulang Cepat'), findsOneWidget);
    expect(find.text('Kegiatan Luar'), findsOneWidget);
    expect(find.text('Kirim Surat Izin'), findsOneWidget);
  });

  testWidgets(
      'Unsupported Role Screen directs non-mobile roles to web panel with logout',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final state = AppState.forTesting(
      user: const UserProfile(
        id: '99',
        name: 'Drs. Hendro Wibowo, M.Pd',
        identifier: '196803201994031005',
        role: UserRole.unsupported,
        roleBadge: 'Waka Kurikulum',
        className: 'Waka Kurikulum',
        email: 'waka@smkn1bantul.sch.id',
        avatarUrl: '',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: UnsupportedRoleScreen(state: state),
      ),
    );
    await tester.pump();

    expect(find.text('Akses Aplikasi Mobile Belum Tersedia untuk Role Ini'),
        findsOneWidget);
    expect(find.text('Keluar dari Akun (Logout)'), findsOneWidget);
  });
}
