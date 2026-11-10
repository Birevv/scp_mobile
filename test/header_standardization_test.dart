import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:scp_mobile/models/models.dart';
import 'package:scp_mobile/screens/siswa/siswa_history_screen.dart';
import 'package:scp_mobile/screens/siswa/siswa_leave_status_screen.dart';
import 'package:scp_mobile/screens/siswa/siswa_schedule_screen.dart';
import 'package:scp_mobile/state/app_state.dart';
import 'package:scp_mobile/theme/app_theme.dart';
import 'package:scp_mobile/widgets/headers/scp_page_header.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('id_ID', null);
  });

  const testStudent = UserProfile(
    id: '1',
    name: 'BIMA REVAN SAPUTRA',
    identifier: '0051234567',
    role: UserRole.siswa,
    className: 'XII RPL 2',
    email: 'bima@smkn1bantul.sch.id',
    avatarUrl: '',
  );

  group('ScpPageHeader Component Visual & Structural Tests', () {
    testWidgets('Header renders with exact visual styling, typography, and colors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: ScpPageHeader(
              title: 'Jadwal Pelajaran',
              studentName: 'BIMA REVAN SAPUTRA',
              className: 'XII RPL 2',
              cycleLabel: 'Putaran 1',
              showCycleBadge: true,
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify Title
      final titleFinder = find.text('Jadwal Pelajaran');
      expect(titleFinder, findsOneWidget);
      final Text titleText = tester.widget(titleFinder);
      expect(titleText.style?.fontSize, equals(22));
      expect(titleText.style?.fontWeight, equals(FontWeight.w700));
      expect(titleText.style?.color, equals(Colors.white));

      // Verify Subtitle format: BIMA REVAN SAPUTRA • XII RPL 2
      final subtitleFinder = find.text('BIMA REVAN SAPUTRA • XII RPL 2');
      expect(subtitleFinder, findsOneWidget);
      final Text subtitleText = tester.widget(subtitleFinder);
      expect(subtitleText.style?.fontSize, equals(14));
      expect(subtitleText.style?.fontWeight, equals(FontWeight.w400));

      // Verify Badge
      final badgeFinder = find.text('Putaran 1');
      expect(badgeFinder, findsOneWidget);
      final Text badgeText = tester.widget(badgeFinder);
      expect(badgeText.style?.fontSize, equals(12));
      expect(badgeText.style?.fontWeight, equals(FontWeight.w600));
      expect(badgeText.style?.color, equals(Colors.white));

      // Verify Badge Container background color (#079F92) & border radius 999
      final badgeContainerFinder = find.ancestor(
        of: badgeFinder,
        matching: find.byType(Container),
      ).first;
      final Container badgeContainer = tester.widget(badgeContainerFinder);
      final BoxDecoration badgeDecoration = badgeContainer.decoration as BoxDecoration;
      expect(badgeDecoration.color, equals(const Color(0xFF079F92)));
      expect(badgeDecoration.borderRadius, equals(BorderRadius.circular(999)));

      // Verify Header Background color (#203F91) & bottom radius 24
      final headerContainerFinder = find.byType(ScpPageHeader);
      expect(headerContainerFinder, findsOneWidget);
      final Container rootContainer = tester.widget(
        find.descendant(of: headerContainerFinder, matching: find.byType(Container)).first,
      );
      final BoxDecoration rootDecoration = rootContainer.decoration as BoxDecoration;
      expect(rootDecoration.color, equals(const Color(0xFF203F91)));
      expect(
        rootDecoration.borderRadius,
        equals(const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        )),
      );
    });

    testWidgets('Cycle Badge is hidden when showCycleBadge is false or cycleLabel is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: ScpPageHeader(
              title: 'Perizinan Saya',
              studentName: 'BIMA REVAN SAPUTRA',
              className: 'XII RPL 2',
              cycleLabel: null,
              showCycleBadge: false,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Perizinan Saya'), findsOneWidget);
      expect(find.text('BIMA REVAN SAPUTRA • XII RPL 2'), findsOneWidget);
      expect(find.text('Putaran 1'), findsNothing);
      expect(find.text('Putaran 2'), findsNothing);
    });
  });

  group('Header Application Rules Across the 3 Main Screens', () {
    testWidgets('Jadwal Pelajaran Screen uses ScpPageHeader with cycle badge',
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

      expect(find.byType(ScpPageHeader), findsOneWidget);
      expect(find.text('Jadwal Pelajaran'), findsOneWidget);
      expect(find.text('BIMA REVAN SAPUTRA • XII RPL 2'), findsOneWidget);
      expect(find.text('Putaran 1'), findsWidgets); // badge + cycle button
    });

    testWidgets('Perizinan Saya Screen uses ScpPageHeader with hidden cycle badge',
        (WidgetTester tester) async {
      final state = AppState.forTesting(user: testStudent);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: SiswaLeaveStatusScreen(
            state: state,
            onBack: null,
            onNewRequest: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ScpPageHeader), findsOneWidget);
      expect(find.text('Perizinan Saya'), findsOneWidget);
      expect(find.text('BIMA REVAN SAPUTRA • XII RPL 2'), findsOneWidget);
      // Badge should be hidden in header
      final headerFinder = find.byType(ScpPageHeader);
      expect(
        find.descendant(of: headerFinder, matching: find.text('Putaran 1')),
        findsNothing,
      );
      expect(
        find.descendant(of: headerFinder, matching: find.text('Putaran 2')),
        findsNothing,
      );
    });

    testWidgets('Riwayat Kehadiran Screen uses ScpPageHeader with hidden cycle badge',
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

      expect(find.byType(ScpPageHeader), findsOneWidget);
      expect(find.text('Riwayat Kehadiran'), findsOneWidget);
      expect(find.text('BIMA REVAN SAPUTRA • XII RPL 2'), findsOneWidget);
      // Badge should be hidden in header
      final headerFinder = find.byType(ScpPageHeader);
      expect(
        find.descendant(of: headerFinder, matching: find.text('Putaran 1')),
        findsNothing,
      );
      expect(
        find.descendant(of: headerFinder, matching: find.text('Putaran 2')),
        findsNothing,
      );
    });
  });

  group('Responsive & Overflow Safety Tests', () {
    for (final width in [320.0, 360.0, 375.0, 412.0, 430.0]) {
      testWidgets('Header renders cleanly at ${width.toInt()}px width without overflow',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(Size(width, 700));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: ScpPageHeader(
                title: 'Jadwal Pelajaran Praktik Kejuruan',
                studentName: 'MUHAMMAD FACHRI KURNIAWAN PUTRA',
                className: 'XII REKAYASA PERANGKAT LUNAK 2',
                cycleLabel: 'Putaran 2',
                showCycleBadge: true,
              ),
            ),
          ),
        );
        await tester.pump();

        // Verify no RenderFlex overflow
        expect(tester.takeException(), isNull);
        expect(find.byType(ScpPageHeader), findsOneWidget);
      });
    }
  });
}

