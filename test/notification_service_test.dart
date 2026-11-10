import 'package:flutter_test/flutter_test.dart';
import 'package:scp_mobile/services/in_app_notification_service.dart';
import 'package:scp_mobile/services/local_notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalNotificationService & InAppNotificationService Tests', () {
    test('InAppNotificationService dismiss can be called safely when no overlay is active', () {
      expect(() => InAppNotificationService.dismiss(), returnsNormally);
    });

    test('LocalNotificationService shows notification without unhandled exception', () async {
      expect(
        () async => await LocalNotificationService.showNotification(
          id: 1,
          title: 'Tes Notifikasi',
          body: 'Notifikasi berhasil dikirim ke HP',
        ),
        returnsNormally,
      );
    });

    test('LocalNotificationService cancel methods run safely', () async {
      expect(() async => await LocalNotificationService.cancel(1), returnsNormally);
      expect(() async => await LocalNotificationService.cancelAll(), returnsNormally);
    });
  });
}

