import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/database/database_service.dart';
import '../../services/notifications/firebase_messaging_service.dart';
import '../../services/notifications/local_notification_service.dart';

final appInitializationProvider = FutureProvider<bool>((ref) async {
  final databaseService = ref.read(databaseServiceProvider);
  final messagingService = ref.read(firebaseMessagingServiceProvider);
  final localNotificationService = ref.read(localNotificationServiceProvider);

  await databaseService.initialize();
  await messagingService.initialize();
  await localNotificationService.initialize();

  return true;
});
