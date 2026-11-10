import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:scp_mobile/models/models.dart';
import 'package:scp_mobile/screens/guru/guru_journal_input_screen.dart';
import 'package:scp_mobile/screens/siswa/siswa_leave_request_screen.dart';
import 'package:scp_mobile/state/app_state.dart';
import 'package:scp_mobile/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets(
      'SiswaLeaveRequestScreen only permits realtime camera and excludes gallery or PDF files',
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

    // Verify realtime camera button is present
    expect(find.text('Ambil Foto Bukti (Kamera Realtime)'), findsOneWidget);

    // Verify file and PDF options are removed
    expect(find.text('Pilih File/PDF'), findsNothing);
    expect(find.text('Pilih Galeri'), findsNothing);
  });

  testWidgets(
      'GuruJournalInputScreen only permits realtime camera and excludes gallery files',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
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
        home: GuruJournalInputScreen(
          state: state,
          onBack: () {},
          onSuccess: () {},
        ),
      ),
    );
    await tester.pump();

    // Verify realtime camera button is present
    expect(find.text('Ambil Foto Kegiatan (Kamera Realtime)'), findsOneWidget);

    // Verify gallery upload option is removed
    expect(find.text('Pilih Galeri'), findsNothing);
    expect(find.text('Pilih File/PDF'), findsNothing);
  });
}
