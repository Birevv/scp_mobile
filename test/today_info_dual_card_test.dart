import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:scp_mobile/models/models.dart';
import 'package:scp_mobile/theme/app_theme.dart';
import 'package:scp_mobile/widgets/cards/today_info_card.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });
  group('TodayInfoCard Dual Card Widget Tests', () {
    testWidgets(
        'Renders left clock card with Jakarta and WIB real-time clock',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: TodayInfoCard(
              formattedDate: 'Selasa, 10 November 2026',
              todayEvent: AcademicEventInfo.unconfigured(),
              activeCycle: CycleType.putaran1,
            ),
          ),
        ),
      );
      await tester.pump();

      // Memastikan Sisi Kiri menampilkan jam digital & zona waktu
      expect(find.text('Jakarta'), findsOneWidget);
      expect(find.text('Waktu Standar WIB'), findsOneWidget);
      expect(find.text('Putaran 1'), findsOneWidget);
    });

    testWidgets(
        'Scenario A: When today has an active event (UKK), right card displays UKK ongoing status',
        (WidgetTester tester) async {
      const activeUkkEvent = AcademicEventInfo(
        id: 101,
        title: 'Ujian Kompetensi Keahlian (UKK) Rekayasa Perangkat Lunak',
        category: 'ukk',
        categoryLabel: 'Ujian Kejuruan',
        isHoliday: false,
        disableKbm: false,
        isConfigured: true,
        statusLabel: 'Sedang Berlangsung',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: TodayInfoCard(
              formattedDate: 'Selasa, 10 November 2026',
              todayEvent: activeUkkEvent,
              activeCycle: CycleType.putaran1,
            ),
          ),
        ),
      );
      await tester.pump();

      // Sisi kanan harus menampilkan UKK besar dan judul event
      expect(find.text('UKK'), findsOneWidget);
      expect(find.text('Ujian Kejuruan'), findsOneWidget);
      expect(find.textContaining('Ujian Kompetensi Keahlian (UKK)'), findsOneWidget);
    });

    testWidgets(
        'Scenario B: When no ongoing event today, right card displays countdown to upcoming event',
        (WidgetTester tester) async {
      final now = DateTime.now();
      final fiveDaysLater = now.add(const Duration(days: 5));
      final fiveDaysLaterStr =
          '${fiveDaysLater.year}-${fiveDaysLater.month.toString().padLeft(2, '0')}-${fiveDaysLater.day.toString().padLeft(2, '0')}';

      final upcomingExam = AcademicEventInfo(
        id: 202,
        title: 'Ujian Sekolah (US)',
        category: 'ujian',
        categoryLabel: 'Ujian Sekolah',
        isHoliday: false,
        disableKbm: true,
        startDate: fiveDaysLaterStr,
        endDate: fiveDaysLaterStr,
        isConfigured: true,
      );

      // Hari ini tidak ada event aktif (effective KBM)
      const regularDay = AcademicEventInfo(
        title: 'Hari Sekolah Efektif (KBM Normal)',
        category: 'effective_day',
        categoryLabel: 'Hari Sekolah Efektif',
        isHoliday: false,
        disableKbm: false,
        requiresAttendance: true,
        isConfigured: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: TodayInfoCard(
              formattedDate: 'Selasa, 10 November 2026',
              todayEvent: regularDay,
              activeCycle: CycleType.putaran1,
              calendarEvents: [upcomingExam],
            ),
          ),
        ),
      );
      await tester.pump();

      // Memastikan Sisi Kanan menampilkan hitung mundur ke Ujian Sekolah
      expect(find.text('Hitung Mundur'), findsOneWidget);
      expect(find.text('Ujian Sekolah (US)'), findsOneWidget);
      expect(find.text('5 Hari'), findsOneWidget);
      expect(find.text('Tinggal 5 hari lagi'), findsOneWidget);
    });

    testWidgets(
        'Scenario C: Tap on right card triggers onTapCalendarStatus callback',
        (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: TodayInfoCard(
              formattedDate: 'Selasa, 10 November 2026',
              todayEvent: AcademicEventInfo.unconfigured(),
              activeCycle: CycleType.putaran1,
              onTapCalendarStatus: () {
                tapped = true;
              },
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Informasi kalender belum tersedia.'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
