import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:scp_mobile/models/models.dart';
import 'package:scp_mobile/screens/guru/guru_journal_history_screen.dart';
import 'package:scp_mobile/screens/guru/guru_journal_input_screen.dart';
import 'package:scp_mobile/services/api_service.dart';
import 'package:scp_mobile/state/app_state.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });
  const guruUser = UserProfile(
    id: '10',
    name: 'Budi Santoso, S.Kom',
    identifier: '198501012010011001',
    role: UserRole.guru,
    roleBadge: 'Guru',
    className: '-',
    email: 'budi@smkn1bantul.sch.id',
    avatarUrl: '',
  );

  final sampleJournal = TeachingJournal(
    id: '42',
    scheduleId: '7',
    date: DateTime(2026, 11, 19),
    timeSlot: '07:30 - 09:00 WIB',
    className: 'XII RPL 1',
    roomName: 'Lab Komputer RPL 1',
    subjectName: 'Pemrograman Web',
    teacherName: 'Budi Santoso, S.Kom',
    topic: 'Materi Awal Laravel',
    notes: 'Catatan awal',
    photoUrl: '/storage/journal_photos/old.jpg',
    cycle: CycleType.putaran1,
    totalStudents: 2,
    presentCount: 2,
  );

  testWidgets('GuruJournalHistoryScreen menampilkan tombol Edit Jurnal dan memanggil callback', (tester) async {
    final mockClient = MockClient((request) async {
      if (request.url.path.endsWith('/teacher/journals')) {
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'OK',
            'data': {
              'data': [
                {
                  'id': 42,
                  'schedule_id': 7,
                  'date': '2026-11-19',
                  'time_slot': '07:30 - 09:00 WIB',
                  'subject_name': 'Pemrograman Web',
                  'classroom_name': 'XII RPL 1',
                  'room_name': 'Lab Komputer RPL 1',
                  'cycle_type': 'Putaran 1',
                  'teaching_material': 'Materi Awal Laravel',
                  'notes': 'Catatan awal',
                  'activity_photo_url': '/storage/journal_photos/old.jpg',
                  'attendance_count': 2,
                  'present_count': 2,
                  'permission_count': 0,
                  'sick_count': 0,
                  'absent_count': 0,
                },
              ],
            },
          }),
          200,
        );
      }
      return http.Response(jsonEncode({'success': true, 'data': {}}), 200);
    });

    final state = AppState.forTesting(
      user: guruUser,
      apiService: ApiService(client: mockClient),
      teachingJournals: [sampleJournal],
    );

    TeachingJournal? tappedJournal;

    await tester.pumpWidget(
      MaterialApp(
        home: ListenableBuilder(
          listenable: state,
          builder: (_, _) => GuruJournalHistoryScreen(
            state: state,
            onEditJournal: (j) => tappedJournal = j,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Jurnal'), findsOneWidget);
    await tester.ensureVisible(find.text('Edit Jurnal'));
    await tester.tap(find.text('Edit Jurnal'));
    await tester.pump();

    expect(tappedJournal, isNotNull);
    expect(tappedJournal!.id, '42');
  });

  testWidgets('GuruJournalInputScreen mode edit memuat detail, mengubah data, dan mengirim PUT', (tester) async {
    Map<String, dynamic>? capturedPutBody;
    String? capturedPutPath;

    final mockClient = MockClient((request) async {
      if (request.method == 'GET' && request.url.path.endsWith('/teacher/journals/42')) {
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Detail jurnal berhasil diambil',
            'data': {
              'id': 42,
              'schedule_id': 7,
              'date': '2026-11-19',
              'time_slot': '07:30 - 09:00 WIB',
              'subject_name': 'Pemrograman Web',
              'classroom_name': 'XII RPL 1',
              'room_name': 'Lab Komputer RPL 1',
              'cycle_type': 'Putaran 1',
              'teaching_material': 'Materi Awal Laravel',
              'notes': 'Catatan awal',
              'activity_photo_url': '/storage/journal_photos/old.jpg',
              'attendance_count': 2,
              'present_count': 1,
              'permission_count': 0,
              'sick_count': 1,
              'absent_count': 0,
              'attendances': [
                {
                  'id': 1,
                  'student_id': 101,
                  'student_name': 'Ahmad Fauzan',
                  'identity_number': '0011223344',
                  'status': 'Hadir',
                  'notes': null,
                },
                {
                  'id': 2,
                  'student_id': 102,
                  'student_name': 'Bunga Citra',
                  'identity_number': '0011223345',
                  'status': 'Sakit',
                  'notes': 'Demam',
                },
              ],
            },
          }),
          200,
        );
      }

      if (request.method == 'PUT' && request.url.path.endsWith('/teacher/journals/42')) {
        capturedPutPath = request.url.path;
        capturedPutBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Jurnal dan presensi berhasil diperbarui',
            'data': {
              'id': 42,
              'schedule_id': 7,
              'date': '2026-11-19',
              'time_slot': '07:30 - 09:00 WIB',
              'subject_name': 'Pemrograman Web',
              'classroom_name': 'XII RPL 1',
              'room_name': 'Lab Komputer RPL 1',
              'cycle_type': 'Putaran 1',
              'teaching_material': capturedPutBody!['teaching_material'],
              'notes': capturedPutBody!['notes'],
              'activity_photo_url': '/storage/journal_photos/old.jpg',
              'attendance_count': 2,
              'present_count': 2,
              'permission_count': 0,
              'sick_count': 0,
              'absent_count': 0,
            },
          }),
          200,
        );
      }

      return http.Response(jsonEncode({'success': true, 'data': {}}), 200);
    });

    final state = AppState.forTesting(
      user: guruUser,
      apiService: ApiService(client: mockClient),
      teachingJournals: [sampleJournal],
    );

    var successCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: ListenableBuilder(
          listenable: state,
          builder: (_, _) => GuruJournalInputScreen(
            state: state,
            editingJournal: sampleJournal,
            onBack: () {},
            onSuccess: () => successCalled = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Jurnal & Presensi'), findsOneWidget);
    expect(find.text('Simpan Perubahan Jurnal'), findsOneWidget);
    expect(find.text('Foto dokumentasi tersimpan'), findsOneWidget);
    expect(find.text('Ambil Ulang Foto (Kamera Realtime)'), findsOneWidget);
    expect(find.text('Ahmad Fauzan'), findsOneWidget);
    expect(find.text('Bunga Citra'), findsOneWidget);

    // Ubah materi pembelajaran
    final topicField = find.byType(TextFormField).first;
    await tester.enterText(topicField, 'Materi Baru: Laravel REST API');
    await tester.pump();

    // Simpan perubahan
    await tester.tap(find.text('Simpan Perubahan Jurnal'));
    await tester.pumpAndSettle();

    expect(successCalled, isTrue);
    expect(capturedPutPath, endsWith('/teacher/journals/42'));
    expect(capturedPutBody?['teaching_material'], 'Materi Baru: Laravel REST API');
    expect((capturedPutBody?['attendances'] as List).length, 2);
  });
}
