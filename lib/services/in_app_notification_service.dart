import 'package:flutter/material.dart';
import '../widgets/indicators/heads_up_notification_banner.dart';
import 'local_notification_service.dart';

/// InAppNotificationService - Pengelola Notifikasi Melayang (Heads-Up Banner) & Notifikasi Sistem HP
/// Menggunakan Overlay global untuk tampilan dalam aplikasi dan LocalNotificationService untuk notifikasi sistem (status bar / tray) Android/iOS.
class InAppNotificationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static OverlayEntry? _currentOverlay;

  /// Menampilkan banner notifikasi heads-up di layar aplikasi DAN mengirim notifikasi ke sistem HP
  static void show({
    BuildContext? context,
    required String title,
    required String message,
    String? timeLabel = 'Baru saja',
    String? primaryActionLabel,
    VoidCallback? onPrimaryAction,
    String? secondaryActionLabel = 'Tutup',
    VoidCallback? onSecondaryAction,
    Duration autoDismissDuration = const Duration(seconds: 5),
    bool sendToSystemNotification = true,
    int? notificationId,
    String? payload,
  }) {
    // 1. Kirim notifikasi nyata ke status bar & tray sistem HP
    if (sendToSystemNotification) {
      final id = notificationId ??
          DateTime.now().millisecondsSinceEpoch.remainder(100000);
      LocalNotificationService.showNotification(
        id: id,
        title: title,
        body: message,
        payload: payload,
      );
    }

    // 2. Tampilkan heads-up banner melayang di dalam aplikasi
    dismiss();

    final OverlayState? overlay =
        context != null ? Overlay.of(context) : navigatorKey.currentState?.overlay;

    if (overlay == null) return;

    _currentOverlay = OverlayEntry(
      builder: (ctx) => HeadsUpNotificationBanner(
        title: title,
        message: message,
        timeLabel: timeLabel,
        primaryActionLabel: primaryActionLabel,
        onPrimaryAction: onPrimaryAction,
        secondaryActionLabel: secondaryActionLabel,
        onSecondaryAction: onSecondaryAction,
        autoDismissDuration: autoDismissDuration,
        onDismiss: () {
          dismiss();
        },
      ),
    );

    overlay.insert(_currentOverlay!);
  }

  /// Menutup notifikasi aktif saat ini
  static void dismiss() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  /// Simulasi Notifikasi 15 Menit Sebelum Waktu Habis (Untuk Demo UKK & Uji Coba)
  static void simulateClassEndingSoon({
    BuildContext? context,
    String currentSubject = 'Pemrograman Perangkat Bergerak',
    String roomName = 'Lab Komputer RPL 2',
    String className = 'XII RPL 1',
    String endTime = '09:45',
    String nextSubject = 'Basis Data & SQL',
    String nextRoom = 'Lab Komputer RPL 1',
    String nextStartTime = '10:00',
    bool isTeacher = false,
    VoidCallback? onNavigateToSchedule,
    VoidCallback? onNavigateToJournal,
  }) {
    final title = '15 Menit Menuju Pergantian Jam (Selesai $endTime WIB)';
    final message = isTeacher
        ? 'Sesi mengajar "$currentSubject" di $className ($roomName) segera berakhir. Sesi berikutnya: "$nextSubject" di $nextRoom ($nextStartTime WIB).'
        : 'Pelajaran "$currentSubject" di $roomName segera berakhir. Sesi berikutnya: "$nextSubject" di $nextRoom ($nextStartTime WIB).';

    show(
      context: context,
      title: title,
      message: message,
      primaryActionLabel: isTeacher ? 'Isi Jurnal' : 'Lihat Jadwal',
      onPrimaryAction: isTeacher ? onNavigateToJournal : onNavigateToSchedule,
      secondaryActionLabel: 'Tutup',
      onSecondaryAction: () {},
      autoDismissDuration: const Duration(seconds: 6),
      sendToSystemNotification: true,
      payload: isTeacher ? 'guru_journal_input' : 'siswa_schedule',
    );
  }
}
