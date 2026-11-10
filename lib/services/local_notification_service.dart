import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// LocalNotificationService - Menangani Notifikasi Sistem di Status Bar & Tray HP
class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Callback ketika notifikasi sistem diklik oleh pengguna
  static void Function(String? payload)? onNotificationClick;

  /// Inisialisasi plugin notifikasi lokal untuk Android dan iOS
  static Future<void> initialize({
    void Function(String? payload)? onNotificationClickCallback,
  }) async {
    if (_isInitialized) return;

    if (onNotificationClickCallback != null) {
      onNotificationClick = onNotificationClickCallback;
    }

    // Android: Gunakan ikon launcher bawaan aplikasi (@mipmap/ic_launcher)
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS: Izin awal untuk alert, badge, dan sound
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          final payload = response.payload;
          if (onNotificationClick != null) {
            onNotificationClick!(payload);
          }
        },
      );

      _isInitialized = true;

      // Buat notification channel di Android secara eksplisit
      await _createNotificationChannel();

      // Minta izin notifikasi untuk Android 13+ (API 33+)
      await requestPermissions();
    } catch (e) {
      debugPrint('LocalNotificationService initialization error: $e');
    }
  }

  /// Membuat Notification Channel Android (Penting untuk Android 8.0+)
  static Future<void> _createNotificationChannel() async {
    if (kIsWeb || !Platform.isAndroid) return;

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'scp_schedule_channel',
        'Pengingat Jadwal & Kelas',
        description:
            'Notifikasi sistem untuk pergantian jam pelajaran dan kegiatan sekolah',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      await androidPlugin.createNotificationChannel(channel);
    }
  }

  /// Minta izin notifikasi (wajib untuk Android 13+)
  static Future<bool> requestPermissions() async {
    if (kIsWeb) return false;

    try {
      if (Platform.isAndroid) {
        final androidPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final granted = await androidPlugin?.requestNotificationsPermission();
        return granted ?? false;
      } else if (Platform.isIOS) {
        final iosPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        final granted = await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    }
    return false;
  }

  /// Menampilkan notifikasi ke HP (Status Bar / System Tray)
  static Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Pastikan service sudah diinisialisasi
    if (!_isInitialized) {
      await initialize();
    }

    // Detail notifikasi Android (Heads-up alert & status bar)
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'scp_schedule_channel',
      'Pengingat Jadwal & Kelas',
      channelDescription:
          'Notifikasi sistem untuk pergantian jam pelajaran dan kegiatan sekolah',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
      ),
    );

    // Detail notifikasi iOS
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.show(
        id,
        title,
        body,
        platformDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }

  /// Batalkan notifikasi tertentu berdasarkan ID
  static Future<void> cancel(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
    } catch (e) {
      debugPrint('Error canceling notification: $e');
    }
  }

  /// Batalkan semua notifikasi
  static Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Error canceling all notifications: $e');
    }
  }
}
