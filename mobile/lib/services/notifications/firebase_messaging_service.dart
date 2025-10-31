import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_notification_service.dart';

final firebaseMessagingServiceProvider = Provider<FirebaseMessagingService>((ref) {
  final localNotifications = ref.read(localNotificationServiceProvider);
  return FirebaseMessagingService(
    FirebaseMessaging.instance,
    localNotifications,
  );
});

class FirebaseMessagingService {
  FirebaseMessagingService(this._messaging, this._localNotificationService);

  final FirebaseMessaging _messaging;
  final LocalNotificationService _localNotificationService;

  Future<void> initialize() async {
    await _messaging.requestPermission();
    await _messaging.setAutoInitEnabled(true);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        _localNotificationService.scheduleNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: notification.title ?? 'تنبيه',
          body: notification.body ?? '',
          scheduledDate: DateTime.now().add(const Duration(seconds: 1)),
        );
      }
    });
  }

  Future<String?> getToken() => _messaging.getToken();
}
