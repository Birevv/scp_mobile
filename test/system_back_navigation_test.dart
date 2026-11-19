import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:scp_mobile/main.dart';
import 'package:scp_mobile/models/models.dart';
import 'package:scp_mobile/screens/siswa/siswa_dashboard_screen.dart';
import 'package:scp_mobile/screens/siswa/siswa_leave_request_screen.dart';
import 'package:scp_mobile/screens/siswa/siswa_leave_status_screen.dart';
import 'package:scp_mobile/screens/siswa/siswa_schedule_screen.dart';
import 'package:scp_mobile/state/app_state.dart';
import 'package:scp_mobile/theme/app_theme.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('id_ID', null);
  });

  AppState createAuthenticatedSiswaState() {
    return AppState.forTesting(
      user: const UserProfile(
        id: '10',
        name: 'Budi Santoso',
        identifier: '12345',
        email: 'budi@smkn1bantul.sch.id',
        role: UserRole.siswa,
        className: 'XI RPL 1',
        avatarUrl: '',
      ),
    );
  }

  Future<void> pumpShell(WidgetTester tester, AppState state) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: ScpMainShell(
          state: state,
          splashDuration: const Duration(milliseconds: 50),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
  }

  testWidgets(
      'System back returns from secondary tab to dashboard instead of exiting',
      (WidgetTester tester) async {
    final state = createAuthenticatedSiswaState();
    await pumpShell(tester, state);

    expect(find.byType(SiswaDashboardScreen), findsOneWidget);

    // Root dashboard allows system pop (exit app).
    final rootPopScope = tester.widget<PopScope>(
      find.byWidgetPredicate((w) => w is PopScope).first,
    );
    expect(rootPopScope.canPop, isTrue);

    // Navigate to Jadwal tab.
    await tester.tap(find.text('Jadwal'));
    await tester.pumpAndSettle();
    expect(find.byType(SiswaScheduleScreen), findsOneWidget);

    // Secondary tab intercepts system back.
    final tabPopScope = tester.widget<PopScope>(
      find.byWidgetPredicate((w) => w is PopScope).first,
    );
    expect(tabPopScope.canPop, isFalse);

    // Simulate Android system Back button press.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // Should return to SiswaDashboardScreen.
    expect(find.byType(SiswaDashboardScreen), findsOneWidget);
  });

  testWidgets(
      'System back walks back through nested screens and respects unsaved form confirmation',
      (WidgetTester tester) async {
    final state = createAuthenticatedSiswaState();
    await pumpShell(tester, state);

    // Go to Perizinan tab.
    await tester.tap(find.text('Perizinan'));
    await tester.pumpAndSettle();
    expect(find.byType(SiswaLeaveStatusScreen), findsOneWidget);

    // Open Ajukan Izin form.
    await tester.tap(find.text('Ajukan Izin Sekarang'));
    await tester.pumpAndSettle();
    expect(find.byType(SiswaLeaveRequestScreen), findsOneWidget);

    // Enter unsaved reason text.
    await tester.enterText(
      find.byType(TextFormField).first,
      'Demam tinggi sejak tadi malam',
    );
    await tester.pump();

    // Pressing system back should show confirmation dialog, not leave immediately.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Batalkan Pengisian Form?'), findsOneWidget);
    expect(find.byType(SiswaLeaveRequestScreen), findsOneWidget);

    // Confirm cancellation -> returns to SiswaLeaveStatusScreen.
    await tester.tap(find.text('Ya, Batalkan'));
    await tester.pumpAndSettle();
    expect(find.byType(SiswaLeaveStatusScreen), findsOneWidget);

    // Pressing system back again returns to SiswaDashboardScreen.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(SiswaDashboardScreen), findsOneWidget);
  });
}
