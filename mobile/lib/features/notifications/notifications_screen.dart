import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_localizations.dart';
import '../../services/notifications/local_notification_service.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final notificationService = ref.read(localNotificationServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('notificationsTitle')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(localizations.translate('notificationsTitle')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await notificationService.scheduleNotification(
                  id: 1,
                  title: localizations.translate('notificationTitle'),
                  body: localizations.translate('notificationBody'),
                  scheduledDate: DateTime.now().add(const Duration(minutes: 1)),
                );
              },
              child: Text(localizations.translate('scheduleNotification')),
            ),
          ],
        ),
      ),
    );
  }
}
