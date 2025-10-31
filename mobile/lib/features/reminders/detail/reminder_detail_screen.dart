import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';

class ReminderDetailScreen extends StatelessWidget {
  const ReminderDetailScreen({super.key, this.id});

  final String? id;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('reminderDetailTitle')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${localizations.translate('reminderDetailTitle')}: ${id ?? '-'}'),
            const SizedBox(height: 8),
            Text('${localizations.translate('timeField')}: --'),
            const SizedBox(height: 8),
            Text('${localizations.translate('medicationField')}: --'),
          ],
        ),
      ),
    );
  }
}
